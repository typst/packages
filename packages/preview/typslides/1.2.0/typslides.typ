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

  set enum(numbering: (it => context text(fill: black)[*#it.*]))

  body
}

//*************************************** Aux functions ***************************************\\

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

#let grayed(
  text-size: 20pt,
  content,
) = {
  set align(center + horizon)
  set text(size: text-size)
  block(
    fill: rgb("#F3F2F0"),
    inset: (x: .8cm, y: .8cm),
    breakable: false,
    above: .75cm,
    below: .15cm,
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

    let sections = sections.final()
    pad(
      enum(
        ..sections.map(section => link(section.loc, section.body)),
      ),
    )

    // Using the default outline() function...
    //
    // set outline(title: none)
    //
    // show outline.entry: it => (
    //   context {
    //     show linebreak: none
    //     let num = text(weight: "bold", fill: theme-color.get())[#it.body.fields().at("children").first()]
    //     let title = text(style: "normal")[#it.body.fields().at("children").last()]
    //     [#num #title]
    //   }
    // )
    //
    // outline()

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

    [= #smallcaps(body)]

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
        15%
      } else {
        45%
      },
      margin: 0cm
      // margin: (x: 1.5cm, top: 1cm, bottom: 1cm),
    )

    set list(
      marker: text(theme-color.get(), [•]),
    )

    align(left + top)[
      #rect(
        fill: theme-color.get(),
        width: 100%,
        inset: .47cm,
        height: if title != none {
          1.5cm
        } else {
          .95cm
        },
        [
          #text(white, weight: "semibold", size: 24pt)[#h(.6cm) #title]
          #let v-num = -1.2cm
          #if title != none {
            v-num = -1.5cm
          }
          #align(right)[
            #text(
              fill: white,
              weight: "semibold",
              size: 12pt,
            )[#v(v-num) #page-num]
          ]
        ],
      )
    ]

    set text(size: 20pt)
    set par(justify: true)

    block(
      inset: (x: 1.2cm, bottom: 1.1cm, top: .6cm),
      body,
    )
  }
)

//**************************************** Bibliography ***************************************\\

#let bibliography-slide(
  bib-path,
  title: "References",
  style: "ieee",
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
      style: style,
    )
  }
)