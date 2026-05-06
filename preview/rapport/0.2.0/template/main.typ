#import "@preview/rapport:0.2.0": *

#show: rapport.with(
  title: "TITLE",
  author: "AUTHOR",
  header: "HEADER",
  date: datetime(
    year: 2026,
    month: 05,
    day: 1,
  ),
  paper-size: "a4",
  font-size: 11pt,
  body-font: "Source Serif 4",
  heading-font: "Source Sans 3",
)

= HEADING

#lorem(64)

== SUBHEADING

#lorem(64)


