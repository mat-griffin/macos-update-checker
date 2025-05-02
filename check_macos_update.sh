#!/bin/bash

set -e

# RSS feed URL
RSS_URL="https://developer.apple.com/news/releases/rss/releases.rss"
LAST_VERSION_FILE="last_macos_version.txt"

# Slack webhook (set as GitHub Actions secret)
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL}"

# Fetch latest non-beta macOS release
latest_macos_item=$(curl -s "$RSS_URL" | xmlstarlet sel -N content="http://purl.org/rss/1.0/modules/content/" -t \
    -m "//item[(contains(description, 'macOS') or contains(title, 'macOS')) and not(contains(title, 'beta')) and not(contains(description, 'beta'))][1]" \
    -v "title" -o "|" -v "link" -n)

if [ -z "$latest_macos_item" ]; then
    echo "No stable macOS item found."
    exit 0
fi

title=$(echo "$latest_macos_item" | cut -d '|' -f 1)
link=$(echo "$latest_macos_item" | cut -d '|' -f 2)

# Compare to last version (if file exists)
last_version=$(cat "$LAST_VERSION_FILE" 2>/dev/null || echo "")

if [ "$title" != "$last_version" ]; then
    echo "$title" > "$LAST_VERSION_FILE"

    payload=$(jq -n --arg text ":apple: *New macOS Release Available!*\n*Version:* $title\n*Link:* $link" \
        '{text: $text}')

    curl -X POST -H 'Content-type: application/json' --data "$payload" "$SLACK_WEBHOOK_URL"
    echo "Posted update to Slack: $title"
else
    echo "No new update. Latest is still: $title"
fi
