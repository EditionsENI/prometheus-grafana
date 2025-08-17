#!/bin/sh

rm -f fichiers-chapitre-*.tar.gz
for i in `ls -d chapitre*`
do
  tar cfz fichiers-${i}.tar.gz --exclude "target" --exclude ".venv" --exclude "vendor" --exclude "*.jar" --exclude "__pycache__" --exclude "data" --exclude ".idea" $i
done
