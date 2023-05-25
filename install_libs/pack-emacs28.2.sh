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
            make -j16 NATIVE_FULL_AOT=1
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
		print_info "开始配置 emacs, 首先在 .emacs.d 中链接 chemacs 所需要的文件"
        set -uex

        # Emacs/chemacs2
        ln -sf $conf_dir/.emacs-profiles.el $HOME/.emacs-profiles.el
        [ ! -d $HOME/.emacs.d/ ] && mkdir $HOME/.emacs.d/
        ln -sf $conf_dir/.emacs.d/early-init.el $HOME/.emacs.d/early-init.el
        ln -sf $conf_dir/.emacs.d/init.el $HOME/.emacs.d/init.el
        ln -sf $conf_dir/.emacs.d/chemacs.el $HOME/.emacs.d/chemacs.el

		print_info "之后链接主目录文件"
        # Wemacs
        [ ! -d $HOME/.wemacs/ ] && mkdir $HOME/.wemacs/
        ln -sf $conf_dir/.wemacs/early-init.el $HOME/.wemacs/early-init.el
        ln -sf $conf_dir/.wemacs/init.el $HOME/.wemacs/init.el
        ln -sfT $conf_dir/.wemacs/snippets $HOME/.wemacs/snippets

		print_info "把 emacsclient 和 emacs 链接到 ~/.local/bin/ 中"
        ln -sf $CODES/emacs-28.2/src/emacs $HOME/.local/bin/emacs
        ln -sf $CODES/emacs-28.2/lib-src/emacsclient $HOME/.local/bin/emacsclient

        set -ue

		print_success "emacs 配置完成"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}
