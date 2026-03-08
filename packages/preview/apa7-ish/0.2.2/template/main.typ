
#import "@preview/apa7-ish:0.2.2": *

#show: conf.with(
  title: "An Intriguing Title",
  subtitle: "Subtitle",
  documenttype: "Research Article",
  anonymous: false,
  authors: (
    (
      name: "First Last",
      email: "email@example.com",
      affiliation: "University of Instances",
      postal: "Address String",
      orcid: "0000-1111-1111-1111",
      corresponding: true,
    ),
    (
      name: "First Last",
      affiliation: ("University of Instances", "University of Examples"),
      orcid: "0000-1111-1111-1111",
    ),
  ),
  abstract: [Abstract goes here],
  date: "May 20, 2025",
  keywords: [informative, keywords],
  funding: [Funding Statement],
)

= Introduction

Start writing here.

#pagebreak()

= Declaration of Interest Statement
#label("declaration-of-interest-statement")
The authors report there are no competing interests to declare.

#pagebreak()

// add your .bib file here
// #bibliography("references.bib")
