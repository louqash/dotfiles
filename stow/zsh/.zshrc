# ----- ALIASES -----
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"
alias gti="git"
alias ..="cd .."
alias vim="nvim"
alias vi="nvim"

# ----- HISTORY FIX -----
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
unsetopt BEEP                    # Disable terminal bell.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

# ----- REMOTE SHELL -----
# Preserve the locale, terminal type, and forwarded SSH agent from the server.
export EDITOR=nvim
export VISUAL=nvim
[[ -n "${LANG:-}" ]] || export LANG=C.UTF-8

typeset -U path PATH
path=("$HOME/.local/bin" $path)
[[ ! -d "$HOME/.pyenv/bin" ]] || path=("$HOME/.pyenv/bin" $path)
fpath=("$HOME/.zfunc" $fpath)

autoload -Uz compinit
compinit
bindkey -v
bindkey "^R" history-incremental-search-backward
bindkey "^I" expand-or-complete

# Older distribution packages ship fzf bindings as separate files.
if (( $+commands[fzf] )); then
  if fzf --help | command grep -q -- '--zsh'; then
    source <(fzf --zsh)
  else
    for bindings in /usr/share/doc/fzf/examples/key-bindings.zsh /usr/share/fzf/key-bindings.zsh; do
      if [[ -r "$bindings" ]]; then
        source "$bindings"
        break
      fi
    done
  fi
fi

# A built-in prompt needs no additional installation and identifies the host.
PROMPT='%F{green}%n@%m%f %F{blue}%~%f %# '
(( ! $+commands[pyenv] )) || eval "$(pyenv init - zsh)"
(( ! $+commands[direnv] )) || eval "$(direnv hook zsh)"

[[ ! -f "$HOME/.zshrc.local" ]] || source "$HOME/.zshrc.local"
