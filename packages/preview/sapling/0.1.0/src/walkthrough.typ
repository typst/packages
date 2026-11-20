// Walkthroughs: several pictures next to each other to show how a tree evolves.

#import "draw.typ": font-size

// A picture with a title above it. `none` as title draws just the content.
#let step(title, content) = {
  assert(
    title == none or type(title) in (str, content),
    message: "sapling: title must be a string, content or none, got " + repr(title),
  )
  if title == none { return content }
  block(breakable: false, grid(
    align: center,
    row-gutter: 0.6em,
    text(size: font-size, title),
    content,
  ))
}

// Arranges the items in a grid: `columns` items per row (`auto` = one row),
// with an arrow between consecutive items of a row if `arrows` is not `false`.
#let walkthrough(..items, columns: auto, arrows: false, gutter: 12pt) = {
  assert(
    columns == auto or (type(columns) == int and columns >= 1),
    message: "sapling: columns must be auto or an int of at least 1, got " + repr(columns),
  )
  assert(
    type(arrows) in (bool, str, content),
    message: "sapling: arrows must be true, false or content, got " + repr(arrows),
  )
  assert(
    type(gutter) == length,
    message: "sapling: gutter must be a length, got " + repr(gutter),
  )
  let items = items.pos()
  let n = items.len()
  if n == 0 { return }
  let per-row = if columns == auto { n } else { calc.min(columns, n) }
  let arrow = if arrows == true { sym.arrow.r } else { arrows }
  let cells = ()
  for (i, item) in items.enumerate() {
    cells.push(item)
    // no arrow after the last item or at the end of a row
    if arrows != false and i + 1 < n and calc.rem(i + 1, per-row) != 0 { cells.push(arrow) }
  }
  align(center, grid(
    columns: (auto,) * if arrows == false { per-row } else { 2 * per-row - 1 },
    align: center + horizon,
    gutter: gutter,
    ..cells,
  ))
}
