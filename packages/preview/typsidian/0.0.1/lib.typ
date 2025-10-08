#import "@preview/zebraw:0.5.5": *
#import "@preview/itemize:0.1.2" as el
#import "@preview/showybox:2.0.4": showybox
#import "@preview/glossarium:0.5.9": gls, glspl, make-glossary, print-glossary, register-glossary
#import "@preview/fontawesome:0.6.0": *

// Typsidian - Template for Typst for Obsidian plugin: https://github.com/k0src/Typst-for-Obsidian
// Required fonts: Inter 24pt, GeistMono NFP, Fira Math
// https://fonts.google.com/specimen/Inter
// https://github.com/ryanoasis/nerd-fonts/releases/
// https://github.com/firamath/firamath/releases/
//
// by: https://github.com/k0src

#let in-box = state("in-box", false)

#let _title = state("template-title", "")
#let _course = state("template-course", "")
#let _colors = state("template-colors", (
  bg: rgb("#ffffff"),
  heading-colors: (
    "1": rgb("#222222"),
    "2": rgb("#3a189a"),
    "3": rgb("#0051cb"),
    "4": rgb("#00aa86"),
    "5": rgb("#eb2969"),
    "6": rgb("#ff6f61"),
  ),
  code-colors: (
    bg: rgb("#fafafa"),
    numbers: rgb("#ababab"),
    highlight: rgb("#ffffff"),
  ),
  text-colors: (
    main: rgb("222222"),
    link: rgb("#1a2dff"),
    bold: rgb("#8a5cf5"),
    emph: rgb("#8a5cf5"),
    muted: rgb("#5c5c5c"),
  ),
  boxes: (
    example: (
      header: rgb("#fbe55b"),
      bg: rgb("#fff9e5"),
      text: rgb("#575410"),
      title: rgb("#575410"),
      code: (
        bg: rgb("#fffbed"),
        numbers: rgb("#b3b0a6"),
        highlight: rgb("#fff9e5"),
      ),
    ),
    info: (
      header: rgb("#4fc784"),
      bg: rgb("#eefbf2"),
      text: rgb("#0d472d"),
      code: (
        bg: rgb("#f5fdf7"),
        numbers: rgb("#a7b0a9"),
        highlight: rgb("#eefbf2"),
      ),
    ),
    important: (
      header: rgb("#d32f35"),
      bg: rgb("#fde3e4"),
      text: rgb("#420d0f"),
      code: (
        bg: rgb("#fef2f3"),
        numbers: rgb("#b2a9aa"),
        highlight: rgb("#fde3e4"),
      ),
    ),
    aside: (
      header: rgb("#7cc4fd"),
      bg: rgb("#e0eefe"),
      text: rgb("#07274a"),
      title: rgb("#07274a"),
      code: (
        bg: rgb("#eff7ff"),
        numbers: rgb("#a7adb3"),
        highlight: rgb("#e0eefe"),
      ),
    ),
  ),
))

#let typsidian(
  title: "Digital Signal Processing",
  author: "John Smith",
  course: "DSP101",
  text-args: (
    main: (
      font: "Inter 24pt",
      weight: "regular",
      size: 10pt,
    ),
    mono: (
      font: "GeistMono NFP",
      weight: "regular",
      size: 1.1em,
    ),
  ),
  show-index: false,
  index-entry-list: array,
  theme: "light",
  show-heading-colors: true,
  show-bold-color: true,
  show-italic-color: true,
  standalone: true,
  body,
) = {
  let index-entry-list = if type(index-entry-list) == array {
    index-entry-list
  } else {
    (index-entry-list,)
  }

  show: zebraw
  show: el.default-enum-list
  show ref: el.ref-enum

  _title.update(title)
  _course.update(course)

  let colors = if theme == "dark" {
    (
      bg: rgb("#1e1e1e"),
      heading-colors: (
        "1": rgb("#dadada"),
        "2": rgb("#8a5cf5"),
        "3": rgb("#3e56ff"),
        "4": rgb("#40c795"),
        "5": rgb("#df237d"),
        "6": rgb("#f36222"),
      ),
      code-colors: (
        bg: rgb("#242424"),
        numbers: rgb("#666666"),
        highlight: rgb("#292929"),
      ),
      text-colors: (
        main: rgb("#dadada"),
        link: rgb("#1a2dff"),
        bold: rgb("#8a5cf5"),
        emph: rgb("#8a5cf5"),
        muted: rgb("#b3b3b3"),
      ),
      boxes: (
        example: (
          header: rgb("#fbe55b"),
          bg: rgb("#2b2a18"),
          text: rgb("#fef9c3"),
          title: rgb("#2b2a18"),
          code: (
            bg: rgb("#252410"),
            numbers: rgb("#9a986e"),
            highlight: rgb("#3a381a"),
          ),
        ),
        info: (
          header: rgb("#4fc784"),
          bg: rgb("#162822"),
          text: rgb("#a8f0c5"),
          code: (
            bg: rgb("#11231c"),
            numbers: rgb("#6ea98a"),
            highlight: rgb("#1d3b2e"),
          ),
        ),
        important: (
          header: rgb("#ff5a5f"),
          bg: rgb("#2a1617"),
          text: rgb("#ffb3b6"),
          code: (
            bg: rgb("#221213"),
            numbers: rgb("#a67577"),
            highlight: rgb("#3a1c1e"),
          ),
        ),
        aside: (
          header: rgb("#7cc4fd"),
          bg: rgb("#162231"),
          text: rgb("#b3dcff"),
          title: rgb("#162231"),
          code: (
            bg: rgb("#101a27"),
            numbers: rgb("#6f8fae"),
            highlight: rgb("#1b2b3f"),
          ),
        ),
      ),
    )
  } else {
    (
      bg: rgb("#ffffff"),
      heading-colors: (
        "1": rgb("#222222"),
        "2": rgb("#3a189a"),
        "3": rgb("#0051cb"),
        "4": rgb("#00aa86"),
        "5": rgb("#eb2969"),
        "6": rgb("#ff6f61"),
      ),
      code-colors: (
        bg: rgb("#fafafa"),
        numbers: rgb("#ababab"),
        highlight: rgb("#ffffff"),
      ),
      text-colors: (
        main: rgb("222222"),
        link: rgb("#1a2dff"),
        bold: rgb("#8a5cf5"),
        emph: rgb("#8a5cf5"),
        muted: rgb("#5c5c5c"),
      ),
      boxes: (
        example: (
          header: rgb("#fbe55b"),
          bg: rgb("#fff9e5"),
          text: rgb("#575410"),
          title: rgb("#575410"),
          code: (
            bg: rgb("#fffbed"),
            numbers: rgb("#b3b0a6"),
            highlight: rgb("#fff9e5"),
          ),
        ),
        info: (
          header: rgb("#4fc784"),
          bg: rgb("#eefbf2"),
          text: rgb("#0d472d"),
          code: (
            bg: rgb("#f5fdf7"),
            numbers: rgb("#a7b0a9"),
            highlight: rgb("#eefbf2"),
          ),
        ),
        important: (
          header: rgb("#d32f35"),
          bg: rgb("#fde3e4"),
          text: rgb("#420d0f"),
          code: (
            bg: rgb("#fef2f3"),
            numbers: rgb("#b2a9aa"),
            highlight: rgb("#fde3e4"),
          ),
        ),
        aside: (
          header: rgb("#7cc4fd"),
          bg: rgb("#e0eefe"),
          text: rgb("#07274a"),
          title: rgb("#07274a"),
          code: (
            bg: rgb("#eff7ff"),
            numbers: rgb("#a7adb3"),
            highlight: rgb("#e0eefe"),
          ),
        ),
      ),
    )
  }

  _colors.update(colors)

  // Text & Raw Text
  show raw: set text(
    font: text-args.mono.at("font", default: "GeistMono NFP"),
    weight: text-args.mono.at("weight", default: "regular"),
    size: text-args.mono.at("size", default: 1.1em),
  )
  set text(
    font: text-args.main.at("font", default: "Inter 24pt"),
    weight: text-args.main.at("weight", default: "regular"),
    size: text-args.main.at("size", default: 10pt),
    fill: colors.text-colors.at("main", default: black),
  )
  show link: text.with(fill: colors.text-colors.at("link", default: blue))
  set enum(numbering: "1.a.i.", full: false)
  set par(justify: true)

  // Bold & Italic Text
  show strong: it => context {
    if show-bold-color and not in-box.get() {
      text(fill: colors.text-colors.at("bold", default: black), it)
    } else {
      it
    }
  }

  show emph: it => context {
    if show-italic-color and not in-box.get() {
      text(fill: colors.text-colors.at("emph", default: black), it)
    } else {
      it
    }
  }

  // Math
  show math.equation: set text(font: "Fira Math")
  set math.mat(delim: "[")
  show math.equation: set block(spacing: 1.05em)

  // Headings
  show heading: set block(below: 1em)
  set heading(numbering: "1.")

  show heading.where(level: 1): set align(center)
  show heading.where(level: 2): set text(weight: "bold")
  show heading.where(level: 3): set text(weight: "semibold")
  show heading: it => {
    if show-heading-colors {
      set text(fill: colors.heading-colors.at(str(it.level), default: black))
      if it.level >= 4 and it.level <= 6 {
        set text(weight: "medium")
        it
      } else {
        it
      }
    } else {
      if it.level >= 4 and it.level <= 6 {
        set text(weight: "medium")
        it
      } else {
        it
      }
    }
  }

  // Lists
  set enum(indent: 0.5em, body-indent: 0.5em)
  set list(indent: 0.5em, body-indent: 0.5em)

  // Figures
  show figure: it => context {
    let glossary-check = query(selector(<in-glossary>).before(here(), inclusive: true))
    if glossary-check.len() == 0 {
      show figure.caption.where(kind: table): set align(center)
      align(center, it)
      v(0.5em)
    } else {
      align(left, it)
    }
  }

  // Tables
  let frame(stroke) = (x, y) => (
    left: if x > 0 { 0em } else { stroke },
    right: stroke,
    top: if y < 2 { stroke } else { 0em },
    bottom: stroke,
  )
  set table(
    fill: (_, y) => if calc.odd(y) { colors.code-colors.bg },
  )

  // Code blocks
  show: zebraw-init.with(
    background-color: colors.code-colors.bg,
    lang: false,
    indentation: 2,
    highlight-color: colors.code-colors.highlight,
    numbering-font-args: (fill: colors.code-colors.numbers),
    inset: (
      top: 0.34em,
      right: 0.34em,
      bottom: 0.34em,
      left: 0.34em,
    ),
  )

  // Page setup
  set page(
    paper: "us-letter",
    columns: 1,
    fill: colors.bg,
    margin: (top: 7em, right: 6em, bottom: 6.5em, left: 6em),
    header: context {
      if counter(page).get().first() > 1 [
        #title
        #h(1fr)
        #counter(page).display()
      ]
    },
    footer: context {
      if counter(page).get().first() > 1 {
        align(right, [
          #course
        ])
      }
    },
  ) if standalone


  // Glossary
  if show-index {
    show: make-glossary
    if index-entry-list.len() > 0 {
      register-glossary(index-entry-list)
    }
  }

  body

  if show-index {
    pagebreak()
    let group-order = index-entry-list
      .enumerate()
      .fold((:), (acc, pair) => {
        let (idx, entry) = pair
        let grp = entry.at("group", default: "")
        if grp not in acc {
          acc.insert(grp, idx)
        }
        acc
      })
    [= Index]
    [
      #show figure: set block(below: 0.25em, above: 0.25em)
      #metadata("glossary") <in-glossary>
      #print-glossary(
        show-all: true,
        group-sortkey: group => {
          group-order.at(group, default: 999999)
        },
        index-entry-list,
      )
    ]
  }
}

// MACROS
// Inline code
#let c(code, lang: "text") = context {
  let colors = _colors.get()
  box(
    fill: colors.code-colors.bg,
    inset: (x: 0.3em, y: 0em),
    outset: (y: 0.3em),
    radius: 0.15em,
    raw(code, lang: lang),
  )
}

// Title
#let date = datetime.today().display("[month repr:long] [day], [year]")
#let make-title(show-outline: true, show-underline: true, centered: true) = context {
  let colors = _colors.get()
  let title = _title.get()
  let course = _course.get()

  place(
    top + center,
    float: true,
    scope: "parent",
    clearance: 2em,
  )[
    #pad(
      top: 4pt,
      align(if centered { center } else { left })[
        #block(text(
          fill: colors.heading-colors.at("1", default: black),
          size: 18pt,
          weight: "semibold",
          [#course -- #title],
        ))
        #if show-underline [
          #line(
            length: 100%,
            stroke: 0.1em + colors.heading-colors.at("1", default: black),
          )
        ]
        #v(1em)
        #if show-outline [
          #outline(title: none, depth: 2)
        ]
      ],
    )
  ]
}

// Boxes
#let bbox(title, body, show-title: true) = context {
  let colors = _colors.get()

  let frame-config = (
    body-color: colors.code-colors.bg,
    radius: 4pt,
    thickness: 0.1em,
  )
  showybox(
    ..if show-title { (title: title) },
    frame: frame-config,
    body-style: (color: colors.text-colors.muted),
    [
      #in-box.update(true)
      #show heading: it => {
        set text(fill: colors.text-colors.muted)
        block({
          it.body
        })
      }
      #set heading(numbering: none)
      #show strong: set text(fill: colors.text-colors.muted)
      #show emph: set text(fill: colors.text-colors.muted)
      #body
      #in-box.update(false)
    ],
  )
}

#let info(title, body, show-title: true) = context {
  let colors = _colors.get()

  show: zebraw.with(
    background-color: colors.boxes.info.code.bg,
    highlight-color: colors.boxes.info.code.highlight,
    numbering-font-args: (fill: colors.boxes.info.code.numbers),
  )

  let frame-config = (
    title-color: colors.boxes.info.header,
    border-color: colors.boxes.info.header,
    body-color: colors.boxes.info.bg,
    radius: 0.4em,
    thickness: 0.1em,
  )

  showybox(
    ..if show-title {
      (
        title: [#fa-info-circle(size: 0.9em) #h(0.25em) #title],
        title-style: (color: colors.boxes.info.bg),
      )
    },
    body-style: (color: colors.boxes.info.text),
    frame: frame-config,
    [
      #in-box.update(true)
      #show heading: it => {
        set text(fill: colors.boxes.info.text)
        block({
          it.body
        })
      }
      #set heading(numbering: none)
      #show strong: set text(fill: colors.boxes.info.text)
      #show emph: set text(fill: colors.boxes.info.text)
      #body
      #in-box.update(false)
    ],
  )
}

#let important(title, body, show-title: true) = context {
  let colors = _colors.get()

  show: zebraw.with(
    background-color: colors.boxes.important.code.bg,
    highlight-color: colors.boxes.important.code.highlight,
    numbering-font-args: (fill: colors.boxes.important.code.numbers),
  )

  let frame-config = (
    title-color: colors.boxes.important.header,
    border-color: colors.boxes.important.header,
    body-color: colors.boxes.important.bg,
    radius: 0.4em,
    thickness: 0.1em,
  )

  showybox(
    ..if show-title {
      (
        title: [#fa-triangle-exclamation(size: 0.9em) #h(0.25em) #title],
        title-style: (color: colors.boxes.important.bg),
      )
    },
    body-style: (color: colors.boxes.important.text),
    frame: frame-config,
    [
      #in-box.update(true)
      #show heading: it => {
        set text(fill: colors.boxes.important.text)
        block({
          it.body
        })
      }
      #set heading(numbering: none)
      #show strong: set text(fill: colors.boxes.important.text)
      #show emph: set text(fill: colors.boxes.important.text)
      #body
      #in-box.update(false)
    ],
  )
}

#let example(title, body, show-title: true) = context {
  let colors = _colors.get()

  show: zebraw.with(
    background-color: colors.boxes.example.code.bg,
    highlight-color: colors.boxes.example.code.highlight,
    numbering-font-args: (fill: colors.boxes.example.code.numbers),
  )

  let frame-config = (
    title-color: colors.boxes.example.header,
    border-color: colors.boxes.example.header,
    body-color: colors.boxes.example.bg,
    radius: 0.4em,
    thickness: 0.1em,
  )

  showybox(
    ..if show-title {
      (
        title: [#fa-book(size: 0.9em) #h(0.25em) #title],
        title-style: (color: colors.boxes.example.title),
      )
    },
    body-style: (color: colors.boxes.example.text),
    frame: frame-config,
    [
      #in-box.update(true)
      #show heading: it => {
        set text(fill: colors.boxes.example.text)
        block({
          it.body
        })
      }
      #set heading(numbering: none)
      #show strong: set text(fill: colors.boxes.example.text)
      #show emph: set text(fill: colors.boxes.example.text)
      #body
      #in-box.update(false)
    ],
  )
}

#let aside(title, body, show-title: true) = context {
  let colors = _colors.get()
  show: zebraw.with(
    background-color: colors.boxes.aside.code.bg,
    highlight-color: colors.boxes.aside.code.highlight,
    numbering-font-args: (fill: colors.boxes.aside.code.numbers),
  )

  let frame-config = (
    title-color: colors.boxes.aside.header,
    border-color: colors.boxes.aside.header,
    body-color: colors.boxes.aside.bg,
    radius: 0.4em,
    thickness: 0.1em,
  )

  counter("aside").step()

  showybox(
    ..if show-title {
      (
        title: [
          #in-box.update(true)
          #text(fill: colors.boxes.aside.title)[_Aside_ #context {
            let section = counter(heading).get().first()
            let aside-num = counter("aside").display()
            [#section.#aside-num]
          }: #title]
          #in-box.update(false)  
        ],
      )
    },
    body-style: (color: colors.boxes.aside.text),
    frame: frame-config,
    [
      #in-box.update(true)
      #show heading: it => {
        set text(fill: colors.boxes.aside.text)
        block({
          it.body
        })
      }
      #set heading(numbering: none)
      #show strong: set text(fill: colors.boxes.aside.text)
      #show emph: set text(fill: colors.boxes.aside.text)
      #body
      #in-box.update(false)
    ],
  )
}
