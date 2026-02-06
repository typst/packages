#let bin = plugin("../bin/plugin.wasm")

/// Pick a target from a source
#let pick(
  src,
  target,
  lang: "rust",
) = {
  json(bin.pick(bytes(src), bytes(target), bytes(lower(lang))))
}
