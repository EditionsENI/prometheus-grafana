#!/bin/sh

for i in `ls -d chapitre*`
do
  tar cfz fichiers-${i}.tar.gz --exclude "target" --exclude ".idea" $i
done
