#import "colors.typ": neo-maroon

#let setup-page(body) = {

  // ==========================================
  // DYNAMIC PAGE HEADER CONFIGURATION
  // ==========================================
  // This configuration places the current chapter title and page number
  // dynamically at the top of every page.
  set page(
    header: context {
      // 1. QUERY EXISTING HEADINGS
      // Retrieve all Level 1 headings that appear before our current location.
      let before = query(heading.where(level: 1).before(here()))

      // Retrieve all Level 1 headings that appear after our current location.
      let after = query(heading.where(level: 1).after(here()))

      // 2. CHECK CURRENT PAGE
      // Filter the 'after' headings to see if any Level 1 heading
      // actually starts exactly ON the current page.
      let on_page = after.filter(h => h.location().page() == here().page())

      // 3. PRIORITY LOGIC
      // If a new section starts on this page, prioritize it.
      // Otherwise, fall back to the last section that started on a previous page.
      let current-heading = if on_page.len() > 0 {
        on_page.first()
      } else if before.len() > 0 {
        before.last()
      } else {
        none
      }

      // 4. DRAW HEADER
      // If a valid heading was found, draw the header block.
      if current-heading != none {
        // Base styles for the header text
        set text(font: "New Computer Modern Sans", size: 10pt, weight: "bold")

        // Draw a full-width block with a black bottom border rule
        block(width: 100%, stroke: (bottom: 0.7pt + black), inset: (bottom: 6pt))[

          // Print the section number (if it exists) with the custom magenta color
          #if current-heading.numbering != none {
            text(fill: neo-maroon)[
              #sym.section#numbering(current-heading.numbering, ..counter(heading).at(current-heading.location()))
            ]
            h(7pt) // Fixed horizontal spacing between number and title
          }
          // Print the heading title, then push the page number to the far right
          #current-heading.body
          #h(1fr)
          #counter(page).display()
        ]
      }
    },
  )


  body
}
