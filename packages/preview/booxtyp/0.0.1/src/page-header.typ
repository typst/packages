#let page-header-rules(body) = {
  // set page(numbering: none)
  set page(
    header: locate(
      loc => {
        // The flag to indicate whether the main document has started
        let did-main-document-start = counter(heading).at(loc).first() >= 1

        // Find all previous chapters
        let previous-chapter-elements = query(selector(heading.where(level: 1)).before(loc), loc)

        // Search for next chapters starting from the current location
        let next-chapter-elements = query(selector(heading.where(level: 1)).after(loc), loc)

        // The flag to indicate whether the current location is at the end of the main document
        let is-end-of-main-document = if previous-chapter-elements.len() > 0 {
          let previous-chapter-element = previous-chapter-elements.last()

          if next-chapter-elements.len() > 0 {
            let next-chapter-element = next-chapter-elements.first()

            previous-chapter-element.numbering != none and next-chapter-element.numbering == none and loc.page() == next-chapter-element.location().page()
          } else {
            true
          }
        } else {
          false
        }

        // Page numbering style
        let page-numbering = if did-main-document-start {
          // Roman numerals
          "1"
        } else {
          // Arabic numerals
          "i"
        }

        // The immediate next chapter
        let current-chapter-element = if next-chapter-elements.len() > 0 {
          next-chapter-elements.first()
        } else {
          none
        }

        // If the current location is in the same page as the chapter,
        // including the chapter where the current location is in
        // then do NOT show anything in the header
        if current-chapter-element != none and current-chapter-element.location().page() == loc.page() {
          return none
        }

        // Handle pages with odd page number
        if calc.odd(loc.page()) {
          // Page number
          strong(counter(page).display(page-numbering))

          // Some space
          h(8pt)

          // Search for previous chapters starting from the current location
          let previous-chapter-elements = query(selector(heading.where(level: 1)).before(loc), loc)

          // The immediate previous chapter
          let current-chapter-element = if previous-chapter-elements.len() > 0 {
            previous-chapter-elements.last()
          } else {
            none
          }

          // Current chapter
          if current-chapter-element != none {
            if current-chapter-element.numbering != none {
              strong([
                Chapter
                // Chapter number
                #numbering("1", counter(heading).at(loc).first())
              ])
            }

            // Chapter title
            smallcaps(current-chapter-element.body)
          }
        } else {
          // Handle pages with even page number
          // The header is on the right side of the page
          set align(right)

          // If the main document is ended, then only show the page number
          if is-end-of-main-document {
            // Page number
            strong(counter(page).display(page-numbering))
          } else {
            // Find the current section
            let current-section-element = {
              // Search for previous chapters
              let previous-section-elements = query(selector(heading.where(level: 2)).before(loc), loc)

              // The previous chapter
              if previous-section-elements.len() > 0 {
                previous-section-elements.last()
              } else {
                none
              }
            }

            // Current section
            if current-section-element != none {
              [
                // Section number
                #strong(numbering("1.1", ..counter(heading).at(loc)))
                // Section title
                #current-section-element.body
              ]
            }

            // Some space
            h(8pt)

            // Page number
            strong(counter(page).display(page-numbering))
          }
        }
      },
    ),
  )

  // The rest of the document
  body
}