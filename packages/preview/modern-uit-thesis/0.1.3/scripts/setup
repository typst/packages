# source this script to prepare some common environment variables

# adapted from https://github.com/johannes-wolf/cetz/blob/35c0868378cea5ad323cc0d9c2f76de8ed9ba5bd/scripts/package
# licensed under Apache License 2.0

# Local package directories per platform
if [[ "$OSTYPE" == "linux"* ]]; then
  DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  DATA_DIR="$HOME/Library/Application Support"
else
  DATA_DIR="${APPDATA}"
fi

function read-toml() {
  local file="$1"
  local key="$2"
  # Read a key value pair in the format: <key> = "<value>"
  # stripping surrounding quotes.
  perl -lne "print \"\$1\" if /^${key}\\s*=\\s*\"(.*)\"/" < "$file"
}

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)/.." # macOS has no realpath
PKG_PREFIX="$(read-toml "$ROOT/typst.toml" "name")"
VERSION="$(read-toml "$ROOT/typst.toml" "version")"

function resolve-target() {
  local target="$1"

	if [[ "$target" == "@local" ]]; then
		echo "${DATA_DIR}/typst/packages/local"
	elif [[ "$target" == "@preview" ]]; then
		echo "${DATA_DIR}/typst/packages/preview"
	else
		echo "$target"
	fi
}
