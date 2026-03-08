#import "@preview/tidy:0.4.3"

#let figure-caption = link(
  "https://typst.app/docs/reference/model/figure/#parameters-caption",
  text(blue, underline[caption]),
)
#let figure-kind = link(
  "https://typst.app/docs/reference/model/figure/#parameters-kind",
  text(blue, underline[kind]),
)
#let figure-supplement = link(
  "https://typst.app/docs/reference/model/figure/#parameters-supplement",
  text(blue, underline[supplement]),
)
#let numbering-type = link(
  "https://typst.app/docs/reference/model/numbering/",
  text(blue, underline[numbering pattern or function]),
)
#let docs = tidy.parse-module(
  read("src/internal.typ"),
  scope: (
    figure-caption: figure-caption,
    figure-kind: figure-kind,
    figure-supplement: figure-supplement,
    numbering-type: numbering-type,
  ),
  name: "Manual",
)
#tidy.show-module(docs, style: tidy.styles.default, sort-functions: none)
