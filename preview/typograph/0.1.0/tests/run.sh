#!/usr/bin/env bash
# typograph test runner: unit tests + smoke tests must compile cleanly;
# negative tests must fail to compile. Run from the typograph/ directory:
#   bash tests/run.sh
set -u
cd "$(dirname "$0")/.."
FAIL=0
TEST_TMP="$(mktemp -d "${TMPDIR:-/tmp}/typograph-tests.XXXXXX")" || {
  echo "could not create test temporary directory" >&2
  exit 1
}
trap 'rm -rf "$TEST_TMP"' EXIT
# Staged under "preview" (not "local") because a couple of tests
# (package-contract.typ, negative/lib-private-alias.typ) deliberately compile
# through the manifest/package loader at the exact path this package will
# ship under once published, to catch entrypoint/facade regressions.
if ! mkdir -p "$TEST_TMP/packages/preview/typograph" \
  || ! ln -s "$PWD" "$TEST_TMP/packages/preview/typograph/0.1.0"; then
  echo "could not stage local package fixture" >&2
  exit 1
fi
export TYPST_PACKAGE_PATH="$TEST_TMP/packages"

expected_error() {
  case "$(basename "$1")" in
    config-positional.typ) echo "config() takes only named arguments" ;;
    config-theme.typ|config-unknown.typ) echo "unknown config option" ;;
    diagram-zero-scale.typ) echo "diagram scale must be a positive" ;;
    diagram-grid-type.typ) echo "diagram grid must be a boolean" ;;
    diagram-inset-unknown.typ) echo "diagram inset has unknown key" ;;
    duplicate-node-name.typ) echo "duplicate node name" ;;
    edge-bad-highlight-length.typ|edge-bad-highlight-type.typ) echo "highlight: expects" ;;
    edge-direction-duplicate.typ) echo "exactly one direction and one numeric strength" ;;
    edge-direction-strength.typ) echo "direction strength must be positive" ;;
    edge-label-pos.typ) echo "label-pos must be a number from 0 to 1" ;;
    edge-bad-quad-control.typ) echo "quad() control must be a numeric" ;;
    edge-bad-cubic-control.typ) echo "cubic() controls must be numeric" ;;
    edge-bad-rel.typ) echo "rel() dx/dy must be numbers" ;;
    edge-path-first.typ) echo "first waypoint cannot be line(), quad(), or cubic()" ;;
    edge-bend-with-from.typ) echo "bend: and from:/to: are alternatives" ;;
    edge-bend-with-smooth.typ) echo "smooth() cannot be combined with bend:" ;;
    edge-from-to-with-chain.typ) echo "from:/to: can only be used on a simple 2-waypoint edge" ;;
    edge-fragment-endpoint.typ) echo "edge waypoints must be a node" ;;
    edge-ref-unknown.typ) echo "found no node with that name" ;;
    edge-ref-non-string.typ) echo "ref() name must be a string" ;;
    edge-rel-first.typ) echo "cannot be an edge's first" ;;
    edge-smooth-endpoint.typ) echo "smooth() can only mark an interior edge waypoint" ;;
    edge-smooth-with-explicit-path.typ) echo "smooth() cannot be combined with explicit" ;;
    edge-style-font-size.typ|edge-style-unknown.typ) echo "edge style has unknown key" ;;
    edge-style-label-inset.typ) echo "label-inset must be a length" ;;
    edge-style-label-fill.typ) echo "label-fill must be none, a color" ;;
    edge-style-highlight-auto.typ) echo "highlight must be none, a color" ;;
    edge-style-clip-auto.typ) echo "clip must be a boolean" ;;
    edge-too-few-waypoints.typ) echo "needs at least 2 waypoints" ;;
    edge-unknown-preset.typ) echo "unknown edge preset" ;;
    gate-invalid-legs.typ) echo "gate leg counts must be non-negative integers" ;;
    group-bad-pivot.typ) echo "group pivot must be a numeric" ;;
    lib-private-alias.typ) echo 'module `typograph` does not contain `core-diagram`' ;;
    make-node-reserved-field.typ) echo "extra fields cannot replace reserved field" ;;
    node-type-bad-kind.typ) echo "node-type() kind must be a string" ;;
    node-type-bad-flippable.typ) echo "node-type() flippable must be a boolean" ;;
    node-name-non-string.typ) echo "node name must be a string or none" ;;
    node-unsupported-rotate.typ) echo "rotate is not supported by shapes." ;;
    node-unknown-shape.typ) echo "shape must be a builder function" ;;
    node-inset-unknown.typ) echo "node style inset has unknown key" ;;
    node-style-min-size.typ) echo "min-size must be a non-negative length" ;;
    node-style-rotate.typ) echo "rotate must be an angle" ;;
    place-logical-align.typ) echo "place align must use physical" ;;
    polygon-outline-boundary.typ|polygon-outline-origin.typ) echo "requires the node origin strictly inside the polygon" ;;
    port-bad-side-index.typ|port-negative-index.typ|port-non-integer-index.typ) echo "gate has no port" ;;
    port-bad-side-name.typ) echo "port side must be" ;;
    port-on-non-gate.typ) echo "port() expects a port-capable node" ;;
    primitive-bad-result.typ) echo "returned unsupported outline kind" ;;
    primitive-spoof-trusted.typ) echo "requires the node origin strictly inside the polygon" ;;
    shape-bad-radius.typ) echo "circle outline radius must be a non-negative length" ;;
    shape-bad-label-offset.typ) echo "outline label-offset must be an absolute-length pair" ;;
    shape-invisible-label-offset.typ) echo "outlines cannot use label-offset" ;;
    shape-labelled-string.typ) echo "shape-labelled must be auto or a builder function" ;;
    shape-polygon-anchor.typ) echo "requires its anchor inside the polygon" ;;
    shape-polygon-points.typ) echo "needs at least three numeric point pairs" ;;
    shape-regular-vertices.typ) echo "vertices must be an integer of at least 3" ;;
    theme-bad-node-presets.typ) echo "theme node-presets must be a dictionary" ;;
    theme-bad-palette.typ) echo "theme palette must be a dictionary" ;;
    theme-bad-node-preset-value.typ) echo "node preset \"z\" must be a dictionary" ;;
    theme-bad-edge-preset-value.typ) echo "edge preset \"alert\" must be a dictionary" ;;
    theme-bad-type.typ) echo "diagram theme must be a dictionary" ;;
    theme-unknown-field.typ) echo "diagram theme has unknown field" ;;
    *) return 1 ;;
  esac
}

echo "== positive tests (must compile) =="
for f in tests/unit.typ tests/api-contract.typ tests/theme-contract.typ tests/shape-contract.typ tests/config-contract.typ tests/package-contract.typ tests/smoke.typ tests/highlight-waypoints.typ tests/stress.typ tests/shape-stress.typ tests/curve-stress.typ tests/user.typ; do
  if typst compile --root . "$f" "$TEST_TMP/out.pdf" 2>"$TEST_TMP/error.txt"; then
    echo "  PASS  $f"
  else
    echo "  FAIL  $f (expected success, got error)"
    sed 's/^/        /' "$TEST_TMP/error.txt"
    FAIL=1
  fi
done

echo "== outline geometry snapshot =="
if ! typst eval 'query(raw).map(it => it.text)' \
  --in tests/outline-probe.typ --root . --pretty \
  >"$TEST_TMP/outline-probe.json" 2>"$TEST_TMP/error.txt"; then
  echo "  FAIL  tests/outline-probe.typ"
  sed 's/^/        /' "$TEST_TMP/error.txt"
  FAIL=1
elif cmp -s tests/outline-probe.expected.json "$TEST_TMP/outline-probe.json"; then
  echo "  PASS  tests/outline-probe.expected.json"
else
  echo "  FAIL  tests/outline-probe.expected.json (outline sizes changed)"
  diff -u tests/outline-probe.expected.json "$TEST_TMP/outline-probe.json" || true
  FAIL=1
fi

echo "== negative tests (must fail to compile) =="
for f in tests/negative/*.typ; do
  EXPECTED="$(expected_error "$f")" || {
    echo "  FAIL  $f (no expected diagnostic registered)"
    FAIL=1
    continue
  }
  if typst compile --root . "$f" "$TEST_TMP/out.pdf" 2>"$TEST_TMP/error.txt"; then
    echo "  FAIL  $f (expected a compile error, but it compiled)"
    FAIL=1
  elif grep -Fq -- "$EXPECTED" "$TEST_TMP/error.txt"; then
    echo "  PASS  $f"
  else
    echo "  FAIL  $f (failed for the wrong reason; expected: $EXPECTED)"
    sed 's/^/        /' "$TEST_TMP/error.txt"
    FAIL=1
  fi
done

echo "== generated documentation assets =="
# This comparison has to be reproducible across machines that generate and
# verify the committed SVG separately (a contributor's laptop vs. CI), which
# plain rendering doesn't guarantee on its own, in two separate ways this
# project has actually hit:
#   - Font availability. --ignore-system-fonts pins font resolution to
#     Typst's own bundled fonts. Without it, whichever machine has (or
#     lacks) a same-named system font can render text-heavy figures
#     differently than a machine using only the embedded copy.
#   - Build/architecture jitter. Even with fonts pinned, a different Typst
#     *build* of the same version (different OS/arch/libm) is not
#     guaranteed bit-identical for curve or glyph geometry. compare-svg.py
#     (used in place of a raw cmp) rounds every decimal number in both
#     files to 2 decimal places before comparing, which absorbs that
#     sub-percent jitter while still catching any real content change.
# Regenerate a figure with the same --ignore-system-fonts flag after editing
# it, before running this suite again.
for f in docs/img/*.typ; do
  svg="${f%.typ}.svg"
  out="$TEST_TMP/$(basename "$svg")"
  if ! typst compile --root . --ignore-system-fonts --format svg "$f" "$out" 2>"$TEST_TMP/error.txt"; then
    echo "  FAIL  $svg (source did not compile as SVG)"
    sed 's/^/        /' "$TEST_TMP/error.txt"
    FAIL=1
  elif [ ! -e "$svg" ]; then
    echo "  FAIL  $svg (missing; generate it from $f)"
    FAIL=1
  elif python3 tests/compare-svg.py "$svg" "$out"; then
    echo "  PASS  $svg"
  else
    echo "  FAIL  $svg (stale; regenerate it from $f)"
    FAIL=1
  fi
done

if [ "$FAIL" -ne 0 ]; then
  echo "== RESULT: FAILURES ABOVE =="
  exit 1
else
  echo "== RESULT: all tests passed =="
fi
