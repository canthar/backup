# backup
## Usage ##
backup output_directory directories_to_backup...

### Example ###
backup /mnt/external_drive /home/user/projects /etc

## Disc layout ##
Script creates new directory for every backup with name $(date -Iseconds).
It alsa maintains symlink for recent backup with name last_backup

### Result ###
```
# ll /run/backup
total 28
drwxr-xr-x 3 user users  4096 cze 24 15:40 2017-06-24T13:44:09+02:00
drwxr-xr-x 3 user users  4096 cze 24 15:40 2017-06-24T14:45:32+02:00
drwxr-xr-x 4 user users  4096 cze 24 15:39 2017-06-24T15:39:37+02:00
lrwxrwxrwx 1 user users    25 cze 24 15:39 last_backup -> 2017-06-24T15:39:37+02:00
```

## How it works ##
It's just a simple wrapper over rsync --link-dir=$LAST_BACKUP
