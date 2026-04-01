#import "colors.typ": colors

#let name(content) = text(
  font: "Roboto",
  size: 24pt,
  weight: "bold",
  fill: colors.black,
  content
) + v(1em)

#let position(content) = text(
  font: "Roboto",
  size: 7.6pt,
  fill: colors.awesome,
  smallcaps(content)
)

#let social-entry(content) = text(
  font: "Roboto",
  size: 6.8pt,
  fill: colors.text,
  content
)

#let summary(content) = text(
  font: "Roboto",
  size: 8.8pt,
  fill: colors.awesome,
  content
)

#let footer(content) = text(
  size: 8pt,
  fill: colors.lighttext,
  smallcaps(content)
)

#let section(content) = text(
  size: 16pt,
  weight: "bold",
  fill: colors.text,
  content
)

#let subsection(content) = text(
  size: 12pt,
  fill: colors.text,
  smallcaps(content)
)

#let org(content) = text(
  size: 10pt,
  weight: "bold",
  fill: colors.darktext,
  content
)

#let duration(content) = text(
  size: 8pt,
  style: "italic",
  fill: colors.graytext,
  content
)

#let project(content) = text(
  size: 10pt,
  weight: "bold",
  fill: colors.darktext,
  content
)

#let date(content) = text(
  size: 8pt,
  style: "italic",
  fill: colors.graytext,
  content
)

#let description(content) = text(
  size: 9pt,
  fill: colors.text,
  content
)

#let table-header(content) = text(
  size: 9pt,
  weight: "bold",
  fill: colors.text,
  content
)

#let workstream(content) = text(
  weight: "bold",
  fill: colors.black,
  content
)
