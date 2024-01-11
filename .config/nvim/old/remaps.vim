let mapleader = " "

" Disabling arrow keys
noremap <UP> <NOP>
noremap <DOWN> <NOP>
noremap <LEFT> <NOP>
noremap <RIGHT> <NOP>

" Buffer nav
noremap <leader><leader> <c-^>
noremap <leader>b :bp<CR>
noremap <leader>n :bn<CR>
noremap <leader>c :bd<CR>

noremap <leader>pv :Ex<CR>

" Search in files
noremap <leader>s :Rg 

" Find file
noremap <C-p> :GFiles --recurse-submodules --exclude-standard<cr>
noremap <leader>pf :Files<cr>

