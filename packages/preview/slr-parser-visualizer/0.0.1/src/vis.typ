#import "lib.typ": *
#import "@preview/diagraph:0.3.6": raw-render



#let render-item(item) = {
  let (lhs, rhs) = item
  let rhs-str = rhs.map(s => if s == "." { text(fill: red.darken(20%))[$bullet.op$] } else if s == "\\epsilon" { $epsilon$ } else { $#s$ })
  box[#$#lhs arrow.r$ #rhs-str.join(h(2pt))]
}

#let fmt-sym(s, variables) = {
  if s == "\\epsilon" { $epsilon$ }
  else if s == "$"    { text(font: "DejaVu Sans Mono", size: 8pt)[\$] }
  else if s in variables { $#s$ }
  else { text(font: "DejaVu Sans Mono", size: 8pt)[#s] }
}

#let dot-escape(s) = {
  s.replace("\\", "\\\\")
   .replace("\"", "\\\"")
   .replace("\n", "\\n")
   .replace("'", "\\'")
}

#let item-to-str(item) = {
  let (lhs, rhs) = item
  let rhs-s = rhs.map(s => if s == "." { "•" } else if s == "\\epsilon" { "ε" } else { s }).join(" ")
  lhs + " → " + rhs-s
}




#let show-grammar(grammar) = {
  block(width: 100%)[
    #table(
      columns: (auto, auto, auto, auto),
      stroke: none,
      align: (center, center, center, left),
      inset: (x: 6pt, y: 3pt),
      [*\#*], [*Var*], [], [*Production*],
      ..grammar.enumerate().map(((i, prod)) => {
        let (lhs, rhs) = prod
        (
          text(fill: purple.darken(20%))[$#i$],
          $#lhs$,
          $arrow.r$,
          rhs.map(s => if s == "\\epsilon" { $epsilon$ } else { $#s$ }).join($space$),
        )
      }).flatten()
    )
  ]
}


#let show-aug-grammar(grammar) = {
  let aug = augment-grammar(grammar)
  block(width: 100%)[
    #table(
      columns: (auto, auto, auto, auto),
      stroke: none,
      align: (center, center, center, left),
      inset: (x: 6pt, y: 3pt),
      [*\#*], [*Var*], [], [*Production*],
      ..aug.enumerate().map(((i, prod)) => {
        let (lhs, rhs) = prod
        (
          text(fill: purple.darken(20%))[$#i$],
          $#lhs$,
          $arrow.r$,
          rhs.map(s => if s == "\\epsilon" { $epsilon$ } else { $#s$ }).join($space$),
        )
      }).flatten()
    )
  ]
}



#let show-first-follow(grammar) = {
  let aug      = augment-grammar(grammar)
  let vars     = get-variables(aug).filter(v => v != aug.at(0).at(0))
  let first    = compute-first(aug)
  let follow   = compute-follow(aug, first)

  block(width: 100%)[
    #table(
      columns: (auto, 1fr, 1fr),
      inset: (x: 8pt, y: 5pt),
      fill: (col, row) => {
        if row == 0 { luma(220) }
        else if calc.odd(row) { luma(248) }
        else { white }
      },      [*Variable*], [*FIRST*], [*FOLLOW*],
      ..vars.map(v => {
        let fi = first.at(v, default: ()).map(s =>
          if s == "\\epsilon" { strong($epsilon$) } else if s == "$" { strong([\$]) } else { strong($#s$) }
        ).join([, ])
        let fo = follow.at(v, default: ()).map(s =>
          if s == "$" { strong([\$]) } else { strong($#s$) }
        ).join([, ])
        ($#v$, fi, fo)
      }).flatten()
    )
  ]
}



#let show-canonical-items(grammar) = {
  let aug = augment-grammar(grammar)
  let C   = canonical-items(aug)
  let symbols = get-all-symbols(aug).filter(x => x != "\\epsilon")

  // Build origin map: state-index -> (parent-index, symbol)
  let origins = (:)
  for (i, state) in C.enumerate() {
    for sym in symbols {
      let next = goto(state, sym, aug)
      if next.len() > 0 {
        let j = C.position(x => x == next)
        if j != none and str(j) not in origins {
          origins.insert(str(j), (i, sym))
        }
      }
    }
  }

  block(width: 100%)[
    #grid(
      columns: (1fr, 1fr, 1fr, 1fr, 1fr),
      gutter: 10pt,
      ..C.enumerate().map(((i, state)) => {
        let origin-label = if str(i) in origins {
          let (par, sym) = origins.at(str(i))
          text(size: 10pt, fill: purple.darken(20%))[(I#sub[#par], #sym)]
        } else {
          text(size: 10pt, fill: purple.darken(20%))[#emph[inicial]]
        }
        block(
          stroke: 1pt + luma(100),
          inset: 8pt,
          width: 100%,
        )[
          #text(size: 14pt, weight: "bold", fill: purple.darken(20%))[I#sub[#i]]
          #h(4pt)
          #origin-label
          #stack(
            dir: ttb,
            spacing: 2pt,
            ..state.map(item => render-item(item))
          )
        ]
      })
    )
  ]
}



#let show-automaton(grammar, width: 100%) = {
  let aug      = augment-grammar(grammar)
  let C        = canonical-items(aug)
  let symbols  = get-all-symbols(aug).filter(x => x != "\\epsilon")

  let edges = ()
  for (i, state) in C.enumerate() {
    for sym in symbols {
      let next = goto(state, sym, aug)
      if next.len() > 0 {
        let j = C.position(x => x == next)
        if j != none {
          edges.push((i, j, sym))
        }
      }
    }
  }


  let edge-lines = edges.map(e => {
    let (a, b, sym) = e
    let lbl = dot-escape(if sym == "\\epsilon" { "ε" } else { sym })
    "  I" + str(a) + " -> I" + str(b) + " [label=\"" + lbl + "\"];"
  })

  let dot-src = (
    "digraph LR0 {\n"
    + "  rankdir=LR;\n"
    + "  node [margin=\"0.05,0.17\", fontsize=18, fontcolor=darkviolet];\n"
    + "  edge [fontsize=15];\n"
    + edge-lines.join("\n") + "\n"
    + "}"
  )

  block(width: 100%)[
    #raw-render(raw(dot-src, lang: "dot"), width: width)
  ]
}



#let show-parse-table(grammar) = {
  let aug       = augment-grammar(grammar)
  let C         = canonical-items(aug)
  let result    = build-tables(C, aug)
  let ACTION    = result.ACTION
  let GOTO      = result.GOTO
  let conflicts = result.conflicts

  let terminals = get-terminals(aug).filter(x => x != "\\epsilon") + ("$",)
  let variables = get-variables(aug).filter(x => x != aug.at(0).at(0))  // drop S'

  let n-cols = 1 + terminals.len() + variables.len()

  let render-cell(entry) = {
    if entry == none { return [] }
    let (kind, val) = entry
    if kind == action-type.SHIFT  { text(weight: "bold", fill: blue.darken(20%))[s#val] }
    else if kind == action-type.REDUCE { text(weight: "bold", fill: green.darken(20%))[r#val] }
    else if kind == action-type.ACCEPT { text(fill: purple, weight: "bold")[acc] }
    else { [] }
  }

  block(width: 100%)[
    #if conflicts.len() > 0 {
      block(
        fill: red.lighten(80%),
        stroke: 0.5pt + red,
        inset: 6pt,
        radius: 3pt,
      )[
        #text(fill: red.darken(20%), weight: "bold")[⚠ Conflicts (#conflicts.len())]
        #for c in conflicts [
          - State #c.state, symbol `#c.symbol`: existing #repr(c.existing) vs incoming #repr(c.incoming)
        ]
      ]
      v(6pt)
    }

    #table(
      columns: range(n-cols).map(_ => auto),
      inset: (x: 10pt, y: 6pt),
      fill: (col, row) => {
        if row == 0 or row == 1 { luma(220) }
        else if calc.odd(row) { luma(248) }
        else { white }
      },
      align: center,

      table.cell(colspan: 1)[],
      table.cell(colspan: terminals.len(), stroke: (bottom: 0.5pt + black))[*ACTION*],
      table.cell(colspan: variables.len(), stroke: (bottom: 0.5pt + black))[*GOTO*],

      [*STATE*],
      ..terminals.map(t =>
        text(font: "DejaVu Sans Mono", size: 8pt)[*#t*]
      ),
      ..variables.map(v => $bold(#v)$),

      // Data rows
      ..C.enumerate().map(((i, _)) => {
        let act-row = ACTION.at(i)
        let got-row = GOTO.at(i)
        (
          [*#i*],
          ..terminals.map(t  => render-cell(act-row.at(t,  default: none))),
          ..variables.map(v  => {
            let g = got-row.at(v, default: none)
            if g != none { [#g] } else { [] }
          }),
        )
      }).flatten()
    )
  ]
}



#let show-parse-trace(grammar, sentence) = {
  let aug    = augment-grammar(grammar)
  let C      = canonical-items(aug)
  let tables = build-tables(C, aug)
  let input  = sentence + ("$",)
  let result = parse-input(input, tables.ACTION, tables.GOTO, aug)

  let action-label(act) = {
    let (kind, val) = act
    if kind == action-type.SHIFT  { [shift #val] }
    else if kind == action-type.REDUCE {
      let rule = aug.at(val)
      let rhs-s = rule.at(1).map(s => if s == "\\epsilon" { $epsilon$ } else { $#s$ }).join($space$)
      [$"reduce" #rule.at(0) arrow.r #rhs-s$]
    }
    else if kind == action-type.ACCEPT { text(fill: purple, weight: "bold")[accept] }
    else { text(fill: red)[error] }
  }

  block(width: 100%)[
    #table(
      columns: (auto, auto, auto, auto),
      inset: (x: 7pt, y: 6pt),
      fill: (_, row) => if row == 0 { luma(220) } else if calc.odd(row) { luma(248) } else { white },
      [*Step*], [*Stack*], [*Entry*], [*Action*],
      ..result.log.map(entry => {
        let stk   = entry.stack.map(s => str(s)).join(" ")
        let inp   = entry.input.map(s => if s == "$" { [\$] } else { text(font: "DejaVu Sans Mono")[#s] }).join(h(3pt))
        (
          [#entry.step],
          text(font: "DejaVu Sans Mono", size: 8pt)[#stk],
          inp,
          action-label(entry.action),
        )
      }).flatten()
    )
  ]
}



#let _ast-to-dot(root) = {
  let nodes = ()   // (id, label, is-leaf)
  let edges = ()   // (parent-id, child-id)
  let queue = ((0, root),)
  let next-id = 1

  while queue.len() > 0 {
    let (my-id, node) = queue.remove(0)
    let is-leaf = node.children.len() == 0
    nodes.push((my-id, node.label, is-leaf))

    for child in node.children {
      edges.push((my-id, next-id))
      queue.push((next-id, child))
      next-id = next-id + 1
    }
  }

  let node-lines = nodes.map(n => {
    let (id, lbl-raw, leaf) = n
    let lbl   = dot-escape(if lbl-raw == "\\epsilon" { "ε" } else { lbl-raw })
    let shape = if leaf { "ellipse" } else { "rectangle" }
    let fill  = if leaf { "#d6eaf8" } else { "#d5f5e3" }
    let line  = "  n" + str(id) + " [label=\"" + lbl + "\", shape=" + shape + ", style=filled, fillcolor=\"" + fill + "\", fontname=\"Courier\", fontsize=10];"
    line
  })

  let edge-lines = edges.map(e => {
    "  n" + str(e.at(0)) + " -> n" + str(e.at(1)) + ";"
  })

  (
    "digraph ParseTree {\n"
    + "  rankdir=TB;\n"
    + node-lines.join("\n") + "\n"
    + edge-lines.join("\n") + "\n"
    + "}"
  )
}

#let show-parse-tree(grammar, sentence) = {
  let aug    = augment-grammar(grammar)
  let C      = canonical-items(aug)
  let tables = build-tables(C, aug)
  let input  = sentence + ("$",)
  let result = parse-input(input, tables.ACTION, tables.GOTO, aug)

  block(width: 100%)[
    #if result.ast == none {
      text(fill: red)[No parse tree — input was rejected.]
    } else {
      let dot-src = _ast-to-dot(result.ast)
      raw-render(raw(dot-src, lang: "dot"))
    }
  ]
}
