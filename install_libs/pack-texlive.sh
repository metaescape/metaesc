#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_texlive() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
		directory="/usr/local/texlive"

		if [ ! -d "$directory" ]; then
			print_info "开始安装 textlive, 通过"
			print_info "从就近镜像下载 tl 的安装包"
			cd /tmp # working directory of your choice
			wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz

			print_info "解压 install-tl-unx.tar.gz"
			zcat install-tl-unx.tar.gz | tar xf -

			# 使用 ls 命令和通配符匹配获取 * 的字符串
			directories=(install-tl-*)

			# 检查是否匹配到目录
			if [ -d "${directories[0]}" ]; then
				# 获取匹配到的字符串并保存到变量 version 中
				version=${directories[0]#install-tl-}
				year=${version:0:4}
				print_info  "$version 版本 texlive 安装目录已解压，准备安装"
			else
				print_error "Install package not found"
				exit 
			fi

			cd install-tl-*/
			sudo perl ./install-tl --no-interaction
			print_success "text 安装完毕"
			print_info "请手动添加环境变量 \n"
		else
		  ls /usr/local/texlive
		  print_success "$directory installed"
		  
		fi
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}


function setup_texlive() {
	local distro
	distro=$(whichdistro)
    _cur_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
    conf_dir="$(builtin cd "$current_dir" && git rev-parse --show-toplevel)"
	if [[ $distro == "debian" ]]; then
		print_info "配置 texlive 主要就是添加环境变量, 这包括 terminal 和 emacs "
		print_info "由于 texlive 并不常修改，因此在 bashrc 和 ~/metaesc/lib/open_emacs 中手动修改"
		print_success ""
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}
