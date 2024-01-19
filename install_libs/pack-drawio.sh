#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_drawio() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
		print_info "使用 snap 安装有许多 bug(2023.5)"
		print_info "到 https://github.com/jgraph/drawio-desktop/releases 手动下载 deb: "
		print_notice "将 deb 放置在 /data/installer 下"
		print_notice "目前还不清楚如何卸载这个 deb 包, 因此之考虑覆盖安装"
		sudo dpkg -i /data/installer/drawio-amd64-21.2.8.deb
		# sudo snap install drawio
		print_success "drawio 安装完毕, 无需额外配置，直接系统启动 drawio"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}


function setup_drawio() {
    print_success "当前无额外配置"
}
