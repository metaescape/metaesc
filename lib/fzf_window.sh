#!/usr/bin/env bash
# Script: window_management.sh
# Description: This script enhances window management using fzf and wmctrl.
# It allows the user to interactively select a window from a list and perform actions like swapping or killing.
# Features:
# 1. Window Selection: Displays a list of windows using fzf. The user can select a window from this list.
# 2. Swap Windows: By pressing '/', the script swaps the currently focused window with the selected one.
# 3. Kill Window: By pressing ',', the script kills the process associated with the currently focused window.
# 4. Focus Window: By pressing 'Enter', the script focuses on the selected window.
# Dependencies: Requires 'wmctrl', 'fzf', 'xdotool', and 'i3-msg' for window manipulation and selection.
# Usage: Run the script to interactively choose and manage windows in an i3 environment.
# deprecated, use ~/metaesc/lib/ivy-xwish.el instead

win=$(wmctrl -l | tr -s ' ' | grep -v "select_window\|Floating" |\
        fzf --height 50%  --header ', to kill; / to swap' --expect=/,,)
current_win_id=$(cat /tmp/current_win_id)

[[ -z ${win} ]] && exit;
echo "$win" | grep '^/' > /dev/null && { #swap
    id=$(echo $win | tail -1 | cut -d ' ' -f2) #second
    i3-msg "[id=$current_win_id] swap container with id $id"
    # i3-msg "restart" #fix window tree update delay
    exit;
} 
echo "$win" | grep '^,' > /dev/null && { #switch
    pid=$(xdotool getwindowpid $current_win_id)
    kill -9 $pid
    # i3-msg [id=$id] focus
}

# use enter to select 
id=$(echo $win | tail -1 | cut -d ' ' -f1) #first
i3-msg [id=$id] focus
