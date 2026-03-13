#import "@preview/fletcher:0.5.8" as fletcher
#import "@preview/diagraph-layout:0.0.1" as dgl

#let node(name, ..args) = {
  assert(args.pos().len() <= 1)
  let body = {
    let pos = args.pos()
    if pos.len() == 0 {
      str(name)
    } else {
      let body = pos.at(0)
      if body == none {
        body = box(width: 0.85em, height: 0.85em)
      }
      body
    }
  }
  metadata((
    class: "autograph-node",
    name: name,
    body: body,
    args: args.named(),
  ))
}

#let edge(tail, head, ..args) = {
  assert(args.pos().len() == 0)
  metadata((
    class: "autograph-edge",
    tail: tail,
    head: head,
    args: args.named(),
  ))
}

// This function transforms a list of Bézier control points to a list of Bézier segments.
// A single Bézier segment has 4 control points: the start, two points that determine the curvature, and the end.
// When the curve consists of only one segment, the length is 4,
// and for more than one segment, the length must be 7, 10, 13, 16, ...
// For example, when points = (p0, p1, p2, p3, p4, p5, p6, p7, p8, p9),
// we get: 
// ((p0, p1, p2, p3), (p3, p4, p5, p6), (p6, p7, p8, p9))
#let bezier-segments(points) = {
  assert(calc.rem(points.len() - 1, 3) == 0)
  let segments = ()
  let i = 0
  while i + 3 < points.len() {
    segments.push(points.slice(i, i + 4))
    i += 3
  }
  segments
}

// Extracts the boundaries of a list of Bézier segments,
// For example:
// ((p0, p1, p2, p3), (p3, p4, p5, p6), (p6, p7, p8, p9)) -> (p0, p3, p6, p9)
#let bezier-boundaries(segments) = {
  (
    segments.at(0).at(0),
    ..segments.map(
      segment => segment.at(3)
    )
  )
}

// Replaces the start and end points of a list of Bézier segements.
// For example: 
// ((p0, p1, p2, p3), (p3, p4, p5, p6)) -> ((new-start, p1, p2, p3), (p3, p4, p5, new-end))
// or
// ((p0, p1, p2, p3)) -> ((new-start, p1, p2, new-end))
#let replace-bezier-bounds(segments, new-start, new-end) = {
  let replace-start(segments, replacement) = (
    (
      replacement,
      ..segments.first().slice(1),
    ),
    ..segments.slice(1),
  )
  let replace-end(segments, replacement) = (
    ..segments.slice(0, -1),
    (
      ..segments.last().slice(0, -1),
      replacement,
    ),
  )
  replace-start(
    replace-end(
      segments,
      new-end
    ),
    new-start
  )
}

#let diagram(
  engine: "dot",
  bezier: false,
  ..args,
) = context {
  let default-args = (
    node-shape: fletcher.shapes.ellipse,
    node-stroke: 1pt + black,
    edge-stroke: 1pt,
    mark-scale: 125%,
    node-inset: 1.5em,
  )
  let diagram-args = args.named()
  for (k, v) in default-args.pairs() {
    if not diagram-args.keys().contains(k) {
      diagram-args.insert(k, v)
    }
  }
  let is-autograph-elem(e) = e.value.class.starts-with("autograph-")
  let fletcher-elements = args.pos().flatten().filter(e => not is-autograph-elem(e))
  let autograph-elements = args.pos().flatten().filter(is-autograph-elem)
  let (rendered-nodes, edges, layout-edges) = {
    if autograph-elements.len() > 0 {
      let nodes = autograph-elements.filter(
        e => e.value.class == "autograph-node"
      ).map(
        e => (str(e.value.name), e)
      ).to-dict()
      let edges = autograph-elements.filter(e => e.value.class == "autograph-edge")
      let node-dimensions = nodes.pairs().map(
        ((name, node)) => {
          let measurements = measure(
            fletcher.diagram(
              ..diagram-args,
              fletcher.node(
                (0,0), // Let's hope that this keeps people from manually supplying a position in the node args
                ..node.value.args,
                node.value.body
              )
            )
          )
          (name, measurements)
        }
      ).to-dict()
      assert(nodes.keys() == node-dimensions.keys())
      let layout = dgl.layout-graph(
        engine: engine,
        directed: true,
        ..node-dimensions.pairs().map(
          ((name, measurements)) => {
            dgl.node(
              name,
              width: measurements.width,
              height: measurements.height
            )    
          }
        ),
        ..edges.enumerate().map(
          ((i, edge)) => {
            // We are doing some hacks with the edge label in order to be able to identify out edges later on
            // (since they don't have a built-in identifier at the moment).
            // Since we are using labelfloat: true, the layout is only affected if you have a lot of edges, but
            // even then, probably not by much.
            // Later on, we can sort by the label width of each edge and get our canonical edge order back.
            // I hope we can replace this with something more sound later on.
            let min-len = 8pt
            let step = 1pt
            let dummy-id = min-len + (i * step)
            // Note: Currently, the "head" and "tail" arguments of the edge function are incorrectly named.
            // Therefore, we need to effectively call it as edge(head: tail, tail: head) for it to be correct later.
            // Since this feels more natural anyway, it's likely that the parameter names are simply a typo.
            dgl.edge(
              str(edge.value.tail),
              str(edge.value.head),
              label: (width: dummy-id, height: 0pt),
              labelfloat: "true",
            )
          }
        )
      )
      assert(not layout.errored)
      let node-positions = layout.nodes.map(
        (node) => {
          (node.name, (node.x, node.y))
        }
      ).to-dict()
      // diagraph-layout does not guarantee that the input and output order of the nodes is identical.
      // We ensure this by explicitly re-ordering the dict.
      let node-positions = nodes.keys().map(
        name => (name, node-positions.at(name))
      ).to-dict()
      assert(nodes.keys() == node-positions.keys())
      // We guarantee that the first node that was defined will be at position (0,0).
      // To do so, we offset all positions by the first position.
      let position-offset = node-positions.values().at(0)
      let node-positions = node-positions.pairs().map(
        ((name, (x,y))) => {
          let (dx, dy) = position-offset
          (name, (x - dx, y - dy))
        }
      ).to-dict()
      // diagraph-layout does not guarantee that the input and output order of the edges is identical.
      // Since we applied a summy label width to each edge before, it *should* suffice to sort by that width
      // to get our original edge order back.
      let layout-edges = {
        layout.edges.sorted(
          key: edge => edge.label.width
        )
      }
      // Nonetheless, I will still go the extra mile and manually "order" the edges
      // by the (tail, head) combinations which is only ambiguous if you have multiple identical edges.
      let layout-edges = {
        let layout-edges-old = layout-edges
        let layout-edges-new = ()
        for edge in edges {
          let tail = str(edge.value.tail)
          let head = str(edge.value.head)
          for (i, layout-edge) in layout-edges-old.enumerate() {
            if tail == layout-edge.tail and head == layout-edge.head {
              layout-edges-new.push(
                layout-edges-old.remove(i)
              )
              break
            }
          }
        }
        layout-edges-new
      }
      let layout-edges = layout-edges.map(
        edge => {
          let points = edge.points.map(
            // We are again using the position-offset, just like with the node-positions:
            point => {
              let (dx, dy) = position-offset
              (point.x - dx, point.y - dy)
            }
          )
          let segments = bezier-segments(points)
          (
            head: edge.head,
            tail: edge.tail,
            points: points,
            segments: segments,
          )
        }
      )
      assert(
        layout-edges.map(
          edge => (edge.tail, edge.head)
        ) == edges.map(
          edge => (str(edge.value.tail), str(edge.value.head))
        )
      )
      let rendered-nodes = {
        for ((name, node), (x, y)) in nodes.pairs().zip(node-positions.values()) {
          fletcher.node(
            (x, y),
            name: node.value.name,
            ..node.value.args,
            node.value.body
          )
        }
      }
      (rendered-nodes, edges, layout-edges)
    } else {
      ((), (), ())
    }
  }
  if not bezier {
    // When bezier == false, we draw the edges using fletcher.edge.
    // Since fletcher currently (as of v0.5.8) doesn't support bezier, this can look a bit choppy.
    // This will probably be improved with fletcher v.0.6.0 and we will remove the bezier option.
    fletcher.diagram(
      ..diagram-args,
      rendered-nodes,
      for (edge, layout-edge) in edges.zip(layout-edges) {
        assert(str(edge.value.tail) == layout-edge.tail)
        assert(str(edge.value.head) == layout-edge.head)
        let segments = replace-bezier-bounds(
          layout-edge.segments,
          edge.value.tail,
          edge.value.head
        )
        // Since we're currently unable to draw Bézier curves, we're only keeping the segment boundaries:
        let points = bezier-boundaries(segments)
        fletcher.edge(
          ..points,
          marks: "-solid",
          ..edge.value.args,
        )
      },
      fletcher-elements,
    )
  } else {
    // When bezier == true, we draw the edges using cetz.draw.bezier.
    // This will look fine by default, but will ignore all edge styles that you passed to diagram.
    // fletcher will probably feature bezier edges in v.0.6.0 and we will remove the bezier option.
    fletcher.diagram(
      ..diagram-args,
      rendered-nodes,
      fletcher-elements,
      render: (grid, fletcher-nodes, fletcher-edges, options) => {
        fletcher.cetz.canvas({
          fletcher.draw-diagram(grid, fletcher-nodes, fletcher-edges, debug: options.debug)
          for (edge, layout-edge) in edges.zip(layout-edges) {
            let segments = layout-edge.segments
            // let points = edge.points
            let calculate-angle(center, other) = {
              let base-unit = 1pt
              let dist = (
                (center.at(0) - other.at(0)) / base-unit,
                (center.at(1) - other.at(1)) / base-unit,
              )
              calc.atan2(dist.at(0), dist.at(1))
            }
            let tail-node = fletcher.find-node(fletcher-nodes, edge.value.tail)
            let tail-angle = calculate-angle(segments.at(0).at(0), tail-node.pos.xyz)
            let head-node = fletcher.find-node(fletcher-nodes, edge.value.head)
            let head-angle = calculate-angle(segments.at(-1).at(-1), head-node.pos.xyz)
            fletcher.get-node-anchor(tail-node, tail-angle, start-point => {
              fletcher.get-node-anchor(head-node, head-angle, end-point => {
                let segments = replace-bezier-bounds(segments, start-point, end-point)
                for (i, (a, b, c, d)) in segments.enumerate() {
                  let default-style = (
                    stroke: 1pt + black,
                    mark: (end: ">", fill: black, scale: 1.5)
                  )
                  let style = edge.value.args
                  for (k,v) in default-style.pairs() {
                    if not style.keys().contains(k) {
                      style.insert(k, v)
                    }
                  }
                  let style = {
                    if i != segments.len() - 1 {
                      let style = style
                      let _ = style.remove("mark")
                      style
                    } else {
                      style
                    }
                  }
                  fletcher.cetz.draw.bezier(
                    a, d, b, c,
                    ..style
                  )
                }
              })
            })
          }
        })
      },
    )    
  }
}
