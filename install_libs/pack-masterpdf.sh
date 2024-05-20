#!/usr/bin/env bash
set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh
source $(dirname "${BASH_SOURCE[0]:-$0}")/../user_env.sh

PDFAPP="master-pdf-editor-5.9.40-qt5.9.x86_64.deb"
PDFAPP="master-pdf-editor-5.9.82-qt5.9.x86_64.deb"

function install_masterpdf() {
	local distro
	distro=$(whichdistro)
	print_info "当前安装 deb 源文件为 $INSTALLERS/$PDFAPP"
	# if PDFAPP not found, print error
	if [[ ! -f "$INSTALLERS/$PDFAPP" ]]; then
		print_warning  "$INSTALLERS/$PDFAPP "
		print_warning "请从 https://code-industry.net/free-pdf-editor/ 下载 deb 并放到 $INSTALLERS 目录下"
		exit 1
	fi

	if [[ $distro == "debian" ]]; then
		print_info "安装 master-pdf-editor 用于编辑 outline"
		sudo apt install "$INSTALLERS/$PDFAPP"
		print_success "master-pdf-editor 安装完毕"
        
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}

function setup_masterpdf() {
    print_info "基本不需要手动配置 masterpdf"
}
