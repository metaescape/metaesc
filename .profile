# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
# if [ -n "$BASH_VERSION" ]; then
#     # include .bashrc if it exists
#     if [ -f "$HOME/.bashrc" ]; then
# 	. "$HOME/.bashrc"
#     fi
# fi

port=7890
proxy(){
    echo export https_proxy=https://127.0.0.1:$port
    echo export http_proxy=http://127.0.0.1:$port
    echo export all_proxy=http://127.0.0.1:$port
    export https_proxy=https://127.0.0.1:$port
    export http_proxy=http://127.0.0.1:$port
    export all_proxy=https://127.0.0.1:$port
}

unproxy(){
    echo export https_proxy=""
    echo export http_proxy=""
    echo export all_proxy=""
    export https_proxy=""
    export http_proxy=""
    export all_proxy=""
}
unproxy > /dev/null

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# for rust
. "$HOME/.cargo/env"

# for cuda
if [ -e /usr/local/cuda-10.1 ];then
	export PATH=/usr/local/cuda-10.1/bin:${PATH}
	export LD_LIBRARY_PATH=/usr/local/cuda-10.1/lib64:${LD_LIBRARY_PATH}
fi

# for texlive
if [[ -e /usr/local/texlive/2023 ]]; then
	export MANPATH=/usr/local/texlive/2023/texmf-dist/doc/man:$MANPATH
	export INFOPATH=/usr/local/texlive/2023/texmf-dist/doc/info:$INFOPATH.
	export PATH=/usr/local/texlive/2023/bin/x86_64-linux:$PATH.
fi

# for ibus-rime
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus

# for nodejs
VERSION=v18.14.2
DISTRO=linux-x64
export PATH=/usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin:$PATH

# for personal scripts
PATH="$HOME/metaesc/bin:$PATH"
