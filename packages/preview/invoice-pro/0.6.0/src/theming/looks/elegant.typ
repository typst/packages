// LOOK `elegant` (serif family): law firms, notaries, tax advisers, auditors,
// consultancies. A letter from chambers: Libertinus Serif throughout, one deep
// ink colour for the letterhead, key labels and the payable, hairlines for every
// divider, no filled areas (cheap to print, credible in greyscale).
// Default layout: the sender's window layout, with DIN 5008 form B instead of
// form A (its 37 mm letterhead zone gives the centred letterhead room).
#import "../custom.typ" as c
#import "serif.typ": family, pairs

#let look = {
  c.colors(
    primary: rgb("#1c2a48"), // deep ink blue; accent stays = primary
    text: rgb("#1e1e1e"),
    text-muted: rgb("#5a5f69"),
    border: t => t.colors.primary.lighten(55%),
    tint: t => t.colors.primary.lighten(94%),
  )
  c.fonts(body: ("Libertinus Serif",), heading: ("Libertinus Serif",))
  c.sizes(body: 10pt, small: 0.88em, fine: 7pt, large: 1.25em, title: 1.4em)
  c.weights(strong: "semibold")
  c.strokes(hairline: 0.3pt, thin: 0.45pt, regular: 0.6pt, thick: 0.6pt)
  c.spacing(small: 0.42em, medium: 0.7em)
  c.title(color: t => t.colors.primary-text)
  c.line-items(discount-color: rgb("#7d1d2c"))
  c.logo(height: 11mm)
  family
  pairs
  c.area("letterhead", text: (fill: t => t.colors.primary-text))
}
