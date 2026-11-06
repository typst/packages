#import "layout.typ"
#import "process-args.typ"
#import "draw-functions.typ"



/// This is the basic command for creating gates. Use this to create a simple gate, e.g., `gate($X$)`. 
/// For special gates, many other dedicated gate commands exist. 
///
/// Note, that most of the parameters listed here are mostly used for derived gate 
/// functions and do not need to be touched in all but very few cases. 
///
/// //#example(`quill.quantum-circuit(1, quill.gate($H$), 1)`)
///
/// - content (content): What to show in the gate (may be none for special gates like @@ctrl() ).
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
///             Signature: `(gate, draw-params) => {}`.
/// - draw-function (function): Drawing function that produces the displayed content.
///             Signature: `(gate, draw-params) => {}`.
/// - label (array, string, content, dictionary): One or more labels to add to the gate.
///             Usually, a label consists of a dictionary with entries for the keys 
///             `content` (the label content), `pos` (2d alignment specifying the 
///             position of the label) and optionally `dx` and/or `dy` (lengths, ratios 
///             or relative lengths). If only a single label is to be added, a plain 
///             content or string value can be passed which is then placed at the default
///             position. 
///
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
  size-hint: layout.default-size-hint,
  draw-function: draw-functions.draw-boxed-gate,
  gate-type: "",
  data: none,
  label: none
) = (
  content: content, 
  fill: fill,
  radius: radius,
  width: width,
  box: box,
  floating: floating,
  multi: multi,
  size-hint: size-hint,
  draw-function: draw-function,
  gate-type: gate-type, 
  data: data,
  labels: process-args.process-label-arg(label, default-pos: top)
)



/// Basic command for creating multi-qubit or controlled gates. See also @@ctrl() and @@swap(). 
///
/// - content (content):
/// - n (integer): Number of wires the multi-qubit gate spans. 
/// - target (none, integer): If specified, a control wire is drawn from the gate up 
///        or down this many wires counted from the wire this `mqgate()` is placed on. 
/// - fill (none, color): Gate backgrond fill color.
/// - radius (length, dictionary): Gate rectangle border radius. 
///        Allows the same values as the builtin `rect()` function.
/// - width (auto, length): The width of the gate can be specified manually with this property. 
/// - box (boolean): Whether this is a boxed gate (determines whether the 
///        outgoing wire will be drawn all through the gate (`box: false`) or not).
/// - wire-count (integer): Wire count for control wires.
/// - inputs (none, array): You can put labels inside the gate to label the input wires with 
///        this argument. It accepts a list of labels, each of which has to be a dictionary
///        with the keys `qubit` (denoting the qubit to label, starting at 0) and `content`
///        (containing the label content). Optionally, providing a value for the key `n` allows
///        for labelling multiple qubits spanning over `n` wires. These are then grouped by a 
///        brace. 
/// - outputs (none, array): Same as `inputs` but for gate outputs. 
/// - extent (auto, length): How much to extent the gate beyond the first and 
///        last wire, default is to make it align with an X gate (so [size of x gate] / 2). 
/// - size-all-wires (none, boolean): A single-qubit gate affects the height of the row
///        it is being put on. For multi-qubit gate there are different possible 
///        behaviours:
///          - Affect height on only the first and last wire (`false`)
///          - Affect the height of all wires (`true`)
///          - Affect the height on no wire (`none`)
/// - label (array, string, content, dictionary): One or more labels to add to the gate. 
///        See @@gate(). 
/// - wire-label (array, string, content, dictionary): One or more labels to add to the 
///        control wire. Works analogous to `labels` but with default positioning to the 
///        right of the wire. 
/// - data (any): Optional additional gate data. This can for example be a dictionary
///        storing extra information that may be used for instance in a custom
///        `draw-function`.
#let mqgate(
  content,
  n: 1, 
  target: none,
  fill: none, 
  radius: 0pt,
  width: auto,
  box: true, 
  wire-count: 1,
  inputs: none,
  outputs: none,
  extent: auto, 
  size-all-wires: false,
  draw-function: draw-functions.draw-boxed-multigate, 
  label: none,
  wire-label: none,
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
    size-all-wires: size-all-wires,
    inputs: inputs,
    outputs: outputs,
    wire-label: process-args.process-label-arg(wire-label, default-pos: right),
  ),
  label: label,
  data: data,
)



// SPECIAL GATES

/// Draw a meter box representing a measurement. 
/// - target (none, integer): If given, draw a control wire to the given target
///                           qubit the specified number of wires up or down.
/// - wire-count (integer):   Wire count for the (optional) control wire. 
/// - n (integer):            Number of wires to span this meter across. 
/// - label (array, string, content, dictionary): One or more labels to add to the gate. 
///        See @@gate(). 
#let meter(target: none, n: 1, wire-count: 2, label: none, fill: none, radius: 0pt) = {
  label = if label != none {(content: label, pos: top, dy: -0.5em)} else { () }
  if target == none and n == 1 {
    gate(none, fill: fill, radius: radius, draw-function: draw-functions.draw-meter, data: (meter-label: label), label: label)
  } else {
     mqgate(none, n: n, target: target, fill: fill, radius: radius, box: true, wire-count: wire-count, draw-function: draw-functions.draw-meter, data: (meter-label: label), label: label)
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
/// - bend (ratio): How much to bend the wires. With `0%`, the wires are straight. 
/// - separation (auto, none, length, color, stroke): Overlapping wires are separated by drawing a thicker line below. With this option, this line can be customized in color or thickness. 
#let permute(..qubits, width: 30pt, bend: 100%, separation: auto) = {
  if qubits.named().len() != 0 {
    assert(false, message: "Unexpected named argument `" + qubits.named().keys().first() + "` in function `permute()`")
  }
  mqgate(none, n: qubits.pos().len(), width: width, draw-function: draw-functions.draw-permutation-gate, data: (qubits: qubits.pos(), extent: 2pt, separation: separation, bend: bend))
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

/// Target element for controlled-X operations (#sym.plus.circle). 
/// - fill (none, color, boolean): Fill color for the target circle. If set 
///        to `true`, the target is filled with the circuits background color.
/// - size (length): Size of the target symbol. 
#let targ(fill: none, size: 4.3pt, label: none) = gate(none, box: false, draw-function: draw-functions.draw-targ, fill: fill, data: (size: size), label: label)

/// Target element for controlled-Z operations (#sym.bullet). 
///
/// - open (boolean): Whether to draw an open dot. 
/// - fill (none, color): Fill color for the circle or stroke color if
///        `open: true`. 
/// - size (length): Size of the control circle. 
// #let ctrl(open: false, fill: none, size: 2.3pt) = gate(none, draw-function: draw-ctrl, fill: fill, size: size, box: false, open: open)

/// Target element for #smallcaps("swap") operations (#sym.times) without vertical wire). 
/// - size (length): Size of the target symbol. 
#let targX(size: 7pt, label: none) = gate(none, box: false, draw-function: draw-functions.draw-swap, data: (size: size), label: label)

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
  draw-function: (gate, draw-params) => box(
    inset: (x: .6em), 
    draw-functions.draw-ctrl(gate, draw-params)
  ),
  fill: fill,
  data: (open: open, size: size),
  label: process-args.process-label-arg(label, default-pos: top + right, default-dx: -.5em)
)



/// Creates a #smallcaps("swap") operation with another qubit. 
/// 
/// - n (integer): How many wires up or down the target wire lives. 
/// - size (length): Size of the target symbol. 
/// - wire-label (array, string, content, dictionary): One or more labels 
///        to add to the control wire. See @@mqgate(). 
#let swap(n, wire-count: 1, size: 7pt, label: none, wire-label: none) = mqgate(
  none,
  target: n,
  box: false,
  draw-function: draw-functions.draw-swap,
  wire-count: wire-count,
  data: (size: size),
  label: label,
  wire-label: wire-label
)



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
/// - wire-label (array, string, content, dictionary): One or more labels 
///        to add to the control wire. See @@mqgate(). 
#let ctrl(
  n,
  wire-count: 1,
  open: false,
  fill: none,
  size: 2.3pt,
  show-dot: true,
  label: none,
  wire-label: none,
) = mqgate(
  none,
  target: n,
  box: false,
  draw-function: draw-functions.draw-ctrl,
  wire-count: wire-count,
  fill: fill,
  data: (open: open, size: size, show-dot: show-dot),
  label: label,
  wire-label: wire-label
)
