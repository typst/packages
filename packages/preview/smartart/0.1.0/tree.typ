// Tree: multi-level hierarchy.  Import with:  #import "tree.typ": tree
//
//   #tree(([CEO], (([Eng], ([Web], [Mobile])), [Sales])))
//   #tree((([CEO], blue), ((([Eng], green), (([Web], orange), ([Mobile], red))), [Sales])))
#import "@preview/cetz:0.3.4": canvas, draw

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
) = canvas({
  import draw: *
  let nodes = _tlayout(root, 0, 0).at(0)
  for nd in nodes {
    let px = nd.x * xstep
    let py = -nd.depth * ystep
    for kx in nd.kids {
      let cxp = kx * xstep
      let cyp = -(nd.depth + 1) * ystep
      let midy = (py - box-h / 2 + cyp + box-h / 2) / 2
      line((px, py - box-h / 2), (px, midy), (cxp, midy), (cxp, cyp + box-h / 2),
        stroke: (paint: accent, thickness: 2.5pt, join: "round"))
    }
  }
  for nd in nodes {
    let px = nd.x * xstep
    let py = -nd.depth * ystep
    let col = if nd.color != none { nd.color } else { if nd.depth == 0 { root-fill } else { box-fill } }
    rect((px - box-w / 2, py - box-h / 2), (px + box-w / 2, py + box-h / 2),
      fill: if filled { col } else { none },
      stroke: if filled { none } else { outline + col },
      radius: 0.15)
    content((px, py), box(width: (box-w - 0.4) * 1cm,
      align(center + horizon, text(fill: text-fill, size: size, [
        #set par(justify: false)
        #nd.label
      ]))))
  }
})
