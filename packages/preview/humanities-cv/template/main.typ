#import "../lib.typ": humanities_cv, experience, paper 
// #import "@preview/humanities-cv:0.1.0": humanities_cv, experience, paper 

#show: humanities_cv.with(
  name: "Bob Typesetterson",
  address: "5419 Hollywood Blvd Ste c731, Los Angeles, CA 90027",
  updated: [November 2025],
  contacts: (
    [(323) 555 1435],
    [#link("mailto:trixieargon@gmail.com")],
  ),
  footer-text: [Typesetterson --- Page#sym.space]
)

= Education

#experience(
  place: [Bachelor of Arts in English, Typst University],
  time: [2023--26],
)[
Undergraduate thesis #quote[A literary theory of typesetting].
Advised by:
- Laurenz Typistotle (English)
]

= Professional experience 
#experience(
  place: [#link("https://typst.app/")[Typst]],
  title: "Intern",
  time: [2026],
  location: "Online"
)[
    Built out a killer template for a CV in the humanities.
]


= Peer-reviewed Publications
#paper(
  venue: [#link("https://typst.app/blog/")[The Typst blog]],
  title: [Why literary theory matters in Typst], 
  date: [2025] 
)

#paper(
  venue: [#link("https://www.euppublishing.com/loi/jobs")[Journal of Beckett Studies] [submitted]],
  title: [Typesetting systems in Beckett],
  date: [2026]
)
