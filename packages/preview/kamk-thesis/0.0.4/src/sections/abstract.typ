#import "../core/utils.typ": format-authors

// Clearance below the abstract logo, shared across frontmatter pages.
#let frontmatter-top-margin = 3cm

// Place the KAMK logo in the top-right corner (~1.5 cm from the top and right
// edges, accounting for the SVG's built-in transparent padding).
#let abstract-logo = place(
  top + right,
  dx: -1.2cm,
  dy: 1.2cm,
  image(
    "../../assets/KAMK_rgb_copyrighted.svg",
    width: 17.3%,
    alt: "Kajaani University of Applied Sciences logo",
  ),
)

#let render-abstract(
  lang-dict,
  authors: (),
  language: "fi",
  title: "",
  degree: "",
  keywords: (),
  body
) = {
  // Place the logo in the top-right corner and move the abstract heading
  // below the logo's bottom edge. Scoped here so other pages are unaffected.
  set page(
    margin: (top: frontmatter-top-margin),
    background: abstract-logo,
  )

  // The abstract page body text size is 10pt
  set text(size: 10pt)
  
  // Heading is 11pt, bold
  show heading: set text(size: 11pt, weight: "bold")
  show heading: set block(below: 1.5em)

  // Not outlined (not in Table of Contents)
  heading(level: 1, outlined: false, strong(lang-dict.abstract))

  // Metadata block: Author, Title, Degree, Keywords
    block[
      *#lang-dict.author*: #format-authors(authors, language: language) \
      *#lang-dict.title*: #title \
      *#lang-dict.degree*: #degree \
      *#lang-dict.keywords*: #keywords.join(", ")
    ]
  
  // A gap between the metadata and the actual abstract text
  v(1.5em)
  
  // Abstract text block.
  body
}
