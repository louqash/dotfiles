set shell=/bin/zsh
let mapleader = "\<Space>"

call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-surround'
Plug 'Raimondi/delimitMate'
Plug 'itchyny/lightline.vim'
Plug 'preservim/nerdtree'

Plug 'dracula/vim', { 'as': 'dracula' }

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'mtdl9/vim-log-highlighting'

call plug#end()
filetype off
filetype plugin indent on

set updatetime=500

" Colors
syntax on
set t_Co=256
set cursorline
set termguicolors
colorscheme dracula

highlight Normal ctermbg=3028032 cterm=None gui=None guibg=#2e3440
highlight NonText ctermbg=3028032 cterm=None gui=None guibg=#2e3440
highlight Visual ctermbg=3028032 cterm=None gui=None guibg=#2e3440
highlight StatusLine ctermbg=3028032 cterm=None gui=None guibg=#2e3440

" Permanent undo
set undodir=~/.vimdid
set undofile

set nocompatible
set nobackup
set ruler
set number
set relativenumber
set title
set encoding=utf-8
set cursorline
set laststatus=2

set smarttab
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set incsearch		" Incrementgal search
set autowrite		" Automatically save before commands like :next and :ma
set linebreak   " Word wrap only on newline
set splitright

syntax on

hi MatchParen cterm=underline ctermbg=none ctermfg=162

" helps with find command
set path+=**
set wildmenu

" Disabling arrow keys
noremap <UP> <NOP>
noremap <DOWN> <NOP>
noremap <LEFT> <NOP>
noremap <RIGHT> <NOP>

" Buffer nav
noremap <leader><leader> <c-^>
noremap <leader>p :bp<CR>
noremap <leader>n :bn<CR>

noremap <leader>x :wq<CR>

" Close buffer
noremap <leader>c :bd<CR>

noremap <C-_> 0i//<Esc>j

" setup for tagbar
nmap <F8> :TagbarToggle<CR>
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

inoremap <S-Tab> <C-V><Tab>

" fzf
let g:fzf_layout = { 'down': '~20%' }
noremap <leader>s :Rg
noremap <expr> <C-p> (len(system('git rev-parse')) ? ':Files' : ':GFiles --recurse-submodules --exclude-standard')."\<cr>"

" Set this. Airline will handle the rest.
let g:airline#extensions#ale#enabled = 1
