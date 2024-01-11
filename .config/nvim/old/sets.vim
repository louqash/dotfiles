set nocompatible

filetype off
filetype plugin indent on

set shell=/usr/bin/zsh
set updatetime=500

" Colors
syntax on
set t_Co=256
colorscheme onedark
set cursorline
set background=dark
set termguicolors

" Persistant undo
set undofile

set nobackup
set ruler
set number
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

set wildmenu
