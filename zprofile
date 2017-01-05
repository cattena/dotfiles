# ---------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------

export PATH="/Library/Frameworks/Python.framework/Versions/3.4/bin:$PATH"
export PATH="/usr/local/git/bin:$PATH"
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export PATH="$PATH:/Users/Alex/Scripts"
export GOPATH="$HOME/.golang"
export PATH="$HOME/.golang/bin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
export PATH="$HOME/.cargo/bin:$PATH"

setopt auto_cd
cdpath=($GOPATH/src $GOPATH/src/github.com/kniren)

# ---------------------------------------------------------------------
# Exports --¬
# ---------------------------------------------------------------------

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export EDITOR=nvim
