// SPDX-FileCopyrightText: 2023 Jade Lovelace
// SPDX-FileCopyrightText: 2025 Pascal Quach
// SPDX-FileCopyrightText: 2025 Typst Community
// SPDX-FileCopyrightText: 2025 Contributors to the typst-algorithmic project
// SPDX-License-Identifier: MIT

/*
 * Generated AST:
 * (change-indent: int, body: ((ast | content)[] | content | ast)
 */

#let ast-to-content-list(indent, ast) = {
  if type(ast) == array {
    // array of (ast | content)
    ast.map(d => ast-to-content-list(indent, d))
  } else if type(ast) == content {
    // (line-content: ast, line-indent: int)
    (line-content: ast, line-indent: indent)
  } else if type(ast) == dictionary {
    // (change-indent: int, body: ((ast | content)[] | content | ast))
    let new-indent = ast.at("change-indent", default: 0) + indent
    ast-to-content-list(new-indent, ast.body)
  }
}

#let style-algorithm(
  body,
  caption-style: strong,
  caption-align: start,
  breakable: true,
  hlines: (grid.hline(), grid.hline(), grid.hline()),
  placement: none,
  scope: "column",
) = {
  show figure.where(kind: "algorithm"): it => {
    set block(breakable: breakable)
    let algo = grid(
      columns: 1,
      stroke: none,
      inset: 0% + 5pt,
      hlines.at(0),
      caption-style(align(caption-align, it.caption)),
      hlines.at(1),
      align(start, it.body),
      hlines.at(2),
    )
    let _placement = placement
    let _scope = scope
    if it.placement != none { _placement = it.placement }
    if it.scope != "column" { _scope = it.scope }
    if _placement != none {
      place(_placement, scope: _scope, float: true, algo)
    } else {
      algo
    }
  }
  body
}

#let algorithm(
  inset: 0.2em,
  indent: 0.5em,
  vstroke: 0pt + luma(200),
  line-numbers: true,
  ..bits,
) = {
  let content = bits.pos().map(b => ast-to-content-list(0, b)).flatten()
  if content.len() == 0 or content == (none,) {
    return none
  }
  let grid-bits = ()
  let line-number = 1

  let indent-list = content.map(c => c.line-indent)
  let max-indent = indent-list.sorted().last()
  let colspans = indent-list.map(i => max-indent + 1 - i)
  let indent-content = indent-list.map(i => ([], grid.vline(stroke: vstroke), []) * int(i / 2))
  let indents = (indent,) * max-indent
  let offset = 18pt + if indents.len() != 0 { indents.sum() }
  let columns = (..indents, 100% - offset)
  if line-numbers {
    columns.insert(0, 18pt)
  }

  while line-number <= content.len() {
    if line-numbers { grid-bits.push([#line-number:]) }
    grid-bits = grid-bits + indent-content.at(line-number - 1)
    grid-bits.push(grid.cell(content.at(line-number - 1).line-content, colspan: colspans.at(line-number - 1)))
    line-number = line-number + 1
  }
  return grid(
    columns: columns,
    // line spacing
    inset: inset,
    stroke: none,
    ..grid-bits
  )
}

#let algorithm-figure(
  title,
  supplement: "Algorithm",
  inset: 0.2em,
  indent: 0.5em,
  vstroke: 0pt + luma(200),
  line-numbers: true,
  ..bits,
) = {
  return figure(supplement: supplement, kind: "algorithm", caption: title, algorithm(
    indent: indent,
    inset: inset,
    vstroke: vstroke,
    line-numbers: line-numbers,
    ..bits,
  ))
}

#let iflike-unterminated(kw1: "", kw2: "", cond, ..body) = (
  (strong(kw1) + " " + cond + " " + strong(kw2)),
  (change-indent: 2, body: body.pos()),
)
#let iflike-terminated(kw1: "", kw2: "", kw3: "", cond, ..body) = (
  (strong(kw1) + " " + cond + " " + strong(kw2)),
  (change-indent: 2, body: body.pos()),
  strong(kw3),
)
#let iflike(kw1: "", kw2: "", kw3: none, cond, ..body) = (
  if kw3 == "" or kw3 == none {
    iflike-unterminated(kw1: kw1, kw2: kw2, cond, ..body)
  } else {
    iflike-terminated(kw1: kw1, kw2: kw2, kw3: kw3, cond, ..body)
  }
)
#let arraify(v) = {
  if type(v) == array {
    v
  } else {
    (v,)
  }
}
#let call(name, kw: "function", inline: false, style: smallcaps, args, ..body) = (
  if inline {
    [#style(name)\(#arraify(args).join(", ")\)]
  } else {
    iflike(kw1: kw, kw3: "end", (style(name) + $(#arraify(args).join(", "))$), ..body)
  }
)

// Named blocks
#let Function = call.with(kw: "function")
#let Procedure = call.with(kw: "procedure")

// Misc
#let Line(block) = (block,)
#let LineBreak = Line[]

/// Inline call
#let CallInline(name, args) = call(inline: true, name, args)
#let FnInline(f, args) = call(inline: true, style: strong, f, args)
#let CommentInline(c) = sym.triangle.stroked.r + " " + c

// Block calls
#let Call(..args) = (CallInline(..args),)
#let Fn(..args) = (FnInline(..args),)
#let Comment(c) = (CommentInline(c),)
#let LineComment(l, c) = ([#l.first()#h(1fr)#CommentInline(c)], ..l.slice(1))

// Control flow
#let If = iflike.with(kw1: "if", kw2: "then", kw3: "end")
#let While = iflike.with(kw1: "while", kw2: "do", kw3: "end")
#let For = iflike.with(kw1: "for", kw2: "do", kw3: "end")
#let Else = iflike.with(kw1: "else", kw2: "", kw3: "end", "")
#let ElseIf = iflike.with(kw1: "else if", kw2: "then", kw3: "end")
#let IfElseChain(..conditions-and-bodies) = {
  let result = ()
  let conditions-and-bodies = conditions-and-bodies.pos()
  let len = conditions-and-bodies.len()
  let i = 0

  while i < len {
    if i == len - 1 and calc.odd(len) {
      // Last element is the "else" block
      result.push(Else(..arraify(conditions-and-bodies.at(i))))
    } else if calc.even(i) {
      // Condition
      let cond = conditions-and-bodies.at(i)
      let body = arraify(conditions-and-bodies.at(i + 1))
      if i == 0 {
        // First condition is a regular "if"
        result.push(If(cond, ..body, kw3: ""))
      } else if i + 2 == len {
        // Last condition before "else" is an "elseif" with "end"
        result.push(ElseIf(cond, ..body, kw3: "end"))
      } else {
        // Intermediate conditions are "elseif" without "end"
        result.push(ElseIf(cond, ..body, kw3: ""))
      }
    } else {
      // Skip body since it's already processed
    }
    i = i + 1
  }
  result
}

// Instructions
#let Assign(var, val) = (var + " " + $<-$ + " " + arraify(val).join(", "),)
#let Return(arg) = (strong("return") + " " + arraify(arg).join(", "),)
#let Terminate = (smallcaps("terminate"),)
#let Break = (smallcaps("break"),)
