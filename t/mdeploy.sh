#!/bin/bash

TOOLSDIR=$(dirname $0)

git status

if [ -n "$(git status --porcelain)" ]; then 
	read -p "Press [Enter] key to deploy changes ..."
	${TOOLSDIR}/mserverpush.sh
fi
