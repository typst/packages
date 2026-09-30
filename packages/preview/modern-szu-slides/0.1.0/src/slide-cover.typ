// Modern SZU Slides - Cover and Outline Slides Implementation
#import "@preview/touying:0.7.4": *
#import "slide-text.typ": *
#import "szu-colors.typ": *

#let cover-latin-text-pattern = regex("[A-Za-z0-9][A-Za-z0-9+\\-_/.:,%&()]*")

#let title-slide(
  title: [深圳大学学位论文题目],
  subtitle: none,
  author: [答辩人姓名],
  advisor: [指导教师 教授],
  college: [计算机与软件学院],
  major: [计算机科学与技术],
  date: datetime.today(),
  flag: auto,
  lang: "zh",
  config: (:),
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(fill: cover-bg, margin: 0pt),
  )
  let flag-image = if flag == auto {
    image("/assets/SZU_flag.pdf", width: 35%)
  } else {
    flag
  }
  let body = {
    set text(font: if lang == "zh" { zh-font } else { en-font }, fill: white)
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
            #if flag-image != none { flag-image }
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
                  #text(size: cover-title-size, weight: "bold", fill: strong-text-fill)[#title]
                ]
                #if subtitle != none [
                  #v(0.5em)
                  #line(length: 100%, stroke: 1.8pt + cover-rule)
                  #v(1em)
                  #align(center)[
                    #text(size: 1.25em, fill: szu-primary-dark-red)[#subtitle]
                  ]
                ]
              ],
              [
                #align(center)[
                  #grid(
                    columns: 2,
                    column-gutter: 4em,
                    align: center,
                    [
                      #text(size: cover-meta-label-size, weight: "bold", fill: cover-bg)[#(if lang == "zh" { "答辩人：" } else { "Candidate: " })]
                      #text(size: cover-meta-value-size, fill: strong-text-fill)[#author]
                    ],
                    [
                      #text(size: cover-meta-label-size, weight: "bold", fill: cover-bg)[#(if lang == "zh" { "指导老师：" } else { "Advisor: " })]
                      #text(size: cover-meta-value-size, fill: strong-text-fill)[#advisor]
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
            #stack(
              dir: ttb,
              spacing: 0.7em,
              grid(
                columns: 2,
                column-gutter: 3em,
                align: (center, center),
                [
                  #text(size: 15pt, weight: "bold", fill: cover-institution)[#(if lang == "zh" { "学院：" } else { "College: " })]
                  #text(size: 14pt, fill: cover-institution)[#college]
                ],
                [
                  #text(size: 15pt, weight: "bold", fill: cover-institution)[#(if lang == "zh" { "专业：" } else { "Major: " })]
                  #text(size: 14pt, fill: cover-institution)[#major]
                ],
              ),
              text(size: 13pt, fill: cover-institution)[
                #if type(date) == datetime {
                  if lang == "zh" {
                    date.display("[year] 年 [month] 月 [day] 日")
                  } else {
                    date.display("[month repr:long] [day], [year]")
                  }
                } else {
                  date
                }
              ],
            )
          ]
        ],
      )
    ]
  }
  touying-slide(self: self, body)
})

#let outline-slide(
  title: none,
  lang: "zh",
  body,
) = slide[
  #pad(top: -1em)[
    #stack(
      dir: ttb,
      spacing: 0.8em,
      [
        #text(size: outline-heading-size, weight: "bold", fill: cover-accent)[
          #if title != none { title } else if lang == "zh" { [大纲] } else { [Outline] }
        ]
        #line(length: 100%, stroke: 1.4pt + outline-rule)
      ],
      body,
    )
  ]
]

#let thanks-slide(
  title: none,
  subtitle: none,
  lang: "zh",
) = slide(
  config: config-page(
    header: none,
    footer: none,
    margin: 0em,
  ) + config-store(
    header-right: none,
    footer-right: none,
    footer-progress: false,
  ),
)[
  #align(center + horizon)[
    #text(size: 2.2em, weight: "bold", fill: cover-bg)[
      #if title != none { title } else if lang == "zh" { [感谢各位老师聆听！] } else { [Thank you for listening!] }
    ]
    #let sub = if subtitle != none { subtitle } else if lang == "zh" { [敬请各位专家批评指正] } else { none }
    #if sub != none [
      #v(16pt)
      #text(size: 1.4em)[#sub]
    ]
  ]
]
