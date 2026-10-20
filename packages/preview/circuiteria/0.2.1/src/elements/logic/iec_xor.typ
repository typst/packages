#import "/src/cetz.typ": draw
#import "iec_gate.typ" as iec-gate

/// Draws an IEC-XOR gate. This function is also available as `element.iec-gate-xor()`
/// 
/// For parameters, see #doc-ref("gates.iec-gate")
/// #examples.iec-gate-xor
#let iec-gate-xor(
  x: none,
  y: none,
  w: none,
  h: none,
  inputs: 2,
  fill: none,
  stroke: black + 1pt,
  id: "",
  inverted: (),
  debug: (
    ports: false
  )
) = {
  iec-gate.iec-gate(
    x: x,
    y: y,
    w: w,
    h: h,
    inputs: inputs,
    fill: fill,
    stroke: stroke,
    id: id,
    inverted: inverted,
    debug: debug,
    symbol: $= 1$,
  )
}

/// Draws an IEC-XNOR gate. This function is also available as `element.iec-gate-xnor()`
/// 
/// For parameters, see #doc-ref("gates.iec-gate")
/// #examples.iec-gate-xnor
#let iec-gate-xnor(
  x: none,
  y: none,
  w: none,
  h: none,
  inputs: 2,
  fill: none,
  stroke: black + 1pt,
  id: "",
  inverted: (),
  debug: (
    ports: false
  )
) = {
  iec-gate-xor(
    x: x,
    y: y,
    w: w,
    h: h,
    inputs: inputs,
    fill: fill,
    stroke: stroke,
    id: id,
    inverted: if inverted != "all" {inverted + ("out",)} else {inverted},
    debug: debug
  )
}