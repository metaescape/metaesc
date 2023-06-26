#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_rime() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
		print_info "开始安装/更新 rime, 主要需要 ibus 和 ibus-rime, librime-dev"
		print_info "librime-dev 是 emacs-rime 所需"
        sudo apt update
        sudo apt install ibus ibus-rime librime-dev -y

		print_success "ibus, ibus-rime, librime-dev 安装完毕"
		print_info "使用 ibus-daemon --xim -d -r 启动 daemon, 之后可以使用 ibus restart 重启"
		print_info "安装后默认可以使用 luna 拼音，使用 setup rime 添加配置 \n"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}


function setup_rime() {
	local distro
	distro=$(whichdistro)
    _cur_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
    conf_dir="$(builtin cd "$current_dir" && git rev-parse --show-toplevel)"
	if [[ $distro == "debian" ]]; then
		print_info "开始配置 rime, 首先添加环境变量，考虑到输入法是主要是在图形界面用的"
		print_info "因此环境变量加入到 ~/.xprofile 中，但放 ~/.profile 也无妨，这里主要建立软链接 "
        set -uex
        ln -sf $conf_dir/.profile $HOME/.profile

		print_info "接着考虑词库 emacs rime 和 ibus rime 的词库和输入法配置文件的链接"

        [ ! -d $HOME/.config/emacs_rime ] && mkdir $HOME/.config/emacs_rime
        for rime_data in $HOME/.config/emacs_rime $HOME/.config/ibus/rime; do
            for target in "custom_phrase.txt" "essay-zh-hans.txt" "pinyin.schema.yaml" "default.custom.yaml" "extended.dict.yaml" "zh-hans-t-essay-bgw.gram" "installation.yaml" "user.yaml"; do
                ln -sf $conf_dir/rime/${target} "${rime_data}"/"${target}"
            done
            # link dir
		    print_info "使用 ln -T 选项来链接目录"
            for target in "dicts" "opencc"; do
                ln -sfn $conf_dir/rime/${target}/ "${rime_data}"/"${target}"
            done
        done
        set -ue
		print_success "ibus-rime 配置完成，重新 deploy 后可以生效"
		print_success "emacs-rime 词库配置完成，可以在 emacs 中执行 rime-deploy 生效"
		print_notice "ibus-rime 和 emacs-rime 是共享静态词库的，但他们的静态词库运行时不共享"
		print_notice "但可以用的方式进行词库的同步"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}
