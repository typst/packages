#import "defaults.typ": defaults, merge

/// Breakable explanatory box that retains the surrounding body line rhythm.
///
/// ```example
/// #callout(title: [Note])[
///   This paragraph keeps the document's baseline rhythm.
/// ]
/// ```
///
/// - body (content): box content
/// - title (content, none): optional bold heading inside the box
/// - config (dictionary): partial nested overrides merged over the exported
///   `defaults` dictionary. Hover `satz.defaults` (using a namespace import)
///   for the shared keys, types, meanings, and baseline values. This helper
///   reads `colors.bg-subtle`, `colors.brand-primary`, and `callouts.*`; other
///   accepted values do not affect the callout. The merge helper does not
///   validate unknown values.
/// - fill (color, auto): box fill. `auto` uses `config.colors.bg-subtle`.
/// - stroke (color, dictionary, none, auto): border. `auto` uses
///   `config.colors.brand-primary` with the configured `callouts.stroke`;
///   `none` removes the border; a color or stroke dictionary sets it directly.
#let callout(body, title: none, config: (:), fill: auto, stroke: auto) = context {
  let c = merge(defaults, config)
  let style = c.callouts
  set align(left)
  // A line containing only smaller code must keep the body's cap-height.
  let body-top = measure([H]).height
  show raw: set text(top-edge: body-top, bottom-edge: 0pt)
  set text(hyphenate: false)
  set par(justify: false, spacing: style.paragraph-spacing)
  set list(tight: false, spacing: style.list-spacing)
  set enum(tight: false, spacing: style.list-spacing)
  block(
    width: 100%,
    breakable: true,
    inset: style.inset,
    radius: style.radius,
    fill: if fill == auto { c.colors.bg-subtle } else { fill },
    stroke: if stroke == auto {
      (paint: c.colors.brand-primary, thickness: style.stroke)
    } else { stroke },
    {
      if title != none {
        block(sticky: true, below: style.title-below,
          text(weight: "bold", fill: c.colors.brand-primary, title))
      }
      body
    },
  )
}
