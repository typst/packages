// Page number layout config.
#let num-layout(
      p-num-start: 1, // Starting page number
      p-num-alt-start: none, // Alternative starting page number (e.g., for chapters)
      p-num-pattern: "1", // Pattern for page numbering (e.g., "1", "i", "a", "A")
      p-num-placement: bottom, // Placement of page numbers (top or bottom)
      p-num-align-horizontal: center, // Horizontal alignment of page numbers
      p-num-align-vertical: horizon, // Vertical alignment of page numbers
      p-num-pad-left: 0pt, // Extra padding added to the left of the page number
      p-num-pad-horizontal: 1pt, // Horizontal padding for page numbers
      p-num-size: 12pt, // Size of page numbers
      p-num-border: none, // Border color for page numbers. eg: luma(0)
      p-num-halign-alternate: true, // Alternate horizontal alignment between left and right pages.
    ) = {
      // TODO: add ability to set a shape behind page number
  let layout = (
      p-num-start: p-num-start,
      p-num-alt-start: p-num-alt-start,
      p-num-pattern: p-num-pattern,
      p-num-placement: p-num-placement,
      p-num-align-horizontal: p-num-align-horizontal,
      p-num-align-vertical: p-num-align-vertical,
      p-num-pad-left: p-num-pad-left,
      p-num-pad-horizontal: p-num-pad-horizontal,
      p-num-size: p-num-size,
      p-num-border: p-num-border,
      p-num-halign-alternate: p-num-halign-alternate,
    )
  return layout
}

// This function creates a signature (booklet) layout for printing.
// It takes various parameters to configure the layout, such as
// binding margins, page numbering styles, content padding, and the content to be laid out.
#let sig(
  page-margin-binding: 0in, // Binding margin for each page (space between pages)
  page-border: none, // Color for the border around each page (set to none for no border)
  draft: false, // Whether to output draft or final layout
  p-num-layout: (), // The layout of the page number
  pad-content: 5pt, // Padding around page content
  contents: (), // Content to be laid out in the booklet (an array of content blocks)
) = {
    // Begin processing given content into booklet format
    let wrapped-cont = ()  // Array to hold wrapped content
    let p-num = 1 // Initialize page number
    
    // Loop through the provided content and package for placement in the booklet
    // We will insert a page number for each page before we reorder things
    for value in contents {
      let page
      let p-num-placement
      let p-num-height   
      let p-num-value
      let page-number-box
      // Compose a page number box for this page if it falls within a defined layout
      for layout in p-num-layout {
        // Check if this is the right layout or not
        if layout.at("p-num-start") <= p-num {
          // If it is check whether we need to build a box or not
          if layout.at("p-num-pattern") == none {
            page-number-box = none
            continue
          }
        
          // Substitute alternative starting number if specified for this page number layout
          if layout.at("p-num-alt-start") != none {
            p-num-value = (p-num - layout.at("p-num-start")) + layout.at("p-num-alt-start")
          } else {
            p-num-value = p-num
          }
        
          // Build dimensions of box from layout definition
          p-num-height = layout.at("p-num-size") + layout.at("p-num-pad-horizontal")

          // Hold on to placment for use when building pages
          p-num-placement = layout.at("p-num-placement")
            let align-h = layout.at("p-num-align-horizontal")
            if calc.even(p-num) and layout.at("p-num-halign-alternate") {
              if (align-h == left) {
                align-h = right
              } else if (align-h == right) {
                align-h = left
              }
          }
          // Compose page number box
          page-number-box = box(
            width: 1fr,
            height: p-num-height,
            stroke: layout.at("p-num-border"),
            align(align-h + layout.at("p-num-align-vertical"),
                pad(left: layout.at("p-num-pad-left"), text(size: layout.at("p-num-size"),
                numbering(layout.at("p-num-pattern"), p-num-value))))
          )
        }
      }

      // Compose the page based on page number box placement
      if page-number-box == none {
        page = pad(pad-content, value) // Page without any page numbers
      } else if p-num-placement == top {
        page = stack(page-number-box, pad(pad-content, value)) // Placing the page number on top explicit is necessary so that the page content does not overlap the page number box 
      } else {
        page = {
          pad(pad-content, value)
          place(p-num-placement, page-number-box)
        }
      }

      // Wrap the finished page content to the specified page size
      wrapped-cont.push(
        block(
          width: 100%,
          height: 100%,
          spacing: 0em,
          page
        )
      )

      p-num += 1 // Increment page number
    }

    let reordered-pages = () // Prepare to collect reordered pages
    let num-pages = wrapped-cont.len() // Total number of pages
    let half-num = int(num-pages / 2) // Number of pages in each half
  
    // Round half-num up to account for odd page numbers
    if calc.odd(num-pages) {
      half-num += 1
    }

    // We need a multiple of 4 half-pages to prevent the blank pages from being in the middle
    // This is because there are 4 half-pages per sheet.
    if calc.odd(half-num) {
      half-num += 1
    }

  // To reorder the pages we put a front page side by side with a back page.
  // And iterate until we reach the middle of the booklet.
  // We alternate between left an right.
  // The index of front pages will increase, while the index of back pages will decrease.
  // For example, 8 pages will give 2 sheets.
  // Sheet 1:
  // 8 | 1
  // 2 | 7
  // Sheet 2:
  // 6 | 3
  // 4 | 5
  let front-index = 0;
  let back-index = half-num * 2 - 1;

    // Reorder pages into booklet signature
    for num in range(half-num) {
    let front-content = wrapped-cont.at(front-index);
    let back-content = if back-index < num-pages { wrapped-cont.at(back-index) } else { block() };
    // even pages indices => BACK  | FRONT
    //  odd pages indices => FRONT | BACK
    if calc.even(num) {
      (front-content, back-content) = (back-content, front-content)
    }
    reordered-pages.push(front-content)
    reordered-pages.push(back-content)
    front-index += 1
    back-index -= 1
    }

    // Create grid to place booklet pages
    let sig-grid = grid.with(
      columns: (1fr, 1fr),
      column-gutter: page-margin-binding * 2,
    )

    // Draw border if not set to none
    if page-border != none {
      sig-grid = sig-grid.with(
        stroke: page-border
      )
    }

    // Output draft or final layout
    if draft {
      sig-grid(..wrapped-cont)
    } else {
      sig-grid(..reordered-pages)
    }
}

// This function is a placeholder for automatically breaking content into pages
#let booklet() = {
  // TODO: Take in single block of content and calculate how to break it into pages automatically
  // Then feed resulting pages to sig function will offer trade off of convenience for less control
}