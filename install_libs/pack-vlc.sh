#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_vlc() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
		print_info "可以使用 snap 安装 vlc, 但如果是在服务器上，这会导致 xforward 失败"
		print_info "因此在服务器上，还是用 apt 安装, 客户端可以用 snap 或 apt，但为了统一都用 apt"

		# sudo snap insall vlc
		sudo apt install vlc
		print_success "vlc 安装/更新完毕"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}


function setup_vlc() {
    print_notice "vlc 可以设置成用 hl 来控制前进后退，在图形界面中手动设置"
}
