#! /bin/bash

_latexmk () {
	# -cd  Change to directory of source file when processing it
	# -gg  Super go mode: clean out generated files (-CA), and then process files regardless of file timestamps
	latexmk -cd -gg -lualatex -silent "$1" > /dev/null 2>&1
	if [ "$?" -eq 0 ]; then
		echo -e "\033[32mOK:\e[0m $TEX_FILE"
	else
		echo -e "\033[31mERROR:\e[0m $TEX_FILE"
	fi
	#  -c clean up (remove) all nonessential files, except dvi, ps and pdf files. This and the other clean-ups are instead of a regular make.
	latexmk -cd -c -silent "$1" > /dev/null 2>&1
}

for TEX_FILE in $(find . -iname "*.tex" | sort); do
	_latexmk "$TEX_FILE"
done
