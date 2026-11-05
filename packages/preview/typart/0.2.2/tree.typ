// Tree: multi-level hierarchy.  Import with:  #import "tree.typ": tree
//
//   #tree(([CEO], (([Eng], ([Web], [Mobile])), [Sales])))
//   #tree((([CEO], blue), ((([Eng], green), (([Web], orange), ([Mobile], red))), [Sales])))
//   #tree(([CEO], (([Eng], ([Web], [Mobile])), [Sales])), dir: ltr)   // root on the left
#import "common.typ": _txt, _u

#let _tlab(nd) = {
  if type(nd) != array { return nd }
  let first = nd.at(0)
  if type(first) == array { return first.at(0) }
  first
}
#let _tcol(nd) = {
  if type(nd) != array { return none }
  let first = nd.at(0)
  if type(first) == array and first.len() >= 2 and type(first.at(1)) == color { return first.at(1) }
  if nd.len() >= 2 and type(nd.at(1)) == color { return nd.at(1) }
  none
}
#let _tkids(nd) = {
  if type(nd) != array { return () }
  let second = nd.at(1, default: ())
  if type(second) == color { return () }
  second
}
// Lays the subtree out across the levels from `start`: siblings follow each other `gap`
// apart and a parent is centred on its first and last child, shifting the subtree when
// the parent's own box would begin before `start`.  size(label) -> (height, cross size).
#let _tlayout(nd, depth, start, gap, size) = {
  let (h, cross) = size(_tlab(nd))
  let me = (depth: depth, label: _tlab(nd), color: _tcol(nd), h: h)
  let kids = _tkids(nd)
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
  box-w: 4, box-h: 1.5, xstep: auto, ystep: auto,
  root-fill: rgb("#aab4f7"), box-fill: rgb("#a7dd9b"),
  text-fill: rgb("#1f1f3a"), accent: rgb("#73c25a"), size: 15pt,
  filled: true,
  outline: 2.5pt,
  pad: 0.3,  // vertical padding (cm) added around wrapped text; box-h is the minimum height
) = context {
  let across = dir.axis() == "horizontal"
  let xstep = if xstep == auto { if across { 5.6 } else { 4.6 } } else { xstep }
  let ystep = if ystep == auto { if across { 1.9 } else { 2.8 } } else { ystep }
  let (box-w, box-h, xstep, ystep, pad) = (_u(box-w), _u(box-h), _u(xstep), _u(ystep), _u(pad))
  let label(body) = box(width: box-w - 0.4cm, align(center, _txt(body, text-fill, size, weight: auto)))
  // Box height follows the wrapped text (box-h is the minimum).
  let size(body) = {
    let h = calc.max(box-h, measure(label(body)).height + 2 * pad)
    (h, if across { h } else { box-w })
  }
  let (gap-x, gap-y) = (xstep - box-w, ystep - box-h)
  let (nodes, cross-len) = _tlayout(root, 0, 0pt, if across { gap-y } else { gap-x }, size)
  // Levels run along the main axis, each one as deep as its largest box, so multi-line
  // boxes never overlap the previous level.
  let half(nd) = if across { box-w / 2 } else { nd.h / 2 }
  let maxdepth = calc.max(..nodes.map(nd => nd.depth))
  let maxhalf = range(maxdepth + 1).map(d => calc.max(..nodes.filter(nd => nd.depth == d).map(half)))
  let level = (maxhalf.at(0),)
  for d in range(1, maxdepth + 1) {
    level.push(level.at(d - 1) + maxhalf.at(d - 1) + (if across { gap-x } else { gap-y }) + maxhalf.at(d))
  }
  let main-len = level.last() + maxhalf.last()
  let pt(cross, main) = {
    let main = if dir == rtl or dir == btt { main-len - main } else { main }
    if across { (main, cross) } else { (cross, main) }
  }
  box(width: if across { main-len } else { cross-len }, height: if across { cross-len } else { main-len }, {
    for nd in nodes.filter(nd => nd.kids.len() > 0) {
      let from = level.at(nd.depth) + half(nd)
      let to = level.at(nd.depth + 1)
      // one shared bar per parent, before the largest child's near edge
      let bar = (from + to - calc.max(..nd.kids.map(half))) / 2
      for kid in nd.kids {
        place(top + left, curve(stroke: (paint: accent, thickness: 2.5pt, join: "round"),
          curve.move(pt(nd.pos, from)), curve.line(pt(nd.pos, bar)), curve.line(pt(kid.pos, bar)),
          curve.line(pt(kid.pos, to - half(kid)))))
      }
    }
    for nd in nodes {
      let col = if nd.color != none { nd.color } else if nd.depth == 0 { root-fill } else { box-fill }
      let (x, y) = pt(nd.pos, level.at(nd.depth))
      place(top + left, dx: x - box-w / 2, dy: y - nd.h / 2,
        box(width: box-w, height: nd.h, radius: 0.15cm,
          fill: if filled { col }, stroke: if not filled { outline + col },
          align(center + horizon, label(nd.label))))
    }
  })
}
