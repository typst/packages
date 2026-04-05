
#let b-if-a-is-none(a, b) = { if a != none { a } else { b } }
#let is-gate(item) = { type(item) == "dictionary" and "gate-type" in item }
#let is-circuit-drawable(item) = { is-gate(item) or type(item) in ("string", "content") }
#let is-circuit-meta-instruction(item) = { type(item) == "dictionary" and "qc-instr" in item }


#let draw-arrow(start, end, length: 5pt, width: 2.5pt, stroke: 1pt + black, arrow-color: black) = {
  place(line(start: start, end: end, stroke: stroke))
  let dir = (end.at(0) - start.at(0), end.at(1) - start.at(1))
  dir = dir.map(x => float(repr(x).slice(0,-2)))
  // let angle = calc.atan2(dir.at(0), dir.at(1))
  
  let len = calc.sqrt(dir.map(x => x*x).sum())
  dir = dir.map(x => x/len)
  let normal = (-dir.at(1), dir.at(0))

  let arrow-start = end
  let arrow-end = (end.at(0) + length*dir.at(0), end.at(1) + length*dir.at(1))
  let w = width/2
  let v1 = (arrow-start.at(0) - w*normal.at(0), arrow-start.at(1) - w*normal.at(1))
  let v2 = (arrow-start.at(0) + w*normal.at(0), arrow-start.at(1) + w*normal.at(1))
  path(arrow-end, v1, v2, closed: true, fill: arrow-color)
}

#let test-arrow() = {
  draw-arrow((0pt, 0pt), (20pt, 10pt), stroke: .1pt)
}
// INTERNAL GATE DRAW FUNCTIONS

#let draw-targ(item, draw-params) = {
  let size = item.data.size
  box[
    #circle(
      radius: size, 
      stroke: draw-params.wire, 
      fill: if item.fill == none {none} 
        else { 
          if item.fill == true {draw-params.background} 
          else if type(item.fill) == "color" {item.fill} 
        }
    )
    #place(line(start: (size, 0pt), length: 2*size, angle: -90deg, stroke: draw-params.wire))
    #place(line(start: (0pt, -size), length: 2*size, stroke: draw-params.wire))
  ]
}

#let draw-ctrl(gate, draw-params) = {
  let clr = draw-params.wire
  let color = b-if-a-is-none(gate.fill, draw-params.color)
  if "show-dot" in gate.data and not gate.data.show-dot { return none }
  if gate.data.open {
    let stroke = b-if-a-is-none(gate.fill, draw-params.wire)
    box(circle(stroke: stroke, fill: draw-params.background, radius: gate.data.size))
  } else {
    box(circle(fill: color, radius: gate.data.size))
  }
}

#let draw-swap(gate, draw-params) = {
  box({
    let d = gate.data.size
    let stroke = draw-params.wire
    box(width: d, height: d, {
      place(line(start: (-0pt,-0pt), end: (d,d), stroke: stroke))
      place(line(start: (d,0pt), end: (0pt,d), stroke: stroke))
    })
  })
}


// Default gate draw function. Draws a box with global padding
// and the gates content. Stroke and default fill are only applied if 
// gate.box is true
#let draw-boxed-gate(gate, draw-params) = align(center, box(
  inset: draw-params.padding, 
  width: gate.width,
  stroke: if gate.box { draw-params.wire }, 
  fill: if gate.fill != none {gate.fill} else if gate.box {draw-params.background}, 
  gate.content,
  radius: gate.radius,
))

// Same but without displaying a box
#let draw-unboxed-gate(gate, draw-params) = box(
  inset: draw-params.padding, 
  fill: if gate.fill != none {gate.fill} else {draw-params.background}, 
  gate.content
)

#let lrstick-size-hint(gate, draw-params) = {
  let content = box(inset: draw-params.padding, gate.content)
  let size = measure(content, draw-params.styles)
  let hint = (
    width1: 4 * draw-params.padding,
    width: 2 * size.width,
    height: size.height,
  )
  return hint
}

// Draw an lstick (align: "right") or rstick (align: "left")
#let draw-lrstick(gate, draw-params, align: none) = {
  assert(align in ("left", "right"), message: "Only left and right are allowed")
  let isleftstick = (align == "right")
  let draw-brace = gate.data.brace != none
    
  let content = box(inset: draw-params.padding, gate.content)
  let size = measure(content, draw-params.styles)
  
 
  let brace = none
  
  if draw-brace {
   let brace-symbol = if gate.data.brace == auto {
        if gate.multi != none { if isleftstick {"{"} else {"}"} }
        } else { gate.data.brace }
    let brace-height
    if gate.multi == none {
      brace-height = 1em + 2 * draw-params.padding
    } else {
      brace-height = draw-params.multi.wire-distance + .5em
    }
    brace = $ lr(#brace-symbol#box(height: brace-height)) $
  }
  
  let brace-size = measure(brace, draw-params.styles)
  let width = size.width + brace-size.width
  let height = size.height
  let brace-offset-y
  let total-offset-y = 0pt
  let content-offset-y = 0pt
  
  if gate.multi == none {
    brace-offset-y = size.height/2 - brace-size.height/2
  } else {
    let dy = draw-params.multi.wire-distance
    // at layout stage:
    if dy == 0pt { return box(width: 2 * width, height: size.height, content) }
    height = dy
    total-offset-y = + size.height/2
    content-offset-y = -total-offset-y + height/2
    brace-offset-y = -.25em
  }
  
  let inset = (:)
  inset.insert(align, width)
  let brace-pos-x = if isleftstick { size.width } else { 0pt }
  let content-pos-x = if isleftstick { 0pt } else { brace-size.width }

  move(dy: total-offset-y,
    box(width: 2 * width, height: height,
    inset: inset, 
      {
        place(brace, dy: brace-offset-y, dx: brace-pos-x)
        place(content, dy: content-offset-y, dx: content-pos-x)
      }
  ))
}

#let draw-nwire(gate, draw-params) = {
  set text(size: .7em)
  let size = measure(gate.content, draw-params.styles)
  let extent = 2.5pt + size.height
  box(height: 2 * extent, { // box is solely for height hint
    place(dx: 1pt, dy: 0pt, gate.content)
    place(dy: extent, line(start: (0pt,-4pt), end: (-5pt,4pt), stroke: draw-params.wire))
  })
}

// Draw a gate spanning multiple wires
#let draw-boxed-multigate(gate, draw-params) = {
  let dy = draw-params.multi.wire-distance
  let extent = if gate.multi.extent == auto {draw-params.x-gate-size.height/2} else {gate.multi.extent}
  let layout-version = box(
      width: gate.width,
      inset: draw-params.padding, 
      stroke: draw-params.wire, 
      fill: if gate.fill != none {gate.fill} else {draw-params.background}, 
      gate.content,
      height: 2 * extent
    )
  if dy == 0pt {
    layout-version
  } else {
    let size = measure(gate.content, draw-params.styles)
    align(center, box(
      width: gate.width,
      height: dy + 2 * extent,
      inset: (x: draw-params.padding, y: dy/2 + extent - size.height/2), 
      radius: gate.radius,
      stroke: draw-params.wire, 
      fill: if gate.fill != none {gate.fill} else {draw-params.background}, 
      gate.content
    ))
  }
}

#let draw-permutation-gate(gate, draw-params) = {
  let dy = draw-params.multi.wire-distance
  let width = gate.width
  if dy == 0pt { return box(width: width, height: 4pt) }
  box(
    height: dy + 4pt,
    inset: (y: 2pt),
    fill: draw-params.background,
    width: width, {
      let qubits = gate.data.qubits
      let y0 = draw-params.center-y-coords.at(gate.qubit)
      for from in range(qubits.len()) {
        let to = qubits.at(from)
        let y-from = draw-params.center-y-coords.at(from + gate.qubit) - y0
        let y-to = draw-params.center-y-coords.at(to + gate.qubit) - y0
        place(path(((0pt,y-from), (-width/2, 0pt)), ((width, y-to), (-width/2, 0pt)), stroke: 3pt + draw-params.background))
        place(path(((-.1pt,y-from), (-width/2, 0pt)), ((width+.1pt, y-to), (-width/2, 0pt)), stroke: draw-params.wire)) 
      }
    }
  )
}

// parameter may be: 
//  - length (will be same for all sides)
//  - dict with keys left, right, top, bottom, default (all optional). Default is for every side that is not specified If no default is given, 0pt is used. 
// returns array with paddings for (left, top, right, bottom). 
#let expand-padding-param(padding) = {
  if type(padding) == "length" { return 4 * (padding, ) }
  let p = 4 * (0pt, )
  if "default" in padding { p = 4 * (padding.default, ) }
  if "left" in padding { p.at(0) = padding.left }
  if "top" in padding { p.at(1) = padding.top }
  if "right" in padding { p.at(2) = padding.right }
  if "bottom" in padding { p.at(3) = padding.bottom }
  return p
}

#let draw-gate-group(corners, item) = {
  let p = item.padding
  let (pl, pt, pr, pb) = expand-padding-param(p)
  let (x1, x2, y1, y2) = (corners.x1 - pl, corners.x2 + pr, corners.y1 - pt, corners.y2 + pb)
  place(dy: y1, dx: x1, rect(
    width: x2 - x1, height: y2 - y1,
    stroke: item.style.stroke,
    fill: item.style.fill,
    radius: item.style.radius
  ))
}

#let draw-meter(gate, draw-params) = {
    let stroke = draw-params.wire
    let fill = if gate.fill != none {gate.fill} else {draw-params.background} 
    let height = draw-params.x-gate-size.height 
    let width = 1.5 * height
    rect(
    width: width, height: height, 
    radius: gate.radius,
    stroke: stroke, fill: fill, 
    inset: 0.22 * height, {
      let center-x = width/2 -.22*height
      place(path((0%,100%), ((50%,40%), (-40%, 0pt)), (100%, 100%), stroke: stroke))
        // place(line(start: (50%, 100%), length: 100%, angle: -70deg, stroke: stroke))
        // place(path((75%, 17%), (86%, -0%), (82%, 26%), closed: true, stroke: stroke))
      draw-arrow((center-x, height*.58), (width*.6, height*.2), length: 3.8pt, width: 2.8pt, stroke: stroke, arrow-color: draw-params.color)
    })
    if gate.data.meter-label != none {
      let label-size = measure(gate.data.meter-label, draw-params.styles)
      place(
      dx: width/2 - label-size.width/2,
      dy: -label-size.height -height - .6em, gate.data.meter-label
      )
    }  
  }

#let default-size-hint(item, draw-params) = {
  let func = item.draw-function
  let hint = measure(func(item, draw-params), draw-params.styles)
  hint.offset = auto
  return hint
}


/// This is the basic command for creating gates. Use this to create a simple gate, e.g., `gate($X$)`. 
/// For special gates, many other dedicated gate commands exist. 
///
/// Note, that most of the parameters listed here are mostly used for derived gate 
/// functions and do not need to be touched in all but very few cases. 
///
/// - content (content): What to show in the gate (may be none for special gates like @@ctrl).
/// - fill (none, color): Gate backgrond fill color.
/// - radius (length, dictionary): Gate rectangle border radius. 
///             Allows the same values as the builtin `rect()` function.
/// - width (auto, length): The width of the gate can be specified manually with this property. 
/// - box (boolean): Whether this is a boxed gate (determines whether the outgoing 
///             wire will be drawn all through the gate (`box: false`) or not).
/// - floating (boolean): Whether the content for this gate will be shown floating 
///             (i.e. no width is reserved).
/// - multi (dictionary): Information for multi-qubit and controlled gates (see @@mqgate() ).
/// - size-hint (function): Size hint function. This function should return a dictionary
///             containing the keys `width` and `height`. The result is used to determine 
///             the gates position and cell sizes of the grid. 
///             Signature: `(gate, draw-params).`
/// - draw-function (function): Drawing function that produces the displayed content.
///             Signature: `(gate, draw-params).`
/// - data (any): Optional additional gate data. This can for example be a dictionary
///             storing extra information that may be used for instance in a custom
///             `draw-function`.
#let gate(
  content,
  fill: none,
  radius: 0pt,
  width: auto,
  box: true,
  floating: false,
  multi: none,
  size-hint: default-size-hint,
  draw-function: draw-boxed-gate,
  gate-type: "",
  data: none
) = (
  content: if type(content) == "content" {content} else { content }, 
  fill: fill,
  radius: radius,
  width: width,
  box: box,
  floating: floating,
  multi: multi,
  size-hint: size-hint,
  draw-function: draw-function,
  gate-type: gate-type, 
  data: data
)



/// Basic command for creating multi-qubit or controlled gates. See also @@ctrl and @@swap. 
///
/// - content (content):
/// - n (integer): Number of wires the multi-qubit gate spans. 
/// - target (none, integer): If specified, a control wire is drawn from the gate up 
///        or down this many wires counted from the wire this `mqgate()` is placed on. 
/// - fill (none, color): Gate backgrond fill color.
/// - radius (length, dictionary): Gate rectangle border radius. 
///        Allows the same values as the builtin `rect()` function.
/// - box (boolean): Whether this is a boxed gate (determines whether the 
///        outgoing wire will be drawn all through the gate (`box: false`) or not).
/// - label (content): Optional label on the vertical wire. 
/// - wire-count (integer): Wire count for control wires.
/// - extent (auto, length): How much to extent the gate beyond the first and 
///        last wire, default is to make it align with an X gate (so [size of x gate] / 2). 
/// - size-all-wires (none, boolean): A single-qubit gate affects the height of the row
///        it is being put on. For multi-qubit gate there are different possible 
///        behaviours:
///          - Affect height on only the first and last wire (`false`)
///          - Affect the height of all wires (`true`)
///          - Affect the height on no wire (`none`)
/// - data (any): Optional additional gate data. This can for example be a dictionary
///        storing extra information that may be used for instance in a custom
///        `draw-function`.
#let mqgate(
  content,
  n: 1, 
  target: none,
  fill: none, 
  radius: 0pt,
  box: true, 
  label: none, 
  width: auto,
  wire-count: 1,
  extent: auto, 
  size-all-wires: false,
  draw-function: draw-boxed-multigate, 
  data: none,
) = gate(
  content, 
  fill: fill, box: box, 
  width: width,
  radius: radius,
  draw-function: draw-function,
  multi: (
    target: target,
    num-qubits: n, 
    wire-count: wire-count, 
    label: label,
    extent: extent,
    size-all-wires: size-all-wires
  ),
  data: data
)


// align: "left" (for rstick) or "right" (for lstick)
// brace: auto, none, "{", "}", "|", "[", ...
#let lrstick(content, n, align, brace) = gate(
  content, 
  draw-function: draw-lrstick.with(align: align), 
  // size-hint: lrstick-size-hint,
  box: false, 
  floating: true,
  multi: if n == 1 { none } else { 
   (
    target: none,
    num-qubits: n, 
    wire-count: 0, 
    label: label,
    size-all-wires: if n > 1 { none } else { false }
  )},
  data: (brace: brace), 
)


// SPECIAL GATES

/// Draw a meter box representing a measurement. 
/// - target (none, integer): If given, draw a control wire to the given target
///                           qubit the specified number of wires up or down.
/// - wire-count (integer):   Wire count for the (optional) control wire. 
/// - n (integer):            Number of wires to span this meter across. 
/// - label (content):        Label to show above the meter. 
#let meter(target: none, n: 1, wire-count: 2, label: none,
  fill: none, 
  radius: 0pt) = {
  if target == none and n == 1 {
    gate(none, fill: fill, radius: radius, draw-function: draw-meter, data: (meter-label: label))
  } else {
     mqgate(none, n: n, target: target, fill: fill, radius: radius, box: true, wire-count: wire-count, draw-function: draw-meter, data: (meter-label: label))
  }
}

/// Create a visualized permutation gate which maps the qubits $q_k, q_(k+1), ... $ to  
/// the qubits $q_(p(k)), q_(p(k+1)), ...$ when placed on the qubit $k$. The permutation 
/// map is given by the `qubits` argument. Note, that qubit indices start with 0. 
/// 
/// *Example:*
///
///  `permute(1, 0)` when placed on the second wire swaps the second and third wire. 
/// 
///  `permute(2, 0, 1)` when placed on wire 0 maps $(0,1,2) arrow.bar (2,0,1)$.
/// 
/// Note also, that the wiring is not very sophisticated and will probably look best for 
/// relatively simple permutations. Furthermore, it only works with quantum wires. 
///  
/// - ..qubits (array): Qubit permutation specification. 
/// - width (length): Width of the permutation gate. 
/// 
#let permute(..qubits, width: 30pt) = {
  mqgate(none, n: qubits.pos().len(), width: width, draw-function: draw-permutation-gate, data: (qubits: qubits.pos(), extent: 2pt))
}

/// Create an invisible (phantom) gate for reserving space. If `content` 
/// is provided, the `height` and `width` parameters are ignored and the gate 
/// will take the size it would have if `gate(content)` was called. 
///
/// Instead specifying width and/or height will create a gate with exactly the
/// given size (without padding).
///
/// - content (content): Content to measure for the phantom gate size. 
/// - width (length): Width of the phantom gate (ignored if `content` is not `none`). 
/// - height (length): Height of the phantom gate (ignored if `content` is not `none`). 
#let phantom(content: none, width: 0pt, height: 0pt) = {
  let thecontent = if content != none { box(hide(content)) } else { 
    let w = height
    if type(w) in ("content", "string") { }
    box(width: width, height: height) 
  }
  gate(thecontent, box: false, fill: none)
}

/// Target element for controlled #smallcaps("x") operations (#sym.plus.circle). 
/// - fill (none, color, boolean): Fill color for the target circle. If set 
///        to `true`, the target is filled with the circuits background color.
/// - size (length): Size of the target symbol. 
#let targ(fill: none, size: 4.3pt) = gate(none, box: false, draw-function: draw-targ, fill: fill, data: (size: size))

/// Target element for controlled #smallcaps("z") operations (#sym.bullet). 
///
/// - open (boolean): Whether to draw an open dot. 
/// - fill (none, color): Fill color for the circle or stroke color if
///        `open: true`. 
/// - size (length): Size of the control circle. 
// #let ctrl(open: false, fill: none, size: 2.3pt) = gate(none, draw-function: draw-ctrl, fill: fill, size: size, box: false, open: open)

/// Target element for #smallcaps("swap") operations (#sym.times) without vertical wire). 
/// - size (length): Size of the target symbol. 
#let targX(size: 7pt) = gate(none, box: false, draw-function: draw-swap, data: (size: size))

/// Create a phase gate shown as a point on the wire together with a label. 
///
/// - label (content): Angle value to display. 
/// - open (boolean): Whether to draw an open dot. 
/// - fill (none, color): Fill color for the circle or stroke color if
///        `open: true`. 
/// - size (length): Size of the circle. 
#let phase(label, open: false, fill: none, size: 2.3pt) = gate(
  none, 
  box: false,
  draw-function: (gate, draw-params) => {
      box(inset: (x: .6em), draw-ctrl(gate, draw-params))
      place(label, dy: -1.2em, dx: 1.2em)
    },
  fill: fill,
  data: (open: open, size: size)
)




/// Basic command for labelling a wire at the start. 
/// - content (content): Label to display, e.g., `$|0〉$`.
/// - n (content): How many wires the `lstick` should span. 
/// - brace (auto, none, string): If `brace` is `auto`, then a default `{` brace
///      is shown only if `n > 1`. A brace is always shown when 
///      explicitly given, e.g., `"}"`, `"["` or `"|"`. No brace is shown for 
///      `brace: none`. 
#let lstick(content, n: 1, brace: auto) = lrstick(content, n, "right", brace)


/// Basic command for labelling a wire at the end. 
/// - content (content): Label to display, e.g., `$|0〉$`.
/// - n (content): How many wires the `rstick` should span. 
/// - brace (auto, none, string): If `brace` is `auto`, then a default `}` brace
///      is shown only if `n > 1`. A brace is always shown when 
///      explicitly given, e.g., `"}"`, `"["` or `"|"`. No brace is shown for 
///      `brace: none`. 
#let rstick(content, n: 1, brace: auto) = lrstick(content, n, "left", brace)

/// Create a midstick
#let midstick(content) = gate(content, draw-function: draw-unboxed-gate)



/// Creates a symbol similar to `\qwbundle` on `quantikz`. Annotates a wire to 
/// be a bundle of quantum or classical wires. 
/// - label (integer, content): 
#let nwire(label) = gate([#label], draw-function: draw-nwire, box: false)

/// Create a controlled gate. See also @@ctrl. This function however
/// may be used to create controlled gates where a gate box is at both ends
/// of the control wire. 
/// 
/// *Example: *
/// `controlled($H$, 2)`. 
/// 
/// - content (content): Gate content to display.
/// - n (integer): How many wires up or down the target wire lives. 
/// - wire-count (integer): Wire count for the control wire.  
/// - draw-function (function). See @@gate. 
/// - ..args (array): Optional, additional arguments to be stored in the gate. 
// #let controlled(content, n, wire-count: 1, draw-function: draw-boxed-gate, ..args) = mqgate(content, target: n, wire-count: wire-count, draw-function: draw-function, ..args)

/// Creates a #smallcaps("swap") operation with another qubit. 
/// 
/// - n (integer): How many wires up or down the target wire lives. 
/// - size (length): Size of the target symbol. 
#let swap(n, size: 7pt) = mqgate(none, target: n, box: false, draw-function: draw-swap, data: (size: size))

/// Creates a control with a vertical wire to another qubit. 
/// 
/// - n (integer): How many wires up or down the target wire lives. 
/// - wire-count (integer): Wire count for the control wire.  
/// - open (boolean): Whether to draw an open dot. 
/// - fill (none, color): Fill color for the circle or stroke color if
///        `open: true`. 
/// - size (length): Size of the control circle. 
/// - show-dot (boolean): Whether to show the control dot. Set this to 
///        false to obtain a vertical wire with no dots at all. 
#let ctrl(n, wire-count: 1, open: false, fill: none, size: 2.3pt, show-dot: true) = mqgate(none, target: n, draw-function: draw-ctrl, wire-count: wire-count, fill: fill, data: (open: open, size: size, show-dot: show-dot))




// META INSTRUCTIONS

/// Set current wire mode (0: none, 1 wire: quantum, 2 wires: classical, more  
/// are possible) and optionally the stroke style. 
///
/// The wire style is reset for each row.
///
/// - wire-count (integer): Number of wires to display. 
/// - stroke (none, stroke): When given, the stroke is applied to the wire. 
///                Otherwise the current stroke is kept. 
/// - wire-distance (length): Distance between wires. 
#let setwire(wire-count, stroke: none, wire-distance: 1pt) = (
  qc-instr: "setwire",
  wire-count: wire-count,
  stroke: stroke,
  wire-distance: wire-distance
)

/// Highlight a group of circuit elements by drawing a rectangular box around
/// them. 
/// 
/// - wires (integer): Number of wires to include.
/// - steps (integer): Number of columns to include.
/// - padding (length, dictionary): Padding of rectangle. May be one length
///     for all sides or a dictionary with the keys `left`, `right`, `top`, 
///     `bottom` and `default`. Not all keys need to be specified. The value 
///     for `default` is used for the omitted sides or `0pt` if no `default` 
///     is given. 
/// - stroke (stroke): Stroke for rectangle.
/// - fill (color): Fill color for rectangle.
/// - radius (length, dictionary): Corner radius for rectangle.
#let gategroup(
  wires, 
  steps, 
  padding: 0pt, 
  stroke: .7pt, 
  fill: none,
  radius: 0pt  
) = (
  qc-instr: "gategroup",
  wires: wires,
  steps: steps,
  padding: padding,
  style: (fill: fill, stroke: stroke, radius: radius)
)

/// Slice the circuit vertically, showing a separation line between columns. 
/// 
/// - wires (integer): Number of wires to slice.
/// - label (content): Label for the slice. 
/// - stroke (stroke): Line style for the slice. 
#let slice(
  wires: 0, 
  label: none,
  stroke: (paint: red, thickness: .7pt, dash: "dashed"),
  dx: 0pt,
  dy: 0pt
) = (
  qc-instr: "slice",
  wires: wires,
  label: label,
  dx: dx, dy: dy,
  style: (stroke: stroke)
)

/// Lower-level interface to the cell coordinates to create an arbitrary
/// annotatation by passing a custom function.
/// 
/// This function is passed the coordinates of the specified cell rows 
/// and columns. 
/// 
/// - rows (integer, array): Row indices for which to obtain coordinates. 
/// - columns (integer, array): Column indices for which to obtain coordinates. 
/// - callback (function): Function to call with the obtained coordinates. The
///     signature should be with signature `(row-coords, col-coords) => {}`. 
///     This function is expected to display the content to draw in absolute 
///     coordinates within the circuit. 
#let annotate(
  rows,
  columns,
  callback 
) = (
  qc-instr: "annotate",
  rows: rows,
  columns: columns,
  callback: callback
)



// Get content from a gate or plain content item
#let get-content(item, draw-params) = {
  if is-gate(item) { 
    if item.draw-function != none {
      let func = item.draw-function
      return func(item, draw-params)
    }
  } else { return item }
}

// Get size hint for a gate or plain content item
#let get-size-hint(item, draw-params) = {
  if is-gate(item) { 
    let func = item.size-hint
    return func(item, draw-params) 
  } 
  measure(item, draw-params.styles)
}


// From a list of row heights or col widths, compute the respective
// cell center coordinates, e.g., (3pt, 3pt, 4pt) -> (1.5pt, 4.5pt, 8pt)
#let compute-center-coords(cell-lengths, gutter) = {
  let center-coords = ()
  let tmpx = 0pt
  gutter.insert(0, 0pt)
  // assert.eq(cell-lengths.len(), gutter.len())
  for (cell-length, g) in cell-lengths.zip(gutter) {
    center-coords.push(tmpx + cell-length / 2 + g)
    tmpx += cell-length + g
  }
  return center-coords
} 

// Given a list of n center coordinates in and n cell sizes along one axis (x or y), retrieve the coordinates for a single cell or a list of cells given by index. 
// If a cell index is out of bounds, the outer last coordinate is returned
// center-coords: List of center coordinates for each index
// cell-sizes: List of cell sizes for each index
// cells: Indices of cell for which to retrieve coordinates
// mode: "center" or "start"
#let obtain-cell-coords(center-coords, cell-sizes, cells, mode) = {
  assert(mode in ("center", "start", "end"), message:"Only \"center\", \"start\" and \"end\" are allowed for cell coordinate mode")
  let last = center-coords.at(-1) + cell-sizes.at(-1) / 2
  let get(x) = { 
    let coord = center-coords.at(x, default: last)
    if mode == "start" { coord -= cell-sizes.at(x, default: 0pt)/2 }
    if mode == "end" { coord += cell-sizes.at(x, default: 0pt)/2 }
    return coord
  }
  if type(cells) == "integer" { get(cells)  }
  else if type(cells) == "array" { cells.map(x => get(x)) }
  else { panic("Unsupported coordinate type") }
}

// Given a list of n center coordinates in and n cell sizes along one axis (x or y), retrieve the coordinates for a single cell or a list of cells given by index. 
// If a cell index is out of bounds, the outer last coordinate is returned
// center-coords: List of center coordinates for each index
// cell-sizes: List of cell sizes for each index
// cells: Indices of cell for which to retrieve coordinates
// These may also be floats. In this case, the integer part determines the cell index and the fractional part a percentage of the cell width. e.g., passing 2.5 would return the center coordinate of the cell
#let obtain-cell-coords1(center-coords, cell-sizes, cells) = {
  let last = center-coords.at(-1) + cell-sizes.at(-1) / 2
  let get(x) = { 
    let integral = calc.floor(x)
    let fractional = x - integral
    let cell-width = cell-sizes.at(integral, default: 0pt)
    return center-coords.at(integral, default: last) + cell-width * (fractional - 0.5)
  }
  if type(cells) in ("integer", "float") { get(cells)  }
  else if type(cells) == "array" { cells.map(x => get(x)) }
  else { panic("Unsupported coordinate type") }
}


#let draw-horizontal-wire(x1, x2, y, stroke, wire-count, wire-distance: 1pt) = {
  if x1 == x2 { return }
  for i in range(wire-count) {
    place(line(start: (x1, y), end: (x2, y), stroke: stroke), 
      dy: (2*i - (wire-count - 1)) * wire-distance)
  }
}

#let draw-vertical-wire(y1, y2, x, stroke, wire-count: 1, wire-distance: 1pt) = {
  for i in range(wire-count) {
    place(line(start: (x, y1), end: (x, y2), stroke: stroke), 
      dx: (2*i - int(wire-count/2)) * wire-distance)
  }
}

/// Create a quantum circuit diagram. Content items may be
/// - Gates created by one of the many gate commands (@@gate, 
///   @@mqgate, @@meter, ...)
/// - `[\ ]` for creating a new wire/row 
/// - Commands like @@setwire or @@gategroup
/// - Integers for creating cells filled with the current wire setting 
/// - Lengths for creating space between rows or columns 
/// - Plain content or strings to be placed on the wire 
/// - @@lstick, @@midstick or @@rstick for placement next to the wire 
///
/// - wire (stroke): Style for drawing the circuit wires. This can take anything 
///            that is valid for the stroke of the builtin `line()` function. 
/// - row-spacing (length): Spacing between rows.
/// - column-spacing (length): Spacing between columns.
/// - min-row-height (length): Minimum height of a row (e.g., when no 
///             gates are given).
/// - min-column-width (length): Minimum width of a column.
/// - gate-padding (length): General padding setting including the inset for 
///            gate boxes and the distance of @@lstick and co. to the wire. 
/// - equal-row-heights (boolean): If true, then all rows will have the same 
///            height and the wires will have equal distances orienting on the
///            highest row. 
/// - color (color): Foreground color, default for strokes, text, controls
///            etc. If you want to have dark-themed circuits, set this to white  
///            for instance and update `wire` and `fill` accordingly.           
/// - fill (color): Default fill color for gates. 
/// - font-size (length): Default font size for text in the circuit. 
/// - scale-factor (relative length): Total scale factor applied to the entire 
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
/// - ..content (array): Items, gates and circuit commands (see description). 
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
  scale-factor: 100%,
  baseline: 0pt,
  circuit-padding: none,
  ..content
) = { 
  if content.pos().len() == 0 { return }
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
    multi: (wire-distance: 0pt)
  )

  draw-params.x-gate-size = default-size-hint(gate($X$), draw-params)
  
  let items = content.pos()
  /////////// First pass: Layout (spacing)   ///////////
  
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
    } else if is-circuit-meta-instruction(item) { 
    } else if is-circuit-drawable(item) {
      let isgate = is-gate(item)
      if isgate { item.qubit = row }
      let ismulti = isgate and item.multi != none
      let size = get-size-hint(item, draw-params)
      
      let width = size.width 
      let height = size.height
      if is-gate(item) and item.floating { width = 0pt }

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
  let center-x-coords = compute-center-coords(colwidths, col-gutter)
  let center-y-coords = compute-center-coords(rowheights, row-gutter)
  draw-params.center-y-coords = center-y-coords
  
  (row, col) = (0, 0)
  let (x, y) = (0pt, 0pt) // current cell top-left coordinates
  let center-y = y + rowheights.at(row) / 2 // current cell center y-coordinate
  let circuit-width = colwidths.sum() + col-gutter.slice(0, -1).sum(default: 0pt)
  let circuit-height = rowheights.sum() + row-gutter.sum()

  let wire-count = 1
  let wire-distance = 1pt
  let wire-stroke = wire
  let prev-wire-x = center-x-coords.at(0)
  let (extra-top, extra-bottom) = (0pt, 0pt)
  let (extra-left, extra-right) = (0pt, 0pt)

  /////////// Second pass: Generation ///////////
  
  let circuit = block(
    width: circuit-width, height: circuit-height, {
    set align(top + left) // qcircuit could be called in a scope where these have been changed which would mess up everything

    let to-be-drawn-later = () // dicts with content, x and y
      
    for item in items {
      if item == [\ ]{
        y += rowheights.at(row)
        row += 1
        center-y = center-y-coords.at(row)
        col = 0; x = 0pt
        wire-count = 1; wire-stroke = wire
        prev-wire-x = center-x-coords.at(0)
        
      } else if is-circuit-meta-instruction(item) {
        if item.qc-instr == "setwire" {
          wire-count = item.wire-count
          wire-distance = item.wire-distance
          if item.stroke != none { wire-stroke = item.stroke }
        } else if item.qc-instr == "gategroup" {
          assert(item.wires > 0, message: "gategroup: wires arg needs to be > 0")
          assert(row+item.wires <= rowheights.len(), message: "gategroup: height exceeds range")
          assert(item.steps > 0, message: "gategroup: steps arg needs to be > 0")
          assert(col+item.steps <= colwidths.len(), message: "gategroup: width exceeds range")
          let y1 = obtain-cell-coords1(center-y-coords, rowheights, row)
          let y2 = obtain-cell-coords1(center-y-coords, rowheights, row + item.wires)
          let x1 = obtain-cell-coords1(center-x-coords, colwidths, col)
          let x2 = obtain-cell-coords1(center-x-coords, colwidths, col + item.steps - 1e-9)
          // let y1 = rowheights.slice(0, row).sum(default: 0pt)
          // let y2 = rowheights.slice(0, row + item.wires).sum(default: 0pt)
          // let x1 = colwidths.slice(0, col).sum(default: 0pt)
          // let x2 = colwidths.slice(0, col + item.steps).sum(default: 0pt)
          draw-gate-group((x1: x1, x2: x2, y1: y1, y2: y2), item)
        } else if item.qc-instr == "slice" {
          assert(item.wires >= 0, message: "slice: wires arg needs to be > 0")
          assert(row+item.wires <= rowheights.len(), message: "slice: height exceeds range")
          let end = if item.wires == 0 {rowheights.len()} else {row+item.wires}
          let y1 = obtain-cell-coords1(center-y-coords, rowheights, row)
          let y2 = obtain-cell-coords1(center-y-coords, rowheights, end)
          let x = obtain-cell-coords1(center-x-coords, colwidths, col)          // let y1 = rowheights.slice(0, row).sum(default: 0pt)
          // let y2 = rowheights.slice(0, end).sum(default: 0pt)
          // let x = colwidths.slice(0, col).sum(default: 0pt)
          place(line(
            start: (x, y1),
            end: (x, y2),
            stroke: item.style.stroke
          ))
          if item.label != none {
            let size = measure(item.label, styles)
            let y = y1 - (size.height + 5pt)
            extra-top = calc.max(extra-top, -y)
            place(dx: x - size.width/2, dy: y, item.label)
          }
        } else if item.qc-instr == "annotate" {
          let rows = obtain-cell-coords1(center-y-coords, rowheights, item.rows)
          let cols = obtain-cell-coords1(center-x-coords, colwidths, item.columns)
          place((item.callback)(rows, cols))
        }
      // ---------------------------- Gates & Co. ------------------------------
      } else if is-circuit-drawable(item) {
        let center-x = center-x-coords.at(col)
        
        let isgate = is-gate(item)
        let do-draw-later = true
        
        // let content = get-content(item, draw-params)  
        // let size = measure(content, styles)
        let size = get-size-hint(item, draw-params)
        
        let top = center-y - size.height / 2
        let bottom = center-y + size.height / 2
  

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
              let (y1, y2) = ((bottom, top).at(int(item.multi.target < 1)), center-y-coords.at(target-qubit))
              draw-vertical-wire(
                y1, 
                y2, 
                center-x, 
                wire, 
                wire-count: item.multi.wire-count)
            } 
            let nq = item.multi.num-qubits
            if nq > 1 {
              assert(row + nq -1 < center-y-coords.len(), message: "Target 
              qubit for multi qubit gate does not exist")
              let y1 = center-y-coords.at(row + nq - 1)
              let y2 = center-y-coords.at(row)
              draw-params.multi.wire-distance = y1 - y2
              // content = get-content(item, draw-params)
              let func = item.size-hint
              size.width = func(item, draw-params).width
              do-draw-later = true
            }
            
          }
        }
        
        let current-wire-x = center-x
        draw-horizontal-wire(prev-wire-x, current-wire-x, center-y, wire-stroke, wire-count, wire-distance: wire-distance)
        if isgate and item.box { prev-wire-x = center-x + size.width / 2 } 
        else { prev-wire-x = current-wire-x }
        
        extra-left = calc.max(-(center-x - size.width/2), extra-left)
        extra-right = calc.max(center-x + size.width/2 - circuit-width, extra-right)

        let x-pos = center-x
        let y-pos = center-y
        let offset = size.at("offset", default: auto)
        if offset == auto {
          x-pos -= size.width / 2
          y-pos -= size.height / 2
        } else if type(offset) == "dictionary" {
          let offset-x = offset.at("x", default: auto)
          let offset-y = offset.at("x", default: auto)
          if offset-x == auto { x-pos -= size.width / 2}
          else if type(offset-x) == "length" { x-pos -= offset-x }
          if offset-y == auto { y-pos -= size.width / 2}
          else if type(offset-y) == "length" { y-pos -= offset-y }
        }
        
        let content = get-content(item, draw-params)
        if do-draw-later {
          to-be-drawn-later.push((content: content, x: x-pos, y: y-pos))
        } else {
          place(
            dx: x-pos, dy: y-pos, 
            if isgate { content } else { box(content) }
          )
        }
          
        x += colwidths.at(col)
        col += 1
        draw-params.multi.wire-distance = 0pt
      } else if type(item) == "integer" {
        col += item
        // let t = col
        // if col == center-x-coords.len() { t -= 1}
        let center-x = center-x-coords.at(col - 1)
        draw-horizontal-wire(prev-wire-x, center-x, center-y, wire-stroke, wire-count, wire-distance: wire-distance)
        prev-wire-x = center-x
      }
      
    } // end loop over items

    for item in to-be-drawn-later {
      place(dx: item.x, dy: item.y, item.content)
    }
  }) // end circuit = block(..., {
    
  /////////// END Second pass: Generation ///////////

  
  let scale-float = float(repr(scale-factor).slice(0,-1))  * 0.01
  if circuit-padding != none {
    extra-left += circuit-padding.at("left", default: 0pt)
    extra-top += circuit-padding.at("top", default: 0pt)
    extra-right += circuit-padding.at("right", default: 0pt)
    extra-bottom += circuit-padding.at("bottom", default: 0pt)
  }
  let height = scale-float * (circuit-height + extra-bottom + extra-top)
  
  let thebaseline = baseline
  if type(thebaseline) in ("content", "string") {
    thebaseline = height/2 - measure(thebaseline, styles).height/2
  }
  box(baseline: thebaseline,
    width: scale-float * (circuit-width + extra-left + extra-right), 
    height: scale-float * (circuit-height + extra-bottom + extra-top), 
    // fill: background,
    // stroke: 1pt + gray,
    move(dy: scale-float * extra-top, dx: scale-float * extra-left, 
      scale(
        x: scale-factor, 
        y: scale-factor, 
        origin: left + top, 
        circuit
    ))
  )
  
})
}