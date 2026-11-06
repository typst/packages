// Multi-tier phonological representations (CV phonology, skeletal tiers, etc.)
// Part of phonokit package

#import "@preview/cetz:0.4.2"
#import "_config.typ": phonokit-font
#import "ipa.typ": ipa as ipa-convert

#let multi-tier(
  levels: (),
  links: (),
  dashed: (),
  delinks: (),
  arrows: (),
  arrow-delinks: (),
  float: (),
  highlight: (),
  ipa: (),
  tier-labels: (),
  spacing: 1.5,
  level-spacing: 1.2,
  stroke-width: 0.05em,
  baseline: 40%,
  scale: 1.0,
  show-grid: false,
) = {
  // Validate input
  assert(type(levels) == array, message: "levels must be an array of arrays")
  assert(levels.len() > 0, message: "levels array cannot be empty")

  // Convert labels: "x" → "×" (skeletal slot), Greek names → Unicode, trailing digits → subscripts
  let greek-map = (
    "sigma": "σ",
    "Sigma": "Σ",
    "mu": "μ",
    "omega": "ω",
    "Omega": "Ω",
    "beta": "β",
    "alpha": "α",
    "gamma": "γ",
    "delta": "δ",
    "phi": "φ",
    "Phi": "Φ",
    "pi": "π",
    "tau": "τ",
    "lambda": "λ",
  )

  let render-label(label) = {
    // Greek letter substitution (applied before digit subscripting so "sigma1" → "σ₁")
    let m-greek = label.match(regex("^([A-Za-z]+?)(\d*)$"))
    if m-greek != none {
      let base = m-greek.captures.at(0)
      let trail = m-greek.captures.at(1)
      if base in greek-map {
        label = greek-map.at(base) + trail
      }
    }

    let label = label.replace(regex("^x$"), "×")

    let m = label.match(regex("^(.*?)(\d+)$"))
    if m != none {
      let base = m.captures.at(0)
      let digits = m.captures.at(1)
      let subscript-map = (
        "0": "₀",
        "1": "₁",
        "2": "₂",
        "3": "₃",
        "4": "₄",
        "5": "₅",
        "6": "₆",
        "7": "₇",
        "8": "₈",
        "9": "₉",
      )
      let sub = digits.clusters().map(d => subscript-map.at(d, default: d)).join()
      base + sub
    } else {
      label
    }
  }

  // Parse levels into a grid of (label, x-position, y-level) tuples
  // Entries can be:
  //   "label"                → label at (array col index, array level index)
  //   ("label", col)         → fractional column, normal level
  //   ("label", col, level)  → fractional column, fractional level
  //   ""                     → empty slot
  let tier-grid = levels
    .enumerate()
    .map(((level-idx, row)) => {
      row
        .enumerate()
        .map(((col-idx, entry)) => {
          if type(entry) == array {
            let col-pos = entry.at(1)
            let level-pos = entry.at(2, default: level-idx)
            (label: entry.at(0), col-x: col-pos, level-pos: level-pos)
          } else {
            (label: entry, col-x: col-idx, level-pos: level-idx)
          }
        })
    })

  let num-levels = tier-grid.len()

  // Find the rightmost column x-position across all levels (for tier label placement)
  let max-col-x = calc.max(..tier-grid.map(row => calc.max(..row.map(cell => cell.col-x))))

  // Bind parameters to avoid shadowing built-in/imported names inside CeTZ closure
  let scale-factor = scale
  let sw = stroke-width * scale-factor
  let ipa-levels = ipa

  // Vertical offsets from level center (following prosody.typ pattern)
  let text-above = 0.30
  let line-top = 0.42
  let line-bot = -0.18

  box(inset: 1.2em, baseline: baseline, cetz.canvas(length: scale-factor * 1cm, {
    import cetz.draw: *

    // Helper: y-coordinate for a level index (used for default positioning)
    let level-y(level) = -level * level-spacing

    // Helper: get a cell's actual position (respects fractional col and level overrides)
    let cell-x(level, col) = tier-grid.at(level).at(col).col-x * spacing
    let cell-y(level, col) = -tier-grid.at(level).at(col).level-pos * level-spacing

    // Helper: line departure point (bottom of label)
    let bot-point(level, col) = {
      (cell-x(level, col), cell-y(level, col) + line-bot)
    }

    // Helper: line arrival point (top of label)
    let top-point(level, col) = {
      (cell-x(level, col), cell-y(level, col) + line-top)
    }

    // Determine line attachment points for a pair of positions
    let line-endpoints(l1, c1, l2, c2) = {
      if l1 == l2 {
        (bot-point(l1, c1), bot-point(l2, c2))
      } else if l1 < l2 {
        (bot-point(l1, c1), top-point(l2, c2))
      } else {
        (bot-point(l2, c2), top-point(l1, c1))
      }
    }

    // === Layer 0: Debug grid (behind everything) ===
    if show-grid {
      let grid-color = luma(180)
      let grid-stroke = (paint: grid-color, thickness: 0.3pt, dash: "dashed")

      let max-col = int(max-col-x) + 1
      let pad = 0.6

      // Vertical lines for each integer column
      for col in range(max-col) {
        let x = col * spacing
        line(
          (x, pad),
          (x, -(num-levels - 1) * level-spacing - pad),
          stroke: grid-stroke,
        )
      }

      // Horizontal lines for each level
      for level-i in range(num-levels) {
        let y = level-y(level-i)
        line(
          (-pad, y),
          ((max-col - 1) * spacing + pad, y),
          stroke: grid-stroke,
        )
      }

      // Column index labels (above the diagram)
      for col in range(max-col) {
        content(
          (col * spacing, pad + 0.3),
          text(size: 0.9em * scale-factor, fill: grid-color, font: "Courier New", str(col)),
        )
      }

      // Level index labels (left of the diagram)
      for level-i in range(num-levels) {
        content(
          (-pad - 0.4, level-y(level-i)),
          text(size: 0.9em * scale-factor, fill: grid-color, font: "Courier New", str(level-i)),
        )
      }

      // Column index labels (below the diagram)
      for col in range(max-col) {
        content(
          (col * spacing, -(num-levels - 1) * level-spacing - pad - 0.3),
          text(size: 0.9em * scale-factor, fill: grid-color, font: "Courier New", str(col)),
        )
      }

      // Level index labels (right of the diagram)
      for level-i in range(num-levels) {
        content(
          ((max-col - 1) * spacing + pad + 0.4, level-y(level-i)),
          text(size: 0.9em * scale-factor, fill: grid-color, font: "Courier New", str(level-i)),
        )
      }

      // Dots at every grid intersection
      for level-i in range(num-levels) {
        for col in range(max-col) {
          circle(
            (col * spacing, level-y(level-i)),
            radius: 0.05,
            fill: grid-color,
            stroke: none,
          )
        }
      }
    }

    // === Layer 1: Auto-link lines (between adjacent-level same-column non-empty cells) ===
    for level in range(num-levels - 1) {
      let row-top = tier-grid.at(level)
      let row-bot = tier-grid.at(level + 1)
      let cols = calc.min(row-top.len(), row-bot.len())

      for col in range(cols) {
        if row-top.at(col).label == "" or row-bot.at(col).label == "" { continue }
        if (level, col) in float or (level + 1, col) in float { continue }

        let (p1, p2) = line-endpoints(level, col, level + 1, col)
        line(p1, p2, stroke: sw)
      }
    }

    // === Layer 2: Extra solid links (skip any that also appear in dashed) ===
    for link in links {
      if link in dashed { continue }
      let ((l1, c1), (l2, c2)) = link
      let (p1, p2) = line-endpoints(l1, c1, l2, c2)
      line(p1, p2, stroke: sw)
    }

    // === Layer 3: Dashed lines ===
    for d in dashed {
      let ((l1, c1), (l2, c2)) = d
      let (p1, p2) = line-endpoints(l1, c1, l2, c2)
      line(p1, p2, stroke: (dash: "dashed", thickness: sw))
    }

    // === Layer 4: Highlight circles (drawn behind labels, centered on text) ===
    for (level-idx, col-idx) in highlight {
      let cell = tier-grid.at(level-idx).at(col-idx)
      if cell.label == "" { continue }

      let x = cell-x(level-idx, col-idx)
      let y = cell-y(level-idx, col-idx) + text-above / 3

      // White mask circle (slightly larger, masks lines behind it)
      circle((x, y), radius: 0.45, stroke: none, fill: white)
      // Visible highlight circle
      circle((x, y), radius: 0.35, stroke: sw, fill: none)
    }

    // === Layer 5: Labels (identical rendering regardless of highlight) ===
    for (level-idx, row) in tier-grid.enumerate() {
      for (col-idx, cell) in row.enumerate() {
        if cell.label == "" { continue }

        let x = cell-x(level-idx, col-idx)
        let y = cell-y(level-idx, col-idx) + text-above

        let is-ipa = level-idx in ipa-levels

        let label-content = if is-ipa {
          context text(font: phonokit-font.get(), ipa-convert(cell.label))
        } else if type(cell.label) == str {
          let rendered = render-label(cell.label)
          context text(font: phonokit-font.get(), rendered)
        } else {
          context text(font: phonokit-font.get(), cell.label)
        }

        content(
          (x, y),
          anchor: "north",
          text(size: 1em * scale-factor, box(
            inset: 0.15em,
            align(center + horizon, label-content),
          )),
        )
      }
    }

    // === Layer 5: Tier labels (right-aligned, to the right of the diagram) ===
    for tl in tier-labels {
      let (level-idx, label-text) = tl
      let x = (max-col-x + 1.5) * spacing
      let y = level-y(level-idx) + text-above

      content(
        (x, y),
        anchor: "north-west",
        text(size: 1em * scale-factor, context text(font: phonokit-font.get(), label-text)),
      )
    }

    // === Layer 6: Delink cross marks (on top of everything) ===
    for d in delinks {
      let ((l1, c1), (l2, c2)) = d

      let (p1, p2) = line-endpoints(l1, c1, l2, c2)
      let (x1, y1) = p1
      let (x2, y2) = p2

      let mid-x = (x1 + x2) / 2
      let mid-y = (y1 + y2) / 2

      let dx = x2 - x1
      let dy = y2 - y1
      let length = calc.sqrt(dx * dx + dy * dy)

      if length == 0 { continue }

      let dir-x = dx / length
      let dir-y = dy / length

      let perp-x = -dir-y
      let perp-y = dir-x

      let offset = 0.15
      let spacing-offset = 0.06

      let p1-start = (
        mid-x - offset * perp-x - spacing-offset * dir-x,
        mid-y - offset * perp-y - spacing-offset * dir-y,
      )
      let p1-end = (
        mid-x + offset * perp-x - spacing-offset * dir-x,
        mid-y + offset * perp-y - spacing-offset * dir-y,
      )

      let p2-start = (
        mid-x - offset * perp-x + spacing-offset * dir-x,
        mid-y - offset * perp-y + spacing-offset * dir-y,
      )
      let p2-end = (
        mid-x + offset * perp-x + spacing-offset * dir-x,
        mid-y + offset * perp-y + spacing-offset * dir-y,
      )

      line(p1-start, p1-end, stroke: sw)
      line(p2-start, p2-end, stroke: sw)
    }

    // === Layer 7: Arrows (rectangular paths above top / below bottom level) ===
    let arrow-clearance = 0.5

    for (arrow-idx, a) in arrows.enumerate() {
      let ((l1, c1), (l2, c2)) = a

      let is-top = l1 == 0 and l2 == 0
      let is-bot = l1 == num-levels - 1 and l2 == num-levels - 1

      let x1 = cell-x(l1, c1)
      let x2 = cell-x(l2, c2)

      if is-top {
        let y1 = cell-y(l1, c1) + line-top
        let y2 = cell-y(l2, c2) + line-top
        let y-bar = level-y(0) + line-top + arrow-clearance

        line((x1, y1), (x1, y-bar), stroke: sw)
        line((x1, y-bar), (x2, y-bar), stroke: sw)
        line((x2, y-bar), (x2, y2), stroke: sw, mark: (end: "stealth"), fill: black)

        if arrow-idx in arrow-delinks {
          let mid-x = (x1 + x2) / 2
          let cross-h = 0.15
          let cross-gap = 0.06
          line((mid-x - cross-gap, y-bar - cross-h), (mid-x - cross-gap, y-bar + cross-h), stroke: sw)
          line((mid-x + cross-gap, y-bar - cross-h), (mid-x + cross-gap, y-bar + cross-h), stroke: sw)
        }
      } else if is-bot {
        let y1 = cell-y(l1, c1) + line-bot
        let y2 = cell-y(l2, c2) + line-bot
        let y-bar = level-y(num-levels - 1) + line-bot - arrow-clearance

        line((x1, y1), (x1, y-bar), stroke: sw)
        line((x1, y-bar), (x2, y-bar), stroke: sw)
        line((x2, y-bar), (x2, y2), stroke: sw, mark: (end: "stealth"), fill: black)

        if arrow-idx in arrow-delinks {
          let mid-x = (x1 + x2) / 2
          let cross-h = 0.15
          let cross-gap = 0.06
          line((mid-x - cross-gap, y-bar - cross-h), (mid-x - cross-gap, y-bar + cross-h), stroke: sw)
          line((mid-x + cross-gap, y-bar - cross-h), (mid-x + cross-gap, y-bar + cross-h), stroke: sw)
        }
      }
    }
  }))
}
