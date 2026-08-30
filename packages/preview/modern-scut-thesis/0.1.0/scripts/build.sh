#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

usage() {
  cat <<'EOF'
Usage:
  scripts/build.sh final
  scripts/build.sh blind <single|double>
  scripts/build.sh for-check
  scripts/build.sh for-print
  scripts/build.sh all
  scripts/build.sh clean
EOF
}

compile() {
  mkdir -p out
  typst compile --root . "$@"
}

build_final() {
  compile template/thesis.typ out/thesis.pdf
}

build_blind() {
  local level="${1:-}"
  if [[ "$level" != "single" && "$level" != "double" ]]; then
    usage >&2
    exit 2
  fi

  compile \
    --input profile=blind \
    --input "blind=$level" \
    template/thesis.typ "out/thesis-blind-$level.pdf"
}

page_range() {
  # 单次 eval 同时查询两个结构标签，省一次完整编译
  typst eval --root . --in template/thesis.typ \
    'str(query(<mainmatter-start>).first().location().page()) + " " + str(query(<backmatter-start>).first().location().page())' || {
      echo "错误：未找到结构标签（<mainmatter-start> 应由 mainmatter 布局自动放置，" >&2
      echo "<backmatter-start> 应由 bilingual-bibliography() 自动放置）。" >&2
      exit 1
    }
}

build_for_check() {
  local range start end
  range="$(page_range)"
  range="${range//\"/}"
  start="${range% *}"
  end=$(( ${range#* } - 1 ))

  compile --no-pdf-tags --pages "$start-$end" template/thesis.typ out/thesis-for-check.pdf
}

build_for_print() {
  compile \
    --input profile=for-print \
    template/thesis.typ out/thesis-for-print.pdf
}

case "${1:-}" in
  final)
    build_final
    ;;
  blind)
    build_blind "${2:-}"
    ;;
  for-check)
    build_for_check
    ;;
  for-print)
    build_for_print
    ;;
  all)
    build_final
    build_blind single
    build_blind double
    build_for_check
    build_for_print
    ;;
  clean)
    rm -f out/thesis*.pdf
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
