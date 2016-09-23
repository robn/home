source $HOME/.bash_prompt
source $HOME/.bash_secret

eval "$(plenv init -)"

export ANDROID_HOME=/usr/local/opt/android-sdk

alias vi=vim
alias vim="vim -o"

export PATH="$HOME/bin:$HOME/.cargo/bin:$PATH"
