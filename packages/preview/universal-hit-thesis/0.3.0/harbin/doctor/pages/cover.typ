#import "../../../common/theme/type.typ": 字体, 字号
#import "../../../common/config/constants.typ": current-date
#import "../../../common/utils/states.typ": thesis-info-state

#let cover-primary(
  title-cn: "",
  title-en: "",
  author: "",
  supervisor: "",
  profession: "",
  collage: "",
  reply-date: "",
  institute: "",
  year: current-date.year(),
  month: current-date.month(),
  day: current-date.day(),
) = {
  align(center)[

    #let space-scale-ratio = 1.25

    #v(50pt)

    #text(size: 字号.小一, font: 字体.宋体, weight: "bold")[*博士学位论文*]

    #v(87.5pt)

    #text(size: 字号.二号, font: 字体.黑体)[#title-cn]

    #v(33pt)

    #par(justify: false)[
      #text(size: 字号.小二, font: 字体.宋体, weight: "bold")[#title-en]
    ]

    #v(64pt)

    #align(center)[
      #text(size: 字号.小二, font: 字体.宋体, weight: "bold")[
        #author
      ]
    ]

    #v(137pt)

    #align(center)[
      #text(size: 字号.小二, font: 字体.楷体, weight: "bold")[#institute]

      #text(size: 字号.小二, font: 字体.宋体, weight: "bold")[
        #[#year]年#[#month]月
      ]
    ]
  ]
}

#let cover-secondary(
  title-cn: "",
  author: "",
  supervisor: "",
  profession: "",
  collage: "",
  affiliation: "",  
  institute: "",
  chinese-library-classification: "××××",
  universal-decimal-classification: "××××",
  school-identification-code: "×××",
  year: current-date.year(),
  month: current-date.month(),
  day: current-date.day(),
) = {
  align(center)[

    #let space-scale-ratio = 1.4

    #block(inset: (top: 4pt))[
      #grid(
        columns: (1fr, 1fr),
        align(left)[
          #text(size: 字号.小四, font: 字体.宋体)[国内图书分类号：#chinese-library-classification] \
          #text(size: 字号.小四, font: 字体.宋体)[国际图书分类号：#universal-decimal-classification]
        ],
        align(right)[
          #text(size: 字号.小四, font: 字体.宋体)[学校代码：#school-identification-code] \
          #text(size: 字号.小四, font: 字体.宋体)[密级：公开]
        ]
      )
    ]

    #v(90pt)

    #text(size: 字号.小二, font: 字体.宋体)[*博士学位论文*]

    #v(32pt)

    #text(size: 字号.二号, font: 字体.黑体)[#title-cn]

    #v(151pt)

    #let cover-info-key(content) = {
      align(right)[
        #text(size: 字号.四号, font: 字体.黑体)[#content]
      ]
    }

    #let cover-info-colon(content) = {
      align(left)[
        #text(size: 字号.四号, font: 字体.黑体)[#content]
      ]
    }

    #let cover-info-value(content) = {
      align(left)[
        #text(size: 字号.四号, font: 字体.宋体)[#content]
      ]
    }

    // #let base-space = 0.8
    #let key-width = 字号.四号 * 6
    #let get-tracking-by-characters-count(count) = (key-width - count * 1em) / (count - 1)

    #grid(
      columns: (76fr, 1.5em, 100fr),
      rows: (字号.四号, 字号.四号),
      row-gutter: 1.5em,
      cover-info-key(text(tracking: get-tracking-by-characters-count(5))[博士研究生]),
      cover-info-colon[：],
      cover-info-value(author),
      cover-info-key(text(tracking: get-tracking-by-characters-count(2))[导师]),
      cover-info-colon[：],
      cover-info-value(supervisor), 
      cover-info-key(text(tracking: get-tracking-by-characters-count(4))[申请学位]),
      cover-info-colon[：],
      cover-info-value(profession),
      cover-info-key(text(tracking: get-tracking-by-characters-count(5))[学科或类别]),
      cover-info-colon[：],
      cover-info-value(collage),
      cover-info-key(text(tracking: get-tracking-by-characters-count(4))[所在单位]),
      cover-info-colon[：],
      cover-info-value(affiliation),
      cover-info-key(text(tracking: get-tracking-by-characters-count(4))[答辩日期]),
      cover-info-colon[：],
      cover-info-value([#[#year]年#[#month]月]),
      cover-info-key(text(tracking: get-tracking-by-characters-count(6))[授予学位单位]),
      cover-info-colon[：],
      cover-info-value(institute),
    )
  ]
}

#let cover-secondary-en(
  title-en: "",
  author-en: "",
  supervisor-en: "",
  profession-en: "",
  collage-en: "",
  affiliation-en: "",  
  institute-en: "",
  chinese-library-classification: "××××",
  universal-decimal-classification: "××××",
  year: current-date.year(),
  month: current-date.month(),
  day: current-date.day(),
) = {
  align(center)[

    #let space-scale-ratio = 1.4

    #block(inset: (top: 6pt))[
      #grid(
        columns: (1fr, 1fr),
        align(left)[
          #set par(spacing: 1em)

          #text(size: 字号.小四, font: 字体.宋体)[Classified Index: #chinese-library-classification]

          #text(size: 字号.小四, font: 字体.宋体)[U.D.C: #universal-decimal-classification]
        ],
        align(right)[

        ]
      )
    ]


    #v(58pt)

    #text(size: 字号.小二, font: 字体.宋体)[Dissertation for the Doctoral Degree]

    #v(68pt)

    #text(size: 字号.小二, font: 字体.黑体)[*#title-en*]

    #v(109pt)

    #let cover-info-key(content) = {
      align(left)[
        #text(size: 字号.四号, font: 字体.黑体)[*#content*]
      ]
    }

    #let cover-info-colon(content) = {
      align(left)[
        #text(size: 字号.四号, font: 字体.黑体)[#content]
      ]
    }

    #let cover-info-value(content) = {
      align(left)[
        #text(size: 字号.四号, font: 字体.宋体)[#content]
      ]
    }

    // #let base-space = 0.8
    #let key-width = 字号.四号 * 6
    #let get-tracking-by-characters-count(count) = (key-width - count * 1em) / (count - 1)

    #grid(
      columns: (96fr, 100fr),
      row-gutter: 11.6pt,
      column-gutter: 0em,
      cover-info-key(text()[Candidate：]),
      cover-info-value(author-en),

      cover-info-key(text()[Supervisor：]),
      cover-info-value(supervisor-en), 

      cover-info-key(text()[Academic Degree Applied for：]),
      cover-info-value(profession-en),

      cover-info-key(text()[Specialty：]),
      cover-info-value(collage-en),

      cover-info-key(text()[Affiliation：]),
      cover-info-value(affiliation-en),

      cover-info-key(text()[Date of Defense：]),
      cover-info-value([
        #import "@preview/datify:0.1.3": custom-date-format
        #let year-month = datetime(
          year: year,
          month: month,
          day: 3,
        )
        #custom-date-format(year-month, "Month, YYYY")
      ]),

      cover-info-key(text()[Degree-Conferring-Institution：]),
      cover-info-value(institute-en),
    )
  ]
}

#let cover() = {
  context {
    let thesis-info = thesis-info-state.get()
    cover-primary(
      title-cn: thesis-info.at("title-cn"),
      title-en: thesis-info.at("title-en"),
      author: thesis-info.at("author"),
      supervisor: thesis-info.at("supervisor"),
      profession: thesis-info.at("profession"),
      collage: thesis-info.at("specialty"),
      institute: thesis-info.at("institute"),
      year: thesis-info.at("year"),
      month: thesis-info.at("month"),
      day: thesis-info.at("day"),
    )

    pagebreak()

    cover-secondary(
      title-cn: thesis-info.at("title-cn"),
      author: thesis-info.at("author"),
      supervisor: thesis-info.at("supervisor"),
      profession: thesis-info.at("profession"),
      collage: thesis-info.at("specialty"),
      affiliation: thesis-info.at("affiliation"),
      institute: thesis-info.at("institute"),
      chinese-library-classification: thesis-info.at("chinese-library-classification"),
      universal-decimal-classification: thesis-info.at("universal-decimal-classification"),
      school-identification-code: thesis-info.at("school-identification-code"),
      year: thesis-info.at("year"),
      month: thesis-info.at("month"),
      day: thesis-info.at("day"),
    )

    pagebreak()

    cover-secondary-en(
      title-en: thesis-info.at("title-en"),
      author-en: thesis-info.at("author-en"),
      supervisor-en: thesis-info.at("supervisor-en"),
      profession-en: thesis-info.at("profession-en"),
      collage-en: thesis-info.at("specialty-en"),
      affiliation-en: thesis-info.at("affiliation-en"),
      institute-en: thesis-info.at("institute-en"),
      chinese-library-classification: thesis-info.at("chinese-library-classification"),
      universal-decimal-classification: thesis-info.at("universal-decimal-classification"),
      year: thesis-info.at("year"),
      month: thesis-info.at("month"),
      day: thesis-info.at("day"),
    )
  }
}