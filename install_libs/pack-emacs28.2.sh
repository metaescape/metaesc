#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_emacs28.2() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
		print_info "采用编译的方式来安装 emacs, 首先要准备安装条件，包括 build 需要的库，包括 build-essential, 剩下的可以用 `sudo apt build-dep --no-install-recommends emacs` 来查看"
        sudo apt install build-essential -y
        sudo apt build-dep emacs -y

		print_info "sqlite3 用于 org-roam"
        sudo apt install sqlite3

        if [ ! -e $CODES/emacs-28.2 ]; then
            pushd $CODES
            wget http://mirrors.aliyun.com/gnu/emacs/emacs-28.2.tar.gz
            print_notice "下载 emacs-28.2.tar.gz"
            tar -xf emacs-28.2.tar.gz
            pushd $CODES/emacs-28.2
            ./autogen.sh
            ./configure 
            make -j16
            popd 
            rm -rf emacs-28.2.tar.gz
            print_notice "删除 emacs-28.2.tar.gz"
            popd
		    print_success "emacs28.2 编译完毕"
        fi
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}

function setup_emacs28.2() {
	local distro
	distro=$(whichdistro)
    _cur_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
    conf_dir="$(builtin cd "$_cur_dir" && git rev-parse --show-toplevel)"
	if [[ $distro == "debian" ]]; then
        script_path=$(realpath "${BASH_SOURCE[0]}")
        countdown_warning 7 "Emacs" "$script_path"
        set -uex
        # Emacs/chemacs2
		print_info "开始配置 emacs, 链接主目录文件"
        CONFIG_HOME=$HOME/.wemacs/
        
        # Wemacs
        [ ! -d $CONFIG_HOME ] && mkdir $CONFIG_HOME
        ln -sf $conf_dir/.wemacs/early-init.el $CONFIG_HOME/early-init.el
        ln -sf $conf_dir/.wemacs/init.el $CONFIG_HOME/init.el
        ln -sfT $conf_dir/.wemacs/snippets $CONFIG_HOME/snippets

		print_info "把 emacsclient 和 emacs 以软链接方式添加到 ~/.local/bin/, 以供全局使用"
        ln -sf $CODES/emacs-28.2/src/emacs $HOME/.local/bin/emacs
        ln -sf $CODES/emacs-28.2/lib-src/emacsclient $HOME/.local/bin/emacsclient

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
