#import "@preview/touying:0.7.1": *
#import "colors.typ": *
#import "data.typ": *
#import "utils.typ": translatedMonth
#import "options.typ": options

#let title-slide(
  ..args,
) = touying-slide-wrapper(self => {
  let opts = options.final()
  let new-config = utils.merge-dicts(
    opts,
    config-page(
      footer: none,
      margin: (top: 4em, left: 1em),
    ),
    config-common(freeze-slide-counter:true),
  )

  self = utils.merge-dicts(self, new-config)

  let authors = (self.info.authors,).flatten()
  let title = (self.info.title,).flatten()
  let subtitle = self.info.subtitle
  let institution = self.info.institution
  let conference = self.info.conference
  let location = self.info.location
  let date = self.info.date

  let bold(size, body) = strong(text(size: size, body))

  let body = {
    set align(center + horizon)
    set text(fill: self.colors.primary)
    v(-3.0em)
    block(
      fill: self.colors.background,
      inset: 1.5em,
      radius: 0.5em,
      breakable: false,
      {
        bold(1.75em, title.at(0, default:none))
        if subtitle != none {
          parbreak()
          bold(1.0em, subtitle)
        }
      },
    )
    v(0.5em)
    // authors
    grid(
      columns: (1fr,) * calc.min(authors.len(), 3),
      column-gutter: 1em,
      row-gutter: 1em,
        ..authors.enumerate().map(((idx, author)) => {
          author
        }
      )
    )
    v(1em)
    // institution
    if institution != none {
      parbreak()
      text(size: 0.7em, institution)
    }
    v(1em)
    // conference
    if conference != none {
      parbreak()
      text(size: 1.0em, conference)
      linebreak()
    }
    let locStr = ""
    if location != none {
      locStr = [, #location]
    }
    // date
    if date != none {
      if conference == none {
        parbreak()
      }
      text(size: 1.0em,
        if opts.lang == "de" {
          [#date.day(). #translatedMonth(date, opts.lang) #date.year()#locStr]
        } else {
          [#translatedMonth(date, opts.lang) #date.day(), #date.year()#locStr]
        }
      )
    }
  }

  touying-slide(self: self, body)
})

#let outline-slide(
  ..args,
) = touying-slide-wrapper(self => {
  let opts = options.final()
  let new-config = utils.merge-dicts(
    opts,
    config-page(
      margin: (top: 2em, left: 1em),
      header: none,
      footer: none,
      background:
        place(image("./../assets/bg-umit.jpg"))
        + box(fill: self.colors.primary.transparentize(45%).lighten(75%), height:100%, width: 100%)
    ),
  )

  self = utils.merge-dicts(self, new-config)

  let body = {
    show: align.with(horizon)
    show outline.entry.where(level: 1): it => {
      let style(entry) = block(
          fill: gradient.linear(
            self.colors.primary,
            self.colors.primary.transparentize(100%),
            relative: "parent",
          ),
          width: 100%,
          inset: 6pt,
          strong(text( fill: white, entry ))
        )
      link(it.element.location(), style( it.body() ))
      v(1em)
    }

    pad(x: 5em, outline(depth: 1, ..args))
  }

  touying-slide(self: self, body)
})

#let new-section-slide(
  level: 1,
  numbered: true,
  ..args,
) = touying-slide-wrapper(self => {
  let opts = options.final()
  let new-config = utils.merge-dicts(
    opts,
    config-page(
      margin: 0pt,
      header: none,
      footer: none,
      background:
        place(image("./../assets/bg-umit.jpg"))
        + box(fill: self.colors.primary.transparentize(45%).lighten(75%), height:100%, width: 100%)
    ),
  )

  self = utils.merge-dicts(self, new-config)
  self.store.title = ""

  let body = {
    set text(size: 1.5em, fill: self.colors.neutral-lightest, weight: "bold")
    v(-4em)
    block(
      width: 100%,
      fill: gradient.linear(
        self.colors.primary,
        self.colors.primary.transparentize(100%),
        relative: "parent",
      ),
      inset: (x: 2em, y: .8em),
      utils.display-current-heading(level: level, numbered: numbered)
    )
  }

  touying-slide(self: self, body)
})
