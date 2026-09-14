#import "ipa.typ": *
#import "_config.typ": phonokit-font

#let finger = text(size: 14pt)[☞]
#let viol-sym = text(size: 1.2em)[#sym.ast]

// Helper: Format constraint names with smallcaps, but not text inside brackets
#let format-constraint(name) = {
  // Match pattern: text before bracket, bracket content, text after
  let bracket-match = name.match(regex("^([^\[]*)\[([^\]]*)\](.*)$"))

  if bracket-match != none {
    // Has brackets: smallcaps before, regular inside brackets, smallcaps after
    let before = bracket-match.captures.at(0)
    let inside = bracket-match.captures.at(1)
    let after = bracket-match.captures.at(2)

    // Compose the parts
    [#smallcaps(before)\[#inside\]#if after != "" { smallcaps(after) }]
  } else {
    // No brackets: all smallcaps
    smallcaps(name)
  }
}

// --- Helper: Parse Violation String ---
#let format-viol(v) = {
  if v == "" { return [] }
  let parts = ()
  let stars = v.matches("*").len()
  let fatal = v.contains("!")
  for _ in range(stars) { parts.push(viol-sym) }
  if fatal { parts.push(strong("!")) }
  parts.join(h(1pt))
}

// NOTE: --- The Main Function ---
#let tableau(
  input: "Input",
  candidates: (),
  constraints: (),
  violations: (),
  winner: 0,
  dashed-lines: (),
  scale: none,
  shade: true,
) = {
  // 1. Validation and Truncation
  assert(constraints.len() <= 10, message: "Maximum 10 constraints allowed in tableau")

  // Truncate constraint names to 10 characters
  let constraints = constraints.map(c => {
    if c.len() > 10 { c.slice(0, 10) } else { c }
  })

  // Scale: use user-provided scale if given, otherwise auto-scale
  let scale-factor = if scale != none {
    scale
  } else if constraints.len() > 6 {
    0.85
  } else {
    1.0
  }
  let font-size = scale-factor * 1em
  let scaled-finger = text(size: 14pt * scale-factor)[☞]

  // 2. Shading Logic (only if enabled)
  let fatal-map = ()
  if shade {
    for (r, row-viols) in violations.enumerate() {
      let fatal-col = 999
      for (c, cell) in row-viols.enumerate() {
        if cell.contains("!") {
          fatal-col = c
          break
        }
      }
      fatal-map.push(fatal-col)
    }
  }

  // 3. Prepare Input Content
  let input-content = if type(input) == str {
    [/#ipa(input)/]
  } else {
    input
  }

  // 4. Grid Definitions
  let col-defs = (auto, 2pt) + constraints.map(_ => auto)
  let row-defs = (1.75em, 2pt) + candidates.map(_ => 1.75em)

  context text(size: font-size, font: phonokit-font.get())[#table(
    columns: col-defs,
    rows: row-defs,
    align: (col, row) => (if col == 0 { right } else { center }) + horizon,
    inset: 5pt,

    stroke: (col, row) => {
      let s = 0.4pt + black
      let is-dashed = if col >= 2 { dashed-lines.contains(col - 1) } else { false }
      (
        left: s,
        top: s,
        bottom: s,
        right: if is-dashed { (thickness: 0.4pt, dash: "dashed") } else { s },
      )
    },

    fill: (col, row) => {
      if not shade or row < 2 or col < 2 { return none }
      let cand-idx = row - 2
      let cons-idx = col - 2
      if cand-idx < fatal-map.len() {
        let fatal-col = fatal-map.at(cand-idx)
        if cons-idx > fatal-col {
          // Check if there's at least one solid line between fatal-col and cons-idx
          // A cell is only shaded if the path from the fatal violation contains a solid line
          let has-solid-line = false
          for c in range(fatal-col, cons-idx) {
            // The right border of constraint c is dashed if dashed-lines.contains(c + 1)
            // (see stroke logic at line 99: dashed-lines.contains(col - 1) where col = c + 2)
            if not dashed-lines.contains(c + 1) {
              has-solid-line = true
              break
            }
          }
          if has-solid-line { return luma(230) }
        }
      }
      return none
    },

    // --- Content ---
    input-content, // Use the pre-calculated variable
    [],
    ..constraints.map(c => format-constraint(c)),

    // Gap Row
    ..range(col-defs.len()).map(_ => []),

    // Candidates
    ..candidates
      .enumerate()
      .map(((i, cand)) => {
        let cells = ()
        let cand-content = if type(cand) == str { ipa(cand) } else { cand }
        let prefix = if i == winner { scaled-finger + " " } else { "" }

        cells.push(align(right)[#prefix #cand-content])
        cells.push([])

        let row-viols = if i < violations.len() { violations.at(i) } else { () }
        for j in range(constraints.len()) {
          if j < row-viols.len() {
            cells.push(format-viol(row-viols.at(j)))
          } else {
            cells.push([])
          }
        }
        return cells
      })
      .flatten()
  )]
}

// NOTE: --- HG TABLEAU FUNCTION ---
#let hg(
  input: "Input",
  candidates: (),
  constraints: (),
  weights: (),
  violations: (),
  scale: none,
) = {
  // 1. Validation and Truncation
  assert(constraints.len() <= 10, message: "Maximum 10 constraints allowed")

  // Truncate constraint names to 10 characters
  let constraints = constraints.map(c => {
    if c.len() > 10 { c.slice(0, 10) } else { c }
  })

  // Scale: use user-provided scale if given, otherwise auto-scale
  let font-size = if scale != none {
    scale * 1em
  } else if constraints.len() > 6 {
    0.85em
  } else {
    0.95em
  }

  // 2. CALCULATIONS
  let h-scores = ()

  for row-viols in violations {
    let h = 0.0
    for (i, v) in row-viols.enumerate() {
      if i < weights.len() {
        h += float(v) * float(weights.at(i))
      }
    }
    h-scores.push(h)
  }

  // 3. GRID DEFINITIONS (simpler than maxent - only h(y) column)
  let col-defs = (auto, 2pt) + constraints.map(_ => auto) + (2pt, auto)

  let row-defs = (auto, 1.75em, 2pt) + candidates.map(_ => 1.75em)

  context text(size: font-size, font: phonokit-font.get())[#table(
    columns: col-defs,
    rows: row-defs,
    align: (col, row) => (if col == 0 { right } else { center }) + horizon,
    inset: 5pt,

    // --- STROKE LOGIC ---
    stroke: (col, row) => {
      // Row 0 (Weights): Always floating
      if row == 0 { return none }

      // Standard borders for the main table
      let s = 0.4pt + black
      (left: s, top: s, bottom: s, right: s)
    },

    // --- ROW 0: WEIGHTS ---
    [], [],
    ..weights.map(w => text(size: 0.9em)[$w=#w$]),
    // Fill remaining columns: gap (2pt) + h(y) column
    [], [],

    // --- ROW 1: HEADERS ---
    { if type(input) == str { [/#ipa(input)/] } else { input } },
    [],
    ..constraints.map(c => format-constraint(c)),
    [],
    [$h_i$],

    // --- ROW 2: GAP ---
    ..range(col-defs.len()).map(_ => []),

    // --- ROWS 3+: CANDIDATES ---
    ..candidates
      .enumerate()
      .map(((i, cand)) => {
        let cells = ()
        let cand-content = if type(cand) == str { ipa(cand) } else { cand }
        cells.push(align(right)[#cand-content])
        cells.push([])

        // Violations
        let row-viols = if i < violations.len() { violations.at(i) } else { () }
        for j in range(constraints.len()) {
          if j < row-viols.len() { cells.push(text(size: 0.85em)[#str(row-viols.at(j))]) } else { cells.push([]) }
        }

        cells.push([])

        // Only h(y) column - no MaxEnt probabilities
        if i < h-scores.len() {
          cells.push(text(size: 0.85em)[#str(calc.round(h-scores.at(i), digits: 2))])
        } else {
          cells.push("-")
        }

        return cells
      })
      .flatten()
  )]
}

// NOTE: --- NHG DEMO TABLEAU (Pedagogical - shows symbolic noise) ---
#let nhg-demo(
  input: "Input",
  candidates: (),
  constraints: (),
  weights: (),
  violations: (),
  probabilities: none, // optional: if provided, will display P(y) values
  scale: none,
) = {
  // 1. Validation and Truncation
  assert(constraints.len() <= 10, message: "Maximum 10 constraints allowed")

  // Truncate constraint names to 10 characters
  let constraints = constraints.map(c => {
    if c.len() > 10 { c.slice(0, 10) } else { c }
  })

  // Scale: use user-provided scale if given, otherwise auto-scale
  let font-size = if scale != none {
    scale * 1em
  } else if constraints.len() > 6 {
    0.85em
  } else {
    0.95em
  }

  // 2. CALCULATIONS
  let h-scores = ()
  let epsilon-formulas = ()

  for row-viols in violations {
    // Calculate deterministic harmony h(y)
    let h = 0.0
    for (i, v) in row-viols.enumerate() {
      if i < weights.len() {
        h += float(v) * float(weights.at(i))
      }
    }
    h-scores.push(h)

    // Build epsilon formula: ε(y) = Σ(n_i × v_i)
    let epsilon-parts = ()
    for (i, v) in row-viols.enumerate() {
      if i < constraints.len() and v != 0 {
        let v-val = float(v)
        let abs-v = calc.abs(v-val)
        let sign = if v-val < 0 { "-" } else { "" }
        let coef = if abs-v == 1 { "" } else { str(int(abs-v)) }
        epsilon-parts.push(sign + coef + "n_" + str(i + 1))
      }
    }

    // Join epsilon parts and create single math expression
    let epsilon-formula = if epsilon-parts.len() > 0 {
      let formula-str = epsilon-parts.join(" ")
      eval("$" + formula-str + "$")
    } else {
      $0$
    }
    epsilon-formulas.push(epsilon-formula)
  }

  // 3. GRID DEFINITIONS (h, ε, P columns)
  let col-defs = (auto, 2pt) + constraints.map(_ => auto) + (2pt, auto, auto)
  if probabilities != none {
    col-defs.push(auto) // Add P(y) column
  }

  let row-defs = (auto, 1.75em, 2pt) + candidates.map(_ => 1.75em)

  context text(size: font-size, font: phonokit-font.get())[#table(
    columns: col-defs,
    rows: row-defs,
    align: (col, row) => (if col == 0 { right } else { center }) + horizon,
    inset: 5pt,

    // --- STROKE LOGIC ---
    stroke: (col, row) => {
      // Row 0 (Weights): Always floating
      if row == 0 { return none }

      // Standard borders for the main table
      let s = 0.4pt + black
      (left: s, top: s, bottom: s, right: s)
    },

    // --- ROW 0: WEIGHTS (shown as w=value like maxent) ---
    [], [],
    ..weights.map(w => text(size: 0.9em)[$w=#w$]),
    // Fill remaining columns: gap + h + ε + (optional P)
    ..range(if probabilities != none { 4 } else { 3 }).map(_ => []),

    // --- ROW 1: HEADERS ---
    { if type(input) == str { [/#ipa(input)/] } else { input } },
    [],
    ..constraints.map(c => format-constraint(c)),
    [],
    [$h_i$],
    [$epsilon_i$],
    ..(if probabilities != none { ([$P_i$],) } else { () }),

    // --- ROW 2: GAP ---
    ..range(col-defs.len()).map(_ => []),

    // --- ROWS 3+: CANDIDATES ---
    ..candidates
      .enumerate()
      .map(((i, cand)) => {
        let cells = ()
        let cand-content = if type(cand) == str { ipa(cand) } else { cand }
        cells.push(align(right)[#cand-content])
        cells.push([])

        // Violations
        let row-viols = if i < violations.len() { violations.at(i) } else { () }
        for j in range(constraints.len()) {
          if j < row-viols.len() {
            cells.push(text(size: 0.85em)[#str(row-viols.at(j))])
          } else {
            cells.push([])
          }
        }

        cells.push([])

        // h(y) column
        if i < h-scores.len() {
          cells.push(text(size: 0.85em)[#str(calc.round(h-scores.at(i), digits: 2))])
        } else {
          cells.push("-")
        }

        // ε(y) column (formula)
        if i < epsilon-formulas.len() {
          cells.push(text(size: 0.85em)[#epsilon-formulas.at(i)])
        } else {
          cells.push("-")
        }

        // P(y) column (if provided)
        if probabilities != none and i < probabilities.len() {
          cells.push(text(size: 0.85em)[#str(calc.round(probabilities.at(i), digits: 3))])
        } else if probabilities != none {
          cells.push("-")
        }

        return cells
      })
      .flatten()
  )]
}

// NOTE: --- NHG TABLEAU (Smart - samples noise and calculates probabilities) ---
#let nhg(
  input: "Input",
  candidates: (),
  constraints: (),
  weights: (),
  violations: (),
  num-simulations: 1000,
  seed: none,
  show-epsilon: true,
  scale: none,
) = {
  // 1. Validation and Truncation
  assert(constraints.len() <= 10, message: "Maximum 10 constraints allowed")

  // Truncate constraint names to 10 characters
  let constraints = constraints.map(c => {
    if c.len() > 10 { c.slice(0, 10) } else { c }
  })

  // Scale: use user-provided scale if given, otherwise auto-scale
  let font-size = if scale != none {
    scale * 1em
  } else if constraints.len() > 6 {
    0.85em
  } else {
    0.95em
  }

  // 2. Generate all random samples upfront using LCG
  let initial-seed = if seed != none { seed } else { 12345 }
  let total-samples = (num-simulations + 1) * constraints.len()

  let normal-samples = ()
  let state = initial-seed

  for i in range(total-samples) {
    // Generate two uniform random numbers for Box-Muller
    state = calc.rem(state * 1103515245 + 12345, 2147483648)
    let u1 = state / 2147483648.0
    state = calc.rem(state * 1103515245 + 12345, 2147483648)
    let u2 = state / 2147483648.0

    // Box-Muller transform
    if u1 < 0.00001 { u1 = 0.00001 }
    let sample = calc.sqrt(-2.0 * calc.ln(u1)) * calc.cos(2.0 * calc.pi * u2)
    normal-samples.push(sample)
  }

  // 3. Calculate deterministic harmonies
  let h-scores = ()
  for row-viols in violations {
    let h = 0.0
    for (i, v) in row-viols.enumerate() {
      if i < weights.len() {
        h += float(v) * float(weights.at(i))
      }
    }
    h-scores.push(h)
  }

  // 4. Monte Carlo simulation
  let win-counts = candidates.map(_ => 0)
  let sample-idx = 0

  for sim in range(num-simulations) {
    // Get noise for this simulation
    let noise = ()
    for c in range(constraints.len()) {
      noise.push(normal-samples.at(sample-idx))
      sample-idx = sample-idx + 1
    }

    // Calculate noisy harmonies
    let noisy-harmonies = ()
    for (cand-idx, row-viols) in violations.enumerate() {
      let h = h-scores.at(cand-idx)
      let epsilon = 0.0
      for (i, v) in row-viols.enumerate() {
        if i < noise.len() {
          epsilon += noise.at(i) * float(v)
        }
      }
      noisy-harmonies.push(h + epsilon)
    }

    // Find winner
    let max-harmony = calc.max(..noisy-harmonies)
    let winner-idx = noisy-harmonies.position(h => h == max-harmony)
    if winner-idx != none {
      win-counts.at(winner-idx) = win-counts.at(winner-idx) + 1
    }
  }

  // Calculate probabilities
  let probabilities = win-counts.map(count => float(count) / float(num-simulations))

  // 5. Get epsilon values for display (one more set of samples)
  let display-noise = ()
  for c in range(constraints.len()) {
    display-noise.push(normal-samples.at(sample-idx))
    sample-idx = sample-idx + 1
  }

  let epsilon-values = ()
  for row-viols in violations {
    let epsilon = 0.0
    for (i, v) in row-viols.enumerate() {
      if i < display-noise.len() {
        epsilon += display-noise.at(i) * float(v)
      }
    }
    epsilon-values.push(epsilon)
  }

  // 6. GRID DEFINITIONS
  let col-defs = (auto, 2pt) + constraints.map(_ => auto) + (2pt, auto)
  if show-epsilon {
    col-defs.push(auto) // epsilon column
  }
  col-defs.push(auto) // P(y) column

  let row-defs = (auto, 1.75em, 2pt) + candidates.map(_ => 1.75em)

  context text(size: font-size, font: phonokit-font.get())[#table(
    columns: col-defs,
    rows: row-defs,
    align: (col, row) => (if col == 0 { right } else { center }) + horizon,
    inset: 5pt,

    // --- STROKE LOGIC ---
    stroke: (col, row) => {
      // Row 0 (Weights): Always floating
      if row == 0 { return none }

      // Standard borders for the main table
      let s = 0.4pt + black
      (left: s, top: s, bottom: s, right: s)
    },

    // --- ROW 0: WEIGHTS ---
    [], [],
    ..weights.map(w => text(size: 0.9em)[$w=#w$]),
    // Fill remaining columns: gap + h + optional ε + P
    ..range(if show-epsilon { 4 } else { 3 }).map(_ => []),

    // --- ROW 1: HEADERS ---
    { if type(input) == str { [/#ipa(input)/] } else { input } },
    [],
    ..constraints.map(c => format-constraint(c)),
    [],
    [$h_i$],
    ..(if show-epsilon { ([$epsilon_i$],) } else { () }),
    [$P_i$],

    // --- ROW 2: GAP ---
    ..range(col-defs.len()).map(_ => []),

    // --- ROWS 3+: CANDIDATES ---
    ..candidates
      .enumerate()
      .map(((i, cand)) => {
        let cells = ()
        let cand-content = if type(cand) == str { ipa(cand) } else { cand }
        cells.push(align(right)[#cand-content])
        cells.push([])

        // Violations
        let row-viols = if i < violations.len() { violations.at(i) } else { () }
        for j in range(constraints.len()) {
          if j < row-viols.len() {
            cells.push(text(size: 0.85em)[#str(row-viols.at(j))])
          } else {
            cells.push([])
          }
        }

        cells.push([])

        // h(y) column
        if i < h-scores.len() {
          cells.push(text(size: 0.85em)[#str(calc.round(h-scores.at(i), digits: 2))])
        } else {
          cells.push("-")
        }

        // ε(y) column (sampled value) - only if show-epsilon
        if show-epsilon {
          if i < epsilon-values.len() {
            cells.push(text(size: 0.85em)[#str(calc.round(epsilon-values.at(i), digits: 2))])
          } else {
            cells.push("-")
          }
        }

        // P(y) column (estimated from simulations)
        if i < probabilities.len() {
          cells.push(text(size: 0.85em)[#str(calc.round(probabilities.at(i), digits: 3))])
        } else {
          cells.push("-")
        }

        return cells
      })
      .flatten()
  )]
}

// NOTE: --- MAXENT TABLEAU FUNCTION ---
#let maxent(
  input: "Input",
  candidates: (),
  constraints: (),
  weights: (),
  violations: (),
  visualize: true,
  sort: false,
  scale: none,
) = {
  // 1. Validation and Truncation
  assert(constraints.len() <= 10, message: "Maximum 10 constraints allowed in maxent")

  // Truncate constraint names to 10 characters
  let constraints = constraints.map(c => {
    if c.len() > 10 { c.slice(0, 10) } else { c }
  })

  // Scale: use user-provided scale if given, otherwise auto-scale
  let font-size = if scale != none {
    scale * 1em
  } else if constraints.len() > 6 {
    0.85em
  } else {
    0.95em
  }

  // 2. CALCULATIONS
  let h-scores = ()
  let p-star-scores = ()
  let total-p-star = 0.0

  for row-viols in violations {
    let h = 0.0
    for (i, v) in row-viols.enumerate() {
      if i < weights.len() {
        h += float(v) * float(weights.at(i))
      }
    }
    h-scores.push(h)
    let p-star = calc.exp(-h)
    p-star-scores.push(p-star)
    total-p-star += p-star
  }

  // Safety check for empty violations/division by zero
  let p-scores = if total-p-star > 0 {
    p-star-scores.map(x => x / total-p-star)
  } else {
    candidates.map(_ => 0.0)
  }

  // 3. SORT BY PROBABILITY (if enabled)
  let order = if sort {
    range(candidates.len()).sorted(key: i => -p-scores.at(i))
  } else {
    range(candidates.len())
  }
  let candidates = order.map(i => candidates.at(i))
  let violations = order.map(i => violations.at(i))
  let h-scores = order.map(i => h-scores.at(i))
  let p-star-scores = order.map(i => p-star-scores.at(i))
  let p-scores = order.map(i => p-scores.at(i))

  // 4. GRID DEFINITIONS
  let bar-col-width = 3cm
  let col-defs = (auto, 2pt) + constraints.map(_ => auto) + (2pt, auto, auto, auto)
  if visualize {
    col-defs.push(bar-col-width) // The Floating Column
  }

  let row-defs = (auto, 1.75em, 2pt) + candidates.map(_ => 1.75em)
  let last-col-idx = col-defs.len() - 1

  let tbl = context text(size: font-size, font: phonokit-font.get())[#table(
    columns: col-defs,
    rows: row-defs,
    align: (col, row) => (if col == 0 { right } else { center }) + horizon,
    inset: 5pt,

    // --- STROKE LOGIC ---
    stroke: (col, row) => {
      // 1. Row 0 (Weights): Always floating
      if row == 0 { return none }

      // 2. Visual Column: STRIP ALL LINES to make it float
      if visualize and col == last-col-idx { return none }

      // 3. Standard borders for the main table
      let s = 0.4pt + black
      (left: s, top: s, bottom: s, right: s)
    },

    // --- ROW 0: WEIGHTS ---
    [], [],
    ..weights.map(w => text(size: 0.9em)[$w=#w$]),
    // Fill remaining columns with empty cells
    ..range(if visualize { 5 } else { 4 }).map(_ => []),

    // --- ROW 1: HEADERS ---
    { if type(input) == str { [/#ipa(input)/] } else { input } },
    [],
    ..constraints.map(c => format-constraint(c)),
    [],
    [$h_i$], [$e^(-h_i)$], [$P_i$],
    // Add empty floating header if visualizing
    ..(if visualize { ([],) } else { () }),

    // --- ROW 2: GAP ---
    ..range(col-defs.len()).map(_ => []),

    // --- ROWS 3+: CANDIDATES ---
    ..candidates
      .enumerate()
      .map(((i, cand)) => {
        let cells = ()
        let cand-content = if type(cand) == str { ipa(cand) } else { cand }
        cells.push(align(right)[#cand-content])
        cells.push([])

        // Violations
        let row-viols = if i < violations.len() { violations.at(i) } else { () }
        for j in range(constraints.len()) {
          if j < row-viols.len() { cells.push(text(size: 0.85em)[#str(row-viols.at(j))]) } else { cells.push([]) }
        }

        cells.push([])

        if i < h-scores.len() {
          cells.push(text(size: 0.85em)[#str(calc.round(h-scores.at(i), digits: 2))])
          cells.push(text(size: 0.85em)[#str(calc.round(p-star-scores.at(i), digits: 3))])
          let p-val = p-scores.at(i)
          cells.push(text(size: 0.85em)[#str(calc.round(p-val, digits: 3))])

          // --- FLOATING VISUAL BAR ---
          if visualize {
            cells.push(align(left + horizon)[
              #box(width: 50%, height: 0.5em, stroke: 0.5pt + luma(100))[
                #rect(
                  width: p-val * 100%,
                  height: 100%,
                  fill: luma(100),
                  stroke: 0.5pt + luma(100),
                )
              ]
            ])
          }
        } else {
          // Fallback
          cells.push("-")
          cells.push("-")
          cells.push("-")
          if visualize { cells.push([]) }
        }

        return cells
      })
      .flatten()
  )]

  if visualize { pad(right: -bar-col-width, tbl) } else { tbl }
}



