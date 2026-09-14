#import "@preview/zebraw:0.5.5": *
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
#let _author = state("template-author", "")
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
    bg-alt: rgb("#f0f0f0"),
    numbers: rgb("#ababab"),
    highlight: rgb("#ffffff"),
  ),
  text-colors: (
    main: rgb("222222"),
    link: rgb("#222222"),
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
  text-args: (:),
  show-index: false,
  index-entry-list: array,
  theme: "light",
  show-heading-colors: true,
  show-bold-color: true,
  show-italic-color: true,
  standalone: true,
  body,
) = {
  let _text-args = (
    main: (
      font: "Inter 24pt",
      weight: "regular",
      size: 10pt,
    ),
    mono: (
      font: "GeistMono NFP",
      weight: "regular",
      size: 1em,
    ),
    headings: (
      font: "Inter 24pt",
      numbering: "1.1.1.1.1.1",
      weights: (
        "1": "extrabold",
        "2": "bold",
        "3": "semibold",
        "4": "medium",
        "5": "medium",
        "6": "medium",
      ),
      sizes: (
        "1": 14pt,
        "2": 12pt,
        "3": 11pt,
        "4": 10pt,
        "5": 10pt,
        "6": 10pt,
      ),
      aligns: (
        "1": center,
        "2": left,
        "3": left,
        "4": left,
        "5": left,
        "6": left,
      ),
      small-caps: (
        "1": false,
        "2": false,
        "3": false,
        "4": false,
        "5": false,
        "6": false,
      ),
    ),
    math: (
      font: "Fira Math",
      size: 1em,
      weight: 400,
    ),
  )

  let merged-text-args = _text-args
  for (key, value) in text-args {
    if key in merged-text-args and type(merged-text-args.at(key)) == dictionary and type(value) == dictionary {
      merged-text-args.at(key) = merged-text-args.at(key) + value
    } else {
      merged-text-args.at(key) = value
    }
  }

  let index-entry-list = if type(index-entry-list) == array {
    index-entry-list
  } else {
    (index-entry-list,)
  }

  show: zebraw

  _title.update(title)
  _course.update(course)
  _author.update(author)

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
        bg-alt: rgb("#2E2E2E"),
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
        bg-alt: rgb("#f0f0f0"),
        numbers: rgb("#ababab"),
        highlight: rgb("#ffffff"),
      ),
      text-colors: (
        main: rgb("222222"),
        // link: rgb("#1a2dff"),
        link: rgb("#222222"),
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
    font: merged-text-args.mono.at("font", default: "GeistMono NFP"),
    weight: merged-text-args.mono.at("weight", default: "regular"),
    size: merged-text-args.mono.at("size", default: 1em),
  )
  set text(
    font: merged-text-args.main.at("font", default: "Inter 24pt"),
    weight: merged-text-args.main.at("weight", default: "regular"),
    size: merged-text-args.main.at("size", default: 10pt),
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
  show math.equation: set text(
    font: merged-text-args.math.at("font", default: "Fira Math"), 
    size: merged-text-args.math.at("size", default: 1em),
    weight: merged-text-args.math.at("weight", default: 400)
  )
  set math.mat(delim: "[")
  show math.equation: set block(spacing: 1.05em)

  // Headings
  show heading: set block(below: 1em)
  set heading(numbering: merged-text-args.headings.numbering)

  show heading: it => {
    let level-str = str(it.level)

    let weight = merged-text-args.headings.weights.at(level-str, default: "regular")
    let size = merged-text-args.headings.sizes.at(level-str, default: 10pt)
    let alignment = merged-text-args.headings.aligns.at(level-str, default: left)

    set align(alignment)

    if show-heading-colors {
      set text(
        font: merged-text-args.headings.font,
        weight: weight,
        size: size,
        fill: colors.heading-colors.at(level-str, default: black),
      )
      if merged-text-args.headings.small-caps.at(level-str, default: false) {
        smallcaps(it)
      } else {
        it
      }
    } else {
      set text(
        weight: weight,
        size: size,
        font: merged-text-args.headings.font,
      )
      if merged-text-args.headings.small-caps.at(level-str, default: false) {
        smallcaps(it)
      } else {
        it
      }
    }
  }

  // Lists
  set enum(indent: 0.5em, body-indent: 0.5em)
  set list(indent: 0.5em, body-indent: 0.5em)

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
      if counter(page).get().first() > 1 {
        let h1s = query(selector(heading.where(level: 1)).before(here()))
        let heading-text = if h1s.len() > 0 and h1s.last().body != none {
          let body-str = h1s.last().body
          if body-str != [] and body-str != "" {
            [#sym.dash.em #body-str]
          } else {
            []
          }
        } else {
          []
        }
        text(size: 0.85em)[
          #title #heading-text
          #h(1fr)
          #counter(page).display()
        ]
      }
    },
    footer: context {
      if counter(page).get().first() > 1 {
        text(size: 0.85em)[
          #grid(
            columns: (1fr, 1fr),
            align: (left, right),
            author, course,
          )
        ]
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
      #set heading(numbering: none)
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
#let make-title(show-outline: true, show-underline: true, show-author: false, centered: true) = context {
  let colors = _colors.get()
  let title = _title.get()
  let course = _course.get()
  let author = _author.get()

  pad(
    top: 4pt,
    align(if centered { center } else { left })[
      #block(text(
        fill: colors.heading-colors.at("1", default: black),
        size: 18pt,
        weight: "semibold",
        [#course -- #title],
      ))
      #if show-author [
        #text(
          fill: colors.text-colors.at("muted", default: black),
          size: 12pt,
          weight: "regular",
          [#h(0.5em) #author #h(1em) #date],
        )
      ]
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
}

// Box function
#let box(theme: "basic", title: none, breakable: false, body, box-radius: 0.25em) = context {
  let colors = _colors.get()
  let _box-thickness = 0.1em

  let theme-config = if theme == "info" {
    (
      zebra-bg: colors.boxes.info.code.bg,
      zebra-highlight: colors.boxes.info.code.highlight,
      zebra-numbers: colors.boxes.info.code.numbers,
      frame: (
        title-color: colors.boxes.info.header,
        border-color: colors.boxes.info.header,
        body-color: colors.boxes.info.bg,
        radius: box-radius,
        thickness: _box-thickness,
      ),
      body-color: colors.boxes.info.text,
      title-icon: fa-info-circle(size: 0.9em),
      title-color: colors.boxes.info.bg,
    )
  } else if theme == "important" {
    (
      zebra-bg: colors.boxes.important.code.bg,
      zebra-highlight: colors.boxes.important.code.highlight,
      zebra-numbers: colors.boxes.important.code.numbers,
      frame: (
        title-color: colors.boxes.important.header,
        border-color: colors.boxes.important.header,
        body-color: colors.boxes.important.bg,
        radius: box-radius,
        thickness: _box-thickness,
      ),
      body-color: colors.boxes.important.text,
      title-icon: fa-triangle-exclamation(size: 0.9em),
      title-color: colors.boxes.important.bg,
    )
  } else if theme == "example" {
    (
      zebra-bg: colors.boxes.example.code.bg,
      zebra-highlight: colors.boxes.example.code.highlight,
      zebra-numbers: colors.boxes.example.code.numbers,
      frame: (
        title-color: colors.boxes.example.header,
        border-color: colors.boxes.example.header,
        body-color: colors.boxes.example.bg,
        radius: box-radius,
        thickness: _box-thickness,
      ),
      body-color: colors.boxes.example.text,
      title-icon: fa-book(size: 0.9em),
      title-color: colors.boxes.example.title,
    )
  } else if theme == "aside" {
    (
      zebra-bg: colors.boxes.aside.code.bg,
      zebra-highlight: colors.boxes.aside.code.highlight,
      zebra-numbers: colors.boxes.aside.code.numbers,
      frame: (
        title-color: colors.boxes.aside.header,
        border-color: colors.boxes.aside.header,
        body-color: colors.boxes.aside.bg,
        radius: box-radius,
        thickness: _box-thickness,
      ),
      body-color: colors.boxes.aside.text,
      title-icon: none,
      title-color: colors.boxes.aside.title,
      is-aside: true,
    )
  } else if theme == "theorem" {
    (
      zebra-bg: colors.code-colors.bg-alt,
      zebra-highlight: none,
      zebra-numbers: none,
      frame: (
        border-color: colors.text-colors.main,
        title-color: colors.text-colors.main,
        radius: 1pt,
        thickness: 1pt,
        body-inset: 2em,
        dash: "densely-dashed",
        body-color: colors.bg,
      ),
      body-color: colors.text-colors.muted,
      title-style: (
        weight: 500,
        color: white,
        sep-thickness: 0pt,
      ),
      title-icon: none,
      title-color: none,
    )
  } else if theme == "frame" {
    (
      zebra-bg: colors.bg,
      zebra-highlight: none,
      zebra-numbers: none,
      frame: (
        title-color: colors.code-colors.bg,
        border-color: colors.text-colors.muted,
        thickness: (left: 1pt),
        radius: 0pt,
        body-color: colors.bg,
      ),
      body-color: colors.text-colors.main,
      title-style: (
        weight: 500,
        color: colors.text-colors.main,
        sep-thickness: 0pt,
      ),
      title-icon: none,
      title-color: none,
    )
  } else {
    // basic theme (default)
    (
      zebra-bg: colors.code-colors.bg-alt,
      zebra-highlight: none,
      zebra-numbers: none,
      frame: (
        body-color: colors.code-colors.bg,
        radius: box-radius,
        thickness: _box-thickness,
        inset: if title == none { (x: 1em, y: 1.5em) } else { (x: 1em, y: 0.65em) },
      ),
      body-color: colors.text-colors.muted,
      title-icon: none,
      title-color: none,
    )
  }
  
  // zebraw styling
  show: zebraw.with(
    background-color: theme-config.zebra-bg,
    highlight-color: theme-config.at("zebra-highlight", default: none),
    numbering-font-args: if theme-config.at("zebra-numbers", default: none) != none {
      (fill: theme-config.zebra-numbers)
    } else {
      (:)
    },
    numbering: false,
    inset: (
      top: 0.34em,
      right: 0.34em,
      bottom: 0.34em,
      left: 0.64em,
    ),
  )

  // showybox arguments
  let showybox-args = (
    body-style: (color: theme-config.body-color),
    frame:  theme-config.frame,
    breakable: breakable,
  )

  if "title-style" in theme-config {
    showybox-args.insert("title-style", theme-config.title-style)
  }

  if title != none {
    if theme-config.at("is-aside", default: false) {
      counter("aside").step()
      showybox-args.insert("title", [
        #in-box.update(true)
        #text(fill: theme-config.title-color)[_Aside_ #context {
            let section = counter(heading).get().first()
            let aside-num = counter("aside").display()
            [#section.#aside-num]
          }: #title]
        #in-box.update(false)
      ])
    } else if theme-config.title-icon != none {
      showybox-args.insert("title", [#theme-config.title-icon #h(0.25em) #title])
      if theme-config.title-color != none {
        showybox-args.insert("title-style", (color: theme-config.title-color))
      }
    } else {
      showybox-args.insert("title", title)
    }
  } 
  
  // Render the box
  showybox(
    ..showybox-args,
    [
      #in-box.update(true)
      #show heading: it => {
        set text(fill: theme-config.body-color)
        block({
          it.body
        })
      }
      #set heading(numbering: none)
      #show strong: set text(fill: theme-config.body-color)
      #show emph: set text(fill: theme-config.body-color)
      #body
      #in-box.update(false)
    ],
  )
}

#let hr(pad: 0.1em) = context {
  let colors = _colors.get()
  [
    #v(pad)
    #line(length: 100%, stroke: 0.05em + colors.code-colors.numbers)
    #v(pad)
  ]
}