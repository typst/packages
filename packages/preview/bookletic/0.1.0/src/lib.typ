// This function creates a signature (booklet) layout
// It takes various parameters to configure the layout
#let sig(
  signature_paper: "us-letter", // Paper size for the booklet
  page_margin_top: 0.25in, // Top margin for each page
  page_margin_bottom: 0.25in, // Bottom margin for each page
  page_margin_binding: 0.25in, // Binding margin for each page
  page_margin_edge: 0.25in, // Edge margin for each page
  page_border: luma(0), // Whether to draw a border around each page
  draft: false, // Whether to output draft or final layout
  pNum_pattern: "1", // Pattern for page numbering
  // TODO: add ability to set a shape behind page number
  pNum_placment: top, // Placement of page numbers (top or bottom)
  pNum_align_horizontal: center, // Horizontal alignment of page numbers
  pNum_align_vertical: horizon, // Vertical alignment of page numbers
  pNum_size: 12pt, // Size of page numbers
  pNum_pad_horizontal: 1pt, // Horizontal padding for page numbers
  pNum_border: luma(0), // Border color for page numbers
  pad_content: 5pt, // Padding around page content
  contents: (), // Content to be laid out in the booklet
) = {
  // set printer page size (typst's page) and a booklet page size (pages in the booklet)
  set page(signature_paper, margin: (
    top: page_margin_top,
    bottom: page_margin_bottom,
    left: page_margin_edge,
    right: 6in
  ), flipped: true)

  // Note: This is hardcoded to two page single fold signatures.
  // Current handled pages sizes are Us-Letter and Us-Legal.
  let page_height = (8.5in - page_margin_top) - page_margin_bottom;
  let page_width
  if signature_paper == "us-legal" {
    // Calculate page width for US Legal paper size
    page_width = ((14in - (page_margin_edge * 2)) - page_margin_binding) / 2;
  } else {
    // Calculate page width for US Letter paper size
    page_width = ((11in - (page_margin_edge * 2)) - page_margin_binding) / 2;
  }

  let wrappedCont = ()  // Array to hold wrapped content
  let pNum = 1 // Initialize page number

  // Loop through the provided content and package for placement in the booklet
  for value in contents {
    let page
    // Insert page number for each page before we reorder things
    // TODO: Handle starting and stoping page numbering at specific page (to allow no numbers on cover or blank pages)
    // Compose page number box
    let pNum_hight = pNum_size + pNum_pad_horizontal
    let pNum_width = page_width
    let pageNumber = box(
      width: pNum_width,
      height: pNum_hight,
      stroke: pNum_border,
      align(pNum_align_horizontal + pNum_align_vertical, text(size: pNum_size, numbering(pNum_pattern, pNum)))
    )

    // Compose the page based on page number placement
    if pNum_placment == top {
      page = stack(pageNumber, pad(pad_content, value)) // Page number on top
    } else {
      page = pad(pad_content, value) + align(bottom, pageNumber) // Page number at bottom
    }

    // Wrap the page content to the specified page size
    wrappedCont.push(
      block(
        width: page_width,
        height: page_height,
        spacing: 0em,
        page
      )
    )

    pNum += 1 // Increment page number
  }

  let reorderedPages = () // Prepare to collect reordered pages
  let numPages = wrappedCont.len() // Total number of pages
  let halfNum = int(numPages / 2) // Number of pages in each half

  // Split pages into front and back halves for reordering
  let frontHalf = wrappedCont.slice(0, halfNum)
  let backHalf = wrappedCont.slice(halfNum).rev()

  // Reorder pages into booklet signature
  for num in range(halfNum) {
    // If total number of pages is odd, leave back cover blank
    // else use last even page as back cover
    if calc.odd(numPages) {
      // TODO: handle odd number of pages
    } else {
      // Alternate page arrangement for booklet signature
      if calc.even(num) {
        reorderedPages.push(backHalf.at(num))
        reorderedPages.push(frontHalf.at(num))
      } else {
        reorderedPages.push(frontHalf.at(num))
        reorderedPages.push(backHalf.at(num))
      }
    }
  }

  // Create grid to place booklet pages
  let sig_grid = grid.with(
    columns: 2 * (page_width,),
    rows: page_height,
    gutter: page_margin_binding,
  )

  // Draw border if not set to none
  if page_border != none {
    sig_grid = sig_grid.with(
      stroke: page_border
    )
  }

  // Output draft or final layout
  if draft {
    sig_grid(..wrappedCont)
  } else {
    sig_grid(..reorderedPages)
  }
}

// This function is a placeholder for automatically breaking content into pages
#let booklet() = {
  // TODO: Take in single block of content and calculate how to break it into pages automatically
  // Then feed resulting pages to sig function will offer trade off of convenience for less control
}