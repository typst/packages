#import "render.typ": unimola

/// Show-rule helper to render fenced raw blocks (`plantuml` / `puml`) automatically.
/// Example: `#show raw.where(lang: "plantuml"): show-unimola-blocks()`
/// -> function
#let show-unimola-blocks(
  theme: auto,
  preamble: auto,
  auto-wrap: auto,
  deterministic: auto,
  includes: auto,
  width: auto,
  height: auto,
  fit: "contain",
  scale: none,
  alt: none,
) = block => unimola(
  block.text,
  theme: theme,
  preamble: preamble,
  auto-wrap: auto-wrap,
  deterministic: deterministic,
  includes: includes,
  width: width,
  height: height,
  fit: fit,
  scale: scale,
  alt: alt,
)
