#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_wemeet() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
		print_info "到 https://meeting.tencent.com/download?app_lang=zh-cn 手动下载 deb: "
		print_notice "将 deb 放置在 /data/installer 下"
		sudo dpkg -i /data/installer/TencentMeeting_0300000000_3.19.2.400_x86_64_default.publish.officialwebsite.deb
		print_success "腾讯视频安装完毕，直接用 dmenu desktop 方式启动"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}


function setup_wemeet() {
	local distro
	distro=$(whichdistro)
    _cur_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
    conf_dir="$(builtin cd "$current_dir" && git rev-parse --show-toplevel)"
	if [[ $distro == "debian" ]]; then
		print_success "当前无额外配置"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}
