export HOMEBREW_NO_AUTO_UPDATE=1

export NVM_DIR="/Users/$(whoami)/goinfre/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export HOMEBREW_CASK_OPTS="--appdir=/Users/$(whoami)/goinfre/Applications"

export ANDROID_NDK_HOME="/opt/goinfre/$(whoami)/homebrew/share/android-ndk"

# Android в goinfre
export ANDROID_HOME=/opt/goinfre/$(whoami)/Android/sdk
export GRADLE_USER_HOME=/opt/goinfre/$(whoami)/.gradle
export ANDROID_SDK_ROOT=/opt/goinfre/$(whoami)/Android/sdk