#!/bin/bash

# URL of the RSS feed
RSS_URL="https://developer.apple.com/news/releases/rss/releases.rss"

# Fetch the RSS feed and parse it, excluding beta versions
latest_macos_item=$(curl -s "$RSS_URL" | xmlstarlet sel -N content="http://purl.org/rss/1.0/modules/content/" -t \
    -m "//item[(contains(description, 'macOS') or contains(title, 'macOS')) and not(contains(title, 'beta')) and not(contains(description, 'beta'))][1]" \
    -v "title" -o " " -v "link" -n)

# Check if an item was found
if [ -z "$latest_macos_item" ]; then
    echo "No stable macOS item found in the RSS feed."
    exit 1
fi

# Extract title and link from the latest macOS item
title=$(echo "$latest_macos_item" | sed 's/ \(http.*\)//')
link=$(echo "$latest_macos_item" | grep -o 'http.*')

# Display the result
echo "Latest macOS Release:"
echo "Version: $title"
echo "Link: $link"