#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_conda() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
        if [ ! -e ~/miniconda3 ]; then
            pushd ~
			print_info "下载 bash 脚本直接安装 miniconda3"
            print_notice "下载 miniconda 3"
			wget https://mirrors.aliyun.com/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh
			bash Miniconda3-latest-Linux-x86_64.sh -b
			rm Miniconda3-latest-Linux-x86_64.sh
            print_notice "删除 miniconda3 安装脚本"
            popd
			print_success "Miniconda 安装完毕, bashrc 中集成了 cona 和 conls 命令"
        fi
		print_info "install conda usr environment"
		print_notice "usr 环境 emacs 也需要"
		conda env list | grep ^usr
		if [ "$?" != 0 ]; then
			echo "install conda usr environment"
			conda create -n usr python=3.7
		fi
		export PS1="\u@\h:\w\$ "
		source ~/miniconda3/bin/activate usr
		pip install pandoc jupyter notedown black beautysh pynvim 
		# conda install pandoc #this is executable pandoc
		conda deactivate
		print_success "conda usr environment 安装完毕"

	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}

function setup_conda {
	local distro
	distro=$(whichdistro)
    _cur_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
    conf_dir="$(builtin cd "$current_dir" && git rev-parse --show-toplevel)"

	print_info "使得 conda 和 pip 使用国内源"
	if [[ $distro == "debian" ]]; then
        set -uex
		[ ! -d $HOME/.config/pip ] && mkdir $HOME/.config/pip
        ln -sf $conf_dir/.config/pip/pip.conf $HOME/.config/pip/pip.conf
        ln -sf $conf_dir/.condarc $HOME/.condarc
        set -ue
		print_notice "设置使用国内源成功"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}
