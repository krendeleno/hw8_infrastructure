#! /bin/bash

currentTag=$(git tag | tail -1)
prevTag=$(git tag | tail -2 | head -1)
author=$(git show $currentTag| grep Author: )
date=$(git show $currentTag | grep Date:)
if [ $currentTag = $prevTag ]; then
  gitlog=$(git log $currentTag)
else
  gitlog=$(git log $prevTag..$currentTag)
fi

unique="https://github.com/krendeleno/hw8_infrastructure/$currentTag"
description="$currentTag\n$author\n$date\n$gitlog"

response=$(curl -s --request POST  "https://api.tracker.yandex.net/v2/issues/" -H "Content-Type: application/json" -H "Authorization: OAuth $OAuth" -H "X-Org-Id: $XOrgId" \
    -d '{
    "summary": "New release "'"$currentTag"'",
    "queue": "TMP",
    "description": "'"$description"'",
    "type": "release",
    "unique": "'"$unique"'"
    }')

echo $response

#if [ $response = 201 ]; then
#  echo "Release created successfully"
#  elif [ $response = 404 ]; then
#  echo "Not found"
#  elif [ $response = 409 ]; then
#  ehcho "Can't create release with the same unique"
#fi