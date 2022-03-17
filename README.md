# Linux Dotfiles

## Requirements
This repo contains dotfiles for:
```
zsh vim tmux
```

- Vim requires [vim-plug](https://github.com/junegunn/vim-plug) installed
```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

- Tmux requires [tmux-yank](https://github.com/tmux-plugins/tmux-yank) installed:
```bash
mkdir .tmux && git clone https://github.com/tmux-plugins/tmux-yank ~/.tmux/yank
```


## Instructions
```bash
cd && git clone https://github.com/srokadev/dotfiles
[ -d ~/.config ] || mkdir ~/.config
rsync -abiP --suffix .old --exclude '.git' ~/dotfiles/ ~
rm -rf dotfiles
```
