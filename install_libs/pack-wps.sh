#!/usr/bin/env bash
set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh
source $(dirname "${BASH_SOURCE[0]:-$0}")/../user_env.sh

function install_wps() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then

        if ! command -v wps &> /dev/null
        then
			print_info "安装 wps"
            pushd $INSTALLERS
			wps=$(find . -maxdepth 1 -name "wps-office*.deb" -print 2>/dev/null)
			if  [ -z $wps ]; then
		        print_info "请手动从 https://www.wps.com/office/linux/ 中下载 deb 包"
                exit
            fi
			# 安装.deb文件
			sudo apt install "./$wps"
			print_success "wps 安装完毕"
            popd
		else 
			print_success "wps 已安装"
			print_info "如需重装，请先用 sudo apt remove wps-office 卸载 wps"
			print_info "再手动从 https://www.wps.com/office/linux/ 中下载 deb 包到 $INSTALLERS 目录中"
			print_info "并保持 $INSTALLERS 中只有一个最新的 deb 文件"
		    print_info "然后重新执行 ./metaesc.sh -i wps"
        fi
        
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}

function setup_wps() {
    print_info "基本不需要手动配置"
}
