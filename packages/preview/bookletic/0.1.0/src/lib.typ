// This function creates a signature (booklet) layout
// It takes various parameters to configure the layout
#let sig(
  signature-paper: "us-letter", // Paper size for the booklet
  page-margin-top: 0.25in, // Top margin for each page
  page-margin-bottom: 0.25in, // Bottom margin for each page
  page-margin-binding: 0.25in, // Binding margin for each page
  page-margin-edge: 0.25in, // Edge margin for each page
  page-border: luma(0), // Whether to draw a border around each page
  draft: false, // Whether to output draft or final layout
  p-num-pattern: "1", // Pattern for page numbering
  // TODO: add ability to set a shape behind page number
  // TODO: add ability to set which pages to start and stop page numbering on 
  p-num-placment: top, // Placement of page numbers (top or bottom)
  p-num-align-horizontal: center, // Horizontal alignment of page numbers
  p-num-align-vertical: horizon, // Vertical alignment of page numbers
  p-num-size: 12pt, // Size of page numbers
  p-num-pad-horizontal: 1pt, // Horizontal padding for page numbers
  p-num-border: luma(0), // Border color for page numbers
  pad-content: 5pt, // Padding around page content
  contents: (), // Content to be laid out in the booklet
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
  for value in contents {
    let page
    // Insert page number for each page before we reorder things
    // TODO: Handle starting and stoping page numbering at specific page (to allow no numbers on cover or blank pages)
    // Compose page number box
    let p-num-hight = p-num-size + p-num-pad-horizontal
    let p-num-width = page-width
    let page-number-box = box(
      width: p-num-width,
      height: p-num-hight,
      stroke: p-num-border,
      align(p-num-align-horizontal + p-num-align-vertical, text(size: p-num-size, numbering(p-num-pattern, p-num)))
    )

    // Compose the page based on page number placement
    if p-num-placment == top {
      page = stack(page-number-box, pad(pad-content, value)) // Page number on top
    } else {
      page = pad(pad-content, value) + align(bottom, page-number-box) // Page number at bottom
    }

    // Wrap the page content to the specified page size
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

  // Split pages into front and back halves for reordering
  let front-half = wrapped-cont.slice(0, half-num)
  let back-half = wrapped-cont.slice(half-num).rev()

  // Reorder pages into booklet signature
  for num in range(half-num) {
    // If total number of pages is odd, leave back cover blank
    // else use last even page as back cover
    if calc.odd(num-pages) {
      // TODO: handle odd number of pages
    } else {
      // Alternate page arrangement for booklet signature
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