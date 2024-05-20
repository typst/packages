#let zine(
  zine_page_margin: 5pt,
  draw_border: true,
  contents: ()
) = {
  // set printer page size (typst's page) and a zine page size (pages in the zine)
  set page("us-letter", margin: zine_page_margin, flipped: true)
  let zine_page_height = (8.5in-zine_page_margin)/2 - zine_page_margin;
  let zine_page_width = (11in-zine_page_margin)/4 - zine_page_margin;
  
  let contents = (
    // reorder the pages so the order in the grid aligns with a zine template
    contents.slice(1,5).rev()+contents.slice(5,8)+contents.slice(0,1)
  ).map(
    // wrap the contents in blocks the size of the zine pages so that we can
    // maneuver them at will
    elem => block(
      width: zine_page_width,
      height: zine_page_height,
      spacing: 0em,
      elem
    )
  ).enumerate().map(
    // flip if on top row
    elem => {
      if elem.at(0) < 4 {
        rotate(
          180deg,
          origin: center,
          elem.at(1)
        )
      } else {
        elem.at(1)
      }
    }
  )

  let zine_grid = grid.with(
    columns: 4 * (zine_page_width, ),
    rows: zine_page_height,
    gutter: zine_page_margin,
  )
  if draw_border {
    zine_grid = zine_grid.with(
      stroke: luma(0)
    )
  }
  zine_grid(..contents)
}
