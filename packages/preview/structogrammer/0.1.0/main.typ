#let structogram =  {

let stroke- = stroke;

let localisation = (
  "de": (
    While: (condition) => [solange #condition],
    For: (body) => [für #body],
    ForIn: (element, container) => [für jedes #element aus #container],
    ForTo: (start-declaration, end) => [von #start-declaration bis #end],
    If: (condition) => [#condition?],
    Break: (value) => [#value],
  ),
  "en": (
    While: (condition) => [while #condition],
    For: (body) => [for #body],
    ForIn: (element, container) => [for each #element in #container],
    ForTo: (start-declaration, end) => [from #start-declaration until #end],
    If: (condition) => [#condition?],
    Break: (value) => [#value],
  ),
)

// Returns an array of needed columns for a diagram specification
// The returned array contains booleans for each column from left to right,
// with wide columns as `true` and narrow columns as `false`.
//
// Narrow columns can be of a fixed size while remaining space can be
// distributed among wide columns.
//
// See to-elements for an explanation of a diagram spec.
let allocate-columns(spec) = {
  if spec == none or spec == () { return (false,) }
  
  if type(spec) == content or type(spec) == str { return (true,) }

  if type(spec) == array {
    let allocated-columnss = spec.map(allocate-columns)

    let wide-needed = 0
    for allocated-columns in allocated-columnss {
      wide-needed = calc.max(
        allocated-columns.fold(
          0, (cnt, el) => if (el) {cnt + 1} else {cnt}  // count instances of `true`
        ),
        wide-needed,
      )
    }

    let narrows = (wide-needed + 1) * (0,)
    
    for allocated-columns in allocated-columnss {
      let far-left-narrows = 0
      for column in allocated-columns {
        if column { break }

        far-left-narrows += 1
      }
      
      narrows.first() = calc.max(narrows.first(), far-left-narrows)
    }
    
    for allocated-columns in allocated-columnss {
      let far-right-narrows = 0
      for column in allocated-columns.rev() {
        if column { break }

        far-right-narrows += 1
      }
      
      narrows.last() = calc.max(narrows.last(), far-right-narrows)
    }

    for allocated-columns in allocated-columnss {
      let wide-index = 0
      let needed-before = 0
      
      for column in allocated-columns {
        if column {
          narrows.at(wide-index) = calc.max(narrows.at(wide-index), needed-before)
          wide-index += 1
          needed-before = 0
          continue
        }

        needed-before += 1
      }
    }

    return narrows.map((count) => count * (false,)).intersperse(true).flatten()
  }

  assert(type(spec) == dictionary, message: "spec must be one of: none, str, content, array of specs, dictionary, got: " + str(type(spec)))

  if (spec.keys() in (("Break",), ("Call",))) {
    return (true,)
  }
  
  if (("While" in spec or ("For" in spec)) and "Do" in spec) {
    assert(
      spec.keys() in (
        ("While", "Do"), ("Do", "While"), ("For", "Do"), ("For", "To", "Do"), ("For", "In", "Do")
      ),
      message: (
        "Must loop with either While-Do, Do-While, For-Do or For-In-Do, found: "
        + spec.keys().join("-")
      ),
    )

    let allocated = allocate-columns(spec.Do)
    
    return (false, ..allocated)
  }
  
  if (
    "If" in spec
  ) {
    assert(
      spec.keys() in (
        ("If", "Then"), ("If", "Then", "Else"), ("If", "Else"),
      ),
      message: (
        "Conditional must be either If-Then(-Else), If-Else, found: "
        + spec.keys().join("-")
      ),
    )

    let then-allocated = allocate-columns(spec.at("Then", default: none))
    let else-allocated = allocate-columns(spec.at("Else", default: none))
    
    return (
      ..then-allocated,
      ..else-allocated,
    )
  }
  
  assert(false, message: "Not a valid spec dictionary: " + repr(spec) + ", keys: " + repr(spec.keys()))
}

// Given any amount of grid.cell elements, return copies with x and y positions
// shifted by the passed dx and dy values.
//
// Cells without an x attribute will raise an error if dx isn't 0, y likewise.
let shift-cells(dx: 0, dy: 0, ..cells) = {
  assert(
    cells.named().len() == 0,
    message: "shift-cells doesn't take any named arguments except dx and dy"
  )
  
  let shifted = ()
  
  for cell in cells.pos() {
    let args = (:)
    
    if dx != 0 {
      assert(
        cell.has("x"),
        message: "A cell must have an x attribute to be shifted horizontally",
      )

      args.x = cell.x + dx
    } else {
      if cell.has("x") { args.x = cell.x }
    }
    
    if dy != 0 {
      assert(
        cell.has("y"),
        message: "A cell must have a y attribute to be shifted vertically",
      )

      args.y = cell.y + dy
    } else {
      if cell.has("y") { args.y = cell.y }
    }
    
    if cell.has("colspan") { args.colspan = cell.colspan }
    if cell.has("rowspan") { args.rowspan = cell.rowspan }
    if cell.has("align") { args.align = cell.align }
    if cell.has("inset") { args.inset = cell.inset }
    if cell.has("stroke") { args.stroke = cell.stroke }
    if cell.has("fill") { args.fill = cell.fill }
    if cell.has("breakable") { args.breakable = cell.breakable }
    
    shifted.push(
      grid.cell(
        cell.body,
        ..args,
      )
    )
  }

  return shifted
}

// Given a grid.cell, return a copy with an added stroke in the specified direction.
let add-stroke(cell, dir: "bottom", stroke: black + 0.5pt) = {  
    let args = (:)

    if "stroke" not in args { args.insert("stroke", (:)) }
    
    if cell.has("x") { args.x = cell.x }
    if cell.has("y") { args.y = cell.y }
    if cell.has("colspan") { args.colspan = cell.colspan }
    if cell.has("rowspan") { args.rowspan = cell.rowspan }
    if cell.has("align") { args.align = cell.align }
    if cell.has("inset") { args.inset = cell.inset }
    if cell.has("stroke") { args.stroke = cell.stroke }
    if cell.has("fill") { args.fill = cell.fill }
    if cell.has("breakable") { args.breakable = cell.breakable }

    args.stroke.insert(dir, stroke)
    
    return grid.cell(
      cell.body,
      ..args,
    )
}

// Measure how many columns and rows a set of passed grid.cells would take up.
// The returned dictionary contains the following keys:
// - left, x:  The x-coordinate of the first used column
// - top,  y:  The y-coordinate of the first used row
// - right:    The x-coordinate of the last used column
// - bottom:   The y-coordinate of the last used row
// - width:    How many columns are occupied (i.e. from leftmost to rightmost column)
// - height:   How many rows are occupied (i.e. from highest to lowest row)
//
// Cells have to have at least x and y attributes to be measured here.
let measure-cells(..cells) = {
  assert(
    cells.named().len() == 0,
    message: "measure-cells doesn't take any named arguments"
  )

  assert(cells.pos().len() > 0, message: "Must provide at least one cell to measure")
  
  let (min-x, min-y) = (none, none)
  let (max-x, max-y) = (none, none)

  for cell in cells.pos() {
    assert(
      cell.has("x") and cell.x != auto,
      message: "Each measured cell has to have non-auto x"
    )
    assert(
      cell.has("y") and cell.y != auto,
      message: "Each measured cell has to have non-auto y"
    )
    
    if min-x == none or cell.x < min-x {
      min-x = cell.x
    }
    if min-y == none or cell.y < min-y {
      min-y = cell.y
    }
    
    if max-x == none or cell.x + cell.at("colspan", default: 1) - 1 > max-x {
      max-x = cell.x + cell.at("colspan", default: 1) - 1
    }
    if max-y == none or cell.y + cell.at("rowspan", default: 1) - 1 > max-y {
      max-y = cell.y + cell.at("rowspan", default: 1) - 1
    }
  }

  return (
    left: min-x,
    top: min-y,
    
    x: min-x,
    y: min-y,
    
    right: max-x,
    bottom: max-y,
    
    width: max-x - min-x + 1,
    height: max-y - min-y + 1,
  )
}

// Returns an array of grid.cell elements according to the passed diagram spec.
// Takes one positional argument, `spec`.
//
// A spec can be:
// - `none` or an emtpy array `()`:  An empty cell,
//                                   taking up at least a narrow column
// - a string or content:            A cell containing that string or content,
//                                   taking up at least a wide column
// - A dictionary:                   Control block (see below)
// - An array of specs:              The cells that each element produced,
//                                   stacked on top of each other. Wide columns
//                                   are aligned to wide columns of other element
//                                   specs and narrow columns consumed as needed.
//
// Specs can contain the following control blocks:
// - If/Then/Else:                                                      │╲▔▔▔▔╱│
//   A conditional with the following keys:                             │ ╲??╱ │
//   - `If`: The condition on which to branch                           │Y ╲╱ N│
//   - `Then`: A diagram spec for the "yes"-branch                      ├───┬──┤
//   - `Else`: A diagram spec for the "no"-branch                       │ … │  │
//   Then and Else are both optional, but at least one must be present  │   │ …│
//   Examples:                                                          └───┴──┘
//   - `(If: "debug mode", Then: ("print debug message"))`
//   - `(If: "x > 5", Then: ("x = x - 1", "print x"), Else: "print x")`
//   Columns: Takes up columns according to its contents next to one another,
//   inserting narrow columns for empty branches
//
// - For/Do, For/To/Do, For/In/Do, While/Do, Do/While:              ┌──────────┐
//   A loop, with the loop control either at the top or bottom.     │ While x  │
//   For/Do formats the control as "For $For",                      │  ┌───────┤
//   For/To/Do as "For $For to $To",                                │  │ Do    │
//   For/In/Do as "For each $For in $In",                           └──┴───────┘
//   While/Do and Do/While as "While $While".
//   Order of specified keys matters.
//   Examples:
//   - `(While: "true", Do: "print \"endless loop\"")`  (regular while loop)
//   - `(Do: "print \"endless loop\"", While: "true")`  (do-while loop)
//   - `(For: "item", In: "Container", Do: "print item.name")`
//   Columns: Inserts a narrow column left to its content.
//
// - Method call (Call)
//   A block indicating that a subroutine is executed here.       ┌┬──────────┬┐
//   Only accepts the key `Call`, which is the string name        ││ call()   ││
//   Example:                                                     └┴──────────┴┘
//   - `(Call: "func()")`
//   Columns: One wide column
//
// - Break/Return (Break)
//   A block indicating that a subroutine is executed here.        ┌───────────┐
//   Only accepts the key `Break`, which is the target to break to │⮜  target  │
//   Example:                                                      └───────────┘
//   - `(Break: "")`
//   - `(Break: "to enclosing loop")`
//   Columns: One wide column
//
// Named arguments:
// - columns:        If you already allocated wide and narrow columns, `to-elements`
//                   can use them. Useful for sub-specs, as you'd usually generate
//                   allocations first and then do another recursive pass to fill them.
//                   The default, `auto` does exactly this on the highest recursion level.
// - stroke:         The stroke to use between cells, or for control blocks.
//                   Note: to avoid duplicate strokes, every cell only adds strokes to
//                   its top and left side. Put the resulting cells in a container with
//                   bottom and right strokes for a finished diagram. See `structogram()`.
//                   Default: `0.5pt + black`
// - inset:          How much to pad each cell. Default: `0.5em`
// - segment-height: How high each row should be. Default: `2em`
// - narrow-width:   The width that narrow columns will be. Needed for diagonals in
//                   conditional blocks. Default: 1em
let to-elements(
  spec,
  columns: auto,
  stroke: 0.5pt + black,
  inset: 0.5em,
  segment-height: 2em,
  narrow-width: 1em,
) = {
  if columns == auto {
    columns = allocate-columns(spec)
  }
  
  if spec == none or spec == () {
    return (
      grid.cell(
        box(height: segment-height, inset: inset)[],
        x: 0, y: 0,
        colspan: columns.len(),
        rowspan: 1,
        stroke: (top: stroke, left: stroke),
      ),
    )
  }

  if type(spec) == content or type(spec) == str {
    return (
      grid.cell(
        box(height: segment-height, inset: inset, align(horizon)[#spec]),
        x: 0, y: 0,
        colspan: columns.len(),
        rowspan: 1,
        stroke: (top: stroke, left: stroke),        
      ),
    )
  }


  if type(spec) == array {
    let all-elements = ()
    let y = 0
    
    for subspec in spec {
      let elements = to-elements(
        subspec,
        columns: columns, 
        stroke: stroke,
        inset: inset,
        segment-height: segment-height,
        narrow-width: narrow-width,
      )

      elements = shift-cells(..elements, dy: y)

      y = measure-cells(..elements).bottom + 1

      for element in elements {
        all-elements.push(element)
      }
    }

    return all-elements
  }

  assert(type(spec) == dictionary, message: "spec must be one of: none, str, content, array of specs, dictionary, got: " + str(type(spec)))

  if spec.keys() == ("Break",) {
    return (
      grid.cell(
        box(
          height: segment-height, 
          stack(
            dir: ltr,
            spacing: -inset / 2,
            stack(
              dir: ttb,
              box(
                width: segment-height / 2, height: segment-height / 2,
                line(start: (0%, 100%), end: (100%, 0%), stroke: stroke),
              ),
              box(
                width: segment-height / 2, height: segment-height / 2,
                line(start: (0%, 0%), end: (100%, 100%), stroke: stroke),
              ),
            ),
            align(
              horizon,
              box(
                inset: inset,
                context { (localisation.at(text.lang, default: localisation.en).Break)(spec.Break) }
              )
            ),
          ),
        ),
        x: 0, y: 0,
        colspan: columns.len(),
        rowspan: 1,
        stroke: (top: stroke, left: stroke),
      ),
    )
  }

  if spec.keys() == ("Call",) {
    return (
      grid.cell(
        stack(
          dir: ltr,
          spacing: inset / 2,
          box(
            width: segment-height / 5, height: segment-height,
            line(start: (100%, 0%), end: (100%, 100%), stroke: stroke),
          ),
          align(horizon, box(inset: inset, spec.Call)),
          align(
            right,
            box(
              width: segment-height / 5, height: segment-height,
              align(left, line(start: (0%, 0%), end: (0%, 100%), stroke: stroke)),
            ),
          ),
        ),
        x: 0, y: 0,
        colspan: columns.len(),
        rowspan: 1,
        stroke: (top: stroke, left: stroke),
      ),
    )
  }

  if (("While" in spec or "For" in spec) and "Do" in spec) {
    assert(
      spec.keys() in (
        ("While", "Do"), ("Do", "While"), ("For", "Do"), ("For", "To", "Do"), ("For", "In", "Do")
      ),
      message: (
        "Must loop with either While-Do, Do-While, For-Do or For-In-Do, found: "
        + spec.keys().join("-")
      ),
    )
      
    if spec.keys() in (("While", "Do"), ("For", "Do"), ("For", "To", "Do"), ("For", "In", "Do")) {
      let condition = if "While" in spec {
        context { (localisation.at(text.lang, default: localisation.en).While)(spec.While) }
      } else if "In" in spec {
        context { (localisation.at(text.lang, default: localisation.en).ForIn)(spec.For, spec.In) }
      } else if "To" in spec {
        context { (localisation.at(text.lang, default: localisation.en).ForTo)(spec.For, spec.To) }
      } else {
        context { (localisation.at(text.lang, default: localisation.en).For)(spec.For) }
      }
      
      let do-elements = shift-cells(
        dx: +1, dy: +1,
        ..to-elements(
          spec.Do,
          columns:columns.slice(1, none),
          stroke: stroke,
          inset: inset,
          segment-height: segment-height,
          narrow-width: narrow-width,
        )
      )
          
      return (
        grid.cell(
          box(height: segment-height, inset: inset, align(horizon, condition)),
          x: 0, y: 0,
          colspan: columns.len(),
          rowspan: 1,
          stroke: (left: stroke, top: stroke, right: none, bottom: none),   
        ),
        ..do-elements,
        grid.cell(
          [],
          x: 0, y: 1,
          colspan: 1,
          rowspan: measure-cells(..do-elements).bottom + 1,
          stroke: (left: stroke, top: none, right: none, bottom: none),
        ),
      )
    }
    
    if spec.keys() == ("Do", "While") {
      let do-elements = shift-cells(
        dx: +1,
        ..to-elements(
          spec.Do,
          columns:columns.slice(1, none),
          stroke: stroke,
          inset: inset,
          segment-height: segment-height,
          narrow-width: narrow-width,
        )
      )

      do-elements.at(-1) = add-stroke(
        do-elements.at(-1),
        dir: "bottom",
        stroke: stroke,
      )
          
      return (
        grid.cell(
          box(
            height: segment-height, inset: inset,
            align(
              horizon,
              context { (localisation.at(text.lang, default: localisation.en).While)(spec.While) },
            ),
          ),
          x: 0, y: measure-cells(..do-elements).bottom + 1,
          colspan: columns.len(),
          rowspan: 1,
          stroke: (left: stroke, top: none, right: none, bottom: stroke),   
        ),
        ..do-elements,
        grid.cell(
          [],
          x: 0, y: 0,
          colspan: 1,
          rowspan: measure-cells(..do-elements).bottom + 1,
          stroke: (left: stroke, top: stroke, right: stroke, bottom: none),
        ),
      )
    }
    
    assert(false, message: "Malformed While spec: " + repr(spec) + ", keys: " + repr(spec.keys()))
  }

  if "If" in spec {
    if (
      spec.keys() == ("If", "Then")
      or spec.keys() == ("If", "Else")
      or (
        spec.keys() == ("If", "Then", "Else")
        and (
          spec.Then in ((), none)
          or spec.Else in ((), none)
        )
      )
    ) {
      let positive = "Then" in spec and spec.Then not in ((), none)
      
      let then-elements = shift-cells(
          dx: if positive { 0 } else { +1 }, dy: +1,
          ..to-elements(
            if positive { spec.Then } else { spec.Else },
            columns: if positive { columns.slice(0, -1) }
                     else { columns.slice(1, none) },
            stroke: stroke,
            inset: inset,
            segment-height: segment-height,
            narrow-width: narrow-width,
          )
        )
          
      return (
        grid.cell(
          colspan: if positive { columns.len() - 1 } else { 1 },
          x: 0, y: 0,
          stroke: (top: stroke, left: stroke, right: none, bottom: stroke),
          box(
            height: segment-height,
            width: if positive { auto } else { narrow-width },
            stack(
              dir: ttb,
              line(
                start: (0%, 0%),
                end: (100%, 100%),
                stroke: stroke,
              ),
              context{ set text(size: 0.75 * text.size)
                context { move(
                  dy: -measure([Y]).height - inset / 2,
                  dx: inset / 2,
                  [Y]
                ) }
              },
              if not positive {
                move(
                  dx: narrow-width - inset,
                  dy: -segment-height + inset,
                  context {
                    let cond = (localisation.at(text.lang, default: localisation.en).If)(spec.If)
                    box(width: measure(cond).width, cond)
                  },
                )
              }
            )
          )
        ),
        grid.cell(
          colspan: if positive { 1 } else { columns.len() - 1 },
          x: if positive { columns.len() - 1 } else { 1 }, y: 0,
          stroke: (top: stroke, left: none, right: none, bottom: stroke),
          box(
            height: segment-height,
            width: if positive { narrow-width } else { auto },
            align(right, 
              stack(
                dir: ttb,
                line(
                  start: (0%, 100%),
                  end: (100%, 0%),
                  stroke: stroke,
                ),
                context{ set text(size: 0.75 * text.size)
                  context { move(
                    dy: -measure([N]).height - inset / 2,
                    dx: -inset / 2,
                    [N]
                  ) }
                },
                if positive {
                  move(
                    dx: -narrow-width + inset,
                    dy: -segment-height + inset,
                    context {
                      let cond = (localisation.at(text.lang, default: localisation.en).If)(spec.If)
                      box(width: measure(cond).width, cond)
                    },
                  )
                }
              )
            )
          )
        ),
        ..then-elements,
        grid.cell(
          [],
          x: if positive { columns.len() - 1 } else { 0 }, y: 1,
          colspan: 1,
          rowspan: measure-cells(..then-elements).bottom,
          stroke: (top: stroke, left: stroke),
        ),
      )

    }
    
    if spec.keys() == ("If", "Then", "Else") {
      let then-alloc-columns = allocate-columns(spec.Then)

      let wide-column-index = 0
      let then-wide-columns = then-alloc-columns.fold(
        0, (cnt, el) => if (el) {cnt + 1} else {cnt}
      )

      let end-narrow-column-index = 0
      let then-end-narrow-columns = then-alloc-columns.rev().position((el) => el)

      if then-end-narrow-columns == none { then-end-narrow-columns = then-alloc-columns.len() }

      let (then-columns, else-columns) = ((), ())
      
      for column in columns {
        if column {
          wide-column-index += 1
          if wide-column-index <= then-wide-columns {
            then-columns.push(column)
            continue
          }
        }
        
        if wide-column-index < then-wide-columns {
          then-columns.push(column)
          continue
        }

        if end-narrow-column-index < then-end-narrow-columns and not column {
          end-narrow-column-index += 1
          then-columns.push(column)
          continue
        }

        else-columns.push(column)
      }
      
      let then-elements = shift-cells(
          dy: +1,
          ..to-elements(
            spec.Then,
            columns: then-columns,
            stroke: stroke,
            inset: inset,
            segment-height: segment-height,
            narrow-width: narrow-width,
          )
        )
      let else-elements = shift-cells(
          dx: then-columns.len(), dy: +1,
          ..to-elements(
            spec.Else,
            columns: else-columns,
            stroke: stroke,
            inset: inset,
            segment-height: segment-height,
            narrow-width: narrow-width,
          )
        )

      let (then-size, else-size) = (
        measure-cells(..then-elements),
        measure-cells(..else-elements),
      )

      let filler = ()

      if then-size.bottom < else-size.bottom {
        filler = (
          grid.cell(
            [],
            x: then-size.left,
            y: then-size.bottom + 1,
            colspan: then-size.width,
            rowspan: else-size.height - then-size.height,
            stroke: (top: stroke, left: stroke),
          ),
        )
      } else if then-size.bottom > else-size.bottom {
        filler = (
          grid.cell(
            [],
            x: else-size.left,
            y: else-size.bottom + 1,
            colspan: else-size.width,
            rowspan: then-size.height - else-size.height,
            stroke: (top: stroke, left: stroke),
          ),
        )
      }

      let condition-element = context {
        let cond = (localisation.at(text.lang, default: localisation.en).If)(spec.If)
        box(width: measure(cond).width, cond)
      }
          
      return (
        grid.cell(
          colspan: then-columns.len(),
          x: 0, y: 0,
          stroke: (top: stroke, left: stroke, right: none, bottom: stroke),
          box(
            height: segment-height,
            stack(
              dir: ttb,
              line(
                start: (0%, 0%),
                end: (100%, 100%),
                stroke: stroke,
              ),
              context{ set text(size: 0.75 * text.size)
                context { move(
                  dy: -measure([Y]).height - inset / 2,
                  dx: inset / 2,
                  [Y]
                ) }
              },
              align(
                right,
                context {
                  move(
                    dx: measure(condition-element).width / 2,
                    dy: -segment-height + inset,
                    condition-element,
                  )
                },
              ),
            )
          )
        ),
        grid.cell(
          colspan: else-columns.len(),
          x: then-columns.len(), y: 0,
          stroke: (top: stroke, left: none, right: none, bottom: stroke),
          box(
            height: segment-height,
            align(right, 
              stack(
                dir: ttb,
                line(
                  start: (0%, 100%),
                  end: (100%, 0%),
                  stroke: stroke,
                ),
                context{ set text(size: 0.75 * text.size)
                  context { move(
                    dy: -measure([N]).height - inset / 2,
                    dx: -inset / 2,
                    [N]
                  ) }
                },
              )
            )
          )
        ),
        ..then-elements,
        ..else-elements,
        ..filler,
      )
    }
    
    assert(false, message: "Malformed If spec: " + repr(spec) + ", keys: " + repr(spec.keys()))
  }
  
  assert(false, message: "Not a valid spec dictionary: " + repr(spec) + ", keys: " + repr(spec.keys()))

}

// Return a finished structogram element (in blocks).
// Positional arguments:
// - spec:           The structogram spec, see `to-elements()` for documentation
// Named arguments:
// - width:          Width for the entire diagram, `auto` (default) behaves like `box`
// - title:          A title for the structogram, usually a method name with arguments.
//                   Default: `none`
// - stroke:         The stroke to use for the structogram. Default: `0.5pt + black`
// - inset:          How much to pad cells in the structogram. Default: `0.5em`
// - segment-height: Height of rows in the structogram. Default: `2em`
// - narrow-width:   Width of narrow or empty columns in the structogram. Default: `1em`
// - fill:           A fill to use for the main structogram block. Default: `white`
// - secondary-fill: A fill to use for the outer block added if a title is provided. Default: `rgb("#eee")`
// - text-fill:      Fill to use for structogram text. Default: `black`
// - title-fill:     Fill to use for structogram title. Default: `black`
let structogram(
  spec,
  width: auto,
  title: none,
  stroke: 0.5pt + black,
  inset: 0.5em,
  segment-height: 2.5em,
  narrow-width: 1em,
  fill: white,
  secondary-fill: rgb("eee"),
  text-fill: black,
  title-fill: black,
) = {
  
  let columns = allocate-columns(spec)

  if width == auto {
    width = columns.fold(0pt, (width, column) => if column { width + 2 * segment-height + stroke-(stroke).thickness } else { width + narrow-width + stroke-(stroke).thickness })
  }

  let s-grid = grid(
    ..to-elements(
      spec,
      columns: columns,
      stroke: stroke,
      inset: inset,
      segment-height: segment-height,
      narrow-width: narrow-width,
    ),
    columns: columns.map(col => if (col) { 1fr } else { narrow-width }),
  )
  
  if title != none {
    return box(
      stroke: stroke,
      inset: inset * 2,
      radius: inset,
      fill: secondary-fill,
      width: width,
    )[
      #set text(fill: title-fill)
      #v(inset / 2)
      #heading(bookmarked: false, outlined: false, numbering: none, level: 4)[#title]
      #v(0.5em)
      #set text(fill: text-fill)
      #box(stroke: (bottom: stroke, right: stroke, top: none, left: none), fill: fill, inset: stroke.thickness / 2, s-grid)
    ]
  }

  return box(width:width, fill: fill, [#set text(fill: text-fill);#s-grid], stroke: (bottom: stroke, right: stroke))
}

structogram

}