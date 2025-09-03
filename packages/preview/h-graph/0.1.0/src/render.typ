#import "@preview/fletcher:0.5.8" as flcr: diagram, edge, node
//render part
#let render-help-draw-edge(ed: array) = {
  let (from, to, info) = ed
  if from == to and info == () {
    return edge(label(from), label()(to), bend: 130deg, "->")
  }
  return edge(label(from), label(to), ..info)
}

#let render-help-draw-edge(ed: array, dict-params: (:)) = {
  let (from, to, info) = ed

  info.at(1) = info
    .at(1)
    .pairs()
    .filter(
      v => not v.at(0).starts-with("_"),
    )
    .to-dict()
  if from == to and info.at(0).len() == 0 {
    let std-param-arr = ("-|>",)
    let std-param-dict = (stroke: 1pt, bend: 130deg)
    std-param-dict += dict-params
    std-param-dict += info.at(1)
    return edge(label(from), label(to), ..std-param-dict, ..std-param-arr)
  } else {
    let std-param-dict = (stroke: 1pt)
    std-param-dict += dict-params
    std-param-dict += info.at(1)
    return edge(label(from), label(to), ..info.at(0), ..std-param-dict)
  }
}

/*
 * place it in circles
 */
#let polar-render(
  cir-n: 1,
  scl: 1,
) = (nodes: dictionary, edges: array) => {
  let cir_n = int(cir-n)
  let scl = float(scl)
  assert(cir_n >= 1)
  let node_num = nodes.keys().len()

  let to_origins = range(1, cir_n + 1).map(i => i / cir_n)
  let total = to_origins.sum()
  let each_nums = to_origins.map(i => i / total).map(pct => int(pct * node_num))
  each_nums.at(each_nums.len() - 1) += node_num - each_nums.sum()
  let each_parital_sum = (0,)
  for each_num in each_nums {
    each_parital_sum.push(each_parital_sum.at(each_parital_sum.len() - 1) + each_num)
  }

  // real render
  scale(
    100% * scl,
    origin: left + top,
    reflow: true,
    diagram(
      spacing: each_nums.at(each_nums.len() - 1) * 10pt * (calc.min(calc.ln(cir_n + 1) * 1.5, 2)),
      // origin
      node((1, 0), name: <origin>),
      ..edges.map(ed => render-help-draw-edge(ed: ed)),

      for cir_i in range(0, cir_n) {
        let _nodes = nodes.pairs().slice(each_parital_sum.at(cir_i), each_parital_sum.at(cir_i + 1))
        let _node_num = each_nums.at(cir_i)
        let _node_cons = _nodes.map(pair => {
          let (key, value) = pair
          let final_con = if (value.content == none) {
            key
          } else {
            value.content
          }
          return (key, final_con)
        })


        for ((id, content), deg) in range(0, _node_num).map(i => (_node_cons.at(i), (i / _node_num) * 360deg)) {
          node(
            stroke: 1.5pt,
            (rel: (deg, to_origins.at(cir_i)), to: <origin>),
            if (_nodes.filter(v => v.at(0) == id).at(0).at(1).content == none) { content } else { eval(content) },
            inset: 10pt,
            name: label(id),
          )
        }
      },
    ),
  )
}

/*
 * Calculate to degree sequence and place from center,
 * if degree is zero, place between the graph
 * if the node has been found, then use bended edge
 */
#let tree-render(scl: 1, ed-bd: "30deg", min-space: "50pt", base-deg: "0") = (nodes: dictionary, edges: array) => {
  let scl = float(scl) * 100%
  let ed-bend = eval(ed-bd)
  let base-deg = int(base-deg)
  let min-space = min-space
  if nodes.len() == 0 {
    return
  }
  // analyze the degree sequence
  let deg-map = (:)
  for nd in nodes.keys() {
    deg-map.insert(nd, 0)
  }

  for ed in edges {
    deg-map.insert(ed.at(0), deg-map.at(ed.at(0)) + 1)
    deg-map.insert(ed.at(1), deg-map.at(ed.at(1)) + 1)
  }

  let deg-seq = deg-map.pairs().sorted(key: it => -it.at(1))
  // gen the node-info
  // content
  let node-cons = nodes
    .pairs()
    .map(
      n => (n.at(0), if n.at(1).content == none { n.at(0) } else { eval(n.at(1).content) }),
    )
    .to-dict()


  let place-info-map = (:)
  for nd in nodes.keys() {
    place-info-map.insert(nd, (
      depth: 0,
      from-deg: 0,
      childrens: (),
      found: false,
      cache-deg: 0,
      from: none,
    ))
  }

  let deg-first = deg-seq.at(0).at(0)

  place-info-map.at(deg-first) = (
    depth: 0,
    from-deg: base-deg,
    cache-deg: base-deg,
    found: true,
    childrens: edges
      .filter(v => deg-first in v and v.at(0) != v.at(1))
      .map(v => if (v.at(0) == deg-first) { v.at(1) } else { v.at(0) }),
    from: none,
  )
  for first-child in place-info-map.at(deg-first).childrens {
    place-info-map.at(first-child).found = true
  }
  // bfs
  let get-out(place-info-map, waiting-arr) = {
    let _place-info-map = place-info-map

    while waiting-arr.len() != 0 {
      let (from, now) = waiting-arr.at(0)
      waiting-arr = waiting-arr.slice(1)

      // set self props, deg is set by cache and children number
      _place-info-map.at(now).found = true
      _place-info-map.at(now).from = from
      _place-info-map.at(now).depth = _place-info-map.at(from).depth + 1
      _place-info-map.at(now).from-deg = calc.rem(
        (
          _place-info-map.at(from).cache-deg
            + int(360 / (_place-info-map.at(from).childrens.len() + if from == deg-first { 0 } else { 1 }))
        ),
        360,
      )
      // save the degree
      _place-info-map.at(from).cache-deg = _place-info-map.at(now).from-deg
      _place-info-map.at(now).cache-deg = _place-info-map.at(now).from-deg + 180

      // nxt loop
      let nxt-nds = edges
        .filter(v => now in v and v.at(0) != v.at(1))
        .map(v => if (v.at(0) == now) { v.at(1) } else { v.at(0) })
        .filter(v => not _place-info-map.at(v).found)

      for nxt-nd in nxt-nds {
        _place-info-map.at(nxt-nd).found = true
        _place-info-map.at(nxt-nd).from = now
      }

      _place-info-map.at(now).childrens = nxt-nds
      waiting-arr += nxt-nds.map(it => (now, it))
    }
    return _place-info-map
  }

  place-info-map = get-out(
    place-info-map,
    place-info-map.at(deg-first).childrens.map(it => (deg-first, it)),
  )

  // other not in the main tree, recursive to draw
  let other-nds = place-info-map
    .pairs()
    .filter(v => v.at(1).from == none and v.at(0) != deg-first)
    .map(v => (v.at(0), nodes.at(v.at(0))))
    .to-dict()
  let other-egs = edges.filter(
    ed => ed.at(0) in other-nds.keys() or ed.at(1) in other-nds.keys(),
  )


  tree-render(
    scl: scl,
    ed-bd: ed-bd,
    min-space: min-space,
    base-deg: base-deg,
  )(nodes: other-nds, edges: other-egs)

  // remains
  edges = edges.filter(ed => not (ed.at(0) in other-nds.keys() or ed.at(1) in other-nds.keys()))
  place-info-map = place-info-map.pairs().filter(v => v.at(1).from != none or v.at(0) == deg-first).to-dict()

  let max-place-order = calc.max(
    ..place-info-map.values().map(it => it.depth),
  )

  let drawed-eles = (node((1, 0), name: <origin>),)

  for (id, info) in place-info-map.pairs().sorted(key: it => it.at(1).depth) {
    drawed-eles.push(
      node(
        stroke: 1.5pt,
        (
          rel: (
            eval(str(info.from-deg) + "deg"),
            if info.from == none { 0pt } else {
              let custom-edge-lens = edges
                .filter(
                  v => (info.from == v.at(0) and id == v.at(1)) or (info.from == v.at(1) and id == v.at(0)),
                )
                .filter(v => "_l" in v.at(2).at(1).keys())
              if custom-edge-lens.len() > 0 {
                let max-len = calc.max(..custom-edge-lens.map(v => v.at(2).at(1).at("_l")))
                max-len
              } else {
                eval(min-space)
              }
            },
          ),
          to: if info.from == none { <origin> } else { label(info.from) },
        ),
        node-cons.at(id),
        inset: 10pt,
        name: (label(id)),
      ),
    )
  }


  for ed in edges {
    let (e-from, e-to, e-info) = ed
    if place-info-map.at(e-from).from == e-to or place-info-map.at(e-to).from == e-from or e-from == e-to {
      // normal draw
      drawed-eles.push(render-help-draw-edge(ed: ed))
    } else {
      drawed-eles.push(render-help-draw-edge(ed: ed, dict-params: (
        bend: ed-bend,
      )))
    }
  }


  scale(
    100% * scl,
    origin: left + top,
    reflow: true,
    diagram(
      ..drawed-eles,
    ),
  )
}

