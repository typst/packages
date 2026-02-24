# leonux

Minimalistic typst slides (similar to LaTeX beamer)

# Quick usage guide

```typst
#import "@preview/leonux:1.1.0": *

// Setup the format and enter personal information
#show: setup.with(
	ratio: "16-9",
	primary: rgb("137C24"), // This is the default color, if primary: none
	title: "Title of the presentation",
	subtitle: "Subtitle of the presentation",
	date: "April 9, 2025",
	author: "Name",
	institute: "Institute"
)

// slide number only counts slide and content,references (both based on slide)

// Create titlepage

#titlepage()

// Create Table of contents (shows sections, not slides)

#content(title: "Content")

// Create a section

#section(title: "Probability")

// Create a slide

#slide(title: "Name of the slide")[
	- Some content
	- Some citation @ref of Leonux #footnote("Leonux - minimalistic typst slides")
	// Create a block (e.g. for a definition)
	#my-block(title: "Definition: Law of large numbers")[
		$ forall epsilon > 0: lim_(n -> infinity) P(|r_n - p| <= epsilon) = 1 $
		Or in words: For large $n$ applies: $p approx r_n$.
	]

	This text will be shown on the first and second subslide. \
	#show: later // Make following content appear on the next subslide
	This text will only be shown on the second subslide.
]

// Create bibliography

#references(title:"References")[
	#bibliography("bibliography.bib")
]
```
