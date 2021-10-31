#! /bin/bash

currentTag=$(git tag | tail -1)
unique="https://github.com/krendeleno/hw8_infrastructure/$currentTag"

docker build -t release:"$currentTag" .

if [ $? = 0 ]; then
  echo "Docker-image created successfully"

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

commentText="Docker-образ создан: release:$currentTag"

    comment=$(
    curl  -s -o dev/null -w '%{http_code}' -X POST https://api.tracker.yandex.net/v2/issues/$taskID/comments \
    -H "Content-Type: application/json" \
    -H "Authorization: OAuth $OAuth" \
    -H "X-Org-Id: $XOrgId" \
    -d '{
        "text":"'"$commentText"'"
    }')

    if [ $comment = 201 ]; then
      echo "Comment about docker-image created successfully"
    elif [ $comment = 404 ]; then
      echo "Not found"
    else
      echo "Something went wrong with statusCode: $comment"
    fi

else
  echo "Docker-image wasn't created"
fi
