// Colour maths for token derivation (pure Typst, WCAG-exact).

/// WCAG relative luminance.
#let luminance(c) = {
  let (r, g, b, ..) = color.linear-rgb(c).components(alpha: false)
  0.2126 * r / 100% + 0.7152 * g / 100% + 0.0722 * b / 100%
}

/// WCAG contrast ratio.
/// -> float
#let contrast(a, b) = {
  let (l1, l2) = (luminance(a), luminance(b))
  if l1 < l2 { (l1, l2) = (l2, l1) }
  (l1 + 0.05) / (l2 + 0.05)
}

/// Black or white, whichever contrasts more with `bg`.
/// -> color
#let on-color(bg) = if contrast(bg, black) >= contrast(bg, white) {
  black
} else { white }

/// Darkens (on light bg) or lightens (on dark bg) `fg` until it reaches `target`.
/// Returns an RGB colour (like every derivation), so a CMYK seed is reported once.
/// -> color
#let legible(fg, bg, target: 4.5) = {
  let c = fg
  let dark-bg = luminance(bg) < 0.18
  let i = 0
  while contrast(c, bg) < target and i < 20 {
    c = if dark-bg { c.lighten(10%) } else { c.darken(10%) }
    i += 1
  }
  rgb(c)
}

/// Soft surface (zebra / fills) from a seed: OKLCH at L = 92.88 %, a fraction of the
/// seed's chroma, same hue. For the default seed #1f2937 this yields exactly #e2e8f0,
/// the historic zebra colour, so the default look is preserved by derivation.
/// -> color
#let tint-of(seed) = {
  let (l, c, h, ..) = oklch(seed).components()
  rgb(oklch(92.88%, calc.min(c * 0.4264, 0.04), h))
}
