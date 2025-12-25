#import "../languages.typ": getText

#let title(
  background,
  thesis-type,
  title,
  degree,
  author,
  place,
  study-course,
  department,
  first-examiner,
  second-examiner,
  date-of-submission,
  titleSize,
  language: "de",
) = {
  set page(margin: (left: 3.7cm, bottom: 3cm, top: 1cm), background: background)

  set align(left)

  v(4cm)
  text(44pt)[*#thesis-type*]

  stack(
    spacing: 3mm,
    [#text(8pt)[#getText("title-of-thesis", language)]],
    [#text(titleSize, hyphenate: true)[*#title*]],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[#getText("degree", language)]],
    [#degree],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[#getText("name-place-of-birth", language)]],
    [#author, #place],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[#getText("course-of-study", language)]],
    [#study-course],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[#getText("department", language)]],
    [#department],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[#getText("first-examiner", language)]],
    [#first-examiner],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[#getText("second-examiner", language)]],
    [#second-examiner],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[#getText("date-of-submission", language)]],
    [#date-of-submission],
    line(length: 100%, stroke: 0.5pt),
  )
}
