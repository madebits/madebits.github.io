#!/bin/bash

git status

if [ -n "$(git status --porcelain)" ]; then 
	read -p "Press [Enter] key to deploy changes ..."
	./mserverpush.sh
fi
