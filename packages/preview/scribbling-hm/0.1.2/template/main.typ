#import "@preview/scribbling-hm:0.1.2": *

#import "abbreviations.typ": abbreviations-list
#import "variables.typ": variables-list

#show: thesis.with(
  title: lorem(15),
  title-translation: lorem(12),
  course-of-study: "Informatik",
  submission-date: datetime.today(),
  student-id: 12345678,
  author: "Erika Mustermann",
  supervisors: "Prof. Dr. Max Mustermann",
  semester: "WiSe 2025/26",
  study-group: "IF7",
  birth-date: datetime(year: 2000, day: 1, month: 1),
  abstract-two-langs: true,
  abstract: none,
  abstract-translation: none,
  blocking: true,
  gender: "w",
  supervisor-gender: "m",
  bib: bibliography("references.bib", title: "Literaturverzeichnis"),
  abbreviations-list: abbreviations-list,
  variables-list: variables-list,
  draft: true,
)

= Section
== Subsection
This @typst formatting is defined in the variables list.

#todo[Mehr Text]
