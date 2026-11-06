
// #import "@preview/t4t:0.4.3": get
// borrowed code for portability
#let all-of-type(t, ..values) = values.pos().all(v => std.type(v) == t)
#let dict-merge(..dicts) = {
  if all-of-type(dictionary, ..dicts.pos()) {
    let c = (:)
    for dict in dicts.pos() {
      for (k, v) in dict {
        if k not in c {
          c.insert(k, v)
        } else {
          let d = c.at(k)
          c.insert(k, dict-merge(d, v))
        }
      }
    }
    return c
  } else {
    return dicts.pos().last()
  }
}
// from https://github.com/typst/typst/issues/1939
#let colorize(svg, color) = {
  let blk = black.to-hex()
    svg.replace(blk, color.to-hex()).replace("<path d=", "<path fill=\"" + color.to-hex() + "\" " + "d=")
}

#let _default-palette(base-colour: rgb("#095a5b") ) = (
  background: (
    base: luma(95%),
    light: luma(98%),
    dark: luma(90%),
  ),
  foreground: (
    base: luma(40%),
    light: luma(50%),
    dark: luma(2%),
  ),
  highlight: (
    base: base-colour,
    light: base-colour.lighten(50%),
    dark: base-colour.darken(50%),
  ),
)


#let _default-fonts(family: "Fira Sans") = (
  main: (
    font: family,
    size: 11pt,
    fill: black,
    features: (onum: 1),
    weight: 400,
  ),
  section: (
    size: 1.05em,
    font: family,
    features: (smcp: 1, c2sc: 1, onum: 1),
    weight: 400,
  ),
  subsection: (
    size: 1em,
    font: family,
    features: (smcp: 1, c2sc: 1),
    weight: 400,
  ),
  subsubsection: (
    size: 0.8em,
    font: family,
    features: (smcp: 1, c2sc: 1),
    weight: 300,
  ),
  title: (
    font: family,
    size: 2em,
    fill: black,
    weight: 500,
  ),
  raw: (
    font: "Fira Code",
    size: 1em,
    features: (onum: 1),
    fill: luma(30%),
    weight: 400,
  ),
  math: (font: "Fira Math"),
)

#let _default-layout = (
  date-width: 2cm, 
  margin-left: 33.5mm, 
  bleed: 6mm)


#let nutshell(
  title: none,
  author: none,
  alsoknown: none,
  nationality: none,
  age: none,
  date: none,
  last-updated: datetime.today().display(),
  contact-details: (:),
  statement: none,
  resume-url: none,
  palette: (:),
  fonts: (:),
  separator: auto,
  layout: (:),
  // The main content.
  body,
) = {
  

  let separator = if separator == auto {
    rect(fill: palette.highlight.light.transparentize(20%), height: 5pt)
  } else {
    separator
  }

  let highlight = palette.highlight.base

  set text(..fonts.main)
  show raw: set text(..fonts.raw)
  show math.equation: set text(..fonts.math)

  set strong(delta: 200)

  let (pagewidth, pageheight, bleed) = (297mm, 420mm, layout.bleed)
  let margin-body-left = layout.margin-left


  let info(body, tracking: 0pt, fill: palette.foreground.base, weight: 200) = {
    set text(
      tracking: tracking,
      weight: weight,
      fill: palette.foreground.base,
      ..fonts.raw,
    )
    raw(body)
  }

  show "•": text.with(fill: palette.highlight.base)

  let contact-row(key, value) = {
    (
      [#text(key, ..fonts.subsubsection, size: 0.9em, weight: "light")],
      [#pad(left: 0.5em)[#value]],
    )
  }

  set page(
    background: rect(
      width: 100%,
      height: 100%,
      fill: palette.background.light,
      stroke: none,
    ),
    footer: context [
      // #set text(size: 0.8em,
      //         features: (onum:1),)
      // #show raw: set text(size: 0.8em)
      #text(..fonts.raw, size: 0.7em)[#last-updated]
      #h(1fr)
      #smallcaps[#lower(author)] | #text(..fonts.raw, size: 0.7em)[#resume-url]
      #h(1fr)
      #text(..fonts.raw, size: 0.7em)[#counter(page).display("1/1", both: true)]

    ],
  )

  grid(
    align: bottom + left,
    columns: (auto, 1fr),
    row-gutter: 0pt,
    align(left)[
      #text(..fonts.title)[#author]
      #v(1.5em, weak: true)
      #title  \
      #nationality \
      #age 
    ],
    align(right)[
      #grid(
        columns: 2,
        row-gutter: 0.5em,
        column-gutter: 0.5em,
        align: (right + bottom, left + bottom),
        grid.vline(
          start: 0,
          end: contact-details.len(),
          x: 1,
          stroke: palette.foreground.light + 0.4pt,
        ),
        ..contact-details
          .pairs()
          .map(it => contact-row(it.at(0), it.at(1)))
          .join(),
      )
    ],
  )

  block(inset: 0.5em)[
    #statement
  ]

  show heading: it => {
    set text(..fonts.section)
    grid(
      columns: (layout.date-width, 1fr),
      column-gutter: .5em,
      align(bottom)[#separator], it.body,
    )
    v(1.2em, weak: true)
  }

  show terms: terms => grid(
    columns: (layout.date-width, 1fr), align: top,
    column-gutter: .5em, row-gutter: if terms.tight { .6em } else { 1em },
    ..terms
      .children
      .map(item => (
        {
          pad(top: 0.2em, text(..fonts.subsubsection)[
            #item.term])
        },
        item.description,
      ))
      .flatten()
  )

  set terms(hanging-indent: layout.date-width)
  show terms.item: it => {
    show "|>": h(1fr)
    it
  }

  body
} // end nutshell


#let nutshell-setup(fonts: (:), palette: (:), layout: (:)) = {
  let layout = dict-merge(_default-layout, layout)

  let palette = dict-merge(_default-palette(), palette)

  let _default-fonts = _default-fonts() // local copy
  _default-fonts.main.fill = palette.foreground.base
  _default-fonts.title.fill = palette.highlight.base
  _default-fonts.section.fill = palette.highlight.base
  _default-fonts.subsection.fill = palette.foreground.dark
  _default-fonts.subsubsection.fill = palette.highlight.base

  let fonts = dict-merge(_default-fonts, fonts)

  let status(body) = text(body, tracking: 0.1pt, ..fonts.subsection)
  let details(body) = text(
    body,
    tracking: 0.2pt,
    ..fonts.subsubsection,
    fill: palette.highlight.base,
    size: 0.9em,
  )

  return (
    nutshell: nutshell.with(fonts: fonts,
      palette: palette, 
      layout: layout),
    fonts: fonts,
    palette: palette,
    layout: layout,
    status: status,
    details: details,
  )
}


// Some fancy logos
// adapted from original by discord user @adriandelgado
#let TeX = context (
  {
    set text(font: "New Computer Modern")
    let e = measure("E")
    let T = "T"
    let E = text(1em, baseline: e.height * 0.31, "E")
    let X = "X"
    box(T + h(-0.15em) + E + h(-0.125em) + X)
  }
)

#let LaTeX = context (
  {
    set text(font: "New Computer Modern")
    let a-size = 0.66em
    let l = measure("L")
    let a = measure(text(a-size, "A"))
    let L = "L"
    let A = box(scale(x: 110%, text(
      a-size,
      baseline: a.height - l.height,
      "A",
    )))
    box(L + h(-a.width * 0.67) + A + h(-a.width * 0.25) + TeX)
  }
)
