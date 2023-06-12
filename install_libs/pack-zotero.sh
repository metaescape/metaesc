#!/usr/bin/env bash

set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

function install_zotero() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
		print_info "安装 zotero"

        if ! command -v zotero &> /dev/null
        then
            pushd /data/installer/
            ZOTERO=Zotero-6.0.26_linux-x86_64.tar.bz2
            if [ ! -e ./$ZOTERO ]; then
		        print_info "请手动从 https://www.zotero.org/download/ 中下载 tar 包"
                exit
            fi
            tar -jxvf $ZOTERO
            sudo mv ./Zotero_linux-x86_64/ ~/.local/zotero
            ~/.local/zotero/set_launcher_icon
            ln -sf ~/.local/zotero/zotero.desktop ~/.local/share/applications/zotero.desktop
            popd
        fi
        print_success "zotero 安装完毕"
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}

function setup_zotero() {
	local distro
	distro=$(whichdistro)
    _cur_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
    conf_dir="$(builtin cd "$_cur_dir" && git rev-parse --show-toplevel)"
	if [[ $distro == "debian" ]]; then

		print_info "在 zotero 中手动配置："
        print_notice "Better bibtex 参考： https://retorque.re/zotero-better-bibtex/installation/"
        print_notice "edit -- preference -- betterBibtex -- automatic export -- Add urls to BibTex export -- in the url field"
        print_notice ""

	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}
