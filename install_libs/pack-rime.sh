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

		print_info "从 https://github.com/iDvel/rime-ice 下载 rim-ice"
        pushd ~/codes/

        if [ -d "rime-ice" ]; then
            echo "rime-ice 目录已存在，正在更新仓库..."
            cd rime-ice
            git pull
        else
            echo "正在克隆 rime-ice 仓库..."
            git clone https://github.com/iDvel/rime-ice.git --depth=1
        fi
        cp -r ./rime-ice/* ~/.config/ibus/rime/
        cp -r ./rime-ice/* ~/.config/emacs_rime/

        default_custom_yaml=$conf_dir/.config/ibus/rime/default.custom.yaml
        installation_ibus=$conf_dir/.config/ibus/rime/installation.yaml
        installation_emacs=$conf_dir/.config/emacs_rime/installation.yaml
        ln -sf $default_custom_yaml $HOME/.config/ibus/rime/default.custom.yaml
        ln -sf $default_custom_yaml $HOME/.config/emacs_rime/default.custom.yaml
        ln -sf $installation_ibus $HOME/.config/ibus/rime/installation.yaml
        ln -sf $installation_emacs $HOME/.config/emacs_rime/installation.yaml 
        popd

		print_success "ibus-rime 配置完成，重新 deploy 后可以生效"
		print_success "emacs-rime 词库配置完成，可以在 emacs 中执行 rime-deploy 生效"
		print_notice "ibus-rime 和 emacs-rime 是共享静态词库的，但他们的静态词库运行时不共享, sue sync to  share"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}
