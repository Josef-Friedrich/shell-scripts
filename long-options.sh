#! /bin/sh

# See https://stackoverflow.com/a/28466267

while getopts ab:c-: arg; do
	case $arg in
		a)
			echo a
			;;
		b)
			echo b is $OPTARG
			;;
		c)
			ARG_C=true
			;;
		-)
			LONG_OPTARG="${OPTARG#*=}"
			case $OPTARG in
				alpha)
					echo alpha
					;;
				bravo=?*)
					ARG_B="$LONG_OPTARG" ;;
				bravo*)
					echo "No arg for --$OPTARG option" >&2; exit 2 ;;
				charlie)
					ARG_C=true ;;
				alpha* | charlie*)
					echo "No arg allowed for --$OPTARG option" >&2; exit 2 ;;
				'')
					break ;; # "--" terminates argument processing
				*)
					echo "Illegal option --$OPTARG" >&2; exit 2 ;;
				 esac ;;
		\?)
			exit 2
			;;  # getopts already reported the illegal option
	esac
done
shift $((OPTIND-1)) # remove parsed options and args from $@ list
