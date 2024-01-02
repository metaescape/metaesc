.SILENT:
.SUFFIXES:
.PHONY: help

# 获取所有脚本名称（不包括前缀和后缀）
SCRIPTS := $(patsubst pack-%.sh,%,$(notdir $(wildcard install_libs/pack-*.sh)))

# 定义两套命令
INSTALL_TARGETS := $(addsuffix -install,$(SCRIPTS))
SETUP_TARGETS := $(addsuffix -setup,$(SCRIPTS))

# 所有目标
ALL_TARGETS := $(INSTALL_TARGETS) $(SETUP_TARGETS)

# 安装规则
$(INSTALL_TARGETS):
	./metaesc.sh -i $(@:-install=)

# 设置规则
$(SETUP_TARGETS):
	./metaesc.sh -s $(@:-setup=)

init-tangle: wemacs-tangle

wemacs-tangle:
	emacs --batch -l ~/metaesc/make_tangle.el --eval "(tangle-config-file \"init\")"
	emacs

xwish-tangle:
	emacs --batch -l ~/metaesc/make_tangle.el --eval "(tangle-config-file \"xwish\")"

# i3-tmp:
# 	sed '/:tangle/{/myconf\/.config\/i3\/config/!d}' ~/org/logical/i3wm.org > /tmp/i3.org

i3-tangle: 
	emacs --batch -l ~/metaesc/make_tangle.el --eval "(tangle-config-file \"i3\")"
	i3-msg "reload"
	i3-msg "restart"

tmux-tangle:
	emacs --batch -l ~/metaesc/make_tangle.el --eval "(tangle-config-file \"tmux\")"
	tmux source-file ~/.tmux.conf

bashrc-tangle:
	# sed '/:tangle/{/bashrc/!d}' ~/org/logical/bash.org > /tmp/bashrc.org
	emacs --batch -l ~/metaesc/make_tangle.el --eval "(tangle-config-file \"bashrc\")"

inputrc-tangle:
	sed '/:tangle/{/inputrc/!d}' ~/org/logical/cmdline.org > /tmp/inputrc.org
	emacs --batch -l ~/metaesc/make_tangle.el --eval "(tangle-config-file \"inputrc\")"

vimrc-tangle:
	sed '/:tangle/{/metaesc\/.vim\/vimrc/!d}' ~/org/logical/vim.org > /tmp/vimrc.org
	emacs --batch -l ~/metaesc/make_tangle.el --eval "(tangle-config-file \"vimrc\")"

update-org-ids:
	emacs --batch \
	      --eval '(setq org-directory "~/org")' \
	      --eval '(setq org-id-locations-file "~/.wemacs/.org-id-locations")' \
	      --eval '(require (quote org-id))' \
	      --eval '(org-id-update-id-locations (directory-files-recursively org-directory "\\.\\(org\\|gtd\\)"))'

backup-emacs-org:
	mkdir -p /data/resource/emacs_org_backup
	tar -czvf /data/resource/emacs_org_backup/$$(date +'%Y%m%d')-wemacs.tar.gz ~/.wemacs
	tar -czvf /data/resource/emacs_org_backup/$$(date +'%Y%m%d')-org.tar.gz ~/org
	@echo "Backup completed."

# 帮助信息
help:
	@echo "Available targets:"
	@$(foreach target,$(ALL_TARGETS),echo "  $(target)";)
	@echo "  help"
	@echo "  autocomplete"
