#!/usr/bin/env bash
# Regenerates assets/videos/animation.webp from a source video authored as
# colored lines on a black canvas.
#
# Flutter's video_player renders through a real <video> element on web (a
# platform view outside Flutter's paint pipeline), so a Dart-side
# ColorFilter can never make it transparent there. Instead we bake the same
# "black canvas -> transparent" luminance key into the pixels themselves,
# offline, and ship an animated WebP with a real alpha channel, decoded by
# Flutter's own Image widget on every platform.
#
# Usage: scripts/render_loading_animation.sh <source-video> [width] [height]
set -euo pipefail

SRC="${1:?usage: render_loading_animation.sh <source-video> [width] [height]}"
WIDTH="${2:-592}"
HEIGHT="${3:-1281}"
OUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/assets/videos"
FRAMES_DIR="$(mktemp -d)"
trap 'rm -rf "$FRAMES_DIR"' EXIT

FPS="$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0 "$SRC")"
FRAME_DURATION_MS="$(python3 -c "n,d=map(int,'$FPS'.split('/')); print(round(1000*d/n))")"

ffmpeg -y -i "$SRC" \
  -vf "scale=${WIDTH}:${HEIGHT},format=rgba,geq=r='r(X,Y)':g='g(X,Y)':b='b(X,Y)':a='0.2126*r(X,Y)+0.7152*g(X,Y)+0.0722*b(X,Y)'" \
  "$FRAMES_DIR/frame_%03d.png"

img2webp -loop 0 -d "$FRAME_DURATION_MS" -lossy -q 70 -m 4 \
  "$FRAMES_DIR"/frame_*.png -o "$OUT_DIR/animation.webp"

echo "Wrote $OUT_DIR/animation.webp"
