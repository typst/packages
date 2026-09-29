#import "protocol.typ": request, data, result-data, analysis-model, execution-policy
#import "annotations.typ": highlight-positions, pair-annotation, color-scale, value-annotations

#let analyze(sequence, model: analysis-model(), constraints: none, execution: execution-policy(), id: none) = request(
  "analyze",
  ("sequence": sequence),
  model: model,
  constraints: constraints,
  execution: execution,
  id: id,
)

/// Return the operations, layouts, and decoders supported by the stable engine.
#let capabilities() = request("capabilities", (:))

/// Metadata and SHA-256 fingerprints for the embedded thermodynamic model.
#let parameters() = request("parameters", (:))

/// Validate and parse extended dot-bracket notation.
#let validate(sequence, structure, execution: execution-policy(), id: none) = request(
  "validate", ("sequence": sequence, "structure": structure), execution: execution, id: id,
)

#let _contiguous-segments(positions) = {
  let segments = ()
  if positions.len() > 0 {
    let first = positions.first()
    let previous = first
    for position in positions.slice(1) {
      if position != previous + 1 {
        segments.push((from: first, to: previous))
        first = position
      }
      previous = position
    }
    segments.push((from: first, to: previous))
  }
  segments
}

/// Identify stems and planar loop motifs from a supplied structure. Crossing
/// pairs remain available in `parsed` but motif classification uses bracket
/// level zero, where hairpin/internal/multiloop nesting is well-defined.
#let structure-elements(sequence, structure, execution: execution-policy()) = {
  let parsed = data(validate(sequence, structure, execution: execution))
  let planar = parsed.pairs.filter(pair => pair.level == 0).sorted(key: pair => pair.i)
  let stems = ()
  for pair in planar {
    let has-outer-neighbor = planar.any(other => other.i == pair.i - 1 and other.j == pair.j + 1)
    if not has-outer-neighbor {
      let pairs = (pair,)
      let current = pair
      let next = planar.find(other => other.i == current.i + 1 and other.j == current.j - 1)
      while next != none {
        pairs.push(next)
        current = next
        next = planar.find(other => other.i == current.i + 1 and other.j == current.j - 1)
      }
      let positions = ()
      for entry in pairs {
        if entry.i not in positions { positions.push(entry.i) }
        if entry.j not in positions { positions.push(entry.j) }
      }
      stems.push((
        kind: "stem",
        index: stems.len() + 1,
        pairs: pairs,
        positions: positions.sorted(),
        outer-pair: pairs.first(),
        inner-pair: pairs.last(),
        length: pairs.len(),
      ))
    }
  }
  let loops = ()
  for stem in stems {
    let closing = stem.inner-pair
    let contained = stems.filter(candidate => {
      let outer = candidate.outer-pair
      outer.i > closing.i and outer.j < closing.j
    })
    let children = contained.filter(candidate => not contained.any(other => {
      other != candidate and other.outer-pair.i < candidate.outer-pair.i and other.outer-pair.j > candidate.outer-pair.j
    }))
    let positions = range(closing.i + 1, closing.j).filter(position => not children.any(child =>
      position >= child.outer-pair.i and position <= child.outer-pair.j
    ))
    let loop-kind = if children.len() == 0 { "hairpin" }
    else if children.len() == 1 {
      let child = children.first().outer-pair
      let left = child.i - closing.i - 1
      let right = closing.j - child.j - 1
      if left == 0 or right == 0 { "bulge" } else { "internal" }
    } else { "multiloop" }
    loops.push((
      kind: loop-kind,
      index: loops.filter(loop => loop.kind == loop-kind).len() + 1,
      closing-pair: closing,
      child-stems: children.map(child => child.index),
      positions: positions,
      segments: _contiguous-segments(positions),
    ))
  }
  let top-level = stems.filter(candidate => not stems.any(other =>
    other != candidate and other.outer-pair.i < candidate.outer-pair.i and other.outer-pair.j > candidate.outer-pair.j
  ))
  let exterior-positions = range(1, parsed.length + 1).filter(position => not top-level.any(stem =>
    position >= stem.outer-pair.i and position <= stem.outer-pair.j
  ))
  (
    parsed: parsed,
    stems: stems,
    loops: loops,
    exterior: (
      kind: "exterior",
      index: 1,
      positions: exterior-positions,
      segments: _contiguous-segments(exterior-positions),
    ),
  )
}

/// Convert one element returned by `structure-elements` to renderer layers.
#let element-annotations(element, fill: auto, stroke: auto, radius: auto, pair-stroke: auto) = {
  let annotations = (highlight-positions(
    element.at("positions", default: ()),
    fill: fill,
    stroke: stroke,
    radius: radius,
  ),)
  if element.kind == "stem" and pair-stroke != auto {
    annotations += element.pairs.map(pair => pair-annotation(pair.i, pair.j, stroke: pair-stroke))
  }
  annotations
}

/// Compute normalized native-vector layout geometry without rendering it.
#let layout(sequence, structure, method: "naview", execution: execution-policy(), id: none) = request(
  "layout",
  ("sequence": sequence, "structure": structure),
  options: ("method": method),
  execution: execution,
  id: id,
)

/// Predict only the minimum-free-energy structure.
#let fold(sequence, model: analysis-model(), constraints: none, execution: execution-policy(), id: none) = request(
  "fold", ("sequence": sequence), model: model, constraints: constraints, execution: execution, id: id,
)

/// Evaluate one supplied pseudoknot-free structure.
#let evaluate(sequence, structure, model: analysis-model(), constraints: none, execution: execution-policy(), id: none) = request(
  "evaluate",
  ("sequence": sequence, "structure": structure),
  model: model,
  constraints: constraints,
  execution: execution,
  id: id,
)

/// Reproducible stochastic backtracking from the partition ensemble.
#let sample(sequence, count: 100, seed: 0, unique: false, model: analysis-model(), constraints: none, execution: execution-policy(), id: none) = request(
  "sample",
  ("sequence": sequence),
  model: model,
  constraints: constraints,
  options: ("count": count, "seed": seed, "unique": unique),
  execution: execution,
  id: id,
)

/// Construct a one-based inclusive region for an accessibility query.
#let accessibility-window(from, to) = (from: from, to: to)

/// Exact joint unpaired probabilities and opening energies.
#let accessibility(sequence, windows, model: analysis-model(), constraints: none, execution: execution-policy(), id: none) = request(
  "accessibility",
  ("sequence": sequence),
  model: model,
  constraints: constraints,
  options: ("windows": windows),
  execution: execution,
  id: id,
)

/// Deterministic k-best structures in an energy band above the MFE.
#let suboptimal(sequence, energy-band: 5.0, limit: 100, model: analysis-model(), constraints: none, execution: execution-policy(), id: none) = request(
  "suboptimal",
  ("sequence": sequence),
  model: model,
  constraints: constraints,
  options: ("energy_band_kcal_mol": energy-band, "limit": limit),
  execution: execution,
  id: id,
)

/// Connected intermolecular duplex ensemble with no intramolecular pairs.
#let duplex(sequence-a, sequence-b, model: analysis-model(), execution: execution-policy(), id: none) = request(
  "duplex",
  ("sequence_a": sequence-a, "sequence_b": sequence-b),
  model: model,
  execution: execution,
  id: id,
)

/// Unrestricted two-strand cofold ensemble and optional mass-action solution.
#let cofold(sequence-a, sequence-b, concentration-a: none, concentration-b: none, model: analysis-model(), execution: execution-policy(), id: none) = request(
  "cofold",
  ("sequence_a": sequence-a, "sequence_b": sequence-b),
  model: model,
  options: (
    "concentration_a_molar": concentration-a,
    "concentration_b_molar": concentration-b,
  ),
  execution: execution,
  id: id,
)

/// Sliding-window local pair and accessibility probabilities.
#let local(sequence, window-size: 150, max-pair-span: 100, max-unpaired: 30, model: analysis-model(), execution: execution-policy(), id: none) = request(
  "local",
  ("sequence": sequence),
  model: model,
  options: (
    "window_size": window-size,
    "max_pair_span": max-pair-span,
    "max_unpaired": max-unpaired,
  ),
  execution: execution,
  id: id,
)

/// Circular-RNA MFE, partition function, centroid, and MEA analysis.
#let circular(sequence, model: analysis-model(dangles: 0), constraints: none, execution: execution-policy(), id: none) = request(
  "circular", ("sequence": sequence), model: model, constraints: constraints, execution: execution, id: id,
)

/// Describe one modified nucleotide. `kind` may be "m6a",
/// "pseudouridine", "inosine", "seven-deazaadenosine", "purine", or
/// "dihydrouridine" to activate calibrated sparse nearest-neighbor data.
#let modified-base(position, symbol, canonical-base, kind: none, paired-energy: 0.0, unpaired-energy: 0.0, stack-energy: 0.0) = (
  position: position,
  symbol: symbol,
  canonical-base: canonical-base,
  kind: kind,
  paired-energy-kcal-mol: paired-energy,
  unpaired-energy-kcal-mol: unpaired-energy,
  stack-energy-kcal-mol: stack-energy,
)

/// Analyze a canonical sequence with position-specific modified-base effects.
#let modified(sequence, modifications, model: analysis-model(), execution: execution-policy(), id: none) = request(
  "modified",
  ("sequence": sequence),
  model: model,
  options: ("modifications": modifications),
  execution: execution,
  id: id,
)

/// Analyze an integrated secondary-structure/G-quadruplex ensemble.
#let gquad(sequence, model: analysis-model(), execution: execution-policy(), id: none) = request(
  "gquad", ("sequence": sequence), model: model, execution: execution, id: id,
)

/// Configure ProbKnot decoding, the H-type component ensemble, and the
/// opt-in exact exponential arbitrary-matching ensemble.
#let pseudoknot-options(
  threshold: 0.0,
  iterations: 1,
  min-helix: 3,
  gamma: 1.0,
  initiation: -1.38,
  crossing: 2.46,
  unpaired: 0.06,
  evidence-weight: 0.0,
  max-components: none,
  max-ensemble-states: none,
  exact-arbitrary-ensemble: false,
) = (
  threshold: threshold,
  iterations: iterations,
  min-helix: min-helix,
  gamma: gamma,
  initiation-kcal-mol: initiation,
  crossing-kcal-mol: crossing,
  unpaired-kcal-mol: unpaired,
  evidence-weight-kcal-mol: evidence-weight,
  max-components: max-components,
  max-ensemble-states: max-ensemble-states,
  exact-arbitrary-ensemble: exact-arbitrary-ensemble,
)

/// Predict crossing base pairs as extended dot-bracket notation.
#let pseudoknot(sequence, options: pseudoknot-options(), model: analysis-model(), execution: execution-policy(), id: none) = request(
  "pseudoknot", ("sequence": sequence), model: model, options: options, execution: execution, id: id,
)

/// Evaluate a supplied canonical extended-dot-bracket matching with the
/// generalized pseudoknot energy used by the arbitrary-topology ensemble.
#let evaluate-pseudoknot(sequence, structure, options: pseudoknot-options(), model: analysis-model(), execution: execution-policy(), id: none) = request(
  "evaluate-pseudoknot",
  ("sequence": sequence, "structure": structure),
  model: model,
  options: options,
  execution: execution,
  id: id,
)

/// Configure the fixed-seed conditional density-2 ensemble.  Published DP09
/// constants are explicit so a result records the exact requested model.
#let conditional-density2-options(
  gamma: 1.0,
  pk-only: false,
  multiloop-init: 3.39,
  multiloop-branch: 0.03,
  multiloop-unpaired: 0.02,
  pseudoloop-initiation: -1.38,
  multiloop-pseudoknot: 10.07,
  nested-pseudoknot: 15.0,
  band: 2.46,
  pseudoloop-unpaired: 0.06,
  closed-subregion: 0.96,
  spanning-stack-factor: 0.89,
  spanning-internal-factor: 0.74,
  spanning-multiloop-init: 3.41,
  spanning-multiloop-branch: 0.56,
  spanning-multiloop-unpaired: 0.12,
) = (
  gamma: gamma,
  pk-only: pk-only,
  multiloop-init-kcal-mol: multiloop-init,
  multiloop-branch-kcal-mol: multiloop-branch,
  multiloop-unpaired-kcal-mol: multiloop-unpaired,
  pseudoloop-initiation-kcal-mol: pseudoloop-initiation,
  multiloop-pseudoknot-kcal-mol: multiloop-pseudoknot,
  nested-pseudoknot-kcal-mol: nested-pseudoknot,
  band-kcal-mol: band,
  pseudoloop-unpaired-kcal-mol: pseudoloop-unpaired,
  closed-subregion-kcal-mol: closed-subregion,
  spanning-stack-factor: spanning-stack-factor,
  spanning-internal-factor: spanning-internal-factor,
  spanning-multiloop-init-kcal-mol: spanning-multiloop-init,
  spanning-multiloop-branch-kcal-mol: spanning-multiloop-branch,
  spanning-multiloop-unpaired-kcal-mol: spanning-multiloop-unpaired,
)

/// Complete fixed-seed conditional density-2 ensemble. Dangles 0/2 use the
/// independent cubic-time, quadratic-space interval hypergraph; the nonlocal
/// dangles 1/3 models dispatch to exact exhaustive evaluation. `structure` is
/// the pseudoknot-free seed; all decoded outputs pass directly to `plot`.
#let conditional-density2(
  sequence,
  structure,
  options: conditional-density2-options(),
  model: analysis-model(),
  constraints: none,
  execution: execution-policy(),
  id: none,
) = request(
  "conditional-density2",
  ("sequence": sequence, "structure": structure),
  model: model,
  constraints: constraints,
  options: options,
  execution: execution,
  id: id,
)

/// Draw exact independent Boltzmann samples from the fixed-seed density-2
/// ensemble. Every returned combined structure can be passed directly to
/// `plot`; `topology` contains exact fatgraph invariants for the sample.
#let conditional-density2-sample(
  sequence,
  structure,
  count: 100,
  seed: 0,
  unique: false,
  options: conditional-density2-options(),
  model: analysis-model(),
  constraints: none,
  execution: execution-policy(),
  id: none,
) = request(
  "conditional-density2-sample",
  ("sequence": sequence, "structure": structure),
  model: model,
  constraints: constraints,
  options: options + (count: count, seed: seed, unique: unique),
  execution: execution,
  id: id,
)

/// Return the exact k lowest-energy density-2 extensions retained within an
/// energy band above the conditional MFE.
#let conditional-density2-suboptimal(
  sequence,
  structure,
  energy-band: 5.0,
  limit: 100,
  options: conditional-density2-options(),
  model: analysis-model(),
  constraints: none,
  execution: execution-policy(),
  id: none,
) = request(
  "conditional-density2-suboptimal",
  ("sequence": sequence, "structure": structure),
  model: model,
  constraints: constraints,
  options: options + ("energy_band_kcal_mol": energy-band, "limit": limit),
  execution: execution,
  id: id,
)

/// Compute the exact orientable fatgraph genus, boundary components, Euler
/// characteristic, and crossing-graph components of an RNA chord diagram.
#let fatgraph-topology(sequence, structure, execution: execution-policy(), id: none) = request(
  "fatgraph-topology",
  ("sequence": sequence, "structure": structure),
  execution: execution,
  id: id,
)

/// Convert crossing components from `fatgraph-topology` (or a sampled
/// structure's `topology`) into pair-edge annotations for `plot`/`render`.
#let topology-annotations(
  topology,
  palette: (
    rgb("#d73027"), rgb("#4575b4"), rgb("#1a9850"), rgb("#984ea3"),
    rgb("#ff7f00"), rgb("#a65628"), rgb("#e7298a"), rgb("#66a61e"),
  ),
  thickness: 1.15pt,
) = {
  let topology = result-data(topology)
  topology.pairs
    .filter(pair => pair.crossing_degree > 0)
    .map(pair => pair-annotation(
      pair.i,
      pair.j,
      stroke: (
        paint: palette.at(calc.rem(pair.component - 1, palette.len())),
        thickness: thickness,
        cap: "round",
      ),
    ))
}

/// Evaluate one explicit pair of planar layers under the conditional
/// density-2 model.  The returned combined structure is directly renderable.
#let evaluate-conditional-density2(
  sequence,
  seed-structure,
  added-structure,
  options: conditional-density2-options(),
  model: analysis-model(),
  constraints: none,
  execution: execution-policy(),
  id: none,
) = request(
  "evaluate-conditional-density2",
  (
    "sequence": sequence,
    "seed_structure": seed-structure,
    "added_structure": added-structure,
  ),
  model: model,
  constraints: constraints,
  options: options,
  execution: execution,
  id: id,
)

/// Configure alignment covariation scoring.
#let comparative-options(covariance-weight: 1.0, incompatible-penalty: 1.0, minimum-pair-occupancy: 0.5) = (
  covariance-weight-kcal-mol: covariance-weight,
  incompatible-penalty: incompatible-penalty,
  minimum-pair-occupancy: minimum-pair-occupancy,
)

/// Fold a gap-aware alignment with explicit covariation pseudo-energies.
#let comparative(alignment, options: comparative-options(), model: analysis-model(), execution: execution-policy(), id: none) = request(
  "comparative", ("alignment": alignment), model: model, options: options, execution: execution, id: id,
)

/// Compute the globally minimum-saddle path over the complete planar
/// secondary-structure graph. Adjacent states differ by exactly one inserted
/// or deleted base pair. This exact operation has exponential state space and
/// deliberately has no beam or state-count cap.
#let landscape(
  sequence,
  start-structure,
  target-structure,
  model: analysis-model(),
  constraints: none,
  execution: execution-policy(),
  id: none,
) = request(
  "landscape",
  (
    "sequence": sequence,
    "start_structure": start-structure,
    "target_structure": target-structure,
  ),
  model: model,
  constraints: constraints,
  execution: execution,
  id: id,
)

/// Exhaustively inverse-fold an IUPAC sequence template for a planar target.
/// `return-count` limits only the returned ranking; every compatible sequence
/// in the template and explicit GC interval is scored by an exact constrained
/// partition-function ratio.
#let inverse-design(
  target-structure,
  template: none,
  minimum-gc-fraction: 0.0,
  maximum-gc-fraction: 1.0,
  return-count: 10,
  model: analysis-model(),
  constraints: none,
  execution: execution-policy(),
  id: none,
) = {
  let resolved-template = if template == none {
    range(target-structure.len()).map(_ => "N").join()
  } else { template }
  request(
    "inverse-design",
    (
      "target_structure": target-structure,
      "template": resolved-template,
    ),
    model: model,
    constraints: constraints,
    options: (
      "minimum-gc-fraction": minimum-gc-fraction,
      "maximum-gc-fraction": maximum-gc-fraction,
      "return-count": return-count,
    ),
    execution: execution,
    id: id,
  )
}

/// Define a ligand-bound sequence/structure motif at a one-based position.
/// The supplied free energy is the 1 M standard-state binding energy;
/// `concentration` contributes the exact `-RT ln(c / 1 M)` chemical potential.
#let ligand-motif(
  id,
  start,
  sequence,
  structure,
  standard-binding-energy,
  concentration: 1.0,
) = (
  "id": id,
  "start": start,
  "sequence": sequence,
  "structure": structure,
  "standard-binding-energy-kcal-mol": standard-binding-energy,
  "concentration-molar": concentration,
)

/// Compute the exact joint ensemble over all planar RNA structures and all
/// non-overlapping subsets of compatible ligand sites.
#let ligand(
  sequence,
  motifs,
  model: analysis-model(),
  constraints: none,
  execution: execution-policy(),
  id: none,
) = request(
  "ligand",
  ("sequence": sequence, "motifs": motifs),
  model: model,
  constraints: constraints,
  execution: execution,
  id: id,
)

/// Convert accessibility results of a selected window length to nucleotide
/// colors (blue: closed, yellow: accessible), anchored at the window start.
#let accessibility-annotations(result, window-length: 1, scale: auto, legend: auto) = {
  let result = result-data(result)
  let entries = result.windows.filter(entry => entry.length == window-length)
  let resolved-scale = if scale == auto {
    color-scale(colors: (rgb("#313695"), rgb("#74add1"), rgb("#fee090")), label: [Accessibility])
  } else { scale }
  value-annotations(
    entries.map(entry => entry.probability_unpaired),
    positions: entries.map(entry => entry.from),
    scale: resolved-scale,
    legend: legend,
  )
}

/// Convert an RNAplfold-style local accessibility track into base colors.
#let local-accessibility-annotations(result, window-length: 1, scale: auto, legend: auto) = {
  let result = result-data(result)
  let entries = result.accessibility.filter(entry => entry.length == window-length)
  let resolved-scale = if scale == auto {
    color-scale(colors: (rgb("#313695"), rgb("#74add1"), rgb("#fee090")), label: [Accessibility])
  } else { scale }
  value-annotations(
    entries.map(entry => entry.probability_unpaired),
    positions: entries.map(entry => entry.from),
    scale: resolved-scale,
    legend: legend,
  )
}

/// Compute the normalized nucleotide ensemble defect of a target structure
/// from an existing `predict` result without another WASM call.
#let ensemble-defect(sequence, target, result) = {
  let parsed = data(validate(sequence, target))
  let result = result-data(result)
  let paired = (:)
  for pair in parsed.pairs {
    let probability = result.pair_probabilities.find(
      entry => entry.i == calc.min(pair.i, pair.j) and entry.j == calc.max(pair.i, pair.j),
    )
    let p = if probability == none { 0.0 } else { probability.probability }
    paired.insert(str(pair.i), p)
    paired.insert(str(pair.j), p)
  }
  let correct = 0.0
  for index in range(0, parsed.length) {
    correct += if str(index + 1) in paired {
      paired.at(str(index + 1))
    } else {
      result.unpaired_probabilities.at(index)
    }
  }
  (
    target-structure: parsed.structure,
    normalized-ensemble-defect: 1.0 - correct / parsed.length,
    expected-correct-nucleotides: correct,
  )
}

/// Convert per-nucleotide positional entropy from `predict` into base colors.
#let entropy-annotations(result, high: auto, missing-fill: luma(88%), scale: auto, legend: auto) = {
  let result = result-data(result)
  let values = result.ensemble.positional_entropy_bits
  let maximum = if high == auto { calc.max(0.000001, result.ensemble.max_positional_entropy_bits) } else { high }
  let resolved-scale = if scale == auto {
    color-scale(minimum: 0.0, maximum: maximum, missing: missing-fill, label: [Positional entropy (bits)])
  } else { scale }
  value-annotations(values, scale: resolved-scale, legend: legend)
}
