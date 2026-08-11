#import "@preview/supercharged-hm:0.1.1": *
#import "glossary.typ" : glossary

#show: hm-template.with(
  title: "HM Template",
  subtitle: [Advanced Typst Styling],
  doc-type: "Modularbeit",
  authors: authors("Peter Lustig"),
  // set to "de" for german
  language: "en",
  // Table of content depth, set to none to disable
  toc-depth: 2,
  // displays the acronyms defined in the acronyms dictionary
  // remove to disable
  glossary: glossary,
  // Leave empty for none
  bibliography: bibliography("sources.bib"),
)


// Remove after reading
#include "example_usage.typ"

= Introduction

You can use an #gls("api") to retrieve data@balzert_lehrbuch_2011

#lorem(100)
