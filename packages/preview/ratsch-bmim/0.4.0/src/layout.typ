#import "task.typ"
#import "utils.typ": *
#import "options.typ": *
#import "slides.typ": *


#let heading-colored(it) = context {
  let opts = options.final()
  block(
    width: 100%,
    inset: (bottom: 5pt),
    [
      #if it.numbering == none [#it.body] else [#counter(heading).display(it.numbering) #it.body]
      #place(bottom+left, dy: 5pt, line(length: 33%, stroke: 0.1em + opts.theme.primary))
    ]
  )
}

#let underline-space(fraction) = box(height: -1pt, line(length: fraction))

#let banner(..args) = {
  let opts = options.final()
  let height = if args.named().at("slide", default: false) {0.5em} else {1.5em}
  let size = args.named().at("size", default: 1em)
  let all-sections = query(outline.entry.where(level: 1))
  let current-section = utils.current-heading(level: 1)
  show text: set text(size: size, fill: opts.theme.background)
  let showAni = args.named().at("progressAnimation", default: false)

  grid(
    columns: if args.named().at("slide", default: false) and showAni {(auto, 1fr)} else {(auto)},
    gutter: 1pt,
    grid.cell(
      box(
        width: if args.named().at("slide", default: false) and showAni {80%} else {100%},
        height: height,
        if args.pos().len() != 0 {
          set align(if showAni { horizon+left } else { horizon+center })
          show text: set text(size: size, fill: opts.theme.background)
          pad(x: 15pt, {pad(..args.pos())})
        }
      )
    ),
    if args.named().at("slide", default: false) and showAni {
      grid.cell(
        box(
          width: 100%,
          height: height,
          align(horizon+center)[
            #stack(
              dir: ltr,
              spacing: 10pt,
              ..all-sections.enumerate().map(((idx, sec)) => {
                let is-current = sec.element.location() == current-section.location()

                let dot = if is-current {
                  circle(radius: 3.5pt, stroke: 1pt + gray.lighten(20%), fill: gray.lighten(20%))
                } else {
                  circle(radius: 3.5pt, stroke: 1pt + gray.lighten(20%), fill: none)
                }
                dot
              })
            )
          ]
        )
      )
    }
  )
}

#let header-colored(title:none) = context {
  let opts = options.final()
  pad(
    top: page.margin.top * 0.3,
    left: -page.margin.left * 0.4,
    rect(
      fill: opts.theme.primary,
      width: 100% + page.margin.left * 0.4,
      height: 80%,
    )
  )
  pad(
    top: page.margin.top * 0.3,
    left: -page.margin.left * 0.4,
    grid(
      columns: (auto, 1fr, auto),
      grid.cell(
        pad(
          left: page.margin.left * 0.4,
          bottom: page.margin.top * 0.12,
          image(
            "./../assets/logo_iace_white.svg", height: page.margin.top * 0.254
          )
        )
      ),
      grid.cell(
        banner(title)
      ),
      grid.cell(
        pad(
          bottom: page.margin.top * 0.135,
          image(
            "./../assets/logo_umit_white_wo.svg", height: page.margin.top * 0.17
          )
        )
      ),
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
  line(length: 100%, stroke: 0.25mm)
}

#let header = (
  article: header-colored(),
  exam: header-colored(),
  exercise: header-colored(),
  lecture: context {
    set par(spacing: 0.5em)

    if page-is-chap-start() {
      none
    } else {
      let page-num = here().page()
      let before = query(heading).filter(h => h.location().page() <= page-num)

      let chapters = before.filter(h => h.level == 1)
      let sections = before.filter(h => h.level == 2)
      let sec = sections.last()
      let chapNum = numbering(chapters.last().numbering, counter(heading).at(sec.location()).at(0))
      let secNum = counter(heading).at(sec.location()).enumerate().map(((idx, cnt)) => if idx == 0 {chapNum} else {str(cnt)}).join(".")

      if calc.even(here().page()) {
        if chapters == () {
          return
        }
        let chapT = chapters.last().body
        [#chapNum; #h(1em); #chapT; #h(1fr)]
      } else {
        if sections.len() > 0 {
          let secT = sec.body
          [#h(1fr); #secNum; #h(1em); #secT]
        }
      }
      line(length: 100%, stroke: 0.25mm)
    }
  },
  letter: () => context {
    let opts = options.final()
    if opts.lang == "de" {
      image(
        "./../assets/logo_umit_blue_gr.png",
        width: 33%
      )
    } else {
      image(
        "./../assets/logo_umit_blue_en.png",
        width: 33%
      )
    }
  },
  poster: header-colored(),
  report: header-colored(),
  slides: (heading: none, progressAnimation: none) => context {
    let opts = options.final()
    let showAni = type(progressAnimation) == dictionary and progressAnimation.at("section", default: false)
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
    rect(
      fill: opts.theme.primary,
      width: 100%,
      height: 100%,
    )
    pad(
      top: -page.margin.top * 1.42,
      grid(
        columns: (auto, 1fr, auto),
        if logo-left == auto {
          pad(
            top: -6.5pt,
            left: page.margin.left - 11%,
            image("./../assets/logo_iace_white.svg", height: 20.8pt)
          )
        } else {
          logo-left
        },
        pad( x: -1pt,
          banner(slide: true, size: 17.6pt, progressAnimation: showAni, move(dy: 0.5pt, heading))
        ),
        if logo-right == auto {
          pad(
            top: -2.2pt,
            right: page.margin.right,
            image("./../assets/logo_umit_white_wo.svg", height: 17.2pt)
          )
        } else {
          logo-right
        },
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

#let bmim-footer(foot, pagenum: context {counter(page).display("1")} ) = context {
    let opts = options.final()
    set text(size: 0.8em)
    set par(spacing: 0.5em)
    line(length: 100%, stroke: 0.5pt)
    if opts.oneside {
        foot; h(1fr); pagenum
    } else {
      if calc.odd(here().page()) {
        foot; h(1fr); pagenum
      } else {
        pagenum; h(1fr); foot
      }
    }
}

#let footer = (
  article: () => context {
    align(
      center,
      counter(page).display("1")
    )
  },
  exam: (course, title) => context {
    let opts = options.final()
    let course = if type(course) == array { course.at(1) } else { course }
    let foot = [
      #opts.spell.exam - #course
      #if opts.show-solution != none [
        #set text(color.red)
        *#opts.spell.with #opts.spell.sol*
      ]
    ]
    if calc.odd(here().page()) and here().page() != 1 {
      bmim-footer([#foot #h(1fr) Matrikelnr: #underline-space(25%)], pagenum: counter(page).display("1/1", both: true))
    } else {
      bmim-footer(foot, pagenum: counter(page).display("1/1", both: true))
    }
  },
  exercise: (course, title) => context {
    let opts = options.final()
    let course = if type(course) == array { course.at(1) } else { course }
    let title = if type(title) == array { title.join([ \- ]) } else { title }
    let foot = [
      #course - #title
      #if opts.show-solution != none [
        #set text(color.red)
        *#opts.spell.with #opts.spell.sol*
      ]
    ]
    bmim-footer(foot)
  },
  lecture: (course, date) => context{
    let opts = options.final()
    let course = if type(course) == array { course.at(1) } else { course }

    let foot = [
      #course, Version #print-date(date)
    ]
    bmim-footer(foot, pagenum: counter(page).display())
  },
  letter: () => context {
    let opts = options.final()
    if opts.lang == "de" {
      image(
        "./../assets/footer_umit_gr.png",
        width: 100%
      )
    } else {
      image(
        "./../assets/footer_umit_en.png",
        width: 100%
      )
    }
  },
  poster: (event,date,location,contact, ..args) => context {
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
    let opts = options.final()
    let course = if type(course) == array { course.at(1) } else { course }
    let title = if type(title) == array { title.join([ \- ]) } else { title }
    let foot = [
      #course - #title
      #if opts.show-solution != none [
        #set text(color.red)
        *#opts.spell.with #opts.spell.sol*
      ]
    ]
    bmim-footer(foot)
  },
  slides: (author:none, title:none, date:none, pagenum:none, progressAnimation:none) => context {
    let opts = options.final()
    let showAni = type(progressAnimation) == dictionary and progressAnimation.at("slides", default: false)
    block(
      [
        #if showAni {
          block(
            inset: (bottom: -page.height * 5.7%),
            components.progress-bar(height: page.height * 3.3%, opts.theme.highlight, opts.theme.primary)
          )
        }
        #box(
          stroke: (
            top: opts.theme.secondary + 0pt,
          ),
          fill: if showAni {none} else {opts.theme.primary},
          inset: (left: page.margin.left, right: page.margin.right, top: -page.height * 0.525%, bottom: page.height * 0.9%),
          grid(
            columns: (auto, 70%, 1fr, 5%),
            gutter: 2%,
            align: (left, left, center, right),
            rows: page.height * 2.8%,
            text(white)[#author],
            text(white)[#title],
            if opts.lang == "de" {
              text(white)[#date.day(). #translatedMonth(date, opts.lang) #date.year()]
            } else {
              text(white)[#translatedMonth(date, opts.lang) #date.day(), #date.year()]
            },
            text(white)[#pagenum],
          ),
        )
      ]
    )
  },
  workbook: (course) => context {
    let opts = options.final()
    let course = if type(course) == array { course.at(1) } else { course }
    let foot = [
      #course - #opts.spell.exercises
    ]
    bmim-footer(foot)
  },
)

#let finalblock = (
  lecture: () => context {
  },
  letter: (sender) => context {
    let opts = options.final()

    v(2em)
    opts.spell.regards
    if sender.signature != none {
      v(0.25em)
      sender.signature
      v(0.25em)
    } else {
      v(4em)
    }
    sender.name
    linebreak()
    sender.pos
  },
)

#let bmim-title(args) = {
    let opts = options.final()
    let course = if type(args.course) == array { args.course.at(0) } else { args.course }

    align(center,
      box(
        width: 77%,
        stroke: (bottom: 1pt),
        inset: (bottom: 7pt),
        [
          #text(size: 2em)[#args.title]
          #v(-1.5em)
          #text(size: 1.2em)[#course]
        ])
    )
    grid(
      columns: (2fr, 1fr),
      gutter: 0.5em,
      align: (right, left),
      text[
        #if opts.show-solution != none {
          set text(color.red)
          strong[
            #opts.spell.with #opts.spell.sol,
          ]
        }
        #if args.date != none [
          #opts.spell.on
          #args.date.day(). #translatedMonth(args.date, opts.lang)
          #args.date.year(),
        ]
        #opts.spell.ho:
      ],
      grid(
        row-gutter: 0.5em,
        ..args.authors.map(author => text(author)),
      ),
    )
}

#let titleblock = (
  exam:     (args) => context {
    let opts = options.final()
    bmim-title(args)
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
      if args.show-hints {
        {
          set list(spacing: 1.3em)
          [
            *Hinweise*
            #set text(size: 0.9em)
            #pad(left: 1.4em)[
              - Die Prüfung umfasst *#context task.total-count()* Aufgaben, die Bearbeitungszeit beträgt *#args.total-time*.
              - Es können insgesamt *#context task.total-points()* Punkte erreicht werden.
              - Zugelassene Hilfsmittel:
                - *Ein handschriftlich* beschriebener A4 Zettel, am Ende der Klausur *abzugeben*.
              - *Nicht zugelassene* Hilfsmittel:
                - Jegliche Unterlagen
                - Elektronische Geräte
              - Schreiben Sie *leserlich* und geben Sie den *Lösungsweg* vollständig an.
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
      stroke: 0.1em,
      align:left,
      ..tableData.filter(x => x != none)
    )
  },
  exercise: (args) => bmim-title(args),
  report: (args) => context {
    let margs = args
    margs.date = none
    bmim-title(margs)
    let opts = options.final()
    set align(center)
    grid(
      columns: (2fr, 1fr),
      gutter: 0.5em,
      align: (right, left),
      [
        #opts.spell.lc:
      ],
      [
        #args.date.day(). #translatedMonth(args.date, opts.lang) #args.date.year()
      ],
    )
  },
  lecture: (args) => context {
    let opts = options.final()
    let course = if type(args.course) == array { args.course.at(0) } else { args.course }
    set std.page(
      header: context {
        if counter(page).get().first() == 1 {
          pad(
            top: page.margin.top * 0.3,
            left: -page.margin.left * 0.4,
            right: -page.margin.left * 0.4,
            rect(
              fill: opts.theme.primary,
              width: 100% + page.margin.left * 0.4,
              height: 80%,
            )
          )
          pad(
            top: page.margin.top * 0.3,
            left: -page.margin.left * 0.4,
            grid(
              columns: (auto, 1fr, auto),
              grid.cell(
                pad(
                  left: page.margin.left * 0.4,
                  bottom: page.margin.top * 0.12,
                  image(
                    "./../assets/logo_iace_white.svg", height: page.margin.top * 0.254
                  )
                )
              ),
              grid.cell(
                banner()
              ),
              grid.cell(
                pad(
                  bottom: page.margin.top * 0.135,
                  image(
                    "./../assets/logo_umit_white_wo.svg", height: page.margin.top * 0.17
                  )
                )
              ),
            )
          )
        } else {
          none
        }
      }
    )

    set align(center+horizon)
    set par(spacing: 3em)

    [
      // maybe some time in the distant future ...
      // #set page(background: box(
      //   width: 100%, 
      //   height: 100%, 
      //   fill: gradient.linear(
      //     opts.theme.primary, 
      //     black,
      //     angle: 90deg
      //   )
      // ))
      // #set text(fill: opts.theme.background)
      #smallcaps[
        #set text(1.5em)
        Skriptum zur Lehrveranstaltung \
      ]

      #{
        set text(2em)
        strong(course)
      }

      #{
        set text(1.2em)
        args.authors.map(smallcaps).join([, ])
      }
      #par[]
      #par[]
      #[
        #set text(1.2em)
        Institut für Automatisierungs- und Regelungstechnik \
      ]
      #par[]
      #par[]
      #print-semester(args.date)
    ]
    pagebreak(to: "odd", weak: true)
    counter(page).update(1)
  },
  letter: (
    recipient,
    sender,
    location,
    date,
    subject
  ) => context {
    let headText(body) = {
      set text(gray, size: 8pt)
      if body != none {
        lower(body)
        linebreak()
      }
    }
    // left block
    place(top + left, [
      #if sender.department != none {
        headText(sender.department)
      }
      #headText(sender.institute)
      #text(size: 10pt)[
        #if recipient.institution != none [
          #recipient.institution \
        ]
        #if recipient.pro != none [
          #recipient.pro
        ]
        #if recipient.name != none [
          #recipient.name \
        ]
        #recipient.address
      ]
    ])
    // right block
    place(top + right, [
      #align(left)[
        #if sender.department != none {
          headText(sym.zwj)
        }
        #headText(sender.pos)
        #text(size: 8pt)[
          #sender.name \
          T #sender.tel \
          #if sender.fax != none {
            [F #sender.fax #linebreak()]
          }
          E #sender.email
        ]
      ]
    ])
    // date block
    v(10.5em)
    align(right)[
      #location, #print-date(date)
    ]
    // subject line
    // (should appear above the first fold)
    v(1.5em)
    if subject != none {
      text(weight: "bold")[#subject]
      v(2em)
    }
  },
  poster:   (title, authors) => context {
    place(top+center, float: true, scope: "parent",[
      #text(1.4em, strong(title))\
      #authors.join([\ ])
    ])
  },
  article:   (args) => context {
    let opts = options.final()
    place(top,
      float: true,
      scope: "parent",
      block(
        {
          set par(spacing: .7em, leading: .7em)
          text(size: 2.5em, weight: "semibold", args.title)
          linebreak()
          text(size: 1.5em, weight: "semibold", args.subtitle)
          line(length: 33%)
          text(size: 0.9em, weight: "medium")[
            #args.authors.join(", ")
            #linebreak()
            #opts.spell.date: #print-date(args.date)
          ]
        })
    )
  },
  // place(
  //   top, float: true, scope: "parent",
  //   block(inset: (top: 2em, bottom: 1em), {
  //     set par(spacing: 1em)
  //     // let w = measure(title).width
  //     // line(length: w+0.5em, stroke: 1pt)
  //     args.authors.join(", ")
  //     // line(length: w+0.5em, stroke: 3pt)
  //
  //   })
  // ),
  slides: () => context {},
  workbook: (args) => context {
    let opts = options.final()
    let course = if type(args.course) == array { args.course.at(0) } else { args.course }
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
        args.authors.map(smallcaps).join([, ])
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
              image("./../assets/logo_iace_black.svg", height: 2.65em)
            )
          )
        )
      ]
      #print-date(args.date)
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

