# ----- ALIASES -----
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"
alias gti="git"
alias ..="cd .."
alias vim="nvim"
alias vi="nvim"

# ----- SSH-AGENT -----
SSH_ENV="$HOME/.ssh/environment"

start_agent() {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    echo "Add keys you want to add to .zshrc:${LINENO} file"
    # ssh-add ~/.ssh/<YOUR_KEY>
}

if [ $(find ${SSH_ENV} -mtime -6h) ]; then
    . "${SSH_ENV}" > /dev/null
    (ps -ef | grep "${SSH_AGENT_PID}[^\[]" &> /dev/null) || start_agent;
else
    start_agent;
fi

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
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

# ----- EXPORTS -----
export EDITOR="vim"
export TERM="xterm-256color"
export CLICOLOR=1

bindkey -v
bindkey "^R" history-incremental-search-backward

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/opt/binutils/bin:$PATH"

autoload -Uz compinit && compinit
source <(fzf --zsh)

# Pure prompt
fpath+=("$(brew --prefix)/share/zsh/site-functions")
autoload -U promptinit; promptinit
prompt pure

# PYENV
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# DIRENV
eval "$(direnv hook zsh)"

