#import "@preview/touying:0.7.4": *

#let default-accent = rgb("#087A5C")
#let body-color = rgb("#17241F")
#let code-fill = rgb("#F4F5F4")
#let sans-fonts = ("Pretendard GOV",)
#let serif-fonts = ("RIDIBatang",)
#let code-fonts = ("D2Coding",)

#let weighted(mode, level, body) = {
  if mode == "serif" {
    let width = if level == "bold" { .20pt } else { .12pt }
    text(fill: body-color, stroke: width + body-color, body)
  } else {
    text(weight: if level == "bold" { "bold" } else { "semibold" }, body)
  }
}

#let _content-slide(title: auto, ..args) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }

  let header(self) = {
    set text(fill: body-color, size: 30pt)
    if self.store.title != none {
      weighted(self.store.mode, "bold", utils.call-or-display(self, self.store.title))
    } else {
      weighted(self.store.mode, "bold", utils.display-current-heading(level: 2))
    }
    line(length: 100%, stroke: .8pt + self.colors.primary)
  }

  let footer(self) = {
    set text(fill: body-color, size: 10pt)
    utils.display-current-heading(level: 1)
    h(1fr)
    context utils.slide-counter.display()
  }

  self = utils.merge-dicts(
    self,
    config-page(header: header, footer: footer, header-ascent: 30%),
  )
  set text(size: 22pt)
  touying-slide(self: self, ..args)
})

#let title-slide(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = [
    #if info.logo != none {
      place(top + right, utils.call-or-display(self, info.logo))
    }
    #align(left + horizon)[
      #text(size: 46pt)[#weighted(self.store.mode, "bold", info.title)]
      #v(1.2em)
      #line(length: 12%, stroke: 2pt + self.colors.primary)
      #v(1.2em)
      #if info.author != none { block(info.author) }
      #if info.institution != none { block(info.institution) }
      #if info.date != none { block(utils.display-info-date(self)) }
    ]
  ]
  touying-slide(self: self, body)
})

#let new-section-slide(self: none, body) = touying-slide-wrapper(self => {
  let content = align(left + horizon)[
    #text(size: 10pt, fill: self.colors.primary)[SECTION]
    #v(.8em)
    #text(size: 38pt)[
      #weighted(self.store.mode, "bold", utils.display-current-heading(level: 1))
    ]
  ]
  touying-slide(self: self, content)
})

#let focus-slide(body) = touying-slide-wrapper(self => {
  touying-slide(
    self: self,
    align(left + horizon, text(size: 38pt, fill: body-color, body)),
  )
})

#let _callout(self: none, kind, title, body) = {
  let is-warning = kind == "warning"
  let left-stroke = if is-warning {
    (paint: body-color, thickness: 3pt, dash: "dashed")
  } else {
    3pt + self.colors.primary
  }
  block(
    width: 100%,
    fill: code-fill,
    stroke: (left: left-stroke),
    inset: (x: 1em, y: .7em),
  )[
    #text(size: .75em)[#weighted(self.store.mode, "semibold", title)]
    #linebreak()
    #body
  ]
}

#let callout(kind, title, body) = {
  assert(
    ("info", "warning").contains(kind),
    message: "callout kind must be either \"info\" or \"warning\"",
  )
  touying-fn-wrapper-raw(_callout, kind, title, body)
}

#let info(title: [정보], body) = callout("info", title, body)
#let warning(title: [주의], body) = callout("warning", title, body)

#let ling-theme(
  mode: "sans",
  accent: default-accent,
  aspect-ratio: "16-9",
  title: none,
  author: none,
  institution: none,
  date: none,
  logo: none,
  ..args,
  body,
) = {
  assert(
    ("sans", "serif").contains(mode),
    message: "mode must be either \"sans\" or \"serif\"",
  )

  let proportional-fonts = if mode == "serif" { serif-fonts } else { sans-fonts }
  set text(
    font: proportional-fonts,
    size: 22pt,
    fill: body-color,
    lang: "ko",
    cjk-latin-spacing: auto,
  )
  set par(
    justify: false,
    leading: if mode == "serif" { .45em } else { .35em },
  )
  show raw: set text(font: code-fonts, size: .78em, ligatures: false)
  show raw.where(block: true): it => block(
    width: 100%,
    fill: code-fill,
    inset: .8em,
    radius: 0pt,
    it,
  )
  show strong: it => weighted(mode, "semibold", it.body)
  show quote: set block(stroke: (left: 1.2pt + accent), inset: (left: 1em))
  show link: set text(fill: accent)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      fill: rgb("#FFFFFF"),
      margin: (top: 4em, bottom: 1.8em, x: 2.2em),
    ),
    config-colors(primary: accent),
    config-common(
      slide-fn: _content-slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-store(title: none, mode: mode),
    config-info(
      title: title,
      author: author,
      institution: institution,
      date: date,
      logo: logo,
    ),
    ..args,
  )

  body
}
