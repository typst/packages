#import "@preview/hei-synd-thesis:0.1.1": *
#import "/metadata.typ": *

#let entry-list = (
  (
    key: "hei",
    short: "HEI",
    long: "Haute École d'Ingénierie",
    group: "University"
  ),
  (
    key: "synd",
    short: "SYND",
    long: "Systems Engineering",
    group: "University"
  ),
  (
    key: "it",
    short: "IT",
    long: "Infotronics",
    group: "University"
  ),
  (
    key: "rust",
    short: "Rust",
    plural: "Rust programs",
    long: "Rust Programming Language",
    description: "Rust is a modern systems programming language focused on safety, speed, and concurrency. It prevents common programming errors such as null pointer dereferencing and data races at compile time, making it a preferred choice for performance-critical applications.",
    group: "Programming Language"
  ),
)

#let make_glossary(
  gloss:true,
  title: i18n("gloss-title", lang: option.lang),
) = {[
  #if gloss == true {[
    #pagebreak()
    #set heading(numbering: none)
    = #title <sec:glossary>
    #print-glossary(
      entry-list,
      // show all term even if they are not referenced, default to true
      show-all: false,
      // disable the back ref at the end of the descriptions
      disable-back-references: false,
    )
  ]} else{[
    #set text(size: 0pt)
    #title <sec:glossary>
    #print-glossary(
      entry-list,
      // show all term even if they are not referenced, default to true
      show-all: false,
      // disable the back ref at the end of the descriptions
      disable-back-references: false,
    )
  ]}
]}
