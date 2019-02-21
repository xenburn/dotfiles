# Settings
setopt COMBINING_CHARS
setopt CHASE_LINKS
setopt AUTO_PUSHD
setopt PROMPT_SUBST
setopt INTERACTIVE_COMMENTS
setopt EXTENDED_GLOB GLOB_DOTS
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS SHARE_HISTORY
unsetopt FLOW_CONTROL

# Aliases
unalias run-help 2>/dev/null
alias cp='cp -vip'
alias mv='mv -vi'
alias rm='rm -vi'
alias rcp='rsync -av --progress'
alias jobs='jobs -l'
alias pgrep='pgrep -fla'
alias grep='grep -EI --color=auto'
alias head='head -n $(( $LINES - 10 ))'

# Widgets
autoload -Uz run-help
autoload -Uz edit-command-line
autoload -Uz add-zsh-hook
autoload -Uz vcs_info
zle -N edit-command-line
zle -N zle-line-init
zle -N zle-keymap-select
autoload -Uz compinit

# Completions
compinit -C && { [[ ! -s "$HOME/.zcompdump.zwc" ]] && zcompile "$HOME/.zcompdump" }&!

zstyle ':completion::complete:*' use-cache on
zstyle ':completion:*' menu selection
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' matcher-list '' 'm:{a-z\-}={A-Z\_}' 'r:|?=** m:{a-z\-}={A-Z\_}'
zstyle ':completion:*' list-colors no=00 fi=00 di=01\;34 pi=33 so=01\;35 bd=00\;35 cd=00\;34 or=00\;41 mi=00\;45 ex=01\;32
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,ppid,user,comm'
zstyle ':completion:*:*:-command-:*:*' ignored-patterns '(_*|VCS_*|XPC_*)'
zstyle ':completion:*:*:*:users' ignored-patterns daemon nobody '_*'
zstyle ':completion:*:*:*:groups' ignored-patterns 'com.*' '_*'
zstyle -e ':completion:*' hosts 'reply=()'

# History
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=6000000
export SAVEHIST=$HISTSIZE

# Functions
ls() {
    if whence gls &>/dev/null; then
        command gls -hA --color=auto "$@"
    else
        command ls -hAG "$@"
    fi
}

ssh() {
    if [[ "$TERM" =~ "^tmux-256color" ]]; then
        TERM=screen-256color command ssh "$@"
    else
        command ssh "$@"
    fi
}

info() {
    command info "$@" | command vim -RMNu NONE -
}

pgi() {
    local process_list header matched mem_field
    process_list="$(ps ax -mo pid,ppid,pgid,pcpu,cputime,rss,state,tty,user,comm)"
    matched="$(echo "$process_list" | grep -Ei --color=always "$1")"

    if [[ ! -z "$matched" ]]; then
        header="$(echo "$process_list" | head -n1)"
        if whence gnumfmt &>/dev/null; then
            mem_field="$(echo "$header" | awk '{for (i = 1; i <= NF; i++) { if ($i ~ "RSS") print i }}')"
            printf '%s\n%s\n' "$header" "$matched" | gnumfmt --header --field "$mem_field" --from-unit=1024 --to=si | less
        else
            printf '%s\n%s\n' "$header" "$matched" | less
        fi
    else
        return 1
    fi
}

vim() {
    if (($# > 0)); then
        local -a args=()
        for arg in "$@"; do
            [[ -h "$arg" ]] && args+="$(readlink $arg)" || args+="$arg"
        done
        command vim "${args[@]}"
    elif [[ -f "Session.vim" ]]; then
        command vim -S
    else
        command vim -c LoadSession
    fi
}

peek() {
    if (($# == 1)); then
        if [[ ! -z "$TMUX" ]]; then
            tmux split-window "exec command vim -RM $1"
        else
            command vim -RM "$1"
        fi
    else
        printf >&2 'Usage: peek <file>\n'
    fi
}

# Key Maps
bindkey -v
bindkey -M vicmd "/" history-incremental-pattern-search-forward
bindkey -M vicmd "?" history-incremental-pattern-search-backward
bindkey -M vicmd '^g' what-cursor-position
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
bindkey '^n' insert-last-word
bindkey '^r' history-incremental-search-backward
bindkey '^s' history-incremental-search-forward
bindkey '^u' backward-kill-line
bindkey '^y' yank
bindkey '^w' backward-delete-word

# Prompt
zle-line-init zle-keymap-select() {
    prompt_char="${${KEYMAP/vicmd/%%}/(main|viins)/$}"
    zle reset-prompt
}
precmd() { vcs_info }
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' formats ' %F{green}(%b%f%c%u%F{green})%f'
zstyle ':vcs_info:*' actionformats ' %F{green}(%b%f:%F{red}%a%f%c%u%F{green})%f'
zstyle ':vcs_info:*' stagedstr '%F{blue}+%f'
zstyle ':vcs_info:*' unstagedstr '%F{red}.%f'
PROMPT=$'%(0?,,%F{red}%? )%(#.%F{1}.%f)%n%f@%m:%F{blue}%~%f${vcs_info_msg_0_} %(#.#.$prompt_char) '
