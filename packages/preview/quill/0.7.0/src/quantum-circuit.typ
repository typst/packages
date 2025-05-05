#import "utility.typ" as utility: if-auto
#import "verifications.typ"
#import "length-helpers.typ"
#import "decorations.typ": *

#let signum(x) = if x >= 0. { 1. } else { -1. }



/// Create a quantum circuit diagram. Children may be
/// - gates created by one of the many gate commands (@gate, @mqgate, @meter, ...),
/// - `[\ ]` for creating a new wire/row,
/// - commands like @setwire, @slice or @gategroup,
/// - integers for creating cells filled with the current wire setting,
/// - lengths for creating space between rows or columns,
/// - plain content or strings to be placed on the wire, and
/// - @lstick, @midstick or @rstick for placement next to the wire.
#let quantum-circuit(

  /// Style for drawing the circuit wires. This can take anything 
  /// that is valid for the stroke of the built-in `line()` function. 
  /// -> stroke
  wire: .7pt + black,     

  /// Spacing between rows.
  /// -> length
  row-spacing: 12pt,

  /// Spacing between columns.
  /// -> length
  column-spacing: 12pt,

  /// Minimum height of a row (e.g., when no gates are given).
  /// -> length
  min-row-height: 10pt, 

  /// Minimum width of a column.
  /// -> length
  min-column-width: 0pt, 

  /// General padding setting including the inset for gate boxes and 
  /// the distance of @lstick and co. to the wire. 
  /// -> length
  gate-padding: .4em, 

  /// If true, then all rows will have the same height and the wires will
  /// have equal distances orienting on the highest row. 
  /// -> bool
  equal-row-heights: false, 

  /// Foreground color, default for strokes, text, controls etc. If you want
  /// to have dark-themed circuits, set this to white for instance and
  /// update `wire` and `fill` accordingly.           
  /// -> color
  color: black,

  /// Default fill color for gates. 
  /// -> color
  fill: white,

  /// Default font size for text in the circuit. 
  /// -> length
  font-size: 10pt,

  /// Total scale factor applied to the entire circuit without changing proportions.
  /// -> ratio
  scale: 100%,

  /// Set the baseline for the circuit. If a content or a string is given, the 
  /// baseline will be adjusted automatically to align with the center of it. 
  /// One useful application is `"="` so the circuit aligns with the equals symbol. 
  /// -> length | content | str
  baseline: 0pt,

  /// Padding for the circuit (e.g., to accommodate for annotations) in form of 
  /// a dictionary with possible keys `left`, `right`, `top` and `bottom`. Not 
  /// all of those need to be  specified. 
  ///
  /// This setting basically just changes the size of the bounding box for the
  /// circuit and can be used to increase it when labels or annotations extend 
  /// beyond the actual circuit. 
  /// -> length | dictionary
  circuit-padding: .4em,

  /// Whether to automatically fill up all wires until the end. 
  /// -> bool
  fill-wires: true,

  /// Items, gates and circuit commands (see description). 
  /// -> any
  ..children

) = { 
  if children.pos().len() == 0 { return }
  if children.named().len() > 0 { 
    panic("Unexpected named argument '" + children.named().keys().at(0) + "' for quantum-circuit()")
  }
  if type(wire) == color { wire += .7pt }
  if type(wire) == length { wire += black }

  set text(wire.paint, size: font-size)
  set math.equation(numbering: none)

  context {
  
  // Parameter object to pass to draw-function containing current style info
  let draw-params = (
    wire: wire,
    padding: measure(line(length: gate-padding)).width,
    background: fill,
    color: color,
    x-gate-size: none,
    multi: (wire-distance: 0pt)
  )

  draw-params.x-gate-size = layout.default-size-hint(gate($X$), draw-params)
  
  let items = children.pos().map( x => {
    if type(x) in (content, str) and x != [\ ] { return gate(x) }
    return x
  })
  
  /////////// First part: Layout (and spacing)   ///////////
  
  let column-spacing = column-spacing.to-absolute()
  let row-spacing = row-spacing.to-absolute()
  let min-row-height = min-row-height.to-absolute()
  let min-column-width = min-column-width.to-absolute()
  
  // All these arrays are gonna be filled up in the loop over `items`
  let matrix = ((),)
  let row-gutter = (0pt,)
  let single-qubit-gates = ()
  let multi-qubit-gates = ()
  let meta-instructions = ()

  let auto-cell = (empty: true, size: (width: 0pt, height: 0pt), gutter: 0pt)

  let default-wire-style = (
    count: 1,
    distance: 1pt, 
    stroke: wire
  )
  let wire-style = default-wire-style
  let wire-instructions = ()

  let (row, col) = (0, 0)
  let prev-col = 0
  let wire-ended = false

  for item in items {
    if item == [\ ] {
      if fill-wires {
        wire-instructions.push((row, prev-col, -1))
      }
      row += 1; col = 0; prev-col = 0

      if row >= matrix.len() {
        matrix.push(())
        row-gutter.push(0pt)
      }
      wire-style = default-wire-style
      wire-instructions.push(wire-style)
      wire-ended = true
    } else if utility.is-circuit-meta-instruction(item) { 
      if item.qc-instr == "setwire" {
        // let (x, y) = (if-auto(item.x, col), if-auto(item.y, row))
        wire-style.count = item.wire-count

        wire-style.distance = utility.if-auto(item.wire-distance, wire-style.distance)
        wire-style.stroke = utility.if-auto(utility.update-stroke(wire-style.stroke, item.stroke), wire-style.stroke)
        wire-instructions.push(wire-style)
      } else {
        // Visual meta instructions are handled later
        let (x, y) = (if-auto(item.x, col), if-auto(item.y, row))
        meta-instructions.push((x: x, y: y, item: item))
      }
    } else if utility.is-circuit-drawable(item) {
      let gate = item
      let (x, y) = (gate.x, gate.y)
      if x == auto { 
        x = col 
        if y == auto {
          if col != prev-col {
            wire-instructions.push((row, prev-col, col))
          }
          prev-col = col 
          col += 1
        }
      }
      if y == auto { y = row }

      if y >= matrix.len() { matrix += ((),) * (y - matrix.len() + 1) }
      if x >= matrix.at(y).len() {
        matrix.at(y) += (auto-cell,) * (x - matrix.at(y).len() + 1)
      }

      assert(matrix.at(y).at(x).empty, message: "Attempted to place a second gate at column " + str(x) + ", row " + str(y))

      let size-hint = utility.get-size-hint(item, draw-params)
      let gate-size = size-hint
      if item.floating { size-hint.width = 0pt } // floating items don't take width in the layout

      matrix.at(y).at(x) = (
        size: size-hint,
        gutter: 0pt,
        box: item.box,
        empty: gate.data == "placeholder"
      )
      let gate-info = (
        gate: gate,
        size: gate-size,
        x: x,
        y: y
      )
      if gate.multi != none { multi-qubit-gates.push(gate-info) } 
      else { single-qubit-gates.push(gate-info) }
      wire-ended = false
    } else if type(item) == int {
      wire-instructions.push((row, prev-col, col + item - 1))
      col += item
      prev-col = col - 1
      if col >= matrix.at(row).len() {
        matrix.at(row) += (auto-cell,) * (col - matrix.at(row).len())
      }
      wire-ended = false
    } else if type(item) == length {
      if wire-ended {
        row-gutter.at(row - 1) = calc.max(row-gutter.at(row - 1), item)
      } else if col > 0 {
        matrix.at(row).at(col - 1).gutter = calc.max(matrix.at(row).at(col - 1).gutter, item)
      }
    }
  }

  // finish up matrix
  let num-rows = matrix.len()
  let num-cols = calc.max(0, ..matrix.map(array.len))
  if num-rows == 0 or num-cols == 0 { return none }

  
  for i in range(num-rows) {
    matrix.at(i) += (auto-cell,) * (num-cols - matrix.at(i).len())
  }
  row-gutter += (0pt,) * (matrix.len() - row-gutter.len())

  if fill-wires {
    wire-instructions.push((row, prev-col, -1)) // fill current wire
    wire-instructions += range(row + 1, num-rows).map(row => (row, 0, -1)) // we may not have visited all wires due to manual placement. Fill all remaining wires. 
  }

  let vertical-wires = ()
  // Treat multi-qubit gates (and controlled gates)
  // - extract and store all necessary vertical control wires
  // - Apply same size-hints to all cells that a mqgate spans (without the control wire). 
  for gate in multi-qubit-gates {
    let (x, y) = gate
    let size = matrix.at(y).at(x).size
    let multi = gate.gate.multi
    
    if multi.target != none and multi.target != 0 {
      verifications.verify-controlled-gate(gate.gate, x, y, num-rows, num-cols)

      let diff = if multi.target > 0 {multi.num-qubits - 1} else {0}
      vertical-wires.push((
        x: x, 
        y: y + diff, 
        target: multi.target - diff, 
        wire-style: (count: multi.wire-count),
        labels: multi.wire-label
      ))
    }
    let nq = multi.num-qubits
    if nq == 1 { continue }

    verifications.verify-mqgate(gate.gate, x, y, num-rows, num-cols)

    for qubit in range(y, y + nq) {
      matrix.at(qubit).at(x).size.width = size.width
    }
    let start = y
    if multi.size-all-wires != none {
      if not multi.size-all-wires {
        start = calc.max(0, y + nq - 1)
      }
      for qubit in range(start, y + nq) {
        matrix.at(qubit).at(x).size = size
      }
    }
  }


  let row-heights = matrix.map(row => 
    calc.max(min-row-height, ..row.map(item => item.size.height)) + row-spacing
  )
  if equal-row-heights {
    let max-row-height = calc.max(..row-heights)
    row-heights = (max-row-height,) * row-heights.len()
  }

  let col-widths = range(num-cols).map(j => 
    calc.max(min-column-width, ..range(num-rows).map(i => {
        matrix.at(i).at(j).size.width
    })) + column-spacing 
  )

  let col-gutter = range(num-cols).map(j => 
    calc.max(0pt, ..range(num-rows).map(i => {
        matrix.at(i).at(j).gutter
    }))
  )

  let center-x-coords = layout.compute-center-coords(col-widths, col-gutter).map(x => x - 0.5 * column-spacing)
  let center-y-coords = layout.compute-center-coords(row-heights, row-gutter).map(x => x - 0.5 * row-spacing)
  draw-params.center-y-coords = center-y-coords
  
  let circuit-width = col-widths.sum() + col-gutter.slice(0, -1).sum(default: 0pt) - column-spacing
  let circuit-height = row-heights.sum() + row-gutter.sum() - row-spacing



  /////////// Second part: Generation ///////////
  
  let bounds = (0pt, 0pt, circuit-width, circuit-height)
  
  let circuit = block(
    width: circuit-width, height: circuit-height, {
    set align(top + left) // quantum-circuit could be called in a scope where these have been changed which would mess up everything

    let layer-below-circuit
    let layer-above-circuit
    for (item, x, y) in meta-instructions {
      let (the-content, decoration-bounds) = (none, none)
      if item.qc-instr == "gategroup" {
        verifications.verify-gategroup(item, x, y, num-rows, num-cols)
        let (dy1, dy2) = layout.get-cell-coords(center-y-coords, row-heights, (y, y + item.wires - 1e-9))
        let (dx1, dx2) = layout.get-cell-coords(center-x-coords, col-widths, (x, x + item.steps - 1e-9))
        (the-content, decoration-bounds) = draw-functions.draw-gategroup(dx1, dx2, dy1, dy2, item, draw-params)
      } else if item.qc-instr == "slice" {
        verifications.verify-slice(item, x, y, num-rows, num-cols)
        let end = if item.wires == 0 { row-heights.len() } else { y + item.wires }
        let (dy1, dy2) = layout.get-cell-coords(center-y-coords, row-heights, (y, end))
        let dx = layout.get-cell-coords(center-x-coords, col-widths, x)
        (the-content, decoration-bounds) = draw-functions.draw-slice(dx, dy1, dy2, item, draw-params)
      } else if item.qc-instr == "annotate" {
        let rows = layout.get-cell-coords(center-y-coords, row-heights, item.rows)
        let cols = layout.get-cell-coords(center-x-coords, col-widths, item.columns)
        let annotation = (item.callback)(cols, rows)
        verifications.verify-annotation-content(annotation)
        if type(annotation) == dictionary {
          (the-content, decoration-bounds) = layout.place-with-labels(
            annotation.content,
            dx: annotation.at("dx", default: 0pt),
            dy: annotation.at("dy", default: 0pt),
            draw-params: draw-params
          )
        } else if type(annotation) in (symbol, content, str) {
          layer-below-circuit += place(annotation)
        } 
      }
      if decoration-bounds != none {
        bounds = layout.update-bounds(bounds, decoration-bounds)
      }
      if item.at("z", default: "below") == "below" { layer-below-circuit += the-content  }
      else { layer-above-circuit += the-content  }
    }

    layer-below-circuit


    let get-gate-pos(x, y, size-hint) = {
      let dx = center-x-coords.at(x)
      let dy = center-y-coords.at(y)
      let (width, height) = size-hint
      let offset = size-hint.at("offset", default: auto)

      if offset == auto { return (dx - width / 2, dy - height / 2) } 

      assert(type(offset) == dictionary, message: "Unexpected type `" + str(type(offset)) + "` for parameter `offset`") 
      
      let offset-x = offset.at("x", default: auto)
      let offset-y = offset.at("y", default: auto)
      if offset-x == auto { dx -= width / 2}
      else if type(offset-x) == length { dx -= offset-x }
      if offset-y == auto { dy -= height / 2}
      else if type(offset-y) == length { dy -= offset-y }
      return (dx, dy)
    }


    let get-anchor-width(x, y) = {
      if x == num-cols { return 0pt }
      let el = matrix.at(y).at(x)
      if "box" in el and not el.box { return 0pt }
      return el.size.width
    }

    let get-anchor-height(x, y) = {
      let el = matrix.at(y).at(x)
      if "box" in el and not el.box { return 0pt }
      return el.size.height
    }


    let wire-style = default-wire-style
    for wire-piece in wire-instructions {
      if type(wire-piece) == dictionary {
        wire-style = wire-piece
      } else {
        if wire-style.count == 0 { continue }
        let (row, start-x, end-x) = wire-piece
        if end-x == -1 {
          end-x = num-cols - 1
        }
        if start-x == end-x { continue }

        let draw-subwire(x1, x2) = {
          let dx1 = center-x-coords.at(x1)
          let dx2 = center-x-coords.at(x2, default: circuit-width)
          let dy = center-y-coords.at(row)
          dx1 += get-anchor-width(x1, row) / 2
          dx2 -= get-anchor-width(x2, row) / 2
          draw-functions.draw-horizontal-wire(dx1, dx2, dy, wire-style.stroke, wire-style.count, wire-distance: wire-style.distance)
        }
        // Draw wire pieces and take care not to draw through gates. 
        for x in range(start-x + 1, end-x) {
          let anchor-width = get-anchor-width(x, row)
          if anchor-width == 0pt { continue } // no gate or `box: false` gate. 
          draw-subwire(start-x, x)
          start-x = x
        }
        draw-subwire(start-x, end-x)
      }
    }
    
    for (x, y, target, wire-style, labels) in vertical-wires {
      let dx = center-x-coords.at(x)
      let (dy1, dy2) = (center-y-coords.at(y), center-y-coords.at(y + target))
      dy1 += get-anchor-height(x, y) / 2 * signum(target)
      dy2 -= get-anchor-height(x, y + target) / 2 * signum(target)
      
      if labels.len() == 0 {
        draw-functions.draw-vertical-wire(
          dy1, dy2, dx, 
          wire, wire-count: wire-style.count,
        )
      } else {
        let (result, gate-bounds) = draw-functions.draw-vertical-wire-with-labels(
          dy1, dy2, dx, 
          wire, wire-count: wire-style.count,
          wire-labels: labels,
          draw-params: draw-params
        )
        result
        bounds = layout.update-bounds(bounds, gate-bounds)
      }
    }
    
    
    for gate-info in single-qubit-gates {
      let (gate, size, x, y) = gate-info
      let (dx, dy) = get-gate-pos(x, y, size)
      let content = utility.get-content(gate, draw-params)

      let (result, gate-bounds) = layout.place-with-labels(
        content, 
        size: size,
        dx: dx, dy: dy, 
        labels: gate.labels, draw-params: draw-params
      )
      bounds = layout.update-bounds(bounds, gate-bounds)
      result
    }
    
    for gate-info in multi-qubit-gates {
      let (gate, size, x, y) = gate-info
      let draw-params = draw-params
      gate.qubit = y
      if gate.multi.num-qubits > 1 {
        let dy1 = center-y-coords.at(y + gate.multi.num-qubits - 1)
        let dy2 = center-y-coords.at(y)
        draw-params.multi.wire-distance = dy1 - dy2
      }
      
      // lsticks need their offset/width to be updated again (but don't update the height!)
      let content = utility.get-content(gate, draw-params)
      let new-size = utility.get-size-hint(gate, draw-params)
      size.offset = new-size.offset
      size.width = new-size.width

      let (dx, dy) = get-gate-pos(x, y, size)
      let (result, gate-bounds) = layout.place-with-labels(
        content, 
        size: if gate.multi != none and gate.multi.num-qubits > 1 {auto} else {size},
        dx: dx, dy: dy, 
        labels: gate.labels, draw-params: draw-params
      )
      bounds = layout.update-bounds(bounds, gate-bounds)
      result
    }

    layer-above-circuit

    // show matrix
    // for (i, row) in matrix.enumerate() {
    //   for (j, entry) in row.enumerate() {
    //     let (dx, dy) = (center-x-coords.at(j), center-y-coords.at(i))
    //     place(
    //       dx: dx - entry.size.width / 2, dy: dy - entry.size.height / 2, 
    //       box(stroke: green, width: entry.size.width, height: entry.size.height)
    //     )
    //   }
    // }
  
  }) // end circuit = block(..., {
    
  let scale = scale
  if circuit-padding != none {
    let circuit-padding = process-args.process-padding-arg(circuit-padding)
    bounds.at(0) -= circuit-padding.left
    bounds.at(1) -= circuit-padding.top
    bounds.at(2) += circuit-padding.right
    bounds.at(3) += circuit-padding.bottom
  }
  let final-height = scale * (bounds.at(3) - bounds.at(1))
  let final-width = scale * (bounds.at(2) - bounds.at(0))
  
  let thebaseline = baseline
  if type(thebaseline) in (content, str) {
    thebaseline = height/2 - measure(thebaseline).height/2
  }
  if type(thebaseline) == fraction {
    thebaseline = 100% - layout.get-cell-coords1(center-y-coords, row-heights, thebaseline / 1fr) + bounds.at(1)
  }
  box(baseline: thebaseline,
    width: final-width,
    height: final-height, 
    // stroke: 1pt + gray,
    align(left + top, move(dy: -scale * bounds.at(1), dx: -scale * bounds.at(0), 
      layout.std-scale(
        x: scale, 
        y: scale, 
        origin: left + top, 
        circuit
    )))
  )
  
}
}
