/// Notation lints, rendered in red since typst has no user-emitted warnings.

#let plain(c) = if type(c) == str { c } else if type(c) == content {
  if c.has("text") { plain(c.text) } else { c.fields().values().map(plain).join(default: "") }
} else if type(c) == array { c.map(plain).join(default: "") } else { "" }

/// Where a relation holds (`0`, `oo`, `0^+`, `n -> oo`) goes under it: `in_0`, `~_oo`, `->_(n->oo)`. Reasons for a step stay above: `=^"L'Hôpital"`.
#let lints(doc) = {
  show math.attach: it => {
    let t = it.at("t", default: none)
    let point = t != none and plain(it.base) in ("=", "∈", "∼", "→", "≈") and plain(t).match(regex("^([+−-]?(\d+|∞)[+−-]?|.*→.*)$")) != none
    if point { text(fill: red, it) } else { it }
  }
  doc
}
