#!/usr/bin/env bash
# iTunes now playing script for tmux

ITUNES_TRACK=$(osascript <<EOF
if appIsRunning("iTunes") then
    tell app "iTunes" to get the name of the current track
end if

on appIsRunning(appName)
    tell app "System Events" to (name of processes) contains appName
end appIsRunning
EOF)

if test "x$ITUNES_TRACK" != "x"; then
    ITUNES_ARTIST=$(osascript <<EOF
        if appIsRunning("iTunes") then
            tell app "iTunes" to get the artist of the current track
        end if

        on appIsRunning(appName)
            tell app "System Events" to (name of processes) contains appName
        end appIsRunning
    EOF)

    if [ "$ITUNES_ARTIST" == "" ]; then
        echo ' | ♪' $ITUNES_TRACK
    else
        echo ' | ♪' $ITUNES_TRACK '-' $ITUNES_ARTIST
    fi
fi
