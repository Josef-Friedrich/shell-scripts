[![Build Status](https://travis-ci.org/Josef-Friedrich/shell-scripts.svg?branch=master)](https://travis-ci.org/Josef-Friedrich/shell-scripts)

# shell-scripts

A collection of hopefully useful shell scripts

## Coding style

* Use tabs for indentation
* Prefix functions with _
* Variable names are UPPERCASE

Example:

```sh
while getopts ":b:ht" OPT; do
	case $OPT in
		b)
			BODY="$OPTARG"
			;;
		h)
			_usage
			;;
		t)
			SUBJECT="Test mail "
			BODY="Sent on $(date) to $MAILLOG_EMAIL."
			echo "Sending test mail to $MAILLOG_EMAIL."
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			;;
	esac
done

shift $((OPTIND-1))

if [ -z "$SUBJECT" ]; then
	SUBJECT="$1"
fi

FILE="$2"

if [ -z "$SUBJECT" ]; then
	_usage
fi

TMP_FILE=/tmp/maillog.sh_$(date +%s)
if [ ! -f "$FILE" ] && [ -n "$BODY" ]; then
	echo "$BODY" > $TMP_FILE
	FILE=$TMP_FILE
fi

if [ ! -f "$FILE" ]; then
	FILE=$TMP_FILE
	while read DATA; do
		echo "$DATA" >> "$FILE"
		echo "$DATA"
	done
fi

mail -s "$SUBJECT" $MAILLOG_EMAIL < "$FILE"
```

# Test

Run test with this command: `bats test`

---

# Help messages of all scripts

## ./bandwidth-limiting-single-host.sh

```
Usage: bandwidth-limiting-single-host.sh <dest> <bandwidth>

	<dest>: Destination ip address or url
	<bandwith>: Bandwith rates like '1000kbps'. See tc documentation.


OPTIONS:
	-d <dev>: Network interface, e. g.: eth1, eno1
	-h:       Show this message.

or

bandwidth-limiting-single-host.sh [-d <network-interface> ] clear
```

## ./beepbox.sh

```
Usage: beepbox.sh [error|success|sync-start|sync-end|warning]
```

## ./cue-split.sh

```
Usage: cue-split.sh [<path>]

Supported formats: APE, FLAC, MP3, OGG, TTA, WV, WAV
Frontend for:	cuetools, shntool, mp3splt
Optional dependencies: flac, mac, wavpack, ttaenc

The default path is the current directory.

The folder must contain only one *.cue file and one audio file.
```

## ./easy-nsca.sh

```
Usage: easy-nsca.sh [<options>] <service> <check-command>

Environment variables: (to place in your *rc files of your shell)

	- NSCA_SERVER
	- NSCA_CONFIG
	- PATH_CHECK

export NSCA_SERVER="123.123.123.123"
export NSCA_CONFIG="/etc/send_nsca.cfg"
export PATH_CHECK="/usr/lib/nagios/plugins"

Options:
	-c NSCA_CONFIG:    NSCA config file (default: /etc/send_nsca.cfg)
	-h:                Show this help.
	-H NSCA_SERVER:    IP address of the Nagios server.
	-n HOST_SERVICE:   Host of the service.
	-p PATH_CHECK: Folder containing the check commands.
	                   (default: /usr/lib/nagios/plugins)
	-o OUTPUT:         Output of the check commands.
	-r RETURN:         Plugin return codes: 0 Ok, 1 Warning,
	                   2 Critical, 3 Unkown.

Examples:

easy-nsca.sh "APT" "check_apt -t 100"
easy-nsca.sh "Disk space" "check_disk -w 10% -c 5% /dev/sda1"
```

## ./figlet-comment.sh

```
FIGLET-COMMENT(1)

NAME
			 figlet-comment - Converts text to ASCII Art text using figlet and adds comments.

SYNOPSIS
			 figlet-comment [-f f ont style -s comment style] text

DESCRIPTION
			 Converts text to ASCII Art text using figlet and adds comments.

OPTIONS
			 ·   -f schrift: Specify a font style like moscow. Default font style is big. You get a list of possible font styles using figlist(1).

			 ·   -s comment style: Specifiy a comment style like bash. Default comment style is cstyle.

			 ·   none

			 ·   bash

			 ·   cstyle

			 ·   cplus

			 ·   vbasic

			 ·   tex

EXAMPLES
			 figlet-comment -s bash -f moscow foo bar

SEE ALSO
			 figlet(1), figlist(1)
```

## ./figlet-fonts.sh

```
Usage: figlet-fonts.sh

Options:
	-h, --help: Show this help message.
```

## ./git-submodule-rm.sh

```
Usage: git-submodule-rm.sh <path>

Options:
	-h Show this help message.
```

## ./imagemagick-deskew.sh

```
Usage: imagemagick-deskew.sh

Options:
	-h, --help: Show this help message.
```

## ./imagemagick-imslp.sh

```
Usage: imagemagick-imslp.sh [-bfht] <filename-or-glob-pattern>

This is a wrapper script around imagemagick to process image files
suitable for imslp.org (International Music Score Library Project)

http://imslp.org/wiki/IMSLP:Musiknoten_beisteuern

OPTIONS:
	-c: Use CCITT Group 4 compress. This options generates a PDF file
	-b: backup original images (add .bak to filename)
	-f: force
	-h: Show this help message
	-t: threshold, default 50%

```

## ./images-to-date-folders.sh

```
Usage: images-to-date-folders.sh

Options:
	-h, --help: Show this help message.
```

## ./maillog.sh

```
Usage: maillog.sh [-b BODY ] <subject> <text-file-to-send>

Wrapper script to easily send log informations by email.

This script is designed to be used in Shell scripts. By design there is
no '-e' to specify an email address. The email address should be stored
in the 'rc' (run control) files of your shell (for more informations
read the next lines). The maillog.sh script can be used in many
places of your scripts. Because the email address is only stored on
one place, the address can easily be changed and you not have to edit
all your scripts.

# Use cases

## Send a temporay and manually created log file:

	echo 'Some log messages' > /tmp/logs
	echo '... and more log message' >> /tmp/logs
	maillog.sh 'Log subject' /tmp/logs

## Specify the body text by a command line option:

	maillog.sh -b 'Some log messages' 'Log subject'

## Pipe to maillog.sh:

	echo 'Some log messages' | maillog.sh 'Log subject'

# How to specify the email address?

1. Edit this script (maillog.sh) and
place your log email address on line 3

	MAILLOG_EMAIL=yourmail@example.com

or / and:

2. Add this line to your ~.bashrc, ~.bash_profile or ~.zshrc or
whatever your run control file of your shell is:

export MAILLOG_EMAIL=yourmail@example.com

Don't forget to execute your scripts in a login shell (e. g. bash -l)
in order to get the 'MAILLOG_EMAIL' variable.

Options:
	-b BODY:  Text for the body of the mail.
	-h:       Show this help text.
	-t:       Send a test mail (no further arguments needed).
```

## ./mscore-to-eps.sh

```
Usage: mscore-to-eps.sh [-h] [-n] [<path>]

Convert MuseScore files to eps using 'pdfcrop' and 'pdftops' or
'Inkscape'. If <path> is omitted, all MuseScore files in the
current working directory are converted. <path> can be either a
directory or a MuseScore file.

DEPENDENCIES
	'pdfcrop' (included in TeXlive) and 'pdftops' (Poppler tools) or
	'Inkscape'

OPTIONS
	-h, --help	Show this help message.
	-n, --no-clean 	Do not remove / clean intermediate
	                *.pdf files
```

## ./mv-to-alphbetical-folders.sh

```
Usage: mv-to-alphbetical-folders.sh

Options:
	-h, --help: Show this help message.
```

## ./mysqldump-all.sh

```
Usage: mysqldump-all.sh -u <username> -p <password>

	-d: Backup directory
	-h: Show this help message
	-n: Name to distinguish backup runs
	-o: Delete backup files older than (in days)
	-p: MySQL password
	-P: Prefix for the mysql and mysqldump binaries e. g. '/usr/bin' or
	    'docker exec mysql '
	-u: MySQL username
```

## ./otfinfo-all.sh

```
Usage: otfinfo-all.sh

Options:
	-h, --help: Show this help message.
```

## ./rm-by-extension.sh

```
```

## ./rm-empty-folder.sh

```
Usage: rm-empty-folder.sh

Options:
	-h, --help: Show this help message.
```

## ./rm-latex-tmp-files.sh

```
Usage: rm-latex-tmp-files.sh

Options:
	-h, --help: Show this help message.
```

## ./rm-os-tmp-files.sh

```
Usage: rm-os-tmp-files.sh

Options:
	-h, --help: Show this help message.
```

## ./rm-video-by-height.sh

```
rm-video-by-height.sh [-hd] [ -H <height> ] <folder>

	-d: Dry run
	-h: Show this help message
	-H: Height of the min resolution (e. g. 720)

```

## ./rsync-backup.sh

```
Usage: rsync-backup [-abBdehlLmn] <source> <destination>

DESCRIPTION
	A wrapper command for rsync with the main features:
		- Backups in in the folder '.rsync-backup/backups'
		- Logging per e mail.
		- Source und destination folder checks over scp.

OPTIONS
	-a <path>: Creates a .rsync-backup/please-sync affirmation file for the given folder.
	-b: Beep.
	-B: Backup.
	-d: Delete all log file in the log folder.
	-e: Show execution log.
	-h: Show help.
	-l: Show log summary.
	-L: Show log folder.
	-m: Send logs per mail.
	-n: Send NSCA message to nagios.

LOG FILES
	GENERAL LOG FILE
		/home/jf/rsync-backup-logs/summary.log
		/home/jf/rsync-backup-logs/execution.log

	LOG FILE PER DATE, SOURCE AND DESTINATION
		Directory: /home/jf/rsync-backup-logs
		Naming convention: log_$DATE_$HOSTNAME_$SOURCE_$DESTINATION.log

EXCLUDES
	To exclude some files or folders place a 'excludes' file in the destination
	folder (.rsync-backup/excludes). For further informations read the
	'--exclude-from' section in the 'rsync' manual.

AFFIRMATION_FILE
	Synchronization only works, if in both folders (source and destination) a
	affirmation file exists (.rsync-backup/please-sync).

CONFIGURATION
	Custom configurations can be done in /etc/rsync-backup.conf.

DEPENDENCIES
	- rsync
	- scp
	- tee
```

## ./smartctl-batch.sh

```
Usage: ./smartctl-batch.sh <options>

OPTIONS:
	-h, --help: Show this help message.

Use this options:

smartctl 6.5 2016-05-07 r4318 [x86_64-linux-4.12.4-1-ARCH] (local build)
Copyright (C) 2002-16, Bruce Allen, Christian Franke, www.smartmontools.org

Usage: smartctl [options] device

============================================ SHOW INFORMATION OPTIONS =====

  -h, --help, --usage
         Display this help and exit

  -V, --version, --copyright, --license
         Print license, copyright, and version information and exit

  -i, --info
         Show identity information for device

  --identify[=[w][nvb]]
         Show words and bits from IDENTIFY DEVICE data                (ATA)

  -g NAME, --get=NAME
        Get device setting: all, aam, apm, lookahead, security, wcache, rcache, wcreorder

  -a, --all
         Show all SMART information for device

  -x, --xall
         Show all information for device

  --scan
         Scan for devices

  --scan-open
         Scan for devices and try to open each device

================================== SMARTCTL RUN-TIME BEHAVIOR OPTIONS =====

  -q TYPE, --quietmode=TYPE                                           (ATA)
         Set smartctl quiet mode to one of: errorsonly, silent, noserial

  -d TYPE, --device=TYPE
         Specify device type to one of: ata, scsi, nvme[,NSID], sat[,auto][,N][+TYPE], usbcypress[,X], usbjmicron[,p][,x][,N], usbprolific, usbsunplus, marvell, areca,N/E, 3ware,N, hpt,L/M/N, megaraid,N, aacraid,H,L,ID, cciss,N, auto, test

  -T TYPE, --tolerance=TYPE                                           (ATA)
         Tolerance: normal, conservative, permissive, verypermissive

  -b TYPE, --badsum=TYPE                                              (ATA)
         Set action on bad checksum to one of: warn, exit, ignore

  -r TYPE, --report=TYPE
         Report transactions (see man page)

  -n MODE, --nocheck=MODE                                             (ATA)
         No check if: never, sleep, standby, idle (see man page)

============================== DEVICE FEATURE ENABLE/DISABLE COMMANDS =====

  -s VALUE, --smart=VALUE
        Enable/disable SMART on device (on/off)

  -o VALUE, --offlineauto=VALUE                                       (ATA)
        Enable/disable automatic offline testing on device (on/off)

  -S VALUE, --saveauto=VALUE                                          (ATA)
        Enable/disable Attribute autosave on device (on/off)

  -s NAME[,VALUE], --set=NAME[,VALUE]
        Enable/disable/change device setting: aam,[N|off], apm,[N|off],
        lookahead,[on|off], security-freeze, standby,[N|off|now],
        wcache,[on|off], rcache,[on|off], wcreorder,[on|off]

======================================= READ AND DISPLAY DATA OPTIONS =====

  -H, --health
        Show device SMART health status

  -c, --capabilities                                            (ATA, NVMe)
        Show device SMART capabilities

  -A, --attributes
        Show device SMART vendor-specific Attributes and values

  -f FORMAT, --format=FORMAT                                          (ATA)
        Set output format for attributes: old, brief, hex[,id|val]

  -l TYPE, --log=TYPE
        Show device log. TYPE: error, selftest, selective, directory[,g|s],
                               xerror[,N][,error], xselftest[,N][,selftest],
                               background, sasphy[,reset], sataphy[,reset],
                               scttemp[sts,hist], scttempint,N[,p],
                               scterc[,N,M], devstat[,N], ssd,
                               gplog,N[,RANGE], smartlog,N[,RANGE],
                               nvmelog,N,SIZE

  -v N,OPTION , --vendorattribute=N,OPTION                            (ATA)
        Set display OPTION for vendor Attribute N (see man page)

  -F TYPE, --firmwarebug=TYPE                                         (ATA)
        Use firmware bug workaround:
        none, nologdir, samsung, samsung2, samsung3, xerrorlba, swapid

  -P TYPE, --presets=TYPE                                             (ATA)
        Drive-specific presets: use, ignore, show, showall

  -B [+]FILE, --drivedb=[+]FILE                                       (ATA)
        Read and replace [add] drive database from FILE
        [default is +/etc/smart_drivedb.h
         and then    /usr/share/smartmontools/drivedb.h]

============================================ DEVICE SELF-TEST OPTIONS =====

  -t TEST, --test=TEST
        Run test. TEST: offline, short, long, conveyance, force, vendor,N,
                        select,M-N, pending,N, afterselect,[on|off]

  -C, --captive
        Do test in captive mode (along with -t)

  -X, --abort
        Abort any non-captive test on device

=================================================== SMARTCTL EXAMPLES =====

  smartctl --all /dev/sda                    (Prints all SMART information)

  smartctl --smart=on --offlineauto=on --saveauto=on /dev/sda
                                              (Enables SMART on first disk)

  smartctl --test=long /dev/sda          (Executes extended disk self-test)

  smartctl --attributes --log=selftest --quietmode=errorsonly /dev/sda
                                      (Prints Self-Test & Attribute errors)
  smartctl --all --device=3ware,2 /dev/sda
  smartctl --all --device=3ware,2 /dev/twe0
  smartctl --all --device=3ware,2 /dev/twa0
  smartctl --all --device=3ware,2 /dev/twl0
          (Prints all SMART info for 3rd ATA disk on 3ware RAID controller)
  smartctl --all --device=hpt,1/1/3 /dev/sda
          (Prints all SMART info for the SATA disk attached to the 3rd PMPort
           of the 1st channel on the 1st HighPoint RAID controller)
  smartctl --all --device=areca,3/1 /dev/sg2
          (Prints all SMART info for 3rd ATA disk of the 1st enclosure
           on Areca RAID controller)

```

## ./ssh-show-ids.sh

```
Usage: ssh-show-ids.sh

Options:
	-h, --help: Show this help message.
```

## ./svg2iconset.sh

```
Usage: svg2iconset.sh <svg-file>

Options:
	-h, --help: Show this help message.
```

## ./systemctl-enable.sh

```
Usage: systemctl-enable.sh <unit-file>

Enable systemd unit files without specifying an absolute path. If <unit-file>
is omitted all unit files in the working directory are enabled.

Options:
	-h, --help: Show this help message.
```

## ./terminal-colors-16.sh

```
Usage: terminal-colors-16.sh

Options:
	-h, --help: Show this help message.
```

## ./terminal-colors-256.sh

```
Usage: terminal-colors-256.sh

Options:
	-h, --help: Show this help message.
```

## ./wordpress-url-update.sh

```
Usage: wordpress-url-update.sh

Options:
	-u MySQL user
	-p MySQL password
	-d MySQL database
	-o Old URL
	-n New URL
	-h Show usage

'wordpress-url-update.sh' is a small shell script to update the url of
wordpress sites.

This script uses the mysql shell command. To use this script you must have
access to the mysql server providing the data for your wordpress site
over the shell command.

# Where is the url stored in the mysql database?

	* In the table 'wp_options' in the column 'option_value'.
	* In the table 'wp_posts' in the columns 'guid' and 'post_content'.

# Command line usage:

	wordpress-url-update.sh -u <user> -p <password> -d <database> -n <new-url>

## Example:

	wordpress-url-update.sh -u root -p 5dtaJ -d wp_db -n http://new-url.com

If you use the shell script frequently on the same site, it is recommended
to edit the script file and put there your mysql connection and url
informations:

	MYSQL_USER=""
	MYSQL_PASSWORD=""
	MYSQL_DATABASE=""
	NEW_URL=""

## Example:

	MYSQL_USER="root"
	MYSQL_PASSWORD="5dtaJ"
	MYSQL_DATABASE="wp_db"
	NEW_URL="http://new-url.com"

Then you can update your wordpress site executing this short command:

	wordpress-url-update.sh
```

## ./zfs-delete-all-snapshots.sh

```
Usage: zfs-delete-all-snapshots.sh <dataset>

Options:
	-h, --help: Show this help message.
```

## ./zfs-diff-walkthrough.sh

```
Usage: zfs-diff-walkthrough [-p] <nr> [<nr>]

Options:
  -d   Dataset or directory.
  -h   Show this help message.
  -p   Compare with previous snapshot instead of later snapshot.
```

## ./zfs-snapshot-recursive.sh

```
Usage: zfs-snapshot-recursive.sh <snapshot-name>

Create snapshots on all datasets of all zfs pools.

Options:
	-h, --help: Show this help message.
```
