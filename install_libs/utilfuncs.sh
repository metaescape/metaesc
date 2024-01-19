#!/usr/bin/env bash

function print_default() {
	echo -e "$*"
}

function print_info() {
	echo -e "\e[1;36m$*\e[m" # cyan
}

function print_notice() {
	echo -e "\e[1;35m$*\e[m" # magenta
}

function print_success() {
	echo -e "\e[1;32m$*\e[m" # green
}

function print_warning() {
	echo -e "\e[1;33m$*\e[m" # yellow
}

function print_error() {
	echo -e "\e[1;31m$*\e[m" # red
}

function print_debug() {
	echo -e "\e[1;34m$*\e[m" # blue
}

function chkcmd() {
	if ! builtin command -v "$1"; then
		print_error "${1} command not found"
		exit
	fi
}

function yes_or_no_select() {
	local answer
	print_notice "Are you ready? [yes/no]"
	read -r answer
	case $answer in
		yes | y)
			return 0
			;;
		no | n)
			return 1
			;;
		*)
			yes_or_no_select
			;;
	esac
}

function append_file_if_not_exist() {
	contents="$1"
	target_file="$2"
	if ! grep -q "${contents}" "${target_file}"; then
		echo "${contents}" >>"${target_file}"
	fi
}

function whichdistro() {
	#which yum > /dev/null && { echo redhat; return; }
	#which zypper > /dev/null && { echo opensuse; return; }
	#which apt-get > /dev/null && { echo debian; return; }
	if [ -f /etc/debian_version ]; then
		echo debian
		return
	elif [ -f /etc/fedora-release ]; then
		# echo fedora; return;
		echo redhat
		return
	elif [ -f /etc/redhat-release ]; then
		echo redhat
		return
	elif [ -f /etc/arch-release ]; then
		echo arch
		return
	elif [ -f /etc/alpine-release ]; then
		echo alpine
		return
	fi
}

function git_clone_or_fetch() {
	local repo="$1"
	local dest="$2"
	local name
	name=$(basename "$repo")
	if [ ! -d "$dest/.git" ]; then
		print_default "Installing $name..."
		print_default ""
		mkdir -p $dest
		git clone --depth 1 $repo $dest
	else
		print_default "Pulling $name..."
		(
			builtin cd $dest && git pull --depth 1 --rebase origin "$(basename "$(git symbolic-ref --short refs/remotes/origin/HEAD)")" ||
			print_notice "Exec in compatibility mode [git pull --rebase]" &&
			builtin cd $dest && git fetch --unshallow && git rebase origin/"$(basename "$(git symbolic-ref --short refs/remotes/origin/HEAD)")"
		)
	fi
}

function mkdir_not_exist() {
	if [ ! -d "$1" ]; then
		mkdir -p "$1"
	fi
}

function countdown_warning() {
    local duration=$1
    local software_name=$2
    local script_path=$3

    for ((i=duration; i>0; i--)); do
        print_info "注意：这将可能覆盖您的 ${software_name} 原始配置。您有 ${i} 秒时间考虑，使用 Ctrl+C 取消操作。"
        print_info "请查看脚本以了解更多详情：${script_path}"
        sleep 1
    done
}
