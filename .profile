# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

alias vi=vim
alias vim="vim -o"
export EDITOR=vim
export VISUAL=/usr/bin/vim

export PATH="$HOME/.plenv/bin:$PATH"
eval "$(plenv init -)"

export PATH="$HOME/.cargo/bin:$PATH"

#export GDK_SCALE=2
#export GDK_DPI_SCALE=0.5
#export QT_AUTO_SCREEN_SET_FACTOR=0
#export QT_SCALE_FACTOR=2
#export QT_FONT_DPI=96

#export GDK_SCALE=2
export GDK_DPI_SCALE=1.2
