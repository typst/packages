#import "constants.typ": _paper-sizes
#import "validate.typ": *

#let _grid-count(value, name) = {
  if value == auto {
    auto
  } else {
    _positive-int(value, name)
  }
}

#let _orient-item(item, item-orientation) = {
  let item-orientation = _one-of(
    item-orientation,
    ("auto", "original", "portrait", "landscape"),
    "sheetwise: `item-orientation` must be `auto`, `original`, `portrait`, or `landscape`.",
  )

  if item-orientation == "original" {
    item
  } else if item-orientation == "portrait" {
    if item.width <= item.height { item } else { (width: item.height, height: item.width) }
  } else if item-orientation == "landscape" {
    if item.width >= item.height { item } else { (width: item.height, height: item.width) }
  } else if item-orientation == "auto" {
    item
  }
}

#let paper-size(paper, orientation: "portrait") = {
  let size = if type(paper) == str {
    if not _paper-sizes.keys().contains(paper) {
      panic("sheetwise: unknown paper size `" + paper + "`.")
    }
    _paper-sizes.at(paper)
  } else {
    _size(paper, "paper")
  }

  let orientation = _one-of(orientation, ("portrait", "landscape"), "sheetwise: `orientation` must be `portrait` or `landscape`.")
  if orientation == "portrait" { size } else { (width: size.height, height: size.width) }
}

#let _grid-plan(
  sheet,
  trim-size,
  margin,
  gap,
  rows,
  columns,
  item-orientation: "original",
) = {
  let base-item = _size(trim-size, "trim-size")
  let margin = _margin(margin)
  let gap = _pair(gap, "gap")
  let rows = _grid-count(rows, "rows")
  let columns = _grid-count(columns, "columns")
  let usable-width = sheet.width - margin.left - margin.right
  let usable-height = sheet.height - margin.top - margin.bottom

  let candidate-items = if item-orientation == "auto" and base-item.width != base-item.height {
    (
      base-item,
      (width: base-item.height, height: base-item.width),
    )
  } else {
    (_orient-item(base-item, item-orientation),)
  }

  let best = none
  for item in candidate-items {
    if usable-width >= item.width and usable-height >= item.height {
      let auto-columns = calc.floor((usable-width + gap.width) / (item.width + gap.width))
      let auto-rows = calc.floor((usable-height + gap.height) / (item.height + gap.height))
      let candidate-columns = if columns == auto { auto-columns } else { columns }
      let candidate-rows = if rows == auto { auto-rows } else { rows }

      if candidate-columns >= 1 and candidate-rows >= 1 {
        let grid-width = candidate-columns * item.width + (candidate-columns - 1) * gap.width
        let grid-height = candidate-rows * item.height + (candidate-rows - 1) * gap.height

        if grid-width <= usable-width and grid-height <= usable-height {
          let plan = (
            item: item,
            trim-size: item,
            margin: margin,
            gap: gap,
            rows: candidate-rows,
            columns: candidate-columns,
            slots: candidate-rows * candidate-columns,
            grid-width: grid-width,
            grid-height: grid-height,
            origin-x: margin.left + (usable-width - grid-width) / 2,
            origin-y: margin.top + (usable-height - grid-height) / 2,
            item-rotated: item.width != base-item.width or item.height != base-item.height,
          )

          if best == none or plan.slots > best.slots {
            best = plan
          }
        }
      }
    }
  }

  if best == none {
    panic("sheetwise: item/grid does not fit into the sheet after margins.")
  }

  best
}

#let grid-plan(
  paper: "a4",
  orientation: "portrait",
  trim-size: auto,
  item-size: auto,
  item-orientation: "original",
  margin: 10mm,
  gap: 3mm,
  rows: auto,
  columns: auto,
) = {
  let sheet = paper-size(paper, orientation: orientation)
  let trim = _resolve-trim-size(trim-size, item-size: item-size)
  _grid-plan(sheet, trim, margin, gap, rows, columns, item-orientation: item-orientation)
}

#let _slot-position(plan, slot) = {
  let col = calc.rem(slot, plan.columns)
  let row = calc.floor(slot / plan.columns)

  (
    row: row,
    column: col,
    x: plan.origin-x + col * (plan.item.width + plan.gap.width),
    y: plan.origin-y + row * (plan.item.height + plan.gap.height),
    width: plan.item.width,
    height: plan.item.height,
  )
}

#let _slot-region(plan, slot, label: none) = {
  let pos = _slot-position(plan, slot)
  (x: pos.x, y: pos.y, width: pos.width, height: pos.height, label: label)
}

#let _slot-from-row-column(plan, row, col) = row * plan.columns + col

#let _duplex-slot(plan, slot, flip) = {
  let col = calc.rem(slot, plan.columns)
  let row = calc.floor(slot / plan.columns)

  if flip == "long-edge" {
    _slot-from-row-column(plan, row, plan.columns - 1 - col)
  } else if flip == "short-edge" {
    _slot-from-row-column(plan, plan.rows - 1 - row, col)
  } else if flip == "none" {
    slot
  }
}
