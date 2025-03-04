#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_i3() {
	local distro
	distro=$(whichdistro)

	if [[ $distro == "debian" ]]; then
        print_info "i3 引入了大量的生态软件，并且与个性化密切相关 "
        print_info "例如 feh 设置壁纸，dunst 通知系统，wmctrl,xdotool,xcape 与改建相关"
        print_info "arandr compton 设置透明度"
        print_info "scrot 是截取动态图需要, emacs 中也会用到"

        /usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2024.03.04_all.deb keyring.deb SHA256:f9bb4340b5ce0ded29b7e014ee9ce788006e9bbfe31e96c09b2118ab91fca734
        sudo apt install ./keyring.deb
        echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
        sudo apt update
        pkgs="feh dunst zenity wmctrl arandr compton xcape xdotool scrot gnome-screenshot"
        echo $pkgs | xargs sudo apt-get install -y
        print_success "i3 生态安装完毕"
        sudo apt install i3

        print_success "i3wm 最新稳定版安装完毕"
	elif [[ $distro == "redhat" ]]; then
        :
	elif [[ $distro == "arch" ]]; then
        :
	fi
}

function setup_i3() {
	local distro
	distro=$(whichdistro)
        _cur_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
        conf_dir="$(builtin cd "$_cur_dir" && git rev-parse --show-toplevel)"

	if [[ $distro == "debian" ]]; then

        print_info "i3 相关软件的配置大部分都在 ~/.config 中"

        set -uex
        [ ! -d $HOME/.config ] && mkdir $HOME/.config
        ln -sf $conf_dir/.config/i3/config $HOME/.config/i3/config
        ln -sf $conf_dir/.config/i3status/config $HOME/.config/i3status/config
        ln -sf $conf_dir/.config/compton.conf $HOME/.config/compton.conf
        [ -d $HOME/.config/dunst ] && rm -rf $HOME/.config/dunst
        ln -sfn $conf_dir/.config/dunst $HOME/.config/dunst

        set -ue
        print_success "i3 相关配置软链接已建立"

	elif [[ $distro == "redhat" ]]; then
        :
	elif [[ $distro == "arch" ]]; then
        :
	fi
}
