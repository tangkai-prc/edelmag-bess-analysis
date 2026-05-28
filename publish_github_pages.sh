#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

SOURCE_FILE="Combined_Interactive_Preview.html"
TARGET_FILE="index.html"
BRANCH="$(git branch --show-current)"
COMMIT_MESSAGE="${1:-Publish GitHub Pages site}"
ASSET_DIRS=(
  "porvenir_2024_analysis_charts"
  "porvenir_2025_analysis_charts"
  "porvenir_202604_analysis_charts"
)

if [ ! -d ".git" ]; then
  echo "ERROR: This script must run inside the github-pages-export Git repository."
  echo "Current directory: $SCRIPT_DIR"
  exit 1
fi

if [ -z "$BRANCH" ]; then
  echo "ERROR: Cannot detect current Git branch."
  exit 1
fi

if [ ! -f "$SOURCE_FILE" ]; then
  echo "ERROR: Missing source file: $SCRIPT_DIR/$SOURCE_FILE"
  echo "Run python3 -u ../datas2024_2025.py first to generate it."
  exit 1
fi

echo "Publishing GitHub Pages from: $SCRIPT_DIR"
echo "Branch: $BRANCH"
echo "Source: $SOURCE_FILE"
echo "Target: $TARGET_FILE"

cp "$SOURCE_FILE" "$TARGET_FILE"

git add "$TARGET_FILE"
for asset_dir in "${ASSET_DIRS[@]}"; do
  if [ ! -d "$asset_dir" ]; then
    echo "ERROR: Missing published asset directory: $SCRIPT_DIR/$asset_dir"
    echo "Run python3 -u ../datas2024_2025.py first to generate it."
    exit 1
  fi
  git add "$asset_dir"
done

if git diff --cached --quiet -- "$TARGET_FILE" "${ASSET_DIRS[@]}"; then
  echo "No site changes to publish."
  exit 0
fi

git commit -m "$COMMIT_MESSAGE"
git push origin "$BRANCH"

echo "Published $TARGET_FILE and yearly page assets to origin/$BRANCH."
