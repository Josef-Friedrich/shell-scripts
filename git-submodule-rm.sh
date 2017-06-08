#! /bin/sh

git submodule deinit "$1"    
git rm "$1"
rm -rf .git/modules/"$1"
