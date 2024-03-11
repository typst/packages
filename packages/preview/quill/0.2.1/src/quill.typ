#import "utility.typ"
#import "length-helpers.typ"
#import "decorations.typ": *





/// Create a quantum circuit diagram. Children may be
/// - gates created by one of the many gate commands (@@gate(), 
///   @@mqgate(), @@meter(), ...),
/// - `[\ ]` for creating a new wire/row,
/// - commands like @@setwire(), @@slice() or @@gategroup(),
/// - integers for creating cells filled with the current wire setting,
/// - lengths for creating space between rows or columns,
/// - plain content or strings to be placed on the wire, and
/// - @@lstick(), @@midstick() or @@rstick() for placement next to the wire.
///
///
/// - wire (stroke): Style for drawing the circuit wires. This can take anything 
///            that is valid for the stroke of the builtin `line()` function. 
/// - row-spacing (length): Spacing between rows.
/// - column-spacing (length): Spacing between columns.
/// - min-row-height (length): Minimum height of a row (e.g., when no 
///             gates are given).
/// - min-column-width (length): Minimum width of a column.
/// - gate-padding (length): General padding setting including the inset for 
///            gate boxes and the distance of @@lstick() and co. to the wire. 
/// - equal-row-heights (boolean): If true, then all rows will have the same 
///            height and the wires will have equal distances orienting on the
///            highest row. 
/// - color (color): Foreground color, default for strokes, text, controls
///            etc. If you want to have dark-themed circuits, set this to white  
///            for instance and update `wire` and `fill` accordingly.           
/// - fill (color): Default fill color for gates. 
/// - font-size (length): Default font size for text in the circuit. 
/// - scale (ratio): Total scale factor applied to the entire 
///            circuit without changing proportions
/// - baseline (length, content, string): Set the baseline for the circuit. If a 
///            content or a string is given, the baseline will be adjusted auto-
///            matically to align with the center of it. One useful application is 
///            `"="` so the circuit aligns with the equals symbol. 
/// - circuit-padding (dictionary): Padding for the circuit (e.g., to accomodate 
///            for annotations) in form of a dictionary with possible keys 
///            `left`, `right`, `top` and `bottom`. Not all of those need to be 
///            specified. 
///
///            This setting basically just changes the size of the bounding box 
///            for the circuit and can be used to increase it when labels or 
///            annotations extend beyond the actual circuit. 
/// - ..children (array): Items, gates and circuit commands (see description). 
#let quantum-circuit(
  wire: .7pt + black,     
  row-spacing: 12pt,
  column-spacing: 12pt,
  min-row-height: 10pt, 
  min-column-width: 0pt, 
  gate-padding: .4em, 
  equal-row-heights: false, 
  color: black,
  fill: white,
  font-size: 10pt,
  scale: 100%,
  scale-factor: 100%,
  baseline: 0pt,
  circuit-padding: .4em,
  ..children
) = { 
  if children.pos().len() == 0 { return }
  if children.named().len() > 0 { 
    panic("Unexpected named argument '" + children.named().keys().at(0) + "' for quantum-circuit()")
  }
  set text(color, size: font-size)
  
  style(styles => {
  
  // Parameter object to pass to draw-function containing current style info
  let draw-params = (
    wire: wire,
    padding: measure(line(length: gate-padding), styles).width,
    background: fill,
    color: color,
    styles: styles,
    // roman-gates: roman-gates,
    x-gate-size: none,
    multi: (wire-distance: 0pt),
    em: measure(line(length: 1em), styles).width
  )

  draw-params.x-gate-size = layout.default-size-hint(gate($X$), draw-params)
  
  let items = children.pos().map( x => {
    if type(x) in ("content", "string") and x != [\ ] { return gate(x) }
    return x
  })
  
  /////////// First pass: Layout (spacing)   ///////////
  
  let column-spacing = length-helpers.convert-em-length(column-spacing, draw-params.em)
  let row-spacing = length-helpers.convert-em-length(row-spacing, draw-params.em)
  let min-row-height = length-helpers.convert-em-length(min-row-height, draw-params.em)
  let min-column-width = length-helpers.convert-em-length(min-column-width, draw-params.em)
  
  let colwidths = ()
  let rowheights = (min-row-height,)
  let (row-gutter, col-gutter) = ((0pt,), ())
  let (row, col) = (0, 0)
  let wire-ended = false
  
  for item in items { 
    if item == [\ ] {
      
      if rowheights.len() < row + 2 { 
        rowheights.push(min-row-height)
        row-gutter.push(0pt)
      }
      row += 1; col = 0
      wire-ended = true
    } else if utility.is-circuit-meta-instruction(item) { 
    } else if utility.is-circuit-drawable(item) {
      let isgate = utility.is-gate(item)
      if isgate { item.qubit = row }
      let ismulti = isgate and item.multi != none
      let size = utility.get-size-hint(item, draw-params)
      
      let width = size.width 
      let height = size.height
      if isgate and item.floating { width = 0pt }

      if colwidths.len() < col + 1 { 
        colwidths.push(min-column-width)
        col-gutter.push(0pt)
      }
      colwidths.at(col) = calc.max(colwidths.at(col), width)
      
      if not (ismulti and item.multi.size-all-wires == none) {
        // e.g., l, rsticks
        rowheights.at(row) = calc.max(rowheights.at(row), height)
      } 
      
      if ismulti and item.multi.num-qubits > 1 and item.multi.size-all-wires != none { 
        let start = row
        if not item.multi.size-all-wires {
          start = calc.max(0, row + item.multi.num-qubits - 1)
        }
        for qubit in range(start, row + item.multi.num-qubits) {
          while rowheights.len() < qubit + 1 { 
            rowheights.push(min-row-height)
            row-gutter.push(0pt)
          }
          rowheights.at(qubit) = calc.max(rowheights.at(qubit), height)
        }
      }
      col += 1
      wire-ended = false
    } else if type(item) == "integer" {
      for _ in range(colwidths.len(), col + item) { 
        colwidths.push(min-column-width)
        col-gutter.push(0pt) 
      }
      col += item
      wire-ended = false
    } else if type(item) == "length" {
      if wire-ended {
        row-gutter.at(row - 1) = calc.max(row-gutter.at(row - 1), item)
      } else if col > 0 {
        col-gutter.at(col - 1) = calc.max(col-gutter.at(col - 1), item)
      }
    }
  }
  /////////// END First pass: Layout (spacing)   ///////////
  
  rowheights = rowheights.map(x => x + row-spacing)
  colwidths = colwidths.map(x => x + column-spacing)

  if equal-row-heights {
    let max-row-height = calc.max(..rowheights)
    rowheights = rowheights.map(x => max-row-height)
  }
  let center-x-coords = layout.compute-center-coords(colwidths, col-gutter).map(x => x - 0.5 * column-spacing)
  let center-y-coords = layout.compute-center-coords(rowheights, row-gutter).map(x => x - 0.5 * row-spacing)
  draw-params.center-y-coords = center-y-coords
  
  (row, col) = (0, 0)
  let (x, y) = (0pt, 0pt) // current cell top-left coordinates
  let center-y = y + rowheights.at(row) / 2 // current cell center y-coordinate
  let center-y = center-y-coords.at(0) // current cell center y-coordinate
  let circuit-width = colwidths.sum() + col-gutter.slice(0, -1).sum(default: 0pt) - column-spacing
  let circuit-height = rowheights.sum() + row-gutter.sum() - row-spacing

  let wire-count = 1
  let wire-distance = 1pt
  let wire-stroke = wire
  let prev-wire-x = center-x-coords.at(0)

  /////////// Second pass: Generation ///////////
  
  let bounds = (0pt, 0pt, circuit-width, circuit-height)
  
  let circuit = block(
    width: circuit-width, height: circuit-height, {
    set align(top + left) // quantum-circuit could be called in a scope where these have been changed which would mess up everything

    let to-be-drawn-later = () // dicts with content, x and y
      
    for item in items {
      if item == [\ ]{
        y += rowheights.at(row)
        row += 1
        center-y = center-y-coords.at(row)
        col = 0; x = 0pt
        wire-count = 1; wire-stroke = wire
        prev-wire-x = center-x-coords.at(0)
        
      } else if utility.is-circuit-meta-instruction(item) {
        if item.qc-instr == "setwire" {
          wire-count = item.wire-count
          wire-distance = item.wire-distance
          if item.stroke != none { wire-stroke = item.stroke }
        } else if item.qc-instr == "gategroup" {
          assert(item.wires > 0, message: "gategroup: wires arg needs to be > 0")
          assert(row+item.wires <= rowheights.len(), message: "gategroup: height exceeds range")
          assert(item.steps > 0, message: "gategroup: steps arg needs to be > 0")
          assert(col+item.steps <= colwidths.len(), message: "gategroup: width exceeds range")
          let y1 = layout.get-cell-coords(center-y-coords, rowheights, row)
          let y2 = layout.get-cell-coords(center-y-coords, rowheights, row + item.wires - 1e-9)
          let x1 = layout.get-cell-coords(center-x-coords, colwidths, col)
          let x2 = layout.get-cell-coords(center-x-coords, colwidths, col + item.steps - 1e-9)
          let (result, b) = draw-functions.draw-gategroup(x1, x2, y1, y2, item, draw-params)
          bounds = layout.update-bounds(bounds, b, draw-params.em)
          result
        } else if item.qc-instr == "slice" {
          assert(item.wires >= 0, message: "slice: wires arg needs to be > 0")
          assert(row+item.wires <= rowheights.len(), message: "slice: number of wires exceeds range")
          let end = if item.wires == 0 {rowheights.len()} else {row+item.wires}
          let y1 = layout.get-cell-coords(center-y-coords, rowheights, row)
          let y2 = layout.get-cell-coords(center-y-coords, rowheights, end)
          let x = layout.get-cell-coords(center-x-coords, colwidths, col)
          let (result, b) = draw-functions.draw-slice(x, y1, y2, item, draw-params)
          bounds = layout.update-bounds(bounds, b, draw-params.em)
          result
        } else if item.qc-instr == "annotate" {
          let rows = layout.get-cell-coords(center-y-coords, rowheights, item.rows)
          let cols = layout.get-cell-coords(center-x-coords, colwidths, item.columns)
          let annotation = (item.callback)(cols, rows)
          if type(annotation) == "dictionary" {
            assert("content" in annotation, message: "Missing field 'content' in annotation")
            let (content, b) = layout.place-with-labels(
              annotation.content,
              dx: annotation.at("dx", default: 0pt),
              dy: annotation.at("dy", default: 0pt),
              draw-params: draw-params
            )
            content 
            bounds = layout.update-bounds(bounds, b, draw-params.em)
          } else if type(annotation) == "content" {
            place(annotation)
          } else {
            assert(false, message: "Unsupported annotation type")
          }
        }
      // ---------------------------- Gates & Co. ------------------------------
      } else if utility.is-circuit-drawable(item) {
        
        let isgate = utility.is-gate(item)
        
        let size = utility.get-size-hint(item, draw-params)
        let single-qubit-height = size.height
        let center-x = center-x-coords.at(col)
        let top = center-y - single-qubit-height / 2
        let bottom = center-y + single-qubit-height / 2
  

        if isgate {
          item.qubit = row
          if item.box == false {
            bottom = center-y
            top = center-y
          }
          if item.multi != none {
            if item.multi.target != none {
              let target-qubit = row + item.multi.target
              assert(center-y-coords.len() > target-qubit, message: "Target qubit for controlled gate is out of range")
              let y1 = center-y
              let y2 = center-y-coords.at(target-qubit)

              if item.multi.wire-label.len() == 0 {
                draw-functions.draw-vertical-wire(
                  y1, 
                  y2, 
                  center-x, 
                  wire, 
                  wire-count: item.multi.wire-count,
                )
              } else {
                let (result, gate-bounds) = draw-functions.draw-vertical-wire-with-labels(
                  y1, 
                  y2, 
                  center-x, 
                  wire, 
                  wire-count: item.multi.wire-count,
                  wire-labels: item.multi.wire-label,
                  draw-params: draw-params
                )
                result
                bounds = layout.update-bounds(bounds, gate-bounds, draw-params.em)
              }
            } 
            let nq = item.multi.num-qubits
            if nq > 1 {
              assert(row + nq - 1 < center-y-coords.len(), message: "Target 
              qubit for multi qubit gate does not exist")
              let y1 = center-y-coords.at(row + nq - 1)
              let y2 = center-y-coords.at(row)
              draw-params.multi.wire-distance = y1 - y2
              size = (item.size-hint)(item, draw-params)
            }
          }
        }
        
        let current-wire-x = center-x
        draw-functions.draw-horizontal-wire(prev-wire-x, current-wire-x, center-y, wire-stroke, wire-count, wire-distance: wire-distance)
        if isgate and item.box { prev-wire-x = center-x + size.width / 2 } 
        else { prev-wire-x = current-wire-x }
        
        let x-pos = center-x
        let y-pos = center-y
        let offset = size.at("offset", default: auto)
        if offset == auto {
          x-pos -= size.width / 2
          y-pos -= single-qubit-height / 2
        } else if type(offset) == "dictionary" {
          let offset-x = offset.at("x", default: auto)
          let offset-y = offset.at("y", default: auto)
          if offset-x == auto { x-pos -= size.width / 2}
          else if type(offset-x) == "length" { x-pos -= offset-x }
          if offset-y == auto { y-pos -= single-qubit-height / 2}
          else if type(offset-y) == "length" { y-pos -= offset-y }
        }
        
        let content = utility.get-content(item, draw-params)

        let result
        if isgate {
          let gate-bounds
          (result, gate-bounds) = layout.place-with-labels(
            content, 
            size: if item.multi != none and item.multi.num-qubits > 1 {auto} else {size},
            dx: x-pos, dy: y-pos, 
            labels: item.labels, draw-params: draw-params
          )
          bounds = layout.update-bounds(bounds, gate-bounds, draw-params.em)
        } else {
          result = place(
            dx: x-pos, dy: y-pos, 
            if isgate { content } else { box(content) }
          )
        }
        to-be-drawn-later.push(result)
      
          
        x += colwidths.at(col)
        col += 1
        draw-params.multi.wire-distance = 0pt
      } else if type(item) == "integer" {
        col += item
        // let t = col
        // if col == center-x-coords.len() { t -= 1}
        let center-x = center-x-coords.at(col - 1)
        draw-functions.draw-horizontal-wire(prev-wire-x, center-x, center-y, wire-stroke, wire-count, wire-distance: wire-distance)
        prev-wire-x = center-x
      }
      
    } // end loop over items
    for item in to-be-drawn-later {
      item
    }
  }) // end circuit = block(..., {
    
  /////////// END Second pass: Generation ///////////
  // grace period backwards-compatibility:
  let scale = scale
  if scale-factor != 100% { scale = scale-factor }
  let scale-float = scale / 100%
  if circuit-padding != none {
    let circuit-padding = process-args.process-padding-arg(circuit-padding)
    bounds.at(0) -= circuit-padding.left
    bounds.at(1) -= circuit-padding.top
    bounds.at(2) += circuit-padding.right
    bounds.at(3) += circuit-padding.bottom
  }
  let final-height = scale-float * (bounds.at(3) - bounds.at(1))
  let final-width = scale-float * (bounds.at(2) - bounds.at(0))
  
  let thebaseline = baseline
  if type(thebaseline) in ("content", "string") {
    thebaseline = height/2 - measure(thebaseline, styles).height/2
  }
  if type(thebaseline) == "fraction" {
    thebaseline = 100% - layout.get-cell-coords1(center-y-coords, rowheights, thebaseline / 1fr) + bounds.at(1)
  }
  box(baseline: thebaseline,
    width: final-width,
    height: final-height, 
    // stroke: 1pt + gray,
    align(left + top, move(dy: -scale-float * bounds.at(1), dx: -scale-float * bounds.at(0), 
      layout.std-scale(
        x: scale, 
        y: scale, 
        origin: left + top, 
        circuit
    )))
  )
  
})
}