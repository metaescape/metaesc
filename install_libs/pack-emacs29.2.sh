#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_emacs29.2() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
        if [ ! -e $CODES/emacs-29.2 ]; then
            print_info "采用编译的方式来安装 emacs, 首先要准备安装条件，包括 build 需要的库，包括 build-essential, 剩下的可以用 `sudo apt build-dep --no-install-recommends emacs` 来查看"
            sudo apt install build-essential -y
            sudo apt build-dep emacs -y

            print_info "sqlite3 用于 org-roam"
            sudo apt install sqlite3

            pushd $CODES
            wget http://mirrors.aliyun.com/gnu/emacs/emacs-29.2.tar.gz
            print_notice "下载 emacs-29.2.tar.gz"
            tar -xf emacs-29.2.tar.gz
            pushd $CODES/emacs-29.2
            ./autogen.sh
            ./configure 
            make -j16 NATIVE_FULL_AOT=1
            popd 
            rm -rf emacs-29.2.tar.gz
            print_notice "删除 emacs-29.2.tar.gz"
            popd
		    print_success "emacs29.2 编译完毕"
        fi
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}

function setup_emacs29.2() {
	local distro
	distro=$(whichdistro)
    _cur_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
    conf_dir="$(builtin cd "$_cur_dir" && git rev-parse --show-toplevel)"
	if [[ $distro == "debian" ]]; then
		print_info "开始配置 emacs, 首先在 .emacs.29.2 中链接需要的文件"
        CONFIG_HOME=$HOME/.wemacs29/
        set -uex
        # Wemacs
        [ ! -d $CONFIG_HOME ] && mkdir $CONFIG_HOME
        ln -sf $conf_dir/.wemacs/early-init.el $CONFIG_HOME/early-init.el
        ln -sf $conf_dir/.wemacs/init.el $CONFIG_HOME/init.el
        ln -sfT $conf_dir/.wemacs/snippets $CONFIG_HOME/snippets
        set -ue

		print_success "emacs 配置完成"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}
