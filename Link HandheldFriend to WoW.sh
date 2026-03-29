#!/bin/zsh
set -e

link_wowfolder() {
    if [[ -d "$1" ]]; then
        echo "Linking using root WoW folder: $1"
        link_retail "$1/_retail_"
    fi
}

link_retail() {
    if [[ -d "$1" ]]; then
        echo "Linking Retail $1"
        if [[ -d "$1/Interface/AddOns/HandheldFriend" ]]; then
            echo "Removing existing HandheldFriend in $1"
            rm -rf "$1/Interface/AddOns/HandheldFriend"
        fi
        if [[ ! -d "$1/Interface/AddOns/HandheldFriend" ]]; then
            echo "Adding HandheldFriend in $1"
            mkdir -p "$1/Interface/AddOns"
            rsync -a --link-dest="$PWD/" --exclude='.*' "$PWD/" "$1/Interface/AddOns/HandheldFriend"
        fi
    fi
}

report_taskcomplete() {
    echo "Task Complete!"
}

# Run the script
link_wowfolder "/Applications/World of Warcraft"
report_taskcomplete
