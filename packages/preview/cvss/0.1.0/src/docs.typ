#import "@preview/tidy:0.2.0"

= CVSS Calculation Typst Library Documentation

The CVSS Typst Library is a #link("https://github.com/typst/", "Typst") package designed to facilitate the calculation of Common Vulnerability Scoring System (CVSS) scores for vulnerabilities across multiple versions, including CVSS 2.0, 3.0, 3.1, and 4.0. This library provides developers, security analysts, and researchers with a reliable and efficient toolset for assessing the severity of security vulnerabilities based on the CVSS standards.

== Functions
#set text(font: ("Inter", "Lilex Nerd Font Mono"))
#show raw: set text(font: ("Lilex Nerd Font Mono", "JetBrains Mono", "Fira Code", "Cascadia"))
#let docs = tidy.parse-module(read("cvss.typ"))
#tidy.show-module(
  docs,
  show-outline: false,
  first-heading-level: 3,
  show-module-name: true,
  break-param-descriptions: false,
  sort-functions: true,
  style: tidy.styles.default,
  // colors: tidy.styles.default.colors-dark
)
