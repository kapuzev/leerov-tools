#!/bin/bash

SCRIPT_DIR="$HOME/leerov-tools"

# Colors
blue=$'\033[0;34m'
reset=$'\033[0;39m'
green=$'\033[0;32m'
red=$'\033[0;31m'
purple=$'\033[0;35m'

# Initial total space, used and available

echo "$purple"'|----|Before cleanup|----|'
echo "$purple"'|'"$blue"'Size  '"$purple"'|  '"$red"'Used  '"$purple"'|  '"$green"'Avail '"$purple"'|'"$reset"
df -h | grep Users | awk -v purple="$purple" -v green="$green" -v blue="$blue" -v red="$red" '{print purple "|" blue $2 " " purple "=  " red $3 " " purple "+  " green $4 " " purple "|"}'
# Cleanup...
rm -rf ~/Library/Application\ Support/Slack/Code\ Cache/ 2>/dev/zero
rm -rf ~/Library/Application\ Support/Slack/Cache/ 2>/dev/zero
rm -rf ~/Library/Application\ Support/Slack/Service\ Worker/CacheStorage/ 2>/dev/zero

### These lines delete all your Visual Code data

#rm -rf ~/Library/ApplicationSupport/CrashReporter/* 2>/dev/zero
#rm -rf ~/Library/Application\ Support/Code/* 2>/dev/zero
#rm -rf ~/Library/Group\ Containers/* 2>/dev/zero

# Cleanup with array of paths
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
    ~/Library/Application\ Support/Firefox/Profiles/hdsrd79k.default-release/storage
    ~/Library/Application\ Support/Google/Chrome/Default/Service\ Worker/CacheStorage/*
    ~/Library/Application\ Support/Google/Chrome/Crashpad/completed/*
    ~/Library/Safari/*
    ~/Library/Containers/com.apple.Safari/Data/Library/Caches/*

    # Development tools cache
    ~/.kube/cache/*
    ~/Library/Developer/Xcode/*
    ~/Library/Application\ Support/Code/User/workspaceStorage
    ~/Library/Application\ Support/Code/Cache/Library/Application\ Support/Code/Cachei
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
    ~/Library/Application\ Support/Code/User/workspaceStoratge/*
    ~/Library/Caches/com.microsoft.VSCode.ShipIt
    ~/Library/Caches/com.microsoft.VSCode

    # Multimedia applications cache
    ~/Library/Application\ Support/Spotify/PersistentCache

    # Telegram cache
    ~/Library/Application\ Support/Telegram\ Desktop/tdata/user_data
    ~/Library/Application\ Support/Telegram\ Desktop/tdata/emoji
    ~/Library/Group\ Containers/6N38VWS5BX.ru.keepcoder.Telegram/account-570841890615083515/postbox/*
    ~/Library/Containers/org.telegram.desktop/Data/Library/Application\ Support/Telegram\ Desktop/tdata/emoji/*

    # Google update tools cache
    ~/Library/Caches/com.google.SoftwareUpdate
    ~/Library/Caches/com.google.Keystone

    # Docker cache
    ~/Library/Containers/com.docker.docker/Data/vms/*

    # System trash
    ~/.Trash/*

    # My trash
    $SCRIPT_DIR/*.out
)

for path in "${paths[@]}"; do
    if [ -e "$path" ] || [ -L "$path" ]; then
        rm -rf "$path" 2>/dev/null
    fi
done

# Additional cache cleanup
find ~/Library/Application\ Support -type d -iname "*cache*" 2>/dev/null -exec rm -rf {} \;
rm -rf ~/Library/Developer/Xcode/*

# Space after cleanup
echo "$purple"'|----|After  cleanup|----|'
echo "$purple"'|'"$blue"'Size  '"$purple"'|  '"$red"'Used  '"$purple"'|  '"$green"'Avail '"$purple"'|'"$reset"
df -h | grep Users | awk -v purple="$purple" -v green="$green" -v blue="$blue" -v red="$red" '{print purple "|" blue $2 " " purple "=  " red $3 " " purple "+  " green $4 " " purple "|"}'
echo -n "$reset"
echo "$purple"'|----|Cleanup  ended|----|'
