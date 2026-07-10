#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="assets/wallpaper"
JSON_FILE="wallpaper.json"
BASE_URL="https://github.com/WollyDev24/YouShade/blob/main/assets/wallpaper"
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$REPO_ROOT/$WALLPAPER_DIR" ]; then
    echo "Error: $WALLPAPER_DIR directory not found. Run this script from the repo root."
    exit 1
fi

if [ ! -f "$REPO_ROOT/$JSON_FILE" ]; then
    echo "Error: $JSON_FILE not found. Run this script from the repo root."
    exit 1
fi

read -rp "Path to wallpaper file: " SOURCE_FILE

if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: File '$SOURCE_FILE' does not exist."
    exit 1
fi

FILENAME="$(basename "$SOURCE_FILE")"
DEST="$REPO_ROOT/$WALLPAPER_DIR/$FILENAME"

if [ -f "$DEST" ]; then
    echo "Error: '$FILENAME' already exists in $WALLPAPER_DIR."
    exit 1
fi

read -rp "Name: " NAME
read -rp "Author: " AUTHOR
read -rp "Collections (pipe-delimited, e.g. GOOGLE|CRYSTALS): " COLLECTIONS

cp "$SOURCE_FILE" "$DEST"
echo "Copied $FILENAME to $WALLPAPER_DIR/"

ENCODED_FILENAME="$(python3 -c "import urllib.parse; print(urllib.parse.quote('$FILENAME'))")"
URL="$BASE_URL/$ENCODED_FILENAME?raw=true"

python3 -c "
import json, sys

entry = {
    'name': sys.argv[1],
    'author': sys.argv[2],
    'url': sys.argv[3],
    'collections': sys.argv[4],
    'downloadable': True,
    'copyright': 'CreativeCommons Attribution-ShareALike'
}

with open('$REPO_ROOT/$JSON_FILE', 'r') as f:
    wallpapers = json.load(f)

wallpapers.append(entry)

with open('$REPO_ROOT/$JSON_FILE', 'w') as f:
    json.dump(wallpapers, f, indent='\t')
    f.write('\n')

print(f'Added \"{entry[\"name\"]}\" to $JSON_FILE')
" "$NAME" "$AUTHOR" "$URL" "$COLLECTIONS"
