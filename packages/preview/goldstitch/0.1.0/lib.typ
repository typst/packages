// Goldstitch: antisymmetrized Goldstone diagrams for coupled-cluster theory.
//
// The compact input follows Kállay and Surján, J. Chem. Phys. 115, 2945
// (2001), Eq. (8). Fletcher supplies the drawing primitives; this module
// supplies the many-body vertex topology and layouts. Partial Hamiltonian
// contractions use the same notation as fully contracted equation diagrams.

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

// Exact topology of the 13 interaction vertices in Fig. 1 of Kállay–Surján.
// `down` is a pair of internal lines ending at the interaction, `through` has
// one internal line and one fixed continuation, and `up` is a pair of fixed
// lines. Particle/hole kinds are denoted by p/h.
#let _th(kind) = (shape: "through", kind: kind)
#let _dn = (shape: "down", kinds: ("h", "p"))
#let _up = (shape: "up", kinds: ("h", "p"))

#let _interaction-topologies = (
  (_th("p"),),
  (_th("h"),),
  (_dn,),
  (_th("p"), _th("p")),
  (_th("h"), _th("h")),
  (_th("h"), _th("p")),
  (_dn, _th("p")),
  (_dn, _th("h")),
  (_up, _th("p")),
  (_up, _th("h")),
  (_dn, _dn),
  (_up,),
  (_up, _up),
)

#let _fail(message) = panic("goldstitch: " + message)

#let _as-nonnegative-int(value, what) = {
  if type(value) != int or value < 0 {
    _fail(what + " must be a non-negative integer; got " + repr(value))
  }
  value
}

#let _parse-triplet(token) = {
  token = token.trim()
  for (open, close) in (("(", ")"), ("[", "]"), ("{", "}")) {
    if token.starts-with(open) and token.ends-with(close) {
      token = token.slice(1, -1).trim()
      break
    }
  }
  if token.match(regex("[()\\[\\]{}]")) != none {
    _fail("amplitude `" + token + "` has misplaced or mismatched brackets")
  }
  let fields
  if token.match(regex("^[0-9]{3}$")) != none {
    fields = token.clusters().map(int)
  } else {
    fields = token.split(regex("[,:/]")).map(it => it.trim())
    if fields.any(it => it == "") {
      _fail("amplitude `" + token + "` contains an empty field")
    }
    fields = fields.map(int)
  }
  if fields.len() != 3 {
    _fail("amplitude `" + token + "` must contain three integers")
  }
  fields
}

// Parse Kállay's compact representation.
//
// Accepted forms include `"220 000 000 000 4"`, the shortened `"220 4"`,
// delimited high-rank fields such as `"10/2/1 4"`, and structured input such
// as `((2, 2, 0), 4)`. The bare vertices 11 and 12 may be written `"11"` and
// `"12"`.
#let parse-kallay(code) = {
  if type(code) == dictionary {
    if "amplitudes" not in code or "interaction" not in code {
      _fail("a diagram dictionary needs `amplitudes` and `interaction` fields")
    }
    return (amplitudes: code.amplitudes, interaction: code.interaction)
  }

  // Textual and structured input share the same shape: a list of amplitude
  // fields followed by the interaction number.
  let textual = type(code) == str
  let fields = if textual {
    code.trim()
      .replace(regex("[|;@]+"), " ")
      .split(regex("\\s+"))
      .filter(it => it != "")
  } else if type(code) == array {
    code
  } else {
    _fail("notation must be a string, array, or parsed dictionary")
  }
  if fields.len() < 1 or fields.len() > 5 {
    _fail("expected up to four amplitude triplets and an interaction number")
  }

  let amplitudes = fields.slice(0, -1)
  (
    amplitudes: if textual { amplitudes.map(_parse-triplet) } else { amplitudes },
    interaction: if textual { int(fields.last()) } else { fields.last() },
  )
}

// Lower endpoints of an interaction, in group order. A `down` group
// contributes both of its internal lines, `through` a single one, `up` none.
#let _lower-ports(topology) = topology.enumerate().map(((group-index, group)) => {
  let kinds = if group.shape == "through" { (group.kind,) }
    else if group.shape == "down" { group.kinds }
    else { () }
  kinds.map(kind => (kind: kind, group-index: group-index, shape: group.shape))
}).sum(default: ())

#let _validate(model, complete: true) = {
  let interaction = _as-nonnegative-int(model.interaction, "interaction number")
  if interaction > 12 {
    _fail("interaction number must be between 0 and 12; got " + str(interaction))
  }
  if type(model.amplitudes) != array or model.amplitudes.len() > 4 {
    _fail("at most four amplitude triplets are allowed")
  }

  let amplitudes = ()
  let seen-zero = false
  let previous = none
  for (index, raw) in model.amplitudes.enumerate() {
    if type(raw) != array or raw.len() != 3 {
      _fail("amplitude " + str(index + 1) + " must contain three integers")
    }
    let values = raw.enumerate().map(((i, value)) =>
      _as-nonnegative-int(value,
        "field " + str(i + 1) + " of amplitude " + str(index + 1)))
    let (rank, internal, particles) = values

    if previous != none and rank != 0 {
      let (previous-rank, previous-internal, previous-particles) = previous
      if previous-rank > rank {
        _fail("amplitudes " + str(index) + " and " + str(index + 1)
          + " must have nondecreasing excitation levels")
      }
      if previous-rank == rank and previous-internal > internal {
        _fail("amplitudes " + str(index) + " and " + str(index + 1)
          + " have the same excitation level, so their internal-line counts "
          + "must be nondecreasing")
      }
      if (previous-rank == rank and previous-internal == internal
          and previous-particles > particles) {
        _fail("amplitudes " + str(index) + " and " + str(index + 1)
          + " have the same excitation level and internal-line count, so their "
          + "internal particle-line counts must be nondecreasing")
      }
    }
    previous = values

    if rank == 0 {
      if internal != 0 or particles != 0 {
        _fail("a zero-rank padding amplitude must be `000`")
      }
      seen-zero = true
      continue
    }
    if seen-zero { _fail("nonzero amplitudes may not follow `000` padding") }
    if internal == 0 {
      _fail("every cluster vertex in a connected diagram needs an internal line")
    }
    if internal > 2 * rank or particles > rank or particles > internal {
      _fail("invalid internal-line counts in amplitude " + str(index + 1))
    }
    let holes = internal - particles
    if holes > rank {
      _fail("amplitude " + str(index + 1) + " has too many internal hole lines")
    }
    amplitudes.push((rank: rank, internal: internal,
      particles: particles, holes: holes))
  }

  let topology = _interaction-topologies.at(interaction)
  let lower = _lower-ports(topology).map(port => port.kind)
  let expected-p = lower.filter(it => it == "p").len()
  let expected-h = lower.filter(it => it == "h").len()
  let actual-p = amplitudes.map(it => it.particles).sum(default: 0)
  let actual-h = amplitudes.map(it => it.holes).sum(default: 0)
  if (actual-p > expected-p or actual-h > expected-h
      or (complete and (actual-p, actual-h) != (expected-p, expected-h))) {
    _fail("interaction " + str(interaction) + " requires " + str(expected-p)
      + " particle and " + str(expected-h) + " hole internal lines; got "
      + str(actual-p) + " and " + str(actual-h))
  }

  (amplitudes: amplitudes, interaction: interaction, topology: topology)
}

// Typeset the complete Kállay encoding as a tuple of four triplets and η.
#let kallay-label(code) = {
  let model = _validate(parse-kallay(code), complete: false)
  let tuples = model.amplitudes.map(amplitude =>
    (amplitude.rank, amplitude.internal, amplitude.particles))
  tuples += ((0, 0, 0),) * (4 - tuples.len())

  let fields = tuples.map(((rank, internal, particles)) =>
    box($(#rank, #internal, #particles)$))
  let separator = box([,#h(0.35em)])
  let body = (fields + (box($#(model.interaction)$),)).join(separator)
  box($(#body)$)
}

#let _spread(center, width, count) = {
  if count == 0 { return () }
  if count == 1 { return (center,) }
  range(count).map(i => center - width / 2 + width * i / (count - 1))
}

#let _fermion(
  from,
  to,
  kind,
  stroke,
  mark-scale,
  mark: true,
  bend: 0deg,
) = {
  // Fletcher's inherited solid mark points toward the first edge endpoint.
  // Reverse particle edges so particles point out of T; hole edges point in.
  let (tail, head, curve) = if kind == "p" { (to, from, -bend) }
    else { (from, to, bend) }
  edge(tail, head, stroke: stroke, mark-scale: mark-scale, bend: curve,
    snap-to: (none, none),
    // The midpoint is unchanged when particle edges are reversed.
    marks: if mark { ((inherit: "solid", size: 5, pos: 0.5),) } else { () })
}

// The Hamiltonian has the same independently styled edge in both layouts.
// Presets supply defaults; dictionary fields override Fletcher edge options.
#let _hamiltonian-edge(from, to, line, stroke, spacing) = {
  let custom = if type(line) == str { (style: line) }
    else if type(line) == dictionary { line }
    else { _fail("`hamiltonian-line` must be a string or dictionary") }
  let style = custom.remove("style", default: "default")
  if style not in ("default", "dashed", "solid", "dotted", "double", "wavy") {
    _fail("unknown Hamiltonian line style " + repr(style)
      + "; expected `default`, `dashed`, `solid`, `dotted`, `double`, or `wavy`")
  }
  if "vertices" in custom {
    _fail("Hamiltonian `vertices` are determined by the diagram topology")
  }
  let wave = custom.remove("wave", default: (:))
  if type(wave) != dictionary { _fail("`wave` must be a dictionary") }
  if wave.len() > 0 and style != "wavy" {
    _fail("`wave` options require the `wavy` style")
  }
  let options = (
    stroke: 0.7 * stroke,
    dash: if style in ("default", "dashed") {
      (array: (1pt, 1.25pt), phase: 0pt)
    } else if style == "dotted" { "dotted" } else { none },
    snap-to: (none, none),
    layer: 1,
  )
  if style == "double" { options.extrude = (-2, 2) }
  if style == "wavy" {
    // Count waves explicitly so short one-endpoint interactions work too.
    let width = calc.abs(to.at(0) - from.at(0)) * spacing
    let geometry = (amplitude: 1pt,
      segments: calc.max(2, int(calc.round(width / 4pt)))) + wave
    options.decorations = fletcher.cetz.decorations.wave.with(..geometry)
  }
  options += custom
  edge(from, to, ..options)
}

// Attach `targets.len()` of the `sources` abscissae to the targets.
//
// A dynamic program picks the subset and the pairing that minimise the total
// horizontal displacement while keeping both sides in the same left-to-right
// order, so contractions of one species never cross each other.
#let _monotone-assignment(sources, targets) = {
  let ordered = targets.sorted(key: target => target.x)
  let m = ordered.len()
  if m == 0 { return () }
  let indices = range(sources.len()).sorted(key: i => sources.at(i))
  let n = indices.len()

  // cost.at(i).at(j): best total for the first j targets using the first i
  // sources; choice records whether source i-1 was matched to target j-1.
  let infinity = calc.inf
  let cost = ((infinity,) * (m + 1),) * (n + 1)
  let choice = ((false,) * (m + 1),) * (n + 1)
  for i in range(n + 1) { cost.at(i).at(0) = 0.0 }
  for i in range(1, n + 1) {
    for j in range(1, calc.min(i, m) + 1) {
      let skip = cost.at(i - 1).at(j)
      let take = (cost.at(i - 1).at(j - 1)
        + calc.abs(sources.at(indices.at(i - 1)) - ordered.at(j - 1).x))
      if take <= skip {
        cost.at(i).at(j) = take
        choice.at(i).at(j) = true
      } else {
        cost.at(i).at(j) = skip
      }
    }
  }

  let result = ()
  let (i, j) = (n, m)
  while j > 0 {
    if choice.at(i).at(j) {
      result.push((source-index: indices.at(i - 1), target: ordered.at(j - 1)))
      j -= 1
    }
    i -= 1
  }
  result.rev()
}

// Move only fully open particle–hole pairs to one end of T. Preserve the
// relative order of all contracted sites, including those with one open leg.
#let _outer-open-assignments(xs, particles, holes, open-side: 0) = {
  let lines = particles + holes
  let counts = range(xs.len()).map(i =>
    lines.filter(line => line.source-index == i).len())
  let orders = (1, -1).map(direction =>
    range(xs.len()).sorted(key: i =>
      direction * if counts.at(i) == 0 { 0 } else { 1 }))
  let cost(order) = lines.map(line =>
    calc.abs(xs.at(order.position(i => i == line.source-index)) - line.target.x))
    .sum(default: 0.0)
  // In a multi-T diagram, face open pairs outward before minimizing length.
  // With no preferred side, ties put open pairs left. Both sorts are stable.
  let order = if open-side < 0 { orders.first() }
    else if open-side > 0 { orders.last() }
    else if cost(orders.last()) < cost(orders.first()) { orders.last() }
    else { orders.first() }
  let remap(assignment) = assignment.map(line => line + (
    source-index: order.position(i => i == line.source-index),))
  (p-assignment: remap(particles), h-assignment: remap(holes))
}

#let _free-leg-side(x, partner-x, fallback) = {
  if partner-x == none or partner-x == x { fallback }
  else if partner-x < x { 1 } else { -1 }
}

// Abscissae of open cluster legs where they pass the Hamiltonian level.
#let _open-cluster-xs(placements, group-x, offset) = {
  let result = ()
  for placement in placements {
    for (i, x) in placement.pair-xs.enumerate() {
      let p = placement.p-assignment.find(line => line.source-index == i)
      let h = placement.h-assignment.find(line => line.source-index == i)
      for (line, partner, fallback) in ((p, h, 1), (h, p, -1)) {
        if line != none { continue }
        let partner-x = if partner == none { none }
          else { group-x.at(partner.target.group-index) }
        result.push(x + _free-leg-side(x, partner-x, fallback) * offset)
      }
    }
  }
  result
}

#let _interaction-crossings(placements, group-x, offset) = {
  let xs = group-x.sorted()
  let left = xs.first()
  let right = if xs.len() == 1 { left + 0.52 } else { xs.last() }
  _open-cluster-xs(placements, group-x, offset)
    .filter(x => left <= x and x <= right).len()
}

// Move shared lower endpoints away from unrelated open legs at H height.
// Keep closed lenses and through-lines fixed, and preserve the side of every
// contraction so moving H cannot reverse an open leg's fan direction.
#let _clear-hamiltonian-vertices(placements, topology, group-x, offset, clearance) = {
  if clearance <= 0 { return group-x }
  let free-xs = _open-cluster-xs(placements, group-x, offset)
  let center = group-x.sum() / group-x.len()
  let sources = ((),) * topology.len()
  for placement in placements {
    for line in placement.p-assignment + placement.h-assignment {
      sources.at(line.target.group-index).push(placement.pair-xs.at(line.source-index))
    }
  }
  for (i, group) in topology.enumerate() {
    let sites = sources.at(i)
    if group.shape != "down" or sites.dedup().len() < 2 { continue }
    let original = group-x.at(i)
    if free-xs.all(x => calc.abs(original - x) >= clearance) { continue }
    // The nearest safe position lies on an exclusion interval's boundary.
    let candidates = free-xs.map(x => (x - clearance, x + clearance)).sum(default: ())
      .filter(x => sites.all(site => (x - site) * (original - site) > 0)
        and free-xs.all(free => calc.abs(x - free) >= clearance - 1e-9)
        and group-x.enumerate().all(((j, other)) => i == j or (
          (x - other) * (original - other) > 0
          and calc.abs(x - other) >= 2 * clearance - 1e-9)))
    if candidates.len() > 0 {
      // Prefer clearing the leg outward, preserving room between H endpoints.
      // Fall back to the nearest safe position if no outward move is feasible.
      group-x.at(i) = candidates.sorted(key: x => (
        if (x - original) * (original - center) > 0 { 0 } else { 1 },
        calc.round(calc.abs(x - original), digits: 9), -calc.abs(x - center),
      )).first()
    }
  }
  group-x
}

// Choose T attachment sites first, then center H on the actual sites. Using
// whole-bar centers instead tilts closed lenses and leaves wide bars lopsided.
#let _symmetric-attachments(placements, targets, topology,
  through-offset: 0.0, clearance: 0.0,
) = {
  let desired = ((),) * topology.len()
  for placement in placements {
    let target = targets.at(placement.original-index)
    let ports = target.p + target.h
    let groups = ports.map(port => port.group-index).dedup().sorted()
    // Seed multiple H endpoints at opposite ends. After assignment, fully
    // open pairs move to an outer block and H follows the contracted sites.
    let anchors = if groups.len() == 1 { (placement.pair-xs.last(),) } else {
      _spread(placement.center,
        placement.pair-xs.last() - placement.pair-xs.first(), groups.len())
    }
    for port in ports {
      desired.at(port.group-index).push(
        anchors.at(groups.position(it => it == port.group-index)))
    }
  }
  let provisional = desired.map(xs =>
    if xs.len() == 0 { 0.0 } else { xs.sum() / xs.len() })
  let attached = ((),) * topology.len()
  let xs = placements.map(placement => placement.pair-xs).sum(default: ()).sorted()
  let diagram-center = if xs.len() == 0 { 0.0 } else {
    (xs.first() + xs.last()) / 2
  }
  placements = placements.map(placement => {
    let target = targets.at(placement.original-index)
    let assign(kind) = _monotone-assignment(placement.pair-xs,
      target.at(kind).map(port => port + (x: provisional.at(port.group-index))))
    let open-side = if placements.len() <= 1 { 0 }
      else if placement.center < diagram-center { -1 }
      else if placement.center > diagram-center { 1 } else { 0 }
    placement + _outer-open-assignments(placement.pair-xs, assign("p"), assign("h"),
      open-side: open-side)
  })
  for placement in placements {
    for line in placement.p-assignment + placement.h-assignment {
      attached.at(line.target.group-index).push((
        x: placement.pair-xs.at(line.source-index), center: placement.center))
    }
  }
  let group-x = attached.enumerate().map(((i, sites)) => {
    if sites.len() == 0 { return none }
    let x = sites.map(site => site.x).sum() / sites.len()
    if topology.at(i).shape != "through" { return x }
    // Lean toward the bar interior, or toward the other H endpoint for T1.
    // With neither cue, use the usual particle-right / hole-left convention.
    let center = sites.first().center
    let toward = if center != x { center } else {
      provisional.sum() / provisional.len()
    }
    let side = if toward > x { 1 } else if toward < x { -1 }
      else if topology.at(i).kind == "p" { 1 } else { -1 }
    x + side * through-offset
  })
  // Upper-only endpoints have no attachment to center on. Keep them beside
  // the attached endpoint; bare interactions are centered on the origin.
  if group-x.all(x => x == none) {
    group-x = _spread(0.0, 0.52 * (topology.len() - 1), topology.len())
  } else {
    for i in range(group-x.len()) {
      if group-x.at(i) == none {
        let other = 1 - i // The interaction has at most two endpoints.
        let preferred = group-x
        preferred.at(i) = group-x.at(other) + (i - other) * 0.52
        let mirrored = group-x
        mirrored.at(i) = group-x.at(other) - (i - other) * 0.52
        group-x = if (_interaction-crossings(placements, mirrored, through-offset)
          < _interaction-crossings(placements, preferred, through-offset)) {
          mirrored
        } else { preferred }
      }
    }
  }
  group-x = _clear-hamiltonian-vertices(placements, topology, group-x,
    through-offset, clearance)
  placements = placements.map(placement => {
    let update(lines) = lines.map(line => line + (
      target: line.target + (x: group-x.at(line.target.group-index)),))
    placement + (p-assignment: update(placement.p-assignment),
      h-assignment: update(placement.h-assignment))
  })
  (placements: placements, group-x: group-x)
}

#let _place-clusters(items) = {
  let pair-gap = 0.64
  let bar-pad = 0.14
  let block-gap = 0.28
  let widths = items.map(item =>
    (item.amplitude.rank - 1) * pair-gap + 2 * bar-pad)
  let total-width = (widths.sum(default: 0)
    + block-gap * calc.max(0, widths.len() - 1))
  let cursor = -total-width / 2
  let placements = ()
  for ((item, width)) in items.zip(widths) {
    let center = cursor + width / 2
    let pair-xs = _spread(center, pair-gap * (item.amplitude.rank - 1),
      item.amplitude.rank)
    placements.push(item + (center: center, pair-xs: pair-xs))
    cursor += width + block-gap
  }
  placements
}

#let _permutations(items) = {
  if items.len() == 0 { return ((),) }
  let result = ()
  for (i, item) in items.enumerate() {
    for rest in _permutations(items.slice(0, i) + items.slice(i + 1)) {
      result.push((item,) + rest)
    }
  }
  result
}

// At most four T vertices: compare all orders, retaining the symmetric seed
// order on ties. Port ownership and the outward placement of free pairs stay
// unchanged; only the spatial order of whole bars is varied.
#let _layout-clusters(items, targets, topology, through-offset: 0.0, clearance: 0.0) = {
  let layout(order) = _symmetric-attachments(_place-clusters(order), targets, topology,
    through-offset: through-offset, clearance: clearance)
  let crossings(candidate) = _interaction-crossings(candidate.placements,
    candidate.group-x, through-offset)
  let best = layout(items)
  let count = crossings(best)
  if count == 0 or items.len() <= 1 { return best }
  // Among improvements, try wider bars on the left first; compact closed
  // vertices can then sit to their right instead of enclosing free pairs.
  for order in _permutations(items.sorted(key: item => -item.amplitude.rank)) {
    let candidate = layout(order)
    let next = crossings(candidate)
    // A coincident pair of H endpoints is not a valid way to save crossings.
    let xs = candidate.group-x.sorted()
    let separated = xs.len() == 1 or xs.last() - xs.first() >= 0.4
    if next < count and separated {
      best = candidate
      count = next
      if count == 0 { break }
    }
  }
  best
}

// Prefer an H–T contraction, even for a hole-only connection.
// Bare interactions and diagrams with only bent contractions fall back to a
// straight external H leg. Closed lenses remain unmarked in minimal mode.
#let _minimal-arrow(segments, aspect) = {
  let candidates = range(segments.len()).filter(index => {
    let segment = segments.at(index)
    let at-h = segment.tail.starts-with("h") or segment.head.starts-with("h")
    at-h and segment.at("bend", default: 0deg) == 0deg
  }).sorted(key: index => {
    let segment = segments.at(index)
    let internal = segment.tail.starts-with("t") or segment.head.starts-with("t")
    let dx = segment.to.at(0) - segment.from.at(0)
    let dy = (segment.to.at(1) - segment.from.at(1)) * aspect
    (if internal { 0 } else { 1 }, if segment.kind == "p" { 0 } else { 1 },
      -(dx * dx + dy * dy))
  })
  candidates.slice(0, calc.min(1, candidates.len()))
}

// Draw an antisymmetrized Goldstone diagram from Kállay notation.
//
// Each T_r vertex is a solid horizontal bar with r particle-hole line pairs.
// The selected interaction is drawn with the exact lower/through/upper topology
// of Fig. 1. The notation determines which T lines are internal; remaining
// lines and the upper parts of the interaction are fixed external lines.
#let _equation-goldstone(
  code,
  spacing: 7.5mm,
  level-gap: 4.5mm,
  stroke: 0.65pt,
  hamiltonian-line: "default",
  labels: false,
  excitation-symbol: $T$,
  mark-scale: 100%,
  arrows: "minimal",
  leg-angle: 20deg,
  loop-bend: 75deg,
  t1-bar-extension: 2.5pt,
  debug: false,
) = {
  let model = _validate(parse-kallay(code))
  if arrows not in ("minimal", "all") {
    _fail("`arrows` must be `minimal` or `all`")
  }
  let amplitudes = model.amplitudes
  // For H5 coupled to a single saturated T1, use the equivalent split form
  // shown by Kállay and Surján: an upper V at one interaction endpoint and a
  // lower particle-hole pair at the other.
  let split-h5 = (model.interaction == 5 and amplitudes.len() == 1
    and amplitudes.first().rank == 1
    and amplitudes.first().internal == 2
    and amplitudes.first().particles == 1)
  let topology = if split-h5 { (_up, _dn) } else { model.topology }
  let objects = ()
  let upper-y = -0.5
  let t-y = 1.0
  // Measure vertical percentages upward from the cluster level: H is at 45%
  // of the total height.
  let total-height = t-y - upper-y
  let h-y = t-y - 0.45 * total-height
  // Diagram units are anisotropic; `aspect` converts a vertical run into the
  // horizontal run that subtends the same visual angle.
  let aspect = level-gap / spacing
  // Horizontal offset of an external leg leaving a vertex at `leg-angle / 2`.
  let fan = calc.tan(leg-angle / 2) * (t-y - upper-y) * aspect

  // Build logical interaction ports before assigning horizontal positions.
  // This lets equivalent Hamiltonian endpoints be mirrored to follow the T
  // order instead of forcing unnecessary crossings.
  let lower-ports = _lower-ports(topology)

  // At a lower V, keep a particle–hole contraction from the same amplitude
  // paired at one H endpoint. Assign remaining same-species ports in tuple
  // order.
  let targets = ((p: (), h: ()),) * amplitudes.len()
  let remaining = amplitudes.map(a => (p: a.particles, h: a.holes))
  let claimed-down-groups = ()
  for p-port in lower-ports.filter(port =>
    port.shape == "down" and port.kind == "p") {
    let h-port = lower-ports.find(port =>
      port.shape == "down" and port.kind == "h"
        and port.group-index == p-port.group-index)
    let candidates = range(amplitudes.len()).filter(i =>
      remaining.at(i).p > 0 and remaining.at(i).h > 0)
    if h-port != none and candidates.len() > 0 {
      let i = candidates.first()
      targets.at(i).p.push(p-port)
      targets.at(i).h.push(h-port)
      remaining.at(i).p -= 1
      remaining.at(i).h -= 1
      claimed-down-groups.push(p-port.group-index)
    }
  }
  for kind in ("p", "h") {
    let labels = ()
    for (i, counts) in remaining.enumerate() {
      labels += (i,) * counts.at(kind)
    }
    let ports = lower-ports.filter(port =>
      port.kind == kind and not (
        port.shape == "down" and port.group-index in claimed-down-groups))
    for ((label, port)) in labels.zip(ports) {
      targets.at(label).at(kind).push(port)
    }
  }

  let items = amplitudes.enumerate().map(((i, amplitude)) =>
    (amplitude: amplitude, original-index: i))

  // Validation establishes the canonical tuple order, but the drawing may
  // reorient T vertices horizontally. Group vertices by the Hamiltonian
  // endpoint they contract with, placing vertices that span two endpoints
  // between the single-endpoint groups. This shortens contractions and avoids
  // the crowded hole-hole-particle-particle layout produced by canonical
  // ordering. The original index makes ties deterministic.
  let endpoint-of(item) = {
    let target = targets.at(item.original-index)
    let ports = target.p + target.h
    ports.map(port => port.group-index).sum() / ports.len()
  }
  // Ties are broken in tuple order left of the diagram centre and in reverse
  // order right of it, so that a diagram whose two halves carry the same
  // vertices is laid out as their mirror image instead of their translation.
  let midpoint = items.map(endpoint-of).sum(default: 0.0) / calc.max(1, items.len())
  let placed = items.sorted(key: item => {
    let endpoint = endpoint-of(item)
    let orientation = if endpoint <= midpoint { 1 } else { -1 }
    endpoint + 0.0001 * orientation * item.original-index
  })

  let layout = _layout-clusters(placed, targets, topology,
    through-offset: fan * (t-y - h-y) / total-height,
    clearance: 3pt / spacing)
  let placements = layout.placements
  let group-x = layout.group-x
  let group-xs = group-x.sorted()

  // Draw the cluster bars and collect the fermion segments.
  //
  // Gather segments before drawing so minimal mode can choose at most one
  // arrowhead for the whole diagram, on a straight Hamiltonian segment.
  let segments = ()
  let internal-lines = ()
  for placement in placements {
    let amplitude = placement.amplitude
    let p-assignment = placement.p-assignment
    let h-assignment = placement.h-assignment
    // For r > 1 the T_r bar joins the outermost fermion vertices exactly.
    // A T1 bar extends a few points to either side of its sole vertex.
    if amplitude.rank == 1 {
      let vertex = (placement.pair-xs.first(), t-y)
      objects.push(edge(
        (rel: (180deg, t1-bar-extension), to: vertex),
        (rel: (0deg, t1-bar-extension), to: vertex),
        stroke: stroke, snap-to: (none, none), layer: 2,
      ))
    } else {
      objects.push(edge(
        (placement.pair-xs.first(), t-y),
        (placement.pair-xs.last(), t-y),
        stroke: stroke, snap-to: (none, none), layer: 2,
      ))
    }

    for (pair-index, x) in placement.pair-xs.enumerate() {
      let p-line = p-assignment.find(it => it.source-index == pair-index)
      let h-line = h-assignment.find(it => it.source-index == pair-index)
      let vertex = "t" + str(placement.original-index) + ":" + str(pair-index)

      // Free pairs split `leg-angle` evenly (80–20–80 by default). When one
      // leg is contracted, keep the free leg at that preferred angle on the
      // opposite side of the Hamiltonian connection.
      for (kind, line, partner, free-side) in (
        ("h", h-line, p-line, -1),
        ("p", p-line, h-line, 1),
      ) {
        if line != none { continue }
        let side = _free-leg-side(x,
          if partner == none { none } else { partner.target.x }, free-side)
        let outer = "e:" + vertex + ":" + kind
        // Particles leave a cluster vertex, holes enter it.
        segments.push((
          from: (x, t-y), to: (x + side * fan, upper-y), kind: kind,
          tail: if kind == "p" { vertex } else { outer },
          head: if kind == "p" { outer } else { vertex },
        ))
      }

      for (kind, line) in (("p", p-line), ("h", h-line)) {
        if line == none { continue }
        internal-lines.push((
          from: (x, t-y), to: (line.target.x, h-y), kind: kind,
          vertex: vertex, group: "h" + str(line.target.group-index),
        ))
      }

      // Filled T vertex at every particle–hole attachment to the cluster bar.
      objects.push(node((x, t-y), shape: "circle", radius: 1.25pt,
        fill: black, stroke: none, inset: 0pt, snap: false, layer: 3))
    }

    if labels {
      objects.push(node((placement.center, t-y + 0.22),
        $#excitation-symbol _#(amplitude.rank)$, inset: 0pt, snap: false))
    }
  }

  // Open a lens between coincident particle/hole contractions.
  for line in internal-lines {
    let coincident = internal-lines.any(other =>
      other.kind != line.kind and other.from == line.from and other.to == line.to)
    let bend = if not coincident { 0deg }
      else if line.kind == "p" { loop-bend / 2 } else { -loop-bend / 2 }
    segments.push((
      from: line.from, to: line.to, kind: line.kind, bend: bend,
      tail: if line.kind == "p" { line.vertex } else { line.group },
      head: if line.kind == "p" { line.group } else { line.vertex },
    ))
  }

  // Continue through-lines with the same slope on both sides of H. Together
  // with the free T leg this makes a symmetric V, without a kink at H.
  let upper-rise = h-y - upper-y
  for (group-index, group) in topology.enumerate() {
    let x = group-x.at(group-index)
    let vertex = "h" + str(group-index)
    if group.shape == "through" {
      let lower = internal-lines.find(line => line.group == vertex)
      let run = (x - lower.from.at(0)) * upper-rise / (t-y - h-y)
      segments.push((
        from: (x, h-y), to: (x + run, upper-y), kind: group.kind,
        tail: if group.kind == "p" { vertex } else { "e:" + vertex },
        head: if group.kind == "p" { "e:" + vertex } else { vertex },
      ))
    } else if group.shape == "up" {
      let half = calc.tan(leg-angle) * upper-rise * aspect
      segments.push((
        from: (x, h-y), to: (x - half, upper-y), kind: "h",
        tail: "e:" + vertex + ":h", head: vertex,
      ))
      segments.push((
        from: (x, h-y), to: (x + half, upper-y), kind: "p",
        tail: vertex, head: "e:" + vertex + ":p",
      ))
    }
  }

  let marked = _minimal-arrow(segments, aspect)

  for (index, segment) in segments.enumerate() {
    objects.push(_fermion(segment.from, segment.to, segment.kind,
      stroke, mark-scale,
      bend: segment.at("bend", default: 0deg),
      mark: arrows == "all" or index in marked))
  }

  // Hamiltonian line. A single endpoint has the conventional dangling
  // segment to its right.
  let dash-left = group-xs.first()
  let dash-right = if group-xs.len() == 1 { dash-left + 0.52 }
    else { group-xs.last() }
  objects.push(_hamiltonian-edge((dash-left, h-y), (dash-right, h-y),
    hamiltonian-line, stroke, spacing))

  // Open Hamiltonian vertices cover the joins between solid fermion lines and
  // the interaction edge.
  for x in group-xs {
    objects.push(node((x, h-y), shape: "circle", radius: 1.275pt,
      fill: white, stroke: 0.65pt + black, inset: 0pt,
      snap: false, layer: 4))
  }

  if labels {
    objects.push(node(((dash-left + dash-right) / 2, upper-y - 0.16),
      $H_#(model.interaction)$, inset: 0pt, snap: false))
  }

  return diagram(
    ..objects,
    axes: (ltr, ttb),
    cell-size: (spacing, level-gap),
    spacing: 0pt,
    edge-stroke: stroke,
    node-inset: 0pt,
    mark-scale: 100%,
    debug: debug,
  )
}

// The extended renderer works from an explicit port graph. Every fermion
// segment consumes one creation and one annihilation port, with an external
// endpoint for an unused port. This separates incidence from spatial layout.
#let _upper-ports(topology) = topology.enumerate().map(((i, group)) => {
  let kinds = if group.shape == "through" { (group.kind,) }
    else if group.shape == "up" { group.kinds } else { () }
  kinds.map(kind => (kind: kind, group-index: i, shape: group.shape))
}).sum(default: ())

// Accept Kállay strings, structured arrays (including json() output), parsed
// dictionaries, and our normalized output. Revalidate cached models too.
#let parse-diagram(code) = {
  if type(code) == dictionary and "base-code" in code { code = code.base-code }
  let model = _validate(parse-kallay(code), complete: false)
  let upper = _upper-ports(model.topology)
  let capacities = ((upper.filter(it => it.kind == "p").len(),
    upper.filter(it => it.kind == "h").len()),)
  capacities += model.amplitudes.map(a => (a.rank - a.particles, a.rank - a.holes))
  model + (base-code: code, capacities: capacities)
}

#let _signature(model) = {
  let lower = _lower-ports(model.topology)
  let cp = model.capacities.map(it => it.first()).sum()
  let ch = model.capacities.map(it => it.last()).sum()
  let ap = (lower.filter(it => it.kind == "p").len()
    - model.amplitudes.map(it => it.particles).sum(default: 0))
  let ah = (lower.filter(it => it.kind == "h").len()
    - model.amplitudes.map(it => it.holes).sum(default: 0))
  (cp, ch, ap, ah)
}

// Created particles/holes, annihilated particles/holes (quasiparticles).
#let diagram-signature(code) = _signature(parse-diagram(code))

// Geometry is deliberately inspectable: regression tests reconstruct all
// H--T incidences from the SAME segments consumed by the renderer.
#let _operator-layout(model, aspect: 0.6, leg-angle: 20deg, loop-bend: 75deg) = {
  let vertices = ()
  let bars = ()
  let sources = ()
  // Rank-r T bars have r sites, each with exactly one p and one h port.
  let y = 1.6
  let placements = _place-clusters(model.amplitudes.enumerate().map(((i, a)) =>
    (amplitude: a, original-index: i)))
  for placement in placements {
    let id = "t" + str(placement.original-index)
    let ports = (p: (), h: ())
    for (k, x) in placement.pair-xs.enumerate() {
      let site = (id: id + ":" + str(k), at: (x, y), family: "t")
      vertices.push(site)
      ports.p.push(site)
      ports.h.push(site)
    }
    bars.push((id: id, family: "t", rank: placement.amplitude.rank,
      xs: placement.pair-xs, y: y, center: placement.center))
    sources.push(ports)
  }
  let group-x = _spread(0.0, 0.52 * (model.topology.len() - 1), model.topology.len())
  let h-sites = group-x.enumerate().map(((j, x)) =>
    (id: "h" + str(j), at: (x, 0.0), family: "h"))
  vertices += h-sites
  let h-upper = (p: (), h: ())
  let h-lower = (p: (), h: ())
  for port in _upper-ports(model.topology) {
    h-upper.at(port.kind).push(h-sites.at(port.group-index))
  }
  for port in _lower-ports(model.topology) {
    h-lower.at(port.kind).push(h-sites.at(port.group-index))
  }
  let segments = ()
  let connection(creator, annihilator, kind, external: none) = (
    from: creator.at, to: annihilator.at, kind: kind, external: external,
    creator: creator.id, annihilator: annihilator.id,
    tail: if kind == "p" { creator.id } else { annihilator.id },
    head: if kind == "p" { annihilator.id } else { creator.id },
  )
  // Consume H annihilators first. Same-species ports are indistinguishable
  // within a tensor; selecting sites here fixes a deterministic drawing only.
  for (j, amplitude) in model.amplitudes.enumerate() {
    for (kind, count) in (("p", amplitude.particles), ("h", amplitude.holes)) {
      for k in range(count) {
        let creator = sources.at(j).at(kind).remove(0)
        let annihilator = h-lower.at(kind).remove(0)
        segments.push(connection(creator, annihilator, kind))
      }
    }
  }
  sources = (h-upper,) + sources
  // Short open stubs, upward for creation and downward for annihilation.
  // They need not reach a common projection boundary in an operator diagram.
  let reach = 0.6
  let fan = calc.tan(leg-angle / 2) * reach * aspect
  for (ports, creation) in ((sources, true), ((h-lower,), false)) {
    for vertex-ports in ports {
      for kind in ("p", "h") {
        for site in vertex-ports.at(kind) {
          let side = if kind == "p" { 1 } else { -1 }
          let direction = if creation { -1 } else { 1 }
          let offset = if site.family == "h" {
            calc.tan(leg-angle) * reach * aspect
          } else { fan }
          let free = (id: "e:" + site.id + ":" + kind + ":" + repr(creation),
            at: (site.at.first() - direction * side * offset,
              site.at.last() + direction * reach))
          segments.push(if creation {
            connection(site, free, kind, external: "creation")
          } else { connection(free, site, kind, external: "annihilation") })
        }
      }
    }
  }
  // Separate opposite-species edges with identical endpoints into lenses.
  segments = segments.map(line => {
    let paired = segments.any(other => other.kind != line.kind
      and other.creator == line.creator and other.annihilator == line.annihilator)
    line + (bend: if not paired { 0deg }
      else if line.kind == "p" { loop-bend / 2 } else { -loop-bend / 2 })
  })
  (vertices: vertices, bars: bars, segments: segments, group-x: group-x)
}

#let _operator-goldstone(
  model, spacing: 7.5mm, level-gap: 4.5mm, stroke: 0.65pt,
  hamiltonian-line: "default", labels: false, excitation-symbol: $T$,
  mark-scale: 85%, arrows: "all", leg-angle: 20deg,
  loop-bend: 75deg, t1-bar-extension: 2.5pt, debug: false,
) = {
  if arrows not in ("minimal", "all") { _fail("`arrows` must be `minimal` or `all`") }
  let layout = _operator-layout(model, aspect: level-gap / spacing,
    leg-angle: leg-angle, loop-bend: loop-bend)
  let objects = ()
  let marked = _minimal-arrow(layout.segments, level-gap / spacing)
  for (i, segment) in layout.segments.enumerate() {
    objects.push(_fermion(segment.from, segment.to, segment.kind, stroke,
      mark-scale, bend: segment.bend, mark: arrows == "all" or i in marked))
  }
  for bar in layout.bars {
    let left = (bar.xs.first(), bar.y)
    let right = (bar.xs.last(), bar.y)
    if bar.rank == 1 {
      left = (rel: (180deg, t1-bar-extension), to: left)
      right = (rel: (0deg, t1-bar-extension), to: right)
    }
    objects.push(edge(left, right, stroke: stroke, snap-to: (none, none), layer: 2))
    if labels {
      objects.push(node((bar.center, bar.y + 0.45),
        $#excitation-symbol _#(bar.rank)$, inset: 0pt, snap: false))
    }
  }
  let left = layout.group-x.first()
  let right = if layout.group-x.len() == 1 { left + 0.52 } else { layout.group-x.last() }
  objects.push(_hamiltonian-edge((left, 0), (right, 0),
    hamiltonian-line, stroke, spacing))
  for vertex in layout.vertices {
    objects.push(node(vertex.at, shape: "circle", radius: 1.275pt,
      fill: if vertex.family == "h" { white } else { black },
      stroke: if vertex.family == "h" { 0.65pt + black } else { none },
      inset: 0pt, snap: false, layer: 4))
  }
  if labels {
    objects.push(node((left - 0.7, 0), $H_#(model.interaction)$,
      inset: 0pt, snap: false))
  }
  diagram(..objects, axes: (ltr, ttb), cell-size: (spacing, level-gap),
    spacing: 0pt, edge-stroke: stroke, node-inset: 0pt, debug: debug)
}

// Auto preserves the established equation layout for fully contracted H lower
// legs. Partially contracted operators use the port-graph renderer. Explicit
// `mode: "operator"` forces that layout even for pure-creation sectors;
// `mode: "equation"` requires complete Hamiltonian annihilation contractions.
#let goldstone(code, mode: "auto", ..options) = {
  if mode not in ("auto", "equation", "operator") {
    _fail("`mode` must be `auto`, `equation`, or `operator`")
  }
  let model = parse-diagram(code)
  if mode == "equation" {
    return _equation-goldstone(model.base-code, ..options)
  }
  if mode == "auto" and _signature(model).slice(2) == (0, 0) {
    return _equation-goldstone(model.base-code, ..options)
  }
  _operator-goldstone(model, ..options)
}
