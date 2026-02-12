#import "@preview/zebraw:0.6.0": *
#import "@preview/showybox:2.0.4": showybox
#import "@preview/glossarium:0.5.9": gls, glspl, make-glossary, print-glossary, register-glossary
#import "@preview/fontawesome:0.6.0": *

// Typsidian Template
// Required fonts: Fira Sans, Fira Code, Fira Math, Fontawesome Font (for icons)
// https://fonts.google.com/specimen/Fira+Sans
// https://fonts.google.com/specimen/Fira+Code
// https://github.com/firamath/firamath/releases/
// https://fontawesome.com/download
//
// Typst for Obsidian plugin: https://github.com/k0src/Typst-for-Obsidian

// STATE

#let in-box = state("in-box", false)
#let _title = state("template-title", "")
#let _course = state("template-course", "")
#let _author = state("template-author", "")

// Color scheme
#let _colors = state("template-colors", (
  light: (
    typography: (
      bg: rgb("#ffffff"),
      text: rgb("#222222"),
      link: rgb("#4a56d4"),
      bold: rgb("#3f4bc6"),
      emph: rgb("#3f4bc6"),
      muted: rgb("#6a6a6a"),
      headings: (
        "1": rgb("#222222"),
        "2": rgb("#3f4bc6"),
        "3": rgb("#4a56d4"),
        "4": rgb("#5561de"),
        "5": rgb("#5f6ae6"),
        "6": rgb("#353fae"),
      ),
    ),
    boxes: (
      default: (
        bg: rgb("#fafafa"),
        bg-alt: rgb("#f0f0f0"),
        numbers: rgb("#ababab"),
        highlight: rgb("#ffffff"),
      ),
      example: (
        header: rgb("#8b6fb3"),
        bg: rgb("#f4f0f8"),
        text: rgb("#3d2b54"),
        code-bg: rgb("#f9f6fc"),
        code-numbers: rgb("#b0a6b8"),
        code-highlight: rgb("#f4f0f8"),
      ),
      info: (
        header: rgb("#7aa2f7"),
        bg: rgb("#edf2fb"),
        text: rgb("#1f355a"),
        code-bg: rgb("#f4f7fd"),
        code-numbers: rgb("#a4adb8"),
        code-highlight: rgb("#edf2fb"),
      ),
      important: (
        header: rgb("#c77a98"),
        bg: rgb("#f7edf2"),
        text: rgb("#4a1f32"),
        code-bg: rgb("#fbf4f7"),
        code-numbers: rgb("#b0a4aa"),
        code-highlight: rgb("#f7edf2"),
      ),
      aside: (
        header: rgb("#6f8fb3"),
        bg: rgb("#f0f4f8"),
        text: rgb("#2b3f54"),
        code-bg: rgb("#f6f9fc"),
        code-numbers: rgb("#a6b0b8"),
        code-highlight: rgb("#f0f4f8"),
      ),
      highlight: (
        header: rgb("#5fa89a"),
        bg: rgb("#eef7f5"),
        text: rgb("#1f4a42"),
        code-bg: rgb("#f4faf8"),
        code-numbers: rgb("#a4b5b0"),
        code-highlight: rgb("#eef7f5"),
      ),
    ),
  ),
  dark: (
    typography: (
      bg: rgb("#1e1e1e"),
      text: rgb("#dadada"),
      link: rgb("#8f9cff"),
      bold: rgb("#9aa5ff"),
      emph: rgb("#9aa5ff"),
      muted: rgb("#a6a6a6"),
      headings: (
        "1": rgb("#dadada"),
        "2": rgb("#9aa5ff"),
        "3": rgb("#8f9cff"),
        "4": rgb("#7f8cff"),
        "5": rgb("#a3abff"),
        "6": rgb("#6f7cff"),
      ),
    ),
    boxes: (
      default: (
        bg: rgb("#242424"),
        bg-alt: rgb("#2E2E2E"),
        numbers: rgb("#666666"),
        highlight: rgb("#292929"),
      ),
      example: (
        header: rgb("#b28bb8"),
        bg: rgb("#241c27"),
        text: rgb("#e0c6e4"),
        code-bg: rgb("#1f1722"),
        code-numbers: rgb("#9a7fa0"),
        code-highlight: rgb("#2f2434"),
      ),
      info: (
        header: rgb("#7aa2f7"),
        bg: rgb("#171e2b"),
        text: rgb("#b6c9f5"),
        code-bg: rgb("#121824"),
        code-numbers: rgb("#7289b0"),
        code-highlight: rgb("#1f2a3d"),
      ),
      important: (
        header: rgb("#e394b4"),
        bg: rgb("#24181f"),
        text: rgb("#f0b8cf"),
        code-bg: rgb("#1f1318"),
        code-numbers: rgb("#a07287"),
        code-highlight: rgb("#2f1d26"),
      ),
      aside: (
        header: rgb("#7fa6b8"),
        bg: rgb("#1c2327"),
        text: rgb("#bcd6e0"),
        code-bg: rgb("#171d21"),
        code-numbers: rgb("#7f95a0"),
        code-highlight: rgb("#232c30"),
      ),
      highlight: (
        header: rgb("#6fb3a5"),
        bg: rgb("#1d2926"),
        text: rgb("#b8e0d8"),
        code-bg: rgb("#182421"),
        code-numbers: rgb("#7fa59d"),
        code-highlight: rgb("#243230"),
      ),
    ),
  ),
))

#let typsidian(
  title: "Your Title",
  author: "Your Name",
  course: "COURSE101",
  text-args: (:),
  show-index: false,
  index-entry-list: array,
  theme: "light",
  show-heading-colors: true,
  show-bold-color: false,
  show-italic-color: false,
  standalone: true,
  body,
) = {
  let _text-args = (
    main: (
      font: "Fira Sans",
      weight: "regular",
      size: 9.6pt,
    ),
    mono: (
      font: "Fira Code",
      weight: "regular",
      size: 1.05em,
    ),
    headings: (
      font: "Fira Sans",
      numbering: "1.",
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
        "5": true,
        "6": true,
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

  let color-scheme = (
    light: (
      typography: (
        bg: rgb("#ffffff"),
        text: rgb("#222222"),
        link: rgb("#4a56d4"),
        bold: rgb("#3f4bc6"),
        emph: rgb("#3f4bc6"),
        muted: rgb("#6a6a6a"),
        headings: (
          "1": rgb("#222222"),
          "2": rgb("#3f4bc6"),
          "3": rgb("#4a56d4"),
          "4": rgb("#5561de"),
          "5": rgb("#5f6ae6"),
          "6": rgb("#353fae"),
        ),
      ),
      boxes: (
        default: (
          bg: rgb("#fafafa"),
          bg-alt: rgb("#f0f0f0"),
          numbers: rgb("#ababab"),
          highlight: rgb("#ffffff"),
        ),
        example: (
          header: rgb("#8b6fb3"),
          bg: rgb("#f4f0f8"),
          text: rgb("#3d2b54"),
          code-bg: rgb("#f9f6fc"),
          code-numbers: rgb("#b0a6b8"),
          code-highlight: rgb("#f4f0f8"),
        ),
        info: (
          header: rgb("#7aa2f7"),
          bg: rgb("#edf2fb"),
          text: rgb("#1f355a"),
          code-bg: rgb("#f4f7fd"),
          code-numbers: rgb("#a4adb8"),
          code-highlight: rgb("#edf2fb"),
        ),
        important: (
          header: rgb("#c77a98"),
          bg: rgb("#f7edf2"),
          text: rgb("#4a1f32"),
          code-bg: rgb("#fbf4f7"),
          code-numbers: rgb("#b0a4aa"),
          code-highlight: rgb("#f7edf2"),
        ),
        aside: (
          header: rgb("#6f8fb3"),
          bg: rgb("#f0f4f8"),
          text: rgb("#2b3f54"),
          code-bg: rgb("#f6f9fc"),
          code-numbers: rgb("#a6b0b8"),
          code-highlight: rgb("#f0f4f8"),
        ),
        highlight: (
          header: rgb("#5fa89a"),
          bg: rgb("#eef7f5"),
          text: rgb("#1f4a42"),
          code-bg: rgb("#f4faf8"),
          code-numbers: rgb("#a4b5b0"),
          code-highlight: rgb("#eef7f5"),
        ),
      ),
    ),
    dark: (
      typography: (
        bg: rgb("#1e1e1e"),
        text: rgb("#dadada"),
        link: rgb("#8f9cff"),
        bold: rgb("#9aa5ff"),
        emph: rgb("#9aa5ff"),
        muted: rgb("#a6a6a6"),
        headings: (
          "1": rgb("#dadada"),
          "2": rgb("#9aa5ff"),
          "3": rgb("#8f9cff"),
          "4": rgb("#7f8cff"),
          "5": rgb("#a3abff"),
          "6": rgb("#6f7cff"),
        ),
      ),
      boxes: (
        default: (
          bg: rgb("#242424"),
          bg-alt: rgb("#2E2E2E"),
          numbers: rgb("#666666"),
          highlight: rgb("#292929"),
        ),
        example: (
          header: rgb("#b28bb8"),
          bg: rgb("#241c27"),
          text: rgb("#e0c6e4"),
          code-bg: rgb("#1f1722"),
          code-numbers: rgb("#9a7fa0"),
          code-highlight: rgb("#2f2434"),
        ),
        info: (
          header: rgb("#7aa2f7"),
          bg: rgb("#171e2b"),
          text: rgb("#b6c9f5"),
          code-bg: rgb("#121824"),
          code-numbers: rgb("#7289b0"),
          code-highlight: rgb("#1f2a3d"),
        ),
        important: (
          header: rgb("#e394b4"),
          bg: rgb("#24181f"),
          text: rgb("#f0b8cf"),
          code-bg: rgb("#1f1318"),
          code-numbers: rgb("#a07287"),
          code-highlight: rgb("#2f1d26"),
        ),
        aside: (
          header: rgb("#7fa6b8"),
          bg: rgb("#1c2327"),
          text: rgb("#bcd6e0"),
          code-bg: rgb("#171d21"),
          code-numbers: rgb("#7f95a0"),
          code-highlight: rgb("#232c30"),
        ),
        highlight: (
          header: rgb("#6fb3a5"),
          bg: rgb("#1d2926"),
          text: rgb("#b8e0d8"),
          code-bg: rgb("#182421"),
          code-numbers: rgb("#7fa59d"),
          code-highlight: rgb("#243230"),
        ),
      ),
    ),
  )

  let theme-colors = if theme == "dark" { color-scheme.dark } else { color-scheme.light }

  let colors = (
    bg: theme-colors.typography.bg,
    heading-colors: theme-colors.typography.headings,
    text-colors: (
      main: theme-colors.typography.text,
      link: theme-colors.typography.link,
      bold: theme-colors.typography.bold,
      emph: theme-colors.typography.emph,
      muted: theme-colors.typography.muted,
    ),
    box-colors: theme-colors.boxes.default,
    boxes: theme-colors.boxes,
  )

  _colors.update(colors)

  set par(
    leading: 0.8em,
  )

  // Text & Raw Text
  show raw: set text(
    font: merged-text-args.mono.at("font", default: "Fira Code"),
    weight: merged-text-args.mono.at("weight", default: "regular"),
    size: merged-text-args.mono.at("size", default: 1.05em),
  )
  set text(
    font: merged-text-args.main.at("font", default: "Fira Sans"),
    weight: merged-text-args.main.at("weight", default: "regular"),
    size: merged-text-args.main.at("size", default: 9.6pt),
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
    weight: merged-text-args.math.at("weight", default: 400),
  )
  set math.mat(delim: "[")
  show math.equation: set block(spacing: 1.05em)

  // Figures
  show figure: set block(spacing: 1.5em)
  show figure: it => {
    set align(center)
    it.body
    if (it.caption != none) {
      block(width: 95%)[
        #text(size: 0.8em, font: "Open Sans")[
          #emph[#it.supplement #context it.counter.display(it.numbering):] #it.caption.body
        ]
      ]
    }
  }

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
    fill: (_, y) => if calc.odd(y) { colors.box-colors.bg },
  )

  // Code blocks
  show: zebraw-init.with(
    background-color: colors.box-colors.bg,
    lang: false,
    indentation: 2,
    highlight-color: colors.box-colors.highlight,
    numbering-font-args: (fill: colors.box-colors.numbers),
    inset: (
      top: 0.34em,
      right: 0.34em,
      bottom: 0.34em,
      left: 0.34em,
    ),
    radius: 0.2em,
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
    fill: colors.box-colors.bg,
    inset: (x: 0.3em, y: 0em),
    outset: (y: 0.3em),
    radius: 0.15em,
    raw(code, lang: lang),
  )
}

// Title
#let date = datetime.today().display("[month repr:long] [day], [year]")
#let make-title(show-outline: true, show-underline: true, show-author: false, justify: "center") = context {
  let colors = _colors.get()
  let title = _title.get()
  let course = _course.get()
  let author = _author.get()

  if justify == "center" {
    pad(
      top: 4pt,
      align(center)[
        #block(text(
          fill: colors.heading-colors.at("1", default: black),
          size: 2em,
          weight: "semibold",
          [#course -- #title],
        ))
        #if show-author [
          #text(
            fill: colors.text-colors.at("muted", default: black),
            size: 1.2em,
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
  } else {
    let alignment = if justify == "left" { left } else { right }
    pad(
      bottom: 0.5em,
      align(alignment)[
        #block([
          #text(
            size: 2em,
            weight: "regular",
            fill: colors.heading-colors.at("1", default: black),
            [#course --],
          )
          #text(
            size: 2em,
            weight: "semibold",
            fill: colors.heading-colors.at("1", default: black),
            [#title],
          )
        ])
        #block(text(
          fill: colors.heading-colors.at("1", default: black).lighten(10%),
          size: 1.1em,
          weight: "regular",
          [#date],
        ))
        #if show-author [
          #block([#text(
            fill: colors.text-colors.at("muted", default: black),
            size: 1.1em,
            weight: "regular",
            [#author],
          )])
        ]
        #if show-underline [
          #line(
            length: 100%,
            stroke: 0.1em + colors.heading-colors.at("1", default: black).lighten(25%),
          )
        ]
        #v(1em)
        #if show-outline [
          #outline(title: none, depth: 2)
        ]
      ],
    )
  }
}

// Section title
#let section-title(title: "", subtitle: none, justify: "center", underline: false, icon: none) = context {
  let colors = _colors.get()

  if justify == "center" {
    pad(
      top: 4pt,
      align(center)[
        #block(text(
          fill: colors.heading-colors.at("1", default: black),
          size: 1.8em,
          weight: "semibold",
          [#if icon != none [#icon #h(0.2em)] #title],
        ))
        #if subtitle != none [
          #text(
            fill: colors.text-colors.at("muted", default: black),
            size: 1.1em,
            weight: "regular",
            subtitle,
          )
        ]
        #if underline [
          #v(0.3em)
          #line(
            length: 60%,
            stroke: 0.08em + colors.heading-colors.at("1", default: black).lighten(25%),
          )
        ]
      ],
    )
  } else {
    let alignment = if justify == "left" { left } else { right }
    pad(
      bottom: 0.5em,
      align(alignment)[
        #block(text(
          size: 1.8em,
          weight: "semibold",
          fill: colors.heading-colors.at("1", default: black),
          [#if icon != none [#icon #h(0.2em)] #title],
        ))
        #if subtitle != none [
          #block(text(
            fill: colors.text-colors.at("muted", default: black),
            size: 1.1em,
            weight: "regular",
            subtitle,
          ))
        ]
        #if underline [
          #v(0.2em)
          #line(
            length: 40%,
            stroke: 0.08em + colors.heading-colors.at("1", default: black).lighten(25%),
          )
        ]
      ],
    )
  }
}

// Boxes
#let get-box-config(theme, colors, box-radius, box-thickness) = {
  let configs = (
    info: (
      icon: fa-info-circle(size: 0.9em),
      colors: colors.boxes.info,
    ),
    important: (
      icon: fa-triangle-exclamation(size: 0.9em),
      colors: colors.boxes.important,
    ),
    example: (
      icon: fa-book(size: 0.9em),
      colors: colors.boxes.example,
    ),
    aside: (
      icon: none,
      colors: colors.boxes.aside,
    ),
  )

  if theme in configs {
    let cfg = configs.at(theme)
    return (
      zebra-bg: cfg.colors.code-bg,
      zebra-highlight: cfg.colors.code-highlight,
      zebra-numbers: cfg.colors.code-numbers,
      frame: (
        title-color: cfg.colors.header,
        border-color: cfg.colors.header,
        body-color: cfg.colors.bg,
        radius: box-radius,
        thickness: box-thickness,
      ),
      body-color: cfg.colors.text,
      title-icon: cfg.icon,
      title-color: cfg.colors.bg,
    )
  } else if theme == "definition" {
    (
      zebra-bg: colors.box-colors.bg-alt,
      zebra-highlight: none,
      zebra-numbers: none,
      frame: (
        border-color: colors.text-colors.main,
        radius: box-radius,
        thickness: box-thickness,
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
        title-color: colors.box-colors.bg,
        border-color: colors.text-colors.muted,
        thickness: (left: 0.1em),
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
  } else if theme == "highlight" {
    (
      zebra-bg: colors.boxes.highlight.code-bg,
      zebra-highlight: colors.boxes.highlight.code-highlight,
      zebra-numbers: colors.boxes.highlight.code-numbers,
      frame: (
        title-color: colors.boxes.highlight.header,
        border-color: colors.boxes.highlight.header,
        thickness: (left: 0.1em),
        radius: 0pt,
        body-color: colors.boxes.highlight.bg,
      ),
      body-color: colors.boxes.highlight.text,
      title-style: (
        weight: 500,
        color: white,
        sep-thickness: 0pt,
        align: center,
      ),
      title-icon: none,
      title-color: none,
    )
  } else {
    (
      zebra-bg: colors.box-colors.bg-alt,
      zebra-highlight: none,
      zebra-numbers: none,
      frame: (
        body-color: colors.box-colors.bg,
        border-color: colors.text-colors.muted,
        radius: box-radius,
        thickness: box-thickness,
        inset: if title == none { (x: 1em, y: 1.5em) } else { (x: 1em, y: 0.65em) },
      ),
      body-color: colors.text-colors.muted,
      title-icon: none,
      title-color: none,
    )
  }
}

#let box(
  theme: "basic",
  title: none,
  breakable: false,
  body,
  box-radius: 0.2em,
  box-thickness: 0.075em,
  icon: none,
  footer: none,
  inset: (x: 1em, y: 0.65em),
) = context {
  let colors = _colors.get()
  let theme-config = get-box-config(theme, colors, box-radius, box-thickness)

  show: zebraw.with(
    background-color: theme-config.zebra-bg,
    highlight-color: theme-config.at("zebra-highlight", default: none),
    numbering-font-args: if theme-config.at("zebra-numbers", default: none) != none {
      (fill: theme-config.zebra-numbers)
    } else {
      (:)
    },
    numbering: false,
    inset: (top: 0.4em, right: 0.4em, bottom: 0.4em, left: 1em),
    radius: 0.4em,
  )

  let showybox-args = (
    body-style: (color: theme-config.body-color),
    frame: theme-config.frame,
    breakable: breakable,
  )

  if "title-style" in theme-config {
    showybox-args.insert("title-style", theme-config.title-style)
  }

  if title != none {
    let _icon = if icon != none { icon } else { theme-config.title-icon }

    if _icon != none {
      showybox-args.insert("title", [#_icon #h(0.25em) #title])
      if theme-config.title-color != none {
        showybox-args.insert("title-style", (color: theme-config.title-color))
      }
    } else {
      showybox-args.insert("title", title)
    }
  }

  if footer != none {
    showybox-args.insert("footer", footer)
  }

  showybox(
    ..showybox-args,
    [
      #in-box.update(true)
      #show heading: it => {
        set text(fill: theme-config.body-color)
        block({ it.body })
      }
      #set heading(numbering: none)
      #show strong: set text(fill: theme-config.body-color)
      #show emph: set text(fill: theme-config.body-color)
      #body
      #in-box.update(false)
    ],
  )
}

// Horizontal rule
#let hr(pad: 0.1em, dash: "solid", cap: "round") = context {
  let colors = _colors.get()
  [
    #v(pad)
    #line(
      length: 100%,
      stroke: (
        paint: colors.box-colors.numbers,
        thickness: 0.05em,
        dash: dash,
        cap: cap,
      ),
    )
    #v(pad)
  ]
}

// Definition/term
#let term(word, definition, pronunciation: none) = context {
  let colors = _colors.get()

  block(
    width: 100%,
    inset: (left: 1em, top: 0.5em, bottom: 0.5em),
    stroke: (left: 0.1em + colors.boxes.info.header),
    [
      #text(weight: "bold", fill: colors.boxes.info.header, size: 1.1em)[#word]
      #if pronunciation != none [
        #text(fill: colors.text-colors.muted, style: "italic")[ /#pronunciation/]
      ]
      #v(0.2em)
      #text(fill: colors.text-colors.main)[#definition]
    ],
  )
}

// Quick note
#let note(icon: fa-note-sticky(), color: none, body) = context {
  let colors = _colors.get()
  let note-color = if color != none { color } else { colors.boxes.info.header }

  block(
    width: 100%,
    inset: (left: 0.8em, top: 0.8em, bottom: 0.8em, right: 0.8em),
    fill: note-color.lighten(90%),
    stroke: (left: 2pt + note-color),
    radius: 0.2em,
    [#icon #h(0.2em) #body],
  )
}

// Question and answer
#let qa(question, answer) = context {
  let colors = _colors.get()

  block(
    width: 100%,
    inset: 1em,
    fill: colors.boxes.example.bg,
    stroke: 1pt + colors.boxes.example.header,
    radius: 0.3em,
    [
      #text(weight: "bold", fill: colors.boxes.example.header, size: 1.05em)[Q:#h(0.2em)]
      #text(fill: colors.boxes.example.text)[#question]
      #v(0.7em)
      #text(weight: "bold", fill: colors.boxes.example.header, size: 1.05em)[A:#h(0.2em)]
      #text(fill: colors.boxes.example.text)[#answer]
    ],
  )
}
