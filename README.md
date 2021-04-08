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

## ./backup-file.sh

```
Usage: backup-file.sh <file-path>

	Copy the file and append .bak to the file name.


OPTIONS:
	-h, --help:       Show this message.

```

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

## ./clean-etc-apt-sources-list-d.sh

```
Usage: clean-etc-apt-sources-list-d.sh

Clean up the folder /etc/apt/sources.list.d. Delete the backup
files like '*.save' oder '*.distUpgrade'. Remove all comments from
the configuration files. Then delete all empty files.


OPTIONS:
	-h, --help:       Show this message.

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

A convenient script wrapper around send_nsca.

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
	-p PATH_CHECK:     Folder containing the check commands.
	                   (default: /usr/lib/nagios/plugins)
	-o OUTPUT:         Output of the check commands.
	-r RETURN:         Plugin return codes: 0 Ok, 1 Warning,
	                   2 Critical, 3 Unkown.

Examples:

easy-nsca.sh "APT" "check_apt -t 100"
easy-nsca.sh "Disk space" "check_disk -w 10% -c 5% /dev/sda1"
```

## ./eps-converted-to-pdf-for-tex.sh

```
Usage: eps-converted-to-pdf-for-tex.sh

Convert a EPS file to a PDF file. Append to the created PDF file
-eps-converted-to.pdf. This suffix is needed by LaTeX to include
the graphics into a document. Sometimes the automatic conversion fails.

Options:
	-h, --help: Show this help message.
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
Usage: imagemagick-imslp.sh [-bcfhijrSstv] <filename-or-glob-pattern>

A wrapper script for imagemagick to process image files suitable for imslp.org (International Music Score Library Project)

http://imslp.org/wiki/IMSLP:Musiknoten_beisteuern

OPTIONS:
	-b, --backup
	  Backup original images (add .bak to filename).
	-c, --compression
	  Use CCITT Group 4 compression. This options generates a PDF
	  file.
	-e, --enlighten-border
	  Enlighten the border.
	-f, --force
	  force
	-h, --help
	  Show this help message
	-i, --imslp
	  Use the best options to publish on IMSLP. (--compress,
	   --join, --resize)
	-j, --join
	  Join single paged PDF files to one PDF file
	-r, --resize
	  Resize 200%
	-S, --threshold-series
	  Convert the samge image with different threshold values to
	  find the best threshold value. Those values are probed:
	  50 55 60 65 70 75.
	-s, --short-description
	  Show a short description / summary.
	-t, --threshold
	  threshold, default 50%.
	-v, --version
	  Show the version number of this script.

DEPENDENCIES:

	- pdftk
	- imagemagick (convert, identify)
	- poppler (pdfimages)

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

## ./mp4box-mp4-split.sh

```
NAME
      mp4box-mp4-split.sh - Split mp4 files without re-encoding.

SYNOPSIS
       mp4box-mp4-split.sh mp4-file start-time end-time

DESCRIPTION
       The  mp4-split-command  split  mp4  files  without  re-encoding.  It  uses  the mp4box-command of the GPAC framework. Both start and end time must be specified in this format:
       hh-mm-ss, e. g. 01-34-23.

EXAMPLES
       mp4box-mp4-split.sh video.mp4 00-23-43 01-01-32

```

## ./mscore-reopen.sh

```
No files to convert found!
```

## ./mscore-to-vector.sh

```
Usage: mscore-to-vector.sh [-ehnsSv] [<path>]

Convert MuseScore files (*.mscz, *.mscx) to the EPS or SVG file format.

Convert MuseScore files to eps or svg using 'pdfcrop' and 'pdftops' and
'pdf2svg'. If <path> is omitted, all MuseScore files in the
current working directory are converted. <path> can be either a
directory or a MuseScore file.

DEPENDENCIES
	'pdfcrop' (included in TeXlive) and 'pdftops' (Poppler tools) and
    'pdf2svg'

OPTIONS
	-e, --eps
	  Create only EPS files.
	-h, --help
	  Show this help message.
	-n, --no-clean
	  Do not remove / clean intermediate *.pdf files.
	-N, --no-crop
	  Do not crop.
	-p, --pdf-for-latex
	  Create additionally to the eps a corresponding PDF file with the
	  suffix -eps-converted-to.pdf.
	-s, --svg
	  Create only SVG files.
	-S, --short-description
	  Show a short description / summary.
	-v, --version
	  Show the version number of this script.

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

## ./nsupdate-wrapper.sh

```
nsupdate-wrapper.sh v1.0

Usage: nsupdate-wrapper.sh [-46dhklnrstvz]

Wrapper around nsupdate. Update your DNS server using nsupdate. Supports both ipv4 and ipv6.

Options:
	-4, --ipv4-only
	  Update the ipv4 / A record only.
	-6, --ipv6-only
	  Update the ipv6 / AAAA record only.
	-d, --device
	  The interface (device to look for an IP address), e. g. “eth0”
	-h, --help
	  Show this help message.
	-k, --key-file
	  Path to private key.
	-l, --literal-key [hmac:]keyname:secret
	  Literal TSIG authentication key. keyname is the name of the
	  key, and secret is the base64 encoded shared secret. hmac is
	  the name of the key algorithm; valid choices are hmac-md5,
	  hmac-sha1, hmac-sha224, hmac-sha256, hmac-sha384, or
	  hmac-sha512. If hmac is not specified, the default is
	  hmac-md5. For example: hmac-sha256:example.com:n+WgaHX...0ni+HOQew8=
	-n, --nameserver
	  DNS server to send updates to, e. g. “ns.example.com”
	-r, --record
	  Record to update, e. g. “subdomain.example.com.”
	-s, --short-description
	  Show a short description / summary.
	-t, --ttl
	  Time to live for updated record; default 3600s., e. g. “300”
	-v, --version
	  Show the version number of this script.
	-z, --zone
	  Zone to update, e. g. “example.com.”

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

A wrapper script for rsync with source und destination accessibility checks, advanced logging and backup support.

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

## ./skeleton.sh

```
skeleton.sh v1.0

Usage: skeleton.sh [-AdhrSstv]

This is the management script of the skeleton.sh project!

Options:
	-A, --sync-all
	  Sync all projects that have the same parent folder as this
	  project.
	-d, --sync-dependencies
	  Sync external dependenices (e. g. test-helper.sh bats).
	-h, --help
	  Show this help message.
	-r, --render-readme
	  Render “README.md”.
	-S, --sync-skeleton
	  Sync your project with the skeleton project and update some
	  boilerplate files (e. g. Makefile test/lib/skeleton.sh).
	-s, --short-description
	  Show a short description / summary.
	-t, --test
	  Run the tests located in the “test” folder.
	-v, --version
	  Show the version number of this script.

```

## ./smartctl-batch.sh

```
Usage: ./smartctl-batch.sh <options>

OPTIONS:
	-h, --help: Show this help message.

Use this options:

smartctl 7.1 2019-12-30 r5022 [x86_64-linux-5.8.0-48-generic] (local build)
Copyright (C) 2002-19, Bruce Allen, Christian Franke, www.smartmontools.org

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
        Get device setting: all, aam, apm, dsn, lookahead, security,
        wcache, rcache, wcreorder, wcache-sct

  -a, --all
         Show all SMART information for device

  -x, --xall
         Show all information for device

  --scan
         Scan for devices

  --scan-open
         Scan for devices and try to open each device

================================== SMARTCTL RUN-TIME BEHAVIOR OPTIONS =====

  -j, --json[=[cgiosuv]]
         Print output in JSON format

  -q TYPE, --quietmode=TYPE                                           (ATA)
         Set smartctl quiet mode to one of: errorsonly, silent, noserial

  -d TYPE, --device=TYPE
         Specify device type to one of:
         ata, scsi[+TYPE], nvme[,NSID], sat[,auto][,N][+TYPE], usbcypress[,X], usbjmicron[,p][,x][,N], usbprolific, usbsunplus, sntjmicron[,NSID], intelliprop,N[+TYPE], jmb39x,N[,sLBA][,force][+TYPE], marvell, areca,N/E, 3ware,N, hpt,L/M/N, megaraid,N, aacraid,H,L,ID, cciss,N, auto, test

  -T TYPE, --tolerance=TYPE                                           (ATA)
         Tolerance: normal, conservative, permissive, verypermissive

  -b TYPE, --badsum=TYPE                                              (ATA)
         Set action on bad checksum to one of: warn, exit, ignore

  -r TYPE, --report=TYPE
         Report transactions (see man page)

  -n MODE[,STATUS], --nocheck=MODE[,STATUS]                           (ATA)
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
        dsn,[on|off], lookahead,[on|off], security-freeze,
        standby,[N|off|now], wcache,[on|off], rcache,[on|off],
        wcreorder,[on|off[,p]], wcache-sct,[ata|on|off[,p]]

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
        xerror[,N][,error], xselftest[,N][,selftest], background,
        sasphy[,reset], sataphy[,reset], scttemp[sts,hist],
        scttempint,N[,p], scterc[,N,M], devstat[,N], defects[,N], ssd,
        gplog,N[,RANGE], smartlog,N[,RANGE], nvmelog,N,SIZE

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
         and then    /var/lib/smartmontools/drivedb/drivedb.h]

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

## ./subtitles-add-eng.sh

```
Usage: subtitles-add-eng.sh <extension>

Merge english subtitle files srt into video files specified by an extension.

e. g.: subtitles-add-eng.sh mkv

```

## ./subtitles-batch.sh

```
```

## ./svg2eps.sh

```
Usage: svg2eps.sh <svg-file>

Convert a SVG file to the EPS format using inkscape.

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

## ./test-helper.sh

```
```

## ./video-compress.sh

```
Usage: video-compress.sh <file-path>

Compress a video using FFMPEG.

OPTIONS:
	-h, --help:       Show this message.

```

## ./wayland-or-xorg.sh

```
x11
```

## ./wireguard-easy-keygen.sh

```
Usage: wireguard-easy-keygen.sh <key-name>

This little utility creates a private and a public wireguard key in
the current working directory at once.

wg genkey | tee key-name.privatekey | wg pubkey > key-name.publickey

Options:
	-h, --help: Show this help message.
```

## ./wordpress-url-update.sh

```
Usage: wordpress-url-update.sh

A small shell script to update the url of wordpress sites.

Options:
	-u MySQL user
	-p MySQL password
	-d MySQL database
	-o Old URL
	-n New URL
	-h Show usage



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

## ./xorg-or-wayland.sh

```
x11
```

## ./zfs-delete-all-snapshots.sh

```
Usage: zfs-delete-all-snapshots.sh <dataset>

Options:
	-h, --help: Show this help message.
```

## ./zfs-delete-empty-snapshots.sh

```
Usage: zfs-delete-empty-snapshots.sh <dataset>

Delete empty ZFS snapshots in a secure manner.

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
