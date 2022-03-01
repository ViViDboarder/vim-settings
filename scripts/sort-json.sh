#! /usr/bin/env bash
set -e

for f in "$@"; do
    jq --sort-keys --monochrome-output . "$f" > "$f.tmp"
    mv "$f.tmp" "$f"
done
