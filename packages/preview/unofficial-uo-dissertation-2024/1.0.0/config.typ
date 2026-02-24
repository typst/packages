// config.typ - Configuration and styling rules
// This file contains all the formatting functions and settings

// State variables for appendix figure numbering only
#let in-appendix = state("in-appendix", false)
#let appendix-letter = state("appendix-letter", "")

// Main styling function that applies all UO formatting rules
#let apply-uo-style(doc) = {
  // Page setup - 1 inch margins all around
  set page(
    paper: "us-letter",
    margin: (top: 1in, bottom: 1in, left: 1in, right: 1in),
    numbering: none, // Will be set per section
  )
  // Font settings - Times New Roman 12pt
  set text(
    font: "STIX Two Text",
    size: 12pt,
    lang: "en",
  )
  // Paragraph settings
  set par(
    // first-line-indent: 0.5in,
    justify: false, // Left-aligned as preferred by UO
    leading: 2em, // Double spacing for main text
    spacing: 2em, // Space between paragraphs = same as line spacing
  )
  // Block quote settings
  set quote(block: true)
  show quote: it => {
    set par(first-line-indent: 0pt, leading: 1em)
    pad(left: 0.5in, it)
  }
  
  // Figure and table numbering - by chapter or appendix
  set figure(numbering: (..nums) => {
    let loc = here()
    let is-appendix = in-appendix.at(loc)
    let letter = appendix-letter.at(loc)
    let n = nums.pos().first()
    
    if is-appendix {
      // Appendix: S.A.1 (with letter) or S.1 (without)
      if letter != "" {
        "S." + letter + "." + str(n)
      } else {
        "S." + str(n)
      }
    } else {
      // Chapter: 1.1, 1.2, 2.1, 2.2
      let chapter = counter(heading).at(loc).at(0)
      numbering("1.1", chapter, n)
    }
  })
  
  // Figure caption styling - single spaced, period after number
  show figure: it => {
    // Center align the figure content
    align(center)[
      #it.body
    ]
    v(0.5em)
    
    // Left align the caption
    if it.caption != none {
      align(left)[
        #block[
          #set text(size: 12pt)
          #set par(leading: 1em, first-line-indent: 0pt)
          // Bold the figure number, regular text for caption
          #text(weight: "bold")[
            #it.supplement 
            #context {
              let is-appendix = in-appendix.at(it.location())
              let letter = appendix-letter.at(it.location())
              let fig-num = counter(figure.where(kind: it.kind)).at(it.location()).first()
              
              if is-appendix {
                // Appendix: A.1 or B.1 (with letter) or A.1 (without)
                if letter != "" {
                  [#letter.#fig-num]
                } else {
                  [A.#fig-num]
                }
              } else {
                // Chapter: 1.1, 1.2, 2.1, 2.2
                let chapter = counter(heading).at(it.location()).at(0)
                numbering("1.1", chapter, fig-num)
              }
            }#[.]
          ]#[ ]#it.caption.body
        ]
      ]
    }
    // Space after figure = same as paragraph spacing (2em)
    v(2em)
  }
  
  // Heading settings - enable numbering (for chapters only, manual in appendices)
  set heading(numbering: "1.1.1.1")
  
  // Chapter headings (level 1) - display as "CHAPTER I TITLE"
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set align(center)
    set text(size: 12pt, weight: "regular")
    // Get the chapter number from the counter
    let nums = counter(heading).at(it.location())
    let chapter-num = nums.at(0)
    // Convert to Roman numeral
    let roman = if chapter-num == 1 { "I" }
      else if chapter-num == 2 { "II" }
      else if chapter-num == 3 { "III" }
      else if chapter-num == 4 { "IV" }
      else if chapter-num == 5 { "V" }
      else if chapter-num == 6 { "VI" }
      else if chapter-num == 7 { "VII" }
      else if chapter-num == 8 { "VIII" }
      else if chapter-num == 9 { "IX" }
      else if chapter-num == 10 { "X" }
      else { str(chapter-num) }
    [CHAPTER #roman
    
    #upper(it.body)]
    v(0.5in)
  }
  // Level 2 headings (left-aligned, NOT italic, with numbering)
  // In chapters: automatic (1.1, 1.2). In appendices: manual (write "A.1", "A.2")
  show heading.where(level: 2): it => {
    v(1.5em)
    set align(left)
    set par(first-line-indent: 0pt)
    set text(size: 12pt)
    // Display the heading number only in chapters (automatic)
    // In appendices, the number is part of the heading text itself
    let nums = counter(heading).at(it.location())
    context {
      if not in-appendix.at(it.location()) {
        [#nums.at(0).#nums.at(1)]
        h(0.5em)
      }
    }
    it.body
    v(0.5em)
  }
  // Level 3 headings (left-aligned, italic, with numbering)
  show heading.where(level: 3): it => {
    v(1.5em)
    set align(left)
    set par(first-line-indent: 0pt)
    set text(size: 12pt, style: "italic")
    // Display the heading number only in chapters
    let nums = counter(heading).at(it.location())
    context {
      if not in-appendix.at(it.location()) {
        [#nums.at(0).#nums.at(1).#nums.at(2)]
        h(0.5em)
      }
    }
    it.body
    v(0.5em)
  }
  // Level 4 headings (left-aligned, regular, with numbering)
  show heading.where(level: 4): it => {
    v(1.5em)
    set align(left)
    set par(first-line-indent: 0pt)
    set text(size: 12pt)
    // Display the heading number only in chapters
    let nums = counter(heading).at(it.location())
    context {
      if not in-appendix.at(it.location()) {
        [#nums.at(0).#nums.at(1).#nums.at(2).#nums.at(3)]
        h(0.5em)
      }
    }
    it.body
    v(0.5em)
  }
  doc
}

// Helper function for table of contents entries with leader dots
#let toc-entry(number, title, page) = {
  if number != none {
    [#number.#h(0.5em)]
  }
  title
  box(width: 1fr, repeat[.#h(2pt)])
  [#page]
}

// Helper function for indented TOC subsections
#let toc-subsection(title, page) = {
  pad(left: 0.5in)[
    #title
    #box(width: 1fr, repeat[.#h(2pt)])
    #page
  ]
}

// Function to create appendix headings
// Use letter="A" for Appendix A, letter="" for single unnumbered appendix
#let appendix(letter, title) = {
  pagebreak()
  // Mark that we're now in appendix mode (for figure numbering)
  in-appendix.update(true)
  appendix-letter.update(letter)
  // Reset counters for this appendix
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: "scheme")).update(0)
  
  align(center)[
    #text(size: 12pt)[
      APPENDIX#if letter != "" [ #letter]
      
      #upper(title)
    ]
  ]
  v(0.5in)
}