#! /bin/bash
currentTag=$(git tag | tail -1)
unique="https://github.com/krendeleno/hw8_infrastructure/$currentTag"


testResult=$(npm run test 2>&1 | tr "\\\\\\\\" "/"| tr -s "\n" " ")

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


    comment=$(
    curl  -s -o dev/null -w '%{http_code}' -X POST https://api.tracker.yandex.net/v2/issues/$taskID/comments \
    -H "Content-Type: application/json" \
    -H "Authorization: OAuth $OAuth" \
    -H "X-Org-Id: $XOrgId" \
    -d '{
        "text":"'"$testResult"'"
    }')

    if [ $comment = 201 ]; then
      echo "Tests result added successfully"
    elif [ $comment = 404 ]; then
      echo "Not found"
    else
      echo "Something went wrong with statusCode: $comment"
    fi

