// INVICTA THESIS TEMPLATE for Typst
// Main package exports
// João Lourenço, July 2025 (Typst version)

// Import all template modules
#import "template.typ": invicta-thesis, main-content
#import "covers.typ": make-cover, make-committee-page
#import "toc.typ": make-toc
#import "utils.typ": *

// Export the main template function
#let template = invicta-thesis

// Export utility functions
#let cover = make-cover
#let committee-page = make-committee-page
#let table-of-contents = make-toc

// Export bibliography function
#let make-bibliography(style) = {
  // Set custom header for bibliography pages
  set page(
    header: context {
      let current-page = here().page()
      let page-number = counter(page).at(here()).first()
      
      // Query all headings to find the References heading
      let all-headings = query(heading)
      let references-heading = all-headings.filter(h => 
        h.body == [References] and h.location().page() == current-page
      )
      
      // No header on first page of bibliography (where References heading appears)
      if references-heading.len() > 0 {
        return none
      }
      
      // Create header with "REFERENCES" on left and page number on right
      pad(
        left: -1cm,
        right: -0.7cm,
        grid(
          columns: (1fr, auto),
          align: (left, right),
          text(size: 12pt, style: "italic")[REFERENCES],
          text(size: 12pt)[#page-number],
        )
      )
    },
    footer: context {
      let current-page = here().page()
      let page-number = counter(page).at(here()).first()
      
      // Query all headings to find the References heading
      let all-headings = query(heading)
      let references-heading = all-headings.filter(h => 
        h.body == [References] and h.location().page() == current-page
      )
      
      // Show footer only on first page of bibliography (where References heading appears)
      if references-heading.len() > 0 {
        return align(center)[#text(size: 11pt)[#page-number]]
      }
      
      return none
    },
  )
  
  bibliography("../template/refs.bib", style: style, title: "References")
}

// Export main content wrapper that retrieves config from state
#let main-content-wrapper = (body) => {
  context {
    let config = get-config()
    main-content(config, body)
  }
}
