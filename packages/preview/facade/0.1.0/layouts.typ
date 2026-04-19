// layouts.typ — Flex-like layouts using native Typst grid
// Provides dg-flex, dg-layers, dg-group

#import "shapes.typ": dg-rect

/// Main flex container — CSS flexbox semantics mapped to Typst grid.
///
/// - direction: "row" (horizontal) or "column" (vertical)
/// - justify: main-axis alignment ("start", "center", "end", "space-between", "space-around")
/// - align-items: cross-axis alignment ("stretch", "start", "center", "end")
/// - gap: spacing between items
/// - children: variadic content items
#let dg-flex(
  direction: "row",
  justify: "start",
  align-items: "stretch",
  gap: 0.8em,
  ..args,
) = {
  // Validate arguments
  assert(
    direction in ("row", "column"),
    message: "dg-flex: direction must be 'row' or 'column', got '" + str(direction) + "'",
  )
  assert(
    justify in ("start", "center", "end", "space-between", "space-around"),
    message: "dg-flex: justify must be 'start', 'center', 'end', 'space-between', or 'space-around'",
  )
  assert(
    align-items in ("stretch", "start", "center", "end"),
    message: "dg-flex: align-items must be 'stretch', 'start', 'center', or 'end'",
  )

  let children = args.pos()
  let named = args.named()
  let n = children.len()

  if n == 0 {
    return []
  }

  // === Compute cross-axis alignment ===
  // For row: cross-axis is vertical (top/horizon/bottom)
  // For column: cross-axis is horizontal (left/center/right)
  let cross-align = if align-items == "start" {
    if direction == "row" { top } else { left }
  } else if align-items == "center" {
    if direction == "row" { horizon } else { center }
  } else if align-items == "end" {
    if direction == "row" { bottom } else { right }
  } else {
    // "stretch" — items fill the cross axis; use horizon/center as default alignment
    if direction == "row" { horizon } else { center }
  }

  // === Compute main-axis alignment ===
  // For row: main-axis is horizontal (left/center/right)
  // For column: main-axis is vertical (top/horizon/bottom)
  let main-align = if justify == "start" {
    if direction == "row" { left } else { top }
  } else if justify == "center" {
    if direction == "row" { center } else { horizon }
  } else if justify == "end" {
    if direction == "row" { right } else { bottom }
  } else {
    // space-between / space-around handled via spacers
    if direction == "row" { center } else { horizon }
  }

  // Combined alignment for grid cells
  let cell-align = main-align + cross-align

  // === Build grid based on justify mode ===
  if justify in ("start", "center", "end") {
    // Simple case: just place children with gap
    if direction == "row" {
      // Columns: auto for each child
      // Row: auto (1fr would expand to fill container height)
      let cols = (auto,) * n
      let rows = (auto,)

      grid(
        columns: cols,
        rows: rows,
        column-gutter: gap,
        align: cell-align,
        ..named,
        ..children,
      )
    } else {
      // direction == "column"
      let rows = (auto,) * n
      let cols = (auto,)

      grid(
        columns: cols,
        rows: rows,
        row-gutter: gap,
        align: cell-align,
        ..named,
        ..children,
      )
    }
  } else if justify == "space-between" {
    // Insert 1fr spacers between children
    // Pattern: [child, 1fr, child, 1fr, ..., child]
    if n == 1 {
      // Single child: just center it
      if direction == "row" {
        grid(columns: (1fr,), align: cell-align, ..named, ..children)
      } else {
        grid(rows: (1fr,), align: cell-align, ..named, ..children)
      }
    } else {
      // Multiple children: interleave with 1fr spacers
      let spec = ()
      let items = ()
      for (i, child) in children.enumerate() {
        spec.push(auto)
        items.push(child)
        if i < n - 1 {
          spec.push(1fr)
          items.push([])  // Empty spacer cell
        }
      }

      if direction == "row" {
        grid(
          columns: spec,
          rows: (auto,),
          align: cell-align,
          ..named,
          ..items,
        )
      } else {
        grid(
          columns: (auto,),
          rows: spec,
          align: cell-align,
          ..named,
          ..items,
        )
      }
    }
  } else {
    // justify == "space-around"
    // Pattern: [0.5fr, child, 1fr, child, 1fr, ..., child, 0.5fr]
    let spec = (1fr,)
    let items = ([], )  // Leading spacer

    for (i, child) in children.enumerate() {
      spec.push(auto)
      items.push(child)
      spec.push(1fr)
      items.push([])  // Trailing spacer (or inter-child spacer)
    }

    if direction == "row" {
      grid(
        columns: spec,
        rows: (auto,),
        align: cell-align,
        ..named,
        ..items,
      )
    } else {
      grid(
        columns: (auto,),
        rows: spec,
        align: cell-align,
        ..named,
        ..items,
      )
    }
  }
}

/// Vertical layers preset — perfect for architecture stacks.
/// Automatically wraps each child in a styled rect for consistent layered look.
///
/// - gap: vertical spacing between layers
/// - inset: padding inside each layer rect
/// - radius: corner radius for layer rects
/// - fill: background color (auto = light gray)
/// - stroke: border stroke
/// - align: content alignment within layers
/// - wrap-children: if true, wrap each child in dg-rect; if false, pass through raw
/// Vertical layers preset — perfect for architecture stacks.
/// Simply stacks children vertically with consistent gap.
/// Use dg-rect explicitly around items that need boxes.
///
/// - gap: vertical spacing between layers
/// - align-items: cross-axis alignment ("stretch", "start", "center", "end")
#let dg-layers(
  gap: 0.5em,
  align-items: "center",
  ..args,
) = {
  let children = args.pos()
  let named = args.named()

  // Use dg-flex in column mode
  dg-flex(
    direction: "column",
    justify: "start",
    align-items: align-items,
    gap: gap,
    ..named,
    ..children,
  )
}

/// Simple group wrapper — like a <div> for grouping and adding padding/margins.
/// Useful for nesting and spacing control.
#let dg-group(
  width: auto,
  height: auto,
  padding: 0pt,
  fill: none,
  stroke: none,
  radius: 0pt,
  ..args,
) = {
  let children = args.pos()

  block(
    width: width,
    height: height,
    inset: padding,
    fill: fill,
    stroke: stroke,
    radius: radius,
    children.join(),
  )
}

/// Row shorthand — dg-flex with direction: "row"
#let dg-row(..args) = dg-flex(direction: "row", ..args)

/// Column shorthand — dg-flex with direction: "column"
#let dg-col(..args) = dg-flex(direction: "column", ..args)
