#import "model.typ": severity-scale, likelihood-scale, validate-risks, coverage, check-policy, risk-level
#import "theme.typ": ink, muted, border, levels, note, refs

#let workshop(number, title, body) = {
  assert(type(number) == int and number >= 1 and number <= 5, message: "atelier : numéro de 1 à 5 attendu")
  block(above: 18pt, below: 12pt, sticky: true)[
    #show heading: set block(above: 0pt, below: 0pt)
    #heading(level: 1, numbering: none)[#number. #title]
  ]
  body
}

// columns: ((key: "id", label: [ID], width: 1fr), ...).
#let data-table(rows, columns, font-size: 8.8pt) = {
  assert(type(rows) == array, message: "table : tableau attendu")
  assert(columns.len() > 0, message: "table : colonnes requises")
  set text(size: font-size)
  set par(justify: false, leading: 0.6em)
  table(
    columns: columns.map(c => c.at("width", default: 1fr)),
    inset: (x: 6pt, y: 7pt),
    stroke: (top: none, bottom: 0.5pt + border, left: none, right: none),
    fill: none,
    align: left + top,
    table.header(..columns.map(c => table.cell(
      stroke: (top: 0.6pt + ink, bottom: 0.6pt + ink, left: none, right: none),
      text(size: 8pt, fill: ink, weight: "bold", c.label),
    ))),
    ..if rows.len() == 0 {
      (table.cell(colspan: columns.len(), text(fill: muted)[Aucune donnée renseignée.]),)
    } else {
      rows.map(r => columns.map(c => {
        assert(c.key in r, message: "table : champ manquant « " + c.key + " »")
        r.at(c.key)
      })).flatten()
    },
  )
}

#let scope-card(title: "Périmètre de l'étude", objective: [], scope: [], participants: [], decision-maker: [], strategic-cycle: [], operational-cycle: [], assumptions: []) = note[
  #text(size: 11pt, weight: "bold", fill: ink, title)
  #v(7pt)
  #set text(size: 9pt)
  #grid(columns: (32mm, 1fr), column-gutter: 12pt, row-gutter: 7pt,
    text(fill: muted)[Objectif], objective,
    text(fill: muted)[Périmètre], scope,
    text(fill: muted)[Participants], participants,
    text(fill: muted)[Décideur], decision-maker,
    text(fill: muted)[Cycle stratégique], strategic-cycle,
    text(fill: muted)[Cycle opérationnel], operational-cycle,
    text(fill: muted)[Hypothèses], assumptions,
  )
]

#let assets-table(rows) = data-table(rows, (
  (key: "id", label: [ID], width: 13mm),
  (key: "name", label: [Valeur métier], width: 1.2fr),
  (key: "mission", label: [Mission], width: 1.2fr),
  (key: "owner", label: [Propriétaire], width: 1fr),
  (key: "supports", label: [Biens supports], width: 1.5fr),
))

#let baseline-table(rows) = data-table(rows, (
  (key: "id", label: [ID], width: 13mm),
  (key: "reference", label: [Référence retenue], width: 1.3fr),
  (key: "status", label: [État], width: 0.8fr),
  (key: "gap", label: [Écart constaté], width: 1.4fr),
  (key: "action", label: [Suite à donner], width: 1.4fr),
))

#let events-table(rows) = data-table(rows.map(e => (
  id: e.id, title: [#e.title \ #text(fill: muted, refs(e.assets))],
  impact: e.impact, rating: [*G#e.gravity* \ #e.rationale],
)), (
  (key: "id", label: [ID], width: 13mm),
  (key: "title", label: [Événement / valeurs], width: 1.4fr),
  (key: "impact", label: [Conséquences], width: 1.5fr),
  (key: "rating", label: [Gravité justifiée], width: 1.5fr),
))

#let sources-table(rows) = data-table(rows.map(s => (
  id: s.id, pair: [*#s.source* \ #s.objective],
  profile: [*Motivation :* #s.motivation \ *Ressources :* #s.resources],
  selection: [#strong(if s.retained { [Retenu] } else { [Écarté] }) \ #s.relevance \ #s.rationale],
)), (
  (key: "id", label: [ID], width: 14mm),
  (key: "pair", label: [Source / objectif], width: 1.4fr),
  (key: "profile", label: [Caractérisation], width: 1.3fr),
  (key: "selection", label: [Pertinence et sélection], width: 1.6fr),
))

#let stakeholders-table(rows) = data-table(rows.map(p => (
  id: p.id, name: p.name,
  evaluation: [*Exposition :* #p.exposure \ *Fiabilité cyber :* #p.reliability],
  selection: [*#p.danger* · #if p.retained { [retenue] } else { [écartée] } \ #p.rationale \ *Mesures :* #refs(p.measures)],
)), (
  (key: "id", label: [ID], width: 13mm),
  (key: "name", label: [Partie prenante], width: 1fr),
  (key: "evaluation", label: [Relation et sécurité], width: 1.7fr),
  (key: "selection", label: [Dangerosité / mesures], width: 1.8fr),
))

// One path per row; use multiple rows for alternative paths. Not an AND/OR graph.
#let attack-path(steps) = {
  assert(type(steps) == array and steps.len() > 0, message: "chemin : au moins une étape requise")
  grid(columns: (10pt, 1fr), column-gutter: 5pt, row-gutter: 5pt, align: left + top,
    ..steps.enumerate().map(((i, step)) => (
      text(fill: muted, str(i + 1) + "."),
      step,
    )).flatten(),
  )
}

#let strategic-table(rows) = data-table(rows.map(s => (
  id: s.id, scenario: [*#s.title* \ SR/OV : #s.source \ ER : #refs(s.events) \ PP : #refs(s.stakeholders)],
  path: attack-path(s.path), rating: [*G#s.gravity*],
)), (
  (key: "id", label: [ID], width: 13mm),
  (key: "scenario", label: [Scénario / rattachements], width: 1.2fr),
  (key: "path", label: [Chemin à l'échelle métier], width: 1.8fr),
  (key: "rating", label: [Gravité], width: 17mm),
))

#let operational-table(rows) = data-table(rows.map(o => (
  id: o.id, scenario: [*#o.title* \ Scénario : #o.strategic \ Supports : #o.supports],
  path: attack-path(o.path), rating: [*V#o.likelihood* \ #o.rationale],
)), (
  (key: "id", label: [ID], width: 13mm),
  (key: "scenario", label: [Rattachement / supports], width: 1.2fr),
  (key: "path", label: [Déroulement], width: 1.6fr),
  (key: "rating", label: [Vraisemblance justifiée], width: 1.4fr),
))

#let risk-register(risks, severity: severity-scale, likelihood: likelihood-scale, policy: none) = {
  validate-risks(risks, severity: severity, likelihood: likelihood)
  check-policy(policy, severity.len(), likelihood.len())
  let rating(g, v) = [
    *G#g / V#v*
    #if policy != none {
      let level = levels.at(risk-level(g, v, policy))
      linebreak(); text(size: 8pt, fill: level.ink, level.label)
    }
  ]
  data-table(risks.map(r => (
    id: r.id,
    title: [*#r.title* \ #r.at("owner", default: "") \ #r.at("strategic", default: []) / #r.at("operational", default: [])],
    initial: rating(r.gravity, r.likelihood),
    residual: if r.at("residual", default: none) == none { [Non évalué] } else [
      #emph(if r.residual.status == "target" { [Cible] } else { [Résiduel évalué] }) \
      #rating(r.residual.gravity, r.residual.likelihood) \
      #r.residual.rationale
      #if r.residual.status == "assessed" { [ \ #r.residual.date \ Preuve : #r.residual.evidence] }
    ],
    decision: r.at("decision", default: "À décider"),
  )), (
    (key: "id", label: [ID], width: 12mm),
    (key: "title", label: [Risque / propriétaire], width: 1.25fr),
    (key: "initial", label: [Initial], width: 22mm),
    (key: "residual", label: [Cible ou résiduel], width: 1.7fr),
    (key: "decision", label: [Décision / suivi], width: 1.1fr),
  ))
}

#let treatment-table(rows) = data-table(rows.map(m => (
  id: m.id, action: [*#m.title* \ Risques : #refs(m.risks) \ Priorité : #m.priority],
  owner: [#m.owner \ Échéance : #m.due],
  tracking: [*#m.status* \ #m.evidence],
)), (
  (key: "id", label: [ID], width: 13mm),
  (key: "action", label: [Mesure / rattachement], width: 1.6fr),
  (key: "owner", label: [Responsable / échéance], width: 1.1fr),
  (key: "tracking", label: [État / critère de vérification], width: 1.6fr),
))

#let coverage-table(events, risks) = data-table(coverage(events, risks).map(c => (
  event: c.event, risks: refs(c.risks),
  status: if c.risks.len() == 0 {
    strong([À instruire])
  } else { [Scénario documenté] },
)), (
  (key: "event", label: [Événement redouté], width: 1fr),
  (key: "risks", label: [Risques associés], width: 1fr),
  (key: "status", label: [Couverture], width: 1.2fr),
))
