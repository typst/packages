#import "@preview/touying:0.5.3": *

#import "brand.typ": colour
#import "outline.typ": lineal-outline
#import "progress.typ": lineal-progress-bar

#let multicolumns(columns: auto, alignment: top, gutter: 1em, ..bodies) = {
  let bodies = bodies.pos()
  if bodies.len() == 1 {
    return bodies.first()
  }
  let columns = if columns == auto {
    (1fr,) * bodies.len()
  } else {
    columns
  }
  grid(columns: columns, gutter: gutter, align: alignment, ..bodies)
}

#let _typst-builtin-align = align



#let slide(
  title: auto,
  align: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto {
    self.store.align = align
  }
  // restore typst builtin align function
  let align = _typst-builtin-align
  let header(self) = {
    set align(top)
    show: components.cell.with(inset: (x: 2em))
    set align(bottom)
    components.left-and-right(
      text(
        fill: self.colors.primary,
        weight: "bold",
        size: 1em,
        if title != auto {
          utils.fit-to-width.with(grow: false, 100%, title)
        } else {
          utils.call-or-display(self, self.store.header)
        }
      ),
      text(
        fill: self.colors.primary,
        weight: "bold",
        size: 0.6em,
        utils.call-or-display(self, self.store.header-right)
      ),
    )
    
  }
  let footer(self) = {
    set align(bottom)
    set text(size: 0.8em)
    show: components.cell.with(inset: (x: 2em, y: -1em))
    if self.store.footer-progress {
      box(width: 100%)[
        #lineal-progress-bar(variant: "exact", accent: self.colors.primary, remaining: self.colors.primary-light)
      ]
    }
    show: components.cell.with(inset: (y: 2em))
    components.left-and-right(
      text(fill: self.colors.neutral-darkest.lighten(40%), utils.call-or-display(self, self.store.footer-left)),
      text(fill: self.colors.neutral-darkest, utils.call-or-display(self, self.store.footer-right)),
    )
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-lightest,
      header: header,
      footer: footer,
    ),
  )
  let new-setting = body => {
    show: align.with(self.store.align)
    set text(fill: self.colors.neutral-darkest)
    show heading.where(level: self.slide-level + 1): it => {
      stack(
        dir: ltr, spacing: .4em,
        square(size: .35em, fill: self.colors.primary),
        text(fill: self.colors.primary, it.body)
      )
    }
    set enum(numbering: (nums) => {
      text(fill: self.colors.primary, weight: "bold", str(nums) + ".")
    })
    set list(marker: (level) => {
      place(dy: 2pt, square(fill: self.colors.primary, radius: 1.5pt, size: 8pt))
      h(.5em)
    })
    set table(stroke: self.colors.primary)
    show: setting
    block(inset: (bottom: 1em), body)
  }
  let composer = if composer == auto { multicolumns } else { composer }
  touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: composer, ..bodies)
})



#let new-section-slide(level: 1, numbered: true, body) = touying-slide-wrapper(self => {
  let slide-body = {
    set align(horizon)
    show: pad.with(left: 5%, right: 10%)

    lineal-outline(
      title: none,
      filter: hd => hd.relation != none and not hd.relation.unrelated,
      depth: 2,
      transform: (hd, it) => {
        set text(size: 1.25em, fill: self.colors.primary, weight: "bold") if hd.relation != none and hd.relation.same
        set text(fill: self.colors.primary) if hd.relation != none and hd.relation.child
        set text(fill: text.fill.transparentize(60%)) if hd.relation != none and hd.relation.sibling

        // Extract just the heading text without numbering
        let heading-text = hd.heading.body
        heading-text
      }
    )
    
    body
  }
  self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lightest),
  )
  touying-slide(self: self, slide-body)
})



#let focus-slide(align: horizon + center, body) = touying-slide-wrapper(self => {
  let _align = align
  let align = _typst-builtin-align
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.neutral-lightest, margin: 2em),
  )
  set text(fill: self.colors.primary, size: 1.5em)
  touying-slide(self: self, align(_align, body))
})



#let lineal-theme(
  aspect-ratio: "16-9",
  align: horizon,
  header: self => utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%), depth: self.slide-level),
  logo: auto,
  header-right: context utils.slide-counter.display() + " / " + utils.last-slide-number,
  footer-left: self => pad(self.info.logo, y: -.2em),
  footer-right: self => self.info.title,
  footer-progress: true,
  ..args,
  body,
) = {
  let logo-config = if logo == auto { () } else { (config-info(logo: logo),) }
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 30%,
      footer-descent: 30%,
      margin: (top: 3em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(size: 20pt)
        show highlight: body => text(fill: self.colors.primary, strong(body.body))
        body
      },
      alert: utils.alert-with-primary-color
    ),
    config-colors(..colour),
    // save the variables for later use
    config-store(
      align: align,
      header: header,
      header-right: header-right,
      footer-left: footer-left,
      footer-right: footer-right,
      footer-progress: footer-progress,
    ),
    config-info(
      datetime-format: "[day] [month repr:short] [year]"
    ),
    ..args,
    ..logo-config,
  )
  body
}
