#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_language() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
		print_info "开始安装语言环境, 主要会安装 rime 和 crow-translate 做中英文翻译"
		print_info "crow-translate 主要用于 emacs 中构建生词本和过滤阅读使用"
        source $(dirname "${BASH_SOURCE[0]:-$0}")/pack-rime.sh
		print_info "添加 crow-translate 的个人源，这会在 /etc/apt/sources.list.d/ 和 /etc/apt/trusted.gpg.d/ 中分别添加一个 list 文件和 gpg 文件，后者用于校验安装包信息"
		print_notice "这可能需要 vpn 网络"

        sudo add-apt-repository ppa:jonmagon/crow-translate -y

        install_rime

		print_info "安装 crow-translate"
        sudo apt install crow-translate -y

		print_success "rime 环境和 crow-translate 翻译软件安装完毕 \n"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}
