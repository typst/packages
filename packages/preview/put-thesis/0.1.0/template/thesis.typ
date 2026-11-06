/****************************************************************/
/*                put-thesis – a Typst template                 */
/*                Copyleft 2025 Piotr Kaszubski                 */
/*                                                              */
/*        based on Bachelor's & Master's Thesis Template        */
/*  Copyleft by Dawid Weiss, Marta Szachniuk, Maciej Komosiński */
/*          Faculty of Computing and Telecommunication          */
/*            Poznan University of Technology, 2022             */
/****************************************************************/
#import "@preview/put-thesis:0.1.0": *

#show: put-thesis.with(
  lang: "en",  // or "pl"
  ttype: "bachelor",  // or "master"
  title: "Title of the thesis",
  authors: (
    ("First author", 111111),
    ("Second author", 222222),
    ("Third author", 333333),
  ),
  supervisor: "prof. dr hab. inż. Name",
  year: 2025,  // Year of final submission (not graduation!)

  // Override only if you're not from WIiT/CAT faculty or CompSci institute
  // faculty: "My faculty",
  // institute: "My institute",
  
  // Override to use a different font family. Default is "New Computer Modern".
  // If writing locally, the font must be installed on the system.
  // If writing online and the font is not supported out-of-the-box, the font
  // files must be manually uploaded and should be detected automatically,
  // irrespective of their location.
  // font: "My Cool Font",

  // Enable to have alternating page numbers for odd/even pages. This is
  // standard practice in books and may be useful if you want to print your
  // thesis.
  book-print: false,
)
#abstract[
  Write your abstract here.
]
#outline(depth: 3)
#pagebreak(weak: true)
#show: styled-body

#include("chapters/01-introduction.typ")
#include("chapters/02-literature-review.typ")
#include("chapters/03-own-work.typ")
#include("chapters/04-conclusions.typ")

#pagebreak(weak: true)
#bibliography("references.bib", style: "ieee")

#show: appendices
#include("chapters/05-appendix-a.typ")
#include("chapters/06-appendix-b.typ")
