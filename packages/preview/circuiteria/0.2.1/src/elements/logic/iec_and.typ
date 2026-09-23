#import "/src/cetz.typ": draw
// #import "iec_gate.typ" as iec-gate
#import "iec_gate.typ" as iec-gate


/// Draws an IEC-AND gate. This function is also available as `element.iec-gate-and()`
/// 
/// For parameters, see #doc-ref("gates.iec-gate")
/// #examples.iec-gate-and
#let iec-gate-and(
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
  ),
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
    symbol: $amp$,
  )

}

/// Draws an IEC-NAND gate. This function is also available as `element.iec-gate-nand()`
/// 
/// For parameters, see #doc-ref("gates.iec-gate")
/// #examples.iec-gate-nand
#let iec-gate-nand(
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
  ),
) = {
  iec-gate-and(
    x: x,
    y: y,
    w: w,
    h: h,
    inputs: inputs,
    fill: fill,
    stroke: stroke,
    id: id,
    inverted: if inverted != "all" {inverted + ("out",)} else {inverted},
    debug: debug,
  )
}