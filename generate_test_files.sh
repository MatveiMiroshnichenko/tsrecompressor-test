#!/usr/bin/env bash
set -euo pipefail

# Directories
ORIGINAL_DIR="output/original"
RECOMPRESSED_DIR="output/recompressed"

mkdir -p "$ORIGINAL_DIR" "$RECOMPRESSED_DIR"

# Test stream parameters
DURATION="${DURATION:-10}"          # seconds; override with: DURATION=30 ./generate_test_files.sh
BASENAME="test_stream"
ORIG_FILE="$ORIGINAL_DIR/${BASENAME}.ts"
RECOMP_FILE="$RECOMPRESSED_DIR/${BASENAME}.ts"

echo "==> Generating test stream with ffmpeg (${DURATION}s)..."
ffmpeg -y \
  -f lavfi -i "smptehdbars=size=1920x1080:rate=30" \
  -f lavfi -i "sine=frequency=1000:sample_rate=48000" \
  -map 0:v -map 1:a \
  -c:v libx264 -preset ultrafast -b:v 8M \
  -c:a aac -b:a 192k \
  -t "$DURATION" \
  -f mpegts \
  "$ORIG_FILE"
echo "    Saved: $ORIG_FILE ($(du -sh "$ORIG_FILE" | cut -f1))"

echo "==> Running tsrecompressor on original stream..."
tsrecompressor \
  --input-file="$ORIG_FILE" \
  --output-file="$RECOMP_FILE"
echo "    Saved: $RECOMP_FILE ($(du -sh "$RECOMP_FILE" | cut -f1))"

echo ""
echo "Done."
echo "  Original:     $ORIG_FILE"
echo "  Recompressed: $RECOMP_FILE"
