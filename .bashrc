# # [[id:20230413T164119.017243][最终导出:1]]
# # [[id:20240120T012603.922091][basic]]
#!/usr/bin/env bash
myconf_dir=$HOME/metaesc/
export CONF_DIR=$myconf_dir

export VISUAL=vim
#export TERM=screen-256color
export EDITOR="$VISUAL"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

if [ -t 1 ]; then # avoid bash bind warning: line editing not enabled.
bind -m emacs-standard '"\C-g\C-g": " \C-b\C-k \C-u`__fzf_cd__`\e\C-e\er\C-m\C-y\C-h\e \C-y\ey\C-x\C-x\C-d"'
bind -m emacs-standard '"\C-j\C-l": "**\e\e"'

bind -m emacs-standard '"\C-gs": "git status\C-m"'

bind -m emacs-standard '"\C-gd": "git diff "'
fi
# # basic ends here
# # [[id:20240120T012708.744588][colors-prompt]]
function showcolors {
    for i in 00{2..8} {0{3,4,9},10}{0..7}; do
        echo -e "$i \e[0;${i}mcolor test \e[00m  \e[1;${i}mSubdermatoglyphic text\e[00m"
    done

    for i in 00{2..8} {0{3,4,9},10}{0..7}
    do for j in 0 1
        do echo -e "$j;$i \e[$j;${i}mSubdermatoglyphic text\e[00m"
        done
    done
}

#color for tmux, vim
pcolor() {
    for i in {0..255} ; do
        printf "\x1b[38;5;${i}mcolour${i} "
    done
}

if [ -e ~/.local/share/lscolrs.sh ]; then
    . "~/.local/share/lscolors.sh"
else
    export CLICOLOR=1
    #https://zhuanlan.zhihu.com/p/60880207
    #export LSCOLORS=ExGxFxdaCxDaDahbadeche
    #https://apple.stackexchange.com/questions/33677/how-can-i-configure-mac-terminal-to-have-color-ls-output
    export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
fi

LRED='\033[01;31m'
YELLOW='\033[01;32m'
BLUE='\033[01;34m'
NC='\033[00m'

if [ -f /usr/lib/git-core/git-sh-prompt ]; then
    . /usr/lib/git-core/git-sh-prompt
fi
u_name=$(basename $HOME);
if [ "${u_name}" == "root" ]; then
    export PS1="[ \$? ${LRED} \w ${NC}] []\$(__git_ps1)\n >_ ";
else
    export PS1="[ \$? ${YELLOW}\u@\h${NC}:${BLUE}\w${NC} ] []\$(__git_ps1)\n >_ "
fi
# # colors-prompt ends here
# # [[id:20240120T012727.081695][alias]]
alias ls='ls --color=always'
alias ll='ls -l -h -a'
alias la='ls -a'

alias ..='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'

#For Dirs and files
alias fhere='find . -iname '
alias disk='df -Th --total | less'
alias dsize="du -hs * | sort -hr"
alias dus="du -hs * | sort -hr"
alias ds='df -h | head -n 1;df -h | sort | grep -v "tmpfs\|loop"'
alias fs="find -type f -exec du -Sh {} + | sort -rh | head -n 5"
alias tree='tree -A -N'

if [[ $(uname) == 'Linux' ]]; then
    alias open=xdg-open
    alias wallp='find /data/resource/pictures/wallpaper-dark | fzf --bind "ctrl-l:execute(feh --bg-fill {})"'
fi

ec () {
   nohup ~/metaesc/lib/popup-emacsclient.sh $@ > /dev/null 2>&1 &
}


tmp() {
    [[ ! -d /tmp/test	]] && mkdir /tmp/test
    push /tmp/test
}

ts() { #往右侧tmux pane发命令
    args=$@
    tmux send-keys -t right "$args" C-m
}


# quick conf #
alias vsh='vim ~/.bashrc'
alias .sh='. ~/.bashrc'
alias vvi='vim ~/.vim/vimrc'
alias vmx='vim ~/.tmux.conf'
alias conf='push ${myconf_dir}'
alias vi3='vim ~/.config/i3/config'
alias vtip='vim ~/org/historical/entry.org'
alias sshall='$CONF_DIR/utils/bin/conn_server.sh ssh'
alias sharewifi='sudo iptables -t nat -A POSTROUTING -o wlp1s0 -j MASQUERADE'
# # alias ends here
# # [[id:b97b7ca0-48e6-49da-b8b0-16b3682db416][fzf-pushd]]
fzf-down() {
    fzf --height 50% "$@" --border
}

push() {
    if [[ $# == 0 ]]; then # selection pushd
        local targets=$(dirs -v -l | tail -n +2  |\
                fzf-down -0 --reverse --ansi -m --preview-window right:40% \
                --query "$READLINE_LINE" \
            --preview 'ls --color=always {-1}' --expect "ctrl-d" )
        READLINE_LINE=''
        [[ -z ${targets} ]] && return;
        echo "$targets" | grep 'ctrl-d' > /dev/null
        if [ $? != 0 ]; then
            while read id path; do
                [[ ${id} == 0 ]] && continue
                popd +${id} > /dev/null
                pushd ${path} > /dev/null
            done <<< $(echo "${targets}" | tail -n +2)
        else #pop
            while read id path; do
                popd +${id} > /dev/null
            done <<< $(echo "${targets}" | tail -n +2 | sort -r)
        fi
    else #manual pushd
        local origin_path=$(pwd)
        for path in $@; do
            local full_path=$(cd ${origin_path}; cd "${path}"; pwd)
            local target=$(dirs -v -l | grep "${full_path}$")
            if [[ ! -z ${target} ]]; then
                read id path <<< ${target}
                [[ ${id} == 0 ]] && continue #current dir
                popd +${id} > /dev/null
                pushd ${full_path} > /dev/null
            else
                pushd ${full_path} > /dev/null
            fi
        done
    fi
}

alias j='push'

# 本机默认编辑器为vi，需要改成vim
vi() {
	if [ -d $1 ]; then
        j $1
    else
        vim $1
    fi
}
# # fzf-pushd ends here
# # [[id:20240120T012818.286398][conda]]
_conda_activate() {
    local target=$(conda env list | grep -v "^#" \
            | fzf-down -0 --reverse --ansi \
        | cut -d " " -f1)
    [[ -n ${target} ]] && conda activate ${target}
}
alias cona='_conda_activate'
alias conls='conda list | fzf --reverse -0 --ansi'

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/pipz/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/pipz/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/pipz/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/pipz/miniconda3/bin:$PATH"
    fi
fi
conda activate usr
unset __conda_setup
# <<< conda initialize <<<
# # conda ends here

# # [[id:0a7e0386-6b01-469b-88e9-41c8f3faf64e][rsync]]
rpush() {
    remote="${1:-tc}"
	#-i means differents with add or delete, if use -v only show difference
    rsync -aui --delete --dry-run /data/resource/ "${remote}":/root/resource
    read -p "Are you sure to push to ${remote} server? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
		rsync -auhPz --delete /data/resource/ "${remote}":/root/resource --backup --backup-dir=/root/bak_resource
    fi
}

rpull() {
    remote="${1:-tc}"
    rsync -aui --delete --dry-run "${remote}":/root/resource/ /data/resource
    read -p "Are you sure to pull from ${remote} server? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rsync -auhPz --delete "${remote}":/root/resource/ /data/resource
    fi
}

rget() { #tmp sync
    scp -r tc:/tmp/${1} ./
}


rput() { #tmp sync
    scp -r ${1} tc:/tmp/
}

__grsync() {
	#-i means differents with add or delete, if use -v only show difference
	local prefixes
	local pathes
	local home=$(ssh ${3} 'printf $HOME')
	if [[ ${2} == 'to' ]]; then
		prefixes=("$HOME" "${3}:${home}")
	elif [[ ${2} == 'from' ]]; then
		prefixes=("${3}:${home}" "$HOME")
	fi
	if [[ ${1} == 'all' ]]; then
		pathes=("/database" "/codes/codebase")
	elif [[ ${1} == 'code' ]]; then
		pathes=("/codes/codebase")
	elif [[ ${1} == 'data' ]]; then
		pathes=("/database")
	fi
	local src
	local target
	for path in ${pathes[@]}; do
		echo "${prefixes[0]}${path}/" "${prefixes[1]}${path}"
		rsync -auim --dry-run \
			--exclude={.git,run,.idea,.pytest_cache} \
			--exclude '*/lightning_logs' \
			--exclude '*/.ipynb_checkpoints' --exclude '*/__pycache__' \
			--exclude '*/tarball' \
			"${prefixes[0]}${path}/" "${prefixes[1]}${path}"
		done
    read -p "Are you sure to push to ${3} server? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
		for path in ${pathes[@]}; do
			rsync -auhPzm \
			--exclude={.git,run,.idea,.pytest_cache} \
			--exclude '*/lightning_logs' \
			--exclude '*/.ipynb_checkpoints' --exclude '*/__pycache__' \
			--exclude '*/tarball' \
			"${prefixes[0]}${path}/" "${prefixes[1]}${path}"
		done
	fi
}

_grsync() {
	if [[ "$#" == 1 ]]; then
	    echo "only accept 0 or 2 argument"
	elif [[ "$#" == 2 ]]; then
		__grsync ${2} $rsync_direction ${1}
	elif [[ "$#" == 0 ]]; then
		__grsync all $rsync_direction 127
	fi
} # -m : ignore empty dirs

gpush() {
	local sorted_args=$(echo $@ | xargs -n1 | sort | xargs)
	rsync_direction=to
	_grsync $sorted_args
}

gpull() {
	local sorted_args=$(echo $@ | xargs -n1 | sort | xargs)
	rsync_direction=from
	_grsync $sorted_args
}

# User specific aliases and functions
deep() {
    sudo chmod 000 /data/resource/.deep
}

undeep() {
    sudo chmod 755 /data/resource/.deep
}

port=7890
proxy(){
    echo export https_proxy=http://127.0.0.1:$port
    echo export http_proxy=http://127.0.0.1:$port
    echo export all_proxy=http://127.0.0.1:$port
    export https_proxy=http://127.0.0.1:$port
    export http_proxy=http://127.0.0.1:$port
    export all_proxy=https://127.0.0.1:$port
}

unproxy(){
    echo export https_proxy=""
    echo export http_proxy=""
    echo export all_proxy=""
    export https_proxy=""
    export http_proxy=""
    export all_proxy=""
}
unproxy > /dev/null
# # rsync ends here
# # 最终导出:1 ends here
