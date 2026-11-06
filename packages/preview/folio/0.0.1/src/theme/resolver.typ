/// folio — Theme resolver
/// resolve-token: 3-level fallback chain (user brand → preset → corporate defaults)
/// resolve-spacing: base × density-multiplier × explicit-multiplier
#import "tokens.typ": default-tokens

/// Private: walk a pre-split parts array through a dict.
/// Returns (found: bool, value: any).
/// NOTE: intentionally local — importing from core/resolve.typ would create
///       a theme/ → core/ dependency. See DECISION 3 in todo.md.
#let _walk-dict(dict, parts) = {
  let current = dict
  for p in parts {
    if type(current) == dictionary and p in current {
      current = current.at(p)
    } else {
      return (found: false, value: none)
    }
  }
  (found: true, value: current)
}

/// Resolve a dot-path token through the 3-level fallback chain.
/// 1. User brand override  2. Preset tokens  3. Corporate defaults
/// Returns the resolved value, or rgb("#ff00ff") as a visible debug sentinel.
#let resolve-token(st, path) = {
  let parts = path.split(".")

  let r = _walk-dict(st.at("brand", default: (:)), parts)
  if r.found { return r.value }

  let r = _walk-dict(st.at("preset-tokens", default: (:)), parts)
  if r.found { return r.value }

  let r = _walk-dict(default-tokens, parts)
  if r.found { return r.value }

  rgb("#ff00ff") // visible debug sentinel — token path not found in any level
}

/// Resolve spacing: base-token × density-multiplier × explicit-multiplier.
#let resolve-spacing(st, multiplier: 1.0) = {
  let base = resolve-token(st, "spacing.base")
  if type(base) != length { base = 1em }

  let density = st
    .at("brand", default: (:))
    .at("density", default: "comfortable")
  let d-mults = resolve-token(st, "spacing.density-multiplier")
  let d-mult = if type(d-mults) == dictionary {
    d-mults.at(density, default: 1.0)
  } else { 1.0 }

  base * d-mult * multiplier
}
