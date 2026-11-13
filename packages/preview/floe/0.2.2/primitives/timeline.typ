// ============================================================================
// SNOWPACK DESIGN SYSTEM — PEDAGOGICAL WORKFLOW TIMELINE (primitives/timeline.typ)
// Numbered Algorithm Milestones and Step-by-Step Mechanical Progressions
// ============================================================================
#import "../core/lib.typ": *

/// Step-by-step numbered pedagogical timeline or algorithm execution pipeline
#let timeline(..steps) = {
  let items = steps.pos()
  block(width: 100%, above: 1em, below: 1em)[
    #stack(
      spacing: 0pt,
      ..items.enumerate().map(((idx, step)) => {
        let is-last = idx == items.len() - 1
        let title = if type(step) == array and step.len() >= 1 { step.at(0) } else { [Step #(idx + 1)] }
        let body = if type(step) == array and step.len() >= 2 { step.at(1) } else { step }
        let num-str = str(idx + 1)

        grid(
          columns: (22pt, 1fr),
          gutter: 10pt,
          // Column 1: Number circle + vertical connecting rail
          align(center)[
            #circle(
              radius: 9pt,
              fill: floe-navy,
              stroke: 1.5pt + floe-cyan,
              align(center + horizon)[
                #text(font: fonts.sans, size: 7.5pt, weight: "bold", fill: white)[#num-str]
              ]
            )
            #if not is-last [
              #v(-1pt)
              #line(angle: 90deg, length: 18pt, stroke: 1.2pt + slate-300)
            ]
          ],
          // Column 2: Step title + explanation
          block(inset: (bottom: if is-last { 0pt } else { 12pt }))[
            #text(font: fonts.sans, size: text-scale.sm, weight: "bold", fill: floe-navy)[#title]
            #v(2pt)
            #set text(size: text-scale.base)
            #body
          ]
        )
      })
    )
  ]
}
