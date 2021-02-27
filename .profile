# common startup

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

export EDITOR=vim
export VISUAL=/usr/bin/vim

if [ -d "$HOME/.plenv" ] ; then
  export PATH="$HOME/.plenv/bin:$PATH"
  eval "$(plenv init -)"
fi

if [ -d "$HOME/.cargo" ] ; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

#export GDK_SCALE=2
#export GDK_DPI_SCALE=0.5
#export QT_AUTO_SCREEN_SET_FACTOR=0
#export QT_SCALE_FACTOR=2
#export QT_FONT_DPI=96

#export GDK_SCALE=2
export GDK_DPI_SCALE=1.2
