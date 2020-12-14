#!/bin/bash

rm -rf dirtest

if [ -e "directory" ]; then
  rm -rf 
fi

mkdir dirtest
cd dirtest

DATE=$(date +%y-%m-%d)
touch file-${DATE}.txt

cd ~/scripts
pwd
ls -l