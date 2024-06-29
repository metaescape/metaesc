#!/usr/bin/env bash
set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh
source $(dirname "${BASH_SOURCE[0]:-$0}")/../user_env.sh

function install_deno() {
	local distro
	distro=$(whichdistro)

	if [[ $distro == "debian" ]]; then
		print_info "官方提供的 curl -fsSL https://deno.land/install.sh | sh 可能有网络问题"
		print_info "因此用 curl -fsSL https://x.deno.js.cn/install.sh | sh 代替"
		curl -fsSL https://x.deno.js.cn/install.sh | sh
        
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}

function setup_deno() {
	print_info "请手动配置 deno 环境变量, 添加到 ~/.bashrc 或 ~/.profile"
    print_info "export PATH=\"~/.deno/bin:\$PATH\""
}
