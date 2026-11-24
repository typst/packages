#import "./preamble.typ": *

// Title slide, shown where #bmim.title-slide() is called
#let my-title-slide(..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(margin: 0pt, header: none, footer: none),
    config-common(freeze-slide-counter: true),
  )
  let info = self.info
  // the options of bmim.slides, e.g. lang, theme, fonts, logo
  let opts = info.extra.opts
  touying-slide(self: self, grid(
    columns: (3fr, 2fr),
    rows: 100%,
    block(
      width: 100%,
      height: 100%,
      fill: self.colors.primary,
      inset: (x: 28pt, y: 32pt),
      {
        set align(left + horizon)
        set par(justify: false, leading: 0.4em)
        set text(fill: white)
        text(size: 11pt, weight: "semibold", upper(info.conference))
        v(0.6em)
        // the title is the long title, if a long and a short one are given
        text(size: 26pt, weight: "bold", (info.title,).flatten().first())
        if info.subtitle != none {
          v(0.4em)
          text(size: 15pt, info.subtitle)
        }
        line(length: 30%, stroke: 1.2pt + self.colors.highlight)
        text(size: 11pt, info.authors.join[, ])
        v(0.3em)
        text(size: 8pt, info.institution.join[\ ])
        place(bottom + left, dy: 12pt, text(size: 12pt)[
          #let (d, m, y) = (info.date.day(), translated-month(info.date, opts.lang), info.date.year())
          #if opts.lang == "de" [#d. #m #y] else [#m #d, #y], #info.location
        ])
      },
    ),
    block(width: 100%, height: 100%, clip: true, {
      image("./../assets/background_bettelwurf.jpg", width: 100%, height: 100%, fit: "cover")
      place(bottom + right, dx: -20pt, dy: -20pt, stack(
        dir: ltr,
        spacing: 14pt,
        image("./../assets/logo_lfui_color_invert.png", height: 36pt),
        // in the language of the document
        bmim.umit-logo(height: 30pt),
      ))
    }),
  ))
})

// Outline slide, shown where #bmim.outline-slide(..) is called, gets its
// arguments (cover-lvl and e.g. title)
#let my-outline-slide(cover-lvl: 1, title: none) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config-page(header: none))
  touying-slide(self: self, grid(
    columns: (1fr, 2fr),
    column-gutter: 2em,
    align: horizon,
    text(size: 32pt, weight: "bold", fill: self.colors.primary, title),
    // one row per section, the section cover-lvl is highlighted
    context {
      let sections = query(heading.where(level: 1, outlined: true))
      for (i, it) in sections.enumerate(start: 1) {
        let active = i == cover-lvl
        block(
          width: 100%,
          inset: (x: 0.6em, y: 0.5em),
          fill: if active { self.colors.primary } else { none },
          stroke: (bottom: 0.8pt + self.colors.highlight),
          link(it.location(), text(
            fill: if active { white } else { self.colors.primary },
            weight: "semibold",
          )[#i #h(0.8em) #it.body]),
        )
      }
    },
  ))
})

// Section slide, shown at each first level heading
#let my-section-slide(..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(margin: 0pt, header: none, footer: none, fill: self.colors.primary),
  )
  touying-slide(self: self, {
    set text(fill: white)
    place(left + horizon, dx: 28pt, {
      text(size: 28pt, weight: "bold", utils.display-current-heading(level: 1, numbered: false))
      v(-0.3em)
      line(length: 20%, stroke: 2pt + white)
    })
  })
})

#show: bmim.slides(
  title: (
    "Control design strategies for better results that take a quite a long title to explain what's really happening",
    "Control it better"
  ),
  subtitle: "Because reactions are bad",
  lang: "en",
  conference: "94th Conference of Applied Mathematics and Slide Care",
  institution: (
    [$zwj^(1)$Institut für Automatisierungs und Regelungstechnik, UMIT TIROL, Hall in Tirol, Österreich],
    [$zwj^(2)$Institut für Mechatronik, Universität Innsbruck, Innsbruck, Österreich],
  ),
  location: "Irgendwo",
  authors: (
    [#text(weight: "bold", size: 1.05em)[Jane Doe$zwj^(1)$]],
    [John Doel$zwj^(2)$],
    [John Doele$zwj^(2)$],
    [John Doeles$zwj^(2)$],
    [John Doel$zwj^(2)$],
    [John Doel$zwj^(2)$],
    [Max Mustermann$zwj^(1)$]
  ),
  authors-short: [Doel, Doele, Doeles, et al.],
  date: datetime(day: 31, month: 12, year: 2024),
  logo: (
    left: pad(
      top: -8.0pt,
      left: 21pt,
      image("./../assets/logo_lfui_color_invert.png", height: 30pt)
    ),
  ),
  progress-animation: (
    slides: true,
    section: true,
  ),
  title-slide: my-title-slide,
  outline-slide: my-outline-slide,
  section-slide: my-section-slide,
)

#include "content/slides.typ"
