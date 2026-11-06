#import "../languages.typ": get-text

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
    [#text(8pt)[#get-text("title-of-thesis", language)]],
    [#text(titleSize, hyphenate: true)[*#title*]],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[#get-text("degree", language)]],
    [#degree],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[#get-text("name-place-of-birth", language)]],
    [#author, #place],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[#get-text("course-of-study", language)]],
    [#study-course],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[#get-text("department", language)]],
    [#department],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[#get-text("first-examiner", language)]],
    [#first-examiner],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[#get-text("second-examiner", language)]],
    [#second-examiner],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[#get-text("date-of-submission", language)]],
    [#date-of-submission],
    line(length: 100%, stroke: 0.5pt),
  )
}
