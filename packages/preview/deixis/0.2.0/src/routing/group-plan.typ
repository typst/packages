#import "avoid.typ": _deixis-avoid
#import "group-geometry.typ": endpoint, validate-junctions, lanes-against, metrics
#import "group-sockets.typ": _deixis-socket-pairs

#let empty(edge, index) = (id: edge.id, page: edge.at("page", default: none), edge-index: index,
  search-id: none, status: "budget", detail: "repair-budget", points: (), stats: (:))

// The book accounts for every search, including rejected proposals. All plan
// references point backward to checked search records, making audit independent
// of proposal/commit state. Budget exhaustion retains the checked incumbent.
#let solve(scene, edges, index, against, book, spacing, weight, policy: "soft", cost-options: (:),
  allocate: false, attempt-expansions: auto,
) = {
  let edge = edges.at(index); let page = edge.at("page", default: none)
  if "failure" in edge {
    return (record: edge.failure + (id: edge.id, page: page, edge-index: index,
      search-id: none, points: ()), book: book)
  }
  let remaining = calc.min(if attempt-expansions == auto { scene.max-expansions } else { attempt-expansions },
    book.max-expansions - book.expanded)
  if remaining <= 0 or book.searches.len() >= book.max-searches { return (record: none, book: book) }
  let plane = scene.planes.find(p => p.page == page)
  assert(plane != none)
  let convert(value) = {
    let e = endpoint(value)
    (point: e.point, normal: e.normal, owner: e.owner, owner-gap: e.at("owner-gap", default: 0))
  }
  against = against.filter(r => r.status == "ok" and r.page == page).sorted(key: r => r.edge-index)
  let lanes = against.map(r => lanes-against(scene, edge, edges.at(r.edge-index), r)).flatten()
  let allocation = if allocate { edge.allocation } else { none }
  let reverse = allocate and allocation.reverse
  let source = convert(if reverse { edge.to } else { edge.from })
  let target = convert(if reverse { edge.from } else { edge.to })
  let visits = edge.at("via", default: ())
  let alternatives(values) = if values.len() > 1 { values.map(convert) } else { none }
  let options = if not allocate { (:) } else { (
    sources: alternatives(if reverse { allocation.target } else { allocation.source }),
    targets: if allocation.boundary != none { none } else { alternatives(allocation.target) },
    boundary: allocation.boundary,
  ) }
  let r = _deixis-avoid(source, target, plane, via: if reverse { visits.rev() } else { visits },
    clearance: scene.clearance, escape: scene.escape, bend-cost: scene.bend-cost,
    max-cells: scene.max-cells, max-expansions: remaining, lanes: lanes, policy: policy, spacing: spacing, weight: weight,
    ..cost-options, ..options)
  if reverse {
    r.points = r.points.rev()
    if "selection" in r { r.selection = (source: r.selection.target, target: r.selection.source) }
    if r.status == "endpoint-blocked" {
      if r.detail.starts-with("source-") { r.detail = "target-" + r.detail.slice(7) }
      else if r.detail.starts-with("target-") { r.detail = "source-" + r.detail.slice(7) }
    }
  }
  if allocate and r.status == "ok" {
    // Recover full socket identity, including its exact junction, only after
    // selection. Future fixed-port repairs reuse this accepted frame/normal.
    let port(role, choices, preferred, point) = {
      let chosen = if "selection" in r { r.selection.at(role) } else { convert(preferred) + (point: point) }
      let match = choices.find(p => p.point == chosen.point and p.normal == chosen.normal)
      if match == none { chosen + (junction: none) } else { match }
    }
    r.selection = (source: port("source", allocation.source, edge.from, r.points.first()),
      target: port("target", allocation.target, edge.to, r.points.last()))
  } else if r.status == "ok" and edge.at("allocated", default: false) {
    r.selection = (source: endpoint(edge.from), target: endpoint(edge.to))
    if "allocation-preference" in edge {
      r += (preference: edge.allocation-preference, allocation-cost: r.weighted-score + edge.allocation-preference)
    }
  }
  book.expanded += calc.min(remaining, r.stats.at("expanded", default: 0))
  r += (id: edge.id, page: page, edge-index: index, search-id: book.searches.len())
  let evidence = if edge.at("reselected", default: false) {
    (sockets: (source: edge.from, target: edge.to))
  } else { (:) }
  book.searches.push((policy: policy, against: against.map(p => p.search-id), record: r) + evidence)
  // Automatic choices are resolved once for the independent reference, then
  // frozen before ordinary path repair. Optional group socket proposals use
  // separate fixed searches, retaining the original checked length references.
  // Both feasibility attempts consume the same per-edge/global allowance.
  if not allocate and policy == "independent" and "allocation" in edge {
    let a = edge.allocation
    let move-source = a.source.len() > 1 or (a.boundary != none and a.reverse)
    let move-target = a.target.len() > 1 or (a.boundary != none and not a.reverse)
    let retry = r.status == "no-path" or (r.status == "endpoint-blocked"
      and ((move-source and r.detail.starts-with("source-")) or (move-target and r.detail.starts-with("target-"))))
    let allowance = remaining - calc.min(remaining, r.stats.at("expanded", default: 0))
    if retry and (move-source or move-target) and allowance > 0 {
      let next = solve(scene, edges, index, against, book, spacing, weight,
        policy: policy, cost-options: cost-options, allocate: true, attempt-expansions: allowance)
      if next.record != none { return next }
    }
  }
  (record: r, book: book)
}

#let new-book(max-searches, max-expansions) = (max-searches: max-searches, max-expansions: max-expansions, expanded: 0, searches: ())

#let _deixis-group-limits(book, searches-limited: false) = {
  let limits-hit = ()
  if searches-limited or book.searches.len() >= book.max-searches { limits-hit.push("searches") }
  if book.expanded >= book.max-expansions { limits-hit.push("expansions") }
  if book.searches.any(s => s.record.status == "budget" and s.record.detail == "grid-cells") { limits-hit.push("cells") }
  if book.searches.any(s => s.record.status == "budget" and s.record.detail == "search-expansions") { limits-hit.push("attempt-expansions") }
  limits-hit
}

#let validate-input(edges, spacing, weight, max-searches, max-expansions) = {
  let finite(v) = type(v) in (int, float) and v == v and calc.abs(v) < calc.inf
  assert(edges.len() <= 16)
  assert(finite(spacing) and spacing > 0 and finite(weight) and weight >= 0)
  assert(type(max-searches) == int and max-searches > 0 and type(max-expansions) == int and max-expansions > 0)
  let keys = edges.filter(e => e.id != none).map(e => (e.id, e.at("page", default: none)))
  assert.eq(keys.dedup().len(), keys.len())
}

#let decision(baseline, incumbent, candidate, before, after, length-ratio, length-extra) = {
  for (i, old) in incumbent.enumerate() {
    if old.status == "ok" and candidate.at(i).status != "ok" { return "lost-route" }
    if candidate.at(i).status == "ok" {
      if baseline.at(i).status != "ok" { return "no-reference" }
      if candidate.at(i).length > baseline.at(i).length * length-ratio + length-extra { return "detour" }
    }
  }
  if after.contacts > before.contacts or after.crossings > before.crossings { return "contacts" }
  if after.overlap > before.overlap { return "overlap" }
  let tolerance = calc.max(calc.abs(before.energy), calc.abs(after.energy)) * 1e-10
  if after.energy >= before.energy - tolerance { return "no-improvement" }
  "accept"
}

#let attempts(local, window) = {
  let result = local.rev().map(i => (indices: (i,), order: (i,)))
  if window >= 2 {
    // Near-priority pairs first, then separated pairs. Each pair gets both
    // directions without requiring any global permutation of the batch.
    for distance in range(1, local.len()) {
      for start in range(local.len() - distance).rev() {
        let pair = (local.at(start), local.at(start + distance))
        result.push((indices: pair, order: pair.rev()))
        result.push((indices: pair, order: pair))
      }
    }
  }
  if window >= 3 and local.len() >= 3 {
    for start in range(local.len() - 2).rev() {
      let triple = local.slice(start, start + 3)
      result.push((indices: triple, order: triple.rev()))
      result.push((indices: triple, order: triple))
    }
  }
  result
}

#let _deixis-plan-group(scene, edges, spacing: 3, weight: 4, rounds: 2, window: 3,
  length-ratio: 1.25, length-extra: 0, max-searches: 64, max-expansions: 50000, cost-options: (:),
  independent: false, reselect: false,
) = {
  validate-input(edges, spacing, weight, max-searches, max-expansions)
  assert(type(rounds) == int and rounds in range(5) and window in (1, 2, 3))
  assert(type(length-ratio) in (int, float) and 1 <= length-ratio and length-ratio < calc.inf
    and type(length-extra) in (int, float) and 0 <= length-extra and length-extra < calc.inf)
  if not independent { validate-junctions(scene, edges) }
  let book = new-book(max-searches, max-expansions)
  if independent {
    // The obstacle-only document policy never constructs reservations, scans
    // pair metrics or enters repair. It shares checked search/fallback and
    // budgets, rather than emulating this policy with a zero penalty weight.
    let records = ()
    for (i, edge) in edges.enumerate() {
      let call = solve(scene, edges, i, (), book, spacing, 0, policy: "independent", cost-options: cost-options)
      book = call.book
      records.push(if call.record == none { empty(edge, i) } else { call.record })
    }
    return (records: records, baseline: records, metrics: none, baseline-metrics: none,
      limits-hit: _deixis-group-limits(book), rounds-run: 0,
      expanded: book.expanded, searches: book.searches, history: ())
  }
  if edges.len() == 0 {
    let quality = metrics(scene, edges, (), spacing: spacing, weight: weight)
    return (records: (), baseline: (), metrics: quality, baseline-metrics: quality,
      limits-hit: (), rounds-run: 0, expanded: 0, searches: (), history: ())
  }
  let baseline = ()
  for (i, edge) in edges.enumerate() {
    let call = solve(scene, edges, i, (), book, spacing, weight, policy: "independent", cost-options: cost-options)
    book = call.book
    baseline.push(if call.record == none { empty(edge, i) } else { call.record })
  }
  for (i, record) in baseline.enumerate() {
    if record.status == "ok" and "selection" in record {
      edges.at(i) += (from: record.selection.source, to: record.selection.target, allocated: true)
      if "preference" in record { edges.at(i) += (allocation-preference: record.preference) }
    }
  }
  validate-junctions(scene, edges)
  let baseline-edges = edges
  let incumbent = baseline; let history = ()
  let searches-limited = false; let rounds-run = 0
  let pages = edges.map(e => e.at("page", default: none)).sorted(key: p => if p == none { -1 } else { p }).dedup()
  let quality = metrics(scene, edges, incumbent, spacing: spacing, weight: weight)
  // The first proposal is ordinary soft sequential allocation, with only checked
  // baseline records retained when an attempted edge fails or budgets run out.
  let greedy = ()
  for (i, edge) in edges.enumerate() {
    if baseline.at(i).status != "ok" { greedy.push(baseline.at(i)); continue }
    let call = solve(scene, edges, i, greedy, book, spacing, weight, cost-options: cost-options)
    book = call.book
    greedy.push(if call.record == none or call.record.status != "ok" { baseline.at(i) } else { call.record })
  }
  for page in pages {
    let changes = greedy.filter(r => r.page == page)
    let candidate = incumbent
    for r in changes { candidate.at(r.edge-index) = r }
    let candidate-quality = metrics(scene, edges, candidate, spacing: spacing, weight: weight)
    let outcome = decision(baseline, incumbent, candidate, quality, candidate-quality, length-ratio, length-extra)
    history.push((kind: "initial", indices: changes.map(r => r.edge-index), changes: changes, before: quality,
      candidate: candidate-quality, decision: outcome))
    if outcome == "accept" { incumbent = candidate; quality = candidate-quality }
  }

  // Lower-priority routes are reconsidered first. Singles, bounded pairs in
  // both directions and optional local triples keep all other geometry fixed.
  // Equal-quality proposals preserve the incumbent. No global order search.
  for round in range(rounds) {
    rounds-run += 1
    let accepted = false
    for page in pages {
      let local = range(edges.len()).filter(i => edges.at(i).at("page", default: none) == page)
      // Try permitted real sockets or automatic relays against the incumbent.
      // Each search uses one fixed pair and its exact owner/shared-stub masks.
      // Rejecting a proposal changes neither sockets nor accepted route records.
      if reselect and weight > 0 and quality.exposure > 0 {
        for i in local.rev() {
          let proposals = _deixis-socket-pairs(scene, edges, incumbent, i, spacing,
            baseline.at(i).at("length", default: 0) * length-ratio + length-extra)
          for proposal in proposals {
            if book.searches.len() >= book.max-searches { searches-limited = true; break }
            if book.expanded >= book.max-expansions { break }
            let candidate-edges = edges
            candidate-edges.at(i) += (from: proposal.from, to: proposal.to,
              allocated: true, reselected: true)
            let allocation = edges.at(i).allocation
            if allocation.boundary != none {
              let relay = if allocation.reverse { proposal.from } else { proposal.to }
              candidate-edges.at(i) += (allocation-preference:
                calc.abs(relay.point.first() - allocation.boundary.preferred))
            }
            let against = incumbent.filter(r => r.edge-index != i)
            let call = solve(scene, candidate-edges, i, against, book, spacing, weight, cost-options: cost-options)
            book = call.book
            if call.record == none { break }
            let candidate = incumbent; candidate.at(i) = call.record
            let candidate-quality = if call.record.status == "ok" {
              metrics(scene, candidate-edges, candidate, spacing: spacing, weight: weight)
            } else { none }
            let outcome = if candidate-quality == none { "search-failure" } else {
              decision(baseline, incumbent, candidate, quality, candidate-quality, length-ratio, length-extra)
            }
            if outcome == "accept" and candidate-quality.exposure >= quality.exposure { outcome = "no-separation" }
            history.push((kind: "socket", round: round, indices: (i,), changes: (call.record,), before: quality,
              candidate: candidate-quality, decision: outcome))
            if outcome == "accept" {
              edges = candidate-edges; incumbent = candidate; quality = candidate-quality; accepted = true
              break
            }
          }
        }
      }
      for attempt in attempts(local, window) {
        let indices = attempt.indices; let width = indices.len()
        if indices.any(i => incumbent.at(i).status != "ok") { continue }
        if book.searches.len() + width > book.max-searches { searches-limited = true; break }
        if book.expanded >= book.max-expansions { break }
        let candidate = incumbent
        let against = incumbent.filter(r => r.edge-index not in indices)
        let changes = (); let complete = true
        for i in attempt.order {
          let call = solve(scene, edges, i, against, book, spacing, weight, cost-options: cost-options)
          book = call.book
          if call.record == none or call.record.status != "ok" { complete = false; break }
          changes.push(call.record); against.push(call.record); candidate.at(i) = call.record
        }
        if not complete {
          history.push((kind: "window", round: round, indices: indices, order: attempt.order, changes: changes, before: quality,
            candidate: none, decision: "search-failure"))
          continue
        }
        let candidate-quality = metrics(scene, edges, candidate, spacing: spacing, weight: weight)
        let outcome = decision(baseline, incumbent, candidate, quality, candidate-quality, length-ratio, length-extra)
        history.push((kind: "window", round: round, indices: indices, order: attempt.order, changes: changes, before: quality,
          candidate: candidate-quality, decision: outcome))
        if outcome == "accept" { incumbent = candidate; quality = candidate-quality; accepted = true }
      }
    }
    if not accepted { break }
  }
  let limits-hit = _deixis-group-limits(book, searches-limited: searches-limited)
  (records: incumbent, baseline: baseline, metrics: quality, limits-hit: limits-hit, rounds-run: rounds-run,
    baseline-metrics: metrics(scene, baseline-edges, baseline, spacing: spacing, weight: weight),
    expanded: book.expanded, searches: book.searches, history: history)
}
