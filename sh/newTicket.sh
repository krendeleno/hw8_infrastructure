#! /bin/bash

currentTag=$(git tag | tail -1)
prevTag=$(git tag | tail -2 | head -1)
author=$(git show $currentTag  --pretty=format:"Author: %an" --date=format:'%Y-%m-%d %H:%M:%S' --no-patch)
date=$(git show $currentTag  --pretty=format:"Date: %ad" --date=format:'%Y-%m-%d %H:%M:%S'  --no-patch)
if [ $currentTag = $prevTag ]; then
    gitlog=$(git log $prevTag..$currentTag --pretty=format:"\n* %h %an %ad %s" --date=format:'%Y/%m/%d-%H:%M:%S')
else
    gitlog=$(git log $prevTag..$currentTag --pretty=format:"\n* %h %an %ad %s" --date=format:'%Y/%m/%d-%H:%M:%S')
fi

unique="https://github.com/krendeleno/hw8_infrastructure/$currentTag"
description=$(echo "**$currentTag\n$author\n$date**\nCommit history:$gitlog" | tr -s "\n" " ")
summary="New release $currentTag from github.com/krendeleno/hw8_infrastructure"


response=$(
  curl -s -o dev/null -w '%{http_code}' -X POST https://api.tracker.yandex.net/v2/issues \
  -H "Content-Type: application/json" \
  -H "Authorization: OAuth ${OAuth}" \
  -H "X-Org-Id: ${XOrgId}" \
  -d '{
    "summary":"'"$summary"'",
    "queue":"TMP",
    "type":"task",
    "description":"'"$description"'",
    "unique":"'"$unique"'"
}'
)

echo $response

if [ $response = 201 ]; then
  echo "Release created successfully"
elif [ $response = 404 ]; then
  echo "Not found"
elif [ $response = 409 ]; then
  echo "Can't create release with the same unique"

  taskID=$(
    curl -s -X POST https://api.tracker.yandex.net/v2/issues/_search? \
    -H "Content-Type: application/json" \
    -H "Authorization: OAuth $OAuth" \
    -H "X-Org-Id: $XOrgId" \
    -d '{
    "filter": {
         "unique":"'"$unique"'"
      }
    }' | jq -r '.[].id'
  )

    updateResponse=$(
    curl -s -o dev/null -w '%{http_code}' -X PATCH https://api.tracker.yandex.net/v2/issues/$taskID \
    -H "Content-Type: application/json" \
    -H "Authorization: OAuth $OAuth" \
    -H "X-Org-Id: $XOrgId" \
    -d '{
        "summary":"'"$summary"'",
        "description":"'"$description"'"
    }')

    if [ $updateResponse = 200 ]; then
      echo "Release updated successfully"
    elif [ $updateResponse = 404 ]; then
      echo "Not found"
    else [ $updateResponse = 409 ]
      echo "Something went wrong with statusCode: $updateResponse"
    fi
fi
