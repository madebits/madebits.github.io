#! /bin/bash -x

if [[ ! $1 ]]; then exit 1; fi
repo=$1
URL="https://github.com/madebits/${repo}.git"
git clone "$url"
cd "$repo"
rm -rf .git
git init
git config user.name madebits
git config user.email madebits@no-email.com
git add .
CDATE="Sat, 3 Oct 2015 12:00:00 +0000"
GIT_AUTHOR_DATE="${CDATE}" GIT_COMMITTER_DATE="${CDATE}" git commit --date="${CDATE}" -m "commit"
git remote add origin "$url"
git push -u --force origin master
cd ..
