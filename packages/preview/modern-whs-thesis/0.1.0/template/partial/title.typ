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
) = {
  set page(margin: (left: 3.7cm, bottom: 3cm, top: 1cm), background: background)

  set align(left)

  v(4cm)
  text(44pt)[*#thesis-type*]

  stack(
    spacing: 3mm,
    [#text(8pt)[Titel der Arbeit /\/ Title of Thesis]],
    [#text(24pt)[*#title*]],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[Akademischer Abschlussgrad: Grad, Fachrichtung (Abkürzung) /\/ Degree]],
    [#degree],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[Autorenname, Geburtsort /\/ Name, Place of Birth]],
    [#author, #place],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[Studiengang /\/ Course of Study]],
    [#study-course],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[Fachbereich /\/ Department]],
    [#department],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[Erstprüferin/Erstprüfer /\/ First Examiner]],
    [#first-examiner],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[Zweitprüferin/Zweitprüfer /\/ Second Examiner]],
    [#second-examiner],
    line(length: 100%, stroke: 0.5pt),
  )

  v(0.3cm)
  stack(
    spacing: 3mm,
    [#text(8pt)[Abgabedatum /\/ Date of Submission]],
    [#date-of-submission],
    line(length: 100%, stroke: 0.5pt),
  )
}
