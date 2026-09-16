// Field element constructors — the byte-region cluster's shared vocabulary
// (packet, struct, hexdump all build from these). Each returns a plain descriptor
// dict that `model` consumes; the author supplies widths and labels, never bit
// positions. Pure.
// `at:` anchors a field to an absolute offset in the constructor's own unit:
// `bytes(.., at: k)` is byte `k`, `bits(.., at: k)` is bit `k` (the model works
// in bits, so `bytes` scales its anchor up by 8). This suits byte-oriented views
// (hexdump/struct) without a separate `unit:`. `fill:` highlights a field. `gap`
// is a dashed "unparsed" span; `reserved` is a plain empty field (reserved bits).
// Labels are optional positional trailing content (as on `gap`/`reserved`): omit
// to draw an unnamed field — e.g. `bytes(4, at: 0x10, fill: palette.orange)`
// highlights a region without a legend row.

#let bytes(n, ..rest, at: none, fill: none) = (
  kind: "field",
  width: n * 8,
  label: rest.pos().at(0, default: none),
  anchor: if at == none { none } else { at * 8 },
  fill: fill,
)

#let bits(n, ..rest, at: none, fill: none) = (
  kind: "field",
  width: n,
  label: rest.pos().at(0, default: none),
  anchor: at,
  fill: fill,
)

#let gap(n, ..rest) = (
  kind: "gap",
  width: n,
  label: rest.pos().at(0, default: none),
  anchor: none,
  fill: none,
)

#let reserved(n, ..rest) = (
  kind: "field",
  width: n,
  label: rest.pos().at(0, default: none),
  anchor: none,
  fill: none,
)
