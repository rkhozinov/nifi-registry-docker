#!/bin/sh

while read line
do
  echo $line
done < /dev/stdin
echo username="$NIFI_REGISTRY_GIT_USER"
echo password="$NIFI_REGISTRY_GIT_PASSWORD"
