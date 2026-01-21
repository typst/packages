// package dependancies and show rules
#import "@preview/physica:0.9.5": *
#import "@preview/wrap-it:0.1.1": *
#import "@preview/touying:0.6.1": *

#show: super-T-as-transpose

// Theme Colors
#let sea = rgb("#3b60a0")
#let sky = rgb("#bdd0f1")
#let skyl = rgb("#eff3ff")
#let skyll = rgb("#f4f9ff")
#let paper = rgb("#f5f6f8")

#let may-elements(
  doc,
  code-font: "Maple Mono",
) = [
  // Codeblocks
  #show raw: it => {
    set text(font: code-font, size: 0.9em)
    block(
      width: 100%,
      height: auto,
      fill: skyll,
      inset: 0.6em,
      radius: 0.5em,
      it
    )
  }

  // Links
  #show link: underline
  #show link: it => {
    set text(fill: sea)
    it
  }

  // Detail Decoration
  #show "->": it => [
    #math.limits(it)
  ]
  #show "-->": it => [
    #math.limits(it)
  ]
  #show "<--": it => [
    #math.limits(it)
  ]
  #show "<-": it => [
    #math.limits(it)
  ]
  #show "=>": it => [
    #math.limits(it)
  ]
  #show "==>": it => [
    #math.limits(it)
  ]
  #show "<=": it => [
    #math.limits(it)
  ]
  #show "<==": it => [
    #math.limits(it)
  ]
  #show "<=>": it => [
    #math.limits(it)
  ]
  #show "<==>": it => [
    #math.limits(it)
  ]

  // Tables
  #set table(
    stroke: none,
    gutter: 0.2em,
    align: center,
    fill: (x, y) => if y == 0 {sea},
  )
  #show table.cell: it => {
    if it.y == 0 {
    set text(paper)
    strong(it)
  } else {it}
  }

  #doc
]

#let _may(
  doc,
  font: ("Libertinus Sans", "LXGW Wenkai"),
  code-font: "Maple Mono",
  base-size: 3.56mm,
  lang: "en",
) = [
  // Font Setting
  #set text(
    font: font,
    lang: lang,
    size: base-size,
    weight: "regular",
    style: "normal",
  )

  // Page Configuration
  #set page(
    paper: "a5",
    columns: 1,
    margin: (x: 1cm, y: 1cm),
    numbering: "- 1/1 -"
  )
  #set par(
    justify: true,
  )

  // Quote / Terms
  #show ">|": it => [
    #box(baseline: 0.4em, rect(width: 0.25em, height: 1.4em, fill: sea))
    #h(0.6em)
  ]

  // Headings
  #let subline() = {v(-0.85em); line(length: 100%, stroke: sea); v(-0.2em)}
  #show heading.where(
    level: 1
  ): it => [
    #set align(center)
    #set text(
      fill: sea,
      size: 1.42em,
      weight: "bold",
      style: "normal",
    )
    #it.body
    #subline()
  ]
  #show heading.where(
    level: 2
  ): it => [
    #set text(
      fill: sea,
      size: 1.3em,
      weight: "bold",
      style: "normal",
    )
    #it.body
    #subline()
  ]
  #show heading.where(
    level: 3
  ): it => [
    #set text(
      fill: sea,
      size: 1.2em,
      weight: "bold",
      style: "normal",
    )
    #it.body
    #subline()
  ]
  #show heading.where(
    level: 4
  ): it => text(
    fill: sea,
    size: 1.1em,
    weight: "bold",
    style: "normal",
    it.body
  )
  #show heading.where(
    level: 5
  ): it => text(
    fill: sea,
    size: 1em,
    weight: "bold",
    style: "normal",
    it.body
  )
  #show heading.where(
    level: 6
  ): it => text(
    size: 1em,
    weight: "bold",
    style: "normal",
    it.body
  )

  #show: may-elements.with(code-font: "Maple Mono")

  #doc
]

#let may-serif(doc) = [
  #show: _may.with(font: ("Libertinus Serif", "LXGW Neo ZhiSong"))
  #doc
]

#let may(doc) = [
  #show: _may.with(
    font: ("Libertinus Sans", "LXGW Wenkai"),
  )
  #doc
]

#let may-sans(doc) = [
  #show: _may.with(
    font: ("Libertinus Sans", "LXGW Wenkai"),
  )
  #doc
]

// information item
#let info(something, description) = [
  *#something* #h(1fr) *#description*\
]

// Sliding Themes for Touying

#let may-slide(title: auto, ..args) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }
  // set page
  let header(self) = {
    set align(top)
    show: components.cell.with(fill: self.colors.neutral-dark, inset: 1em)
    set align(horizon)
    set text(fill: self.colors.neutral-lightest)
    set text(size: 1.3em)
    v(0.7em)
    if self.store.title != none {
      utils.call-or-display(self, self.store.title)
    } else {
      utils.display-current-heading(level: 2)
    }
    // set align(right)
    set text(fill: self.colors.primary)
    h(1fr)
    utils.display-current-heading(level: 1)
    v(-0.7em)
    line(start: (-1em, 0em), end: (100% + 1em, 0em), stroke: self.colors.neutral-dark)
  }
  let footer(self) = {
    set align(bottom)
    set text(fill: self.colors.neutral-dark, size: .7em)
    block(
      fill: self.colors.neutral-light,
      inset: (x: 0.35em, bottom: 0.35em, top: 0em),
      {
      line(start: (-0.35em, 0em), end: (100% + 0.35em, 0em), stroke: self.colors.neutral-dark)
      v(-0.7em)
      utils.call-or-display(self, self.store.footer)
      h(1fr)
      context utils.slide-counter.display() + " / " + utils.last-slide-number
    }
    )
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, ..args)
})

#let title-slide(..args) = touying-slide-wrapper(self => {
  show: touying-slides.with(
    config-page(margin: 0em)
  )
  let info = self.info + args.named()
  let body = {
    set align(center + horizon)
    block(
      fill: self.colors.neutral-dark,
      width: 100%,
      inset: (y: 1.2em),
      text(size: 2em, fill: self.colors.neutral-lightest, weight: "bold", info.title),
    )
    if info.subtitle != none {
      v(-0.9em)
      block(
        fill: self.colors.neutral-lighter,
        width: 100%,
        {
        line(length: 100%, stroke: self.colors.neutral-dark)
        v(-0.65em)
        text(size: 1.6em, fill: self.colors.neutral-dark, weight: "bold", info.subtitle)
        v(-0.65em)
        line(length: 100%, stroke: self.colors.neutral-dark)}
      )
    }
    set text(fill: self.colors.neutral-darkest)
    if info.author != none {
      block(info.author)
    }
    if info.institution != none {
      block(info.institution)
    }
    if info.date != none {
      block(utils.display-info-date(self))
    }
  }
  touying-slide(self: self, body)
})

#let new-section-slide(self: none, body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      margin: 0em,
    ),
  )
  let main-body = {
    set align(center + horizon)
    set text(size: 2em, fill: self.colors.neutral-dark, weight: "bold", style: "italic")
    line(start: (17%, 0em), length: 83%, stroke: self.colors.neutral-dark)
    v(-0.97em)
    block(
      fill: self.colors.neutral-lighter,
      inset: (y: 0.42em),
      width: 100%,
      utils.display-current-heading(level: 1)
    )
    v(-0.97em)
    line(start: (-17%, 0em), length: 83%, stroke: self.colors.neutral-dark)
  }
  touying-slide(self: self, main-body)
})

#let focus-slide(body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-dark,
      margin: 0em,
    ),
  )
  set text(fill: self.colors.neutral-lightest, size: 2em)
  touying-slide(self: self, align(horizon + center, body))
})

#let image-slide(body: none, img: none) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      background: img,
      margin: (x: 2em, y: 1.4em),
    ),
  )
  set text(fill: self.colors.neutral-dark, size: 1.4em)
  set image(width: 100%, height: auto)
  touying-slide(self: self, align(left + bottom,
    block(
      fill: self.colors.neutral-lighter,
      inset: (x: 0.4em, y: 0em),
      if body != none {
        line(start: (-0.4em, 0em), length: 100% + 0.8em, stroke: self.colors.neutral-dark)
        v(-0.85em)
        body
        v(-0.85em)
        line(start: (-0.4em, 0em), length: 100% + 0.8em, stroke: self.colors.neutral-dark)
      }
    )))
})

#let may-pre(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  ..args,
  body,
) = {
  set text(
    font: ("Libertinus Sans", "LXGW WenKai"),
    lang: "en",
    size: 7.4mm,
    weight: "regular",
    style: "normal",
  )
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 3em, x: 1em, bottom: 1.4em)
    ),
    config-common(
      slide-fn: may-slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-colors(
      primary: sky,
      neutral-light: skyl,
      neutral-lighter: skyll,
      neutral-lightest: paper,
      neutral-dark: sea,
      neutral-darkest: black,
    ),
    config-methods(
      alert: (self: none, it) => text(weight: "bold", it),
    ),
    config-store(
      title: none,
      footer: footer
    ),
    ..args,
  )

  show: may-elements

  body
}
