export HOMEBREW_NO_AUTO_UPDATE=1

export NVM_DIR="/Users/$(whoami)/goinfre/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export HOMEBREW_CASK_OPTS="--appdir=/Users/$(whoami)/goinfre/Applications"

export ANDROID_NDK_HOME="/opt/goinfre/harveyfa/homebrew/share/android-ndk"