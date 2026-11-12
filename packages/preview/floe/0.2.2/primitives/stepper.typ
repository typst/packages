// ============================================================================
// FLOE DESIGN SYSTEM — STRUCTURED STEPPER & ACTION TABLE (primitives/stepper.typ)
// Aligned Step-by-Step Mathematical Workflows, Iteration Cycles & Algorithms
// ============================================================================
#import "../core/lib.typ": *

/// Clean Aligned Stepper Table Primitive
/// Transforms messy numbered bullets into structured, beautifully aligned workflow rows.
#let stepper(
  steps: (),
  zebra: false,
  inset: (x: 6pt, y: 5.5pt),
  gutter: 6pt,
  above: 0.6em,
  below: 0.6em,
) = block(
  width: 100%,
  above: above,
  below: below,
)[
  #table(
    columns: (auto, auto, 1fr),
    stroke: none,
    fill: (_, y) => if zebra and calc.even(y) { slate-100 } else { none },
    inset: inset,
    align: (horizon + center, horizon + left, horizon + left),
    ..steps.enumerate().map(((idx, s)) => {
      let (num-label, step-title, step-body) = if s.len() == 2 {
        (str(idx + 1), s.at(0), s.at(1))
      } else {
        let nl = if s.len() >= 1 and s.at(0) != auto { [#s.at(0)] } else { str(idx + 1) }
        let st = if s.len() >= 2 { s.at(1) } else { none }
        let sb = if s.len() >= 3 { s.at(2) } else { none }
        (nl, st, sb)
      }

      (
        // Col 1: Step Number Badge
        box(
          width: 15pt,
          height: 15pt,
          fill: floe-navy,
          radius: radii.full,
          align(center + horizon)[
            #text(font: fonts.sans, size: 7.5pt, weight: "bold", fill: white)[#num-label]
          ]
        ),
        // Col 2: Action / Stage Name
        if step-title != none [
          #text(font: fonts.sans, size: 8.5pt, weight: "bold", fill: floe-navy)[#step-title:]
        ] else [
          []
        ],
        // Col 3: Mathematical Implementation / Detail
        if step-body != none [
          #block(width: 100%)[
            #set text(size: text-scale.base)
            #step-body
          ]
        ] else [
          []
        ],
      )
    }).flatten()
  )
]
