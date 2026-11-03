#import "util.typ"
#import "match.typ"

#let node(it, grammar) = {
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


#let spans(tree, grammar) = {
  tree = util.node-depths(tree)
  let max-depth = if type(tree) == dictionary {
    tree.at("depth", default: 0)
  } else { 0 }
  let gap = 3pt
  let out = util.walk(tree, post: it => {
    let color = color.hsl(150deg + 35deg*it.depth, 90%, 45%)
    box(
      node(it, grammar),
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

/// Render a tree given in the format described in @trees.
/// 
/// This is meant to be useful for debugging; for more control, consider using the `cetz.tree` submodule of #link("https://cetz-package.github.io/")[CeTZ].
/// 
/// ```example
/// let tree = (
///   head: "parent",
///   args: ($chi^2$, (head: "child", args: (42, 7), slots: (:))),
///   slots: (slotty: range(3)),
/// )
/// parsely.render.tree(tree)
/// h(1fr)
/// parsely.render.tree(tree, grow: 5em, inset: 4pt,
///   head-style: it => pad(y: -6pt, circle(radius: 2pt, fill: gray)),
///   slot-style: it => text(0.9em, gray)[#it:],
///   edge: line(start: (0%, 0%), end: (100%, 100%), stroke: gray))
/// h(1fr)
/// parsely.render.tree(tree, spread: 3em,
///   head-style: it => text(green, emph[( #it )]),
///   edge: curve(curve.quad((80%, 0%), (100%, 100%)), stroke: 2pt + green))
/// ```
#let tree(
  tree,
  /// Height between generations
  grow: 2.5em,
  /// Distance between siblings
  spread: 1em,
  /// Gap between nodes and edges
  inset: 0.5em,
  /// Style for node names
  head-style: it => strong(raw(it)),
  /// Style for slot labels
  slot-style: it => text(0.8em, raw(it)),
  /// Curve to draw between nodes.
  /// This gets placed in the tree so that the start point is `(0%, 0%)` and end is `(100%, 100%)`.
  /// For example:
  /// ```
  /// line(start: (0%, 0%), end: (100%, 100%), stroke: blue)    // straight
  /// curve(curve.cubic((50%, 50%), (100%, 60%), (100%, 100%))) // brace
  /// curve(curve.quad((100%, 0%), (100%, 100%)), stroke: 2pt)  // arc
  /// ```
  edge: curve(curve.cubic((50%, 50%), (100%, 60%), (100%, 100%))),
) = context {
  set line(stroke: (cap: "round"))
  set curve(stroke: (cap: "round"))

  // this tree walk is a little complex:
  // at each node, return a tuple `(it, meta)` where `it`
  // is the rendered content and `meta` is data that can be
  // passed from children to parents to do with alignment.
  // to horizontally align node heads to be more optically pleasing
  // we need children to tell parents where their heads end up,
  // so `meta` stores the x-coordinate of the center of each node's head
  let (it, meta) = util.walk(tree,
    leaf: it => {
      let it = {
        if it == none { raw("none", lang: "typc") }
        else { it }
      }
      it = pad(y: inset)[#it]
      (it, measure(it).width/2)
    },

    post: ((head, args, slots)) => {
      let meta = {
        args.map(array.last)
        slots.values().map(array.last)
      }
      let children = {
        args.map(array.first)
        slots.values().map(array.first)
      }

      let head = pad(y: inset, head-style(head))
      let (height: h-height, width: h-width) = measure(head)

      if children.len() == 0 { return (head, measure(head).width/2) }

      let edge-labels = {
        (none,)*args.len()
        slots.keys().map(k => box(inset: (top: inset), slot-style(k)))
      }

      let widths = children.zip(edge-labels).map(((c, e)) => {
        calc.max(measure(c).width, measure(e).width)
      })
      let meta = meta.zip(widths).map(((m, w)) => calc.max(m, w/2))

      let total-width = (widths.sum() + (children.len() - 1)*spread).to-absolute()


      let x-children = ()
      let x = 0pt
      for (w, m) in widths.zip(meta) {
        x-children.push((x + m).to-absolute())
        x += w + spread
      }

      // place the head at the average of the children's heads
      // so horizontal placement is visually balanced
      let x-root = (calc.min(..x-children) + calc.max(..x-children))/2

      let result = {
        show: box.with(width: calc.max(total-width, h-width))
        set align(center)
        show: box.with(width: total-width)

        grid(
          columns: widths,
          row-gutter: (grow, 0pt),
          column-gutter: spread,
          align: center + top,
          grid.cell(colspan: children.len(), align: left, {
            move(dx: x-root - h-width/2, head)
          }),
          ..children,
        )

        for (x, label) in x-children.zip(edge-labels) {
          let y = h-height + grow + - measure(label).height

          place(top + left, dx: x-root, dy: h-height, {
            box(width: x - x-root, height: y - h-height, edge)
          })

          place(top, dx: x, dy: y, {
            show: move.with(dx: -measure(label).width/2)
            label
          })
        }
      }

      let meta = calc.max(
        x-root.to-absolute(),
        h-width/2,
      )

      return (result, meta)

    }
  )

  it
}

/// Visualise a tree as a sequence of nodes enclosed by over- or under-braces. 
/// 
/// ```example
/// let tree = parsely.util.content-to-tree(circle(stroke: 5pt)[Hello *World*])
/// parsely.render.waterfall(tree)
/// ```
/// 
/// ```example
/// let tree = parsely.parse($sqrt(1 + x^2/n)$, parsely.common.arithmetic).tree
/// let c = parsely.util.random-color.with(lightness: (30%, 30%), chroma: 30%)
/// parsely.render.waterfall(tree, side: bottom, head-color: c)
/// ```
#let waterfall(
  tree,
  /// Padding inside nodes
  inset: 0.25em,
  /// Vertical padding; higher makes a taller diagram
  grow: 0.5em,
  /// Corner radius
  radius: 0.5em,
  /// Function taking the node's head and returning a color.
  head-color: util.random-color,
  /// Style for node names
  head-style: it => strong(raw(it)),
  /// Style for slot labels
  slot-style: it => text(0.8em, raw(it)),
  /// Show braces on this side of nodes
  side: top,
) = util.walk(tree, post: ((head, args, slots)) => {
  let c = head-color(head)

  slots = slots.pairs().map(((k, v)) => stack(
    dir: direction.from(side),
    spacing: 0.4em,
    text(c, slot-style(k)),
    [#v],
  ))
  let children = args + slots

  set box(stroke: (paint: c, cap: "square"))
  set grid.vline(stroke: c)
  show: box.with(
    stroke: (rest: 1pt, repr(side): 1.75pt, repr(side.inv()): none),
    radius: (repr(side): radius),
  )
  grid(
    align: side.inv(),
    gutter: 0pt,
    inset: (x: inset, repr(side): grow),
    columns: 1 + children.len(),
    text(c, head-style(head)),
    ..children.map(it => [#it]),
    ..range(children.len()).map(x => {
      grid.vline(x: x + 1)
    }),
  )
})
