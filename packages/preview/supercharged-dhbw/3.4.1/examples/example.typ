#import "@preview/supercharged-dhbw:3.4.1": *

#let acronyms = (
  "VIP": "Very important person",
)

#show: supercharged-dhbw.with(
  title: "Exploration of Typst for the Composition of a University Thesis",
  authors: (
    (name: "Max Mustermann", student-id: "7654321", course: "TIS21", course-of-studies: "IT-Security", company: (
      (name: "YXZ GmbH", post-code: "70435", city: "Stuttgart")
    )),
    (name: "Juan Pérez", student-id: "1234567", course: "TIM21", course-of-studies: "Mobile Computer Science", company: (
      (name: "ABC S.L.", post-code: "08005", city: "Barcelona", country: "Spain")
    )),
  ),
  acronyms: acronyms, // displays the acronyms defined in the acronyms dictionary
  at-university: false, // if true the company name on the title page and the confidentiality statement are hidden
  confidentiality-marker: (display: true),
  bibliography: bibliography("example-sources.yml"),
  date: datetime.today(),
  language: "en", // en, de
  supervisor: (company: "John Appleseed"),
  university: "Cooperative State University Baden-Württemberg",
  university-location: "Ravensburg Campus Friedrichshafen",
  university-short: "DHBW",
  // for more options check the package documentation (https://typst.app/universe/package/supercharged-dhbw)
)

= Section A

A #acr("VIP") once said this:

#lorem(250) @examplesource