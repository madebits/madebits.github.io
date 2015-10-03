#!/bin/bash

git config user.name madebits
git config user.email madebits@no-email.com
git add .
GIT_AUTHOR_DATE="Sat, 3 Oct 2015 12:00:00 +0000" GIT_COMMITTER_DATE="Sat, 3 Oct 2015 12:00:00 +0000" git commit --date="Sat, 3 Oct 2015 12:00:00 +0000" -am "update"
git push -u origin master