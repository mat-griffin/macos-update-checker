#!/bin/bash

# RSS feed URL
RSS_URL="https://developer.apple.com/news/releases/rss/releases.rss"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL}"  # Set as a GitHub secret or env var

# File to track the last notified version
LAST_VERSION_FILE="last_macos_version.txt"

# Fetch the latest stable macOS release
latest_macos_item=$(curl -s "$RSS_URL" | xmlstarlet sel -N content="http://purl.org/rss/1.0/modules/content/" -t \
    -m "//item[(contains(description, 'macOS') or contains(title, 'macOS')) and not(contains(title, 'beta')) and not(contains(description, 'beta'))][1]" \
    -v "title" -o " " -v "link" -n)

# Exit if no release found
if [ -z "$latest_macos_item" ]; then
    echo "No stable macOS item found in the RSS feed."
    exit 1
fi

# Extract title and link
title=$(echo "$latest_macos_item" | sed 's/ \(http.*\)//')
link=$(echo "$latest_macos_item" | grep -o 'http.*')

# Show the version info
echo "Latest macOS Release:"
echo "Version: $title"
echo "Link: $link"

# Read the last notified version (if any)
if [ -f "$LAST_VERSION_FILE" ]; then
    last_version=$(cat "$LAST_VERSION_FILE")
else
    last_version=""
fi

# If it's new, notify via Slack
if [ "$title" != "$last_version" ]; then
    echo "$title" > "$LAST_VERSION_FILE"

   payload=$(jq -n --arg title "$title" --arg link "$link" --arg user "<@U038UTST9R8>" \
    '{text: ":applein: *New macOS Release Available!*\n\($user) check it out!\n*Version:* \($title)\n*Link:* \($link)"}')

    curl -X POST -H 'Content-type: application/json' --data "$payload" "$SLACK_WEBHOOK_URL"

    echo "Posted to Slack: $title"
else
    echo "No new version found. Already notified about: $title"
fi
