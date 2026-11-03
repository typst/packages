#import "context.typ": component-wrapper
#import "blocks.typ": block-kinds
#import "../palettes.typ": on-color
#import "../vendor/shadowed.typ": shadow

#let render-ambrosia-badge(self: none, kind: "accent", fill: auto, shadowed: false, body) = {
  assert(kind in block-kinds, message: "Unknown ambrosia-badge kind: " + str(kind))
  assert(type(shadowed) == bool, message: "Badge shadowed must be true or false.")
  let fill = if fill != auto { fill } else if kind == "accent" { self.colors.primary } else { self.colors.at(kind) }
  text(size: 0.7em, weight: "semibold", fill: on-color(fill), {
    let badge = box(fill: fill, radius: 0.4em, inset: (x: 0.5em, y: 0.2em), body)
    if shadowed { context {
      let size = measure(badge)
      box(width: size.width, height: size.height, shadow(badge, radius: 0.4em, blur: 0.25em, dx: 0.1em, dy: 0.1em,
      fill: self.colors.chrome.transparentize(65%)))
    } } else { badge }
  })
}

/// Compact inline semantic label for status, results, and annotations.
/// -> content
#let ambrosia-badge(
  /// Accent, info, success, warning, danger, or neutral.
  /// -> str
  kind: "accent",
  /// Explicit solid fill; auto follows kind.
  /// -> auto | color
  fill: auto,
  /// Add a small shadow to the badge.
  /// -> bool
  shadowed: false,
  /// Positional label text or content.
  /// -> content
  body,
) = component-wrapper(render-ambrosia-badge.with(kind: kind, fill: fill, shadowed: shadowed), body)

#let render-ambrosia-source-note(self: none, body) = block(above: 0.35em, below: 0em,
  text(size: 0.65em, fill: self.colors.muted, body))

/// Local source/credit line without consuming a footnote or creating a reference.
#let ambrosia-source-note(body) = component-wrapper(render-ambrosia-source-note, body)
