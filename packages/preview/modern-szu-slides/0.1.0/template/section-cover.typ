#import "@preview/touying:0.6.1": *

#import "slide-text.typ": *

#let thesis-title = [Your Thesis Title Here]
#let cover-title = [Your Thesis Title Here]
#let thesis-subtitle = [Master's Thesis Defense]
#let college-name = [Department Name]
#let major-name = [Your Major]
#let candidate-name = [Your Name]
#let advisor-names = [Advisor Name]

#let cover-latin-text-pattern = regex("[A-Za-z0-9][A-Za-z0-9+\\-_/.:,%&()]*")

#let title-slide(
  config: (:),
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(fill: cover-bg, margin: 0pt),
  )
  let info = self.info + args.named()
  let body = {
    set text(font: zh-font, fill: white)
    show cover-latin-text-pattern: set text(font: en-font)
    box(
      width: 100%,
      height: 100%,
    )[
      #grid(
        columns: (1fr),
        rows: (20%, 56%, 24%),
        row-gutter: 0pt,
        block(
          fill: cover-bg,
          inset: 0pt,
        )[
          #pad(left: 1.35em, top: 0.2em)[
            #image("assets/SZU_flag.pdf", width: 35%)
          ]
        ],
        block(
          fill: cover-paper,
          inset: 0pt,
        )[
          #pad(x: 3.0em, y: 3.0em)[
            #grid(
              columns: (1fr),
              gutter: 1.6em,
              [
                #align(center)[
                  #text(size: cover-title-size, weight: "bold", fill: strong-text-fill)[#cover-title]
                ]
                #v(0.5em)
                #line(length: 100%, stroke: 1.8pt + cover-rule)
                #v(1em)
                #align(center)[
                    #grid(
                      columns: (auto, auto, 2.3em, auto, auto),
                      column-gutter: 0.45em,
                      row-gutter: 0pt,
                      align(right + horizon)[
                        #text(size: cover-person-label-size, weight: "medium", fill:strong-text-fill)[答辩人：]
                      ],
                      align(left + horizon)[
                        #text(size: cover-person-value-size, fill: strong-text-fill)[#candidate-name]
                      ],
                      [],
                      align(right + horizon)[
                        #text(size: cover-person-label-size, weight: "medium", fill: strong-text-fill)[指导老师：]
                      ],
                      align(left + horizon)[
                        #text(size: cover-person-value-size, fill: strong-text-fill)[#advisor-names]
                      ],
                    )
                  ]
              ],
            )
          ]
        ],
        block(
          fill: cover-bg,
          inset: 0pt,
          width: 100%,
          height: 100%,
        )[
          #align(center + horizon)[
            #pad(x: 1.5em)[
              #stack(
                dir: ttb,
                spacing: 0.8em,
                box[
                  #grid(
                    columns: (auto, auto, 2.5em, auto, auto),
                    column-gutter: 0.45em,
                    row-gutter: 0pt,
                    align: horizon,
                    text(size: cover-meta-label-size, weight: "bold", fill: cover-institution)[学院：],
                    box(text(size: cover-meta-value-size, fill: cover-institution)[#college-name]),
                    [],
                    text(size: cover-meta-label-size, weight: "bold", fill: cover-institution)[专业：],
                    box(text(size: cover-meta-value-size, fill: cover-institution)[#major-name]),
                  )
                ],
                text(size: cover-date-size, fill: cover-institution)[#datetime.today().display("[year]年[month]月[day]日")],
              )
            ]
          ]
        ],
      )
    ]
  }
  touying-slide(self: self, body)
})

#let cover-section = [
  #title-slide()
]
