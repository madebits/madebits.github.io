#!/bin/bash

rm -rf .git
git init
git config user.name madebits
git config user.email madebits@no-email.com
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/madebits/madebits.github.io.git
git push -u --force origin master
