#!/bin/bash
set -e
WORK_DIR="/volume1/tmp/build_mario"
OUTPUT_DIR="/volume1/docker/python-games/frontend/games/mario"
REPO_URL="https://github.com/AzipSauhabah/PythonProjects.git"

echo "[1/5] Nettoyage..."
rm -rf "$WORK_DIR" && mkdir -p "$WORK_DIR" && mkdir -p "$OUTPUT_DIR"

echo "[2/5] Clone via Docker..."
docker run --rm -v "$WORK_DIR":/output alpine/git clone --depth=1 "$REPO_URL" /output/repo

MARIO_DIR="$WORK_DIR/repo/Mario-Level-1-master"

echo "[3/5] main.py async..."
cp "$MARIO_DIR/data/main_web.py" "$MARIO_DIR/main.py"

echo "[4/5] Build pygbag (3-5 min)..."
docker run --rm -v "$WORK_DIR":/work python:3.11-slim bash -c \
  "pip install pygbag pygame --quiet && python -m pygbag --width 800 --height 600 --title 'Super Mario Bros - Level 1' --disable-sound-format-error --build /work/repo/Mario-Level-1-master"

BUILD_OUT="$MARIO_DIR/build/web"
[ ! -d "$BUILD_OUT" ] && echo "❌ Build échoué" && exit 1

echo "[5/5] Copie vers Nginx..."
rm -rf "${OUTPUT_DIR:?}"/* && cp -r "$BUILD_OUT"/. "$OUTPUT_DIR/"
rm -rf "$WORK_DIR"
echo "✅ Done !" && ls -lh "$OUTPUT_DIR"
