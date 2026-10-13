#!/bin/bash
# Rebuilds the watermarked web images in assets/img/art/ from the full-size
# originals in assets/img/DontCommitGallery/ (git-ignored, never published).
#
# Usage: tools/build-art-images.sh
# To add a painting, put the original in DontCommitGallery and add a line to PAINTINGS.
set -euo pipefail

cd "$(dirname "$0")/.."
SRC=assets/img/DontCommitGallery
OUT=assets/img/art
TEXT="© Ishita Goda"

# "<original file> <web name>"
PAINTINGS=(
  "warli.JPG warli"
  "tree.JPG tree-in-bloom"
  "buddha.JPG buddha-lotus"
  "walkinfall.jpg walk-in-fall"
  "wineglass.JPG wine-glass"
)

BIN="${TMPDIR:-/tmp}/ishita-watermark"
if [ ! -x "$BIN" ] || [ tools/watermark.swift -nt "$BIN" ]; then
  echo "Compiling watermark tool (first run takes a minute)..."
  swiftc -O -o "$BIN" tools/watermark.swift
fi

mkdir -p "$OUT"
for entry in "${PAINTINGS[@]}"; do
  read -r file name <<< "$entry"
  for size in 1600 800; do
    "$BIN" "$SRC/$file" "$OUT/$name-$size.jpg" "$size" "$TEXT"
  done
  echo "  $name"
done
echo "Done. Update width/height in index.html if a painting's proportions changed."
