// Extended Wilkinson axis breaks (Talbot, Lin, and Hanrahan 2010, "An Extended
// Wilkinson's Algorithm for Automatic Axis Labeling"), the default placement
// for automatic continuous breaks.
//
// The search scores every candidate sequence on four criteria and keeps the
// best: simplicity (how early its step appears in `_Q`, and whether zero is a
// tick), coverage (how tightly the sequence hugs the data), density (how close
// the tick count lands to the requested `m`), and legibility, which is fixed at
// 1 here because gribouille formats every label the same way.
//
// `pretty` (utils/pretty.typ) stays the fallback for the log10 and sqrt
// helpers and for contour levels, where the step must come from a fixed ladder.

// Candidate step mantissas, most preferred first.
#let _Q = (1.0, 5.0, 2.0, 2.5, 4.0, 3.0)

// Criterion weights from the paper (simplicity, coverage, density,
// legibility).
#let _W = (0.25, 0.2, 0.5, 0.05)

// Search bounds. The paper's loops run to infinity and lean on the score
// bounds to break out; Typst has no such escape hatch, so each loop also
// carries a hard cap.
//
// The skip and exponent caps are slack: raising them to 4 and 8 leaves the
// breaks of 264 sample ranges unchanged, because the simplicity and coverage
// bounds cut those loops first. The tick cap is not, since the density bound
// only starts biting above `m` ticks, so it follows the requested count: a
// sequence of `m` ticks needs candidates past `m` to compete.
#let _MAX-SKIP = 2
#let _MIN-MAX-TICKS = 20
#let _MAX-EXPONENT-STEPS = 3

#let _max-ticks(m) = calc.max(_MIN-MAX-TICKS, 3 * m)

#let _index-of-q(q) = {
  let idx = 0
  for (i, v) in _Q.enumerate() {
    if v == q { idx = i }
  }
  idx
}

// Is `value` a whole multiple of `step`, within a relative tolerance?
#let _divides(value, step) = {
  if step == 0 { return false }
  let ratio = value / step
  calc.abs(ratio - calc.round(ratio)) < 1e-9
}

#let _simplicity(q, skip, lo, hi, step) = {
  let i = _index-of-q(q)
  let n = _Q.len()
  let v = if _divides(lo, step) and lo <= 0 and hi >= 0 { 1 } else { 0 }
  1 - i / (n - 1) - skip + v
}

#let _simplicity-max(q, skip) = {
  let i = _index-of-q(q)
  let n = _Q.len()
  1 - i / (n - 1) - skip + 1
}

#let _coverage(dlo, dhi, lo, hi) = {
  let span = 0.1 * (dhi - dlo)
  1 - 0.5 * (calc.pow(dhi - hi, 2) + calc.pow(dlo - lo, 2)) / calc.pow(span, 2)
}

// Best coverage any sequence of the given span could reach: the data centred
// inside it.
#let _coverage-max(dlo, dhi, span) = {
  let range = dhi - dlo
  if span <= range { return 1.0 }
  let half = (span - range) / 2
  1 - 0.5 * (calc.pow(half, 2) * 2) / calc.pow(0.1 * range, 2)
}

#let _density(k, m, dlo, dhi, lo, hi) = {
  let r = (k - 1) / (hi - lo)
  let rt = (m - 1) / (calc.max(hi, dhi) - calc.min(lo, dlo))
  2 - calc.max(r / rt, rt / r)
}

#let _density-max(k, m) = if k >= m { 2 - (k - 1) / (m - 1) } else { 1.0 }

// Breaks for `[lo, hi]` targeting `m` ticks, filtered to the interval so a
// loose sequence never draws a tick outside the panel. `integer` restricts the
// search to whole steps landing on whole positions, for a scale whose values
// are all whole numbers (years, counts, epoch days).
#let extended(lo, hi, m: 5, integer: false) = {
  if lo == hi {
    let step = if integer { 1.0 } else if lo == 0 { 1.0 } else {
      calc.abs(lo) * 0.1
    }
    return (lo - step, lo, lo + step)
  }
  let (dlo, dhi) = if lo > hi { (hi, lo) } else { (lo, hi) }
  // The paper floors the running best at -2, which assumes some candidate
  // clears it. A range narrower than the step ladder allows (a single whole
  // year, once `integer` rules out sub-unit steps) scores every candidate
  // below that, so the floor starts at negative infinity and the best
  // candidate always wins; the pruning bounds behave the same either way.
  let best-score = -float.inf
  let best = none
  let skip = 1
  while skip <= _MAX-SKIP {
    for q in _Q {
      let simplicity-bound = (
        _W.at(0) * _simplicity-max(q, skip) + _W.at(1) + _W.at(2) + _W.at(3)
      )
      // Every later `q` scores lower on simplicity alone, so once the bound
      // falls short this skip level is exhausted.
      if simplicity-bound < best-score { break }
      let k = 2
      while k <= _max-ticks(m) {
        let dm = _density-max(k, m)
        let density-bound = (
          _W.at(0) * _simplicity-max(q, skip)
            + _W.at(1)
            + _W.at(2) * dm
            + _W.at(3)
        )
        if density-bound < best-score { break }
        let delta = (dhi - dlo) / (k + 1) / skip / q
        let z = int(calc.ceil(calc.log(delta, base: 10)))
        let z-steps = 0
        while z-steps <= _MAX-EXPONENT-STEPS {
          let step = skip * q * calc.pow(10.0, z)
          let coverage-bound = (
            _W.at(0) * _simplicity-max(q, skip)
              + _W.at(1) * _coverage-max(dlo, dhi, step * (k - 1))
              + _W.at(2) * dm
              + _W.at(3)
          )
          if coverage-bound < best-score { break }
          let unit = step / skip
          // Whole-number scales reject a fractional step or offset outright,
          // which is what keeps 2020..2023 on whole years.
          let whole = (
            (not integer) or (_divides(step, 1.0) and _divides(unit, 1.0))
          )
          if whole {
            let min-start = int(calc.floor(dhi / step)) * skip - (k - 1) * skip
            let max-start = int(calc.ceil(dlo / step)) * skip
            let start = min-start
            while start <= max-start {
              let s-lo = start * unit
              let s-hi = s-lo + step * (k - 1)
              let score = (
                _W.at(0) * _simplicity(q, skip, s-lo, s-hi, step)
                  + _W.at(1) * _coverage(dlo, dhi, s-lo, s-hi)
                  + _W.at(2) * _density(k, m, dlo, dhi, s-lo, s-hi)
                  + _W.at(3)
              )
              if score > best-score {
                best-score = score
                best = (lo: s-lo, step: step, k: k)
              }
              start += 1
            }
          }
          z += 1
          z-steps += 1
        }
        k += 1
      }
    }
    skip += 1
  }
  if best == none { return (dlo, dhi) }
  let tol = best.step * 1e-6
  range(best.k)
    .map(i => best.lo + i * best.step)
    .filter(b => b >= dlo - tol and b <= dhi + tol)
}
