#!/usr/bin/env bash
# Rebuild the WASM plugin (if possible) and compile the document.
#
# A precompiled sketch.wasm ships with this project, so Rust is OPTIONAL.
# If the toolchain or the wasm target is missing we say so and fall back to
# the bundled binary instead of failing the build.
set -euo pipefail
cd "$(dirname "$0")"

# rustup/cargo are often not on PATH in non-login shells
export PATH="$HOME/.cargo/bin:$PATH"

TARGET=wasm32-unknown-unknown
build_plugin=yes

if ! command -v cargo >/dev/null 2>&1; then
  echo "note: cargo not found - using the bundled sketch.wasm"
  echo "      (install Rust from https://rustup.rs if you want to rebuild it)"
  build_plugin=no
fi

# cargo alone is not enough: the wasm target's std must also be installed,
# otherwise the build dies with 'can't find crate for std' (E0463).
if [ "$build_plugin" = yes ]; then
  if command -v rustup >/dev/null 2>&1; then
    if ! rustup target list --installed 2>/dev/null | grep -qx "$TARGET"; then
      echo "note: Rust target $TARGET is missing - installing it..."
      if ! rustup target add "$TARGET"; then
        echo "warning: could not install $TARGET - using the bundled sketch.wasm"
        build_plugin=no
      fi
    fi
  else
    # cargo without rustup (distro package, nix, ...): probe for the target's
    # std by attempting the build later; warn early so the error makes sense.
    if ! cargo build --release --quiet \
          --manifest-path plugin/Cargo.toml --target "$TARGET" 2>/dev/null; then
      echo "warning: cannot build for $TARGET (no rustup to install it)."
      echo "         Install the target via your package manager, e.g."
      echo "           Debian/Ubuntu:  apt install rust-src  (or use rustup)"
      echo "         Falling back to the bundled sketch.wasm."
      build_plugin=no
    fi
  fi
fi

if [ "$build_plugin" = yes ]; then
  cargo build --release --manifest-path plugin/Cargo.toml --target "$TARGET"
  cp "plugin/target/$TARGET/release/sketch.wasm" ./sketch.wasm
  echo "rebuilt sketch.wasm"
fi

if [ ! -f sketch.wasm ]; then
  echo "error: sketch.wasm is missing and could not be built." >&2
  exit 1
fi

typst compile xkcd.typ xkcd.pdf --font-path fonts
typst compile example.typ example.pdf --font-path fonts
echo "wrote xkcd.pdf and example.pdf"
