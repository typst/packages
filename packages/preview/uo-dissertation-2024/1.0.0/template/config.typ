// config.typ - Configuration and styling rules
// This file contains all the formatting functions and settings

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
  )
  // Block quote settings
  set quote(block: true)
  show quote: it => {
    set par(first-line-indent: 0pt, leading: 1em)
    pad(left: 0.5in, it)
  }
  
  // Figure and table numbering - by chapter (e.g., 1.1, 1.2, 2.1, 2.2)
  set figure(numbering: n => {
    let chapter = counter(heading).get().at(0)
    let fig-num = n
    numbering("1.1", chapter, fig-num)
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
              let chapter = counter(heading).get().at(0)
              let fig-num = counter(figure).get().first()
              numbering("1.1", chapter, fig-num)
            }#[.]
          ]#[ ]#it.caption.body
        ]
      ]
    }
  }
  
  // Heading settings - enable numbering
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
  show heading.where(level: 2): it => {
    v(0.25in)
    set align(left)
    set text(size: 12pt)
    // Display the heading number in format: 1.1
    let nums = counter(heading).at(it.location())
    [#nums.at(0).#nums.at(1)]
    h(0.5em)
    it.body
    v(0.25in)
  }
  // Level 3 headings (left-aligned, italic, with numbering)
  show heading.where(level: 3): it => {
    v(0.25in)
    set text(size: 12pt, style: "italic")
    // Display the heading number in format: 1.1.1
    let nums = counter(heading).at(it.location())
    [#nums.at(0).#nums.at(1).#nums.at(2)]
    h(0.5em)
    it.body
    v(0.2in)
  }
  // Level 4 headings (left-aligned, regular, with numbering)
  show heading.where(level: 4): it => {
    v(0.2in)
    set text(size: 12pt)
    // Display the heading number in format: 1.1.1.1
    let nums = counter(heading).at(it.location())
    [#nums.at(0).#nums.at(1).#nums.at(2).#nums.at(3)]
    h(0.5em)
    it.body
    v(0.15in)
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
#let appendix(letter, title) = {
  pagebreak()
  align(center)[
    #text(size: 12pt)[
      APPENDIX #letter
      
      #upper(title)
    ]
  ]
  v(0.5in)
}

// Function for creating tables with UO formatting
#let uo-table(caption-text, ..args) = {
  figure(
    table(..args),
    caption: caption-text,
    kind: table,
    supplement: [Table],
  )
}

// Function for creating figures with UO formatting
#let uo-figure(content, caption-text) = {
  figure(
    content,
    caption: caption-text,
    supplement: [Figure],
  )
}

// Function for creating schemes with UO formatting
#let uo-scheme(content, caption-text) = {
  figure(
    content,
    caption: caption-text,
    supplement: [Scheme],
    kind: "scheme",
  )
}

// Function for formatting references (single-spaced with space between)
#let reference(content) = {
  set par(first-line-indent: 0pt, leading: 1em)
  content
  v(1em)
}