#import "@preview/fontawesome:0.4.0": *
#import "@preview/modernpro-coverletter:0.0.3": *

#show: coverletter.with(
  font-type: "PT Serif",
  name: [],
  address: [],
  contacts: (
    (text: [#fa-icon("location-dot") UK]),
    (text: [#fa-icon("mobile") 123-456-789], link: "tel:123-456-789"),
    (text: [#fa-icon("link") example.com], link: "https://www.example.com"),
    (text: [#fa-icon("github") github], link: "https://github.com/"),
    (text: [#fa-icon("envelope") example\@example.com], link: "mailto:example@example.com"),
  ),
  recipient: (
    start-title: [],
    cl-title: [],
    date: [],
    department: [],
    institution: [],
    address: [],
    postcode: [],
  ),
)

#set par(justify: true, first-line-indent: 2em)
#set text(weight: "regular", size: 12pt)

// Main body of the cover letter
