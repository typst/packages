// Tree: multi-level hierarchy.  Import with:  #import "tree.typ": tree
//
//   #tree(([CEO], (([Eng], ([Web], [Mobile])), [Sales])))
//   #tree((([CEO], blue), ((([Eng], green), (([Web], orange), ([Mobile], red))), [Sales])))
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
#let _tlayout(nd, depth, x0) = {
  let kids = _tkids(nd)
  if kids.len() == 0 {
    (((x: x0, depth: depth, label: _tlab(nd), kids: (), color: _tcol(nd)),), x0 + 1)
  } else {
    let acc = ()
    let cx = x0
    let roots = ()
    for k in kids {
      let res = _tlayout(k, depth + 1, cx)
      cx = res.at(1)
      roots.push(res.at(0).first().x)
      acc += res.at(0)
    }
    (((x: (roots.first() + roots.last()) / 2, depth: depth, label: _tlab(nd), kids: roots, color: _tcol(nd)),) + acc, cx)
  }
}
#let tree(
  root,
  box-w: 4, box-h: 1.5, xstep: 4.6, ystep: 2.8,
  root-fill: rgb("#aab4f7"), box-fill: rgb("#a7dd9b"),
  text-fill: rgb("#1f1f3a"), accent: rgb("#73c25a"), size: 15pt,
  filled: true,
  outline: 2.5pt,
  pad: 0.3,  // vertical padding (cm) added around wrapped text; box-h is the minimum height
) = context {
  let (box-w, box-h, xstep, ystep, pad) = (_u(box-w), _u(box-h), _u(xstep), _u(ystep), _u(pad))
  let nodes = _tlayout(root, 0, 0).at(0)
  let label(nd) = box(width: box-w - 0.4cm, align(center, _txt(nd.label, text-fill, size, weight: auto)))
  // Box height follows the wrapped text (box-h is the minimum).  half: "depth_x" -> half-height.
  let half = (:)
  for nd in nodes {
    half.insert(str(nd.depth) + "_" + str(nd.x), calc.max(box-h, measure(label(nd)).height + 2 * pad) / 2)
  }
  let hh(depth, x) = half.at(str(depth) + "_" + str(x))
  // Row centres from the tallest box per level so multi-line boxes never overlap the
  // row above; vgap keeps constant-height trees identical to a fixed ystep.
  let vgap = ystep - box-h
  let maxdepth = calc.max(..nodes.map(nd => nd.depth))
  let maxhalf = range(maxdepth + 1).map(d => calc.max(..nodes.filter(nd => nd.depth == d).map(nd => hh(d, nd.x))))
  let row-y = (maxhalf.at(0),)
  for d in range(1, maxdepth + 1) {
    row-y.push(row-y.at(d - 1) + maxhalf.at(d - 1) + vgap + maxhalf.at(d))
  }
  let px = x => x * xstep + box-w / 2
  box(width: px(calc.max(..nodes.map(nd => nd.x))) + box-w / 2, height: row-y.last() + maxhalf.last(), {
    for nd in nodes.filter(nd => nd.kids.len() > 0) {
      let parent-y = row-y.at(nd.depth) + hh(nd.depth, nd.x)
      let child-y = row-y.at(nd.depth + 1)
      // one shared bar per parent, above the tallest child's top edge
      let bar-y = (parent-y + child-y - calc.max(..nd.kids.map(kx => hh(nd.depth + 1, kx)))) / 2
      for kx in nd.kids {
        place(top + left, curve(stroke: (paint: accent, thickness: 2.5pt, join: "round"),
          curve.move((px(nd.x), parent-y)), curve.line((px(nd.x), bar-y)), curve.line((px(kx), bar-y)),
          curve.line((px(kx), child-y - hh(nd.depth + 1, kx)))))
      }
    }
    for nd in nodes {
      let col = if nd.color != none { nd.color } else if nd.depth == 0 { root-fill } else { box-fill }
      let h = 2 * hh(nd.depth, nd.x)
      place(top + left, dx: px(nd.x) - box-w / 2, dy: row-y.at(nd.depth) - h / 2,
        box(width: box-w, height: h, radius: 0.15cm,
          fill: if filled { col }, stroke: if not filled { outline + col },
          align(center + horizon, label(nd))))
    }
  })
}
