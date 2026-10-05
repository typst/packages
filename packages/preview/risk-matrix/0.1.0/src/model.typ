// Scales follow the labels of ANSSI EBIOS RM v1.5, pp. 26 and 66.
// Consequence thresholds and likelihood rationales belong to the study.
#let severity-scale = ("Mineure", "Significative", "Grave", "Critique")
#let likelihood-scale = ("Peu vraisemblable", "Vraisemblable", "Très vraisemblable", "Quasi certain")

// A project example, NOT a prescribed ANSSI acceptance policy.
// Rows: G1..G4. Columns: V1..V4. Nothing is inferred by multiplication.
#let example-policy = (
  ("low", "low", "medium", "medium"),
  ("low", "medium", "medium", "high"),
  ("medium", "medium", "high", "high"),
  ("medium", "high", "high", "high"),
)

#let require-fields(item, fields, where) = {
  assert(type(item) == dictionary, message: where + ": dictionnaire attendu")
  for field in fields {
    assert(field in item, message: where + ": champ manquant « " + field + " »")
  }
}

#let check-id(id) = {
  assert(type(id) == str and id.trim() != "", message: "identifiant non vide attendu")
}

#let check-rating(value, maximum, name) = {
  assert(type(value) == int, message: name + ": entier attendu")
  assert(value >= 1 and value <= maximum, message: name + ": hors échelle (1.." + str(maximum) + ")")
}

#let check-policy(policy, g-count, v-count) = {
  if policy != none {
    assert(type(policy) == array and policy.len() == g-count, message: "politique : nombre de lignes incorrect")
    for row in policy {
      assert(type(row) == array and row.len() == v-count, message: "politique : nombre de colonnes incorrect")
      for level in row {
        assert(level in ("low", "medium", "high"), message: "politique : classe inconnue (low, medium, high)")
      }
    }
  }
}

#let risk-level(gravity, likelihood, policy) = {
  assert(type(policy) == array and policy.len() > 0, message: "politique explicite requise")
  assert(type(policy.first()) == array and policy.first().len() > 0, message: "politique vide")
  check-policy(policy, policy.len(), policy.first().len())
  check-rating(gravity, policy.len(), "gravité")
  check-rating(likelihood, policy.first().len(), "vraisemblance")
  policy.at(gravity - 1).at(likelihood - 1)
}

#let risk(id, title, gravity, likelihood, owner: "", strategic: none, operational: none, feared-events: (), residual: none, decision: "À décider") = (
  id: id, title: title, gravity: gravity, likelihood: likelihood,
  owner: owner, strategic: strategic, operational: operational,
  feared-events: feared-events, residual: residual, decision: decision,
)

#let validate-risks(risks, severity: severity-scale, likelihood: likelihood-scale) = {
  assert(type(risks) == array, message: "risques : tableau attendu")
  assert(type(severity) == array and severity.len() > 0, message: "échelle de gravité vide")
  assert(type(likelihood) == array and likelihood.len() > 0, message: "échelle de vraisemblance vide")
  let ids = ()
  for r in risks {
    require-fields(r, ("id", "title", "gravity", "likelihood"), "risque")
    check-id(r.id)
    assert(not (r.id in ids), message: "identifiant de risque dupliqué : " + r.id)
    ids.push(r.id)
    check-rating(r.gravity, severity.len(), "gravité de " + r.id)
    check-rating(r.likelihood, likelihood.len(), "vraisemblance de " + r.id)
    let residual = r.at("residual", default: none)
    if residual != none {
      require-fields(residual, ("gravity", "likelihood", "status", "rationale"), "résiduel de " + r.id)
      check-rating(residual.gravity, severity.len(), "gravité résiduelle de " + r.id)
      check-rating(residual.likelihood, likelihood.len(), "vraisemblance résiduelle de " + r.id)
      assert(residual.status in ("target", "assessed"), message: "résiduel : statut target ou assessed requis")
      assert(type(residual.rationale) == str and residual.rationale.trim() != "", message: "résiduel : justification requise")
      if residual.status == "assessed" {
        require-fields(residual, ("date", "evidence"), "résiduel évalué de " + r.id)
        assert(type(residual.date) == str and residual.date.trim() != "", message: "résiduel évalué : date requise")
        assert(type(residual.evidence) == str and residual.evidence.trim() != "", message: "résiduel évalué : preuve requise")
      }
    }
  }
  none
}

#let indexed(rows, fields, name) = {
  assert(type(rows) == array, message: name + ": tableau attendu")
  let ids = ()
  for row in rows {
    require-fields(row, ("id",) + fields, name)
    check-id(row.id)
    assert(not (row.id in ids), message: name + ": identifiant dupliqué " + row.id)
    ids.push(row.id)
  }
  ids
}

#let check-refs(refs, ids, where, nonempty: false) = {
  assert(type(refs) == array, message: where + ": tableau de références attendu")
  if nonempty { assert(refs.len() > 0, message: where + ": référence requise") }
  for ref in refs {
    assert(ref in ids, message: where + ": référence inconnue « " + str(ref) + " »")
  }
}

// Cross-workshop integrity checks; completeness remains an analyst decision.
#let validate-study(study, severity: severity-scale, likelihood: likelihood-scale) = {
  require-fields(study, ("assets", "baseline", "events", "sources", "stakeholders", "strategic", "operational", "risks", "measures"), "étude")
  let assets = indexed(study.assets, ("name", "mission", "owner", "supports"), "valeur métier")
  let baseline = indexed(study.baseline, ("reference", "status", "gap", "action"), "socle")
  let events = indexed(study.events, ("title", "assets", "gravity", "impact", "rationale"), "événement redouté")
  let sources = indexed(study.sources, ("source", "objective", "motivation", "resources", "relevance", "retained", "rationale"), "couple SR/OV")
  let stakeholders = indexed(study.stakeholders, ("name", "exposure", "reliability", "danger", "retained", "rationale", "measures"), "partie prenante")
  let strategic = indexed(study.strategic, ("title", "source", "events", "stakeholders", "path", "gravity"), "scénario stratégique")
  let operational = indexed(study.operational, ("title", "strategic", "path", "supports", "likelihood", "rationale"), "scénario opérationnel")
  validate-risks(study.risks, severity: severity, likelihood: likelihood)
  let risk-ids = study.risks.map(r => r.id)
  let measures = indexed(study.measures, ("title", "risks", "owner", "due", "status", "priority", "evidence"), "mesure")
  for e in study.events {
    check-refs(e.assets, assets, e.id, nonempty: true)
    check-rating(e.gravity, severity.len(), e.id + " gravité")
  }
  for s in study.sources {
    assert(type(s.retained) == bool, message: s.id + ": retained doit être booléen")
  }
  for p in study.stakeholders {
    assert(type(p.retained) == bool, message: p.id + ": retained doit être booléen")
    check-refs(p.measures, measures, p.id)
  }
  for s in study.strategic {
    check-refs((s.source,), sources, s.id)
    let pair = study.sources.find(x => x.id == s.source)
    assert(pair.retained, message: s.id + ": couple SR/OV non retenu")
    check-refs(s.events, events, s.id, nonempty: true)
    check-refs(s.stakeholders, stakeholders, s.id)
    check-rating(s.gravity, severity.len(), s.id + " gravité")
    let maximum = calc.max(..study.events.filter(e => e.id in s.events).map(e => e.gravity))
    assert(s.gravity == maximum, message: s.id + ": gravité incohérente avec les événements liés")
    assert(type(s.path) == array and s.path.len() > 0, message: s.id + ": chemin requis")
  }
  for o in study.operational {
    check-refs((o.strategic,), strategic, o.id)
    assert(type(o.path) == array and o.path.len() > 0, message: o.id + ": chemin requis")
    check-rating(o.likelihood, likelihood.len(), o.id + " vraisemblance")
  }
  for r in study.risks {
    require-fields(r, ("strategic", "operational", "feared-events", "owner", "decision"), r.id)
    check-refs((r.strategic,), strategic, r.id)
    check-refs((r.operational,), operational, r.id)
    check-refs(r.feared-events, events, r.id, nonempty: true)
    let s = study.strategic.find(x => x.id == r.strategic)
    let o = study.operational.find(x => x.id == r.operational)
    assert(o.strategic == s.id, message: r.id + ": scénarios non reliés")
    check-refs(r.feared-events, s.events, r.id + " événements du scénario")
    assert(r.gravity == s.gravity, message: r.id + ": gravité différente du scénario stratégique")
    assert(r.likelihood == o.likelihood, message: r.id + ": vraisemblance différente du scénario opérationnel")
  }
  for m in study.measures {
    check-refs(m.risks, risk-ids, m.id)
  }
  none
}

#let coverage(events, risks) = events.map(e => (
  event: e.id,
  risks: risks.filter(r => e.id in r.at("feared-events", default: ())).map(r => r.id),
))
