/**************/
/* PAGE SETUP */
/**************/

// Defining all margins
// Same as the LaTeX template from TypographiX (already validated by DIRCOM)
#let margin-default = (
  top: 40mm,
  bottom: 35mm,
  left: 20mm,
  right: 20mm,
)

//     Bigger margins      yeay
#let margin-despair-mode = (
  top: 1.2 * margin-default.at("top"),
  bottom: 1.2 * margin-default.at("bottom"),
  left: 1.5 * margin-default.at("left"),
  right: 1.5 * margin-default.at("right"),
)

// Applying margins and other page-related setup
#let apply-page(doc, despair-mode: false, first-line-indent-all: auto) = context {
  set page(paper: "a4", margin: if (despair-mode) { margin-despair-mode } else { margin-default })

  let first-line-indent-all = if first-line-indent-all == auto {
    if text.lang == "fr" { true } else { false }
  } else { first-line-indent-all }
  set par(justify: true, first-line-indent: (amount: 20pt, all: first-line-indent-all))

  doc
}

// Applying header and footer setup
#let apply-header-footer(doc, short-title: none) = {
  set page(
    header: {
      grid(
        columns: (1fr, 1fr),
        align(horizon, smallcaps(text(
          fill: rgb("01426A"),
          size: 14pt,
          font: "New Computer Modern",
          weight: "regular",
        )[#short-title])),
        align(right, image("assets/logo-x-ip-paris.svg", height: 20mm)),
      )
    },
    numbering: "1 / 1",
  )
  counter(page).update(1)

  doc
}

/*********/
/* COVER */
/*********/

#let translate-month(month) = {
  // Construction mapping for months
  let t = (:)
  let fr-month-s = (
    "Janv.",
    "Févr.",
    "Mars",
    "Avr.",
    "Mai",
    "Juin",
    "Juill.",
    "Août",
    "Sept.",
    "Oct.",
    "Nov.",
    "Déc.",
  )
  let fr-months-l = (
    "Janvier",
    "Février",
    "Mars",
    "Avril",
    "Mai",
    "Juin",
    "Juillet",
    "Août",
    "Septembre",
    "Octobre",
    "Novembre",
    "Décembre",
  )
  for i in range(12) {
    let idate = datetime(year: 0, month: i + 1, day: 1)
    let ml = idate.display("[month repr:long]")
    let ms = idate.display("[month repr:short]")
    t.insert(ml, fr-months-l.at(i))
    t.insert(ms, fr-month-s.at(i))
  }

  // Translating month
  let fr-month = t.at(month)
  fr-month
}

#let display-date(date, short-month) = {
  context {
    // Getting adapted month string
    let repr = if short-month { "short" } else { "long" }
    let month = date.display("[month repr:" + repr + "]")

    // Translate if necessary
    if text.lang == "fr" {
      month = translate-month(month)
    }

    // Returns month and year
    [#month #str(date.year())]
  }
}

#let cover(
  title,
  author,
  date-start,
  date-end,
  subtitle: none,
  logo: none,
  short-month: false,
  logo-horizontal: true,
) = {
  set page(background: move(dx: 0pt, dy: -13%, image("assets/armes.svg")))
  set text(font: "New Computer Modern Sans", hyphenate: false, fill: rgb(1, 66, 106))
  set align(center)

  v(1.8fr)

  set text(size: 24pt, weight: "bold")
  upper(title)

  v(1.5fr)

  if subtitle != none {
    set text(size: 20pt)
    subtitle
  }

  v(1.5fr)

  set text(size: 18pt, weight: "regular")
  display-date(date-start, short-month)
  [ \- ]
  display-date(date-end, short-month)

  image("assets/filet-court.svg")

  set text(size: 16pt)
  smallcaps(author)

  v(1fr)

  let logo-height = if (logo-horizontal) { 20mm } else { 30mm }
  let path-logo-x = if (logo-horizontal) { "assets/logo-x-ip-paris.svg" } else {
    "assets/logo-x.svg"
  }

  set image(height: logo-height)

  if (logo != none) {
    grid(
      columns: (1fr, 1fr),
      align: center + horizon,
      logo, image(path-logo-x),
    )
  } else {
    grid(columns: 1fr, align: center + horizon, image(path-logo-x))
  }
}

/***********/
/* HEADING */
/***********/

#let apply-heading(doc) = {
  // Numbering parameters
  set heading(numbering: "1.1 ")

  // For some reason, `below: auto` need to be reinserted explicitely for blocks for H1, H2, H3
  // otherwise spacing below is not inserted although `below: auto` is supposedly the default already

  // H1 styling
  show heading.where(level: 1): he => {
    set align(center)
    block(width: 85%, below: auto, {
      set par(justify: false)
      set text(
        size: 20pt,
        weight: "black",
        fill: rgb("CE0037"),
        font: "New Computer Modern Sans",
        hyphenate: false,
      )
      if type(he.numbering) == str {
        counter(heading).display(he.numbering.slice(0, -3))
        linebreak()
      } else if he.numbering != none {
        upper((he.numbering)(he.level).slice(0, -1))
        linebreak()
      }
      upper(he.body)
      image("assets/filet-long.svg", width: 30%)
      v(0.5em)
    })
  }

  // H2 styling
  show heading.where(level: 2): he => {
    block(below: auto, text(
      size: 20pt,
      weight: "medium",
      fill: rgb("00677F"),
      {
        smallcaps(he)
        v(-0.5em)
        image("assets/filet-court.svg")
      },
    ))
  }

  // H3 styling
  show heading.where(level: 3): he => {
    block(below: auto, text(
      size: 16pt,
      weight: "regular",
      fill: rgb("01426A"),
      {
        if he.numbering != none {
          counter(heading).display(he.numbering).slice(0, -1)
          [ • ]
        }

        smallcaps(he.body)
      },
    ))
  }

  // Don't forget to return doc cause
  // we're in a template
  doc
}

#let appendix(body, title: "Appendix") = {
  counter(heading).update(0)
  // From https://github.com/typst/typst/discussions/3630
  set heading(
    numbering: (..nums) => {
      let vals = nums.pos()
      let s = ""
      if vals.len() == 1 {
        s += title + " "
      }
      s += numbering("A.1 ", ..vals)
      s
    },
  )

  body
}

/***********/
/* OUTLINE */
/***********/

#let apply-outline(doc) = {
  show outline: o => {
    set par(first-line-indent: 0pt)
    o
  }

  // Level 1 headings
  show outline.entry.where(level: 1): i => {
    strong(i)
  }

  // Don't forget to return doc cause
  // we're in a template
  doc
}

/********/
/* MAIN */
/********/

#let apply(doc, despair-mode: false, first-line-indent-all: auto) = {
  show: apply-page.with(despair-mode: despair-mode, first-line-indent-all: first-line-indent-all)
  show: apply-heading
  show: apply-outline
  doc
}
