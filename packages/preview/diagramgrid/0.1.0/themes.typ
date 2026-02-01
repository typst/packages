// themes.typ — Simple theming helpers for diagramgrid
// Provides dg-theme and preset themes

#import "shapes.typ": dg-rect
#import "layouts.typ": dg-layers

/// Create a theme configuration dictionary.
/// Themes can be applied by spreading into shape/layout calls.
#let dg-theme(
  // Shape defaults
  fill: none,
  stroke: 0.8pt + luma(120),
  radius: 5pt,
  inset: (x: 8pt, y: 6pt),
  // Layout defaults
  gap: 0.8em,
  // Layer defaults
  layer-fill: rgb("#f8f9fa"),
  layer-stroke: 0.7pt + luma(180),
  layer-radius: 6pt,
  layer-inset: 8pt,
) = (
  fill: fill,
  stroke: stroke,
  radius: radius,
  inset: inset,
  gap: gap,
  layer-fill: layer-fill,
  layer-stroke: layer-stroke,
  layer-radius: layer-radius,
  layer-inset: layer-inset,
)

/// Preset: Light theme (default-like, subtle grays)
#let theme-light = dg-theme(
  fill: white,
  stroke: 0.8pt + luma(180),
  radius: 5pt,
  layer-fill: rgb("#f8f9fa"),
  layer-stroke: 0.7pt + luma(200),
)

/// Preset: Dark theme (dark backgrounds, light text)
#let theme-dark = dg-theme(
  fill: rgb("#2d3748"),
  stroke: 1pt + rgb("#4a5568"),
  radius: 6pt,
  layer-fill: rgb("#1a202c"),
  layer-stroke: 1pt + rgb("#4a5568"),
)

/// Preset: Blueprint theme (blue tones)
#let theme-blueprint = dg-theme(
  fill: rgb("#e8f4fd"),
  stroke: 1pt + rgb("#3182ce"),
  radius: 4pt,
  layer-fill: rgb("#ebf8ff"),
  layer-stroke: 1pt + rgb("#63b3ed"),
)

/// Preset: Warm theme (warm earth tones)
#let theme-warm = dg-theme(
  fill: rgb("#fffaf0"),
  stroke: 0.8pt + rgb("#c05621"),
  radius: 6pt,
  layer-fill: rgb("#feebc8"),
  layer-stroke: 0.8pt + rgb("#dd6b20"),
)

/// Preset: Minimal theme (no fills, just strokes)
#let theme-minimal = dg-theme(
  fill: none,
  stroke: 0.6pt + luma(100),
  radius: 3pt,
  layer-fill: none,
  layer-stroke: 0.6pt + luma(150),
)

/// Helper to apply theme to a shape call
#let themed-rect(theme, content, ..args) = {
  dg-rect(
    content,
    fill: theme.fill,
    stroke: theme.stroke,
    radius: theme.radius,
    inset: theme.inset,
    ..args,
  )
}

/// Helper to apply theme to layers — wraps each child in a themed rect
#let themed-layers(theme, width: 200pt, ..args) = {
  let children = args.pos()
  dg-layers(
    gap: theme.gap,
    ..children.map(c => dg-rect(
      c,
      width: width,
      fill: theme.layer-fill,
      stroke: theme.layer-stroke,
      radius: theme.layer-radius,
      inset: theme.layer-inset,
    )),
  )
}

/// Color palette for automatic coloring
#let palette-pastel = (
  rgb("#e3f2fd"),  // blue
  rgb("#e8f5e9"),  // green
  rgb("#fff3e0"),  // orange
  rgb("#fce4ec"),  // pink
  rgb("#f3e5f5"),  // purple
  rgb("#e0f7fa"),  // cyan
  rgb("#fff8e1"),  // amber
  rgb("#efebe9"),  // brown
)

#let palette-vibrant = (
  rgb("#90cdf4"),  // blue
  rgb("#9ae6b4"),  // green
  rgb("#fbd38d"),  // orange
  rgb("#feb2b2"),  // red
  rgb("#d6bcfa"),  // purple
  rgb("#81e6d9"),  // teal
  rgb("#faf089"),  // yellow
  rgb("#fbb6ce"),  // pink
)

/// Get a color from palette by index (cycles)
#let palette-color(palette, index) = {
  palette.at(calc.rem(index, palette.len()))
}
