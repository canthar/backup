#!/bin/bash -e

# Simple script to create classic ext4 backup on external drive.
# On external drive (in reality a directory) it creates a bunch of directories with name $(date -Iseconds)
# Every directory has backup of all directories from /etc/backup.conf config file (one directory per line)
# It creates lots of hard links (rsync --link-dest)

usage() {
	echo 'Usage: backup output_directory'
}

find_last_backup() {
	DIR="$1"
	
	if [ -L "$1/last_backup" ]
	then
		readlink -f "$1/last_backup"
	fi
}

backup() {
	OUTPUT_DIR="$1"
	DIR="$2"
	LAST_BACKUP="$3"
	DIRNAME="$(basename "$DIR")"
	
	if [ "$LAST_BACKUP" ] && [ -d "$LAST_BACKUP/$DIRNAME" ]
	then
		rsync -aH --delete --link-dest="$LAST_BACKUP/$DIRNAME" "$DIR/" "$OUTPUT_DIR/$DIRNAME/"
	else
		rsync -aH "$DIR/" "$OUTPUT_DIR/$DIRNAME/"
	fi
}

create_backup() {
	BACKUP_DIR="$1"
	LAST_BACKUP="$2"
	DATE="$(date -Iseconds)"
	NEW_DIR="$1/$DATE"
	
	mkdir "$NEW_DIR"
	
	while read -r DIR
	do
		backup "$NEW_DIR" "$DIR" "$LAST_BACKUP"
	done < /etc/backup.conf
	
	rm "$BACKUP_DIR/last_backup" 2> /dev/null || true
	$(cd "$BACKUP_DIR" && ln -s "$DATE" last_backup)
}

if [ $# -ne 1 ]
then
	echo 'You must provide output_directory'
	usage
	exit 1
fi

BACKUP_DIR="$1"
if [ ! -d "$BACKUP_DIR" ]
then
	echo 'output_directory must be a directory'
	usage
	exit 1
fi

while read -r DIR
do
	if [ "${DIR:0:1}" != / ]
	then
		echo 'All paths in /etc/backup.conf must be absolute'
		exit 1
	fi
	
	if [ ! -d "$DIR" ]
	then
		echo 'All entries in /etc/backup.conf must be existing directories'
		exit 1
	fi
done < /etc/backup.conf

LAST_BACKUP="$(find_last_backup "$BACKUP_DIR")"

create_backup "$BACKUP_DIR" "$LAST_BACKUP"
