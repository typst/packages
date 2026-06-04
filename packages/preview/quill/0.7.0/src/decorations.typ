#import "gates.typ": *


// align: "left" (for rstick) or "right" (for lstick)
// brace: auto, none, "{", "}", "|", "[", ...
#let lrstick(content, n, align, brace, label, pad: 0pt, x: auto, y: auto) = gate(
  content, 
  x: x, 
  y: y,
  draw-function: draw-functions.draw-lrstick, 
  size-hint: layout.lrstick-size-hint,
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
  data: (
    brace: brace,
    align: align,
    pad: pad
  ), 
  label: label
)



/// Basic command for labelling a wire at the start. 
/// 
/// ```example
/// #quantum-circuit(
///   lstick($|0〉$), 1
/// )
/// ```
/// It can also span multiple wires
/// ```example
/// #quantum-circuit(
///   lstick($rho$, n: 2), 1, [\ ], 
///   1
/// )
/// ```
#let lstick(

  /// Label to display, e.g., `$|0〉$`.
  /// -> content
  body, 

  /// How many wires the `lstick` should span. 
  /// -> int
  n: 1, 

  /// If `brace` is `auto`, then a default `{` brace is shown only if `n > 1`. 
  /// A brace is always shown when explicitly given, e.g., `"}"`, `"["` or 
  /// `"|"`. No brace is shown for `brace: none`.
  /// -> auto | none | str
  brace: auto, 

  /// Adds a padding between the label and the connected wire to the right. 
  /// -> length
  pad: 0pt,

  /// One or more labels to add to the gate. See @gate.label. 
  /// -> none | array | str | content | dictionary
  label: none, 

  x: auto,

  y: auto

) = lrstick(body, n, right, brace, label, pad: pad, x: x, y: y)



/// Basic command for labelling a wire at the end. 
/// 
/// ```example
/// #quantum-circuit(
///   1, rstick($|0〉$)
/// )
/// ```
/// It can also span multiple wires
/// ```example
/// #quantum-circuit(
///   1, rstick($rho$, n: 2), [\ ], 
/// )
/// ```
#let rstick(

  /// Label to display, e.g., `$|0〉$`.
  /// -> content
  body, 

  /// How many wires the `rstick` should span. 
  /// -> int
  n: 1, 

  /// If `brace` is `auto`, then a default `}` brace is shown only if `n > 1`. 
  /// A brace is always shown when explicitly given, e.g., `"}"`, `"["` or 
  /// `"|"`. No brace is shown for `brace: none`. 
  /// -> auto | none | str
  brace: auto, 

  /// Adds a padding between the label and the connected wire to the left. 
  /// -> length
  pad: 0pt, 

  /// One or more labels to add to the gate. See @gate. 
  /// -> none | array | str | content | dictionary
  label: none, 

  x: auto,

  y: auto

) = lrstick(body, n, left, brace, label, pad: pad, x: x, y: y)



/// Create a midstick, i.e., a mid-circuit text. 
/// 
/// ```example
/// #quantum-circuit(
///   1, midstick($cal(E)$), 1
/// )
/// ```
/// It can also span multiple wires
/// ```example
/// #quantum-circuit(
///   1, midstick($cal(E)^2$, n: 2), 
///   1, [\ ], 
/// )
/// ```
#let midstick(

  /// Label to display, e.g., `$rho$`.
  /// -> content
  body,

  /// How many wires the `midstick` should span. 
  /// -> content
  n: 1,

  /// One or more labels to add to the gate. See @gate. 
  /// -> none | array | str | content | dictionary
  label: none,

  /// How to fill the midstick.
  /// -> none color | gradient | tiling
  fill: none,

  x: auto,

  y: auto

) = {
  if n == 1 { 
    gate(body, draw-function: draw-functions.draw-unboxed-gate, label: label, fill: fill, x: x, y: y) 
  } else {
    mqgate(body, n: n, draw-function: draw-functions.draw-boxed-multigate, label: label, fill: fill, x: x, y: y, stroke: none) 
  }
}



/// Creates a symbol similar to `\qwbundle` on `quantikz`. Annotates a wire to 
/// be a bundle of quantum or classical wires. 
/// 
/// ```example
/// #quantum-circuit(
///   1, nwire($5$), 1
/// )
/// ```
#let nwire(

  /// The label to put on top of the bundle. 
  /// -> int | content
  body, 

  x: auto, 

  y: auto

) = gate([#body], draw-function: draw-functions.draw-nwire, box: false, x: x, y: y)



/// Set current wire mode (0: none, 1 wire: quantum, 2 wires: classical, more  
/// are possible) and optionally the stroke style. 
///
/// The wire style is reset for each row.
#let setwire(

  /// Number of wires to display. 
  /// -> int
  wire-count, 

  /// When given, the stroke is applied to the wire. Otherwise the current stroke is kept. 
  /// -> auto | none | stroke
  stroke: auto, 

  /// Distance between wires. 
  /// -> length
  wire-distance: auto,

  /// The starting column of the wire change command. 
  /// -> auto | int
  x: auto, 

  /// The starting wire of the wire change command. 
  /// -> auto | int
  y: auto

) = (
  x: x, 
  y: y,
  qc-instr: "setwire",
  wire-count: wire-count,
  stroke: stroke,
  wire-distance: wire-distance
)



/// Highlight a group of circuit elements by drawing a rectangular box around
/// them. 
#let gategroup(

  /// Number of wires to include.
  /// -> int
  wires, 

  /// Number of columns to include.
  /// -> int
  steps, 

  /// The starting column of the gategroup. 
  /// -> auto | int
  x: auto, 

  /// The starting wire of the gategroup. 
  /// -> auto | int
  y: auto, 

  /// The gategroup can be placed `"below"` or `"above"` the circuit. 
  /// -> "below" | "above"
  z: "below", 

  /// Padding of rectangle. May be one length for all sides or a dictionary 
  /// with the keys `left`, `right`, `top`, `bottom` and `default`. Not all 
  /// keys need to be specified. The value for `default` is used for the 
  /// omitted sides or `0pt` if no `default` is given. 
  /// -> length | dictionary
  padding: 0pt, 

  /// Stroke for rectangle.
  /// -> stroke
  stroke: .7pt, 

  /// Fill color for rectangle.
  /// -> color
  fill: none, 

  /// Corner radius for rectangle.
  /// -> length, dictionary
  radius: 0pt, 

  /// One or more labels to add to the group. See @gate. 
  /// -> none | array | str | content | dictionary
  label: none

) = (
  qc-instr: "gategroup",
  wires: wires,
  steps: steps,
  x: x, 
  y: y,
  z: z,
  padding: process-args.process-padding-arg(padding),
  style: (fill: fill, stroke: stroke, radius: radius),
  labels: process-args.process-label-arg(label, default-pos: top)
)



/// Slice the circuit vertically, showing a separation line between columns. 
#let slice(

  /// Number of wires to slice.
  /// -> int
  n: 0, 

  /// The starting column of the slice. 
  /// -> auto | int
  x: auto, 

  /// The starting wire of the slice. 
  /// -> auto | int
  y: auto,

  /// The slice can be placed `"below"` or `"above"` the circuit. 
  /// -> "below" | "above"
  z: "below",

  /// Line style for the slice. 
  /// -> stroke
  stroke: (paint: red, thickness: .7pt, dash: "dashed"),

  /// One or more labels to add to the slice. See @gate. 
  /// -> none | array | str | content | dictionary
  label: none

) = (
  qc-instr: "slice",
  wires: n,
  x: x,
  y: y,
  z: z,
  style: (stroke: stroke),
  labels: process-args.process-label-arg(label, default-pos: top)
)



/// Lower-level interface to the cell coordinates to create an arbitrary
/// annotatation by passing a custom function.
/// 
/// This function is passed the coordinates of the specified cell rows 
/// and columns. 
#let annotate(

  /// Column indices for which to obtain coordinates.
  /// -> int | array
  columns,

  /// Row indices for which to obtain coordinates. 
  /// -> int | array
  rows,

  /// Function to call with the obtained coordinates. The signature should
  /// be with signature `(col-coords, row-coords) => {}`. This function is
  /// expected to display the content to draw in absolute coordinates within 
  /// the circuit. 
  /// -> function
  callback,

  /// The slice can be placed `"below"` or `"above"` the circuit. 
  /// -> "below" | "above"
  z: "below"

) = (
  qc-instr: "annotate",
  rows: rows,
  x: none,
  y: none,
  z: z,
  columns: columns,
  callback: callback
)
