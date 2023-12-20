# Metaesc

个人在 ubuntu 上使用的配置文件管理脚本，包括 dotfiles 和各类自用的交互脚本

首先修改 user_env.sh 中的两个环境变量：

- CODE 为源码项目路径（比如需要编译的 emacs 源码会自动解压到该路径）
- INSTALLERS 为 zip, deb, appimg 等文件下载路径

使用方式举例：

```bash
./metaesc.sh --install/-i/install vscode i3
        安装/更新 vscode 和 i3, 并且把它们的配置文件链接到系统的 ${HOME} 目录下
./metaesc.sh  --install/-i/install all
        安装/更新所有软件和配置
./metaesc.sh  --install server
        安装服务器所需的软件和配置
./metaesc.sh --update vscode i3
        和 --install 完全一样，因为安装和升级基本都是一样的命令，并且重复添加软链接配置并不会有什么副作用
./metaesc.sh --setup all
        对所有软件的配置文件进行设置/链接
./metaesc.sh --setup emacs i3
        对 emacs 和 i3 进行配置，更多用来打印出目标软件的配置方式，用于提醒和查询
./metaesc.sh -s conda
        -s 是 --setup 的简写
        对 conda 和 pip 进行配置, 主要建立 pip.conf 和 .condarc 软链接
```

## 具体文件
i3 相关文件：
```bash
.config/i3/config
.config/i3status/config
.config/compton.conf
.config/dunst/dunstrc
```

