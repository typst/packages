#import "acronyms.typ": *
#import "@preview/aero-dhbw:0.4.2": aero-dhbw
// Code formatting setup
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *

#show: codly-init.with()
#codly(languages: codly-languages)

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
#let university-supervisor = ""
#let company = ""
#let company-location = ""
// #let bib = bibliography("references.bib")

// Uncomment the ones you need and enter the paths to the images/PDFs inside the quotes, e.g. image("path/to/image")
// Uncomment them down below as well
#let dhbw_logo = image("resources/dhbw-logo.png")
// #let company_logo = image("")
// #let confidentiality-notice = image("", width: 100%)
// Leave unset to use the generated declaration of authorship.
// #let declaration_of_authorship = image("", width: 100%)

// Style your tables here, before the template is initialized, so the styling
// applies everywhere (main body, annex, and the AI-usage table). The glossary
// keeps its own fixed style.
// #set table(stroke: 0.5pt + black, inset: 6pt)
// #show table: set table(fill: luma(97%))

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
  university-supervisor: university-supervisor,
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
  // declaration-of-authorship: declaration_of_authorship,
  // Pass included content for project files, not a quoted path.
  // path-to-abstract: include "chapters/abstract.typ",
  // path-to-annex: include "chapters/annex.typ",
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
