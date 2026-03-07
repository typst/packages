#import "@preview/touying:0.6.2": *

#let get-month-name(month) = {
  let months = (
    "Januar",
    "Februar",
    "März",
    "April",
    "Mai",
    "Juni",
    "Juli",
    "August",
    "September",
    "Oktober",
    "November",
    "Dezember"
  )
  return months.at(month - 1)
}

#let outlineShown = counter("outlineShown")
#let sourcesShown = counter("sourcesShown")

#let logo(content, h) = box(height: h)[
  #align(center + horizon)[#content]
]

#let display-date(date: datetime.today(), useCustomDate: false) = {
  if useCustomDate {
    return date
  }
  return str(date.day()) + ". " + get-month-name(date.month()) + " " + str(date.year())
}

#let headerOutline(self) = {
  context {
    set par(
      spacing: .3cm
    )
    set text(size: .5cm)
    let chapters = query(
      heading.where(
        level: 1,
        outlined: true,
      )
    )

    let slides_per_chapter = chapters.enumerate().map((enum) => {
      let i = enum.first()
      let ch = enum.last()
      let start = ch.location()

      let next_ch = if i + 1 < chapters.len() {
        chapters.at(i + 1)
      } else {
        none
      }

      let slides = if next_ch == none {
        query(
          heading.where(level: 2).after(start)
        )
      } else {
        query(
          heading
          .where(level: 2)
          .after(start)
          .before(next_ch.location())
        )
      }

      slides
    })

    let slideCounts = chapters.map(c => {
      let loc = c.location()
      numbering(
        loc.page-numbering(),
        ..counter(page).at(loc),
      )
    })
    for i in range(slideCounts.len()) {
      if chapters.at(i).body == [#self.store.sourcesTitle] {
        slideCounts.at(i) = -1
      } else {
        if i == slideCounts.len() - 1 {
          slideCounts.at(i) = counter(page).final().at(0) - int(slideCounts.at(i))
        } else {
          slideCounts.at(i) = int(slideCounts.at(i + 1)) - int(slideCounts.at(i))
        }
      }
    }
    slideCounts = slideCounts.filter(n => n > 0)
    chapters = chapters.filter(c => c.body != [#self.store.sourcesTitle])

    let tmp = ()
    let t = if int(outlineShown.display()) > 0 {2} else {1}
    for (i, sc) in slideCounts.enumerate() {
      tmp.push(range(t, t + int(sc)))
      t += int(sc)
    }
    slideCounts = tmp

    let all_lvl1 = query(heading.where(level: 1))
    let curr_page = here().page()
    let currentchapter = all_lvl1
    .filter(h => h.location().page() <= curr_page)
    .last(default: none)

    let space-between(items) = {
      box(width: 100%)[
        #for i in range(items.len()) {
          items.at(i)
          if i < items.len() - 1 { h(1fr) }
        }
      ]
    }
    space-between(
      range(chapters.len()).map(i => {
        let color = if currentchapter != none and chapters.at(i).body == currentchapter.body {black} else {gray}
        [
          #box()[
            #link(chapters.at(i).location(),
            [
              #align(left)[
                #text(fill: color, chapters.at(i).body)
              ]
            ]
          )
          #grid(
            columns: slides_per_chapter.at(i).len(),
            gutter: 3pt,
            ..slides_per_chapter.at(i).zip(slideCounts.at(i)).map(zipped => {
              let slide = zipped.first()
              let c = zipped.last()
              let target = slide.location()
              link(
                target,
                [
                  #circle(
                    radius: .1cm,
                    stroke: color,
                    fill: if c == int(utils.slide-counter.display()) {color} else {none}
                  )
                ]
              )
            })
          )
    ]
  ]
})
    )


  }
}

#let footer(self) = {
  set align(bottom)
  show: pad.with(1cm)
  set text(fill: self.colors.neutral-darkest, size: .5em)
  grid(
    columns: (.9cm, .1cm, 1fr, 4cm),
    align: left,
    gutter: 5pt,
    place(right, [
      #text(size: 1cm, context utils.slide-counter.display())
    ]),
    line(start: (0%, 0%), angle: 90deg, length: .7cm, stroke: .5pt + rgb("#808080")),
    [
      #text(size: .3cm, self.store.authors.join(", ") + ",")
      #text(size: .3cm, display-date(date: self.store.date, useCustomDate: self.store.customDate)) \
      #link((page: 1, x: 0pt, y: 0pt), text(size: .3cm, self.store.presentationTitle
        + if self.store.subtitle != none [ \- #self.store.subtitle] else []
      ))
    ],
    place(right, [#logo(self.store.logoInstitution, .7cm)])
  )
}

#let header(self, colorizeEdges: true, title: none) = {
  set align(top)
  show: components.cell.with(inset: 1em)
  headerOutline(self)
  grid(
    columns: (1cm, 1fr, 1cm),
    rows: 2cm,
    align: left + horizon,
    gutter: .5cm,
    fill: (
      if colorizeEdges {rgb(self.colors.primary)} else {none},
      none,
      if colorizeEdges {rgb(self.colors.primary)} else {none},
    ),
    [],
    {
      strong(
        if title != none {
          [#title]
        }
        else {
          if self.store.title != none {
            set text(fill: self.colors.neutral-darkest, size: 1cm)
            utils.call-or-display(self, self.store.title)
          } else {
            set text(fill: self.colors.neutral-darkest, size: 1cm)
            utils.display-current-heading(level: 2)
          }
        }
      )
    },
    []
  )
}

#let slide(title: auto, ..args) = touying-slide-wrapper(self => {
  set list(marker: ([
    #set text(fill: self.colors.primary)
    –
  ]))
  set text(font: self.store.font, weight: "light", size: 20pt)
  if title != auto {
    self.store.title = title
  }
  set align(horizon)
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, ..args)
})

#let headerTitleSlide(self) = {
  set align(top)
  show: components.cell.with(inset: 1cm)
  grid(
    columns: (1fr, 2fr, 1fr),
    fill: none,
    logo(self.store.logoInstitution, 1.2cm),
    [],
    logo(self.store.logoFaculty, 1.2cm),
  )
}

#let footerTitleSlide(self) = {
  set text(fill: self.colors.neutral-darkest, size: 25pt)
  show: components.cell.with(inset: 2cm)
  grid(
    columns: (1fr, 1fr),
    rows: 10cm,
    {
      set par(
        spacing: 0.5em,
      )
      set align(left + horizon)
      if self.store.date != none {
        block(display-date(date: self.store.date, useCustomDate: self.store.customDate))
      }
      if self.store.authors-title-slide != none {
        block(self.store.authors-title-slide)
      }
    },
    [
      #set align(right + horizon)
      #self.store.institution
    ]
  )
}

#let htwk-title-slide(..args) = touying-slide-wrapper(self => {
  let info = self.store + args.named()
  let body = {
    set text(font: self.store.font, weight: "light", size: 20pt)
    set align(center + horizon)
    text(size: 2em, fill: self.colors.neutral-darkest, weight: "bold", info.presentationTitle)
    if info.subtitle != none {
      linebreak()
      text(size: 1em, fill: self.colors.neutral-darkest, weight: "bold", info.subtitle)
    }
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: headerTitleSlide,
      footer: footerTitleSlide
    ),
  )
  let margin = (x: 4em, y: 2em)
  let negative-padding = pad.with(x: -margin.x, y: 0em)
  set page(
    paper: "presentation-" + self.store.aspect-ratio,
    header: headerTitleSlide(self),
    header-ascent: 0em,
    footer: footerTitleSlide(self),
    footer-descent: -8cm,
    background: {
      move(
        dx: 1cm,
        dy: 5cm,
        grid(
          columns: (1fr, 1fr),
          rotate(
            -16deg,
            rect(fill: self.colors.primary, width: 6cm, height: 100%)
          ),
          rotate(
            -16deg,
            rect(fill: self.colors.primary, width: 6cm, height: 100%)
          )
        )
      )
    }
  )
  let container = rect.with(stroke: (dash: "dashed"), height: 100%, width: 100%, inset: 0pt)
  let innerbox = rect.with(fill: rgb("#d0d0d0"))
  body
})

#let htwk-outline(
  title: "Inhalt",
  ..args) = touying-slide-wrapper(self => {
    outlineShown.step()
    set text(font: self.store.font, weight: "light", size: 20pt)
    set outline.entry(fill: none)
    set text(fill: self.colors.neutral-dark)
    show outline.entry.where(level: 1): it => {
      if it.body() == [#self.store.sourcesTitle] {
        []
      } else {
        [
          + #link(
            it.element.location(),
            it.indented(it.prefix(), it.body()),
          )

        ]
      }
    }
    let body = {
      show: components.cell.with(inset: -1em)
      show: pad.with(y: 1cm)
      grid(
        columns: (1cm, 1fr, 1cm),
        rows: 10cm,
        align: left + top,
        gutter: .5cm,
        fill: (rgb(self.colors.primary), none, rgb(self.colors.primary)),
        [],
        {
          move(dy: .5cm, components.adaptive-columns(
            [
              #outline(title: none, depth: 1)
            ]
          ))
        },
        []
      )
    }
    let headerWithoutColoredBars(self) = header(self, colorizeEdges: false, title: [
      #set text(fill: self.colors.neutral-darkest, size: 1cm)
      #utils.call-or-display(self, title)
    ])
    self = utils.merge-dicts(
      self,
      config-page(
        header: headerWithoutColoredBars,
        footer: footer,
      ),
    )
    touying-slide(self: self, align(top, body), ..args)
  })

  #let htwk-sources(title: "Quellen", content) = {
    [
      = #title
      == #title
      #content
    ]
  }

  #let htwk-stripes-theme(
    title: "",
    subtitle: "",
    authors: (),
    authors-title-slide: [],
    customDate: false,
    date: datetime.today(),
    institution: "",
    aspect-ratio: "4-3",
    font: "Libertinus Serif",
    primaryColor: rgb("#009ee3"),
    textColorDark: rgb("#000000"),
    logoInstitution: none,
    logoFaculty: none,
    sourcesTitle: "Quellen",
    ..args,
    body,
  ) = {
    show: touying-slides.with(
      config-page(
        paper: "presentation-" + aspect-ratio,
        margin: (top: 6em, bottom: 2em, x: 2em),
      ),
      config-common(
        slide-fn: slide,
      ),
      config-methods( alert: utils.alert-with-primary-color ),
      config-colors(
        primary: primaryColor,
        neutral-darkest: textColorDark,
      ),
      config-store(
        title: none,
        footer: footer,
        font: font,
        aspect-ratio: aspect-ratio,
        logoInstitution: logoInstitution,
        logoFaculty: logoFaculty,
        sourcesTitle: sourcesTitle,
        presentationTitle: title,
        subtitle: subtitle,
        authors: authors,
        authors-title-slide: authors-title-slide,
        customDate: customDate,
        date: date,
        institution: institution,
      ),
      ..args,
    )

    body
  }
