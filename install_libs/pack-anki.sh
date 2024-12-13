#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

TAR_NAME=anki-24.11-linux-qt6

function install_anki() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
		print_info "安装系统依赖"
        sudo apt install libxcb-xinerama0 libxcb-cursor0 libnss3
		print_info "从 https://apps.ankiweb.net/ 下载 Anki for glibc 的 tar.zst 包后移动到 $INSTALLERS 目录下"

        pushd "$INSTALLERS"
        if [ ! -d "$TAR_NAME" ]; then
            tar xaf "$INSTALLERS/$TAR_NAME.tar.zst"
        fi
        cd $TAR_NAME
        sudo ./install.sh
        popd

		print_success "TAR_NAME 安装/更新完毕"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}


function setup_anki() {
    print_notice "手动设置"
}
