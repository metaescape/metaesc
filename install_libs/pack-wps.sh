#!/usr/bin/env bash
set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_wps() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then

        if ! command -v wps &> /dev/null
        then
			print_info "安装 wps"
            pushd /data/installer/
			wps=$(ls wps-office*.deb 2>/dev/null)
			if  [ ! ${wps[@]} -gt 0 ]; then
		        print_info "请手动从 https://www.wps.com/office/linux/ 中下载 deb 包"
                exit
            fi
			# 安装.deb文件
			for file in "${wps[@]}"; do
				sudo apt install "./$file"
			done
			print_success "wps 安装完毕"
            popd
		else 
			print_success "wps 已安装"
        fi

        if ! command -v masterpdfeditor5 &> /dev/null
        then
			print_info "安装 master-pdf-editor 用于编辑 outline"
			sudo apt install ./master-pdf-editor-5.9.40-qt5.9.x86_64.deb
			print_success "master-pdf-editor 安装完毕"
		else 
			print_success "master-pdf-editor 已安装"
        fi
        
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}

function setup_zotero() {
	local distro
	distro=$(whichdistro)
    _cur_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
    conf_dir="$(builtin cd "$_cur_dir" && git rev-parse --show-toplevel)"
	if [[ $distro == "debian" ]]; then
		print_info "基本不需要手动配置"

	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}
