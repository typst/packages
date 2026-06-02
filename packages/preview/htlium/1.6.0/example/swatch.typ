// Helper used to render a single cover page for the README color-scheme table.
// Compile with: typst compile --root .. --input color=blue swatch.typ ...
#import "../src/template.typ": *

#let palette = (
  red: red,
  blue: blue,
  green: green,
  purple: purple,
  orange: orange,
  teal: teal,
)

#let chosen = palette.at(sys.inputs.at("color", default: "red"))

#show: body => template(
  body,
  color-scheme: chosen,
  author: "Elias Pöschl",
  logo: image("./logo.png"),
  title: "HTLium",
  subtitle: sys.inputs.at("color", default: "red"),
  task-title: "",
  task-content: "",
  class: "3AHIF",
  subject: "Softwareentwicklung",
  school: "HTL Salzburg",
  department: "Informatik",
  teachers: ("Frau Mag. Mustermann",),
  do-lof: false,
  do-lot: false,
  do-bib: false,
)

= Beispiel
#lorem(10)
