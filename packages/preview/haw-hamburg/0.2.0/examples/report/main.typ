// Import dependencies such as glossaries etc.
#import "dependencies.typ": *

// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#import "../../src/lib.typ": report
#show: report.with(
  language: "en",
  title: "Universal Declaration of Human Rights",
  author:"United Nations",
  faculty: "Engineering and Computer Science",
  department: "Computer Science",
  include-declaration-of-independent-processing: true,
)

// Enable glossary
// Use: #gls("key") or #glspl("key") to reference and #print-glossary to print it
// More documentation: https://typst.app/universe/package/glossarium/
#show: make-glossary

// Print abbreviations
#pagebreak(weak: true)
#include "abbreviations.typ"

// Include chapters of report
#pagebreak(weak: true)
#include "chapters/01_preamble.typ"
#include "chapters/02_articles.typ"

// Print glossary
#pagebreak(weak: true)
#include "glossary.typ"

// Print bibliography
#pagebreak(weak: true)
#bibliography("bibliography.bib", style: "../../src/assets/ieeetran.csl")
