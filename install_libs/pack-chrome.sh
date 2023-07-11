#!/usr/bin/env bash
set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_chrome() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then

        if ! command -v google-chrome-stable &> /dev/null
        then
			print_info "安装 google-chrome"
            pushd /data/installer/
			chrome=$(ls google-chrome-stable_current_amd64.deb 2>/dev/null)
			if  [ ! ${chrome[@]} -gt 0 ]; then
		        print_info "请手动从 https://www.google.com/intl/zh-CN/chrome/ 中下载 deb 包"
                exit
            fi
			# 安装.deb文件
			for file in "${chrome[@]}"; do
				sudo apt install "./$file"
			done
			print_success "google chrome 安装完毕"
            popd
		else 
			print_success "google chrome 已安装，尝试更新"
            sudo apt update
            sudo apt install google-chrome-stable
        fi
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}

function setup_chrome() {
	local distro
	distro=$(whichdistro)
    _cur_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
    conf_dir="$(builtin cd "$_cur_dir" && git rev-parse --show-toplevel)"
	if [[ $distro == "debian" ]]; then
		print_info "都是安装插件的工作"

	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}
