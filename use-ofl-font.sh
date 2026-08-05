#!/usr/bin/env bash
# Replace the CC BY-NC xkcd fonts with OFL-1.1 Comic Neue, so the project
# can be redistributed (including commercially). See REDISTRIBUTING.md §1.
set -e
cd "$(dirname "$0")"

echo "Fetching Comic Neue (SIL Open Font License 1.1)..."
tmp=$(mktemp -d)
curl -sL -o "$tmp/cn.zip" \
  "https://github.com/crozynski/comicneue/archive/refs/heads/master.zip"
unzip -q -o "$tmp/cn.zip" -d "$tmp"

rm -rf fonts
mkdir -p fonts
cp "$tmp"/comicneue-master/Fonts/TTF/ComicNeue/*.ttf fonts/
cp "$tmp"/comicneue-master/OFL.txt fonts/LICENSE-ComicNeue.txt
rm -rf "$tmp"

# point the document at the new family
sed -i 's/#set text(font: ("xkcd Script", "xkcd", "DejaVu Sans")/#set text(font: ("Comic Neue", "DejaVu Sans")/' xkcd.typ

echo "Done. fonts/ is now OFL-1.1. Rebuilding..."
./build.sh
