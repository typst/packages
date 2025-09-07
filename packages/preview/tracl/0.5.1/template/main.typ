
// This is a minimal starting document for tracl, a Typst style for ACL.
// See https://github.com/coli-saar/tracl for details.


#import "@preview/tracl:0.5.1": *

#show: doc => acl(doc,
  anonymous: false,
  title: [A Blank ACL Paper],
  authors: (
    (
      name: "Your Name",
      affiliation: [Your Affiliation],
      email: "your@email.edu",
    ),
  ),
)


#abstract[
  #lorem(50)
]


= Introduction

#lorem(80)

#lorem(80)

#lorem(80)


// Uncomment this to include your bibliography

/*
#import "@preview/blinky:0.1.0": link-bib-urls
#let bibsrc = read("custom.bib")

#link-bib-urls(bibsrc)[
   #bibliography("custom.bib", style: "./association-for-computational-linguistics-blinky.csl")
]
*/

