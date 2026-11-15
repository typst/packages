#import "task.typ"
#import "helpers.typ": *
#import "options.typ": *
#import "check.typ": *
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

// Plain text of `body`, or none if it holds more than text (e.g. math).
#let plain-text(body) = {
  if type(body) == str { return body }
  if type(body) != content { return none }
  if body == [ ] or body.func() == h { return " " }
  if body.has("text") { return body.text }
  if body.has("children") {
    let parts = body.children.map(plain-text)
    return if none in parts { none } else { parts.join() }
  }
  if body.has("body") { return plain-text(body.body) }
  none
}

// Show `body` on a single line: a too long text is cut after the last fitting
// word and ends with an ellipsis, other content is clipped.
#let fit-line(body) = layout(size => {
  if measure(body).width <= size.width { return body }
  let plain = plain-text(body)
  if plain == none {
    // keep the content on one line and cut it at the end of the line, the
    // outset keeps the descenders
    return box(width: size.width, clip: true, outset: (y: 0.3em), block(width: 10 * size.width, body))
  }
  let words = plain.split(" ").filter(w => w != "")
  let n = words.len() - 1
  while n > 1 and measure(words.slice(0, n).join(" ") + "…").width > size.width {
    n -= 1
  }
  words.slice(0, n).join(" ") + "…"
})

// Colored bar with optional centered content. On slides, `progress` adds one
// dot per section on the right, the current section filled.
#let banner(slide: false, size: 1em, progress: false, ..body) = {
  assert-no-extra(body, "banner")
  let opts = options.final()
  let height = if slide { 0.5em } else { 1.5em }
  let show-progress = slide and progress
  show text: set text(size: size, fill: opts.theme.background)
  show math.equation: set text(fill: opts.theme.background)

  let content = box(
    width: 100%,
    height: height,
    if body.pos().len() != 0 {
      // slides: always left aligned, other headers and footers: centered
      set align(if slide { horizon+left } else { horizon+center })
      pad(x: 15pt, body.pos().first())
    }
  )

  let progress-dots() = {
    let current-section = utils.current-heading(level: 1)
    let dot(filled) = circle(
      radius: 3.5pt,
      stroke: 1pt + gray.lighten(20%),
      fill: if filled { gray.lighten(20%) },
    )
    box(
      height: height,
      // keep a small distance to the logo on the right
      pad(right: 1em, align(horizon, stack(
        dir: ltr,
        spacing: 10pt,
        // one dot per outlined section, also without an outline in the document
        ..query(heading.where(level: 1, outlined: true)).map(sec => dot(
          current-section != none and sec.location() == current-section.location()
        ))
      )))
    )
  }

  grid(
    // the title takes the free space, the dots only their own width
    columns: if show-progress { (1fr, auto) } else { (auto,) },
    gutter: 1em,
    content,
    ..if show-progress { (progress-dots(),) },
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
          place-institute-logo(opts, "header", height: page.margin.top * 0.254
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

#let chapter-header(oneside: false, rule: false) = context {
  set par(spacing: 0.5em)

  if page-is-chap-start() { return }
  let chapter = query(selector(heading.where(level: 1)).before(here()))
  if chapter.len() == 0 { return }
  let sub = query(selector(heading.where(level: 2)).after(chapter.last().location()))
  sub = sub.filter(el => el.location().page() <= here().page())

  let chap-title = {
    let cnt = counter(heading).at(here())
    let nbr = chapter.last().numbering
    if nbr != none { numbering(nbr, cnt.first())+[.~]+h(0.5em)}
    chapter.last().body
  }
  let sub-title = if sub.len() != 0 {
    let this-sub = sub.last()
    let nbr = this-sub.numbering
    if nbr != none {
      let cnt = counter(heading).at(this-sub.location())
      numbering(nbr, ..cnt.slice(0,count:2))+[.~]+h(0.5em)
    }
    this-sub.body
  }

  if oneside {
    chap-title; h(1fr); sub-title
  } else if calc.even(here().page()) {
    chap-title; h(1fr)
  } else {
    h(1fr); sub-title
  }
  if rule { line(length: 100%, stroke: 0.25mm) }
}


#let header = (
  article: header-colored(),
  exam: header-colored(),
  exercise: header-colored(),
  lecture: context chapter-header(oneside: options.final().oneside, rule: true),
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
  // slide: size and margins of the slide (slide-geometry), none: of the page
  slides: (heading: none, progress-animation: none, slide: none) => context {
    let opts = options.final()
    let slide = if slide != none { slide } else {
      (width: page.width, height: page.height, left: page.margin.left,
        right: page.margin.right, top: page.margin.top, bottom: page.margin.bottom)
    }
    let show-ani = type(progress-animation) == dictionary and progress-animation.at("section", default: false)
    let logo-left = pick-logo(opts.logo, "left")
    let logo-right = pick-logo(opts.logo, "right")
    set text(weight: "bold")
    rect(
      fill: opts.theme.primary,
      width: 100%,
      height: 100%,
    )
    pad(
      top: -slide.top * 1.42,
      grid(
        columns: (auto, 1fr, auto),
        if logo-left == auto {
          pad(
            top: -6.5pt,
            left: slide.left - 11%,
            place-institute-logo(opts, "slides-header", height: 20.8pt)
          )
        } else {
          logo-left
        },
        pad( x: -1pt,
          banner(slide: true, size: 17.6pt, progress: show-ani, move(dy: 0.5pt, heading))
        ),
        if logo-right == auto {
          pad(
            top: -2.2pt,
            right: slide.right,
            image("./../assets/logo_umit_white_wo.svg", height: 17.2pt)
          )
        } else {
          logo-right
        },
      )
    )
  },
  thesis: chapter-header(),
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

#let footer-course-title(course, title) = context {
  let opts = options.final()
  let course = short(course)
  let title = short(title)
  let foot = [
    #if course != none [#course - ]#title
    #if opts.show-solution != none [
      #set text(color.red)
      *#opts.spell.with #opts.spell.sol*
    ]
  ]
  bmim-footer(foot)
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
    let course = short(course)
    let foot = [
      #opts.spell.exam - #course
      #if opts.show-solution != none [
        #set text(color.red)
        *#opts.spell.with #opts.spell.sol*
      ]
    ]
    if calc.odd(here().page()) and here().page() != 1 {
      bmim-footer([#foot #h(1fr) #opts.spell.student-id-short: #underline-space(25%)], pagenum: counter(page).display("1/1", both: true))
    } else {
      bmim-footer(foot, pagenum: counter(page).display("1/1", both: true))
    }
  },
  exercise: footer-course-title,
  lecture: (course, date) => context{
    let opts = options.final()
    let course = short(course)

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
  report: footer-course-title,
  // slide: size and margins of the slide (slide-geometry), none: of the page
  slides: (author:none, title:none, date:none, pagenum:none, progress-animation:none, slide: none) => context {
    let opts = options.final()
    let slide = if slide != none { slide } else {
      (width: page.width, height: page.height, left: page.margin.left,
        right: page.margin.right, top: page.margin.top, bottom: page.margin.bottom)
    }
    let show-ani = type(progress-animation) == dictionary and progress-animation.at("slides", default: false)
    block(
      [
        #if show-ani {
          block(
            inset: (bottom: -slide.height * 5.7%),
            components.progress-bar(height: slide.height * 3.3%, opts.theme.highlight, opts.theme.primary)
          )
        }
        #box(
          stroke: (
            top: opts.theme.secondary + 0pt,
          ),
          fill: if show-ani {none} else {opts.theme.primary},
          inset: (
            left: slide.left,
            right: slide.right,
            top: -slide.height * 0.525%,
            bottom: slide.height * 0.9%
          ),
          grid(
            // author, date and page number never break, the title takes the
            // rest and is cut to a single line
            columns: (auto, 1fr, auto, auto),
            gutter: 2%,
            align: (left, left, right, right),
            rows: slide.height * 2.8%,
            text(white)[#author],
            text(white, fit-line(title)),
            text(white)[#print-date(date)],
            text(white)[#pagenum],
          ),
        )
      ]
    )
  },
  thesis: context {
    let opts = options.final()
    set text(size: 0.8em)
    set par(spacing: 0.5em)
    let pagenum = counter(page).display()
    if opts.oneside {
        h(1fr); pagenum
    } else {
      if calc.odd(here().page()) {
        h(1fr); pagenum
      } else {
        pagenum; h(1fr)
      }
    }
  },
  workbook: (course) => context {
    let opts = options.final()
    let course = if type(course) == array { course.at(1) } else { course }
    let foot = [
      #course - #opts.spell.exercises
    ]
    bmim-footer(foot, pagenum: counter(page).display())
  },
)

#let university-city(university) = {
  assert-one-of("university", university, universities)
  if university == "LFUI" [Innsbruck] else [Hall in Tirol]
}

#let finalblock = (
  thesis: (author, university) => context {
    let spell = options.final().spell
    set page(numbering: none)
    set heading(numbering: none, outlined: false, bookmarked: false)
    [
      = #spell.declaration-title

      #spell.declaration

      #v(3em)
      #grid(
        columns:(35%, 15%, 50%),
        [
          #(spell.signed-at)(university-city(university))
          #box(width:1fr, repeat(gap:0.25em)[.])
        ],
        [],
        [
          #set align(right)
          #box(width:1fr, repeat(gap:0.25em)[.])\
          #author
        ]
      )
    ]
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
    let course = long(args.course)

    align(center,
      box(
        width: 77%,
        stroke: (bottom: 1pt),
        inset: (bottom: 7pt),
        [
          #text(size: 2em)[#long(args.title)]
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
          #opts.spell.on #print-date(args.date),
        ]
        #opts.spell.ho:
      ],
      grid(
        row-gutter: 0.5em,
        ..args.authors.map(author => text(author)),
      ),
    )
}

// Color gradient of the flyer: the box on the front page and the background
// of the back page
#let flyer-gradient(opts) = gradient.linear(
  opts.theme.primary.lighten(10%),
  opts.theme.primary.darken(80%),
  angle: 90deg,
)

// Left and right margin of the back page of the flyer
#let flyer-side = 8%

// Font sizes of the flyer, set with the option `sizes` of flyer()
#let flyer-size-defaults = (
  series: 11pt, // above the title on the front page
  title: 25pt, // title on the front page
  details: 16pt, // rows below the title
  badge: 11pt, // flyer-badge
  heading: 20pt, // flyer-heading
)
#let flyer-sizes = state("bmim-flyer-sizes", flyer-size-defaults)

// Heading on the back page of the flyer, with a line below; `size` (auto: the
// size `heading` of the option `sizes`) is the font size, `rule` the length of
// the line
#let flyer-heading(body, size: auto, rule: 100%) = context {
  let opts = options.final()
  let size = if size == auto { flyer-sizes.get().heading } else { size }
  block(below: 1.2em, {
    block(below: 8pt, {
      set par(leading: 0.4em)
      text(size: size, weight: "medium", hyphenate: false, body)
    })
    line(length: rule, stroke: 1.2pt + opts.theme.background)
  })
}

// Rotated badge on the back page of the flyer, e.g. with date and time; a
// datetime is shown with date and time in the language of the document. It is
// right aligned and reaches beyond the right page edge: right margin plus some
// extra, so that the rotated edge is outside of the page as well.
#let flyer-badge(body, end: none) = context {
  let opts = options.final()
  // the spacings (em) refer to the default body size, not to the option size
  // of the flyer, so the badge only changes with its own size
  set text(size: 9.5pt)
  let side = page.width * (flyer-side / 100%)
  // the box reaches 2em beyond the page edge, the rotation leaves no gap
  let bleed = side + 2em
  align(right, move(dx: bleed, rotate(-5deg, reflow: true, box(
    fill: opts.theme.highlight,
    // the text ends at half the side margin from the page edge
    inset: (left: 1em, right: 2em + side / 2, y: 1.7em),
    text(size: flyer-sizes.get().badge, weight: "bold", print-date-time(body, end: end)),
  ))))
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
        #opts.spell.name: #underline-space(73%) #h(2em)
      ],
      [
        #opts.spell.student-id: #underline-space(50%)
      ],
    )
    v(1.25em)

    let table-data = (
      {
        strong(opts.spell.eval)
        task.points-table
      },
      if args.show-hints {
        {
          set list(spacing: 1.3em)
          [
            *#opts.spell.hints*
            #set text(size: 0.9em)
            #pad(left: 1.4em, (opts.spell.exam-hints)(
              task.total-count(),
              args.total-time,
              task.total-points(),
            ))
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
      ..table-data.filter(x => x != none)
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
        #print-date(args.date)
      ],
    )
  },
  lecture: (args) => context {
    let opts = options.final()
    let course = long(args.course)
    set std.page(
      header: context {
        if counter(page).get().first() == 1 {
          pad(
            left: -page.margin.left * 0.4,
            bottom: -page.margin.top * 0.4,
            grid(
              columns: (1fr, 1fr),
              grid.cell(
                align(left,{
                  pad(
                    left: page.margin.left * 0.4,
                    place-institute-logo(opts, "title-page", height: page.margin.top * 0.508
                    )
                  )
                })
              ),
              grid.cell(
                align(right, {
                  pad(
                    image(
                      "./../assets/logo_umit_white_wo.svg", height: page.margin.top * 0.34
                    )
                  )
                })
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
      #set page(background: box(
        width: 100%,
        height: 100%,
        fill: gradient.linear(
          opts.theme.primary,
          black,
          angle: 90deg
        )
      ))
      #set text(fill: opts.theme.background)
      #smallcaps[
        #set text(1.5em)
        #opts.spell.lecture-notes \
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
        #institute-name(opts) \
      ]
      #par[]
      #par[]
      #print-semester(args.date)
    ]
  },
  letter: (args) => context {
    let (recipient, sender, location, date, subject, ..) = args
    let head-text(body) = {
      set text(gray, size: 8pt)
      if body != none {
        lower(body)
        linebreak()
      }
    }
    // left block
    place(top + left, [
      #if sender.department != none {
        head-text(sender.department)
      }
      #head-text(sender.institute)
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
          head-text(sym.zwj)
        }
        #head-text(sender.pos)
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
  flyer: (args) => context {
    let opts = options.final()
    let fg = opts.theme.background
    let logo-left = pick-logo(opts.logo, "flyer-left")
    let logo-right = pick-logo(opts.logo, "flyer-right")
    set text(fill: fg)
    set par(justify: false)

    // background image, covers the whole page
    if args.background != none {
      place(top + left, box(
        width: page.width, height: page.height, clip: true, {
          set image(width: 100%, height: 100%, fit: "cover")
          args.background
        }
      ))
    }

    // information box at the bottom half
    place(bottom + left, dx: 4%, box(
      width: 92%,
      height: 50%,
      fill: flyer-gradient(opts),
      inset: (x: 6%, top: 2.2em, bottom: 1.8em),
      // the alignment of place would apply to the content as well
      align(top + left, {
        // series above the title, separated by a line
        if args.series != none {
          block(
            width: 100%,
            below: 0.8em,
            stroke: (bottom: 0.6pt + fg),
            inset: (bottom: 0.5em),
            text(size: args.sizes.series, weight: "semibold", upper(args.series)),
          )
        }
        block(below: 1.8em, text(size: args.sizes.title, weight: "semibold", hyphenate: false, long(args.title)))
        // freely labelled rows, e.g. presenter, organisation, date
        set text(size: args.sizes.details)
        grid(
          columns: (8em, 1fr),
          row-gutter: 0.9em,
          // an empty label (none or []) shows no colon
          ..args.details.map(((label, body)) => (
            if label in (none, [], "") { [] } else [#label:],
            body,
          )).flatten(),
        )
        // logos bottom right, the QR code (or any content, e.g. an image)
        // bottom left in its own size, both aligned at the bottom; it is shown
        // as given, so its colors have to contrast with the box
        let main-logo = if logo-right == auto {
          let logo = if opts.lang == "de" { "logo_umit_white_gr.svg" } else { "logo_umit_white_en.svg" }
          image("./../assets/" + logo, height: 50pt)
        } else {
          logo-right
        }
        if args.qr-code != none {
          place(bottom + left, args.qr-code)
        }
        place(bottom + right, stack(
          dir: ltr,
          spacing: 1.5em,
          if logo-left != auto { align(bottom, logo-left) },
          align(bottom, main-logo),
        ))
      }),
    ))
  },
  poster: (args) => context {
    let (title, authors, ..) = args
    place(top+center, float: true, scope: "parent",[
      #text(1.4em, strong(long(title)))\
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
          text(size: 2.5em, weight: "semibold", long(args.title))
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
  slides: () => context {},
  thesis: (args) => context {
    let (program, university, title, subtitle, author, date, advisor, ..) = args
    let opts = options.final()
    let degree = if program == "Bachelor" [Bachelor of Science] else if program == "Master" [Diplom-Ingenieur]
    let work = if program == "Bachelor" { opts.spell.bachelor-thesis } else { opts.spell.master-thesis }
    pad(left: 0mm, right: -5mm, {
      set text(12pt)
      let large(content) = text(12pt, content)
      let Large(content) = text(14pt, content)
      let LARGE(content) = text(17pt, content)
      let bigskip = v(12pt)
      let smallskip = v(3pt)
      v(1em - 27mm)
      // logo
      {
        set text(11.3pt, font: opts.fonts.logo)
        if university =="LFUI" {
          pad(left: -18.5mm, image("./../assets/logo_lfui_color.png", width: 75mm))
          v(-2em)
          opts.spell.lfui-faculty-logo
        } else {
          let logo = if opts.lang == "de" { "logo_umit_blue_gr.svg" } else { "logo_umit_blue_en.svg" }
          pad(left: -4.4mm, top: 7.5mm, image("./../assets/" + logo, height: 16.5mm))
          v(-0.5em)
          opts.spell.umit-department
          v(1.3em)
        }
      }
      // text
      bigskip
      block(height: 3cm, above:1.25cm, {
        Large(strong(long(title)))
        Large(subtitle)
      })
      bigskip
      large[
        #author
      ]
      v(8pt)
      large[
+        #university-city(university), #if type(date) == datetime [
          #translated-month(date, opts.lang) #date.year()
        ] else [
          #date
        ]
      ]

      // align the rest to bottom
      v(1fr)
      Large(work)
      par((opts.spell.thesis-joint)(program))
      smallskip
      par((opts.spell.thesis-submitted)(university))
      smallskip
      par(Large(degree))
      bigskip

      bigskip
      [#opts.spell.assessor:]
      linebreak()
      let adv = advisor.at(0)
      adv.name
      linebreak()
      adv.unit
    })

    if program == "Master" { // advisors
      pagebreak(to: "odd")
      v(1fr)
      let adv = advisor.at(0)
      let z= h(0pt, weak:true)
      grid(
        columns:(1fr, 3.2fr), gutter:1.2em,
        [#opts.spell.supervisor:],
        [#adv.name#z, #adv.university#z, #adv.department#z, #adv.unit],
        ..if advisor.len() > 1 {
          let adv = advisor.at(1)
          (align(top,[#opts.spell.co-supervisor:]),
          [#adv.name#z, #adv.university#z, #adv.department#z, #adv.unit])
        }
      )
    }
  },
  workbook: (args) => context {
    let opts = options.final()
    let course = long(args.course)
    set align(center+horizon)
    set par(spacing: 3em)

    [
      #set page(background: box(
        width: 100%,
        height: 100%,
        fill: gradient.linear(
          opts.theme.primary,
          black,
          angle: 90deg
        )
      ))
      #set text(fill: opts.theme.background)
      #smallcaps[
        #set text(1.3em)
        #opts.spell.workbook
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
        #institute-name(opts)

        #grid(
          columns: (auto, auto),
          grid.cell(
            pad(
              left: -0.6em,
              right: -0.2em,
              place-institute-logo(opts, "title-page", height: 2.65em)
            )
          )
        )
      ]
      #print-date(args.date)
    ]
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
