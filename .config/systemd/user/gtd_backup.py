import shutil
import datetime
import os
import sys
history = 20
date_format = "%Y%m%d_%H%M%S_"  # defalult
now = datetime.datetime.now().strftime(date_format)
src_files_name = ["projects.gtd", "inbox.gtd"]
src_fold = os.path.expanduser("~/org/historical")
src_files = [os.path.join(src_fold, name) for name in src_files_name]
bak_fold = "/data/resource/gtds_backup"
backup_files = [os.path.join(bak_fold, now+name) for name in src_files_name]
for src, backup in zip(src_files, backup_files):
    shutil.copy2(src, backup)
all_baks = []
for (dirpath, dirnames, filenames) in os.walk(bak_fold):
    all_baks.extend([os.path.join(bak_fold, name) for name in filenames])
if len(all_baks) > history:
    need_delete = sorted(all_baks)[:-20]
    for path in need_delete:
        os.remove(path)
