#!/bin/bash

git config user.name madebits
git config user.email madebits@no-email.com
git add .
CDATE="Tue, 3 Oct 2017 12:00:00 +0000"
GIT_AUTHOR_DATE="${CDATE}" GIT_COMMITTER_DATE="${CDATE}" git commit --date="${CDATE}" -am "commit"
git push -u origin master
