#!/usr/bin/env zsh
# ajh17's ~/.zshrc

# Autoload {{{1
autoload -U edit-command-line
zle -N edit-command-line

# Source externals {{{1
source ~/.zsh/styles.zsh
source ~/.zsh/aliases
source ~/.zsh/ajh.zsh-theme
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.zsh/opp.zsh/opp.zsh
source ~/.zsh/opp.zsh/opp/surround.zsh
source `brew --prefix`/etc/autojump.sh
eval "$(rbenv init - --no-rehash zsh)"

# Variables {{{1
export EDITOR=vim
export KEYTIMEOUT=1
export CORRECT_IGNORE='_*'
export SSL_CERT_FILE=/usr/local/opt/curl-ca-bundle/share/ca-bundle.crt
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;33'
export BROWSER='open'
export PAGER='less'
export LESS='-F -g -i -M -R -S -w -X -z-4'
export LANG='en_US.UTF-8'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=yellow,bold'
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=magenta,bold'

# Settings {{{1
setopt alwaystoend completeinword completealiases pathdirs automenu autolist menucomplete
setopt prompt_subst extendedglob globdots globcomplete correct recexact
setopt sharehistory histignoredups histreduceblanks histignorespace
setopt banghist incappendhistory histexpiredupsfirst histignorealldups
setopt histfindnodups histsavenodups histverify
setopt pushdtohome pushdsilent autopushd pushdminus
setopt longlistjobs autoresume multios
setopt autocd cdablevars multios rmstarwait
setopt rcquotes autoparamslash markdirs
setopt chaselinks combiningchars
unsetopt flowcontrol caseglob clobber extendedhistory nomatch

# History {{{1
HISTFILE=$HOME/.cache/.zhistory
HISTSIZE=200000
SAVEHIST=200000

# Key Remappings (Vi-mode) {{{1
bindkey -v
bindkey -M vicmd "?" history-incremental-pattern-search-backward
bindkey -M vicmd "/" history-incremental-pattern-search-forward
bindkey -M vicmd v edit-command-line
bindkey -M vicmd 'u' undo
bindkey -M vicmd '^r' redo
bindkey -M vicmd '~' vi-swap-case
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[Z' reverse-menu-complete
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^l' clear-screen
bindkey '^k' kill-line
bindkey '^u' backward-kill-line
bindkey '^r' history-incremental-search-backward
bindkey '^p' history-search-backward
bindkey '^n' insert-last-word
bindkey '^?' backward-delete-char

# Functions {{{1
function mkcd {
    [[ -n "$1" ]] && mkdir -p "$1" && builtin cd "$1"
}

function cdls {
    builtin cd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}
