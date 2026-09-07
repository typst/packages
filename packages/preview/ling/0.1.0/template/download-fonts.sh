#!/bin/sh
set -eu

fail() {
  echo "download-fonts: $*" >&2
  exit 1
}

for required_command in curl unzip mktemp awk mkdir mv rm dirname; do
  command -v "$required_command" >/dev/null 2>&1 ||
    fail "$required_command is required"
done

if command -v shasum >/dev/null 2>&1; then
  hash_file() {
    shasum -a 256 "$1" | awk '{ print $1 }'
  }
elif command -v sha256sum >/dev/null 2>&1; then
  hash_file() {
    sha256sum "$1" | awk '{ print $1 }'
  }
else
  fail 'shasum or sha256sum is required'
fi

project_dir="$(CDPATH= cd "$(dirname "$0")" && pwd)" ||
  fail 'could not resolve the initialized project directory'
font_dir="$project_dir/fonts"
checksum_file="$font_dir/SHA256SUMS"
[ -f "$checksum_file" ] || fail "missing checksum file: $checksum_file"
mkdir -p "$font_dir"

download_tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/ling-fonts.XXXXXX")" ||
  fail 'mktemp -d failed'
cleanup() {
  rm -rf "$download_tmp_dir"
}
on_signal() {
  trap - 0 1 2 15
  cleanup
  exit "$1"
}
trap cleanup 0
trap 'on_signal 129' 1
trap 'on_signal 130' 2
trap 'on_signal 143' 15

expected_hash() {
  awk -v name="$1" '$2 == name { print $1 }' "$checksum_file"
}

is_verified() {
  font_name="$1"
  expected="$(expected_hash "$font_name")"
  [ -n "$expected" ] || fail "missing pinned checksum for $font_name"
  [ -f "$font_dir/$font_name" ] &&
    [ "$(hash_file "$font_dir/$font_name")" = "$expected" ]
}

install_verified() {
  source_file="$1"
  font_name="$2"
  expected="$(expected_hash "$font_name")"
  [ "$(hash_file "$source_file")" = "$expected" ] ||
    fail "checksum mismatch for $font_name"
  mv "$source_file" "$font_dir/$font_name"
  echo "downloaded and verified: $font_name"
}

pretendard_needed=
for font_name in \
  PretendardGOV-Regular.otf \
  PretendardGOV-SemiBold.otf \
  PretendardGOV-Bold.otf
do
  if is_verified "$font_name"; then
    echo "already verified: $font_name"
  else
    pretendard_needed="$pretendard_needed $font_name"
  fi
done

if [ -n "$pretendard_needed" ]; then
  pretendard_archive="$download_tmp_dir/PretendardGOV-1.3.9.zip"
  curl --fail --location --silent --show-error --retry 2 \
    --output "$pretendard_archive" \
    https://github.com/orioncactus/pretendard/releases/download/v1.3.9/PretendardGOV-1.3.9.zip ||
    fail 'could not download Pretendard GOV 1.3.9'
  unzip -q "$pretendard_archive" \
    'public/static/PretendardGOV-Regular.otf' \
    'public/static/PretendardGOV-SemiBold.otf' \
    'public/static/PretendardGOV-Bold.otf' \
    -d "$download_tmp_dir/pretendard" ||
    fail 'could not extract Pretendard GOV 1.3.9'
  for font_name in $pretendard_needed; do
    install_verified \
      "$download_tmp_dir/pretendard/public/static/$font_name" \
      "$font_name"
  done
fi

download_direct() {
  font_name="$1"
  url="$2"
  if is_verified "$font_name"; then
    echo "already verified: $font_name"
    return
  fi
  target="$download_tmp_dir/$font_name"
  curl --fail --location --silent --show-error --retry 2 \
    --output "$target" "$url" || fail "could not download $font_name"
  install_verified "$target" "$font_name"
}

download_direct RIDIBatang.otf \
  https://ridicorp.com/wp-content/themes/ridicorp/css/font/RIDIBatang.otf
download_direct D2Coding-Regular.ttf \
  https://raw.githubusercontent.com/naver/d2-coding-font/VER1.3.3/fonts/ttf/D2Coding-Regular.ttf
download_direct D2Coding-Bold.ttf \
  https://raw.githubusercontent.com/naver/d2-coding-font/VER1.3.3/fonts/ttf/D2Coding-Bold.ttf
