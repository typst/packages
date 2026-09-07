// Style vocabulary shared by every chalks call. Engine keys cross the WASM
// boundary; color/opacity are applied Typst-side when rendering.
#import "theme.typ": theme-state

/// Complete fallback style used when neither a theme nor a call overrides a key.
///
/// Copy and merge this dictionary when building a custom reusable theme. Stroke
/// widths and fill spacing are numeric canvas points, not Typst lengths.
#let default-style = (
  smoothness: 0.7,
  roughness: 1.0,
  width: 1.2,
  taper: 0.5,
  passes: 1,
  pattern: "hachure",
  angle: 45.0,
  spacing: 4.0,
  color: rgb("#44464a"),
  opacity: 100%,
)

#let _engine-stroke-keys = ("smoothness", "roughness", "width", "taper", "passes")
#let _engine-fill-keys = ("smoothness", "roughness", "width", "pattern", "angle", "spacing")

#let validate-style(s) = {
  for (k, v) in s {
    if k != "seed" and k not in default-style {
      panic("chalks: unknown style key: " + k)
    }
  }
  for k in ("smoothness", "taper") {
    if k in s and (s.at(k) < 0 or s.at(k) > 1) {
      panic("chalks: " + k + " must be in [0, 1], got " + repr(s.at(k)))
    }
  }
  for k in ("width", "spacing") {
    if k in s and s.at(k) <= 0 {
      panic("chalks: " + k + " must be positive")
    }
  }
  if "pattern" in s and s.pattern not in ("hachure", "shade") {
    panic("chalks: unknown fill pattern: " + s.pattern)
  }
  if "passes" in s and s.passes < 1 {
    panic("chalks: passes must be >= 1")
  }
}

/// default-style + document theme + per-call overrides.
/// Must be called inside `context` (canvas and annotate both are).
#let resolve-style(overrides) = {
  validate-style(overrides)
  default-style + theme-state.get() + overrides
}

/// Sets document-wide style overrides for subsequent Chalks rendering.
///
/// ```typst
/// #chalks-theme(chalk)
/// #chalks-theme((roughness: 1.3, width: 1.8, color: navy))
/// ```
///
/// A preset or partial style dictionary is merged over `default-style`.
/// Individual shape arguments still take precedence.
///
/// - t (dictionary): Any subset of `smoothness`, `roughness`, `width`,
///   `taper`, `passes`, `pattern`, `angle`, `spacing`, `color`, and `opacity`.
#let chalks-theme(t) = {
  validate-style(t)
  theme-state.update(t)
}

#let engine-stroke-style(s) = {
  let out = (:)
  for k in _engine-stroke-keys { out.insert(k, float(s.at(k))) }
  out.passes = int(s.passes)
  out
}

#let engine-fill-style(s) = {
  let out = (:)
  for k in _engine-fill-keys {
    out.insert(k, if k == "pattern" { s.at(k) } else { float(s.at(k)) })
  }
  out
}

/// FNV-1a over repr(data), 32-bit: stable auto-seed so unchanged figures
/// never re-roll between compiles.
#let auto-seed(data) = {
  let h = 2166136261
  for b in bytes(repr(data)) {
    h = calc.rem((h.bit-xor(b)) * 16777619, 4294967296)
  }
  h
}
