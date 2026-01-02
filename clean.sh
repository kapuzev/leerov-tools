#!/bin/bash

SCRIPT_DIR="$HOME/leerov-tools"

# Colors
blue=$'\033[0;34m'
reset=$'\033[0;39m'
green=$'\033[0;32m'
red=$'\033[0;31m'
purple=$'\033[0;35m'

# Function to show disk space
show_disk_space() {
    local phase="$1"
    echo "$purple"'|----|'"$phase"'|----|'
    echo "$purple"'|'"$blue"'Size  '"$purple"'|  '"$red"'Used  '"$purple"'|  '"$green"'Avail '"$purple"'|'"$reset"
    
    # Get disk usage for the current user's home directory
    disk_info=$(df -h "$HOME" | tail -1)
    if [ -n "$disk_info" ]; then
        total=$(echo "$disk_info" | awk '{print $2}')
        used=$(echo "$disk_info" | awk '{print $3}')
        avail=$(echo "$disk_info" | awk '{print $4}')
        echo "$purple|$blue$total $purple=  $red$used $purple+  $green$avail $purple|$reset"
    else
        # Fallback to root directory
        disk_info=$(df -h / | tail -1)
        total=$(echo "$disk_info" | awk '{print $2}')
        used=$(echo "$disk_info" | awk '{print $3}')
        avail=$(echo "$disk_info" | awk '{print $4}')
        echo "$purple|$blue$total $purple=  $red$used $purple+  $green$avail $purple|$reset"
    fi
}

# Show initial disk space
show_disk_space "Before cleanup"

# Cleanup paths array
paths=(
    # Slack cache paths
    ~/Library/Application\ Support/Slack/Code\ Cache/
    ~/Library/Application\ Support/Slack/Cache/
    ~/Library/Application\ Support/Slack/Service\ Worker/CacheStorage/
    ~/Library/Application\ Support/Slack/Cache/*
    ~/Library/Application\ Support/Slack/Service\ Worker/CacheStorage/*
    ~/Library/Application\ Support/Slack/Cache
    ~/Library/Application\ Support/Slack/Code\ Cache
    ~/Library/Application\ Support/Slack/Service\ Worker/CacheStorage

    # System caches
    ~/Library/Caches/*
    ~/Library/42_cache/
    ~/Library/Caches/CloudKit
    ~/Library/Caches/com.apple.akd
    ~/Library/Caches/com.apple.ap.adprivacyd
    ~/Library/Caches/com.apple.appstore
    ~/Library/Caches/com.apple.appstoreagent
    ~/Library/Caches/com.apple.cache_delete
    ~/Library/Caches/com.apple.commerce
    ~/Library/Caches/com.apple.iCloudHelper
    ~/Library/Caches/com.apple.imfoundation.IMRemoteURLConnectionAgent
    ~/Library/Caches/com.apple.keyboardservicesd
    ~/Library/Caches/com.apple.nbagent
    ~/Library/Caches/com.apple.nsservicescache.plist
    ~/Library/Caches/com.apple.nsurlsessiond
    ~/Library/Caches/storeassetd
    ~/Library/Caches/com.apple.touristd
    ~/Library/Caches/com.apple.tiswitcher.cache
    ~/Library/Caches/com.apple.preferencepanes.usercache
    ~/Library/Caches/com.apple.preferencepanes.searchindexcache
    ~/Library/Caches/com.apple.parsecd
    ~/Library/42_cache

    # Browser caches
    ~/Library/Application\ Support/Firefox/Profiles/*/storage
    ~/Library/Application\ Support/Google/Chrome/Default/Service\ Worker/CacheStorage/*
    ~/Library/Application\ Support/Google/Chrome/Crashpad/completed/*
    ~/Library/Safari/*
    ~/Library/Containers/com.apple.Safari/Data/Library/Caches/*

    # Development tools cache
    ~/.kube/cache/*
    ~/Library/Developer/Xcode/DerivedData/*
    ~/Library/Application\ Support/Code/User/workspaceStorage
    ~/Library/Application\ Support/Code/CacheData
    ~/Library/Application\ Support/Code/Cache
    ~/Library/Application\ Support/Code/Crashpad/completed
    ~/Library/Application\ Support/Code/CachedData
    ~/Library/Application\ Support/Code/CachedExtension
    ~/Library/Application\ Support/Code/CachedExtensions
    ~/Library/Application\ Support/Code/CachedExtensionVSIXs
    ~/Library/Application\ Support/Code/Code\ Cache
    ~/Library/Application\ Support/Code/CachedData/*
    ~/Library/Application\ Support/Code/Crashpad/completed/*
    ~/Library/Application\ Support/Code/User/workspaceStorage/*
    ~/Library/Caches/com.microsoft.VSCode.ShipIt
    ~/Library/Caches/com.microsoft.VSCode

    # Multimedia applications cache
    ~/Library/Application\ Support/Spotify/PersistentCache

    # Google update tools cache
    ~/Library/Caches/com.google.SoftwareUpdate
    ~/Library/Caches/com.google.Keystone

    # Docker cache
    ~/Library/Containers/com.docker.docker/Data/vms/*

    # System trash
    ~/.Trash/*

    # My trash
    $SCRIPT_DIR/*.out
    $HOME/Desktop/*.log
    $HOME/Desktop/*.tmp
)

# Count cleaned items
cleaned_count=0

# Cleanup loop
for path in "${paths[@]}"; do
    # Expand ~ to home directory
    expanded_path="${path/#\~/$HOME}"
    
    if [ -e "$expanded_path" ] || [ -L "$expanded_path" ]; then
        if rm -rf "$expanded_path" 2>/dev/null; then
            cleaned_count=$((cleaned_count + 1))
        fi
    fi
done

# Clean old downloads (30+ days old)
find ~/Downloads -name "*.dmg" -mtime +30 -delete 2>/dev/null
find ~/Downloads -name "*.zip" -mtime +30 -delete 2>/dev/null
find ~/Downloads -name "*.pkg" -mtime +30 -delete 2>/dev/null

# Additional cache cleanup
find ~/Library/Application\ Support -type d -iname "*cache*" 2>/dev/null -exec rm -rf {} \;

echo ""
echo "$purple"'Cleaned '"$cleaned_count"' items'

# Show disk space after cleanup
echo ""
show_disk_space "After cleanup"
echo "$purple"'|----|Cleanup ended|----|'"$reset"