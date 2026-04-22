#import "../mse-hes-thesis.typ": appendix, report-template

#show: report-template.with(
  title: "Example Report",
  author: "John Doe",
  orientation: "Computer Science",
  teacher: "Alice Smith",
  company: "Tartempion SA",
  confidential: false,
)

= Introduction
Reference @reference

#figure(
  raw(
    "Console.log('Hello, world!');
",
    lang: "js",
    block: true,
  ),
  caption: "JavaScript example",
)


#pagebreak()
#bibliography(full: true, "bibliography.bib", style: "ieee")
#pagebreak()

#show: appendix

= Proofs
#lorem(100)
