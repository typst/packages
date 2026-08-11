#import "colors.typ": neo-blue

#let setup-typography(body) = {
  // ==========================================
  // GLOBAL OUTLINE CONFIGURATION
  // ==========================================
  // This sets the depth of the Table of Contents and how much
  // each nested level is indented.


  // ==========================================
  // LEVEL 1: Main Chapters/Sections
  // ==========================================
  // Level 1 entries are styled with a bold sans-serif font, add
  // vertical padding, and right-align the page number without dot leaders.
  show outline.entry.where(level: 1): it => {
    let loc = it.element.location()
    let page-num = counter(page).at(loc).first()

    link(loc)[
      #if it.element.numbering != none [
        #box(inset: (top: 10pt, bottom: 1pt))[
          #text(font: "New Computer Modern Sans", weight: "bold")[
            #numbering(it.element.numbering, ..counter(heading).at(loc))
            #h(5pt)
            #it.element.body
          ]
          #h(1fr) // Pushes the page number to the right edge (no dots)
          #text(fill: black, font: "New Computer Modern Sans", weight: "bold")[#page-num]
        ]
      ]
    ]
  }

  // ==========================================
  // LEVEL 2: Subsections
  // ==========================================
  // Level 2 entries are indented by 15pt, feature a repeating dot leader
  // to connect the title to the page number, and force the page number to be black.
  show outline.entry.where(level: 2): it => {
    let loc = it.element.location()
    let page-num = counter(page).at(loc).first()

    link(loc)[
      #if it.element.numbering != none [
        #box(inset: (left: 15pt))[
          #numbering(it.element.numbering, ..counter(heading).at(loc))
          #h(0.2em)
          #it.element.body
          #h(5pt)
          #text(fill: black)[
            #box(width: 1fr, repeat(gap: 5pt)[.]) // Generates the dot leaders
            #h(5pt)
            #page-num
          ]
        ]
      ]
    ]
  }

  // ==========================================
  // LEVEL 3: Sub-subsections
  // ==========================================
  // Level 3 same as Level 2
  // #show outline.entry.where(level: 3): it => {
  //   let loc = it.element.location()
  //   let page-num = counter(page).at(loc).first()

  //   link(loc)[
  //     #if it.element.numbering != none [
  //       #box(inset: (left: 15pt))[
  //         #numbering(it.element.numbering, ..counter(heading).at(loc))
  //         #h(0.2em)
  //         #it.element.body
  //         #h(5pt)
  //         #text(fill: black)[
  //           #box(width: 1fr, repeat(gap: 5pt)[.]) // Generates the dot leaders
  //           #h(5pt)
  //           #page-num
  //         ]
  //       ]
  //     ]
  //   ]
  // }

  // ==========================================
  // GLOBAL RULE: All Outline Entries
  // ==========================================
  // Sets the base text color for the entire outline.
  // Specific levels (like Level 1 and 2 above) override this for their
  // page numbers using text(fill: black).
  show outline.entry: it => {
    set text(fill: neo-blue)
    it
  }
  
  body
}
