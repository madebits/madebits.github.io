#!/bin/bash

if [[ ! $1 ]]; then exit 1; fi
CDATE="Sat, 3 Oct 2015 12:00:00 +0000"
GIT_AUTHOR_DATE="${CDATE}" GIT_COMMITTER_DATE="${CDATE}" git tag -a "$1" -m "$1"
git push origin --tags
