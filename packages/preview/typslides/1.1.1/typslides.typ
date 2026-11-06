#import "utils.typ": *

#let theme-color = state("theme-color", none)
#let sections = state("sections", ())

#let typslides(
  ratio: "16-9",
  theme: "bluey",
  body,
) = {

  theme-color.update(_theme-colors.at(theme))

  set text(font: "Fira Sans")

  set page(paper: "presentation-" + ratio)

  show ref: it => (
    context {
      text(fill: theme-color.get())[#it]
    }
  )

  show link: it => (
    context {
      text(fill: theme-color.get())[#it]
    }
  )

  body
}

//*************************************** Aux functions ***************************************\\

#let get-color = context {
  theme-color.get()
}

#let stress(body) = (
  context {
    text(fill: theme-color.get(), weight: "semibold")[#body]
  }
)

#let framed(title: none, back-color: none, content) = (
  context {

    set block(
      width: 100%,
      inset: (x: .4cm, top: .5cm, bottom: .5cm),
      breakable: false,
      above: .1cm,
      below: .1cm,
    )

    if title != none {
      stack(
        block(
          fill: theme-color.get(),
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

#let register-section(name) = (
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
) = (
  context {

    // Adapted from: https://github.com/andreasKroepelin/polylux/blob/main/utils/utils.typ

    text(size: 42pt, weight: "bold")[
      #smallcaps(title)
      #v(-.9cm)
      #_divider(color: theme-color.get())
    ]

    set text(size: 24pt)
    set enum(numbering: (it => context text(fill: black)[*#it.*]))

    let sections = sections.final()
    pad(
      enum(
        ..sections.map(section => link(section.loc, section.body)),
      ),
    )

    pagebreak()
  }
)

//**************************************** Title Slide ****************************************\\

#let title-slide(
  body,
) = (
  context {

    set align(left + horizon)
    show heading: text.with(size: 42pt, weight: "semibold")

    register-section(body)

    [= #smallcaps(body)]

    _divider(color: theme-color.get())
  }
)

//**************************************** Focus Slide ****************************************\\

#let focus-slide(
  text-color: white,
  text-size: 60pt,
  body,
) = (
  context {

    set page(
      fill: theme-color.get(),
    )

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
        62%
      } else {
        77%
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
      margin: (x: 1.5cm, top: 2.55cm, bottom: 1.1cm),
      background: place(
        _slide-header(title, theme-color.get()),
      ),
    )

    set list(
      marker: text(theme-color.get(), [•]),
    )

    set enum(numbering: (it => context text(fill: theme-color.get())[*#it.*]))

    set text(size: 20pt)
    set par(justify: true)
    set align(horizon)

    body
  }
)

//**************************************** Bibliography ***************************************\\

#let bibliography-slide(
  bib-path,
  title: "References",
) = (
  context {

    set text(size: 17pt)
    set par(justify: true)

    bibliography(
      bib-path,
      title: text(size: 30pt)[
        #smallcaps(title)
        #v(-.85cm)
        #_divider(color: theme-color.get())
        #v(.5cm)],
    )
  }
)