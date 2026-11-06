// SPDX-FileCopyrightText: Copyright (C) 2025 Andrew Voynov
//
// SPDX-License-Identifier: AGPL-3.0-only

/// Create a single kanban board item that can be placed in `kanban-column`.
///
/// - hardness-level (any): How hard the task is, its cost (usually a number).
/// - priority-level (any): For example, can be "low", "medium", "high".
/// - inset (relative, dictionary): Inset for: hardness, priority, assignee.
/// - stroke (color, gradient, tiling, length, stroke): Stroke for item box.
/// - fill (none, color, gradient, tiling): Item background fill color.
/// - height (auto, relative): Item height.
/// - args (arguments): 1 positional argument is item name, 2 positional
///    arguments is assignee and item name.
#let kanban-item(
  hardness-level,
  priority-level,
  inset: 0.27em,
  stroke: 0.05em,
  fill: white,
  height: auto,
  ..args,
) = {
  let assignee
  let name
  if args.pos().len() == 1 {
    name = args.pos().first()
  } else {
    (assignee, name) = args.pos()
  }
  let rect(fill: gray.darken(50%), color: white, body) = std.rect(
    fill: fill,
    inset: inset,
    radius: 0.2em,
    text(color, body),
  )
  assignee = if assignee != none { rect.with(assignee) } else { (..a) => none }
  let stroke = if type(stroke) == color { std.stroke(stroke + 0.05em) } else {
    std.stroke(stroke)
  }
  let left-stroke = std.stroke(
    paint: stroke.paint,
    thickness: stroke.thickness + 0.5em,
    cap: stroke.cap,
    join: stroke.join,
    dash: stroke.dash,
    miter-limit: stroke.miter-limit,
  )
  grid.cell(
    box(
      stroke: (left: left-stroke, rest: stroke),
      inset: (left: stroke.thickness / 2),
      fill: stroke.paint,
      radius: 0.3em,
      box(
        width: 100%,
        height: height,
        fill: fill,
        stroke: (rest: stroke),
        inset: 0.5em,
        radius: 0.3em,
        align(
          horizon,
          stack(
            spacing: 0.5em,
            name,
            stack(
              dir: ltr,
              spacing: 0.5em,
              rect(fill: aqua.darken(20%))[#hardness-level],
              rect(fill: green.lighten(10%))[#priority-level],
              assignee(fill: blue),
            ),
          ),
        ),
      ),
    ),
  )
}

/// Create a single kanban board column that can be placed in `kanban`.
///
/// - name (str, content): Column name.
/// - color (color, gradient, tiling): Column color.
/// - items (arguments): Column items created with `kanban-item`.
#let kanban-column(name, color: auto, ..items) = {
  (name: name, color: color, items: items.pos())
}

/// Create a single kanban board item that can be placed in `kanban-column`.
///
/// - width (auto, relative): Kanban board width. Default is `100%`.
/// - item-spacing (relative): Spacing between items in a column.
/// - leading (length): Paragraph leading to use inside the board.
/// - font-size (length): Font size to use inside the board.
/// - font (str, array, dictionary): Font to use inside the board.
/// - args (arguments): Columns created with `kanban-column`.
#let kanban(
  width: 100%,
  item-spacing: 0.5em,
  leading: 0.5em,
  font-size: 1em,
  font: (),
  ..args,
) = {
  let columns = args.pos()
  let column-names = columns
    .enumerate()
    .map(((i, x)) => table.cell(
      stroke: (bottom: stroke(paint: columns.at(i).color, thickness: 1pt)),
      align: left,
      inset: (bottom: 0.5em, rest: 0pt),
      [#x.name (#columns.at(i).items.len())],
    ))
  let column-items = columns.map(x => x.items)
  set text(size: font-size, font: font)
  set par(leading: leading)
  show table: set par(justify: false)
  block(
    width: width,
    table(
      columns: (1fr,) * columns.len(),
      align: left + top,
      stroke: none,
      column-gutter: 1.5em,
      inset: 0pt,
      row-gutter: item-spacing,
      table.header(..column-names),
      ..column-items
        .map(items => grid(row-gutter: item-spacing, ..items))
        .flatten(),
    ),
  )
}
