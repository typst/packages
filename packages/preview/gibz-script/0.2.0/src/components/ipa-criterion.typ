#import "../fonts.typ": heading-font

#let _ipa-label(level, size: 0.9em) = text(weight: 600, size: size)[Gütestufe #level]

#let _ipa-title(title, subtitle, subtitle-leading: 0.78em) = [
  #set par(justify: false, leading: subtitle-leading)
  #text(font: heading-font, weight: 700, size: 1.25em)[#title]
  #if subtitle != none [
    #linebreak()
    #v(0.1em)
    #text(size: 0.825em, fill: luma(35%))[#subtitle]
  ]
]

#let _ipa-content(body, size: 1em, list-indent: 0em) = [
  #set par(justify: false)
  #set text(size: size)
  #set list(indent: list-indent)
  #set enum(indent: list-indent)
  #body
]

#let ipa-criterion(
  id,
  title,
  subtitle,
  level3,
  level2,
  level1,
  level0,
  active-level: none,
  feedback: none,
  feedback-label: "Kommentar / Feedback",
  stroke: 0.6pt + luma(65%),
  inset: 7pt,
  label-fill: luma(97%),
  active-fill-3: rgb("#d9f4df"),
  active-fill-2: rgb("#fff7cc"),
  active-fill-1: rgb("#ffe7cc"),
  active-fill-0: rgb("#ffd6d6"),
  feedback-fill: luma(94%),
  level-label-size: 0.9em,
  level-content-size: 0.9em,
  subtitle-leading: 0.625em,
  feedback-leading: 0.625em,
) = {
  let row-fill = level => if active-level != none and level == active-level {
    if level == 3 {
      active-fill-3
    } else if level == 2 {
      active-fill-2
    } else if level == 1 {
      active-fill-1
    } else {
      active-fill-0
    }
  } else {
    none
  }

  let feedback-cells = if feedback != none {
    (
      table.cell(colspan: 2, fill: feedback-fill)[
        #set par(leading: feedback-leading)
        #text(font: heading-font, weight: 700)[#feedback-label]
        #linebreak()
        #_ipa-content(feedback)
      ],
    )
  } else {
    ()
  }

  block(breakable: false)[
    #table(
      columns: (22%, 78%),
      inset: inset,
      stroke: stroke,
      align: (left + top, left + top),

      table.cell(align: left + horizon, fill: luma(95%))[#text(weight: 700, size: 1.5em)[#id]],
      [#_ipa-title(title, subtitle, subtitle-leading: subtitle-leading)],

      table.cell(fill: if row-fill(3) == none { label-fill } else { row-fill(3) })[#_ipa-label(
        3,
        size: level-label-size,
      )],
      table.cell(fill: row-fill(3))[#_ipa-content(level3, size: level-content-size, list-indent: 0em)],

      table.cell(fill: if row-fill(2) == none { label-fill } else { row-fill(2) })[#_ipa-label(
        2,
        size: level-label-size,
      )],
      table.cell(fill: row-fill(2))[#_ipa-content(level2, size: level-content-size, list-indent: 0em)],

      table.cell(fill: if row-fill(1) == none { label-fill } else { row-fill(1) })[#_ipa-label(
        1,
        size: level-label-size,
      )],
      table.cell(fill: row-fill(1))[#_ipa-content(level1, size: level-content-size, list-indent: 0em)],

      table.cell(fill: if row-fill(0) == none { label-fill } else { row-fill(0) })[#_ipa-label(
        0,
        size: level-label-size,
      )],
      table.cell(fill: row-fill(0))[#_ipa-content(level0, size: level-content-size, list-indent: 0em)],

      ..feedback-cells,
    )
  ]
}
