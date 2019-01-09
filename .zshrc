# Cache completions
zstyle ':completion:*' use-cache true
zstyle ':completion' cache-path $HOME
autoload -Uz compinit && compinit -i -C -d $HOME/.zcompdump

# Completion options.
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose true
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' format '%F{yellow}Completing %d%f'
zstyle ':completion:*' warnings '%F{red}No matches for: %d%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors no=00 fi=00 di=01\;34 pi=33 so=01\;35 bd=00\;35 cd=00\;34 or=00\;41 mi=00\;45 ex=01\;32
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w'
zstyle ':completion:*:manuals' separate-sections true
zstyle -e ':completion:*' hosts 'reply=()'

# Aliases
alias cp="cp -vip"
alias ggrep="git grep --break --heading --line-number"
alias grep="grep -EI --color=auto"
alias gs="git status -sb"
alias head='head -n $(( $LINES - 10 ))'
alias mv="mv -vi"
alias pgrep="pgrep -l"
alias rcp="rsync -av --info=progress2"
alias rm="rm -vi"
alias tailf="tail -F"

# Settings
setopt completeinword menucomplete chaselinks rmstarwait \
    cdablevars autopushd pushdsilent interactivecomments \
    promptsubst transientrprompt extendedglob globdots globstarshort \
    incappendhistory histignoredups histignorealldups histreduceblanks \
    histignorespace banghist
unsetopt flowcontrol clobber nomatch

export HISTFILE=$HOME/.cache/.zhistory
export HISTSIZE=6000000
export SAVEHIST=$HISTSIZE
export PKG_PREFIX=/sw

# Functions
function ssh {
    if [[ "$TERM" =~ "^tmux-256color" ]]; then
        TERM=screen-256color command ssh "$@"
    else
        command ssh "$@"
    fi
}

function ls {
    if [[ -x "${PKG_PREFIX}/bin/gls" ]]; then
        "${PKG_PREFIX}/bin/gls" -hA --color "$@"
    else
        /bin/ls -hAG "$@"
    fi
}

# Force info to use vim keybindings, rather than emacs
function info {
    command info "$@" | vim -u NONE -N -RM -
}

# Create a directory and cd into it
function mkcd {
    mkdir -p "$1" && cd "$1"
}

# Better process grep
function pgi {
    process_list="$(ps ax -o pid,ppid,user,pcpu,pmem,rss,cputime,state,command)"
    head -n1 <(echo "$process_list")
    command grep -Ei --color "$1" <(echo "$process_list")
}

# If a session file exists, open it, otherwise, open vim, resolving any symlinks
function vim {
    if [[ $# -gt 0 ]]; then
        local -a args=()
        for arg in $@; do
            [[ -h "$arg" ]] && args+="$(readlink $arg)" || args+="$arg"
        done
        env vim "${args[@]}"
    elif [[ -f "Session.vim" ]]; then
        env vim -S
    else
        env vim -c LoadSession
    fi
}

# Shows the most used shell commands.
function history_stat {
    history 0 | awk '{print $2}' | sort | uniq -c | sort -n -r | head
}

# Key Maps
bindkey -v
autoload -Uz edit-command-line
zle -N edit-command-line

bindkey -M vicmd "/" history-incremental-pattern-search-forward
bindkey -M vicmd "?" history-incremental-pattern-search-backward
bindkey -M vicmd '^g' what-cursor-position
bindkey -M vicmd '^r' redo
bindkey -M vicmd 'G' end-of-buffer-or-history
bindkey -M vicmd 'gg' beginning-of-buffer-or-history
bindkey -M vicmd 'u' undo
bindkey -M vicmd '~' vi-swap-case
bindkey -M vicmd '^x^e' edit-command-line
bindkey '^x^e' edit-command-line
bindkey '^?' backward-delete-char
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^[[Z' reverse-menu-complete
bindkey '^a' vi-insert-bol
bindkey '^_' run-help
bindkey '^e' vi-add-eol
bindkey '^k' kill-line
bindkey '^l' clear-screen
bindkey '^n' insert-last-word
bindkey '^r' history-incremental-search-backward
bindkey '^s' history-incremental-search-forward
bindkey '^u' backward-kill-line
bindkey '^y' yank
bindkey '^w' backward-delete-word

function zle-line-init zle-keymap-select {
    prompt_char="${${KEYMAP/vicmd/%%}/(main|viins)/$}"
    zle reset-prompt
}

autoload -Uz add-zsh-hook
autoload -Uz vcs_info

zle -N zle-line-init
zle -N zle-keymap-select
add-zsh-hook precmd vcs_info

# Prompt
zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' formats ' %F{green}(%b%f%c%u%F{green})%f'
zstyle ':vcs_info:*' stagedstr '%F{blue}+%f'
zstyle ':vcs_info:*' unstagedstr '%F{red}.%f'
zstyle ':vcs_info:*' actionformats ' %F{green}(%b%f:%F{red}%a%f%c%u%F{green})%f'
zstyle ':vcs_info:git+set-message:*' hooks git-untracked
function +vi-git-untracked() {
    [[ -n $(git ls-files --exclude-standard --others 2>/dev/null) ]] && \
        hook_com[unstaged]+="%F{red}?%f"
}

PROMPT=$'%(0?,,%F{red}%? )%(#.%F{1}.%f)%n%f@%m:%F{blue}%~%f${vcs_info_msg_0_} %(#.#.$prompt_char) '
