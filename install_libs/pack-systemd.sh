#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_systemd() {
	print_info "systemd 一般系统自带"
    }

function setup_systemd() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
		print_info "将 ~/.config/systemd/user 指向 ~/metaesc/.config/systemd/user/"
        conf_dir="$(builtin cd "$current_dir" && git rev-parse --show-toplevel)"
        ln -sfT $conf_dir/.config/systemd/user $HOME/.config/systemd/user 

        # 检查 timer 是否已启用
        if ! systemctl --user is-enabled gtd_backup.timer; then
            echo "Enabling gtd_backup.timer"
            systemctl --user enable gtd_backup.timer
        else
            echo "gtd_backup.timer is already enabled"
        fi

        # 检查 timer 是否已激活（正在运行）
        if ! systemctl --user is-active gtd_backup.timer; then
            echo "Starting gtd_backup.timer"
            systemctl --user start gtd_backup.timer
        else
            echo "gtd_backup.timer is already running"
        fi
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}
