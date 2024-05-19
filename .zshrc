# ----- ALIASES -----
alias ls="ls --color=auto"
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"
alias gti="git"
alias ..="cd .."

# ----- SSH-AGENT -----
ssh_dir="$HOME/.ssh"
SSH_ENV="$ssh_dir/environment"

start_agent() {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    # -- your ssh keys goes here
    # ssh-add <ssh key path>
}

# Check for files in the .ssh directory excluding authorized_hosts and known_hosts
files=$(find "$ssh_dir" -type f ! -name "authorized_keys" ! -name "known_hosts" ! -name "environment")

if [ -n "$files" ]; then
  if [ $(find ${SSH_ENV} -mmin -360) ]; then
      . "${SSH_ENV}" > /dev/null
      (ps -ef | grep "${SSH_AGENT_PID}[^\[]" &> /dev/null) || start_agent;
  else
      pkill ssh-agent;
      start_agent;
  fi
fi

# ----- EXPORTS -----
export EDITOR="vim"
bindkey -v
export TERM="xterm-256color"
export CLICOLOR=1

git_branch() {
  branch=$(git branch --show-current 2> /dev/null)
  [ -z "$branch" ] && branch="" || branch=" [$branch]"
  echo $branch
}

setopt PROMPT_SUBST
PS1="%F{red}%{%Gλ%} %(?.%F{blue}.%F{red})@%m%(?.%F{green}.%F{red})\$(git_branch) %(?.%F{blue}.%F{red})%B%~%b %#%f "

autoload -Uz compinit && compinit
export PATH=$HOME/.toolbox/bin:$PATH

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval $(dircolors ~/.config/Dracula.dircolors)

# ----- PATH -----
# export PATH=~/scripts:$PATH

# ----- HISTORY -----
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
