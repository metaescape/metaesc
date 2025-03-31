#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

site_pkg_dir=~/.wemacs/site-lisp/

function install_eaf() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
        if [ ! -d $site_pkg_dir ]; then
			echo "emacs site-lisp 目录不存在, 请手动创建目录并指定路径"
			exit 1
		fi
		pushd $site_pkg_dir

		if [ ! -d "emacs-application-framework" ]; then 
			print_info "下载 最新的 eaf"
			git clone --depth 1  git@github.com:emacs-eaf/emacs-application-framework.git
			print_success "eaf 下载完毕"
		fi

		if [ ! -d "emacs-application-framework/app" ]; then 
			mkdir -p emacs-application-framework/app
			print_info "创建 eaf app 目录"
		fi 
		cd emacs-application-framework/app
		if [ ! -d "pdf-viewer" ]; then 
			git clone -b master --depth 1 git@github.com:emacs-eaf/eaf-pdf-viewer.git pdf-viewer
		fi
		if [ ! -d "mindmap" ]; then 
			git clone -b master --depth 1 git@github.com:emacs-eaf/eaf-mindmap.git mindmap
		fi
		
		conda env list | grep ^usr
		if [ "$?" != 0 ]; then
			print_info "install conda usr environment"
			print_notice "emacs 需要 usr 环境"
			conda create -n usr python=3.10
		fi

		export PS1="\u@\h:\w\$ "
		eval "$(conda shell.bash hook)"
		conda activate usr
		pip install epc tld lxml PyQt6 PyQt6-Qt6 PyQt6-sip PyQt6-WebEngine PyQt6-WebEngine-Qt6 pymupdf

		print_success "conda usr environment 安装完毕"

	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}

function setup_eaf {
	print_notice "查看 ${site_pkg_dir}emacs-application-framework/app"
	ls -l ${site_pkg_dir}emacs-application-framework/app
}
