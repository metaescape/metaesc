#!/usr/bin/env bash

set -ue

#--------------------------------------------------------------#
##          Functions                                         ##
#--------------------------------------------------------------#

function helpmsg() {
    local script=${BASH_SOURCE[0]:-$0}
	print_info "${BASH_SOURCE[0]:-$0} 的几种用法举例：" 0>&2
	print_info "${script} --install/-i/install vscode i3"
    print_notice "      安装/更新 vscode 和 i3, 并且把它们的配置文件链接到系统的 ${HOME} 目录下"
	print_info "${script} --install/-i/install all:"
    print_notice "      安装/更新所有软件和配置"
	print_info "${script} --install server"
    print_notice "      安装服务器所需的软件和配置"
	print_info "${script} --update vscode i3:"
    print_notice "      和  --install 完全一样，因为安装和升级基本都是一样的命令，并且重复添加软链接配置并不会有什么副作用"
	print_info "${script} --setup all:"
    print_notice "      对所有软件的配置文件进行设置/链接"
	print_info "${script} --setup emacs i3:"
    print_notice "      对 emacs 和 i3 进行配置，更多用来打印出目标软件的配置方式，用于提醒和查询"
}

#--------------------------------------------------------------#
##          main                                              ##
#--------------------------------------------------------------#

function main() {
	local current_dir
	current_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
	main_dir=$(dirname "$current_dir")
	source $main_dir/install_libs/utilfuncs.sh

    print_info "请确保 $main_dir/user_env.sh 中环境变量是正确的："
    cat "$main_dir/user_env.sh"
    print_info "其中 CODE 为源码项目路径，INSTALLERS 为 deb, appimg 等文件下载路径"
	source $main_dir/user_env.sh

    print_info ""
    print_info "---------------------------------"
    print_info ""


	while [ $# -gt 0 ]; do
		case ${1} in
			-h|--help)
				helpmsg
                exit 1
				;;
			install|-i|--install)
				shift
                source $main_dir/install_libs/_install-pkgs.sh
                # source $current_dir/lib/_install-pkgs.sh
                exit 1
                ;;
			update|-u|--update)
				shift
                source $main_dir/install_libs/_install-pkgs.sh
                exit 1
                ;;
			setup|-s|--setup)
				shift
                source $main_dir/install_libs/_setup-pkgs.sh
                exit 1
				;;
            *) ;;

			esac
			shift
	done
}

main "$@"
