/// Fitch-style proof environment.

// Premise {
//   type: "premise",
//   num: Int,
//   content: Content,
//   rule?: Content,
// }
#let fitch-premise(num, content, rule: none) = (
  type: "premise",
  num: num,
  content: content,
  rule: rule,
)

// Assumption {
//   type: "assume",
//   num: Int,
//   content: Content,
//   rule?: Content,
// }
#let fitch-assume(num, content, rule: none) = (
  type: "assume",
  num: num,
  content: content,
  rule: rule,
)

// Step {
//   type: "step",
//   num: Int,
//   content: Content,
//   rule?: Content,
// }
#let fitch-step(num, content, rule: none) = (
  type: "step",
  num: num,
  content: content,
  rule: rule,
)

// Subproof {
//   type: "subproof",
//   lines: [Item],
// }
#let fitch-subproof(
  ..lines,
) = (
  type: "subproof",
  lines: lines.pos(),
)

// Item {
//   num: Int,
//   depth: Int,
//   type: String,
//   content: Content,
//   rule?: Content,
// }


#let _fitch-num-cell(num, _style) = {
  align(right)[#num]
}

#let _fitch-line-cell(item, depth, is-first, is-last, style) = {
  let out = item.content

  if is-last {
    out = box(
      out,
      stroke: (bottom: style.stroke),
      outset: style.pad,
    )
  }

  for level in range(0, depth) {
    let top-out = if level == 0 and is-first {
      style.pad
    } else {
      style.pad + style.row-gutter
    }
    out = box(
      inset: (left: style.indent, rest: 0pt),
      box(
        out,
        stroke: (left: style.stroke),
        outset: (top: top-out, rest: style.pad),
      ),
    )
  }

  out
}

#let _fitch-rule-cell(item, style) = {
  let rule = if item.rule != none {
    item.rule
  } else if item.type == "premise" {
    "Premise"
  } else if item.type == "assume" {
    "Assumption"
  }
  if rule == none { [] } else { text(..style.rule-style)[#rule] }
}


#let fitch-style-default = (
  col-gutter: 0.8em,
  row-gutter: 0.3em,
  // Stroke used for scope bars and assumption underlines.
  stroke: 1pt + blue,
  // Stroke used for the separator between line numbers and content.
  sep-stroke: 1pt + blue,
  // Horizontal spacing between nested bars.
  indent: 1em,
  // Padding inside the cell.
  pad: 0.5em,
  // Style for the rule cell.
  rule-style: (style: "italic"),
)

#let fitch-proof(
  ..nodes,
  start: 1,
  style: fitch-style-default,
) = {
  style = fitch-style-default + style

  let premises = ()
  let body = ()
  for item in nodes.pos() {
    if item.type == "premise" {
      assert(body.len() == 0, message: "Premises must come before other lines in a proof.")
      premises.push(item)
    } else {
      body.push(item)
    }
  }

  let handle-premises(items, depth) = {
    let out = ()
    for (idx, item) in items.enumerate() {
      let is-first = idx == 0
      let is-last = idx == items.len() - 1
      out.push(_fitch-num-cell(item.num, style))
      out.push(_fitch-line-cell(item, depth, is-first, is-last, style))
      out.push(_fitch-rule-cell(item, style))
    }
    out
  }

  let parse-subproof(subproof) = {
    let assumptions = ()
    let subitems = ()
    for item in subproof.lines {
      if item.type == "assume" {
        assert(subitems.len() == 0, message: "Assumptions must come before other lines in a subproof.")
        assumptions.push(item)
      } else {
        subitems.push(item)
      }
    }
    (assumptions, subitems)
  }

  let process-items(items, depth) = {
    let out = ()
    for item in items {
      if item.type == "subproof" {
        let (assumptions, subitems) = parse-subproof(item)
        out += handle-premises(assumptions, depth + 1)
        out += process-items(subitems, depth + 1)
      } else {
        out.push(_fitch-num-cell(item.num, style))
        out.push(_fitch-line-cell(item, depth, false, false, style))
        out.push(_fitch-rule-cell(item, style))
      }
    }
    out
  }

  let cells = ()
  cells += handle-premises(premises, 0)
  cells += process-items(body, 0)

  grid(
    columns: 3,
    column-gutter: style.col-gutter,
    row-gutter: style.row-gutter,
    inset: style.pad,
    grid.vline(x: 1, stroke: style.sep-stroke),
    ..cells,
  )
}
