/// construct an eight-page zine for the current printer page size
/// 
/// The size of the zine pages are deduced from the current page size.
/// The current page defines the size of the page that the zine would be
/// printed on.
///
/// The zine's pages are provided in the order that they should be read,
/// separated by `pagebreak()`s. They are wrapped and then moved into position
/// so that any zine-page-internal layout is preserved.
///
/// === #text(red.darken(25%), underline[Failure Mode])
/// This function will fail if there are not exactly seven `pagebreak()` calls
/// within the document (implying eight pages are defined).
///
/// Unfortunately, we cannot render an example since zen-zine requires
/// access to the page information to be able to deduce the size of the zine
/// pages.
///
/// -> content
#let zine(
  /// size of margin around each zine page
  ///
  /// The default value of 0.25in is chosen because that is a pretty
  /// common minimum margin for printers. You could freely shrink this
  /// margin however the printer may clip the outer edges of the zine
  /// pages.
  ///
  /// The inner margins are _shared_ between pages so this is also
  /// the inner distance between any two zine pages.
  /// -> length
  zine-page-margin: 0.25in,
  /// whether to draw the border of the zine pages in printer mode
  /// 
  /// This border is sometimes helpful for seeing the placement of
  /// content on the final printer-ready page.
  /// -> boolean
  draw-border: true,
  /// whether to be in printer mode (false) or digital (true)
  ///
  /// When creating a digital zine, the margin specified with `zine-page-margin`
  /// is divided by two so that the digital visually looks like the printed
  /// zine with the pages cut out.
  /// -> boolean
  digital: false,
  /// input content of zine
  /// -> content
  content
) = context {
  // we need to be in context so we can get the full page's height and width
  // in order to deduce the zine page height and width
  // each of the zine pages share the margin with their neighbors
  // this height/width is without margins
  let zine-page-height = (page.width - 3*zine-page-margin)/2;
  let zine-page-width = (page.height - 5*zine-page-margin)/4;
  if digital {
    // assign half the zine margin to each digital page
    // resize pages and then provide content since it has pagebreaks already
    set page(
      height: zine-page-height+zine-page-margin/2,
      width: zine-page-width+zine-page-margin/2,
      margin: zine-page-margin/2
    )
    content
  } else {
    // make sure page has the correct margin and it is flipped
    set page(margin: zine-page-margin, flipped: true)
    // break content into the array of pages using the pagebreak
    // function and then place those pages into the grid
    let contents = ()
    let current-content = []
    for child in content.at("children") {
      if child.func() == pagebreak {
        contents.push(current-content)
        current-content = []
      } else {
        current-content = current-content + child
      }
    }

    if current-content != [] {
      contents.push(current-content)
    }

    assert.eq(
      contents.len(), 8,
      message: "Document content does not have exactly 8 pages (7 pagebreaks)."
    )
    
    let contents = (
      // reorder the pages so the order in the grid aligns with a zine template
      contents.slice(1,5).rev()+contents.slice(5,8)+contents.slice(0,1)
    ).map(
      // wrap the contents in blocks the size of the zine pages so that we can
      // maneuver them at will
      elem => block(
        width: zine-page-width,
        height: zine-page-height,
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
  
    let zine-grid = grid.with(
      columns: 4 * (zine-page-width, ),
      rows: zine-page-height,
      gutter: zine-page-margin,
    )
    if draw-border {
      zine-grid = zine-grid.with(
        stroke: luma(0)
      )
    }
    zine-grid(..contents)
  }
}
