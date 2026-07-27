#!/usr/bin/env bash
#
# photos-backup.sh — mirror this Mac's iCloud Photos library to the TrueNAS SMB share.
# macOS only (uses BSD `date`). Run it as:  caffeinate -s ./photos-backup.sh [MODE]
#
# Three osxphotos passes, so each iCloud photo category lands in the right place:
#   1. personal        library/louqash/icloud/YYYY/YYYY-MM/          (--not-shared --not-shared-library) [+download-missing]
#   2. shared albums   library/louqash/icloud/YYYY/<album>/          (--shared)                           [ no download-missing]
#   3. shared library  library/shared-library/icloud/YYYY/YYYY-MM/   (--shared-library)                   [+download-missing]
#
# Passes 1 & 2 are your own library (one Immich external library); pass 3 is the iCloud
# Shared Library you co-own with your wife (a separate library).
#
# download-missing (pull cloud-only originals from iCloud) is ON only for your own photos.
# It is OFF for shared albums, whose other-people contributions can't be downloaded and
# make Photos time out / hang.
#
# REQUIREMENTS (macOS 26.x):
#   * Photos.app must be running — the script launches it. --download-missing drives Photos
#     over AppleScript; if Photos is closed it silently stalls. (--use-photokit aborts on 26.x,
#     so it's deliberately unused. Never pass --live: in osxphotos that's a *filter*, not a
#     "include live video" option — live videos are exported by default.)
#   * osxphotos + exiftool installed; SMB share mounted at /Volumes/photos.
#   * Run under `caffeinate -s` and leave the Mac alone so it can't sleep mid-download.
#
# WHEN AM I DONE?
#   You will never see missing=0 — Live-Photo .mov clips and other people's shared-album
#   photos are permanently unrecoverable. The end-of-run SUMMARY is the source of truth: it
#   separates "real" (downloadable) missing from ignorable clips and prints COMPLETE /
#   ALL BACKED UP / CONVERGED once nothing downloadable is left to fetch.
#
# MODES:
#   (no args)        Incremental — photos since (last successful run − OVERLAP_DAYS). Routine
#                    command; fast. The first ever run has no stored date, so it runs FULL.
#   --full           Whole library. Run occasionally, and after a big manual cull.
#   YYYY [YYYY]      One year, or a year range (targeted; does not update the stored date).
#   --refresh N      Propagate iCloud deletions for the last N days: MOVE that window's
#                    exported files to a reversible _refresh-hold/ folder, then re-sync the
#                    SAME N-day window. Culled photos drop out of the backup; survivors are
#                    re-exported. Delete- and sync-windows are locked together so they can't
#                    drift. Nothing is hard-deleted — you purge the hold folder yourself.
#   -h | --help      Show usage.
#
# The backup is otherwise ADDITIVE (no --cleanup/--delete), so a bad run can never wipe the
# archive; --refresh is the only path that removes anything, and it only moves files.

set -euo pipefail

# ─────────────────────────────── configuration ───────────────────────────────
readonly SHARE_MOUNT="/Volumes/photos"
readonly PERSONAL_DEST="${SHARE_MOUNT}/library/louqash/icloud"       # passes 1 & 2
readonly SHARED_DEST="${SHARE_MOUNT}/library/shared-library/icloud"  # pass 3
readonly REPORTS_DIR="${SHARE_MOUNT}/_reports"
readonly STATE_FILE="${REPORTS_DIR}/.backup-state"
readonly HOLD_ROOT="${SHARE_MOUNT}/_refresh-hold"
readonly LOCK_DIR="${TMPDIR:-/tmp}/photos-backup.lock"   # guards against overlapping runs

readonly DATE_DIR="{created.year}/{created.year}-{created.mm}"        # personal / shared-library layout
readonly ALBUM_DIR="{created.year}/{album}"                          # shared-albums layout
readonly FILENAME="{created.strftime,%Y%m%d_%H%M%S}_{original_name}"  # date-prefix => Live Photo pairing + refresh selection
readonly OVERLAP_DAYS=7          # incremental window re-checks this many days before the last run
readonly PHOTOS_WARMUP_SECS=8    # let Photos.app come up before exporting

# Mutable globals, populated as the run proceeds:
mode=""             # incremental | full | range | refresh
run_start=""        # date this run started (stored as the new "last run")
date_args=()        # osxphotos --from-date/--to-date for this run (may be empty)
refresh_hold=""     # path of the _refresh-hold/<ts>/ dir, when mode=refresh
reports=()          # per-pass CSV report paths
last_run=""         # previous successful run date (from state file)
prev_real=-1        # previous run's real-missing count (for the convergence check)
real_missing=0      # this run's real-missing count (set by print_summary)

# ─────────────────────────────────── helpers ─────────────────────────────────
die()  { echo "ERROR: $*" >&2; exit 1; }

# Prevent two runs from interleaving the state file / refresh moves. mkdir is atomic, so it
# doubles as the lock; the EXIT trap releases it. A stale lock (from a killed run) must be
# removed by hand — we deliberately don't auto-steal it.
acquire_lock() {
  if ! mkdir "${LOCK_DIR}" 2>/dev/null; then
    local owner="?"; [ -f "${LOCK_DIR}/pid" ] && owner=$(cat "${LOCK_DIR}/pid")
    die "another run is in progress (lock ${LOCK_DIR}, pid ${owner}); remove it if stale"
  fi
  echo "$$" > "${LOCK_DIR}/pid"
  trap 'rm -rf "${LOCK_DIR}"' EXIT
}

usage() {
  cat <<EOF
Usage: caffeinate -s $(basename "$0") [MODE]

  (no args)      incremental sync — photos since last run − ${OVERLAP_DAYS}d (routine, fast)
  --full         whole library (run occasionally / after a big cull)
  YYYY [YYYY]    one year, or a year range (targeted)
  --refresh N    propagate iCloud deletions for the last N days (reversible via _refresh-hold/)
  -h, --help     this help

See the comment block at the top of this script for full details.
EOF
}

preflight() {
  command -v osxphotos >/dev/null || die "osxphotos not installed (uv tool install osxphotos)"
  command -v exiftool  >/dev/null || die "exiftool not installed (brew install exiftool)"
  command -v python3   >/dev/null || die "python3 not found"
  mount | grep -q " on ${SHARE_MOUNT} " || die "SMB share not mounted at ${SHARE_MOUNT}"
  mkdir -p "${PERSONAL_DEST}" "${SHARED_DEST}" "${REPORTS_DIR}"
}

# Load last_run / prev_real from the state file (both optional).
load_state() {
  [ -f "${STATE_FILE}" ] || return 0
  last_run=$(sed -n 's/^last_run=//p' "${STATE_FILE}" | head -1)
  local pr; pr=$(sed -n 's/^last_real_missing=//p' "${STATE_FILE}" | head -1)
  [[ "${pr}" =~ ^[0-9]+$ ]] && prev_real="${pr}"
}

# --refresh: move the last-N-days window (selected by the YYYYMMDD_ filename prefix, which
# all three passes share) into the hold dir, then point date_args at that same window.
# Moves stay within the share, so they're fast server-side renames.
refresh_window() {
  local days="$1" cutoff_int cutoff_date f prefix rel
  cutoff_int=$(date -j -v-"${days}"d +"%Y%m%d")
  cutoff_date=$(date -j -v-"${days}"d +"%Y-%m-%d")
  refresh_hold="${HOLD_ROOT}/$(date +%Y%m%d_%H%M%S)_last${days}d"

  echo "==> REFRESH: moving exported photos on/after ${cutoff_date} -> ${refresh_hold}"
  local moved=0
  while IFS= read -r f; do
    prefix=$(basename "$f"); prefix=${prefix:0:8}
    if [[ "${prefix}" =~ ^[0-9]{8}$ ]] && [ "$((10#${prefix}))" -ge "$((10#${cutoff_int}))" ]; then
      rel=${f#"${SHARE_MOUNT}/"}
      mkdir -p "${refresh_hold}/$(dirname "${rel}")"
      mv "$f" "${refresh_hold}/${rel}"
      moved=$((moved + 1))
    fi
  done < <(find "${PERSONAL_DEST}" "${SHARED_DEST}" -type f \
              -name '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_*' 2>/dev/null)

  echo "==> moved ${moved} file(s); re-syncing the same window (from ${cutoff_date})"
  date_args=(--from-date "${cutoff_date}")
}

# Incremental window = photos since (last_run − OVERLAP_DAYS). Falls back to FULL when there's
# no usable stored date.
resolve_incremental() {
  mode="incremental"
  local start=""
  [ -n "${last_run}" ] && start=$(date -j -v-"${OVERLAP_DAYS}"d -f "%Y-%m-%d" "${last_run}" +"%Y-%m-%d" 2>/dev/null || true)
  if [ -z "${start}" ]; then
    mode="full"
    echo "==> No usable stored date -> FULL run"
    return
  fi
  date_args=(--from-date "${start}")
  echo "==> INCREMENTAL run: photos since ${start} (last backup ${last_run} − ${OVERLAP_DAYS}d)"
}

# Parse argv -> set mode + date_args (and, for --refresh, move the window first).
determine_mode() {
  case "${1:-}" in
    -h|--help)
      usage; exit 0 ;;
    --refresh)
      mode="refresh"
      [[ "${2:-}" =~ ^[0-9]+$ ]] || die "--refresh needs a number of days, e.g. --refresh 30"
      refresh_window "$2" ;;
    --full)
      mode="full"; echo "==> FULL run (entire library)" ;;
    "")
      resolve_incremental ;;
    *)
      [[ "$1" =~ ^[0-9]{4}$ && "${2:-$1}" =~ ^[0-9]{4}$ ]] \
        || die "expected a year (YYYY[ YYYY]) or --full/--refresh/--help; got '$1'"
      local y1="$1" y2="${2:-$1}"
      [ "${y1}" -le "${y2}" ] || die "year range must be ascending; got '${y1} ${y2}'"
      mode="range"
      date_args=(--from-date "${y1}-01-01" --to-date "${y2}-12-31T23:59:59")
      echo "==> RANGE run: ${y1} .. ${y2} (does not update stored date)" ;;
  esac
}

launch_photos() {
  echo "==> Launching Photos.app (required for --download-missing)…"
  open -ga Photos
  sleep "${PHOTOS_WARMUP_SECS}"
}

# run_export LABEL DEST DIRECTORY [extra osxphotos flags...]
run_export() {
  local label="$1" dest="$2" directory="$3"; shift 3
  local report="${REPORTS_DIR}/${label}_$(date +%Y%m%d_%H%M%S).csv"
  reports+=("${report}")

  local cmd=(
    osxphotos export "${dest}"
    --update --ramdb --retry 3
    "$@"
    --directory "${directory}"
    --filename "${FILENAME}"
    --exiftool --edited-suffix "_edited" --touch-file
    --report "${report}"
  )
  # Append the date window only if this run has one — keeps --full filter-free and avoids
  # empty-array expansion under `set -u` on older bash.
  [ "${#date_args[@]}" -gt 0 ] && cmd+=("${date_args[@]}")

  echo "==> [${label}] exporting -> ${dest}  (dir: ${directory})"
  "${cmd[@]}"
  echo "==> [${label}] done -> ${report}"
}

run_all_passes() {
  run_export personal       "${PERSONAL_DEST}" "${DATE_DIR}"  --download-missing --not-shared --not-shared-library
  run_export shared-albums  "${PERSONAL_DEST}" "${ALBUM_DIR}" --shared --not-shared-library
  run_export shared-library "${SHARED_DEST}"   "${DATE_DIR}"  --download-missing --shared-library
}

# Classify each report's `missing` into real (downloadable) vs Live-Photo clips, print a
# summary + verdict, and set the global real_missing.
print_summary() {
  echo
  echo "════════════════════════ SUMMARY ════════════════════════"
  local out
  out=$(python3 - "${prev_real}" "${reports[@]}" <<'PY'
import csv, os, sys

prev = int(sys.argv[1]) if sys.argv[1].lstrip("-").isdigit() else -1
reports = sys.argv[2:]

tot_new = tot_real = tot_clips = 0
for path in reports:
    try:
        rows = list(csv.DictReader(open(path)))
    except FileNotFoundError:
        rows = []
    new     = sum(1 for r in rows if r.get("exported", "").strip() == "1")
    missing = [r for r in rows if r.get("missing", "").strip() == "1"]
    clips   = sum(1 for r in missing if r.get("filename", "").lower().endswith(".mov"))
    real    = len(missing) - clips
    tot_new += new; tot_real += real; tot_clips += clips
    label = os.path.basename(path).rsplit("_", 2)[0]
    print(f"  {label:15} exported(new)={new:<5} missing={len(missing):<5} (clips={clips}, real={real})")

print("  " + "-" * 54)
print(f"  new exported this run : {tot_new}")
print(f"  real items missing    : {tot_real}   (downloadable, not yet on NAS)")
print(f"  live-photo clips       : {tot_clips}   (ignorable — can't be pulled on 26.x)")
print()
if tot_real == 0 and tot_new == 0:
    print("  ✅ COMPLETE — nothing new, nothing real missing. Done.")
elif tot_real == 0:
    print(f"  ✅ ALL BACKED UP — 0 real missing ({tot_new} exported/restored this run).")
    print("     Re-run once to confirm it settles to COMPLETE (expect 0 new).")
elif tot_new == 0 and 0 <= prev <= tot_real:
    print(f"  ✅ CONVERGED — nothing downloadable left to fetch; the {tot_real} real +")
    print(f"     {tot_clips} clip items are permanently unavailable. You're done.")
else:
    print(f"  ⏳ STILL CONVERGING — {tot_new} exported, {tot_real} real still missing. Re-run.")
print(f"__REAL__={tot_real}")
PY
  )
  printf '%s\n' "${out}" | sed '/^__REAL__=/d'
  echo "══════════════════════════════════════════════════════════"
  real_missing=$(printf '%s\n' "${out}" | sed -n 's/^__REAL__=//p')
  [[ "${real_missing}" =~ ^[0-9]+$ ]] || real_missing=0
}

# After --refresh, tell the user how to finish (the hold folder is kept, not deleted).
print_refresh_epilogue() {
  [ "${mode}" = "refresh" ] || return 0
  cat <<EOF

==> REFRESH complete. Old copies of that window are HELD (not deleted) at:
      ${refresh_hold}
    Photos you culled in iCloud now exist ONLY there.
      • looks right?  purge:   rm -rf "${refresh_hold}"
      • went wrong?   restore: (cd "${refresh_hold}" && cp -a . "${SHARE_MOUNT}/")
EOF
}

# Only whole-library runs advance the incremental clock; range/refresh are targeted.
save_state() {
  [ "${mode}" = "incremental" ] || [ "${mode}" = "full" ] || return 0
  printf 'last_run=%s\nlast_real_missing=%s\n' "${run_start}" "${real_missing}" > "${STATE_FILE}"
  echo "==> Recorded backup: ${run_start} (real-missing=${real_missing})"
}

# ──────────────────────────────────── main ───────────────────────────────────
main() {
  case "${1:-}" in -h|--help) usage; exit 0 ;; esac
  acquire_lock
  preflight
  load_state
  run_start=$(date +%Y-%m-%d)
  determine_mode "$@"
  launch_photos
  run_all_passes
  print_summary
  print_refresh_epilogue
  save_state
}

main "$@"
