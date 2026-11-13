#import "../brand.typ": colour

/// A quotation with optional attribution and source, usable without the theme.
#let quote(body, author: none, source: none, fill: colour.neutral-light,
  ink: colour.neutral-dark, accent: colour.primary, inset: 1em,
  radius: .35em, size: 1em, gap: .6em,
) = block(width: 100%, fill: fill, inset: inset, radius: radius, breakable: false, {
  set text(size: size, fill: ink)
  grid(columns: (auto, 1fr), column-gutter: .4em, align: top,
    text(size: 2em, fill: accent)[“],
    [#body
      #if author != none or source != none {
        v(gap)
        align(right, [
          #if author != none { text(weight: "semibold", author) }
          #if author != none and source != none { linebreak() }
          #if source != none { text(size: .85em, source) }
        ])
      }
    ],
  )
})
