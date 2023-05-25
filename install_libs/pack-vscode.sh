#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_vscode() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
		print_info "开始安装/更新 vscode, 如有问题参考 vscode 官网 https://code.visualstudio.com/docs/setup/linux"

		print_info "添加 vscode 官方源到 sources.list.d 目录下"
		sudo apt-get install wget gpg
		wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
		sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
		sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
		rm -f packages.microsoft.gpg
		print_success "vscode 源添加完毕"

		print_info "安装依赖，获取最新的软件列表并安装最新的 vscode"
		sudo apt install apt-transport-https
		sudo apt update
		sudo apt install code
		print_success "vscode 安装/更新完毕"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}


function setup_vscode() {
    print_notice "vscode 没什么需要本地配置的，使用 vscode 账户同步即可"
}
