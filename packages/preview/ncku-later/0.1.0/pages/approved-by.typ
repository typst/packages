#let make-approved-by(
  degree: "doctor",
  title-zh-tw: "以 Typst 撰寫之國立成功大學碩博士論文模板",
  title-en: "A Thesis/Dissertation Template written in Typst\nfor National Cheng Kung University",
  student-zh-tw: "張峻豪",
  date: "",
) = {
  set page(
    paper: "a4",
    numbering: none,
    margin: (top: 23mm, bottom: 30mm, left: 20mm, right: 20mm),
  )

  let degree_show = if degree == "doctor" [博士論文] else [碩士論文]

  set align(top + center)
  stack(
    text(size: 25pt)[國立成功大學],
    v(1cm),
    text(size: 25pt, degree_show),
    v(2cm),
    text(size: 17pt, title-zh-tw),
    v(0.5cm),
    text(size: 17pt, title-en),
    v(1cm),
    text(size: 17pt)[研究生：#student-zh-tw \ 本論文業經審查及口試合格特此證明],
    v(1cm),
    place(left, dx: 0.75cm, text(size: 17pt)[論文考試委員：]),
    v(1cm),
  )

  grid(
    columns: (45%, 45%),
    align: (left, right),
    rows: (2cm, 2cm, 2cm),
    line(length: 50%), line(length: 50%),
    line(length: 100%), line(length: 100%),
    line(length: 100%),
  )
}
