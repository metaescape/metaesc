#!/usr/bin/env bash
set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh
source $(dirname "${BASH_SOURCE[0]:-$0}")/../user_env.sh


function install_foliate() {
	local distro
	distro=$(whichdistro)
	print_info "snap 方式会导致无法访问到挂载目录下的文件，因此用非官方 ppa 方式"

	if [[ $distro == "debian" ]]; then
		print_info "安装 foliate 便于阅读 EPUB	"
		print_info "添加 ppa:apandada1/foliate-ppa 到 /etc/apt/sources.list.d"
		sudo add-apt-repository ppa:apandada1/foliate
		sudo apt update
		sudo apt install foliate
		print_info "该 ppa 源二进制在 /usr/bin/com.github.johnfactotum.Foliate, 手动创建软链接"
		ln -s /usr/bin/com.github.johnfactotum.Foliate ~/.local/bin/foliate
		print_success "foliate 安装/更新完毕"
        
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}

function setup_foliate() {
    print_info "在 GUI 中设置主题字体等"
}
