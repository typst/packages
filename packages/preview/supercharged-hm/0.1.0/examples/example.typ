#import "/template/lib.typ": *
#import "example-glossary.typ" : glossary

#show: hm-template.with(
  title: "HM Template",
  subtitle: [Advanced Typst Styling],
  doc_type: "Modularbeit",
  authors: authors("Peter Lustig"),
  // set to "de" for german
  language: "en",
  // Table of content depth, set to none to disable
  toc-depth: 2,
  // displays the acronyms defined in the acronyms dictionary
  // remove to disable
  glossary: glossary,
  // Leave empty for none
  bibliography: bibliography("example-sources.bib"),
)

= Introduction

You can you an #gls("api") to retrieve data.

#lorem(100)@iso18004
