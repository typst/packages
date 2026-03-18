#import "../utils/style.typ": ziti, zihao
#import "../utils/datetime-display.typ": datetime-en-display, datetime-en-display-without-day

#let cover-en-page(
  date: datetime.today(),
  doctype: "master",
  twoside: false,
  anonymous: false,
  info: (:),
) = {
  let cover-en-title = if doctype == "doctor" {
    "A Dissertation Submitted to
    Shanghai Jiao Tong University for the Degree of Doctor"
  } else if doctype == "master" {
    "A Dissertation Submitted to
    Shanghai Jiao Tong University for the Degree of Master"
  } else {
    "A Dissertation Submitted to
    Shanghai Jiao Tong University for the Degree of Bachelor"
  }

  v(if doctype == "bachelor" { 2cm } else { 0cm })

  align(
    center,
    text(
      size: zihao.sihao,
      weight: "bold",
    )[#cover-en-title],
  )

  v(if doctype == "bachelor" { 2.5cm } else { 3.1cm })

  align(
    center,
    text(
      size: zihao.xiaoer,
      weight: "bold",
    )[#info.title_en],
  )

  v(3.5cm)

  let info-key-en(en) = (
    text(
      en,
      weight: "bold",
      size: zihao.sanhao,
    )
  )

  let info-value-en(en) = (
    text(
      en,
      weight: if doctype == "bachelor" { 700 } else { 500 },
      size: zihao.sanhao,
    )
  )

  table(
    stroke: none,
    align: (x, y) => (
      if x == 0 {
        right
      } else {
        left
      }
    ),
    columns: (50%, 50%),
    row-gutter: 0.6em,
    [#info-key-en("Author:")],
    [#if anonymous { } else {
        info-value-en(info.name_en)
      }],

    [#info-key-en("Supervisor:")],
    [#if anonymous { } else {
        info-value-en(info.supervisor_en)
      }],
  )

  v(4cm)

  align(
    center,
    text(size: zihao.sanhao)[
      #info.school_en

      Shanghai Jiao Tong University

      Shanghai, P.R. China

      #if doctype == "bachelor" {
        datetime-en-display-without-day(date)
      } else {
        datetime-en-display(date)
      }
    ],
  )

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}
