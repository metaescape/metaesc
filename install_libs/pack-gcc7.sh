#!/usr/bin/env bash
set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh
source $(dirname "${BASH_SOURCE[0]:-$0}")/../user_env.sh


function install_foliate() {
	local distro
	distro=$(whichdistro)
	print_info "ubuntu 22.04 后需要手动添加 gcc8 的源，主要是 cuda/nvcc 10.0 之前版本需要"

	if [[ $distro == "debian" ]]; then
        echo "deb [arch=amd64] http://archive.ubuntu.com/ubuntu focal main universe" | sudo tee /etc/apt/sources.list.d/gcc-7.list
        sudo apt update
        apt-cache policy g++-7
        apt-cache show g++-7
        sudo apt install g++-7
	elif [[ $distro == "redhat" ]]; then
		:
	elif [[ $distro == "arch" ]]; then
		:
	fi
}

function setup_foliate() {
	print_info "通过 sudo update-alternatives --config gcc 查看不同 gcc 版本"
	print_info "通过 sudo update-alternatives --config g++ 查看不同 g++ 版本"
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 2
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 2
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 1
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 1
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 1
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 1
}
