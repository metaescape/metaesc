#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_terminal() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
        pkgs="fzf tmux curl ripgrep neovim"
		print_info "termial 是对终端生态的一个集合，主要是 $pkgs ，这里些套件是标配了"
		sudo apt update
        echo $pkgs | xargs sudo apt-get install -y

		print_success "$pkgs 安装完毕"
		print_info "install tmux plugins manager"
		mkdir_not_exist ~/.tmux
		if [ ! -e ~/.tmux/plugins/tpm ]; then
			print_notice "下载 tmux插件管理器 tpm..."
			git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
			print_success "下载 tmux插件管理器 tpm 完毕"
		fi
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}


function setup_terminal() {
	local distro
	distro=$(whichdistro)
    _cur_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
    conf_dir="$(builtin cd "$current_dir" && git rev-parse --show-toplevel)"
	if [[ $distro == "debian" ]]; then
		print_info "添加 tmux, inputrc, bashrc 配置"
        set -uex
        ln -sf $conf_dir/.profile $HOME/.profile

        # Home directory
        ln -sf $conf_dir/.tmux.conf $HOME/.tmux.conf
        ln -sf $conf_dir/.bashrc $HOME/.bashrc
        ln -sf $conf_dir/.inputrc $HOME/.inputrc
        ln -sf $conf_dir/.Xresources $HOME/.Xresources

		print_notice "如果使用了 rxvt 作为终端，那么使用到了 $HOME/.Xresources, 需要重新登录系统才能生效"

        # vim, neovim, ideavim

		print_info "添加 neovim 和 ideavimrc 配置，这里 ideavimrc 是 overkill 了，但添加上并不影响使用"
        ln -sfT $conf_dir/.vim $HOME/.vim
        ln -sf $conf_dir/.vim/vimrc $HOME/.vimrc
        ln -sf $conf_dir/.ideavimrc $HOME/.ideavimrc
        ln -sf $conf_dir/.config/nvim/init.vim $HOME/.config/nvim/init.vim

        set -ue

		print_notice "终端相关配置添加完毕"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}
