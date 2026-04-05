#!/bin/sh
set -e
cd "$(dirname $0)"
cargo build --release --target wasm32-unknown-unknown
cp ./target/wasm32-unknown-unknown/release/plugin.wasm .
