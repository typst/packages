#import "../utils.typ" as ambrosia-utils

#let logo-array(value) = {
  if value == none { () }
  else if type(value) == dictionary { value.values() }
  else if type(value) == array { value }
  else { panic("Logos must be none or a collection of logo content/callbacks.") }
}

// Primary marks repeat throughout a deck; partner marks normally appear only
// on its opening. A single config-info logo remains the compact default.
#let primary-logos(self, info: auto) = {
  let info = if info == auto { self.info } else { info }
  let value = self.store.primary-logos
  if value == auto { if info.logo == none { () } else { (info.logo,) } }
  else { logo-array(value) }
}

#let title-logo-groups(self, info: auto, logos: auto) = {
  let value = if logos != auto { logos } else { self.store.title-logos }
  if value == auto {
    (primary: primary-logos(self, info: info), partners: logo-array(self.store.logos))
  } else {
    let all = logo-array(value)
    // An explicit flat replacement has no role metadata. Its first entry is
    // the featured mark, matching the featured layout's existing convention.
    (primary: all.slice(0, calc.min(1, all.len())), partners: all.slice(calc.min(1, all.len())))
  }
}

// The exact cell owns the logo's bounds. Explicit dimensions and intrinsic SVG
// proportions are contained without clipping or changing the caller's image paths.
#let render-logo(self, logo, height, alignment, kind: "title") = block(width: 100%, height: height,
  above: 0em, below: 0em, breakable: false, layout(bounds => context {
    let body = box(ambrosia-utils.call-or-display(self, logo))
    let size = measure(body, width: bounds.width, height: bounds.height)
    if size.width > 0pt and size.height > 0pt {
      let factor = calc.min(100%, bounds.width / size.width * 100%, bounds.height / size.height * 100%)
      [#metadata((width: bounds.width.pt(), height: bounds.height.pt(),
        logo-width: (size.width * factor).pt(), logo-height: (size.height * factor).pt(),
        background: self.store.logo-background))#std.label("ambrosia-" + kind + "-logo")]
      box(width: bounds.width, height: bounds.height,
        std.align(alignment + horizon, scale(x: factor, y: factor, reflow: true,
          box(width: size.width, height: size.height, body))))
    }
  }))


#let logo-widths(self, logos, height, max-width) = logos.map(logo =>
  measure(box(height: height, ambrosia-utils.call-or-display(self, logo)),
    width: max-width, height: height).width)

// Measure a row at its intended height, then shrink the entire row when the
// allotted width is small. This keeps even several primary marks out of prose.
#let logo-strip(self, logos, height, max-width, alignment: right, gap: 0.5em, kind: "primary") = context {
  if logos.len() == 0 { return [] }
  let gap = gap.to-absolute()
  let max-width = max-width.to-absolute()
  let widths = logo-widths(self, logos, height, max-width)
  let natural = widths.sum() + gap * (logos.len() - 1)
  if natural <= 0pt { return [] }
  let factor = calc.min(100%, max-width / natural * 100%)
  let row = grid(columns: widths, rows: height, column-gutter: gap, align: horizon,
    ..logos.map(logo => render-logo(self, logo, height, center, kind: kind)))
  [#metadata((width: (natural * factor).pt(), limit: max-width.pt(), count: logos.len(), kind: kind))<ambrosia-logo-strip>]
  box(width: natural * factor, height: height,
    std.align(alignment + horizon, scale(x: factor, y: factor, reflow: true, row)))
}

#let render-primary-logos(self, height, max-width, alignment: right, kind: "primary") = logo-strip(self, primary-logos(self), height, max-width, alignment: alignment, kind: kind)

#let header-logo-visible(self) = (self.store.header-logo != none
  and (self.store.header-logo != auto or primary-logos(self).len() > 0))

#let render-header-logo(self, height, max-width) = {
  if not header-logo-visible(self) { return [] }
  if self.store.header-logo == auto {
    render-primary-logos(self, height, max-width, kind: "header")
  } else {
    // Callbacks, like primary collections, must respect the available width.
    logo-strip(self, (self.store.header-logo,), height, max-width, kind: "header")
  }
}

// The two groups use their natural width and share one bounded scale factor.
// The remaining flexible space separates primary marks from their partners.
#let grouped-logo-row(self, primary, partners, height, gap: 0.7em, kind: "title") = block(width: 100%, above: 0em, below: 0em, layout(bounds => context {
    let gap = gap.to-absolute()
    let natural(logos) = if logos.len() == 0 { 0pt } else {
      logo-widths(self, logos, height, bounds.width).sum() + gap * (logos.len() - 1)
    }
    let start = natural(primary)
    let end = natural(partners)
    let spacing = if primary.len() > 0 and partners.len() > 0 { gap } else { 0em }
    let total = start + end
    let factor = if total > 0pt { calc.min(1, (bounds.width - spacing) / total) } else { 1 }
    [#metadata((primary: primary.len(), partners: partners.len(), width: bounds.width.pt()))<ambrosia-logo-groups>]
    grid(columns: (start * factor, 1fr, end * factor), column-gutter: spacing / 2, align: horizon,
      logo-strip(self, primary, height, start * factor, alignment: left, gap: gap, kind: kind), [],
      logo-strip(self, partners, height, end * factor, alignment: right, gap: gap, kind: kind))
  }))

#let logo-columns(logos, definition) = {
  if logos.len() == 0 { return 1 }
  if definition.logo-columns != auto { return calc.min(logos.len(), definition.logo-columns) }
  let limit = if definition.logos-placement == "side" { 1 } else { 6 }
  // Balance overflow rows instead of leaving one orphan logo under a full row.
  calc.ceil(logos.len() / calc.ceil(logos.len() / limit))
}

#let logo-grid(self, logos, definition, height, kind: "title", primary-count: 0) = {
  if logos.len() == 0 or definition.logos-placement == "none" { return [] }
  if definition.at("logos-distribution", default: "equal") == "grouped" and definition.logos-placement != "side" {
    return grouped-logo-row(self, logos.slice(0, primary-count), logos.slice(primary-count),
      height, gap: definition.logo-gap, kind: kind)
  }
  let columns = logo-columns(logos, definition)
  grid(columns: (1fr,) * columns, column-gutter: definition.logo-gap,
    row-gutter: definition.logo-gap,
    ..logos.map(logo => render-logo(self, logo, height, definition.logos-align, kind: kind)))
}
