#! /bin/sh

if [ -z "$1" ]; then
  echo "Usage: open-by-extension <extension>

example: open-by-extension .txt (Opens all *.txt files)"

  exit 1
fi

find . -type f \( -iname "*$1" \) -exec xdg-open "{}" \;
