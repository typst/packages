#import "model.typ": severity-scale, likelihood-scale, validate-risks, check-policy, risk-level
#import "theme.typ": ink, muted, pale, border, levels

#let risk-matrix(risks, severity: severity-scale, likelihood: likelihood-scale, policy: none, stage: "initial", title: none, cell-height: 16mm) = {
  validate-risks(risks, severity: severity, likelihood: likelihood)
  assert(stage in ("initial", "residual"), message: "stage : initial ou residual attendu")
  check-policy(policy, severity.len(), likelihood.len())
  let plotted = risks.filter(r => stage == "initial" or r.at("residual", default: none) != none)
  let missing = risks.filter(r => stage == "residual" and r.at("residual", default: none) == none)
  let children = ()
  for gi in range(severity.len()).rev() {
    children.push(grid.cell(fill: white, align: right + horizon)[
      #text(weight: "bold", fill: ink)[G#(gi + 1)] \
      #text(size: 8pt, fill: muted, severity.at(gi))
    ])
    for vi in range(likelihood.len()) {
      let cell-risks = plotted.filter(r => {
        let point = if stage == "initial" { r } else { r.residual }
        point.gravity == gi + 1 and point.likelihood == vi + 1
      })
      let level = if policy == none { none } else { risk-level(gi + 1, vi + 1, policy) }
      let color = if level == none { (fill: pale, ink: muted, label: "") } else { levels.at(level) }
      children.push(grid.cell(fill: color.fill, layout(size => {
        let body = [
          #text(size: 7pt, fill: color.ink, color.label)
          #v(2pt)
          #for r in cell-risks {
            let suffix = if stage == "initial" { "" } else if r.residual.status == "target" { " · C" } else { " · E" }
            box(inset: (x: 2pt, y: 1pt), text(size: 9pt, weight: "bold", fill: ink, r.id + suffix))
            [#h(3pt) ]
          }
        ]
        // Grow dense cells so identifiers cannot overflow into another risk rating.
        let height = calc.max(cell-height, measure(body, width: size.width).height)
        block(height: height, width: 100%, body)
      })))
    }
  }
  children.push(grid.cell(fill: white)[])
  for (vi, label) in likelihood.enumerate() {
    children.push(grid.cell(fill: white, align: center)[
      #text(weight: "bold", fill: ink)[V#(vi + 1)] \
      #text(size: 8pt, fill: muted, label)
    ])
  }
  block(width: 100%, breakable: false)[
    #if title != none { text(size: 13pt, weight: "bold", fill: ink, title); v(8pt) }
    #text(size: 9pt, fill: muted)[Gravité ↑]
    #v(4pt)
    #grid(columns: (27mm,) + (1fr,) * likelihood.len(), gutter: 3pt, inset: 5pt, ..children)
    #align(right, text(size: 9pt, fill: muted)[Vraisemblance →])
    #v(5pt)
    #if policy == none {
      text(size: 8pt, fill: muted)[Sans politique : positionnement uniquement, sans classe de risque.]
    } else {
      for key in ("low", "medium", "high") {
        let level = levels.at(key)
        box(width: 6pt, height: 6pt, fill: level.fill, stroke: 0.4pt + level.ink)
        h(3pt)
        text(size: 8pt, fill: muted, level.label)
        h(10pt)
      }
    }
    #if stage == "residual" {
      parbreak()
      text(size: 8pt, fill: muted)[C = cible après traitement prévu ; E = résiduel réévalué sur preuves.]
    }
    #if missing.len() > 0 {
      parbreak()
      text(size: 8pt, fill: muted)[Sans cotation cible/résiduelle : #missing.map(r => r.id).join(", ").]
    }
    #if risks.len() == 0 { parbreak(); text(size: 8pt, fill: muted)[Aucun risque renseigné.] }
  ]
}

#let risk-comparison(risks, severity: severity-scale, likelihood: likelihood-scale, policy: none) = [
  #risk-matrix(risks, severity: severity, likelihood: likelihood, policy: policy, title: "01 / Situation initiale")
  #v(14pt)
  #risk-matrix(risks, severity: severity, likelihood: likelihood, policy: policy, stage: "residual", title: "02 / Cibles et risques résiduels")
]
