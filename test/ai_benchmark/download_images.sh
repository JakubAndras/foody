#!/bin/bash
# Download Nutrition5k overhead images for selected benchmark dishes.
#
# Usage:
#   bash test/ai_benchmark/download_images.sh
#
# Downloads ~50 overhead RGB images (640x480, ~400KB each, ~20 MB total).
# No authentication required — the bucket is public.

set -e

IMAGES_DIR="test/ai_benchmark/nutrition5k/images"
IDS_FILE="test/ai_benchmark/nutrition5k/selected_dish_ids.txt"
BASE_URL="https://storage.googleapis.com/nutrition5k_dataset/nutrition5k_dataset/imagery/realsense_overhead"

if [ ! -f "$IDS_FILE" ]; then
  echo "ERROR: $IDS_FILE not found."
  echo "Run first: dart run test/ai_benchmark/nutrition5k_parser.dart"
  exit 1
fi

total=$(wc -l < "$IDS_FILE" | tr -d ' ')
count=0
success=0
failed=0

echo "Downloading $total dish images (overhead RGB, 640x480)..."
echo ""

while IFS= read -r dish_id; do
  dish_id=$(echo "$dish_id" | tr -d '\r\n ')
  [ -z "$dish_id" ] && continue

  count=$((count + 1))
  target_dir="$IMAGES_DIR/$dish_id"
  target_file="$target_dir/rgb.png"

  # Skip if already downloaded
  if [ -f "$target_file" ]; then
    echo "[$count/$total] $dish_id — already exists, skipping"
    success=$((success + 1))
    continue
  fi

  mkdir -p "$target_dir"
  url="$BASE_URL/$dish_id/rgb.png"

  printf "[$count/$total] $dish_id — downloading... "

  if curl -s -f -o "$target_file" "$url" 2>/dev/null; then
    size=$(wc -c < "$target_file" | tr -d ' ')
    echo "OK (${size} bytes)"
    success=$((success + 1))
  else
    echo "FAILED"
    rm -f "$target_file"
    rmdir "$target_dir" 2>/dev/null || true
    failed=$((failed + 1))
  fi

done < "$IDS_FILE"

echo ""
echo "=== Download Complete ==="
echo "  Success: $success"
echo "  Failed:  $failed"
echo "  Total:   $count"
echo ""

if [ $failed -gt 0 ]; then
  echo "WARNING: $failed dishes failed. Re-run the parser to select replacements:"
  echo "  dart run test/ai_benchmark/nutrition5k_parser.dart"
fi

if [ $success -gt 0 ]; then
  echo "Next steps:"
  echo "  dart run test/ai_benchmark/ai_benchmark_runner.dart --dry-run    # verify setup"
  echo "  dart run test/ai_benchmark/ai_benchmark_runner.dart --runs 1     # quick test"
  echo "  dart run test/ai_benchmark/ai_benchmark_runner.dart              # full benchmark"
fi
