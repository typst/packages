#import "@preview/scribbling-hm:0.1.9": *

#import "abbreviations.typ": abbreviations-list
#import "variables.typ": variables-list

#show: thesis.with(
  title: lorem(15),
  title-translation: lorem(12),
  language: "de",
  study-name: study-name.IFB,
  submission-date: datetime.today(),
  student-id: 12345678,
  author: "Erika Mustermann",
  supervisors: "Prof. Dr. Max Mustermann",
  semester: "WiSe 2025/26",
  study-group: "IF7",
  birth-date: datetime(year: 2000, day: 1, month: 1),
  abstract: none,
  abstract-translation: none,
  blocking: true,
  gender: "w",
  examiner-gender: "m",
  bib: bibliography("references.bib", title: none),
  abbreviations-list: abbreviations-list,
  variables-list: variables-list,
  appendix: include "appendix.typ",
  draft: true,
  print: false
)

= Section
== Subsection
This @typst @typst_doc formatting is defined in the variables list. It is processed by a @cpu. Another sentence using @cpu. #footnote[A third @cpu sentence maybe?]

#todo[Mehr Text]

Bullet points are indented by default:

- first
- second
  - first
  - second
- third

Numbered lists too:

+ first
+ second
  + first
  + second
+ third

#lorem(20)

#figure(
  ```rust
  fn main() {
      println!("Hello World!");
  }
  ```,
  caption: ["Hello World" in Rust]
)

= Another Section
#lorem(40)

#pagebreak()

#lorem(200)
#pagebreak()

#lorem(200)
