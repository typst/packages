// Tree: multi-level hierarchy.  Import with:  #import "tree.typ": tree
//
//   #tree(([CEO], (([Eng], ([Web], [Mobile])), [Sales])))
//   #tree((([CEO], blue), ((([Eng], green), (([Web], orange), ([Mobile], red))), [Sales])))
//   #tree(([CEO], (([Eng], ([Web], [Mobile])), [Sales])), dir: ltr)   // root on the left
#import "common.typ": _canvas, _card, _lens, _marked, _on, _or, _pair, _theme, _txt

// A node as (label, colour or none, children).  A node is written as a label, a tuple, a
// dictionary (label, children, color) or an item of a nested bullet list.
#let _tnode(nd) = {
  let fail() = assert(false, message: "tree: a node is label, (label, children), (label, color), "
    + "((label, color), children) or (label: .., children: .., color: ..), got " + repr(nd))
  if type(nd) == content and nd.func() == list.item {
    let parts = if nd.body.has("children") { nd.body.children } else { (nd.body,) }
    let (label, color) = _marked(parts.filter(part => part.func() != list.item).join())
    return (label, color, parts.filter(part => part.func() == list.item))
  }
  if type(nd) == dictionary {
    if "label" not in nd or nd.keys().any(key => key not in ("label", "children", "color")) { fail() }
    return (nd.label, nd.at("color", default: none), nd.at("children", default: ()))
  }
  if type(nd) != array { return (nd, none, ()) }
  if nd.len() not in (1, 2) { fail() }
  let (head, tail) = (nd.first(), nd.at(1, default: ()))
  if type(tail) == color and type(head) != array { return (head, tail, ()) }
  if type(tail) != array { fail() }
  if type(head) != array { return (head, none, tail) }
  if head.len() != 2 or type(head.at(1)) != color { fail() }
  (head.at(0), head.at(1), tail)
}
// Lays the subtree out across the levels from `start`: siblings follow each other `gap`
// apart and a parent is centred on its first and last child, shifting the subtree when
// the parent's own box would begin before `start`.  size(label) -> (height, cross size).
#let _tlayout(nd, depth, start, gap, size) = {
  let (label, color, kids) = _tnode(nd)
  let (h, cross) = size(label)
  let me = (depth: depth, label: label, color: color, h: h)
  if kids.len() == 0 { return ((me + (pos: start + cross / 2, kids: ()),), start + cross) }
  let (acc, roots, end) = ((), (), start - gap)
  for k in kids {
    let (sub, next) = _tlayout(k, depth + 1, end + gap, gap, size)
    roots.push(sub.first())
    acc += sub
    end = next
  }
  let pos = (roots.first().pos + roots.last().pos) / 2
  let shift = calc.max(0pt, start - (pos - cross / 2))
  let moved = n => n + (pos: n.pos + shift)
  (
    (me + (pos: pos + shift, kids: roots.map(moved)),) + acc.map(n => moved(n) + (kids: n.kids.map(moved))),
    calc.max(end, pos + cross / 2) + shift,
  )
}

#let tree(
  root,
  dir: ttb,
  item-width: 6.5em,
  item-height: 2.5em,
  gap: auto,
  filled: true,
  fills: auto,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("tree", theme, style)
  // a nested bullet list is a tree when it has one top item
  let tops = if type(root) == content and root.has("children") { root.children.filter(c => c.func() == list.item) } else { () }
  if not (tops.len() <= 1) { assert(false, message: "tree: the list needs one root item, got " + str(tops.len())) }
  let root = tops.at(0, default: root)
  // one colour per level; the last one serves every deeper level
  let fills = _or(fills, (t.palette.at(0), t.palette.at(1)))
  if not (type(fills) == array and fills.len() > 0 and fills.all(c => type(c) == color)) { assert(false, message: "tree: `fills` is auto "
    + "or an array of colours, one per level, got " + repr(fills)) }
  if not (dir in (ttb, ltr, rtl, btt)) { assert(false, message: "tree: `dir` must be ttb, btt, ltr or rtl, got " + repr(dir)) }
  let across = dir.axis() == "horizontal"
  let (w, min-h, size, em) = _lens("tree", item-width: item-width, item-height: item-height, text-size: text-size,
    em: 1em).values()
  // the space between siblings and between levels; sideways trees stack tighter and reach further
  let (sibling, between) = if gap != auto { _pair("tree", "gap", gap) } else if across { (0.7 * em, 2.7 * em) } else {
    (em, 2.2 * em)
  }
  let label(body, fill) = box(width: w - 0.7 * em, align(center, _txt(body, fill, size, weight: auto)))
  // Box height follows the wrapped text (item-height is the minimum).
  let extent(body) = {
    let h = calc.max(min-h, measure(label(body, t.ink)).height + em)
    (h, if across { h } else { w })
  }
  let (nodes, cross-len) = _tlayout(root, 0, 0pt, sibling, extent)
  // Levels run along the main axis, each one as deep as its largest box, so multi-line
  // boxes never overlap the previous level.
  let half(nd) = if across { w / 2 } else { nd.h / 2 }
  let maxdepth = calc.max(..nodes.map(nd => nd.depth))
  let maxhalf = range(maxdepth + 1).map(d => calc.max(..nodes.filter(nd => nd.depth == d).map(half)))
  let level = (maxhalf.at(0),)
  for d in range(1, maxdepth + 1) { level.push(level.at(d - 1) + maxhalf.at(d - 1) + between + maxhalf.at(d)) }
  let main-len = level.last() + maxhalf.last()
  let pt(cross, main) = {
    let main = if dir == rtl or dir == btt { main-len - main } else { main }
    if across { (main, cross) } else { (cross, main) }
  }
  _canvas("tree", t, width, area, if across { main-len } else { cross-len }, if across { cross-len } else { main-len }, {
    for nd in nodes.filter(nd => nd.kids.len() > 0) {
      let from = level.at(nd.depth) + half(nd)
      let to = level.at(nd.depth + 1)
      // one shared bar per parent, before the largest child's near edge
      let bar = (from + to - calc.max(..nd.kids.map(half))) / 2
      for kid in nd.kids {
        place(top + left, curve(stroke: (paint: t.accent, thickness: t.thick, join: "round"),
          curve.move(pt(nd.pos, from)), curve.line(pt(nd.pos, bar)), curve.line(pt(kid.pos, bar)),
          curve.line(pt(kid.pos, to - half(kid)))))
      }
    }
    for nd in nodes {
      let col = if nd.color != none { nd.color } else { fills.at(calc.min(nd.depth, fills.len() - 1)) }
      let (x, y) = pt(nd.pos, level.at(nd.depth))
      place(top + left, dx: x - w / 2, dy: y - nd.h / 2,
        _card(t, width: w, height: nd.h, radius: t.corner-radius,
          fill: if filled { col }, stroke: if not filled { t.thick + col },
          align(center + horizon, label(nd.label, if filled { _on(t, col) } else { t.ink }))))
    }
  })
})
