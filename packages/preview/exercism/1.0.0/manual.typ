#import "@preview/tidy:0.4.3"

#let numbering-type = link(
  "https://typst.app/docs/reference/model/numbering/",
  text(blue, underline[numbering pattern or function]),
)
#let docs = tidy.parse-module(
  read("src/internal.typ"),
  scope: (numbering-type: numbering-type),
  name: "Manual",
)
#tidy.show-module(docs, style: tidy.styles.default, sort-functions: none)
