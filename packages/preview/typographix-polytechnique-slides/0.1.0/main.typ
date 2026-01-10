#let PALETTE = (
  "blue": rgb("#003E5D"),
  "gold": rgb("#A58B4D"),
  "lighter-blue": rgb("#006881"),
  "gray": rgb("#E7E6E6"),
)
#let PALETTE-AUX = () // TODO

#let MARGIN-FRAME = 6mm
#let BASE-HEIGHT = 19.05cm

#let FONT-SIZES = (24pt, 18pt, 12pt, 10pt, 10pt)

#let FILET-LONG-SIZE = 6.58cm
#let FILET-LONG-SIZE-OUTLINE = 6.4cm

#let DIAG-LINE-SIZE = 0.1mm
#let LENGTH-BETWEEN-FRAME-AND-FILET = 3.22cm
#let SPACING-AFTER-TITLE = 1cm

#let show-bg-lines(width, height) = {
  // We could simplify the expressions below because tan(45deg) = 1
  // But in case anyone wonders how did I come up with that...
  let width-small = height / calc.tan(45deg)
  let overall-width = width + width-small
  let overall-height = calc.tan(45deg) * overall-width
  let overall-hyp = overall-height / calc.sin(45deg)
  let max-height = calc.ceil(overall-height.mm())

  for i in range(0, max-height, step: 2) {
    let sx = if i * 1mm < height { 0mm } else { (i - height.mm()) * calc.tan(45deg) * 1mm }
    let sy = calc.min(i * 1mm, height)
    place(line(
      angle: -45deg,
      start: (sx, sy),
      length: overall-hyp,
      stroke: PALETTE.gold + DIAG-LINE-SIZE,
    ))
  }
}

#let page-background(width, height, is-light: true, dark-frame: false) = {
  if dark-frame {
    place(rect(width: 100%, height: 100%, fill: PALETTE.blue))
  }
  show-bg-lines(width, height)
  rect(
    stroke: 0.2mm + PALETTE.gold,
    width: width - 2 * MARGIN-FRAME,
    height: height - 2 * MARGIN-FRAME,
    fill: if is-light { white } else { PALETTE.blue },
  )
}

// Using the same trick as Diatypst
#let header-page() = context {
  let page = here().page()
  let headings = query(selector(heading.where(level: 2)))
  let heading = headings.rev().find(x => x.location().page() <= page)

  if heading != none {
    block(height: LENGTH-BETWEEN-FRAME-AND-FILET, width: 100%, align(center + horizon, text(
      size: FONT-SIZES.at(0),
      fill: PALETTE.gold,
      weight: "regular",
      {
        heading.body
        [ ]
        if heading.location().page() != page {
          numbering("(i)", page - heading.location().page() + 1)
        }
      },
    )))
    place(center, image("assets/filet-long.svg", width: FILET-LONG-SIZE))
    v(SPACING-AFTER-TITLE)
  }
}

#let render-item-outline(he) = {
  [
    #numbering(he.numbering, counter(heading).at(he.location()).first()) \
    #text(size: FONT-SIZES.at(0), he.body)
    #image("assets/filet-long.svg")
    p. #he.location().page()
  ]
}


#let apply(doc, ratio: 16 / 9, h1-theme: "dark-light", frame-theme: "light") = {
  /***********/
  /* PARSING */
  /***********/
  let H1-THEMES = ("light", "light-dark", "dark-light", "dark")
  if not H1-THEMES.contains(h1-theme) {
    panic(
      "Unexpected value for param 'h1-theme', expected one of the following: 'light', 'light-dark' (light with dark frame), 'dark-light' (dark with light frame), 'dark'",
    )
  }
  let h1-use-light-theme = h1-theme == "light" or h1-theme == "light-dark"
  let h1-dark-frame = h1-theme == "light-dark" or h1-theme == "dark"

  if frame-theme != "light" and frame-theme != "dark" {
    panic("Unexpected value for param 'frame-theme', expected 'light' or 'dark'")
  }
  let slide-dark-frame = frame-theme == "dark"

  if type(ratio) != float {
    panic("Unexpected value for param 'ratio', expected a float")
  }
  let height = BASE-HEIGHT
  let width = ratio * height

  /********/
  /* PAGE */
  /********/
  set page(
    width: width,
    height: height,
    margin: (
      top: MARGIN-FRAME + LENGTH-BETWEEN-FRAME-AND-FILET + SPACING-AFTER-TITLE,
      rest: 2.30cm,
    ),
    background: page-background(width, height, dark-frame: slide-dark-frame),
    footer: place(dx: width - 2.30cm - MARGIN-FRAME - 1.5em, text(
      fill: PALETTE.gold,
      context counter(
        page,
      ).display("1"),
    )),
    header: box(width: 100%, height: 100%, header-page()),
    header-ascent: 0pt,
  )

  /*****************/
  /* GENERAL STYLE */
  /*****************/
  set text(font: "Georgia", fill: PALETTE.blue, size: FONT-SIZES.at(1))
  set heading(numbering: "I")

  /***********/
  /* OUTLINE */
  /***********/
  set outline(depth: 1)
  show outline: o => {
    let headings = query(heading.where(level: 1))
    let nb-heading = headings.len()
    if nb-heading < 2 or nb-heading > 6 {
      set heading(level: 2)
      o
    } else {
      let nb-elem-first-row = if nb-heading in (2, 4) { 2 } else { 3 }
      let nb-elem-snd-row = nb-heading - nb-elem-first-row
      let rows = if nb-elem-snd-row > 0 { (1fr, 1fr) } else { auto }

      [== #o.title]

      v(SPACING-AFTER-TITLE)

      block(height: 100% - SPACING-AFTER-TITLE, align(center + horizon, grid(
        rows: rows,
        align: horizon,
        grid(
          align: center + horizon,
          columns: (1fr,) * nb-elem-first-row,
          ..headings.map(render-item-outline).slice(0, count: nb-elem-first-row),
        ),

        if nb-elem-snd-row > 0 {
          // Special case for nb-heading == 5
          let columns = if nb-heading != 5 { (1fr,) * nb-elem-snd-row } else {
            (0.5fr, 1fr, 1fr, 0.5fr)
          }
          let res = headings
            .map(render-item-outline)
            .slice(nb-elem-first-row, count: nb-elem-snd-row)
          if nb-heading == 5 {
            res.insert(0, [])
          }
          grid(
            align: center + horizon,
            columns: columns,
            ..res
          )
        },
      )))
    }
  }

  /***********/
  /* HEADING */
  /***********/
  let h1-text-color = if h1-use-light-theme { PALETTE.blue } else { white }
  let h1-number-color = if h1-use-light-theme { rgb("#E3DDC9") } else { rgb("#4C788C") }
  show heading.where(level: 1): he => {
    set page(
      header: none,
      footer: none,
      margin: 0cm,
      background: page-background(
        width,
        height,
        is-light: h1-use-light-theme,
        dark-frame: h1-dark-frame,
      ),
    )
    place(center + horizon, text(
      size: 400pt,
      fill: h1-number-color,
      counter(heading).display(he.numbering),
    ))
    align(center + horizon, text(size: 66pt, fill: h1-text-color, weight: "bold", he.body))
  }

  let h2-text-color = PALETTE.gold
  show heading.where(level: 2): he => {
    pagebreak(weak: true)
  }

  doc
}

#let cover(title: none, speaker: none, date: none, background-image: none) = {
  let bg-image = if background-image != none { background-image } else {
    image("assets/boncourt.jpg", width: 100%)
  }
  set page(footer: none)
  set page(background: {
    place(block(width: 100%, height: 100%, bg-image))
    rect(fill: PALETTE.blue.transparentize(30%), width: 100%, height: 100%)
  })
  set page(margin: (top: 2.10cm, left: 1.40cm, bottom: 0.8cm))

  image("assets/logo-x-ip-paris.svg", height: 3.22cm)

  grid(
    columns: 1,
    rows: (1fr, 1.5em, 1fr),
    align(horizon, block(width: 80%, text(fill: white, size: 2 * FONT-SIZES.at(0), title))),
    line(length: 3cm, stroke: PALETTE.gold + 1pt),
    text(fill: PALETTE.gold, size: FONT-SIZES.at(1), speaker),
  )

  place(bottom, text(fill: white, size: FONT-SIZES.at(2), date))
}

#let armes(doc) = {
  place(center + horizon, dy: 6%, image("assets/armes.svg"))

  doc
}
