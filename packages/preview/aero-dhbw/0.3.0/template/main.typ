#import "acronyms.typ": *
#import "@preview/aero-dhbw:0.3.0": aero-dhbw
#import "@preview/codly:1.3.0": *

#show: codly-init.with()
#codly()

#let title = ""
#let author = (
  (name: "", mat-number: "", course-acronym: ""),
)
#let project = ""
#let project-type = ""
#let course = ""
#let university = ""
#let place-of-authorship = ""
#let supervisor = ""
#let company = ""
#let company-location = ""
#let bib = ""

// Uncomment the ones you need and enter the paths to the images/PDFs inside the quotes, e.g. image("path/to/image")
// Uncomment them down below as well
#let dhbw_logo = image("resources/dhbw-logo.png")
// #let company_logo = image("")
// #let confidentiality-notice = image("", width: 100%)

#show: aero-dhbw.with(
  title: title,
  project: project,
  project-type: project-type,
  course: course,
  place-of-authorship: place-of-authorship,
  author: author,
  start-date: datetime(year: 2025, month: 1, day: 1),
  end-date: datetime(year: 2026, month: 1, day: 1),
  supervisor: supervisor,
  company: company,
  company-location: company-location,
  university: university,
  university-logo: dhbw_logo,
  acronym-list: glossary-list,
  figure-gap-above: 0.5em,
  figure-gap-under: 0.5em,
  text-lang: "en",
  // company-logo: company_logo,
  // confidentiality-notice: confidentiality-notice,
  // path-to-abstract: "chapters/abstract.typ",
  // bib: bib,
)

// Optional: force a specific region for hyphenation / quote style
// (the template only sets the language, e.g. "en" covers US, GB, AU, …).
// #set text(region: "GB")

// Keep the content in the chapters folder and only include the files here.
// For example:
#include "chapters/introduction.typ"
//
// #include "chapters/fundamentals.typ"
//
// #include "chapters/main-part.typ"
//
// #include "chapters/summary.typ"
