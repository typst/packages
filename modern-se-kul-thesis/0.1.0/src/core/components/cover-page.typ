#import "../../assets/text-blobs.typ": submission-text
#let generate-year(academic-year) = [
  #if type(academic-year) == array {
    [#academic-year.at(0) #sym.dash.en #academic-year.at(1)]
  } else {
    let next-year = academic-year + 1
    [#academic-year #sym.dash.en #next-year]
  }
]

#let convert-cmyk(degree) = {
  let clr = cmyk(..degree.map(v => v * 100%))
  let (red, green, blue) = rgb(clr)
    .components()
    .slice(0, 3)
    .map(v => int(v * 255 / 100%))
  let text-clr = if (red * 0.299 + green * 0.587 + blue * 0.114) > 186 {
    black
  } else { white }
  return (clr, text-clr)
}

// TODO: fix error messages + add some standard values
#let insert-cover-page(
  title,
  subtitle,
  authors,
  promotors,
  evaluators,
  supervisors,
  academic-year,
  // An degree dictionary, you should specify a `university`
  // keyword, `school` keyword and a `degree` keyword
  degree,
  english-master,
  // can be an actual image, or just a path to an image
  cover: false,
  lang: "en",
) = {
  // diferent scope so logo and font don't get copied over to all the other pages
  let background-logo
  if lang == "en" {
    background-logo = place(
      top + left,
      dy: 10mm,
      dx: 10mm,
      image(
        format: "svg",
        width: 35%,
        "../../assets/logokuleng.svg",
      ),
    )
  } else if lang == "nl" {
    //TODO: add dutch logo
    background-logo = place(
      top + left,
      dy: 10mm,
      dx: 10mm,
      image(
        format: "svg",
        width: 30%,
        "../../assets/logokul.svg",
      ),
    )
    // logo = image("../../assets/logokuleng.svg")
  } else {
    panic("language not supported")
  }
  page(
    margin: 20mm,
    header: none,
    numbering: none,
    footer: none,
    background: background-logo,
  )[
    #{
      set text(
        font: "Nimbus Sans",
      )
      [
        #v(30%)
        #text(2.25em, weight: 500, title)
        #if subtitle != none {
          v(1em)
          text(1.5em, weight: 300, subtitle)
        }
        #v(40pt)
        #block(height: 67pt)[
          #text(1.4em)[#authors.join("\n")]

        ]

      ]

      set text(size: 12pt)
      // v(30pt)
      set align(right)
      // promotors, evaluators, supervisors
      // width should be 50% of the text box, don't know how to do it in typst
      block(width: 45%)[
        #[
          #set par(leading: 6pt)
          #submission-text(degree.master, degree.elective).at(
            if english-master { "en" } else { "nl" },
          )


        ]

        #let bold-spacing = 8pt
        #if promotors == none {
          panic("You probably need to have a promotor")
        } else {
          v(bold-spacing)
          if english-master {
            [*Supervisor*#if promotors.len() > 1 { [*s*] }: #linebreak()]
          } else {
            [*Promotor*#if promotors.len() > 1 { [*en*] }: #linebreak()]
          }
          par(leading: 5pt)[
            // #v(-0.6em)
            #promotors.join(linebreak())
          ]
          // linebreak()
        }
        #if not cover {
          if evaluators == none {
            // []
          } else {
            v(bold-spacing)
            if english-master {
              [*Assessor*#if evaluators.len() > 1 { [*s*] }: #linebreak()]
            } else {
              [*Evaluator*#if evaluators.len() > 1 { [*en*] }: #linebreak()]
            }
            par(leading: 5pt)[
              // #v(-0.6em)
              #evaluators.join(linebreak())
            ]
            // linebreak()
          }

          if supervisors == none {
            // []
          } else {
            v(bold-spacing)
            if english-master {
              [*Supervisor*#if supervisors.len() > 1 { [*s*] }: #linebreak()]
            } else {
              [*Begeleider*#if supervisors.len() > 1 { [*s*] }: #linebreak()]
            }
            par(leading: 5pt)[
              // #v(-0.6em)
              #supervisors.join(linebreak())
            ]
          }
        }
      ]


      // let degree = (color:none)
      let height = if degree.color != none and cover {
        30pt
      } else {
        15pt
      }

      let title-page-footer = text(1.2em, weight: 500, [
        #if english-master {
          "Academic Year"
        } else {
          "Academiejaar"
        }
        #generate-year(academic-year)
      ])
      title-page-footer += if degree.color != none and cover {
        let (clr, text-clr) = convert-cmyk(degree.color)
        v(15pt)
        rect(width: 190mm, height: 15mm, fill: clr, stroke: none)[#align(
          center + horizon,
        )[#text(fill: text-clr)[#degree.master: #degree.elective]]]
      }
      place(
        center + bottom,
        dy: height,
        title-page-footer,
      )
    }
  ]
}
