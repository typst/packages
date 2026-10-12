#import "style.typ": default-emphasis-colors, default-emphasis-labels, default-ink

/// Every drawing option in one record, with defaults merged in. Built once by
/// `mindmap` and handed to measuring and drawing, so both read the same values.
#let make-opts(
  style: "boxed",
  font: "Inter",
  text-size: 9pt,
  node-max-width: 6cm,
  root-max-width: auto,
  mono-font: "DejaVu Sans Mono",
  markers: "none",
  surface: "none",
  emphasis-labels: (:),
  ink: (:),
  emphasis-colors: (:),
  edge: "curved",
) = (
  style: style,
  font: font,
  text-size: text-size,
  node-max-width: node-max-width,
  root-max-width: if root-max-width == auto { node-max-width * 2 } else { root-max-width },
  mono-font: mono-font,
  markers: markers,
  surface: surface,
  emphasis-labels: default-emphasis-labels + emphasis-labels,
  ink: default-ink + ink,
  emphasis-colors: default-emphasis-colors + emphasis-colors,
  edge: edge,
)
