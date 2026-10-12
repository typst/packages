#import "internal.typ": *

#let recipe(columns: none, ..args) = {
  // assert(args.named().len() == 0, message: "recipe cannot contain named args")

  for obj in args.pos() {
    assert(
      type(obj) == dictionary and ("ingredient", "step").contains(obj.type),
      message: "Unknown object passed into recipe: "
        + repr(obj)
        + ", \nOnly the provided `ingredient` and `step` types are allowed.",
    )
  }

  let cells = ()
  let stack = ()

  let step-count = 0

  let depths = (0,)
  let full-rows = ()

  for item in args.pos() {
    if item.type == "ingredient" {
      cells.push(
        table.cell(
          x: 0,
          y: depths.at(0),
          colspan: 1,
          rowspan: item.rowspan,
          align(horizon + left)[#item.value],
        ),
      )
      depths.at(0) += item.rowspan
      stack.push(item)
    } else if item.type == "step" {
      // for debug purposes:
      step-count += 1
      assert(
        item.combine <= stack.len(),
        message: "Step "
          + str(step-count)
          + ": Attempted to combine more ingredients ("
          + str(item.combine)
          + ") than the current count of uncombined products ("
          + str(stack.len())
          + ").",
      )

      if (item.combine == 0) {
        // bad workaround for cells with max colspan as colspan is unknown at runtime so we have to defer creating the cell for now
        assert(
          stack.len() == 0,
          message: "Full colspan steps are allowed only at the start of recipe, consider opening an issue with an example recipe if you need this to work in other places!",
        )
        full-rows.push(
          (y: depths.at(0), value: item.value),
        )
        for idx in range(depths.len()) { depths.at(idx) += 1 }
      } else {
        // calc size of new cell
        let ns = 0
        let nx = 0

        for idx in range(item.combine) {
          let ing = stack.pop()

          if ing.depth > nx { nx = ing.depth }
          ns += ing.rowspan
        }
        nx += 1
        if depths.at(nx, default: none) == none {
          depths.push(
            if full-rows.len() != 0 {
              full-rows.last().y + 1
            } else {
              0
            },
          )
        }

        // pad space before with blank cells if needed
        let max-h = depths.at(0)
        for idx in range(1, nx, inclusive: true) {
          let bs = if idx == nx { ns } else { 0 }
          let rowspan = max-h - depths.at(idx) - bs

          if (
            rowspan > 0
          ) {
            let rowspan = max-h - depths.at(idx) - bs

            cells.push(
              table.cell(
                stroke: (right: 0pt),
                x: idx,
                y: depths.at(idx),
                rowspan: rowspan,
                [],
              ),
            )

            depths.at(idx) += rowspan
          }
        }

        // add new cell
        cells.push(
          table.cell(
            x: nx,
            y: depths.at(nx - 1) - ns,
            rowspan: ns,
            colspan: 1,
            if (not item.vertical) {
              item.value
            } else {
              box(
                rotate(90deg, reflow: true, item.value),
              )
            },
          ),
        )
        depths.at(nx) += ns
        stack.push(
          ingredient(item.value, rowspan: ns, depth: nx),
        )
      }
    }
  }

  // deferred add of the max-colspan cells
  for (y, value) in full-rows {
    cells.push(
      table.cell(
        x: 0,
        y: y,
        colspan: depths.len(),
        value,
      ),
    )
  }

  table(
    stroke: frame(
      1.5pt + rgb("40A040"),
      0.75pt + rgb("40A040"),
    ),
    align: horizon + center,
    inset: (x: 0.30em, y: 0.30em),
    columns: if (columns != none) {
      assert(
        columns.len() == depths.len(),
        message: "Length of the columns argument does not match the actual amount of columns found in table. (Expected: "
          + str(depths.len())
          + ", Received: "
          + str(columns.len())
          + ").",
      )
      columns
    } else {
      (auto,) + (1fr,) * (depths.len() - 1)
    },
    rows: auto,
    ..cells,
  )
}

#let ingredient(value, rowspan: 1) = (
  type: "ingredient",
  rowspan: rowspan,
  depth: 0,
  value: box(
    inset: (y: 0.15em),
    value,
  ),
)

#let step(value, combine: 1, vertical: false) = (
  type: "step",
  combine: combine,
  vertical: vertical,
  value: box(
    inset: (y: 0.15em),
    value,
  ),
)



