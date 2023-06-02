#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_scheme() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
		print_info "采用编译的方式来安装 mit-scheme"
        sudo apt install build-essential -y

        if [ ! -e $CODES/mit-scheme-11.2 ]; then
            print_notice "解压 mit-scheme-11.2"
            pushd /data/installer/
            tar xzf mit-scheme-11.2-x86-64.tar.gz
            mv mit-scheme-11.2 ~/codes/
            popd

        fi

        if command -v mit-scheme &> /dev/null
        then
            print_success "mit-scheme 已安装"
            exit;
        fi
        print_success "开始编译 mit-scheme-11.2"
        pushd $CODES/mit-scheme-11.2/src
        ./configure
        make
        sudo make install
        cd ../doc
        ./configure
        make
        sudo make install-info
        popd
        print_success "mit-scheme-11.2 编译完毕"

	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}

function setup_scheme() {
	local distro
	distro=$(whichdistro)
    _cur_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
    conf_dir="$(builtin cd "$_cur_dir" && git rev-parse --show-toplevel)"
	if [[ $distro == "debian" ]]; then
		print_info "开始配置 mit-scheme"

		print_success "mit-scheme 配置完成"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}
