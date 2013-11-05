##################################
## .zshenv                       #
## Defines environment variables #
##################################

if [[ "$OSTYPE" == darwin* ]]; then
    export BROWSER='open'
fi

#
# Editors
#
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

#
# Language
#
if [[ -z "$LANG" ]]; then
    export LANG='en_US.UTF-8'
fi

#
# Less
#
# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
if (( $+commands[lesspipe.sh] )); then
    export LESSOPEN='| /usr/local/bin/lesspipe.sh %s'
fi

#
# Paths
typeset -gU cdpath fpath mailpath manpath path
typeset -gxU MANPATH
typeset -gxUT INFOPATH infopath

# Set the list of directories that info searches for manuals.
infopath=(
/usr/local/share/info
/usr/share/info
$infopath
)

# Set the list of directories that man searches for manuals.
manpath=(
/usr/local/share/man
/usr/share/man
$manpath
)

for path_file in /etc/manpaths.d/*(.N); do
    manpath+=($(<$path_file))
done
unset path_file

# Set the list of directories that Zsh searches for programs.
path=(
/usr/local/{bin,sbin}
/usr/{bin,sbin}
/{bin,sbin}
~/bin
$path
)

for path_file in /etc/paths.d/*(.N); do
    path+=($(<$path_file))
done
unset path_file

#
# Temporary Files
#
if [[ -d "$TMPDIR" ]]; then
    export TMPDIR="/tmp/$USER"
    mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"
if [[ ! -d "$TMPPREFIX" ]]; then
    mkdir -p "$TMPPREFIX"
fi
