#!/usr/bin/env bash

set -ue

# 确保可以单独执行该脚本
source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh
source $(dirname "${BASH_SOURCE[0]:-$0}")/../user_env.sh

function install_typora() {
	local distro
	distro=$(whichdistro)
	if [[ $distro == "debian" ]]; then
		print_info "开始安装/更新 typora, 如有问题参考 typora 官网 https://support.typora.io/Typora-on-Linux/"

		# 以下方式无法访问 typora 官方源，因此用下载 deb 方式
		## 设置公钥文件路径和最大天数
		#PUBLIC_KEY_FILE="/etc/apt/trusted.gpg.d/typora.asc"
		#MAX_DAYS=30

		## 检查公钥文件是否存在且在MAX_DAYS天内更新过
		#if [ ! -f "$PUBLIC_KEY_FILE" ] || [ $(find "$PUBLIC_KEY_FILE" -mtime +$MAX_DAYS -print) ]; then
		#	print_info "typora 公钥文件不存在或者已经过期，需要重新下载到 $PUBLIC_KEY_FILE"
		#	wget -qO - https://typoraio.cn/linux/public-key.asc | sudo tee "$PUBLIC_KEY_FILE"
		#	# add Typora's repository
		#	sudo add-apt-repository 'deb https://typora.io/linux ./'
		#	print_success "typora 源添加到 /etc/apt/sources.list.d/ 完毕"
		#else
		#	print_info "公钥文件是最新的，不需要重新下载。"
		#fi

		#print_info "获取最新的软件列表并安装最新的 typora"
		#sudo apt update
		#sudo apt-get install typora
		#print_success "typora 安装/更新完毕"

        current_version="typora_1.7.6_amd64.deb"
        if ! command -v typora &> /dev/null

        then
			print_info "安装 typora..."
            pushd $INSTALLERS
			typora=$(find . -maxdepth 1 -name "typora_*.deb" -print 2>/dev/null)
			if [ -z "$typora" ]; then
                print_info "下载 $current_version"
				wget https://download.typora.io/linux/$current_version
                typora=$current_version
            fi
			# 安装.deb文件
		    sudo apt install ./$typora
			print_success "typora 安装完毕"
            popd
		else 
			print_success "typora 已安装"
			print_info "如需重装，请先 apt remove typora 卸载 typora"
		    print_info "从 https://typora.io/releases/all 中检查最新版本，当前为 $typora"
		    print_info "如果需要更新版本则删除 $INSTALLS/$typora 并修改本脚本里的 current_version 为最新版本"
		    print_info "重新执行 ./metaesc.sh -i typora"
		    print_info "如果网络有问题，请手动下载 deb"
        fi

	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}


function setup_typora() {
    print_notice "通过 preferences -> general -> open advance setting "
    print_notice "或打开 typora 的设置文件 ~/.config/Typora/conf/conf.user.json ，添加以下设置： "
	print_notice '"KeyBinding": { "Auto": "F5" }'
}
