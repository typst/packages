#let cover-en-page(
  doctype: "bachelor",
  twoside: false,
  anonymous: false,
  info: (:),
  date: datetime.today(),
) = {
  let title = info.at("title-en", default: "Thesis Title")
  let name = info.at("name-en", default: "Author")
  let school = info.at("school-en", default: "School")
  let major = info.at("major", default: "Major")
  let supervisor = info.at("supervisor-en", default: "Supervisor")

  pagebreak()
  align(center, {
    v(35mm)
    text(size: 20pt, weight: "bold")[Tianjin University of Science and Technology]
    v(12mm)
    text(size: 18pt, weight: "bold")[#title]
    v(22mm)
    text(size: 12pt)[Author: #name]
    v(6mm)
    text(size: 12pt)[School: #school]
    v(6mm)
    text(size: 12pt)[Major: #major]
    v(6mm)
    text(size: 12pt)[Supervisor: #supervisor]
    v(12mm)
    text(size: 12pt)[#date]
  })
}
