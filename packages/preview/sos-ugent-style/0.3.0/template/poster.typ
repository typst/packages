#import "@preview/sos-ugent-style:0.3.0" as ugent: poster-template

// The template only fixes the 'background' (footer, header & color) and
// the area where content will be placed.
// Use any layout-mechanism to your liking to actually create the content.
// Possible Typst packages:
// - litfass
// - poster-syndrome
// - postercise
// - peace-of-posters (layout-ing not really useful?)
// You can also use `#columns` or any other native Typst feature, but `set page(columns: )`
// doesn't work until the mechanism of placing the cover has been refactored.
// This refactor (TODO) will make content part of the page and set the
// correct margins, instead of wrapping everything in a container.

// One way or another, they use 'boxes' or 'frames', which are layouted onto
// the provided area.
// `#ugent.poster` provides some themed boxes (compatibility with these
// layout-mechanisms is not guaranteed. Most of the times, these mechanisms aren't
// even properly separated & exported from the mentioned packages/templates).
#show: poster-template.with(
  title: "A long title",
  faculty: none,
  language: "en",
  header: none,
  footer: h(1fr)+context {
    let gridunit = state("ugent-gridunit").get()
    box(
      inset: (top: -20pt),
      ugent.poster.contact-frame(
        width: auto,
        height: 100%,
        inset: 5pt,
        outset: (right: gridunit)
      )[
        = Contact (second option)
        \<name\>.\<surname\>\@ugent.be #linebreak()
      ]
    )
  },
)

#ugent.poster.title("test")
= Test
Dit is een initieële UGent poster.
Voor een voorbeeld van wat bereikt kan worden, zie https://codeberg.org/th1j5/ugent-FEARS-2025/src/branch/main/poster.pdf.

#lorem(200)

#ugent.poster.focus-frame[
  = Test
  #lorem(4)
]

#v(1fr)
#lorem(100)

#ugent.poster.contact-frame[
  = Contact
  \<name\>.\<surname\>\@ugent.be #linebreak()
  www.ugent.be/\<...\>

  #box(image("assets/figures/facebook-icon.png")) Universiteit Gent \
  #box(image("assets/figures/twitter-icon.png")) \@ugent \
  #box(image("assets/figures/linkedin-icon.png")) Ghent University
]
