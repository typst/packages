#import "layout.typ"
#import "process-args.typ"
#import "draw-functions.typ"




/// Creates a quantum (or classical) gate. For special gates, many dedicated 
/// gate commands like @ctrl, @swap, and more exist. 
/// 
/// ```example
/// #quantum-circuit(
///  1, gate($H$), 1
/// )
/// ```
///
/// Note, that most of the parameters listed here are mostly used for derived gate 
/// functions and do not need to be touched in all but very few cases. 
#let gate(

  /// The body of the gate (may be none for special gates like @ctrl). 
  /// -> content
  body,

  /// The column to put the gate in. 
  /// -> auto | int
  x: auto,

  /// The row to put the gate in. 
  /// -> auto | int
  y: auto,

  /// How to fill the gate box.
  /// -> auto | none | color | gradient | tiling
  fill: auto,

  /// How to stroke the gate box.
  /// -> auto | stroke
  stroke: auto,

  /// Border radius for the gate box. Allows the same values as the built-in 
  /// `rect()` function.
  /// -> length | dictionary
  radius: 0pt,

  /// Specifies the width of the gate. 
  /// -> auto | length
  width: auto,

  /// Whether this is a boxed gate (determines whether the outgoing wire
  /// will be drawn all through the gate (`box: false`) or not).
  /// -> bool
  box: true,

  /// Whether the content for this gate will be shown floating (i.e. no 
  /// width is reserved for layout).
  /// -> bool
  floating: false,

  /// Information for multi-qubit and controlled gates (see @mqgate).
  /// -> none | dictionary
  multi: none,

  /// Size hint function. This function should return a dictionary containing
  /// the keys `width` and `height`. The result is used to determine the gates
  /// position and cell sizes of the grid. Signature: `(gate, draw-params) => {}`.
  /// -> function
  size-hint: layout.default-size-hint,

  /// Drawing function that produces the displayed content. Signature: 
  /// `(gate, draw-params) => {}`.
  /// -> function
  draw-function: draw-functions.draw-boxed-gate,

  /// Optional additional gate data. This can for example be a dictionary storing 
  /// extra information that may be used for instance in a custom `draw-function`.
  /// -> any
  data: none,

  /// One or more labels to add to the gate. Usually, a label consists of a 
  /// dictionary with entries for the keys `content` (the label content), `pos` 
  /// (2d alignment specifying the position of the label) and optionally `dx` 
  /// and/or `dy` (lengths, ratios or relative lengths). If only a single label 
  /// is to be added, a plain content or string value can be passed which is then 
  /// placed at the default position. 
  /// -> none | array | str | content | dictionary
  label: none

) = (
  content: body, 
  x: x, 
  y: y,
  fill: fill,
  stroke: stroke,
  radius: radius,
  width: width,
  box: box,
  floating: floating,
  multi: multi,
  size-hint: size-hint,
  draw-function: draw-function,
  gate-type: "", 
  data: data,
  labels: process-args.process-label-arg(label, default-pos: top)
)



/// Base command for creating multi-qubit or controlled gates. See also @ctrl and @swap. 
/// ```example
/// #quantum-circuit(
///   1, mqgate($E$, n: 2, target: 2), 1, 
///   [\ ], [\ ]
/// )
/// ```
#let mqgate(

  /// The body of the gate. 
  /// -> content
  body,

  /// The number of wires that the multi-qubit gate spans. 
  /// -> int
  n: 1, 

  /// Specifies a control wire to be drawn to a target wire relative to the wire
  /// that the is placed on. 
  /// -> none | int
  target: none,

  /// Which wires to allow to pass through the gate. 
  /// ```example
  /// #quantum-circuit(
  ///   wires: 4,
  ///   1, mqgate(
  ///     n: 4, 
  ///     fill: none, 
  ///     pass-through: (2,),
  ///     $E$
  ///   ), 1
  /// )
  /// ```
  /// Note that it is necessary to set `fill` to none to prevent the gate from 
  /// drawing over the wires. 
  /// 
  /// The indices are given relative to the first wire of the gate. The (relative) first and last wires cannot pass through the gate. 
  pass-through: (),


  /// The column to put the gate in. 
  /// -> auto | int
  x: auto,

  /// The row to put the gate in. If $n>1$, this sets the _first_ row of the
  /// multi-qubit gate. 
  /// -> auto | int
  y: auto,
  
  /// How to fill the gate box
  /// -> auto | none | color | gradient | tiling
  fill: auto, 

  /// How to stroke the gate box. 
  /// -> auto | stroke
  stroke: auto,

  /// Border radius for the gate box. Allows the same values as the built-in 
  /// `rect()` function.
  /// -> length | dictionary
  radius: 0pt,

  /// Specifies the width of the gate. 
  /// -> auto | length
  width: auto,

  /// Whether this is a boxed gate (determines whether the outgoing wire will
  /// be drawn all through the gate (`box: false`) or not).
  /// -> bool
  box: true, 

  /// The number of parallel control wires to draw.
  /// -> int
  wire-count: 1,

  /// How to stroke the control wire. 
  /// -> auto | stroke
  wire-stroke: auto,

  /// You can put labels inside the gate to label the input wires with this
  /// argument. It accepts a list of labels, each of which has to be a 
  /// dictionary with the keys `qubit` (denoting the qubit to label, starting 
  /// at 0) and `content` (containing the label content). Optionally, providing 
  /// a value for the key `n` allows for labelling multiple qubits spanning 
  /// over `n` wires. These are then grouped by a brace. 
  /// -> none | array
  inputs: none,

  /// Same as @mqgate.inputs but for gate outputs. 
  /// -> none | array
  outputs: none,

  /// How much to extent the gate beyond the first and last wire, default is 
  /// to make it align with an X gate (so [size of x gate] / 2). 
  /// -> auto | length
  extent: auto, 

  /// A single-qubit gate affects the height of the row it is being put on. 
  /// For multi-qubit gate there are different possible behaviours:
  ///  - `false`: The hight is affected on only the first and last wire.
  ///  - `true`: The height of all wires is affected.
  ///  - `none`: The height on no wire is affected.
  /// -> none | bool
  size-all-wires: false,

  /// See @gate.draw-function
  /// -> function
  draw-function: draw-functions.draw-boxed-multigate, 

  /// One or more labels to add to the gate. See @gate.label. 
  /// -> none | array | str | content | dictionary
  label: none,

  /// One or more labels to add to the control wire. Works analogous to 
  /// `labels` but with default positioning to the right of the wire. 
  /// -> none | array | str | content | dictionary
  wire-label: none,

  /// Optional additional gate data. This can for example be a dictionary
  /// storing extra information that may be used for instance in a custom
  /// `draw-function`.
  /// -> any
  data: none,

) = gate(
  body, 
  x: x, 
  y: y, 
  fill: fill, 
  stroke: stroke,
  box: box, 
  width: width,
  radius: radius,
  draw-function: draw-function,
  multi: (
    target: target,
    num-qubits: n, 
    wire-count: wire-count, 
    wire-stroke: wire-stroke,
    label: label,
    extent: extent,
    size-all-wires: size-all-wires,
    inputs: inputs,
    outputs: outputs,
    wire-label: process-args.process-label-arg(wire-label, default-pos: right),
    pass-through: pass-through
  ),
  label: label,
  data: data,
)



// SPECIAL GATES

/// Draws a meter representing a measurement. Meters can stand alone,
/// ```example
/// #quantum-circuit(
///  1, meter(), 1
/// )
/// ```
/// connect to another wire and have a label,
/// ```example
/// #quantum-circuit(
///  1, meter(target: 1, label: $X$), 1, [\ ]
/// )
/// ```
/// and can span multiple qubits.
/// ```example
/// #quantum-circuit(
///  1, meter(n: 2), 1, [\ ]
/// )
/// ```
#let meter(

  /// Optional body to use for the meter. Here you may use the `meter-symbol` and 
  /// combine it with additional measurement information. 
  /// ```example
  /// #quantum-circuit(
  ///  1, meter[$P_1$ #meter-symbol], 1
  /// )
  /// ```
  /// Superscripts can be used to embed a small basis inset. 
  /// 
  /// ```example
  /// #let basis-meter(basis) = meter[
  ///   #place(super(baseline: -0.4em, basis)) 
  ///   #meter-symbol
  /// ]
  /// 
  /// #quantum-circuit(
  ///  1, basis-meter[X], 1
  /// )
  /// ```
  /// 
  /// -> any
  ..body,

  /// If given, draw a control wire to the given target qubit the specified
  /// number of wires up or down.
  /// -> none | int
  target: none, 

  /// The number of qubits that the meter spans. 
  /// -> int
  n: 1,

  x: auto,

  y: auto,

  /// Wire count for the optional control wire, see @meter.target. 
  /// -> int
  wire-count: 2, 

  /// How to stroke the optional control wire. 
  /// -> auto | stroke
  wire-stroke: auto,

  /// One or more labels to add to the gate. See @gate.label. 
  /// -> none | array | str | content | dictionary
  label: none, 

  fill: auto, 

  radius: 0pt

) = {
  process-args.assert-no-named(body, fn: "meter")
  body = body.pos()
  if body.len() == 1 {
    body = body.first()
  } else if body.len() == 0 {
    body = auto
  } else {
    assert(false, message: "Unexpected positional argument `" + repr(body.at(1)) + "` encountered at meter")
  }
  label = process-args.process-label-arg(label, default-dy: 0.5em, default-pos: top)
  if target == none and n == 1 {
    gate(body, x: x, y: y, fill: fill, radius: radius, draw-function: draw-functions.draw-meter, label: label)
  } else {
     mqgate(body, x: x, y: y, n: n, target: target, fill: fill, radius: radius, box: true, wire-count: wire-count, wire-stroke: wire-stroke, draw-function: draw-functions.draw-meter, label: label)
  }
}



/// Creates a visualized permutation gate which maps the qubits $q_k, q_(k+1), ... $ 
/// to the qubits $q_(p(k)), q_(p(k+1)), ...$ when placed on the qubit $k$. The 
/// permutation map is given by the `qubits` argument. Note, that qubit indices 
/// start with 0. 
/// 
/// 
/// 
/// ```example
/// #quantum-circuit(
///   1, permute(1, 0), 1, [\ ]
/// )
/// ```
/// The amount of wire bending can be configured:
/// ```example
/// #quantum-circuit(
///   1, permute(2,0,1, bend: 0%), 
///   1, [\ ], [\ ]
/// )
/// ```
/// Note also, that the wiring is not very sophisticated and will probably look best for 
/// relatively simple permutations. Furthermore, it only works with quantum wires. 
#let permute(

  /// Qubit permutation. 
  /// -> int
  ..qubits, 

  /// Width of the permutation gate. 
  /// -> length
  width: 30pt, 

  /// How much to bend the wires. With `0%`, the wires are straight. 
  /// -> ratio
  bend: 100%, 

  /// Overlapping wires are separated by drawing a thicker line below. With 
  /// this option, this line can be customized in color or thickness. 
  /// -> auto | none | length | color | stroke
  separation: auto,

  /// The number of wires to display on each permuted wire. This can be used to
  /// create a permutation of classical or even mixed wires. 
  /// -> int | array
  wire-count: 1,

  /// How to stroke each permuted wire. Wires left at `auto` will inherit the general wire style. 
  /// -> auto | stroke | array
  stroke: auto,

  x: auto,

  y: auto,

) = {
  if qubits.named().len() != 0 {
    assert(false, message: "Unexpected named argument `" + qubits.named().keys().first() + "` in function `permute()`")
  }
  qubits = qubits.pos()
  if type(wire-count) == array {
    assert(
      wire-count.len() == qubits.len(),
      message: "The number of wire-counts and permuted qubits must match"
    )
  } else {
    wire-count = (wire-count,) * qubits.len()
  }
  if type(stroke) == array {
    assert(
      stroke.len() == qubits.len(),
      message: "The number of strokes and permuted qubits must match"
    )
  } else {
    stroke = (stroke,) * qubits.len()
  }
  mqgate(none, n: qubits.len(), width: width, draw-function: draw-functions.draw-permutation-gate, data: (qubits: qubits, extent: 2pt, separation: separation, bend: bend, wire-count: wire-count, stroke: stroke))
}



/// Creates an invisible (phantom) gate for reserving space. If `content` 
/// is provided, the `height` and `width` parameters are ignored and the gate 
/// will take the size it would have if `gate(content)` was called. 
///
/// Instead specifying width and/or height will create a gate with exactly the
/// given size (without padding).
#let phantom(

  /// Content to measure for the phantom gate size. 
  /// -> content
  content: none, 

  /// Width of the phantom gate (ignored if `content` is not `none`). 
  /// -> length
  width: 0pt, 

  /// Height of the phantom gate (ignored if `content` is not `none`). 
  /// -> length
  height: 0pt,

  x: auto,

  y: auto,

) = {
  let thecontent = if content != none { box(hide(content)) } else { 
    box(width: width, height: height) 
  }
  gate(thecontent, x: x, y: y, box: false, fill: none)
}



/// Target element for controlled-$X$ operations. 
/// 
/// ```example
/// #quantum-circuit(
///   1, targ(), 1, 
/// )
/// ```
#let targ(

  /// How many wires up or down the target wire lives. 
  /// -> int
  ..n,

  /// How to fill the target circle. If set to `auto`, the target is 
  /// filled with the circuits background color.
  /// -> none | auto | color | gradient | tiling
  fill: none,

  /// Radius of the target symbol. 
  /// -> length
  size: 4.3pt,

  label: none, 

  x: auto,

  y: auto,

  /// Wire count for the control wire.  
  /// -> int
  wire-count: 1,

  /// How to stroke the optional control wire. 
  /// -> auto | stroke
  wire-stroke: auto,

  /// One or more labels to add to the control wire. See @mqgate.wire-label. 
  /// -> none | array | str | content | dictionary
  wire-label: none,

) = {
  process-args.assert-no-named(n, fn: "targ")
  n = n.pos()
  assert(n.len() <= 1, message: "Unexpected second positional argument for `targ`")

  mqgate(
    none,
    x: x, 
    y: y,
    target: n.at(0, default: 0),
    box: false,
    draw-function: draw-functions.draw-targ,
    wire-count: wire-count,
    wire-stroke: wire-stroke,
    fill: if fill == true {auto} else if fill == false {none} else {fill}, 
    data: (size: size), 
    label: label,
    wire-label: wire-label
  )
}



/// Creates a phase gate shown as a point on the wire together with a label. 
/// 
/// ```example
/// #quantum-circuit(
///   1, phase($α$), 1, 
/// )
/// ```
#let phase(

  /// The angle value to display. 
  /// -> content
  label,
  
  /// Whether to draw an open dot. 
  /// -> bool
  open: false,

  /// How to fill or stroke the circle if `open: true`. 
  /// -> none | color | stroke
  fill: auto,

  /// The radius of the circle. 
  /// -> length
  size: 2.3pt,

  x: auto,

  y: auto

) = gate(
  none, 
  x: x, 
  y: y,
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
/// 
/// ```example
/// #quantum-circuit(
///   1, swap(1), 1, [\ ],
///   1, swap(), 1
/// )
/// ```
#let swap(

  /// How many wires up or down the target wire lives. 
  /// -> int
  ..n, 

  wire-count: 1, 

  /// The size of the target symbol. 
  /// -> length. 
  size: 7pt, 

  label: none, 

  /// One or more labels to add to the control wire. See @mqgate.wire-label. 
  /// -> none | array | str | content | dictionary
  wire-label: none,

  /// How to stroke the control wire. 
  /// -> auto | stroke
  wire-stroke: auto,

  x: auto,

  y: auto

) = {
  process-args.assert-no-named(n, fn: "swap")
  n = n.pos()
  assert(n.len() <= 1, message: "Unexpected second positional argument for `swap`")

  mqgate(
    none,
    x: x, 
    y: y,
    target: n.at(0, default: 0),
    box: false,
    draw-function: draw-functions.draw-swap,
    wire-count: wire-count,
    wire-stroke: wire-stroke,
    data: (size: size),
    label: label,
    wire-label: wire-label
  )
}



/// Creates a control with a vertical wire to another qubit. 
/// 
/// ```example
/// #quantum-circuit(
///   1, ctrl(1), 1, [\ ],
///   1, ctrl(), 1
/// )
/// ```
#let ctrl(

  /// How many wires up or down the target wire lives. 
  /// -> int
  ..n,

  /// Wire count for the control wire.  
  /// -> int
  wire-count: 1,

  /// How to stroke the control wire. 
  /// -> auto | stroke
  wire-stroke: auto,

  /// Whether to draw an open dot. 
  /// -> bool
  open: false,

  /// How to fill or stroke the circle if `open: true`. 
  /// none | color
  fill: auto,

  /// The radius of the control circle. 
  /// -> length
  size: 2.3pt,

  /// Whether to show the control dot at all. Set this to false to obtain a 
  /// vertical wire with no dots at all. 
  /// -> bool
  show-dot: true,

  /// One or more labels to add to the control wire. See @mqgate.wire-label. 
  /// -> none | array | str | content | dictionary
  wire-label: none,

  label: none,

  x: auto,

  y: auto

) = {
  process-args.assert-no-named(n, fn: "ctrl")
  n = n.pos()
  assert(n.len() <= 1, message: "Unexpected second positional argument for `ctrl`")

  mqgate(
    none,
    x: x, 
    y: y,
    target: n.at(0, default: 0),
    box: false,
    draw-function: draw-functions.draw-ctrl,
    wire-count: wire-count,
    fill: fill,
    data: (open: open, size: size, show-dot: show-dot),
    label: label,
    wire-label: wire-label, 
    wire-stroke: wire-stroke
  )
}
