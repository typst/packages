// Tree: multi-level hierarchy.  Import with:  #import "tree.typ": tree
//
//   #tree(([CEO], (([Eng], ([Web], [Mobile])), [Sales])))
//   #tree((([CEO], blue), ((([Eng], green), (([Web], orange), ([Mobile], red))), [Sales])))
#import "@preview/cetz:0.5.2": canvas, draw

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
  let nodes = _tlayout(root, 0, 0).at(0)
  let contentw = (box-w - 0.4) * 1cm
  // Measure each label at the fixed content width so the box height follows the
  // wrapped text instead of clipping it.  hmap: "depth_x" -> half-height (cm).
  let half = ()
  let hmap = (:)
  for nd in nodes {
    let body = box(width: contentw, align(center, text(fill: text-fill, size: size, [
      #set par(justify: false)
      #nd.label
    ])))
    let mh = measure(body).height / 1cm
    let h = calc.max(box-h, mh + 2 * pad)
    half.push(h / 2)
    hmap.insert(str(nd.depth) + "_" + str(nd.x), h / 2)
  }
  // Row y-positions from actual box heights so tall (multi-line) boxes never
  // overlap the row above.  vgap = vertical space between box edges (elbow room);
  // its default keeps constant-height trees identical to the old fixed ystep.
  let vgap = ystep - box-h
  let maxdepth = calc.max(..nodes.map(n => n.depth))
  let maxhalf = range(maxdepth + 1).map(d => calc.max(
    ..nodes.enumerate().filter(((i, n)) => n.depth == d).map(((i, n)) => half.at(i))))
  let row-y = (0,)
  for d in range(1, maxdepth + 1) {
    row-y.push(row-y.at(d - 1) - (maxhalf.at(d - 1) + vgap + maxhalf.at(d)))
  }
  canvas({
    import draw: *
    for nd in nodes {
      if nd.kids.len() == 0 { continue }
      let px = nd.x * xstep
      let py = row-y.at(nd.depth)
      let ph = hmap.at(str(nd.depth) + "_" + str(nd.x))
      let cyp = row-y.at(nd.depth + 1)
      // one shared horizontal bar per parent, placed above the tallest child's
      // top edge so all elbows line up regardless of differing box heights
      let max-ch = calc.max(..nd.kids.map(kx => hmap.at(str(nd.depth + 1) + "_" + str(kx))))
      let bar-y = ((py - ph) + (cyp + max-ch)) / 2
      for kx in nd.kids {
        let cxp = kx * xstep
        let ch = hmap.at(str(nd.depth + 1) + "_" + str(kx))
        line((px, py - ph), (px, bar-y), (cxp, bar-y), (cxp, cyp + ch),
          stroke: (paint: accent, thickness: 2.5pt, join: "round"))
      }
    }
    for (i, nd) in nodes.enumerate() {
      let px = nd.x * xstep
      let py = row-y.at(nd.depth)
      let hh = half.at(i)
      let col = if nd.color != none { nd.color } else { if nd.depth == 0 { root-fill } else { box-fill } }
      rect((px - box-w / 2, py - hh), (px + box-w / 2, py + hh),
        fill: if filled { col } else { none },
        stroke: if filled { none } else { outline + col },
        radius: 0.15)
      content((px, py), box(width: contentw,
        align(center + horizon, text(fill: text-fill, size: size, [
          #set par(justify: false)
          #nd.label
        ]))))
    }
  })
}
