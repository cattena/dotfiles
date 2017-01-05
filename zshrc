#------------------------------------------------------------------
#
#     .zshrc 
#     Author: Alex Sánchez <kniren@gmail.com>
#     Source: https://github.com/kniren/dotfiles
#
# ------------------------------------------------------------------

# ---------------------------------------------------------------------
# Basic options
# ---------------------------------------------------------------------

fpath=(~/.zsh $fpath)
autoload -Uz compinit && compinit
autoload insert-unicode-char
zle -N insert-unicode-char

# Select completion style
zstyle ':completion:*' menu select
zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==02=01}:${(s.:.)LS_COLORS}")'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

bindkey '^[[Z' reverse-menu-complete
bindkey '^R' history-incremental-pattern-search-backward
bindkey '^U' insert-unicode-char
export KEYTIMEOUT=1
export HISTSIZE=1000
export SAVEHIST=1000
export HISTFILE="$HOME/.zsh_history"

# ZSH sourcing
source ~/.zsh/prompto.theme
source ~/.zprofile
eval `dircolors -b ~/.dircolors`

# ---------------------------------------------------------------------
# Functions
# ---------------------------------------------------------------------

# Color man pages
man() {
    env LESS_TERMCAP_mb=$'\E[01;0m' \
    LESS_TERMCAP_md=$'\E[01;38;5;6m' \
    LESS_TERMCAP_me=$'\E[0m' \
    LESS_TERMCAP_se=$'\E[0m' \
    LESS_TERMCAP_so=$'\E[38;5;9m' \
    LESS_TERMCAP_ue=$'\E[0m' \
    LESS_TERMCAP_us=$'\E[04;38;5;2m' \
    man "$@"
}

# ---------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------

# General purpose
#alias tmux="TERM=xterm-256color tmux"
alias z="zathura"
alias clc="clear"
alias copy="rsync -aP"
alias :q="exit"
alias :Q="exit"
alias :e="nvim"
alias :E="nvim"
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ssh="export TERM='xterm-256color'; ssh"
alias whosfat="du --max-depth=1 -h | sort --ignore-case --reverse -h | head -10"
alias ls="ls --color=always" 
alias grep="grep --color=always"
alias egrep="egrep --color=always"
alias youtube-mp3="youtube-dl -f 140 -ix --audio-format mp3"
alias octave='/usr/local/octave/3.8.0/bin/octave'
alias mame="cd ~/Games/mame0181-64bit/ && ./mame64"
alias vim='nvim'

# Git
alias g='git'
compdef g=git
alias gb='git branch'
compdef _git gb=git-branch
alias gst='git status'
compdef _git gst=git-status
alias gdiff='git diff'
gdv() { git diff -w "$@" | view - }
compdef _git gdv=git-diff
alias gmer='git merge'
compdef _git gm=git-merge
alias gco='git checkout'
compdef _git gco=git-checkout
alias gc='git commit -a -m'
alias grt='cd $(git rev-parse --show-toplevel || echo ".")' # Return to root of rep.
