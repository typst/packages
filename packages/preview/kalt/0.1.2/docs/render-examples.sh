#!/usr/bin/env bash
set -euo pipefail

output_dir="${1:-typst/assets/readme}"
mkdir -p "$output_dir"

package_version="$(sed -n 's/^version = "\(.*\)"/\1/p' typst/typst.toml)"
if [[ -z "$package_version" ]]; then
  echo "Could not read package version from typst/typst.toml" >&2
  exit 1
fi

# Render through the same public import users copy from the README.
package_path="$(mktemp -d)"
package_root="$package_path/preview/kalt/$package_version"
mkdir -p "$package_root"
cp -a typst/. "$package_root/"
export TYPST_PACKAGE_PATH="$package_path"

for example in scalar-operations matrix-operations vector-operations complex-arithmetic; do
  echo "Rendering $example"
  typst compile \
    --package-path "$package_path" \
    --root . \
    --format svg \
    "typst/docs/examples/$example.typ" \
    "$output_dir/$example.svg"
done

# Compile the non-visual collection-helper example as a documentation check.
echo "Checking collection-helpers"
typst compile \
  --package-path "$package_path" \
  --root . \
  "typst/docs/examples/collection-helpers.typ" \
  "$package_path/collection-helpers.pdf"

# Render the intentional shape error so the README can show its visual hint.
echo "Rendering error-hints"
typst compile \
  --package-path "$package_path" \
  --root . \
  --format svg \
  "typst/docs/examples/error-hints.typ" \
  "$output_dir/error-hints.svg"
