source plug.vim
source sets.vim
source remaps.vim


" setup for tagbar
set statusline+=%{gutentags#statusline()}
let g:lightline = {
      \ 'colorscheme': 'nord',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified', 'charvaluehex' ] ],
      \   'right':[ [ 'lineinfo' ],
      \             [ 'percent' ],
      \             [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component': {
      \   'charvaluehex': '0x%B'
      \ },
      \ }
let g:gutentags_project_root = [".git", "Cargo.toml"]

inoremap <S-Tab> <C-V><Tab>

" fzf
let g:fzf_layout = { 'down': '~20%' }
