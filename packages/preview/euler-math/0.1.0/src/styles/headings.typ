#import "colors.typ": neo-maroon

#let setup-headings(body) = {
  // ==========================================
  // 1. HEADING NUMBERING LOGIC
  // ==========================================
  // Customizes the numbering format for all headings.
  // Level 1: "1" (no trailing dot).
  // Level 2+: "1.1" (joined with dots, no trailing dot).
  set heading(numbering: (..nums) => {
    let pos = nums.pos()

    if pos.len() == 1 {
      str(pos.first())
    } else {
      pos.map(str).join(".")
    }
  })


  // ==========================================
  // 2. VISUAL STYLES PER HEADING LEVEL
  // ==========================================

  // --- Level 1 (Main Chapters) ---
  show heading.where(level: 1): it => {
    // Check if the heading has numbering (e.g., Table of Contents does not)
    if it.numbering == none {
      // STYLE FOR UNNUMBERED HEADINGS (like Outline/TOC title)
      set text(size: 18pt, font: "New Computer Modern Sans", weight: "bold", fill: black)
      it.body
    } else {
      // STYLE FOR STANDARD CHAPTERS (with section symbol §)
      set text(size: 18pt, font: "New Computer Modern Sans")
      box[
        #text(fill: neo-maroon)[#sym.section #counter(heading).display()]
        #h(5pt)
        #it.body
      ]
    }
  }

  // --- Level 2 (Subsections) ---
  show heading.where(level: 2): it => {
    set text(size: 14pt, font: "New Computer Modern Sans")

    box[
      #text(fill: neo-maroon)[#sym.section#counter(heading).display()]
      #h(5pt)
      #it.body
    ]
  }

  // --- Level 3 (Sub-subsections) ---
  show heading.where(level: 3): it => {
    set text(size: 12pt, font: "New Computer Modern Sans")

    box[
      #text(fill: neo-maroon)[#sym.section#counter(heading).display()]
      #h(5pt)
      #it.body
    ]
  }

  body
}
