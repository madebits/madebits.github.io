#!/bin/bash

rm -rf "./mb-gallery"
toolsDir=$(dirname $0)

git status

if [ -n "$(git status --porcelain)" ]; then 
	read -p "Press [Enter] key to deploy changes ..."
	${toolsDir}/mserverpush.sh
fi
