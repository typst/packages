#import "gates.typ"

/// Info about one quantum gate. 
#let gate-info(

  /// Qubit or first qubit in the case of a multi-qubit gate. 
  /// -> int
  qubit, 
  
  /// The gate function. 
  /// -> function
  constructor, 

  /// Number of qubits. 
  /// -> int
  n: 1, 

  /// Additional gates to draw along with the main one given as 
  /// `(qubit, gate)` tuples. This is used to draw targets or multiple 
  /// controls. 
  ///  -> array
  supplements: (), 

) = (
  (
    qubit: qubit,
    n: n,
    supplements: supplements,
    constructor: constructor,
  ),
)



#let generate-single-qubit-gate(

  /// One or more qubits. Named arguments are disallowed. 
  /// -> arguments
  qubit, 

  /// Gate function.
  /// -> function
  gate
  
) = {
  if qubit.named().len() != 0 {
    assert(false, message: "Unexpected argument `" + qubit.named().keys().first() + "`")
  }
  qubit = qubit.pos()
  if qubit.len() == 1 { qubit = qubit.first() }
  if type(qubit) == int { return gate-info(qubit, gate) }
  qubit.map(qubit => gate-info(qubit, gate))
}


/// Generates a two-qubit gate with two qubits connected by a wire. 
#let generate-two-qubit-gate(

  /// Control qubit(s). 
  /// -> int | array
  qubit1, 

  /// Target qubit(s). 
  /// -> int | array
  qubit2, 

  /// Gate to put at the control qubit. This gate needs to take a
  /// single positional argument: the relative target number. 
  /// -> function
  gate1, 

  /// Gate to put at the target qubit. 
  /// -> function
  gate2

) = {
  if type(qubit1) == int and type(qubit2) == int { 
    assert.ne(qubit2, qubit1, message: "Target and control qubit cannot be the same")
    return gate-info(
      qubit1,
      gate1.with(qubit2 - qubit1),
      n: qubit2 - qubit1 + 1,
      supplements: ((qubit2, gate2),)
    ) 
  }
  if type(qubit1) == int { qubit1 = (qubit1,) }
  if type(qubit2) == int { qubit2 = (qubit2,) }

  range(calc.max(qubit1.len(), qubit2.len())).map(i => {
    let c = qubit1.at(i, default: qubit1.last())
    let t = qubit2.at(i, default: qubit2.last())
    assert.ne(t, c, message: "Target and control qubit cannot be the same")
    gate-info(
      c, 
      gate1.with(t - c), 
      n: t - c + 1, 
      supplements: ((t, gate2),)
    )
  })
}

/// Creates a gate with multiple controls. 
#let generate-multi-controlled-gate(

  /// Control qubits. 
  /// -> array
  controls, 

  /// Target qubit(s). 
  /// -> int | array
  qubit, 

  /// Gate to put at the target. 
  /// -> function
  gate,

  /// Additional arguments to apply to the `ctrl` gate. 
  /// -> any
  ..args

) = {
  let ctrl = gates.ctrl.with(..args)
  let sort-ops(cs, q) = {
    let k = cs.map(c => (c, ctrl.with(0))) + ((q, gate),)
    k = k.sorted(key: x => x.first())
    let n = k.last().at(0) - k.first().at(0)
    if k.first().at(1) == ctrl.with(0) { k.first().at(1) = ctrl.with(n) }
    else if k.last().at(1) == ctrl.with(0) { k.at(2).at(1) = ctrl.with(-n) }
    return k
  }
  controls = controls.map(c => if type(c) == int { (c,) } else { c })
  if type(qubit) == int { qubit = (qubit,) }

  range(calc.max(qubit.len(), ..controls.map(array.len))).map(i => {
    let q = qubit.at(i, default: qubit.last())
    let cs = controls.map(c => c.at(i, default: c.last()))

    assert((cs + (q,)).dedup().len() == cs.len() + 1, message: "Target and control qubits need to be all different (were " + str(q) + " and " + repr(cs) + ")")

    let ops = sort-ops(cs, q)
    gate-info(
      ops.first().at(0), ops.first().at(1), 
      n: ops.last().at(0) - ops.first().at(0) + 1, 
      supplements: ops.slice(1)
    )
  })
}


#let gate(qubit, ..args) = gate-info(qubit, gates.gate.with(..args))

#let mqgate(qubit, n: 1, ..args) = {
  gate-info(qubit, n: n, gates.mqgate.with(..args, n: n))
}

#let barrier() = gate-info(0, barrier)

#let x(..qubit) = generate-single-qubit-gate(qubit, gates.gate.with($X$))
#let y(..qubit) = generate-single-qubit-gate(qubit, gates.gate.with($Y$))
#let z(..qubit) = generate-single-qubit-gate(qubit, gates.gate.with($Z$))

#let h(..qubit) = generate-single-qubit-gate(qubit, gates.gate.with($H$))
#let s(..qubit) = generate-single-qubit-gate(qubit, gates.gate.with($S$))
#let sdg(..qubit) = generate-single-qubit-gate(qubit, gates.gate.with($S^dagger$))
#let sx(..qubit) = generate-single-qubit-gate(qubit, gates.gate.with($sqrt(X)$))
#let sxdg(..qubit) = generate-single-qubit-gate(qubit, gates.gate.with($sqrt(X)^dagger$))
#let t(..qubit) = generate-single-qubit-gate(qubit, gates.gate.with($T$))
#let tdg(..qubit) = generate-single-qubit-gate(qubit, gates.gate.with($T^dagger$))
#let p(theta, ..qubit) = generate-single-qubit-gate(qubit, gates.gate.with($P (#theta)$))

#let rx(theta, ..qubit) = generate-single-qubit-gate(qubit, gates.gate.with($R_x (#theta)$))
#let ry(theta, ..qubit) = generate-single-qubit-gate(qubit, gates.gate.with($R_y (#theta)$))
#let rz(theta, ..qubit) = generate-single-qubit-gate(qubit, gates.gate.with($R_z (#theta)$))

#let u(theta, phi, lambda, ..qubit) = generate-single-qubit-gate(
  qubit, gates.gate.with($U (#theta, #phi, #lambda)$)
)

#let meter(..qubit) = generate-single-qubit-gate(qubit, gates.meter)


#let cx(control, target, ..args) = generate-two-qubit-gate(
  control, target, gates.ctrl.with(..args), gates.targ
)
#let cz(control, target, ..args) = generate-two-qubit-gate(
  control, target, gates.ctrl.with(..args), gates.ctrl.with(0)
)
#let swap(control, target, ..args) = generate-two-qubit-gate(
  control, target, gates.swap.with(..args), gates.swap.with(0)
)
#let ccx(control1, control2, target, ..args) = generate-multi-controlled-gate(
  (control1, control2), target, gates.targ, ..args
)
#let cccx(control1, control2, control3, target, ..args) = generate-multi-controlled-gate(
  (control1, control2, control3), target, gates.targ, ..args
)
#let ccz(control1, control2, target, ..args) = generate-multi-controlled-gate(
  (control1, control2), target, gates.ctrl.with(0), ..args
)
#let cca(control1, control2, target, content, ..args) = generate-multi-controlled-gate(
  (control1, control2), target, gates.gate.with(content), ..args
)


#let ca(control, target, content) = generate-two-qubit-gate(
  control, target, gates.ctrl, gates.gate.with(content)
)

#let multi-controlled-gate(controls, qubit, target, ..args) = generate-multi-controlled-gate(
  controls, qubit, target, ..args
)


/// Constructs a circuit from operation instructions. 
/// 
/// ```example
/// #import tequila as tq
/// 
/// #quantum-circuit(
///   ..tq.build(
///     tq.h(0),
///     tq.cx(0, 1),
///     tq.sdg(1)
///   )
/// )
/// ```
#let build(

  /// Number of qubits. Can be inferred automatically. 
  /// -> auto | int 
  n: auto, 

  /// Determines at which column the subcircuit will be put in the circuit. 
  /// -> int 
  x: 1, 

  /// Determines at which row the subcircuit will be put in the circuit. 
  /// -> int 
  y: 0,

  /// If set to `true`, the a last column of outgoing wires will be added. 
  /// -> bool
  append-wire: true,
  
  /// Sequence of instructions. 
  /// -> any
  ..children

) = {
  let operations = children.pos().flatten()

  let num-qubits = n
  if num-qubits == auto {
    num-qubits = calc.max(..operations.map(x => x.qubit + calc.max(0, x.n - 1))) + 1
  }

  let tracks = ((),) * num-qubits
  
  // now we doin some Tetris
  for op in operations {
    let start = op.qubit
    let end = start + op.n - 1

    assert(start >= 0 and start < num-qubits, message: "The qubit `" + str(start) + "` is out of range. Leave `n` at `auto` if you want to automatically resize the circuit. ")
    assert(end >= 0 and end < num-qubits, message: "The qubit `" + str(end) + "` is out of range. Leave `n` at `auto` if you want to automatically resize the circuit. ")

    // Special case: barriers
    let (q1, q2) = (start, end).sorted()
    if op.constructor == barrier {
      (q1, q2) = (0, num-qubits - 1)
    }


    // Find how "high" the tracks in interval [q1, q2] are stacked so far. 
    let max-track-len = calc.max(..tracks.slice(q1, q2 + 1).map(array.len))
    let h = (start,) + op.supplements.map(supplement => supplement.first())

    // Even up the "height" of the tracks in interval [q1, q2].
    for q in range(q1, q2 + 1) {
      let dif = max-track-len - tracks.at(q).len()
      if op.constructor != barrier and q not in h {
         dif += 1
      }
      tracks.at(q) += (1,) * dif
    }

    // Place gate and supplementary gates. 
    if op.constructor != barrier {
      tracks.at(start).push((op.constructor)(x: x + tracks.at(start).len(), y: y + start))
      for (qubit, supplement) in op.supplements {
        tracks.at(qubit).push((supplement)(x: x + tracks.at(end).len(), y: y + qubit))
      }
    }
  }
  
  // Fill up all tracks
  let max-track-len = calc.max(..tracks.map(array.len)) + 1
  for q in range(tracks.len()) {
    tracks.at(q) += (1,) * (max-track-len - tracks.at(q).len())
  }
  
  let num-cols = x + calc.max(..tracks.map(array.len)) - 2
  if append-wire { num-cols += 1 }
  
  // A special placeholder guarantees that 
  // - the last wire is shown even if there are no gates on it
  // - all wires go to the last column correctly. 
  let placeholder = gates.gate(
    none, 
    x: num-cols, y: y + num-qubits - 1, 
    data: "placeholder", box: false, floating: true, 
    size-hint: (it, i) => (width: 0pt, height: 0pt)
  )

  (placeholder,) + tracks.join().filter(x => x != 1) 
}



/// Constructs a graph state preparation circuit. 
/// 
/// ```example
/// #import tequila as tq
/// 
/// #quantum-circuit(
///   ..tq.graph-state(
///     (1, 2), (2,0)
///   )
/// )
/// ```
#let graph-state(

  /// Number of qubits. Can be inferred automatically. 
  /// -> auto | int
  n: auto,

  /// Determines at which column the subcircuit will be put in the circuit. 
  /// -> int 
  x: 1,

  /// Determines at which row the subcircuit will be put in the circuit. 
  /// -> int 
  y: 0,

  /// If set to `true`, the circuit will be inverted, i.e., a circuit for
  /// "uncomputing" the corresponding graph state. 
  /// -> bool
  invert: false,

  /// -> array
  ..edges

) = {
  edges = edges.pos()
  let max-qubit = 0

  for edge in edges {
    assert(type(edge) == array, message: "Edges need to be pairs of vertices")
    assert(edge.len() == 2, message: "Every edge needs to have exactly two vertices")
    max-qubit = calc.max(max-qubit, ..edge)
  }

  let num-qubits = max-qubit + 1
  if n != auto {
    num-qubits = n
    assert(n > max-qubit, message: "")
  }

  let gates = (
    h(range(num-qubits)),
    barrier(),
    edges.map(edge => cz(..edge))
  )

  if invert {
    gates = gates.rev()
  }

  build(
    x: x, y: y, 
    ..gates
  )
}


/// Template for the quantum fourier transform (QFT). 
/// ```example
/// #import tequila as tq
/// 
/// #quantum-circuit(
///   ..tq.qft(2)
/// )
/// ```
#let qft(

  /// Number of qubits. 
  /// -> auto | int
  n, 

  /// Determines at which column the QFT routine will be placed in the circuit. 
  /// -> int 
  x: 1, 

  /// Determines at which row the QFT routine will be placed in the circuit. 
  /// -> int 
  y: 0

) = {
  let gates = ()

  for i in range(n - 1) {
    gates.push(h(i))
    for j in range(2, n - i + 1) {
      gates.push(ca(i + j - 1, i, $R_#j$))
      gates.push(p(i + j - 1))
    }
    gates.push(barrier())
  }

  gates.push(h(n - 1))
  build(n: n, x: x, y: y, ..gates)
}
