#let extended_abstract_en(
  title_en: "A Thesis/Dissertation Template written in Typst for National Cheng Kung University",
  institute: "Department of Electrical Engineering",
  student_en: "Chun-Hao Chang",
  advisor_en: "Chia-Chi Tsai",
  summary: none,
  keywords: (),
  doc,
) = {
  // show thesis/dissertation title
  set text(size: 14pt)
  set align(center)
  strong(title_en)
  v(0.15cm)
  // student and advisor names
  set text(size: 12pt)
  student_en
  linebreak()
  advisor_en
  v(0.25em)
  institute
  v(0.5cm)

  set align(left)
  [= 英文延伸摘要 <invisible>]
  set heading(outlined: false)
  show heading.where(level: 1): it => {
    set text(12pt)
    set align(center)
    smallcaps(it)
    v(0.5em)
  }

  rect(inset: 1em)[
    = SUMMARY

    #summary

    *Keyword*: #keywords.join(", ")
  ]

  doc
}
