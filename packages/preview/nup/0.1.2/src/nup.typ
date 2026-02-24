#import "@preview/shadowed:0.2.0": shadowed

/// Transpose a 1D-array as if it was a 2D array. The array is treated as if it
/// was width*height (width is inferred) and ends up as height*width. The array
/// is padded with `none` elements to handle non-"rectangular" arrays.
// https://forum.typst.app/t/how-to-display-content-from-an-array-vertically-in-a-table/453/4
#let transpose(arr, height) = {
  let width = calc.ceil(arr.len() / height)
  let missing = width * height - arr.len()
  // add dummy elements so that the array is "rectangular"
  arr += (none,) * missing
  // transpose the array
  array.zip(..arr.chunks(width)).join()
}

#let include-page(x, shadow: true, shadow-args: (:), rect-args: (:)) = {
  if shadow {
    let default-args = (
      fill: white,
      radius: 0pt,
      inset: 0pt,
      clip: false,
      shadow: 4pt,
      color: luma(50%),
    )

    shadowed(..default-args, ..shadow-args)[#grid.cell(x)]
  } else {
    rect(stroke: none, inset: 0pt, ..rect-args)[#grid.cell(x)]
  }
}

#let nup(
  layout,
  pages,
  gutter: 0.1cm,
  row-first: true,
  shadow: true,
  shadow-args: (:),
  rect-args: (:),
  page-args: (:),
) = {
  let default-page = (
    paper: "a4",
    margin: 1cm,
    flipped: true,
    background: rect(width: 100%, height: 100%, fill: luma(95%)),
  )

  set page(..default-page, ..page-args)

  let (nrow, ncol) = layout.split("x")
  let n = pages.len()
  context {
    align(center + horizon, grid(
      columns: (auto,) * int(ncol),
      rows: (
        (page.width - 2 * page.margin - (int(nrow) - 1) * gutter) / int(nrow),
      )
        * int(nrow),
      gutter: gutter,
      ..if row-first {
        pages.map(include-page.with(
          shadow: shadow,
          shadow-args: shadow-args,
          rect-args: rect-args,
        ))
      } else {
        transpose(pages, int(ncol)).map(include-page.with(
          shadow: shadow,
          shadow-args: shadow-args,
          rect-args: rect-args,
        ))
      }
    ))
  }
}
