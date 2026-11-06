// Compose molecular panels using the chemical baseline, independently of ink bounds.
#import "@preview/alchemist:0.2.0": cetz

#let _molecule-row(items, spacing: 0.7em) = items.join(h(spacing))

#let _reaction-arrow(agents, conditions) = context {
  let conditions = if conditions == "" { none } else { conditions }
  let above = _molecule-row(agents, spacing: 0.5em)
  let below = if conditions == none { [] } else { conditions }
  let unit = measure(h(1em)).width
  let half = calc.max(2 * unit, measure(above).width / 2 + 0.3 * unit, measure(below).width / 2 + 0.3 * unit)
  cetz.canvas(baseline: (0, 0), {
    import cetz.draw: *
    line((-half, 0pt), (half, 0pt), stroke: 0.6pt, mark: (end: ">", fill: black))
    if agents.len() > 0 { content((0pt, 0.55em), above, anchor: "south") }
    if conditions != none and conditions != [] { content((0pt, -0.55em), below, anchor: "north") }
  })
}

#let _reaction-row(reactants, agents, products, conditions) = {
  _molecule-row((reactants, _reaction-arrow(agents, conditions), products), spacing: 1em)
}

#let _rgroup-condition(condition) = {
  let group = [R#sub(str(condition.group))]
  let occurrence = condition.occurrence
  let count = if occurrence == ">0" { [at least one site] } else { [#occurrence sites] }
  let remainder = if condition.restH { [H] } else { [any substituent] }
  text(size: 0.8em)[#group: #count#text("; remaining sites: ")#remainder.#if condition.thenGroup > 0 {
    [ If #group is present, R#sub(str(condition.thenGroup)) must also be present.]
  }]
}

#let _rgroup-panel(root, members, conditions) = {
  let cells = ()
  for member in members {
    cells.push(math.equation(math.upright(math.attach([R], b: [#member.group], t: std.hide([#member.group])) + [ =])))
    cells.push(member.drawing)
  }
  stack(dir: ttb, spacing: 1em, root,
    grid(columns: 2, column-gutter: 0.7em, row-gutter: 0.6em,
      align: (right + horizon, left + horizon), ..cells),
    ..conditions.map(_rgroup-condition))
}
