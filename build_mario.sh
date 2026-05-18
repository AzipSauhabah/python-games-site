#!/bin/bash
# ============================================================
# build_mario.sh
# A lancer UNE FOIS sur le NAS pour compiler Mario → WebAssembly
# Puis relancer après chaque mise à jour du repo GitHub.
#
# Usage :
#   chmod +x build_mario.sh
#   sudo bash build_mario.sh
# ============================================================
set -e

REPO_URL="https://github.com/AzipSauhabah/PythonProjects.git"
WORK_DIR="/tmp/build_mario_$$"
OUTPUT_DIR="/volume1/docker/python-games/frontend/games/mario"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  AzipSauhabah — Build Mario WASM         ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Nettoyage ──────────────────────────────────
echo "[1/5] Nettoyage dossier temporaire..."
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
mkdir -p "$OUTPUT_DIR"

# ── Clone ──────────────────────────────────────
echo "[2/5] Clone de github.com/AzipSauhabah/PythonProjects..."
git clone --depth=1 "$REPO_URL" "$WORK_DIR/repo"
MARIO_DIR="$WORK_DIR/repo/Mario-Level-1-master"

echo "      Structure détectée :"
ls "$MARIO_DIR" | sed 's/^/      /'

# ── Préparer main.py pour pygbag ───────────────
echo "[3/5] Préparation main.py (depuis data/main_web.py)..."
# main_web.py est déjà async — pygbag attend main.py à la racine
cp "$MARIO_DIR/data/main_web.py" "$MARIO_DIR/main.py"
echo "      main.py prêt."

# ── Installer pygbag ───────────────────────────
echo "[4/5] Installation pygbag..."
pip3 install pygbag pygame --quiet --break-system-packages 2>/dev/null \
  || pip3 install pygbag pygame --quiet

# ── Build WASM ─────────────────────────────────
echo "[5/5] Compilation WebAssembly (2-4 min selon connexion)..."
echo "      Le premier build télécharge CPython WASM (~30 MB, mis en cache ensuite)"
echo ""

python3 -m pygbag \
    --width 800 \
    --height 600 \
    --title "Super Mario Bros — Level 1" \
    --build \
    "$MARIO_DIR"

BUILD_OUT="$MARIO_DIR/build/web"

if [ ! -d "$BUILD_OUT" ]; then
    echo "❌ Build échoué. Vérifier les erreurs ci-dessus."
    exit 1
fi

# ── Copie vers dossier servi par Nginx ─────────
echo ""
echo "Copie vers $OUTPUT_DIR ..."
# On vide l'ancien build et on copie le nouveau
rm -rf "${OUTPUT_DIR:?}"/*
cp -r "$BUILD_OUT"/. "$OUTPUT_DIR/"

# Nettoyer le tmp
rm -rf "$WORK_DIR"

echo ""
echo "✅ Build terminé !"
echo "   Fichiers dans : $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"
echo ""
echo "   Le jeu sera accessible via : https://games.sauhabah-advisory.eu/games/mario/"
