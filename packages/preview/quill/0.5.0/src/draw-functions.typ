// INTERNAL GATE DRAW FUNCTIONS


#import "utility.typ"
#import "arrow.typ"
#import "layout.typ"






// Default gate draw function. Draws a box with global padding
// and the gates content. Stroke and default fill are only applied if 
// gate.box is true
#let draw-boxed-gate(gate, draw-params) = align(center, box(
  inset: draw-params.padding, 
  width: gate.width,
  radius: gate.radius,
  stroke: if gate.box { draw-params.wire }, 
  fill: utility.if-auto(gate.fill, if gate.box {draw-params.background}),
  gate.content,
))

// Same but without displaying a box
#let draw-unboxed-gate(gate, draw-params) = box(
  inset: draw-params.padding, 
  fill: utility.if-auto(gate.fill, draw-params.background),
  gate.content
)

// Draw a gate spanning multiple wires
#let draw-boxed-multigate(gate, draw-params) = {
  let dy = draw-params.multi.wire-distance
  let extent = gate.multi.extent
  if extent == auto { extent = draw-params.x-gate-size.height / 2 }
  
  let style-params = (
      width: gate.width,
      stroke: utility.if-auto(gate.stroke, draw-params.wire), 
      radius: gate.radius,
      fill: utility.if-auto(gate.fill, draw-params.background), 
      inset: draw-params.padding, 
  )
  align(center + horizon, box(
    ..style-params,
    height: dy + 2 * extent,
    gate.content
  ))
  
  
  let draw-inouts(inouts, alignment) = {
    
    if inouts != none and dy != 0pt {
      let width = measure(line(length: gate.width)).width
      let y0 = -(dy + extent) - draw-params.center-y-coords.at(0)
      let get-wire-y(qubit) = { draw-params.center-y-coords.at(qubit) + y0 }
      
      set text(size: .8em)
      context {
        for inout in inouts {
          let size = measure(inout.label)
          let y = get-wire-y(inout.qubit)
          let label-x = draw-params.padding
          if "n" in inout and inout.n > 1 {
            let y2 = get-wire-y(inout.qubit + inout.n - 1)
            let brace = utility.create-brace(auto, alignment, y2 - y + draw-params.padding)
            let brace-x = 0pt
            let size = measure(brace)
            if alignment == right { brace-x += width - size.width }
            
            place(brace, dy: y - 0.5 * draw-params.padding, dx: brace-x)
            label-x = size.width
            y += 0.5 * (y2 - y)
          }
          place(dy: y - size.height / 2, align(
            alignment, 
            box(inout.label, width: width, inset: (x: label-x))
          ))
        }
      }
      
    }
  
  }
  draw-inouts(gate.multi.inputs, left)
  draw-inouts(gate.multi.outputs, right)
}

#let draw-targ(item, draw-params) = {
  let size = item.data.size
  box({
    circle(
      radius: size, 
      stroke: draw-params.wire, 
      fill: utility.if-auto(item.fill, draw-params.background)
    )
    place(line(start: (size, 0pt), length: 2*size, angle: -90deg, stroke: draw-params.wire))
    place(line(start: (0pt, -size), length: 2*size, stroke: draw-params.wire))
  })
}

#let draw-ctrl(gate, draw-params) = {
  let color = utility.if-auto(gate.fill, draw-params.color)
  if "show-dot" in gate.data and not gate.data.show-dot { return none }
  if gate.data.open {
    let stroke = utility.if-auto(gate.fill, draw-params.wire)
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
      place(line(start: (-0pt, -0pt), end: (d, d), stroke: stroke))
      place(line(start: (d, 0pt), end: (0pt, d), stroke: stroke))
    })
  })
}



#let draw-meter(gate, draw-params) = {
  let content = {
    set align(top)
    let stroke = draw-params.wire
    let padding = draw-params.padding
    let fill = utility.if-none(gate.fill, draw-params.background)
    let height = draw-params.x-gate-size.height 
    let width = 1.5 * height
    height -= 2 * padding
    width -= 2 * padding
    box(
      width: width, height: height, inset: 0pt, 
      {
        let center-x = width / 2
        place(path((0%, 110%), ((50%, 40%), (-40%, 0pt)), (100%, 110%), stroke: stroke))
        set align(left)
        arrow.draw-arrow((center-x, height * 1.2), (width * .9, height*.3), length: 3.8pt, width: 2.8pt, stroke: stroke, arrow-color: draw-params.color)
    })
  }
  gate.content = rect(content, inset: 0pt, stroke: none)
  if gate.multi != none and gate.multi.num-qubits > 1 {
    draw-boxed-multigate(gate, draw-params)
  } else {
    draw-boxed-gate(gate, draw-params)
  }
}


#let draw-nwire(gate, draw-params) = {
  set text(size: .7em)
  let size = measure(gate.content)
  let extent = 2.5pt + size.height
  box(height: 2 * extent, { // box is solely for height hint
    place(dx: 1pt, dy: 0pt, gate.content)
    place(dy: extent, line(start: (0pt,-4pt), end: (-5pt,4pt), stroke: draw-params.wire))
  })
}



#let draw-permutation-gate(gate, draw-params) = {
  let dy = draw-params.multi.wire-distance
  let width = gate.width
  if dy == 0pt { return box(width: width, height: 4pt) }
  
  let separation = gate.data.separation
  if separation == auto { separation = draw-params.background }
  if type(separation) == color { separation += 3pt }
  if type(separation) == length { separation += draw-params.background }
  
  box(
    height: dy + 4pt,
    inset: (y: 2pt),
    fill: draw-params.background,
    width: width, {
      let qubits = gate.data.qubits
      let y0 = draw-params.center-y-coords.at(gate.qubit)
      let bend = gate.data.bend * width / 2
      for from in range(qubits.len()) {
        let to = qubits.at(from)
        let y-from = draw-params.center-y-coords.at(from + gate.qubit) - y0
        let y-to = draw-params.center-y-coords.at(to + gate.qubit) - y0
        if separation != none {
          place(path(((0pt,y-from), (-bend, 0pt)), ((width, y-to), (-bend, 0pt)), stroke: separation))
        }
        place(path(((-.1pt,y-from), (-bend, 0pt)), ((width+.1pt, y-to), (-bend, 0pt)), stroke: draw-params.wire)) 
      }
    }
  )
}

// Draw an lstick (align: "right") or rstick (align: "left")
#let draw-lrstick(gate, draw-params) = {

  assert(gate.data.align in (left, right), message: "`lstick`/`rstick`: Only left and right are allowed for parameter align")
    
  let content = box(inset: draw-params.padding, gate.content)
  let size = measure(content)
  let brace = none
  
  if gate.data.brace != none {
    let brace-height
    if gate.multi == none {
      brace-height = 1em + 2 * draw-params.padding
    } else {
      brace-height = draw-params.multi.wire-distance + .5em
    }
    let brace-symbol = gate.data.brace
    if brace-symbol == auto and gate.multi == none {
      brace-symbol = none
    }
    brace = utility.create-brace(brace-symbol, gate.data.align, brace-height)
  }
  
  let brace-size = measure(brace)
  let width = size.width + brace-size.width + gate.data.pad
  let height = size.height
  let brace-offset-y
  let content-offset-y = 0pt
  
  if gate.multi == none {
    brace-offset-y = size.height / 2 - brace-size.height / 2
  } else {
    let dy = draw-params.multi.wire-distance
    // at first (layout) stage:
    if dy == 0pt { return box(width: 2 * width, height: 0pt, content) }
    height = dy
    content-offset-y = -size.height / 2 + height / 2
    brace-offset-y = -.25em
  }
  
  let brace-pos-x = if gate.data.align == right { size.width } else { gate.data.pad }
  let content-pos-x = if gate.data.align == right { 0pt } else { width - size.width }

  box(
    width: width, 
    height: height, 
    {
      place(brace, dy: brace-offset-y, dx: brace-pos-x)
      place(content, dy: content-offset-y, dx: content-pos-x)
    }
  )
}




#let draw-gategroup(x1, x2, y1, y2, item, draw-params) = {
  let p = item.padding
  let (x1, x2, y1, y2) = (x1 - p.left, x2 + p.right, y1 - p.top, y2 + p.bottom)
  let size = (width: x2 - x1, height: y2 - y1)
  layout.place-with-labels(
    dx: x1, dy: y1, 
    labels: item.labels, 
    size: size,
    draw-params: draw-params, rect(
      width: size.width, height: size.height,
      stroke: item.style.stroke,
      fill: item.style.fill,
      radius: item.style.radius
    )
  )
}

#let draw-slice(x, y1, y2, item, draw-params) = layout.place-with-labels(
  dx: x, dy: y1, 
  size: (width: 0pt, height: y2 - y1),
  labels: item.labels, 
  draw-params: draw-params, 
  line(angle: 90deg, length: y2 - y1, stroke: item.style.stroke)
)



#let draw-horizontal-wire(x1, x2, y, stroke, wire-count, wire-distance: 1pt) = {
  if x1 == x2 { return }

  let wire = line(start: (x1, y), end: (x2, y), stroke: stroke)
  range(wire-count)
    .map(i => (2*i - (wire-count - 1)) * wire-distance)
    .map(dy => place(wire, dy: dy))
    .join()
}

#let draw-vertical-wire(
  y1, 
  y2,
  x,
  stroke,
  wire-count: 1,
  wire-distance: 1pt,
) = {
  let height = y2 - y1

  let wire = line(start: (0pt, 0pt), end: (0pt, height), stroke: stroke)
  let wires = range(wire-count)
    .map(i => 2 * i * wire-distance)
    .map(dx => place(wire, dx: dx))

  place(
    dx: x - (wire-count - 1) * wire-distance,
    dy: y1,
    wires.join()
  )
}

#let draw-vertical-wire-with-labels(
  y1, 
  y2,
  x,
  stroke,
  wire-count: 1,
  wire-distance: 1pt,
  wire-labels: (),
  draw-params: none,
) = {
  let height = y2 - y1
  
  let wire = line(start: (0pt, 0pt), end: (0pt, height), stroke: stroke)
  let wires = range(wire-count)
    .map(i => 2 * i * wire-distance)
    .map(dx => place(wire, dx: dx))

  layout.place-with-labels(
    dx: x - (wire-count - 1) * wire-distance,
    dy: y1,
    labels: wire-labels,
    draw-params: draw-params,
    size: (width: 2 * (wire-count - 1) * wire-distance, height: height),
    wires.join()
  )
}
