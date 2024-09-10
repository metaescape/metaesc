#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_emacs29.4() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
        if [ ! -e $CODES/emacs-29.4 ]; then
            print_info "采用编译的方式来安装 emacs, 首先要准备安装条件，包括 build 需要的库，包括 build-essential, 剩下的可以用 `sudo apt build-dep --no-install-recommends emacs` 来查看"
            sudo apt install build-essential -y
            sudo apt build-dep emacs -y

            sudo apt-get install build-essential autoconf automake libtool texinfo libgtk-3-dev libxpm-dev libjpeg-dev libgif-dev libtiff5-dev libgnutls28-dev libncurses-dev libxml2-dev libgpm-dev libdbus-1-dev libgtk2.0-dev libpng-dev libotf-dev libm17n-dev librsvg2-dev libmagickcore-dev libmagickwand-dev libglib2.0-dev libgirepository1.0-dev -y

            # support native compile
            sudo apt install libgccjit-11-dev -y

            print_info "sqlite3 用于 org-roam"
            sudo apt install sqlite3 -y

            pushd $CODES
            wget http://mirrors.aliyun.com/gnu/emacs/emacs-29.4.tar.gz
            print_notice "下载 emacs-29.4.tar.gz"
            tar -xf emacs-29.4.tar.gz
            pushd $CODES/emacs-29.4
            ./autogen.sh
            ./configure --with-native-compilation=aot
            make -j16 
            popd 
            mv emacs-29.4.tar.gz $INSTALLERS/
            print_notice "emacs-29.4.tar.gz 移动到 $INSTALLERS/"
            popd
            print_success "emacs29.4 编译完毕"
        fi
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}

function setup_emacs29.4() {
	local distro
	distro=$(whichdistro)
    _cur_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
    conf_dir="$(builtin cd "$_cur_dir" && git rev-parse --show-toplevel)"
	if [[ $distro == "debian" ]]; then
        script_path=$(realpath "${BASH_SOURCE[0]}")
        countdown_warning 7 "Emacs" "$script_path"
		print_info "开始配置 emacs, 链接主目录文件"
        set -uex
        CONFIG_HOME=$HOME/.wemacs/
        # Wemacs
        [ ! -d $CONFIG_HOME ] && mkdir $CONFIG_HOME
        ln -sf $conf_dir/.wemacs/early-init.el $CONFIG_HOME/early-init.el
        ln -sf $conf_dir/.wemacs/init.el $CONFIG_HOME/init.el
        ln -sfT $conf_dir/.wemacs/snippets $CONFIG_HOME/snippets

		print_info "把 emacsclient 和 emacs 以软链接方式添加到 ~/.local/bin/, 以供全局使用"
        ln -sf $CODES/emacs-29.4/src/emacs $HOME/.local/bin/emacs
        ln -sf $CODES/emacs-29.4/lib-src/emacsclient $HOME/.local/bin/emacsclient

		print_info "把 $HOME/.emacs.d 设置为 $HOME/.wemacs 目录的软链接"
        if [ -d "$HOME/.emacs.d" ] && [ ! -L "$HOME/.emacs.d" ]; then
            # 如果 $HOME/.emacs.d 是一个目录且不是软链接
            mv "$HOME/.emacs.d" "$HOME/.emacs.d.bak"
            print_info "$HOME/.emacs.d 备份到了 $HOME/.emacs.d.bak"
        fi
        if [ -L "$HOME/.emacs.d" ]; then
            print_info "$HOME/.emacs.d 链接情况如下"
            ls -l "$HOME/.emacs.d"
        elif [ ! -e "$HOME/.emacs.d" ]; then
            # 如果 $HOME/.emacs.d 不存在
            ln -s "$HOME/.wemacs" "$HOME/.emacs.d"
        fi
        set -ue

		print_success "emacs 配置完成"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}
