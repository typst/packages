#import "@preview/hm-bachelors-thesis:0.1.0": *

#show: thesis.with(
  title: lorem(15),
  title-translation: lorem(12),
  submission-date: datetime.today(),
  student-id: 12345678,
  author: "Erika Mustermann",
  supervisors: "Prof. Dr. Max Mustermann",
  semester: "WiSe 2025/26",
  study-group: "IF7",
  birth-date: datetime(year: 2000, day: 1, month: 1),
  abstract-two-langs: true,
  abstract: lorem(45),
  abstract-translation: lorem(40),
  blocking: true,
  gender: "w",
  supervisor-gender: "m",
  bib: bibliography("references.bib", title: "Literaturverzeichnis"),
  draft: true
) 

= Section
== Subsection
#lorem(300)

#todo[Mehr Text]