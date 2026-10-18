// Brand palette . a generator. Derives a coherent palette from one primary color
// so a lab or product can drop in its house color and get a matching deck.
//
//   #import "@preview/sci-brain-slides:0.1.0": brand-palette as build
//   #let palette = build(rgb("#aa1e2b"))   // your house color
//
// Derivation rules (kept simple and predictable, using only color.mix):
//   - primary       = the given color
//   - primary_light = primary mixed 85% toward white
//   - secondary     = primary mixed 35% toward near-black
//   - accent        = primary mixed 55% toward a lavender complement
//   - ink / text    = a very dark shade of primary (12% primary into near-black)
//   - neutrals      = white paper + the dark ink
#let luminance(c) = {
  let channels = rgb(c).components().slice(0, 3).map(v => {
    let v = v / 100%
    if v <= 0.04045 { v / 12.92 } else { calc.pow((v + 0.055) / 1.055, 2.4) }
  })
  (0.2126, 0.7152, 0.0722).zip(channels).map(((w, v)) => w * v).sum()
}

#let on-color(c) = if luminance(c) > 0.179 { black } else { white }

#let build(primary) = {
  let mix2 = (a, wa, b, wb) => color.mix((a, wa), (b, wb))
  let pl = primary.lighten(85%)
  let sec = mix2(primary, 65%, rgb("#10101a"), 35%)
  let ink-c = mix2(primary, 12%, rgb("#10101a"), 88%)
  let text-c = mix2(primary, 8%, rgb("#16161e"), 92%)
  let soft = text-c.lighten(45%)
  let accent-c = mix2(primary, 45%, rgb("#9b83ec"), 55%)
  return (
    primary: primary,
    primary_light: pl,
    secondary: sec,
    // Choose readable text on the primary surface using relative luminance.
    on_primary: on-color(primary),
    accent: accent-c,
    accent_deep: mix2(accent-c, 60%, ink-c, 40%),
    ink: ink-c,
    text: text-c,
    text_soft: soft,
    paper: rgb("#ffffff"),
    paper_bg: pl.lighten(55%),
    hairline: mix2(pl, 60%, rgb("#cccccc"), 40%),
    success: rgb("#2e7d32"),
    warning: rgb("#c62828"),
    neutral_lightest: rgb("#ffffff"),
    neutral_dark: soft,
    neutral_darkest: text-c,
  )
}

// Default brand palette, so it can be listed alongside the others.
#let palette = build(rgb("#2f2f7f"))

// DejaVu Sans is available in the Typst web app and most Linux installs.
// Override the theme's `font:` argument to use another installed family.
#let fonts = (
  sans: "DejaVu Sans",
  serif: "New Computer Modern",
  math: "New Computer Modern Math",
  mono: "DejaVu Sans Mono",
)
