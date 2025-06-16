#import "gates.typ": *


// align: "left" (for rstick) or "right" (for lstick)
// brace: auto, none, "{", "}", "|", "[", ...
#let lrstick(content, n, align, brace, label) = gate(
  content, 
  draw-function: draw-functions.draw-lrstick.with(align: align), 
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
  ), 
  label: label
)




/// Basic command for labelling a wire at the start. 
/// - content (content): Label to display, e.g., `$|0〉$`.
/// - n (content): How many wires the `lstick` should span. 
/// - brace (auto, none, string): If `brace` is `auto`, then a default `{` brace
///      is shown only if `n > 1`. A brace is always shown when 
///      explicitly given, e.g., `"}"`, `"["` or `"|"`. No brace is shown for 
///      `brace: none`
/// - label (array, string, content, dictionary): One or more labels to add to the gate. 
///        See @@gate(). . 
#let lstick(content, n: 1, brace: auto, label: none) = lrstick(content, n, "right", brace, label)


/// Basic command for labelling a wire at the end. 
/// - content (content): Label to display, e.g., `$|0〉$`.
/// - n (content): How many wires the `rstick` should span. 
/// - brace (auto, none, string): If `brace` is `auto`, then a default `}` brace
///      is shown only if `n > 1`. A brace is always shown when 
///      explicitly given, e.g., `"}"`, `"["` or `"|"`. No brace is shown for 
///      `brace: none`. 
/// - label (array, string, content, dictionary): One or more labels to add to the gate. 
///        See @@gate(). 
#let rstick(content, n: 1, brace: auto, label: none) = lrstick(content, n, "left", brace, label)

/// Create a midstick, i.e., a mid-circuit text. 
/// - content (content): Label to display, e.g., `$|0〉$`.
/// - label (array, string, content, dictionary): One or more labels to add to the gate. 
#let midstick(content, fill: none, label: none) = gate(content, draw-function: draw-functions.draw-unboxed-gate, label: label, fill: fill)



/// Creates a symbol similar to `\qwbundle` on `quantikz`. Annotates a wire to 
/// be a bundle of quantum or classical wires. 
/// - label (integer, content): 
#let nwire(label) = gate([#label], draw-function: draw-functions.draw-nwire, box: false)



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
/// - label (array, string, content, dictionary): One or more labels to add to the  
///        group. See @@gate(). 
#let gategroup(
  wires, 
  steps, 
  padding: 0pt, 
  stroke: .7pt, 
  fill: none,
  radius: 0pt,
  label: none
) = (
  qc-instr: "gategroup",
  wires: wires,
  steps: steps,
  padding: process-args.process-padding-arg(padding),
  style: (fill: fill, stroke: stroke, radius: radius),
  labels: process-args.process-label-arg(label, default-pos: top)
)

/// Slice the circuit vertically, showing a separation line between columns. 
/// 
/// - n (integer): Number of wires to slice.
/// - stroke (stroke): Line style for the slice. 
/// - label (array, string, content, dictionary): One or more labels to add to the  
///        slice. See @@gate(). 
#let slice(
  n: 0, 
  stroke: (paint: red, thickness: .7pt, dash: "dashed"),
  label: none
) = (
  qc-instr: "slice",
  wires: n,
  style: (stroke: stroke),
  labels: process-args.process-label-arg(label, default-pos: top)
)

/// Lower-level interface to the cell coordinates to create an arbitrary
/// annotatation by passing a custom function.
/// 
/// This function is passed the coordinates of the specified cell rows 
/// and columns. 
/// 
/// - columns (integer, array): Column indices for which to obtain coordinates. 
/// - rows (integer, array): Row indices for which to obtain coordinates. 
/// - callback (function): Function to call with the obtained coordinates. The
///     signature should be with signature `(col-coords, row-coords) => {}`. 
///     This function is expected to display the content to draw in absolute 
///     coordinates within the circuit. 
#let annotate(
  columns,
  rows,
  callback 
) = (
  qc-instr: "annotate",
  rows: rows,
  columns: columns,
  callback: callback
)


