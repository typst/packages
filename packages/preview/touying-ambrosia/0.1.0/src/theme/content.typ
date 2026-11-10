#import "../palettes.typ": contrast, on-color

// Wrap the original native element once. Its language/theme, quote marks,
// attribution, footnotes, links, and labels remain under Typst's control.
#let apply-code-style(self: none, body) = {
  if self.store.code-style == "plain" { return body }
  show raw.where(block: true): it => context {
    let surface = self.colors.surface-alt
    let ink = if contrast(self.colors.foreground, surface) >= 4.5 { self.colors.foreground }
      else { on-color(surface) }
    block(width: 100%, inset: (x: 0.65em, y: 0.45em), radius: 0.25em,
      fill: surface, stroke: 0.03em + self.colors.border, breakable: false, {
        [#metadata((size: text.size.pt(), background: surface.to-hex()))<ambrosia-code-style>]
        set text(fill: ink)
        it
      })
  }
  body
}

#let apply-quote-style(self: none, body) = {
  if self.store.quote-style == "plain" { return body }
  show quote.where(block: true): it => block(width: 100%,
    inset: (x: 0.6em, y: 0.2em), stroke: (left: 0.14em + self.colors.primary),
    breakable: false, it)
  body
}
