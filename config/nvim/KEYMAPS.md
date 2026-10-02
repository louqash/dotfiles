# Neovim Keymap Reference

**Leader key:** `<Space>`

Mode column: `n` normal · `i` insert · `v` visual · `x` visual-block/charwise · `s` select

---

## General editing (`lua/louqash/remap.lua`)

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>ww` | n | Save file (`:w`) |
| `<leader>y` | n | Yank to system clipboard |
| `<leader>c` | v | Yank selection to system clipboard |
| `<leader>v` | v | Paste from system clipboard |
| `<leader>p` | x | Paste over selection without clobbering the register |
| `J` | v | Move selected lines **down** + reindent |
| `K` | v | Move selected lines **up** + reindent |
| `<C-d>` | n | Half page down, cursor centered |
| `<C-u>` | n | Half page up, cursor centered |

## File tree / netrw (`remap.lua` + `set.lua`)

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>pt` | n | Toggle netrw tree drawer on the left (`:Lexplore`) — press again to close |
| `<leader>pv` | n | Open netrw in an even 50/50 vertical split |

**Inside netrw:**

| Key | Action |
| --- | --- |
| `<Enter>` | Open file / expand folder |
| `-` | Go up to parent directory |
| `u` | Back to previous directory (history) |
| `%` | Create new file |
| `d` | Create new directory |
| `R` | Rename under cursor |
| `D` | Delete under cursor |
| `mf` / `mt` / `mm` / `mc` | Mark file / mark target / move / copy |
| `v` / `o` / `t` | Open in vertical split / horizontal split / new tab |
| `p` | Preview |
| `gh` | Toggle hidden (dotfiles) |
| `?` | netrw help |

## Telescope (`after/plugin/telescope.lua`)

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>pf` | n | Find files |
| `<C-p>` | n | Find **git-tracked** files |
| `<leader>fg` | n | Live grep |
| `<leader>ps` | v | Grep for the current visual selection |

## Undotree (`after/plugin/undotree.lua`)

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>u` | n | Toggle Undotree |

## Git / Fugitive (`after/plugin/fugitive.lua`)

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>gs` | n | Open Fugitive git status (`:Git`) |

---

## LSP (buffer-local, active when a language server attaches — `after/plugin/lsp.lua`)

| Key | Mode | Action |
| --- | --- | --- |
| `gd` | n | Go to definition |
| `K` | n | Hover documentation |
| `<leader>vws` | n | Workspace symbol search |
| `<leader>vd` | n | Open diagnostic float |
| `]d` | n | Next diagnostic |
| `[d` | n | Previous diagnostic |
| `<leader>vca` | n | Code action |
| `<leader>vrr` | n | List references |
| `<leader>vrn` | n | Rename symbol |
| `<leader>vf` | n | Format buffer |
| `<C-h>` | i | Signature help |
| `<leader>ch` | n | Switch source/header (clangd, C/C++ only) |

## Completion menu — nvim-cmp (insert mode, `after/plugin/lsp.lua`)

| Key | Mode | Action |
| --- | --- | --- |
| `<C-n>` | i | Select next completion item |
| `<C-p>` | i | Select previous completion item |
| `<C-y>` | i | Confirm the selected completion |
| `<C-Space>` | i | Trigger completion |
| `<C-e>` | i | Abort / close the completion menu |

## Snippets — LuaSnip (`after/plugin/lsp.lua`)

| Key | Mode | Action |
| --- | --- | --- |
| `<C-k>` | i, s | Jump to **next** snippet placeholder (e.g. next function argument) |
| `<C-j>` | i, s | Jump to **previous** snippet placeholder |

---

## Filetype-specific (buffer-local)

### LaTeX — `.tex` (`after/ftplugin/tex.lua`)

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>mc` | n | Compile with `latexmk` |
| `<leader>mp` | n | Toggle live preview |
| `<leader>mo` | n | Open built PDF |

### Typst — `.typ` (`after/ftplugin/typst.lua`)

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>mp` | n | Toggle browser live-preview |

---

## Handy built-ins (not custom-mapped, discussed for reference)

| Key / command | Action |
| --- | --- |
| `<C-w>o` / `:only` | Close all windows **except** the current one |
| `<C-w>w` | Cycle focus between windows |
| `<C-w>h/j/k/l` | Move focus to window left/down/up/right |
| `:qa` / `:qa!` | Quit all windows (force, discard changes) |
| `:wqa` | Write all + quit all |
