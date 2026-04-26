#import "cfg.typ"
#import "checkbox.typ"
#import "info.typ"
#import "keywords.typ"
#import "palette.typ": *
#import "presentation.typ"
#import "util.typ": *

#let _styling(body, ..args) = {
  if not cfg.render {
    return {
      // PERF: consistently shaves off 0.02 seconds of query time
      // tested on i7 10th gen
      set page(width: auto, height: auto)
      set text(size: 0pt)

      // purely to make references not crash when querying
      set heading(numbering: "1.1")

      body
    }
  }

  let args = args.named()

  set page(
    fill: bg,
    numbering: "1 / 1",
  )
  set text(
    fill: fg,
    lang: args.at("lang", default: "en"),
  )

  set rect(stroke: fg)
  set line(stroke: fg)
  set table(stroke: (x, y) => {
    if x > 0 { (left: gamut.sample(30%)) }
    if y > 0 { (top: gamut.sample(30%)) }
  })

  set heading(numbering: "1.1")

  set outline(
    indent: auto,
    fill: move(
      dy: -0.25em,
      line(length: 100%, stroke: gamut.sample(15%)),
    ),
  )

  set math.equation(numbering: "(1)")
  set math.mat(delim: "[")
  set math.vec(delim: "[")

  show "->": sym.arrow
  show "=>": sym.arrow.double
  show "!=": sym.eq.not

  show ref: text.with(fill: reference.same-file)

  show ref: text.with(fill: reference.same-file)
  show link: it => {
    let accent = if type(it.dest) == str {
      reference.external
    } else {
      reference.same-file
    }
    let ret = text(fill: accent, it)
    if not cfg.dev { ret = underline(ret) }
    ret
  }
  show raw.where(block: false): it => highlight(
    top-edge: 0.9em,
    bottom-edge: -0.25em,
    fill: luma(0%),
    text(if cfg.dev { fg } else { luma(100%) }, it),
  )
  show raw.where(block: true): it => block(
    fill: luma(0%),
    width: 100%,
    inset: 0.75em,
    text(if cfg.dev { fg } else { luma(100%) }, it),
  )
  show table: align.with(center)

  body
}

#let _shared(args) = {
  let args = info.preprocess(args.named())
  let title = args.at("title", default: {
    if cfg.filename != none {
      cfg.filename.trim(
        ".typ",
        repeat: false,
      )
    } else {
      "Untitled"
    }
  })

  (args: args, title: title)
}

/// The args sink is used as metadata.
/// It'll exposed both in a table in the document and via `typst query`.
/// See the manual for details.
#let generic(body, ..args) = {
  let (args, title) = _shared(args)

  show: _styling.with(..args)
  show: keywords.process.with(cfg: args.at("keywords", default: none))
  show: checkbox.process

  set document(
    title: title,
    author: args.at("author", default: ()),
  )

  info.queryize(args)

  body
}

/// Compromise between generic and note.
/// Does not display any content but uses nice, legible fonts.
#let modern(body, ..args) = {
  set text(font: "IBM Plex Sans", size: 14pt)
  show raw: set text(font: "JetBrainsMonoNL NF", weight: "light")

  show: generic.with(..args)

  body
}

#let gfx(body, ..args) = {
  show: modern.with(..args)
  set page(width: auto, height: auto)

  body
}

#let note(body, ..args) = {
  show: modern.with(..args)

  if cfg.render {
    let (args, title) = _shared(args)

    text(2.5em, strong(title))

    if args.len() > 0 {
      v(-1.75em)
      info.render(args)
      separator
    }

    // Are there any headings? If so, no need to render an outline.
    context {
      if query(heading).len() > 0 {
        v(-0.75em)
        outline()
        separator
      }
    }
  }

  body
}

#let latex-esque(body, ..args) = {
  set text(font: "New Computer Modern", size: 12pt)
  show raw: set text(font: "FiraCode Nerd Font Mono")

  show: generic.with(..args)

  set par(justify: true)
  set outline(
    title: [Table of contents],
    fill: repeat[.],
  )

  if cfg.render {
    let (args, title) = _shared(args)

    let title = text(2em, strong(title))

    let extra = args
      .pairs()
      .filter(((key, value)) => key != "title")
      .map(((key, value)) =>
        (
          (upper(key.at(0)) + key.slice(1))
            .replace("Cw", "Content warning"),
          if type(value) in (str, int, float, content) {
            value
          } else if type(value) == array {
            value.join([, ], last: [ and ])
          } else if type(value) == dictionary {
            value.keys().join[, ]
          } else {
            repr(value)
          }
        )
        .join[: ]
      )
      .join[\ ]

    align(center, {
      title
      [\ ]
      v(0.25em)
      extra
    })

    outline()
  }

  body
}

#let slides(body, handout: false, ..args) = {
  set text(size: 26pt)

  show: presentation._prelude
  show: modern.with(..args)
  show: it => presentation._process(it, handout: handout, args.named())

  body
}
