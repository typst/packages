#import "@preview/fontawesome:0.5.0": *
#import "@preview/modernpro-coverletter:0.0.7": *

#show: statement.with(
  font-type: "PT Serif",
  margin: (left: 2cm, right: 2cm, top: 3cm, bottom: 2cm),
  name: [],
  address: [],
  contacts: (
    (text: [#fa-icon("location-dot") UK]),
    (text: [#fa-icon("mobile") 123-456-789], link: "tel:123-456-789"),
    (text: [#fa-icon("link") example.com], link: "https://www.example.com"),
    (text: [#fa-icon("github") github], link: "https://github.com/"),
    (text: [#fa-icon("envelope") example\@example.com], link: "mailto:example@example.com"),
  ),
)

#v(1em)
#align(center, text(13pt, weight: "semibold")[#underline([Title])])
#set par(first-line-indent: 2em, justify: true)
#set text(11pt, weight: "regular")

// Main body of the statement
