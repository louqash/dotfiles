-- Compile the current file with latexmk (pdflatex backend). latexmk reruns
-- pdflatex/bibtex as many times as needed for references and citations.
-- All artifacts (.aux, .log, .synctex.gz, and the .pdf) go into build/ next
-- to the .tex file, keeping the source directory clean.
-- MacTeX lives in /Library/TeX/texbin, which GUI-launched Neovim doesn't
-- inherit on PATH. latexmk also invokes pdflatex by name, so extend PATH
-- rather than hardcoding the latexmk path.
local texbin = "/Library/TeX/texbin"
if vim.fn.executable("latexmk") == 0 and vim.uv.fs_stat(texbin) then
  vim.env.PATH = vim.env.PATH .. ":" .. texbin
end

local function build_dir()
  return vim.fs.dirname(vim.api.nvim_buf_get_name(0)) .. "/build"
end

local function compile()
  vim.cmd.write()
  local file = vim.api.nvim_buf_get_name(0)
  vim.notify("latexmk: compiling " .. vim.fs.basename(file) .. "…", vim.log.levels.INFO)
  vim.system(
    { "latexmk", "-pdf", "-interaction=nonstopmode", "-synctex=1", "-outdir=build", file },
    { cwd = vim.fs.dirname(file) },
    vim.schedule_wrap(function(res)
      if res.code == 0 then
        vim.notify("latexmk: done → build/", vim.log.levels.INFO)
      else
        -- Surface the first pdflatex error line ("! ...") if there is one.
        local err = (res.stdout or ""):match("\n(![^\n]*)") or "see build/*.log"
        vim.notify("latexmk: failed — " .. err, vim.log.levels.ERROR)
      end
    end)
  )
end

local function open_pdf()
  local pdf = build_dir() .. "/" .. vim.fn.expand("%:t:r") .. ".pdf"
  if vim.uv.fs_stat(pdf) then
    vim.ui.open(pdf)
  else
    vim.notify("latexmk: no PDF yet, compile first (<leader>mc)", vim.log.levels.WARN)
  end
end

-- Live preview: latexmk -pvc watches the file and recompiles on every :w.
-- Skim auto-reloads the PDF on change; without it we fall back to `open`
-- (Preview.app), whose auto-refresh is unreliable. Watchers are kept in a
-- global table so re-sourcing this file can't orphan a running process.
_G.latexmk_watchers = _G.latexmk_watchers or {}

local function toggle_preview()
  local file = vim.api.nvim_buf_get_name(0)
  local watcher = _G.latexmk_watchers[file]
  if watcher then
    _G.latexmk_watchers[file] = nil
    watcher:kill("sigterm")
    vim.notify("latexmk: live preview stopped", vim.log.levels.INFO)
    return
  end

  vim.cmd.write()
  local cmd = { "latexmk", "-pdf", "-pvc", "-interaction=nonstopmode", "-synctex=1", "-outdir=build" }
  if vim.uv.fs_stat("/Applications/Skim.app") then
    vim.list_extend(cmd, { "-e", "$pdf_previewer = q[open -a Skim];" })
  end
  table.insert(cmd, file)

  _G.latexmk_watchers[file] = vim.system(
    cmd,
    { cwd = vim.fs.dirname(file) },
    vim.schedule_wrap(function(res)
      -- Only report exits we didn't cause by toggling off.
      if _G.latexmk_watchers[file] then
        _G.latexmk_watchers[file] = nil
        vim.notify("latexmk: live preview exited (code " .. res.code .. ")", vim.log.levels.WARN)
      end
    end)
  )
  vim.notify("latexmk: live preview started — recompiles on save", vim.log.levels.INFO)
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("LatexmkWatchers", { clear = true }),
  callback = function()
    for _, watcher in pairs(_G.latexmk_watchers) do
      watcher:kill("sigterm")
    end
  end,
})

vim.keymap.set("n", "<leader>mc", compile, { buffer = true, desc = "LaTeX: compile with latexmk" })
vim.keymap.set("n", "<leader>mp", toggle_preview, { buffer = true, desc = "LaTeX: toggle live preview" })
vim.keymap.set("n", "<leader>mo", open_pdf, { buffer = true, desc = "LaTeX: open built PDF" })
