#let bin = plugin("../bin/plugin.wasm")

/// Pick a target from a source
#let pick(
  src,
  target,
  lang: "rust",
) = {
  json(bin.pick(bytes(src), bytes(target), bytes(lower(lang))))
}

/// List all targets in a source
#let scope(
  src,
  lang: "rust",
) = {
  json(bin.scope(bytes(src), bytes(lower(lang))))
}
