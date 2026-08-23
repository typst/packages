#import "@preview/supercharged-hm:1.0.0": *
#import "glossary.typ" : glossary

#show: hm-template.with(
  title: "HM Template",
  subtitle: [Advanced Typst Styling],
  authors: authors("Peter Lustig"),
  doc-type: "Modularbeit",
  // set to "de" for german
  language: "en",
  // displays the acronyms defined in the acronyms dictionary
  // remove to disable
  glossary: glossary,
  // Leave empty for none
  bibliography: bibliography("sources.bib"),
  // Table of content depth, set to none to disable
  toc-depth: 2,
)


// Remove after reading
#include "supercharged-hm-usage.typ"

= Introduction

You can use an #gls("api") to retrieve data@balzert_lehrbuch_2011

#lorem(100)
