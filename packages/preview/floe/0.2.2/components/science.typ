// ============================================================================
// FLOE DESIGN SYSTEM — SCIENCE, CHEMISTRY & VECTOR PLOTS (components/science.typ)
// Layer 3: Native CeTZ 2D Function/Data Plotter & Chemical Reaction Blocks
// ============================================================================
#import "../core/lib.typ": *
#import "../primitives/lib.typ": badge, figure-card

/// Native CeTZ 2D Vector Function & Data Series Plotter
/// Plots analytic functions `fn: x => ...` and/or discrete `(x, y)` data series
/// with automatic y-range scaling, gridlines, ticks, axis labels, and legend.
#let plot-2d(
  domain: (0, 10),
  yrange: auto,
  functions: (),
  series: (),
  xlabel: $x$,
  ylabel: $y$,
  width: 11,
  height: 5.0,
  samples: 120,
  show-grid: true,
  xticks: 5,
  yticks: 4,
  title: none,
  subtitle: none,
  badge-label: none,
  footer: none,
  above: 8pt,
  below: 8pt,
) = {
  let (xmin, xmax) = domain
  let dx = (xmax - xmin) / samples

  let curves = ()
  let all-y = ()

  for f-spec in functions {
    let fn = f-spec.at("fn")
    let col = f-spec.at("color", default: floe-cyan)
    let lbl = f-spec.at("label", default: none)
    let dash = f-spec.at("dash", default: "solid")
    let pts = ()
    for i in range(0, samples + 1) {
      let xv = xmin + i * dx
      let yv = fn(xv)
      pts.push((xv, yv))
      all-y.push(yv)
    }
    curves.push((points: pts, color: col, label: lbl, dash: dash, mode: "line"))
  }

  for s-spec in series {
    let pts = s-spec.at("points")
    let col = s-spec.at("color", default: floe-amber)
    let lbl = s-spec.at("label", default: none)
    let mode = s-spec.at("mode", default: "line")
    for p in pts {
      all-y.push(p.at(1))
    }
    curves.push((points: pts, color: col, label: lbl, dash: "solid", mode: mode))
  }

  let (ymin, ymax) = if yrange != auto {
    yrange
  } else if all-y.len() > 0 {
    let lo = calc.min(..all-y)
    let hi = calc.max(..all-y)
    let pad = if hi == lo { 1.0 } else { (hi - lo) * 0.1 }
    (lo - pad, hi + pad)
  } else {
    (-1, 1)
  }

  let map-pt(x, y) = (
    (x - xmin) / (xmax - xmin) * width,
    (y - ymin) / (ymax - ymin) * height,
  )

  let canvas-body = align(center)[
    #cetz.canvas(length: 1cm, {
      import cetz.draw: *

      rect((0, 0), (width, height), fill: rgb("#FAFBFD"), stroke: 0.6pt + slate-300)

      for i in range(0, xticks + 1) {
        let frac = i / xticks
        let xv = xmin + frac * (xmax - xmin)
        let px = frac * width
        if show-grid and i > 0 and i < xticks {
          line((px, 0), (px, height), stroke: (paint: slate-200, thickness: 0.4pt, dash: "dashed"))
        }
        line((px, 0), (px, -0.12), stroke: 0.6pt + slate-500)
        content((px, -0.35), text(font: fonts.sans, size: 7.5pt, fill: slate-600)[#calc.round(xv, digits: 2)])
      }

      for j in range(0, yticks + 1) {
        let frac = j / yticks
        let yv = ymin + frac * (ymax - ymin)
        let py = frac * height
        if show-grid and j > 0 and j < yticks {
          line((0, py), (width, py), stroke: (paint: slate-200, thickness: 0.4pt, dash: "dashed"))
        }
        line((0, py), (-0.12, py), stroke: 0.6pt + slate-500)
        content((-0.22, py), anchor: "east", text(font: fonts.sans, size: 7.5pt, fill: slate-600)[#calc.round(yv, digits: 2)])
      }

      if ymin < 0 and ymax > 0 {
        let (_, y0) = map-pt(xmin, 0)
        line((0, y0), (width, y0), stroke: 0.5pt + slate-400)
      }

      for c in curves {
        let mapped = c.points.map(p => {
          let yc = calc.min(ymax, calc.max(ymin, p.at(1)))
          map-pt(p.at(0), yc)
        })
        if c.mode == "scatter" {
          for mp in mapped {
            circle(mp, radius: 0.08, fill: c.color, stroke: white + 0.5pt)
          }
        } else if mapped.len() >= 2 {
          line(..mapped, stroke: (paint: c.color, thickness: 1.35pt, dash: c.dash))
        }
      }

      content((width / 2, -0.75), text(font: fonts.sans, size: 8.2pt, weight: "bold", fill: floe-navy)[#xlabel])
      content((-0.95, height / 2), angle: 90deg, text(font: fonts.sans, size: 8.2pt, weight: "bold", fill: floe-navy)[#ylabel])
    })
    #let labeled = curves.filter(c => c.label != none)
    #if labeled.len() > 0 [
      #v(2pt)
      #box(
        fill: slate-50,
        stroke: strokes.hairline + slate-200,
        radius: radii.sm,
        inset: (x: 8pt, y: 4pt),
      )[
        #grid(
          columns: (auto,) * labeled.len(),
          gutter: 12pt,
          ..labeled.map(c => {
            box(width: 10pt, height: 2.5pt, fill: c.color, baseline: -2pt)
            h(4pt)
            text(font: fonts.sans, size: 7.8pt, fill: slate-700)[#c.label]
          })
        )
      ]
    ]
  ]

  if title != none or subtitle != none or badge-label != none or footer != none {
    figure-card(
      title: title,
      subtitle: subtitle,
      badge-label: badge-label,
       badge-variant: "info",
      footer: footer,
      above: above,
      below: below,
      canvas-body,
    )
  } else {
    canvas-body
  }
}

/// Chemical Reaction & Thermodynamic Equilibrium Block
/// Formats stoichiometric reactions via `#ce(...)` with optional enthalpy (delta-h),
/// Gibbs free energy (delta-g), equilibrium constant, or reaction conditions.
#let reaction(
  spec,
  title: none,
  delta-h: none,
  delta-g: none,
  keq: none,
  conditions: none,
  num: none,
  above: 1.0em,
  below: 1.0em,
) = block(
  width: 100%,
  fill: rgb("#F8FAFC"),
  stroke: strokes.border + slate-200,
  radius: radii.md,
  inset: (x: 12pt, y: 9pt),
  above: above,
  below: below,
)[
  #if title != none or conditions != none [
    #grid(
      columns: (1fr, auto),
      align: (horizon, horizon),
      if title != none [
        #text(font: fonts.sans, size: 8.2pt, weight: "bold", fill: slate-600, tracking: 0.04em)[#upper(title)]
      ],
      if conditions != none [
        #badge(conditions, variant: "info")
      ]
    )
    #v(4pt)
  ]
  #grid(
    columns: (1fr, auto),
    align: (center + horizon, right + horizon),
    text(size: 11.5pt, fill: floe-navy)[
      #if type(spec) == str { ce(spec) } else { spec }
    ],
    [
      #if delta-h != none [
        #box(fill: white, stroke: strokes.hairline + slate-200, radius: radii.sm, inset: (x: 6pt, y: 2.5pt))[
          #text(font: fonts.sans, size: 8pt, fill: slate-700)[$Delta H^circle.stroked.tiny =$ #delta-h]
        ]
      ]
      #if delta-g != none [
        #h(4pt)
        #box(fill: white, stroke: strokes.hairline + slate-200, radius: radii.sm, inset: (x: 6pt, y: 2.5pt))[
          #text(font: fonts.sans, size: 8pt, fill: slate-700)[$Delta G^circle.stroked.tiny =$ #delta-g]
        ]
      ]
      #if keq != none [
        #h(4pt)
        #box(fill: white, stroke: strokes.hairline + slate-200, radius: radii.sm, inset: (x: 6pt, y: 2.5pt))[
          #text(font: fonts.sans, size: 8pt, fill: slate-700)[$K_("eq") =$ #keq]
        ]
      ]
      #if num != none [
        #h(6pt)
        #text(font: fonts.sans, size: 8.5pt, fill: slate-500)[(#num)]
      ]
    ]
  )
]
