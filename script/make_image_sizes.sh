#!/usr/bin/env bash
#
# Mellowlight Journal — Bildgrößen erzeugen
#
# Legt zu jedem Foto in assets/images/posts/ kleinere Fassungen an:
#
#   standesamt-hassfurt/
#   ├─ erster-blick.webp            ← euer Original, bleibt unangetastet
#   ├─ webp-400/erster-blick.webp
#   ├─ webp-700/erster-blick.webp
#   └─ webp-1000/erster-blick.webp
#
# Der Rest passiert von allein: Jekyll findet die Ordner beim Bauen und baut
# daraus das srcset. Der Browser lädt dann die Fassung, die zur tatsächlichen
# Anzeigegröße passt — auf dem Handy die kleine, am großen Bildschirm die große.
#
# Läuft automatisch bei jedem Push (siehe .github/workflows/build.yml).
# Lokal ausführen:  bash script/make_image_sizes.sh
#
# Nichts wird hochskaliert: ist ein Original kleiner als eine Zielbreite, wird
# diese Fassung übersprungen. Ein größeres Bild ohne mehr Details wäre nur eine
# größere Datei.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/assets/images/posts"

# Muss zu DERIVATIVES in _plugins/ml_image_meta.rb passen.
SIZES=(400 700 1000 1400)

# 82 ist der Punkt, an dem WebP bei Hochzeitsfotos noch sauber aussieht und die
# Datei spürbar kleiner wird. Darunter werden Hauttöne fleckig.
QUALITY=82

if ! command -v vipsthumbnail >/dev/null 2>&1; then
  echo "vipsthumbnail fehlt."
  echo "  Ubuntu/Debian:  sudo apt-get install -y libvips-tools"
  echo "  macOS:          brew install vips"
  echo "  Windows:        https://github.com/libvips/libvips/releases (vips-dev-w64)"
  exit 1
fi

[ -d "$SRC" ] || { echo "Kein Bilderordner unter $SRC"; exit 0; }

created=0
skipped=0
toosmall=0

# Nur Originale: alles, was schon in einem webp-NNN/ liegt, wird übersprungen.
while IFS= read -r -d '' file; do
  case "$file" in */webp-*) continue ;; esac

  dir="$(dirname "$file")"
  name="$(basename "$file")"

  width="$(vipsheader -f width "$file" 2>/dev/null || echo 0)"
  [ "$width" -gt 0 ] || { echo "  übersprungen (nicht lesbar): $name"; continue; }

  for size in "${SIZES[@]}"; do
    # Keine Fassung erzeugen, die größer wäre als das Original.
    if [ "$size" -gt "$width" ]; then
      toosmall=$((toosmall + 1))
      continue
    fi

    out="$dir/webp-$size/$name"

    # Schon vorhanden und neuer als das Original? Dann nichts tun.
    if [ -f "$out" ] && [ "$out" -nt "$file" ]; then
      skipped=$((skipped + 1))
      continue
    fi

    mkdir -p "$dir/webp-$size"
    vipsthumbnail "$file" --size "${size}x>" -o "$out[Q=$QUALITY,strip]"
    created=$((created + 1))
  done
done < <(find "$SRC" -type f \( -iname '*.webp' -o -iname '*.jpg' -o -iname '*.jpeg' \) -print0)

echo "Bildgrößen: $created erzeugt, $skipped aktuell, $toosmall zu groß für die Vorlage."
