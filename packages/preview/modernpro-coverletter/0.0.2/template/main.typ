#import "@preview/modernpro-coverletter:0.0.2": *

#show: main.with(
  font-type: "Roboto",
  name: [#lorem(2)],
  address: [#lorem(4)],
  contacts: (
    (text: "08856", link: ""),
    (text: "example.com", link: "https://www.example.com"),
    (text: "github.com", link: "https://www.github.com"),
    (text: "123@example.com", link: "mailto:123@example.com"),
  ),
  recipient: (
    start-title: [Dear],
    cl-title: [Job Application for Hiring Manager],
    date: [],
    department: [#lorem(2)],
    institution: [#lorem(2)],
    address: [#lorem(4)],
    postcode: [#lorem(1)],
  ),
)

#lorem(300)