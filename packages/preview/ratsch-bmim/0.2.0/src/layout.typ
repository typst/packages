#import "task.typ"
#import "utils.typ": *
#import "options.typ": *
#import "slides.typ": *

#let heading-colored(it) = context {
  let opts = options.final()
  set block(
    width: 100%,
    fill: opts.theme.lolight,
    inset: 4pt,
  )
  place(hide(it))
  if it.numbering == none [
    #block(it.body)
  ] else [
    #block(counter(heading).display(it.numbering)  + h(1em) + it.body)
  ]
}

#let underline-space(fraction) = box(height: -1pt, line(length: fraction))

#let banner(..args) = {
  let opts = options.final()
  let height = if args.named().at("slide", default: false) {0.9em} else {1.5em}
  let size = args.named().at("size", default: 1em)
  box(
    width: 100%, height: height,
    fill: opts.theme.highlight,
    if args.pos().len() != 0 {
      set align(horizon)
      show text: set text(size: size, fill: opts.theme.neutral-lightest)
      pad(x:1em, ..args.pos())
    }
  )
}

#let header-colored(title:none) = context {
  let opts = options.final()
  pad(
    bottom: 0.25em,
    left: -5%,
    right: -5%,
    grid(
      columns: (5%, auto, 1fr, auto, 5%),
      banner(),
      grid.cell(
        pad(
          left: -0.6em,
          right: -0.2em,
          bottom: -0.43em,
          image("./../assets/iace.svg", height: 2.65em)
        )
      ),
      grid.cell(
        banner(title)
      ),
      align(top,
        pad(
          left: 0.2em,
          right: 0.2em,
          top: 0.72em,
          bottom: -1em,
          image(
            width: 9.55em,
            if opts.logo-with-text {
              if opts.lang == "en" {
                "./../assets/logo_umit_eng.svg"
              } else {
                "./../assets/logo_umit_de.svg"
              }
            } else {
              "./../assets/logo_umit_wo.svg"
            }
          )
        )
      ),
      banner(),
    )
  )
}

#let header-plain(course, title) = context {
  set text(size: 0.8em)
  let opts = options.final()
  let course = if type(course) == array { course.at(1) } else { course }
  let this-page = here().page()
  let head = [
    #title -- #course
  ]
  let pagenum = [
    #opts.spell.page #this-page #opts.spell.of
    #counter(page).final().first()
  ]
  if calc.odd(this-page) {
    head; h(1fr); pagenum
  } else {
    pagenum; h(1fr); head
  }
  line(length: 100%, stroke: 0.5pt)
}

#let header = (
  exam: header-colored(),
  exercise: header-colored(),
  lab: header-colored(),
  lecture: header-colored(),
  poster: header-colored(),
  report: header-colored(),
  slides: (heading: none) => context {
    let opts = options.final()
    let logo-left = if type(opts.logo) == dictionary {
      opts.logo.at("left", default: auto)
    } else {
      opts.logo
    }
    let logo-right = if type(opts.logo) == dictionary {
      opts.logo.at("right", default: auto)
    } else {
      opts.logo
    }
    set text(weight: "bold")
    pad(
      top: 0.6em,
      grid(
        columns: (7%, auto, 1fr, auto, 7%),
        banner(slide: true),
        if logo-left == auto {
          pad(
            top: -8pt,
            left: -7pt,
            right: -2pt,
            image("./../assets/iace.svg", height: 1.7em)
          )
        } else {
          logo-left
        },
        pad( x: -1pt,
          banner(slide: true, size: 0.8em, move(dy: -1.5pt, heading))
        ),
        if logo-right == auto {
          pad(
            x: 5pt,
            image("./../assets/logo_umit_de.svg", height: 1.4em)
          )
        } else {
          logo-right
        },
        banner(slide: true),
      )
    )
  },
  workbook: context {
    if page-is-chap-start() {
      none
    } else {
      header-colored()
    }
  },
)

#let footer = (
  exam: (course, title) => context {
    let opts = options.final()
    let course = if type(course) == array { course.at(1) } else { course }
    set text(size: 11pt)
    line(length: 100%, stroke: 0.5pt)
    let foot = [
      #opts.spell.exam - #course
      #if opts.show-solution != none [
        #set text(color.red, stroke: 0.5pt+color.red)
        #opts.spell.with #opts.spell.sol
      ]
    ]
    let pagenum = counter(page).display("1/1", both: true)
    if calc.odd(here().page()) and here().page() != 1 [
      #foot
      #h(1fr)
      Matrikelnr: #underline-space(25%)
      #h(1fr)
      #pagenum
    ]
    else if here().page() == 1 [
      #foot
      #h(1fr)
      #pagenum
    ] else [
      #pagenum
      #h(1fr)
      #foot
    ]
  },
  exercise: (course, title) => context {
    let opts = options.final()
    let course = if type(course) == array { course.at(1) } else { course }
    let title = if type(title) == array { title.join([ \- ]) } else { title }
    set text(size: 0.8em)
    line(length: 100%, stroke: 0.5pt)
    let foot = [
      #course - #title
      #if opts.show-solution != none [
        #set text(color.red, stroke: 0.5pt+color.red)
        #opts.spell.with #opts.spell.sol
      ]
    ]
    let pagenum = counter(page).display("1")
    if calc.odd(here().page()) {
      foot; h(1fr); pagenum
    } else {
      pagenum; h(1fr); foot
    }
  },
  lab: (course, title) => context {
    let opts = options.final()
    let course = if type(course) == array { course.at(1) } else { course }
    let title = if type(title) == array { title.join([ \- ]) } else { title }
    set text(size: 0.8em)
    line(length: 100%, stroke: 0.5pt)
    let foot = [
      #opts.spell.lab - #course - #title
      #if opts.show-solution != none [
        #set text(color.red, stroke: 0.5pt+color.red)
        #opts.spell.with #opts.spell.sol
      ]
    ]
    let pagenum = counter(page).display("1")
    if calc.odd(here().page()) {
      foot; h(1fr); pagenum
    } else {
      pagenum; h(1fr); foot
    }
  },
  lecture: () => context {
  },
  poster: (event,date,location,contact, ..args) => context {
    set text(font: "CMU Typewriter Text")
    let opts = options.final()
    // let ext = 5%
    let ext = 0.4em+1pt
    pad(
      left: -ext,
      right: -ext,
      grid(
        columns: (ext, 2fr, 1fr, ext),
        align: (auto, left, right, auto),
        column-gutter: -1pt,
        banner(),
        banner([#event, #print-date(date), #location]),
        banner([#contact]),
        banner(),
      )
    )
  },
  report: (course, title) => context {
    align(
      if calc.odd(here().page()) { right } else {left},
      counter(page).display("1")
    )
  },
  slides: (author:none, title:none, date:none, pagenum:none) => context {
    let opts = options.final()
    block(
      [
        #block(
          inset: (bottom: -3em),
          components.progress-bar(height: 1.75em, rgb(200, 183, 118).lighten(80%), white)
        )
        #box(
          stroke: opts.theme.highlight,
          inset: (x: 2em, top: -0.3em ,bottom: 0.5em),
          grid(
            columns: (25%, 50%, 1fr, 5em),
            align: (left, auto, center, right),
            rows: 1.5em,
            author,
            title,
            if opts.lang == "de" {
              [#date.day(). #translatedMonth(date, opts.lang) #date.year()]
            } else {
              [#translatedMonth(date, opts.lang) #date.day(), #date.year()]
            },
            pagenum,
          ),
        )
      ]
    )
  },
  workbook: (course) => context {
    let opts = options.final()
    let course = if type(course) == array { course.at(1) } else { course }
    set text(size: 11pt)
    line(length: 100%, stroke: 0.5pt)
    let foot = [
      #course - Übungsaufgaben
    ]
    let pagenum = counter(page).display("1")
    if calc.odd(here().page()) and here().page() != 1 [
      #foot
      #h(1fr)
      #pagenum
    ]
    else if here().page() == 1 [
      #foot
      #h(1fr)
      #pagenum
    ] else [
      #pagenum
      #h(1fr)
      #foot
    ]
  },
)

#let titleblock = (
  exam:     (course, title, authors, date, total-time, show-hints) => context {
    let opts = options.final()
    let course = if type(course) == array { course.at(0) } else { course }

    [
      #set align(center)

      *#title - #course*
    ]
    v(1em)
    grid(
      columns: (2fr, 1fr),
      gutter: 0.5em,
      align: (right, left),
      strong[
        #opts.spell.on #date.day(). #translatedMonth(date, opts.lang)
        #date.year(), #opts.spell.ho:
      ],
      grid(
        row-gutter: 0.5em,
        ..authors.map(author => strong(author)),
      ),
    )
    v(1.25em)
    grid(
      columns: (1fr, 1fr),
      gutter: 0.5em,
      align: (right, left),
      [
        Name: #underline-space(73%) #h(2em)
      ],
      [
        Matrikelnummer: #underline-space(50%)
      ],
    )
    v(1.25em)

    let tableData = (
      {
        strong(opts.spell.eval)
        task.points-table
      },
      if show-hints {
        {
          set list(spacing: 1.3em)
          set text(size: 10pt)
          [
            *Hinweise*
            #v(0.75em)
            #pad(left: 1.4em)[
              - Die Prüfung umfasst #context task.total-count() Aufgaben, die Bearbeitungszeit beträgt #total-time.
              - Es können insgesamt #context task.total-points() Punkte erreicht werden.
              - Zugelassene Hilfsmittel:
                - *ein handschriftlich* beschriebener A4 Zettel; *Muss* am Ende der Klausur abgegeben werden.
                - *keine* weiteren Unterlagen
                - *keine* elektronischen Geräte
              - Bitte schreiben Sie *leserlich* und geben Sie den *Lösungsweg* vollständig an.
              - Schreiben Sie *nicht* mit Bleistift und *nicht* mit Rotstift.
            ]
          ]
        }
      }
    )
    v(1.25em)
    table(
      inset: 0.5em,
      gutter: 0.5em,
      stroke: 0.5pt,
      align:left,
      ..tableData.filter(x => x != none)
    )
  },
  exercise: (course, title, authors, date) => context {
    let opts = options.final()
    let course = if type(course) == array { course.at(0) } else { course }

    [
      #set align(center)

      *#title - #course*
    ]
    v(1em)
    grid(
      columns: (2fr, 1fr),
      gutter: 0.5em,
      align: (right, left),
      strong[
        #opts.spell.on #date.day(). #translatedMonth(date, opts.lang)
        #date.year(), #opts.spell.ho:
      ],
      grid(
        row-gutter: 0.5em,
        ..authors.map(author => strong(author)),
      ),
    )
  },
  lab:      (course, title, authors, date) => context {
    let course = if type(course) == array { course.at(0) } else { course }
    let opts = options.final()
    set align(center)
    rect(
      width: 100%,
      inset: (top: 0.2em, bottom: 0.2em, left: 0.2em, right: 0.2em),
      stroke: 1pt,
      rect(
        width: 100%,
        inset: (top: 1em, bottom: 1em),
        stroke: (paint: black.lighten(20%), thickness: 1.3pt),
        strong[
          #opts.spell.lab \
          #sym.hyph \
          #course \
          #line(length: 95%)
          #if type(title) == array {
            title.at(0)
            linebreak()
            title.at(1)
          } else {
            title
          }
        ]
      )
    )
    grid(
      columns: 2,
      gutter: 0.75em,
      align: (right, left),
      [
        #if opts.show-solution != none {
          set text(color.red)
          strong[
            #opts.spell.with #opts.spell.sol,
          ]
        }
        #opts.spell.ho:
      ],
      grid(
        row-gutter: 0.5em,
        ..authors.map(author => text(author)),
      ),
      [
        #opts.spell.lc:
      ],
      [
        #let curDate = datetime.today()
        #curDate.day(). #translatedMonth(curDate, opts.lang) #curDate.year()
      ],
    )
  },
  lecture: () => context {
  },
  poster:   (title, authors) => context {
    place(top+center, float: true, scope: "parent",[
      #text(1.4em, strong(title))\
      #authors.join([\ ])
    ])
  },
  report:   (course, title, authors, date) => context place(
    top, float: true, scope: "parent",
    block(inset: (top: 2em, bottom: 1em), {
      set par(spacing: 1em)
      let opts = options.final()
      let title = text(opts.theme.highlight, 2em, strong(title))
      let w = measure(title).width
      title
      line(length: w+0.5em, stroke: 1pt)
      authors.join(", ")
      par[#opts.spell.date: #print-date(date)]
      line(length: w+0.5em, stroke: 3pt)

    })
  ),
  slides: () => context {},
  workbook: (course, authors, date) => context {
    let opts = options.final()
    let course = if type(course) == array { course.at(0) } else { course }
    set align(center+horizon)
    set par(spacing: 3em)

    [
      #smallcaps[
        #set text(1.3em)
        Übungsaufgaben zur Lehrveranstaltung
      ]

      #{
        set text(1.5em)
        strong(course)
      }

      #{
        set text(1.3em)
        authors.map(smallcaps).join([, ])
      }
      #par[]
      #par[]
      #[
        #set text(1.1em)
        Institut für Automatisierungs- und Regelungstechnik

        #grid(
          columns: (auto, auto),
          grid.cell(
            pad(
              left: -0.6em,
              right: -0.2em,
              image("./../assets/iace.svg", height: 2.65em)
            )
          )
        )
      ]
      #print-date(date)
    ]
    pagebreak(to: "odd")
  },
)

#let poster-box(heading, content, height:none) = context {
  let opts = options.final()
  show std.heading.where(level:1): it => {
    let opts = options.final()
    set text(fill: opts.theme.neutral-lightest, size: 0.8em)
    set align(center)
    set block(
      width: 100%,
      outset: 0.4em,
      fill: opts.theme.highlight,
      radius: (
        top: 0.4em
      ),
    )
    it
  }
  std.heading(heading)
  block(
    width: 100%,
    height: if height == none { auto } else { height },
    outset: (x:0.4em, y: 0.2em),
    inset: (x: 0.4em, y:0.2em),
    fill: opts.theme.highlight.lighten(90%),
    stroke: opts.theme.highlight + 0.1em,

    content
  )
}

#let solution-box(sol) = {
  block(
    // stroke:0.5pt,
    width: 100%,
    fill: color.red.lighten(0%),
    inset: 2pt,
    box(
      stroke:0.5pt,
      width: 100%,
      fill: white,
      inset: 0.3em,
      sol,
    ),
  )
}

#let slides-quote(it, quotes, outset: 0.5em) = {
  box(
    fill: luma(220),
    outset: outset,
    width: 100%,
    quotes.at(0) + it.body + quotes.at(1)
    + if it.attribution != none {
      set text(size: 0.8em)
      linebreak()
      h(1fr)
      it.attribution
    },
  )
}
