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
#include("chapters/05-appendix-a.typ.typ")
