/**
 * skoltech.typ
 */

#import "/palette.typ": base-colors, dual-colors, skolkovo-green
#import "/util.typ": content-to-string, wrap
#import "/fc.typ": font-config-default, font-config-merge

/**
 * Slide geometry.
 */

#let width = 13.333in
#let height = 7.5in
#let margin = height / 20

// Generate pseudo random sequence of 29 colors (no Skolkovo Green color).
#let make-color-seq(a: 5, b: 0, mod: 29) = {
  return range(29)
    .map(n => 1 + calc.rem(a * n + b, mod))
}

#let color-seq = make-color-seq()

#let h1-to-color(it) = {
  let ix = counter(heading.where(level: 1))
    .at(it.location())
    .at(0)

  // The first header (index 0) corresponds to outline section.
  if ix == 0 {
    return skolkovo-green.values()
  }

  // The rest of sections are colored according a color sequence (indirect
  // indexing).
  let color-ix = color-seq.at(ix - 1)
  let main-color = base-colors.at(color-ix)
  let dual-color = dual-colors.at(color-ix)
  return (main-color, dual-color)
}

#let make-factorial(fill: black, begin: 0, end: 2) = {
  layout(size => {
    let side = size.height / 4
    block(spacing: 0pt, {
      curve(
        fill: fill,
        curve.move((begin * side, 0pt)),
        curve.line((end * side, 0pt)),
        curve.line((0pt, 3 * side)),
        curve.line((side, 3 * side)),
        curve.line((side, 4 * side)),
        curve.line((0pt, 4 * side)),
        curve.line((0pt, 3 * side)),
        curve.close(),
      )
    })
  })
}

#let make-factorial-glyph(begin: 0, end: 2, fill: black) = context {
  let elem = text(top-edge: "ascender", bottom-edge: "baseline")[x]
  let shape = measure(elem)
  box(height: shape.height, {
    make-factorial(begin: begin, end: end, fill: fill)
  })
}

#let factorial = box(make-factorial())

#let make-thx(background: auto, text-color: black, glyph-color: auto) = {
  let glyph-color = if glyph-color == auto {
    text-color
  } else {
    glyph-color
  }

  // Enforce creation of a new page.
  show: body => if background == auto {
    page(body)
  } else {
    page(background: background, body)
  }

  block(width: 100%, height: 100%, {
    set text(size: 280pt, weight: "bold", fill: text-color)
    let glyph = make-factorial-glyph(fill: glyph-color)
    grid(
      rows: (1fr, 1fr),
      columns: (1fr, ),
      align: left + bottom,
      column-gutter: margin,
      row-gutter: margin,
      [], [Thx#glyph],
    )
  })
}

#let make-title-background(
  begin: 0, end: 2,
  background-color: skolkovo-green.main,
  factorial-color: skolkovo-green.dual,
) = {
  let padding = margin
  block(width: 100%, height: 100%, fill: background-color, {
    show: pad.with(x: margin, bottom: padding)
    grid(
      rows: (1fr),
      columns: (auto, 1fr),
      align: left + bottom,
      column-gutter: margin,
      row-gutter: margin,
      make-factorial(begin: begin, end: end, fill:factorial-color),
    )
  })
}


/**
 * make-title - make a title slide.
 */
#let make-title(title, author, date: auto, footer: auto) = {
  let year = if date == auto {
    datetime.today().year()
  } else {
    date.year()
  }

  let (base, dual) = skolkovo-green.values()

  set page(
    margin: (x: 2 * margin, y: 2 * margin),
    footer: align(center + top, {
      set text(size: 14pt)
      if footer != auto {
        footer
      } else if author.institution != none {
        [#author.institution,~#year]
      } else {
        [#year]
      }
    }),
    background: block(width: 100%, height: 100%, fill: base, {
      show: pad.with(x: margin, bottom: margin)
      grid(
        rows: (1fr),
        columns: (auto, 1fr),
        align: left + bottom,
        gutter: margin,
        make-factorial(begin: 1, end: 4, fill: dual))
    }))

  set text(size: 24pt, weight: "regular")
  grid(
    columns: (1fr, auto),
    column-gutter: 2 * margin,
    align: (left + top, right + bottom),
    text(size: 120pt, weight: "bold", title),
    block({
      set align(left)
      set text(size: 24pt)
      set par(spacing: 0.9em)

      // The first block is author's name and (optional) position or role.
      if author.role != none {
        [*#author.name*\ #author.role]
      } else {
        [*#author.name*]
      }

      // The second block is optional (any comment).
      if author.comment != none {
        parbreak()
        author.comment
      }
    }),
  )
}

/**
 * make-outline - make outline side.
 */
#let make-outline() = {
  heading(level: 1, outlined: false)[Outline]
  heading(level: 2, outlined: false)[Outline]
  outline()
}

#let ensure-author(author) = {
  let author = if type(author) == str {
    (name: author)
  } else if type(author) == dictionary {
    author
  }

  author.name = author.at("name", default: [Anonymous])
  author.role = author.at("role", default: none)
  author.institution = author.at("institution", default: [Nowhere])
  author.comment = author.at("comment", default: none)
  return author
}

/**
 * skoltech - main styling rule for slides in Skoltech's brandbook.
 *
 * Args:
 *   title: Paper title.
 *   authors: An information of a single author (presenter).
 *   keywords: Publication keywords (used in PDF metadata).
 *   date: Creation date (used in PDF metadata).
 *   bibliography: Bibliography content.
 *   appendix: Content to append after bibliography section.
 *   aux: An auxilliary settings like font config (see code for details).
 */
#let skoltech(
  title: [],
  authors: (:),
  keywords: (),
  date: auto,
  bibliography: none,
  appendix: none,
  aux: (:),
  body,
) = {
  assert(
    type(authors) in (dictionary, str),
    message: "field `authors` must be either a dictionary or string")
  let author = ensure-author(authors)

  let date = if date == auto {
    datetime.today()
  } else {
    date
  }

  // Prepare font config (FC).
  let fc = font-config-default()
  fc = font-config-merge(fc, aux)

  set document(
    title: title,
    author: content-to-string(author.name),
    keywords: keywords,
    date: date)

  set page(width: width, height: height, margin: margin)

  // According to Skoltech's brandbook, Futura PT by ParaType is a proper type.
  // However, it is a proprietary font. Thus, Jost* is a fallback font.
  //
  // [1]: https://www.paratype.ru/catalog/font/pt/futura-pt
  // [2]: https://indestructibletype.com/Jost
  set text(font: fc.family.sans)
  set text(size: fc.size.normal)
  set par(justify: true, leading: 0.55em, spacing: 0.65em)

  set outline(depth: 1, title: none)
  show outline.entry: it => block({
    set grid.cell(fill: aqua)
    context {
      let ix = counter(heading.where(level: 1))
        .at(it.element.location())
        .at(0)

      let (color, _) = h1-to-color(it.element)
      box(fill: color, outset: 6pt, text(fill: white)[#ix #it.element.body])
    }
    box(width: 1fr, repeat(it.fill))
    it.page()
  })

  show footnote.entry: set text(size: fc.size.footnote)

  show heading.where(level: 1): set text(size: 45pt)
  show heading.where(level: 1): it => context {
    // set page(background: block(width: 100%, height: 100%, fill: none))
    set page(background: make-title-background(begin: 1, end: 3))
    set page(background: {
      let ix = counter(heading.where(level: 1))
        .at(it.location())
        .at(0)
      let (main-color, dual-color) = h1-to-color(it)
      make-title-background(
        begin: 1, end: 3,
        background-color: main-color,
        factorial-color: dual-color)
      })
    pagebreak(weak: true)
    counter(heading.where(level: 1)).step()
    let ix = counter(heading.where(level: 1)).get().at(0)
    let color = base-colors.at(ix)
    block(width: 100%, height: 100%, {
      set text(size: 120pt, weight: "bold")
      grid(
        rows: (1fr, 1fr, 1fr),
        columns: (1fr, ),
        align: left + bottom,
        row-gutter: margin,
        [0#(ix + 0)],
        layout(outside => wrap(
          it.body,
          width: outside.width,
          func: (x, y) => x.join(),
        )),
        layout(outside => wrap(
          it.body,
          width: outside.width,
          func: (x, y) => y.join(),
        )),
      )
    })
  }

  show heading.where(level: 2): set text(size: 48pt, weight: "bold")
  show heading.where(level: 2): it => {
    pagebreak(weak: true)
    it
  }

  show heading.where(level: 3): set heading(outlined: false)
  show heading.where(level: 4): set heading(outlined: false)

  // Configure equation numbering.
  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      let numb = numbering(
        "1",
        ..counter(eq).at(el.location())
      )
      let color = rgb(0%, 8%, 45%)  // Originally `mydarkblue`. :D
      let content = link(el.location(), text(fill: color, numb))
      [(#content)]
    } else {
      return it
    }
  }

  make-title(title, author, date: date)
  make-outline()

  body

  if bibliography != none {
    // Author-year citation style to provide audience more information and
    // context than plain numbers in IEEE-like style.
    set std.bibliography(style: "apa", title: [References])
    bibliography
  }

  make-thx(
    background: block(width: 100%, height: 100%, fill: skolkovo-green.main),
    glyph-color: black)

  // If there is an extra content then render it at the end.
  if appendix != none {
    appendix
  }
}
