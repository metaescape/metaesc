#!/usr/bin/env bash

set -ue
_cur_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
source "${_cur_dir}/utilfuncs.sh"

distro=$(whichdistro)
if [[ $distro == "redhat" ]]; then
    :
elif [[ $distro == "debian" ]]; then
    for arg in "$@"; do
        pack="${_cur_dir}/pack-${arg}.sh"
        if [ ! -e $pack ]; then
            print_warning "没有找到 ${arg} 的管理文件 ${pack}，跳过"
            continue;
        # Check that the function exists
        fi

        source $pack
        func="install_${arg}"
        if ! declare -f "$func" >/dev/null; then
            print_warning "没有找到 ${arg} 的安装函数，跳过"
            continue;
        fi

        eval "$func"
    done
fi
