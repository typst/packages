#import "utils.typ": *

#let theme-color = state("theme-color", none)
#let sections = state("sections", ())

#let typslides(
  ratio: "16-9",
  theme: "bluey",
  font: "Fira Sans",
  link-style: "color",
  body,
) = {
  if type(theme) == str {
    theme-color.update(_theme-colors.at(theme))
  } else {
    theme-color.update(theme)
  }

  set text(font: font)
  set page(paper: "presentation-" + ratio, fill: white)

  show ref: it => (
    context {
      text(fill: theme-color.get())[#it]
    }
  )

  show link: it => (
    context {
      if it.has("label") {
        text(fill: theme-color.get())[#it]
      } else if link-style == "underline" {
        underline(stroke: theme-color.get())[#it]
      } else if link-style == "both" {
        text(fill: theme-color.get(), underline[#it])
      } else {
        text(fill: theme-color.get())[#it]
      }
    }
  )

  show footnote: it => (
    context {
      text(fill: theme-color.get())[#it]
    }
  )

  set enum(numbering: (it => context text(fill: black)[*#it.*]))

  body
}

//*************************************** Aux functions ***************************************\\

// Theme colors

#let themey(body) = context (text(fill: theme-color.get())[#body])
#let bluey(body) = (text(fill: rgb("3059AB"))[#body])
#let greeny(body) = (text(fill: rgb("28842F"))[#body])
#let reddy(body) = (text(fill: rgb("BF3D3D"))[#body])
#let yelly(body) = (text(fill: rgb("C4853D"))[#body])
#let purply(body) = (text(fill: rgb("862A70"))[#body])
#let dusky(body) = (text(fill: rgb("1F4289"))[#body])

//***************************************************\\

#let stress(body) = (
  context {
    text(fill: theme-color.get(), weight: "semibold")[#body]
  }
)

//***************************************************\\

#let framed(
  title: none,
  back-color: none,
  content,
) = (
  context {
    let w = auto

    set block(
      inset: (x: .6cm, y: .6cm),
      breakable: false,
      above: .1cm,
      below: .1cm,
    )

    if title != none {
      set block(width: 100%)
      stack(
        block(
          fill: theme-color.get(),
          inset: (x: .6cm, y: .55cm),
          radius: (top: .2cm, bottom: 0cm),
          stroke: 2pt,
        )[
          #text(weight: "semibold", fill: white)[#title]
        ],
        block(
          fill: {
            if back-color != none {
              back-color
            } else {
              white
            }
          },
          radius: (top: 0cm, bottom: .2cm),
          stroke: 2pt,
          content,
        ),
      )
    } else {
      stack(
        block(
          width: auto,
          fill: if back-color != none {
            back-color
          } else {
            rgb("FBF7EE")
          },
          radius: (top: .2cm, bottom: .2cm),
          stroke: 2pt,
          content,
        ),
      )
    }
  }
)

//***************************************************\\

// Source: https://github.com/polylux-typ/polylux/blob/main/src/toolbox/toolbox-impl.typ

#let cols(columns: none, gutter: 1em, ..bodies) = {
  let bodies = bodies.pos()

  let columns = if columns == none {
    (1fr,) * bodies.len()
  } else {
    columns
  }

  if columns.len() != bodies.len() {
    panic("Number of columns must match number of content arguments")
  }

  grid(columns: columns, gutter: gutter, ..bodies)
}

//***************************************************\\

#let grayed(
  text-size: 24pt,
  content,
) = {
  set align(center + horizon)
  set text(size: text-size)
  block(
    fill: rgb("#F3F2F0"),
    inset: (x: .8cm, y: .8cm),
    breakable: false,
    above: .9cm,
    below: .9cm,
    radius: (top: .2cm, bottom: .2cm),
  )[#content]
}

//***************************************************\\

#let register-section(
  name,
) = (
  context {
    let sect-page = here().position()
    sections.update(sections => {
      sections.push((body: name, loc: sect-page))
      sections
    })
  }
)

//**************************************** Front Slide ****************************************\\

#let front-slide(
  title: none,
  subtitle: none,
  authors: none,
  info: none,
) = (
  context {
    _make-frontpage(
      title,
      subtitle,
      authors,
      info,
      theme-color.get(),
    )
  }
)

//*************************************** Content Slide ***************************************\\

#let table-of-contents(
  title: "Contents",
  text-size: 23pt,
) = (
  context {
    text(size: 42pt, weight: "bold")[
      #smallcaps(title)
      #v(-.9cm)
      #_divider(color: theme-color.get())
    ]

    set text(size: text-size)

    show linebreak: none

    let sections = query(<section>)

    if sections.len() == 0 {
      let subsections = query(<subsection>)
      pad(enum(..subsections.map(subsection => [#link(subsection.location(), subsection.value) <toc>])))
    } else {
      pad(enum(..sections.map(section => {
        let section_loc = section.location()
        let subsections = query(selector(<subsection>).after(section_loc).before(
          selector(<section>).after(section_loc, inclusive: false)
        ))
        if subsections.len() != 0 {
          [#link(section_loc, section.value) <toc> #list(
            ..subsections.map(subsection => [#link(subsection.location(),
            subsection.value) <toc>])
          )]
        } else {
          [#link(section.location(), section.value) <toc>]
        }
      })))
    }

    pagebreak()
  }
)

//**************************************** Title Slide ****************************************\\

#let title-slide(
  body,
  text-size: 42pt,
) = (
  context {
    register-section(body)

    show heading: text.with(size: text-size, weight: "semibold")

    set align(left + horizon)

    [#heading(depth: 1, smallcaps(body)) #metadata(body) <section>]

    _divider(color: theme-color.get())

    pagebreak()
  }
)

//**************************************** Focus Slide ****************************************\\

#let focus-slide(
  text-color: white,
  text-size: 60pt,
  body,
) = (
  context {
    set page(fill: theme-color.get())

    set text(
      weight: "semibold",
      size: text-size,
      fill: text-color,
      font: "Fira Sans",
    )

    set align(center + horizon)

    _resize-text(body)
  }
)

//****************************************** Slide ********************************************\\

#let slide(
  title: none,
  back-color: white,
  outlined: false,
  body,
) = (
  context {
    let page-num = context counter(page).display(
      "1/1",
      both: true,
    )

    set page(
      fill: back-color,
      header-ascent: if title != none {
        65%
      } else {
        66%
      },
      header: [
        #align(right)[
          #text(
            fill: white,
            weight: "semibold",
            size: 12pt,
          )[#page-num]
        ]
      ],
      margin: if title != none {
        (x: 1.6cm, top: 2.5cm, bottom: 1.2cm)
      } else {
        (x: 1.6cm, top: 1.75cm, bottom: 1.2cm)
      },
      background: place(_slide-header(title, outlined, theme-color.get())),
    )

    set list(marker: text(theme-color.get(), [•]))

    set enum(numbering: (it => context text(fill: theme-color.get())[*#it.*]))

    set text(size: 20pt)
    set par(justify: true)
    set align(horizon)

    v(0cm) // avoids header breaking if body is empty
    body
  }
)

//**************************************** Blank slide ****************************************\\

#let blank-slide(body) = (
  context {
    let page-num = context counter(page).display(
      "1/1",
      both: true,
    )

    set page(
      header: [
        #align(right)[
          #text(
            fill: theme-color.get(),
            weight: "semibold",
            size: 12pt,
          )[#page-num]
        ]
      ],
    )

    set list(marker: text(theme-color.get(), [•]))

    set enum(numbering: (it => context text(fill: theme-color.get())[*#it.*]))

    set text(size: 20pt)
    set par(justify: true)
    set align(horizon)
    body
  }
)

//**************************************** Bibliography ***************************************\\

#let bibliography-slide(
  bib-call,
  title: "References",
) = (
  context {
    set text(size: 19pt)
    set par(justify: true)

    set bibliography(title: text(size: 30pt)[#smallcaps(title) #v(-.85cm) #_divider(color: theme-color.get()) #v(.5cm)])

    bib-call
  }
)
