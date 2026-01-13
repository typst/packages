#import "ipa.typ": *

#let finger = text(size: 14pt)[☞]
#let viol-sym = text(size: 1.2em)[#sym.ast]

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
  dashed-lines: () 
) = {
  
  // 1. Shading Logic
  let fatal-map = ()
  for (r, row-viols) in violations.enumerate() {
    let fatal-col = 999 
    for (c, cell) in row-viols.enumerate() {
      if cell.contains("!") { fatal-col = c; break }
    }
    fatal-map.push(fatal-col)
  }

  // 2. Prepare Input Content (The Fix)
  let input-content = if type(input) == str { 
    [/#ipa(input)/] 
  } else { 
    input 
  }

  // 3. Grid Definitions
  let col-defs = (auto, 2pt) + constraints.map(_ => auto)
  let row-defs = (1.75em, 2pt) + candidates.map(_ => 1.75em)

  table(
    columns: col-defs,
    rows: row-defs,
    align: (col, row) => (if col == 0 { right } else { center }) + horizon,
    inset: 5pt,
    
    stroke: (col, row) => {
      let s = 0.4pt + black
      let is-dashed = if col >= 2 { dashed-lines.contains(col - 1) } else { false }
      (
        left: s, top: s, bottom: s,
        right: if is-dashed { (thickness: 0.4pt, dash: "dashed") } else { s }
      )
    },

    fill: (col, row) => {
      if row < 2 or col < 2 { return none }
      let cand-idx = row - 2
      let cons-idx = col - 2 
      if cand-idx < fatal-map.len() {
        if cons-idx > fatal-map.at(cand-idx) { return luma(230) }
      }
      return none
    },

    // --- Content ---
    input-content, // Use the pre-calculated variable
    [], 
    ..constraints.map(c => smallcaps(c)),

    // Gap Row
    ..range(col-defs.len()).map(_ => []),

    // Candidates
    ..candidates.enumerate().map(((i, cand)) => {
      let cells = ()
      let cand-content = if type(cand) == str { ipa(cand) } else { cand }
      let prefix = if (i + 1) == winner { finger + " " } else { "" }
      
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
    }).flatten()
  )
}


// NOTE: --- MAXENT TABLEAU FUNCTION ---
#let maxent(
  input: "Input",
  candidates: (), 
  constraints: (), 
  weights: (), 
  violations: (),
  visualize: true 
) = {

  // 1. CALCULATIONS
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

  // 2. GRID DEFINITIONS
  let col-defs = (auto, 2pt) + constraints.map(_ => auto) + (2pt, auto, auto, auto)
  if visualize {
    col-defs.push(3cm) // The Floating Column
  }

  let row-defs = (auto, 1.75em, 2pt) + candidates.map(_ => 1.75em)
  let last-col-idx = col-defs.len() - 1

  table(
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
    ..constraints.map(c => smallcaps(c)),
    [], 
    [$H(y)$], [$e^(-H(y))$], [$P(y|x)$], 
    // Add empty floating header if visualizing
    ..(if visualize { ([],) } else { () }), 

    // --- ROW 2: GAP ---
    ..range(col-defs.len()).map(_ => []),

    // --- ROWS 3+: CANDIDATES ---
    ..candidates.enumerate().map(((i, cand)) => {
      let cells = ()
      let cand-content = if type(cand) == str { ipa(cand) } else { cand }
      cells.push(align(right)[#cand-content])
      cells.push([])

      // Violations
      let row-viols = if i < violations.len() { violations.at(i) } else { () }
      for j in range(constraints.len()) {
        if j < row-viols.len() { cells.push(text(size: 0.85em)[#str(row-viols.at(j))]) }
        else { cells.push([]) }
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
                stroke: 0.5pt + luma(100)
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
    }).flatten()
  )
}

