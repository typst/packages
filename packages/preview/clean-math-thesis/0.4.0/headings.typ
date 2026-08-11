// Heading settings.
// In a thesis we want
// - Level 1 headings to be called Chapters [heading1-as-chapter]
// - PDF bookmark to contain heading numberings 1.1.2 etc [hacks.typ: bookmark-numbering-hack]
// - Chapters to start on a new page [break-before-headings]

// They must be created in the precise order above, so the PDF link points to directly
// ABOVE the cosmetics and BELOW the breaks.

#import "hacks.typ": bookmark-numbering-hack

// prepend breaks before headings
#let break-before-headings(it) = {
  // Automatically insert a page break before each chapter
  show heading.where(
    level: 1
  ): it => {
    pagebreak(weak: true)
    it
  }
  // only valid for abstract and declaration
  show heading.where(
    outlined: false,
    level: 2
  ): it => {
    set align(center)
    set text(18pt)
    it.body
    v(0.5cm, weak: true)
  }
  // Settings for sub-sub-sub-sections e.g. section 1.1.1.1
  show heading.where(
    level: 4
  ): it => {
    it.body
    linebreak()
  }
  // same for level 5 headings
  show heading.where(
    level: 5
  ): it => {
    it.body
    linebreak()
  }
  it
}

// stylizes level 1 headings
#let heading1-as-chapter(heading-color, it) = {
  // ------------------- Settings for Chapter headings -------------------
  show heading.where(level: 1): set heading(supplement: [Chapter])
  show heading.where(
    level: 1,
  ): it => {
    if it.numbering != none {
      block(width: 100%)[
        #line(length: 100%, stroke: 0.6pt + heading-color)
        #v(0.1cm)
        #set align(left)
        #set text(22pt)
        #text(heading-color)[Chapter
        #counter(heading).display(
          "1:" + it.numbering
        )]

        #it.body
        #v(-0.5cm)
        #line(length: 100%, stroke: 0.6pt + heading-color)
      ]
    }
    else {
      block(width: 100%)[
        #line(length: 100%, stroke: 0.6pt + heading-color)
        #v(0.1cm)
        #set align(left)
        #set text(22pt)
        #it.body
        #v(-0.5cm)
        #line(length: 100%, stroke: 0.6pt + heading-color)
      ]
    }
  }
  it
}

#let thesis-heading(heading-color, it) = {
  // DO NOT CHANGE THE ORDER
  show: it => heading1-as-chapter(heading-color, it)
  show: bookmark-numbering-hack
  show: break-before-headings
  it
}