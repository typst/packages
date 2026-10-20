#import "/src/cetz.typ": draw
#import "iec_gate.typ" as iec-gate


/// Draws an IEC buffer gate. This function is also available as `element.iec-gate-buf()`
///
/// For parameters, see #doc-ref("gates.iec-gate")
/// #examples.iec-gate-buf
#let iec-gate-buf(
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
    ports: false,
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
    symbol: "1",
  )
}

/// Draws an IEC NOT gate. This function is also available as `element.iec-gate-not()`
/// 
/// For parameters, see #doc-ref("gates.iec-gate")
/// #examples.iec-gate-not
#let iec-gate-not(
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
    ports: false,
  ),
) = {
  iec-gate-buf(
    x: x,
    y: y,
    w: w,
    h: h,
    inputs: inputs,
    fill: fill,
    stroke: stroke,
    id: id,
    inverted: if inverted != "all" { inverted + ("out",) } else { inverted },
    debug: debug,
  )
}
