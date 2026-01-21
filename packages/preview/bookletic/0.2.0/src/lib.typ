// This function creates a signature (booklet) layout for printing.
// It takes various parameters to configure the layout, such as paper size,
// margins, page numbering styles, content padding, and the content to be laid out.
#let sig(
  signature-paper: "us-letter", // Paper size for the booklet (e.g., "us-letter", "us-legal")
  page-margin-top: 0.25in, // Top margin for each page
  page-margin-bottom: 0.25in, // Bottom margin for each page
  page-margin-binding: 0.25in, // Binding margin for each page (space between pages)
  page-margin-edge: 0.25in, // Edge margin for each page
  page-border: luma(0), // Color for the border around each page (set to none for no border)
  draft: false, // Whether to output draft or final layout
  p-num-layout: (
      // TODO: add ability to set a shape behind page number
      // TODO: add ability to easily pad page number left or right
    (
      p-num-start: 1, // Starting page number
      p-num-alt-start: none, // Alternative starting page number (e.g., for chapters)
      p-num-pattern: "1", // Pattern for page numbering (e.g., "1", "i", "a", "A")
      p-num-placment: top, // Placement of page numbers (top or bottom)
      p-num-align-horizontal: center, // Horizontal alignment of page numbers
      p-num-align-vertical: horizon, // Vertical alignment of page numbers
      p-num-pad-left: 0pt, // Extra padding added to the left of the page number
      p-num-pad-horizontal: 1pt, // Horizontal padding for page numbers
      p-num-size: 12pt, // Size of page numbers
      p-num-border: luma(0), // Border color for page numbers
    ),
  ),
  pad-content: 5pt, // Padding around page content
  contents: (), // Content to be laid out in the booklet (an array of content blocks)
) = {
  // set printer page size (typst's page) and a booklet page size (pages in the booklet)
  set page(signature-paper, margin: (
    top: page-margin-top,
    bottom: page-margin-bottom,
    left: page-margin-edge,
    right: 6in
  ), flipped: true)

  // Note: This is hardcoded to two page single fold signatures.
  // Current handled pages sizes are Us-Letter and Us-Legal.
  let page-height = (8.5in - page-margin-top) - page-margin-bottom;
  let page-width
  if signature-paper == "us-legal" {
    // Calculate page width for US Legal paper size
    page-width = ((14in - (page-margin-edge * 2)) - page-margin-binding) / 2;
  } else {
    // Calculate page width for US Letter paper size
    page-width = ((11in - (page-margin-edge * 2)) - page-margin-binding) / 2;
  }

  let wrapped-cont = ()  // Array to hold wrapped content
  let p-num = 1 // Initialize page number
  // Loop through the provided content and package for placement in the booklet
  // We will nsert page number for each page before we reorder things
  for value in contents {
    let page
    let p-num-placment
    let p-num-width
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
        p-num-width = page-width
        // Hold on to placment for use when building pages
        p-num-placment = layout.at("p-num-placment")
        // Compose page number box
        page-number-box = box(
          width: p-num-width,
          height: p-num-height,
          stroke: layout.at("p-num-border"),
          align(layout.at("p-num-align-horizontal") + layout.at("p-num-align-vertical"), pad(left: layout.at("p-num-pad-left"), text(size: layout.at("p-num-size"), numbering(layout.at("p-num-pattern"), p-num-value))))
        )
      }
    }

    // Compose the page based on page number box placement
    if page-number-box == none {
      page = pad(pad-content, value) // Page without any page numbers
    } else if p-num-placment == top {
      page = stack(page-number-box, pad(pad-content, value)) // Page number on top
    } else {
      page = pad(pad-content, value) + align(bottom, page-number-box) // Page number at bottom
    }

    // Wrap the finished page content to the specified page size
    wrapped-cont.push(
      block(
        width: page-width,
        height: page-height,
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

  // Split pages into front and back halves for reordering
  let front-half = wrapped-cont.slice(0, half-num)
  let back-half = wrapped-cont.slice(half-num).rev()

  // Reorder pages into booklet signature
  for num in range(half-num) {
    // If total number of pages is odd, leave back cover blank
    // otherwise proceed with reordering pages normally
    if  calc.odd(num-pages) {
      if num == 0 {
        reordered-pages.push([])
        reordered-pages.push(front-half.at(num))
      } else if calc.even(num) {
        reordered-pages.push(back-half.at(num - 1))
        reordered-pages.push(front-half.at(num))
      } else {
        reordered-pages.push(front-half.at(num))
        reordered-pages.push(back-half.at(num - 1))
      }
    } else {
      // Alternate page arrangement for even paged booklet signature
      if calc.even(num) {
        reordered-pages.push(back-half.at(num))
        reordered-pages.push(front-half.at(num))
      } else {
        reordered-pages.push(front-half.at(num))
        reordered-pages.push(back-half.at(num))
      }
    }
  }

  // Create grid to place booklet pages
  let sig-grid = grid.with(
    columns: 2 * (page-width,),
    rows: page-height,
    gutter: page-margin-binding,
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