#! /bin/sh

FILE="$1"
PAGE_NUMBER="$2"

if [ -z "$FILE" ]; then
	echo "Usage: $(basename $0) <pdf file without ext> <page number>"
	exit 1
fi

if [ -z "$PAGE_NUMBER" ]; then
	PAGE_NUMBER=1
fi

#pdfcrop ${FILE}.pdf
pdftops -f $PAGE_NUMBER -l $PAGE_NUMBER -eps "${FILE}.pdf" 
#rm  -f "${FILE}-crop.pdf"
#mv  "${FILE}-crop.eps" $FILE.eps
