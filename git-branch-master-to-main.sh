#! /bin/sh

# Copyright (c) 2022 Josef Friedrich <josef@friedrich.rocks>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

_usage() {
	echo "Usage: $(basename "$0")

Rename the git branch master to main in a local repository.

Options:
	-h, --help: Show this help message."
}

### This SEPARATOR is needed for the tests. Do not remove it! ##########

if [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
	_usage
	exit 0
fi

# Rename the local branch to the new name
git branch --move master main

# https://stackoverflow.com/a/9753364
UPSTREAM_BRANCH="$(git rev-parse --abbrev-ref --symbolic-full-name @{u})"

# https://stackoverflow.com/a/30590238
if [ UPSTREAM_BRANCH != "origin/main" ]; then
  # Delete the old branch on remote - where <remote> is, for example, origin
  git push origin --delete master

  # Prevent git from using the old name when pushing in the next step.
  # Otherwise, git will use the old upstream name instead of <new_name>.
  git branch --unset-upstream main

  # Push the new branch to remote
  git push origin main

  # Reset the upstream branch for the new_name local branch
  git push origin -u main
fi

git fetch origin
git branch --set-upstream-to origin/main main
git remote set-head origin --auto
