#import "../../../common/theme/type.typ": 字体, 字号
#import "../../../common/config/constants.typ": current-date
#import "../../../common/utils/states.typ": thesis-info-state

#let cover-primary(
  title-cn: "",
  title-en: "",
  author: "",
  student-id: "",
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

    #v(50pt)

    #text(size: 字号.小一, font: 字体.宋体, weight: "bold")[*本科毕业论文（设计）*]

    #v(32pt)

    #text(size: 字号.二号, font: 字体.黑体)[#title-cn]

    #v(36pt)

    #par(justify: false)[
      #text(size: 字号.小二, font: 字体.宋体, weight: "bold")[#title-en]
    ]

    #v(62pt)

    #align(center)[
      #text(size: 字号.小二, font: 字体.宋体, weight: "bold")[
        #author
      ]
    ]

    #v(128pt)

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
  student-id: "",
  supervisor: "",
  profession: "",
  collage: "",
  institute: "",
  year: current-date.year(),
  month: current-date.month(),
  day: current-date.day(),
) = {
    align(center)[

    #align(right)[
      #block(inset: (top: 6pt, right: 40pt))[
        #text(size: 字号.小四, font: 字体.宋体)[密级：公开]
      ]
    ]

    #v(42pt)

    #text(size: 字号.小二, font: 字体.宋体)[*本科毕业论文（设计）*]

    #v(32pt)

    #text(size: 字号.二号, font: 字体.黑体)[#title-cn]

    #v(152pt)

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

    #let key-width = 90pt
    #let get-tracking-by-characters-count(count) = (key-width - count * 1em) / (count - 1)

    #grid(
      columns: (76fr, 1.5em, 100fr),
      rows: (字号.四号, 字号.四号),
      row-gutter: 15.4pt,
      cover-info-key(text(tracking: get-tracking-by-characters-count(3))[本科生]),
      cover-info-colon[：],
      cover-info-value(author),
      cover-info-key(text(tracking: get-tracking-by-characters-count(2))[学号]),
      cover-info-colon[：],
      cover-info-value(student-id),
      cover-info-key(text(tracking: get-tracking-by-characters-count(4))[指导教师]),
      cover-info-colon[：],
      cover-info-value(supervisor),
      cover-info-key(text(tracking: get-tracking-by-characters-count(2))[专业]),
      cover-info-colon[：],
      cover-info-value(profession),
      cover-info-key(text(tracking: get-tracking-by-characters-count(2))[学院]),
      cover-info-colon[：],
      cover-info-value(collage),
      cover-info-key(text(tracking: get-tracking-by-characters-count(4))[答辩日期]),
      cover-info-colon[：],
      cover-info-value([#[#year]年#[#month]月]),
      cover-info-key(text(tracking: get-tracking-by-characters-count(2))[学校]),
      cover-info-colon[：],
      cover-info-value(institute),
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
      student-id: thesis-info.at("student-id"),
      supervisor: thesis-info.at("supervisor"),
      profession: thesis-info.at("profession"),
      collage: thesis-info.at("collage"),
      institute: thesis-info.at("institute"),
      year: thesis-info.at("year"),
      month: thesis-info.at("month"),
      day: thesis-info.at("day"),
    )

    pagebreak()

    cover-secondary(
      title-cn: thesis-info.at("title-cn"),
      author: thesis-info.at("author"),
      student-id: thesis-info.at("student-id"),
      supervisor: thesis-info.at("supervisor"),
      profession: thesis-info.at("profession"),
      collage: thesis-info.at("collage"),
      institute: thesis-info.at("institute"),
      year: thesis-info.at("year"),
      month: thesis-info.at("month"),
      day: thesis-info.at("day"),
    )
  }
}