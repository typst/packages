///! Row plan describing every rendered row.
///!
///! Layout builds this once and reads it for everything afterwards: which part
///! a row belongs to, which native header level carries it, which input row it
///! came from, and whether it takes a stripe. Nothing downstream does row
///! arithmetic of its own.

#import "../parts/spanners.typ": spanner-rows
#import "../parts/summaries.typ": directives-for, summary-count

#let entry(part, level: none, source: none, stripe: false) = (
  part: part,
  level: level,
  source: source,
  stripe: stripe,
)

// The plan and the spanner rows it counted, returned together: the renderer
// needs both, and computing the rows twice left the count and the list free to
// disagree with nothing to notice.
#let build-plan(spec) = {
  let plan = ()
  let spanners = spanner-rows(spec)

  // Level 1: the title block, which does not repeat across page breaks.
  if spec.header.title != none { plan.push(entry("title", level: 1)) }
  if spec.header.subtitle != none { plan.push(entry("subtitle", level: 1)) }

  // Level 2: the spanner rows, highest level first, then the column labels.
  // They repeat together, and the plan enumerates them so nothing downstream
  // has to recount the header.
  for index in range(spanners.len()) {
    plan.push(entry("spanner", level: 2, source: index))
  }
  plan.push(entry("labels", level: 2))

  // Striping is computed from the body row position here rather than from a
  // show rule at render time, so its phase survives a page break. It counts
  // body rows alone, so a group label never takes a stripe or shifts the phase.
  // Ungrouped data is one nameless block, so both shapes take the same loop.
  let grouped = spec.groups.len() > 0
  let blocks = if grouped { spec.groups.map(group => group.rows) } else {
    (range(spec.data.len()),)
  }

  let stripe = 0

  // Declared groups need not cover the data, so whatever no group claims leads
  // the body as a nameless block, exactly as an ungrouped table does. Derived
  // groups cover every row by construction, so this is empty for them.
  let claimed = blocks.flatten()
  for position in range(spec.data.len()).filter(position => position not in claimed) {
    plan.push(entry("body", source: position, stripe: calc.odd(stripe)))
    stripe += 1
  }

  for (index, positions) in blocks.enumerate() {
    // Level 3: the group label, which repeats until the next group retires it,
    // so a group spanning a page break reprints its name.
    if grouped { plan.push(entry("group", level: 3, source: index)) }
    for position in positions {
      plan.push(entry("body", source: position, stripe: calc.odd(stripe)))
      stripe += 1
    }
    // Group summaries close their group. They are not body rows, so they take
    // no stripe and do not shift the phase of the rows below.
    if grouped {
      let applicable = directives-for(spec.summaries, spec.groups.at(index).label)
      for row in range(summary-count(applicable)) {
        plan.push(entry("summary", source: (group: index, row: row)))
      }
    }
  }

  for row in range(summary-count(spec.grand-summaries)) {
    plan.push(entry("grand-summary", source: row))
  }

  for (position, note) in spec.source-notes.enumerate() {
    plan.push(entry("source-note", source: position))
  }

  (rows: plan, spanners: spanners)
}
