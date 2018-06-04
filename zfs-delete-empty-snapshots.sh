#! /bin/sh

# https://gist.github.com/SkyWriter/58e36bfaa9eea1d36460

# For each of the above filesystems, delete empty snapshots except the latest snapshot

FIRST_RELEASE=2017-08-25
VERSION=1.0
PROJECT_PAGES="https://github.com/Josef-Friedrich/zfs-delete-empty-snapshots.sh"
SHORT_DESCRIPTION='Delete empty ZFS snapshots in a secure manner.'
USAGE="Usage: zfs-delete-empty-snapshots.sh <dataset>

$SHORT_DESCRIPTION
"

_get_datasets() {
	zfs list -Hr -t snapshot "$1" | \
		grep '@' | \
		cut -d '@' -f 1 | \
		uniq
}

_get_empty_snapshots() {
	zfs list -Hr -d1 -t snapshot -o name,used -s creation "$1" | \
		sed '$d' | \
		awk ' $2 == "0" { print $1 }'
}

## This SEPARATOR is required for test purposes. Please don’t remove! ##

if [ -z "$1" ]; then
	echo "$USAGE" >&2
	exit 1
fi

DATASETS=$(_get_datasets "$1")

for DATASET in $DATASETS ; do
	SNAPSHOTS=$(_get_empty_snapshots "$DATASET")
	for SNAPSHOT in $SNAPSHOTS ; do
		# See https://www.mail-archive.com/zfs-discuss@opensolaris.org/msg17752.html"
		USED=$(zfs list -H -o used "$SNAPSHOT")
		if [ "$USED" = "0" ]; then
			echo "Destroying empty snapshot “$SNAPSHOT”! (USED=$USED)"
			zfs destroy "$SNAPSHOT"
		fi
	done
done
