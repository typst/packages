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
/// - content (content): Label to display, e.g., `$|0〉$`.
/// - n (content): How many wires the `lstick` should span. 
/// - brace (auto, none, str): If `brace` is `auto`, then a default `{` brace
///      is shown only if `n > 1`. A brace is always shown when 
///      explicitly given, e.g., `"}"`, `"["` or `"|"`. No brace is shown for 
///      `brace: none`
/// - pad (length): Adds a padding between the label and the connected wire to the right. 
/// - label (array, str, content, dictionary): One or more labels to add to the gate. 
///        See @@gate(). 
#let lstick(
  content, 
  n: 1, 
  brace: auto, 
  pad: 0pt,
  label: none, 
  x: auto,
  y: auto
) = lrstick(content, n, right, brace, label, pad: pad, x: x, y: y)


/// Basic command for labelling a wire at the end. 
/// - content (content): Label to display, e.g., `$|0〉$`.
/// - n (content): How many wires the `rstick` should span. 
/// - pad (length): Adds a padding between the label and the connected wire to the left. 
/// - brace (auto, none, str): If `brace` is `auto`, then a default `}` brace
///      is shown only if `n > 1`. A brace is always shown when 
///      explicitly given, e.g., `"}"`, `"["` or `"|"`. No brace is shown for 
///      `brace: none`. 
/// - label (array, str, content, dictionary): One or more labels to add to the gate. 
///        See @@gate(). 
#let rstick(
  content, 
  n: 1, 
  brace: auto, 
  pad: 0pt, 
  label: none, 
  x: auto,
  y: auto
) = lrstick(content, n, left, brace, label, pad: pad, x: x, y: y)

/// Create a midstick, i.e., a mid-circuit text. 
/// - content (content): Label to display, e.g., `$|0〉$`.
/// - label (array, str, content, dictionary): One or more labels to add to the gate. 
#let midstick(
  content,
  n: 1,
  fill: none,
  label: none,
  x: auto,
  y: auto
) = {
  if n == 1 { 
    gate(content, draw-function: draw-functions.draw-unboxed-gate, label: label, fill: fill, x: x, y: y) 
  } else {
    mqgate(content, n: n, draw-function: draw-functions.draw-boxed-multigate, label: label, fill: fill, x: x, y: y, stroke: none) 
  }
}




/// Creates a symbol similar to `\qwbundle` on `quantikz`. Annotates a wire to 
/// be a bundle of quantum or classical wires. 
/// - label (int, content): 
#let nwire(label, x: auto, y: auto) = gate([#label], draw-function: draw-functions.draw-nwire, box: false, x: x, y: y)



/// Set current wire mode (0: none, 1 wire: quantum, 2 wires: classical, more  
/// are possible) and optionally the stroke style. 
///
/// The wire style is reset for each row.
///
/// - wire-count (int): Number of wires to display. 
/// - stroke (auto, none, stroke): When given, the stroke is applied to the wire. 
///                Otherwise the current stroke is kept. 
/// - wire-distance (length): Distance between wires. 
#let setwire(wire-count, stroke: auto, wire-distance: auto) = (
  qc-instr: "setwire",
  wire-count: wire-count,
  stroke: stroke,
  wire-distance: wire-distance
)

/// Highlight a group of circuit elements by drawing a rectangular box around
/// them. 
/// 
/// - wires (int): Number of wires to include.
/// - steps (int): Number of columns to include.
/// - x (auto, int): The starting column of the gategroup. 
/// - y (auto, int): The starting wire of the gategroup. 
/// - z (str): The gategroup can be placed `"below"` or `"above"` the circuit. 
/// - padding (length, dictionary): Padding of rectangle. May be one length
///     for all sides or a dictionary with the keys `left`, `right`, `top`, 
///     `bottom` and `default`. Not all keys need to be specified. The value 
///     for `default` is used for the omitted sides or `0pt` if no `default` 
///     is given. 
/// - stroke (stroke): Stroke for rectangle.
/// - fill (color): Fill color for rectangle.
/// - radius (length, dictionary): Corner radius for rectangle.
/// - label (array, str, content, dictionary): One or more labels to add to the  
///        group. See @@gate(). 
#let gategroup(
  wires, 
  steps, 
  x: auto, 
  y: auto,
  z: "below",
  padding: 0pt, 
  stroke: .7pt, 
  fill: none,
  radius: 0pt,
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
/// 
/// - n (int): Number of wires to slice.
/// - x (auto, int): The starting column of the slice. 
/// - y (auto, int): The starting wire of the slice. 
/// - z (str): The slice can be placed `"below"` or `"above"` the circuit. 
/// - stroke (stroke): Line style for the slice. 
/// - label (array, str, content, dictionary): One or more labels to add to the  
///        slice. See @@gate(). 
#let slice(
  n: 0, 
  x: auto, 
  y: auto,
  z: "below",
  stroke: (paint: red, thickness: .7pt, dash: "dashed"),
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
/// 
/// - columns (int, array): Column indices for which to obtain coordinates. 
/// - rows (int, array): Row indices for which to obtain coordinates. 
/// - callback (function): Function to call with the obtained coordinates. The
///     signature should be with signature `(col-coords, row-coords) => {}`. 
///     This function is expected to display the content to draw in absolute 
///     coordinates within the circuit. 
/// - z (str): The annotation can be placed `"below"` or `"above"` the circuit. 
#let annotate(
  columns,
  rows,
  callback,
  z: "below",
) = (
  qc-instr: "annotate",
  rows: rows,
  x: none,
  y: none,
  z: z,
  columns: columns,
  callback: callback
)


