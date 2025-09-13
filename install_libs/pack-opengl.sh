#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_opengl() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
		print_info "开始安装 opengl 工具链"

        sudo apt update
        sudo apt install build-essential cmake xorg-dev libfreetype6-dev
        sudo apt install mesa-common-dev libgl1-mesa-dev libglu1-mesa-dev
		print_success "opengl 工具链安装/更新完毕"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}


function setup_opengl() {
    print_notice "开始写代码吧"
}
