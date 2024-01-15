#! /bin/sh

# https://gist.github.com/knu/111055
# Rename tags named foo-bar-#.#.# to v#.#.# and push the tag changes

git fetch origin

git tag -l | while read TAG; do
  if [ "$(echo $TAG | cut -c 1)" != "v" ]; then
    NEW="v$TAG"
    git tag $NEW $TAG
    git tag -d $TAG
  fi
done

git push --tags --prune origin "refs/tags/*"
