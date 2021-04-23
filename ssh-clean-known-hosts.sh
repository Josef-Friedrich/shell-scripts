#! /bin/sh

LINE="$1"

if [ -z "$LINE" ]; then
  echo "Usage: ssh-clean-knows-hosts <line number>"
  exit 1
fi

cp ~/.ssh/known_hosts ~/.ssh/known_hosts.bak

sed ${LINE}d ~/.ssh/known_hosts > ~/.ssh/known_hosts.tmp

rm -f ~/.ssh/known_hosts

mv ~/.ssh/known_hosts.tmp ~/.ssh/known_hosts
