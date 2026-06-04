#import "util.typ"
#import "match.typ"

#let render(it, grammar) = {
  if it.head == "content" {
    let (fn, ..pos) = it.args
    return fn(..pos, ..it.slots)
  }
  
  let op = grammar.at(it.head)

  if type(op) == function {
    return op(..it.args, ..it.slots)
  }

  let (kind, pattern) = op.pairs().first()
  let op = if "slots" in it {
    match.substitute-slots(pattern, it.slots)
  } else { pattern }

  let args = it.args
  
  if kind == "infix" {
    $args.join(op)$
  } else if kind == "postfix" {
    $args.first() op$
  } else if kind == "prefix" {
    $op args.first()$
  } else if kind == "match" {
    op
  } else {
    panic(op)
  }
}


#let render-spans(tree, grammar) = {
  tree = util.node-depths(tree)
  let max-depth = if type(tree) == dictionary {
    tree.at("depth", default: 0)
  } else { 0 }
  let gap = 3pt
  let out = util.walk(tree, post: it => {
    let color = color.hsl(150deg + 35deg*it.depth, 90%, 45%)
    box(
      render(it, grammar),
      inset: (x: 2pt),
      outset: (x: -1pt, top: gap*it.depth),
      radius: (top: 3pt),
      stroke: (rest: 0.5pt + color, top: 1.5pt + color, bottom: none),
    )
  },
  leaf: it => {
    box(
      $it$,
      inset: (x: 1pt),
      outset: (x: -1pt),
      stroke: (bottom: 1pt + yellow.transparentize(35%)),
    )
  })
  pad(out, top: gap*max-depth)
}