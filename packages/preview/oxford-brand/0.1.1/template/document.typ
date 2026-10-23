#import "oxford.typ": oxford, title-block, colours

#show: oxford.with(
  secondary: "Research Software Engineering Group\\
Doctoral Training Centre, MPLS",
)

#title-block(
  "A University of Oxford document",
  subtitle: "A compact Typst template",
  author: "Your name",
  date: datetime.today().display("[day] [month repr:long] [year]"),
)

= Introduction

This template uses Oxford Blue by default, with the primary University logo in
the preferred top-left position. Its header accepts a simple text identifier for
the department, group, or programme that the document represents.

== Colours

Choose a supported accent through `accent: "royal-blue"`. The full palette is
available as `colours`, for use in content such as #text(fill: colours.orange)[highlights].
