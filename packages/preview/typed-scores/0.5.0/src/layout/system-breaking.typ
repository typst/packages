#import "../foundation/diagnostics.typ": _score-error
#import "../engraving/primitives.typ": barline-separation, thick-barline-thickness, thin-barline-thickness
#import "../engraving/signatures.typ": _inline-signature-note-start, _prologue-start-x, _repeat-side-clearance
#import "staff-stacking.typ": _system-clef-after-barline-gap, _system-repeat-start-gap

#let _measure-prefix-in-system(measure, is-system-start, staff-x, clef-x) = {
  let prefix = if is-system-start {
    _prologue-start-x(
      measure.key,
      measure.time,
      previous-key: measure.at("previous-key"),
      staff-x: staff-x,
      clef-x: clef-x,
    ) - staff-x
  } else {
    _inline-signature-note-start(
      0,
      measure.key,
      measure.time,
      measure.at("show-key"),
      measure.at("show-time"),
      show-clef: measure.at("show-clef"),
      previous-key: measure.at("previous-key"),
      repeat-start: measure.barline.left == "repeat-start",
    )
  }
  let repeat-gap = if is-system-start and measure.barline.left == "repeat-start" {
    _system-repeat-start-gap
  } else {
    0
  }
  prefix + repeat-gap
}

#let _boundary-mark-min-width(item) = {
  let width = 0
  if item.rehearsal != none {
    width = calc.max(
      width,
      // Include the rendered type size, box inset, boundary offset, and the
      // same outward padding LilyPond applies to rehearsal marks.
      measure(text(size: 8pt * 1.12, weight: "bold", item.rehearsal)).width / 8pt + 1.2,
    )
  }
  if item.navigation != none {
    let navigation-width = if type(item.navigation) == str and item.navigation == "segno" {
      3.2
    } else if type(item.navigation) == str and item.navigation == "coda" {
      4.6
    } else {
      measure(text(size: 8pt * 1.02, style: "italic", item.navigation)).width / 8pt + 1.2
    }
    width = calc.max(width, navigation-width)
  }
  width
}

#let _measure-width-in-system(measure, is-system-start, staff-x, clef-x) = {
  let prefix = _measure-prefix-in-system(measure, is-system-start, staff-x, clef-x)
  let repeat-end-gap = if measure.barline.right == "repeat-end" {
    _repeat-side-clearance
  } else {
    0
  }
  // Compound barlines are moved inward at a system end so their outer edge
  // terminates the staff. Reserve their full right-hand inset in the measure
  // width so the final note keeps the same optical clearance under compression.
  let end-barline-gap = if measure.barline.right == "repeat-end" {
    barline-separation / 2 + thick-barline-thickness
  } else if measure.barline.right == "final" {
    (thin-barline-thickness + barline-separation + thick-barline-thickness) / 2
  } else if measure.barline.right == "double" {
    barline-separation / 2 + thin-barline-thickness
  } else {
    0
  }
  calc.max(
    4.5,
    prefix + measure.content-width + repeat-end-gap + end-barline-gap,
    _boundary-mark-min-width(measure),
  )
}

// LilyPond-like line breaking permits modest compression, but evaluates all
// legal barline partitions instead of taking the first line that overflows.
#let _minimum-justification-scale = 0.82
#let _density-adjustment = 0.65

#let _line-break-badness(scale, final-single: false) = {
  let compression = calc.max(0, 1 - scale)
  let expansion = calc.max(0, scale - 1)
  let compression-cost = calc.pow(compression / (1 - _minimum-justification-scale), 2)
  let expansion-cost = calc.pow(expansion / _density-adjustment, 2)
  let final-single-cost = if final-single and expansion > 0 {
    expansion-cost
  } else {
    0
  }
  compression-cost + expansion-cost + final-single-cost
}

#let _adjacent-line-badness(left-scale, right-scale) = {
  calc.pow((left-scale - right-scale) / _density-adjustment, 2) * 0.35
}

// Mark-aware justification treats each boundary mark's measured extent as a
// hard floor. Remaining musical space is still stretchable, so systems end at
// the requested right margin without compressing long navigation text into the
// following bar.
#let _allocate-measure-widths(measures, widths, prefixes, available, ragged: false) = {
  let natural = ()
  let minimum = ()
  for measure-index in range(widths.len()) {
    let flexible = widths.at(measure-index) - prefixes.at(measure-index)
    natural.push(flexible)
    minimum.push(calc.max(
      0,
      _boundary-mark-min-width(measures.at(measure-index)) - prefixes.at(measure-index),
    ))
  }
  let natural-total = natural.sum()
  let minimum-total = minimum.sum()
  if available + 0.0001 < minimum-total {
    return none
  }

  let allocated = ()
  if ragged and available > natural-total {
    allocated = natural
  } else if available >= natural-total {
    let scale = available / natural-total
    allocated = natural.map(value => value * scale)
  } else {
    let compressible = natural-total - minimum-total
    let scale = if compressible <= 0 { 0 } else {
      (available - minimum-total) / compressible
    }
    for measure-index in range(natural.len()) {
      allocated.push(
        minimum.at(measure-index)
          + (natural.at(measure-index) - minimum.at(measure-index)) * scale,
      )
    }
  }

  let density = none
  for measure-index in range(natural.len()) {
    if natural.at(measure-index) > 0 {
      let ratio = allocated.at(measure-index) / natural.at(measure-index)
      density = if density == none { ratio } else { calc.min(density, ratio) }
    }
  }
  if density == none { density = 1 }
  (
    widths: range(widths.len()).map(i => prefixes.at(i) + allocated.at(i)),
    density: density,
  )
}

#let _line-break-candidate(
  measures,
  start,
  stop,
  max-width,
  left-bar-x,
  indent,
  short-indent,
  first-label-reserve,
  short-label-reserve,
  ragged-right,
  ragged-last,
) = {
  let is-first-system = start == 0
  let name-left = if is-first-system { indent } else { short-indent }
  let label-reserve = if is-first-system { first-label-reserve } else { short-label-reserve }
  let system-left-bar-x = left-bar-x + name-left + label-reserve
  let widths = ()
  let prefixes = ()
  let flexible-width = 0

  for index in range(start, stop) {
    let is-first-in-system = index == start
    let measure = measures.at(index)
    let prefix = _measure-prefix-in-system(
      measure,
      is-first-in-system,
      system-left-bar-x,
      system-left-bar-x + _system-clef-after-barline-gap,
    )
    let measure-width = _measure-width-in-system(
      measure,
      is-first-in-system,
      system-left-bar-x,
      system-left-bar-x + _system-clef-after-barline-gap,
    )
    widths.push(measure-width)
    prefixes.push(prefix)
    flexible-width += measure-width - prefix
  }

  let available-flexible-width = max-width - system-left-bar-x - prefixes.sum()
  let justified-density = available-flexible-width / flexible-width
  let ragged = ragged-right == true or (
    stop == measures.len() and (
      ragged-last or (ragged-right == auto and start == 0)
    )
  )
  let allocation = _allocate-measure-widths(
    measures.slice(start, stop),
    widths,
    prefixes,
    available-flexible-width,
    ragged: ragged and justified-density > 1,
  )
  if allocation == none {
    return none
  }
  let density = allocation.density
  // A multi-measure line that cannot reach this density must break; an
  // exceptionally wide individual measure remains legal because it cannot be
  // divided at a barline.
  if density < _minimum-justification-scale and stop - start > 1 {
    return none
  }
  if (
    density < _minimum-justification-scale
      and measures.slice(start, stop).any(measure => measure.lyrics.len() > 0)
  ) {
    return none
  }
  (
    start: start,
    stop: stop,
    density: density,
    badness: _line-break-badness(
      density,
      final-single: stop == measures.len() and stop - start == 1,
    ),
    system: (
      start: start,
      widths: widths,
      natural-width: system-left-bar-x + widths.sum(),
      left-bar-x: system-left-bar-x,
      name-left: name-left,
      label-reserve: label-reserve,
    ),
  )
}

#let _pack-score-systems(
  measures,
  max-width,
  left-bar-x,
  indent,
  short-indent,
  first-label-reserve,
  short-label-reserve,
  ragged-right,
  ragged-last,
) = {
  let candidates = ()
  for start in range(measures.len()) {
    for stop in range(start + 1, measures.len() + 1) {
      let candidate = _line-break-candidate(
        measures,
        start,
        stop,
        max-width,
        left-bar-x,
        indent,
        short-indent,
        first-label-reserve,
        short-label-reserve,
        ragged-right,
        ragged-last,
      )
      if candidate != none {
        candidates.push(candidate)
      }
    }
  }

  // Dynamic programming over legal system candidates. A state retains the
  // previous system's density so the scorer can prefer even neighboring lines.
  let best = (:)
  for candidate-index in range(candidates.len()) {
    let candidate = candidates.at(candidate-index)
    let state = if candidate.start == 0 {
      (cost: candidate.badness, systems: (candidate.system,), density: candidate.density)
    } else {
      let selected = none
      for previous-index in range(candidate-index) {
        let previous = candidates.at(previous-index)
        if previous.stop != candidate.start { continue }
        let prior = best.at(str(previous-index), default: none)
        if prior == none { continue }
        let cost = prior.cost + candidate.badness + _adjacent-line-badness(
          prior.density,
          candidate.density,
        )
        if selected == none or cost < selected.cost {
          selected = (
            cost: cost,
            systems: prior.systems + (candidate.system,),
            density: candidate.density,
          )
        }
      }
      selected
    }
    if state != none {
      best.insert(str(candidate-index), state)
    }
  }

  let selected = none
  for candidate-index in range(candidates.len()) {
    let candidate = candidates.at(candidate-index)
    let state = best.at(str(candidate-index), default: none)
    if candidate.stop == measures.len() and state != none and {
      selected == none or state.cost < selected.cost
    } {
      selected = state
    }
  }
  if selected == none {
    _score-error(
      "score layout",
      "no legal system partition fits the requested width",
      value: max-width,
      expected: "enough staff-space width for every system prologue, label, and complete bar",
      fix: "increase width, reduce indent, note-spacing, or lyric-size, shorten labels or lyric syllables, or disable wrap",
    )
  }
  selected.systems
}

#let _finalize-systems(systems, max-width, ragged-right, ragged-last) = {
  let all-ragged = if ragged-right == auto { systems.len() == 1 } else { ragged-right }
  let finalized-systems = ()
  for (system-index, system) in systems.enumerate() {
    let is-last = system-index + 1 == systems.len()
    let width = if all-ragged or (is-last and ragged-last) {
      system.natural-width
    } else {
      max-width
    }
    finalized-systems.push((
      start: system.start,
      widths: system.widths,
      natural-width: system.natural-width,
      width: width,
      left-bar-x: system.left-bar-x,
      name-left: system.name-left,
      label-reserve: system.label-reserve,
    ))
  }
  finalized-systems
}
