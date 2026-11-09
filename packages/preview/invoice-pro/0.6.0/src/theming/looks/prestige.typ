// LOOK `prestige` (serif family): premium brands, boutique hotels, fashion,
// jewellers, fine dining - few lines, high amounts, the invoice as part of the
// brand. The letterhead area is an onyx surface with champagne text (on
// `a4-band` a full-bleed band, on window layouts the layout's own letterhead box
// inside the margins); on the white page champagne returns only as rules, and
// accent-coloured text uses colors.accent-text (a bronze that reaches 4.5:1).
// A Didone display face for the name and the document word, a Garamond body;
// every chain ends in Libertinus Serif (embedded).
// Default layout: a4-band (us-letter-band in the US). The solid band cannot
// print edge to edge on office printers: prestige is digital-first; for print
// pass a window layout (`layout: theme.layout.din-5008-b`).
#import "../custom.typ" as c
#import "../color.typ": legible
#import "serif.typ": family, pairs

#let look = {
  c.colors(
    primary: rgb("#1c1a17"), // onyx
    accent: rgb("#c8a96b"), // champagne
    on-primary: t => legible(t.colors.accent, t.colors.primary), // champagne text on the onyx surface
    text: rgb("#1c1a17"),
    text-muted: rgb("#6a6258"),
    border: t => t.colors.accent,
    tint: rgb("#f5efe4"),
  )
  c.fonts(
    body: ("EB Garamond", "Libertinus Serif"),
    heading: (
      "Playfair Display",
      "Bodoni Moda",
      "Bodoni MT",
      "Libertinus Serif",
    ),
    label: ("EB Garamond", "Libertinus Serif"), // both have true small capitals
  )
  c.sizes(body: 10pt, small: 0.88em, fine: 6.8pt, large: 1.35em, title: 1.75em)
  c.weights(strong: "semibold")
  c.strokes(hairline: 0.4pt, thin: 0.5pt, regular: 0.6pt, thick: 0.9pt)
  c.spacing(small: 0.44em, medium: 0.75em)
  c.title(color: t => t.colors.text)
  c.line-items(discount-color: rgb("#8c2f39"))
  c.items-table(row-rule: t => (
    t.strokes.hairline + t.colors.accent.lighten(35%)
  ))
  c.logo(height: 12mm)
  family
  pairs
  c.area(
    "letterhead",
    fill: t => t.colors.primary,
    text: (fill: t => t.colors.on-primary),
    inset: (x: 6mm, y: 2.5mm),
  )
}
