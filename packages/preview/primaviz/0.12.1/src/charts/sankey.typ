// sankey.typ - Sankey / flow diagrams
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero, format-number
#import "../validate.typ": validate-sankey-data
#import "../primitives/container.typ": chart-container
#import "../primitives/layout.typ": resolve-size, text-width, place-centered, spread-labels, fit-font-size

/// Renders a Sankey (flow) diagram showing quantities flowing between nodes.
///
/// Nodes are arranged in columns (layers) determined by topological ordering.
/// Flows are drawn as curved bands connecting source and target node ports.
///
/// - data (dictionary): Must contain `nodes` (array of strings) and `flows`
///   (array of dicts with `from`, `to`, `value` keys — indices into `nodes`).
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - node-width (length): Width of each node rectangle
/// - show-labels (bool): Display node name labels
/// - show-values (bool): Display flow value labels on nodes
/// - theme (none, dictionary): Theme overrides
/// -> content
#let sankey-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  node-width: 15pt,
  show-labels: true,
  show-values: false,
  theme: none,
) = context {
  layout(size => {
  validate-sankey-data(data, "sankey-chart")
  let t = _resolve-ctx(theme)
  let (width, height) = resolve-size(width, height, size, n: data.nodes.len(), theme: t)

  let nodes = data.nodes
  let flows = data.flows
  let n = nodes.len()

  // ── Build adjacency info ──────────────────────────────────────────────
  // Compute total in/out flow per node
  let node-out = array.range(n).map(_ => 0)
  let node-in  = array.range(n).map(_ => 0)
  for f in flows {
    node-out.at(f.from) = node-out.at(f.from) + f.value
    node-in.at(f.to)    = node-in.at(f.to) + f.value
  }
  // Node total value = max(in, out) — handles source/sink nodes
  let node-value = array.range(n).map(i => calc.max(node-out.at(i), node-in.at(i)))

  // ── Assign layers via longest-path from sources ───────────────────────
  let layer = array.range(n).map(_ => 0)
  // Iterative relaxation (safe for DAGs of any depth)
  let changed = true
  let iters = 0
  while changed and iters < n {
    changed = false
    iters += 1
    for f in flows {
      let new-layer = layer.at(f.from) + 1
      if new-layer > layer.at(f.to) {
        layer.at(f.to) = new-layer
        changed = true
      }
    }
  }

  let max-layer = nonzero(calc.max(..layer))
  let num-layers = max-layer + 1

  // Group nodes by layer
  let layers = array.range(num-layers).map(_ => ())
  for i in array.range(n) {
    layers.at(layer.at(i)).push(i)
  }

  // ── Layout geometry ───────────────────────────────────────────────────
  // Node labels: [name (value)]; the outer columns keep theirs in a gutter
  // measured from the labels (first column on the left, last on the right)
  let label-size = calc.min(t.axis-label-size, calc.max(5pt, height / 25))
  let label-of(i) = if show-values { [#nodes.at(i) (#format-number(node-value.at(i)))] } else { [#nodes.at(i)] }
  let label-gap = 4pt
  let gutter-cap = width * 0.28
  let first-col = layers.first()
  let last-col = if num-layers > 1 { layers.last() } else { () }
  let widest(col) = col.fold(0pt, (acc, i) => calc.max(acc, text-width(label-of(i), label-size)))
  let gutter(col) = if not show-labels or col.len() == 0 { 0pt } else {
    calc.min(widest(col) + label-gap, gutter-cap)
  }
  let pad-left = calc.max(8pt, gutter(first-col))
  let pad-right = calc.max(8pt, gutter(last-col))
  let pad-y = 10pt    // vertical padding top/bottom
  let chart-w = width - pad-left - pad-right
  let chart-h = height - 2 * pad-y

  // Column x-positions (left edge of node rect)
  let col-spacing = if num-layers > 1 {
    (chart-w - node-width) / (num-layers - 1)
  } else {
    0pt
  }

  // Compute vertical positions for each node within its layer.
  // One scale (length per unit of value) for the whole chart, set by the
  // fullest column, so a flow keeps the same thickness from end to end and
  // a node's bands never stretch to fill it. Shorter columns are centred.
  let node-gap = calc.max(4pt, chart-h * 0.03)
  let node-x = array.range(n).map(_ => 0pt)
  let node-y = array.range(n).map(_ => 0pt)
  let node-h = array.range(n).map(_ => 0pt)

  let col-avail = layers.map(col => calc.max(10pt, chart-h - node-gap * calc.max(col.len() - 1, 0)))
  let col-total = layers.map(col => col.fold(0, (acc, i) => acc + node-value.at(i)))
  let scales = array.range(num-layers)
    .filter(li => col-total.at(li) > 0)
    .map(li => col-avail.at(li) / col-total.at(li))
  let scale = if scales.len() > 0 { calc.min(..scales) } else { 0pt }

  for li in array.range(num-layers) {
    let col-nodes = layers.at(li)
    let hs = col-nodes.map(i => node-value.at(i) * scale)
    let col-h = hs.sum(default: 0pt) + node-gap * calc.max(col-nodes.len() - 1, 0)
    let y-cursor = pad-y + (chart-h - col-h) / 2
    for (k, i) in col-nodes.enumerate() {
      node-x.at(i) = pad-left + col-spacing * layer.at(i)
      node-y.at(i) = y-cursor
      node-h.at(i) = hs.at(k)
      y-cursor = y-cursor + hs.at(k) + node-gap
    }
  }

  // ── Sort flows per node to get stable port offsets ────────────────────
  // For each node, track how much of its height has been "used" by flows
  // on the outgoing (right) and incoming (left) side.
  let out-offset = array.range(n).map(_ => 0pt)
  let in-offset  = array.range(n).map(_ => 0pt)

  // Sort flows by source-layer then target-layer for visual consistency
  let sorted-flows = flows.sorted(key: f => layer.at(f.from) * 1000 + layer.at(f.to))

  // ── Render ────────────────────────────────────────────────────────────
  let page-bg = if t.background == none { white } else { t.background }
  align(center, chart-container(width, height, title, t)[
    #box(width: width, height: height)[
      // Draw flows first (behind nodes)
      #for f in sorted-flows {
        let src = f.from
        let dst = f.to
        let val = f.value
        // Same scale as the nodes: the band is equally thick at both ends
        let src-h = val * scale
        let dst-h = val * scale

        let src-y-start = node-y.at(src) + out-offset.at(src)
        let dst-y-start = node-y.at(dst) + in-offset.at(dst)

        // Update offsets
        out-offset.at(src) = out-offset.at(src) + src-h
        in-offset.at(dst)  = in-offset.at(dst) + dst-h

        // Source right edge, destination left edge
        let x0 = node-x.at(src) + node-width
        let x1 = node-x.at(dst)

        // Build a curved polygon with ~20 intermediate steps
        let steps = 20
        let top-points = ()
        let bot-points = ()
        for s in array.range(steps + 1) {
          let frac = s / steps
          // Cubic ease in-out: 3t^2 - 2t^3
          let ease = 3 * calc.pow(frac, 2) - 2 * calc.pow(frac, 3)
          let x = x0 + (x1 - x0) * frac
          let y-top = src-y-start + (dst-y-start - src-y-start) * ease
          let y-bot = (src-y-start + src-h) + ((dst-y-start + dst-h) - (src-y-start + src-h)) * ease
          top-points.push((x, y-top))
          bot-points.push((x, y-bot))
        }
        // Polygon: top edge left→right, then bottom edge right→left
        let pts = top-points + bot-points.rev()

        let flow-color = get-color(t, src)
        place(left + top, polygon(
          fill: flow-color.transparentize(60%),
          stroke: none,
          ..pts,
        ))
      }

      // Draw nodes
      #for i in array.range(n) {
        let color = get-color(t, i)
        place(left + top,
          dx: node-x.at(i),
          dy: node-y.at(i),
          rect(
            width: node-width,
            height: node-h.at(i),
            fill: color,
            stroke: 0.5pt + color.darken(20%),
          ),
        )
      }

      // Draw labels — spread apart per layer so none overlaps another. First
      // and middle columns put theirs left of the node, the last column to its
      // right; each is wrapped at the room it has, never clipped.
      #if show-labels {
        for li in array.range(num-layers) {
          let col-nodes = layers.at(li)
          let is-last = num-layers > 1 and li == num-layers - 1
          let avail = if is-last { pad-right - label-gap } else if li == 0 { pad-left - label-gap } else {
            calc.max(20pt, col-spacing - node-width - 2 * label-gap)
          }
          let sizes = col-nodes.map(i => fit-font-size(label-of(i), avail, label-size, min: 6pt))
          let heights = col-nodes.enumerate().map(((k, i)) =>
            measure(box(width: avail, text(size: sizes.at(k))[#label-of(i)])).height)
          let sep = heights.fold(0pt, calc.max) + 1pt
          // The names of the biggest nodes win when a column has more than it holds
          let ys = spread-labels(
            col-nodes.map(i => node-y.at(i) + node-h.at(i) / 2), sizes: sep,
            lo: pad-y, hi: height - pad-y, priority: col-nodes.map(i => node-value.at(i)))
          for (k, i) in col-nodes.enumerate() {
            if ys.at(k) == none { continue }
            let ink = text(size: sizes.at(k), fill: t.text-color)[#label-of(i)]
            // Labels of middle columns sit on the flows: a halo in the page
            // colour keeps them legible on any band
            let body = if li > 0 and not is-last {
              let halo = text(size: sizes.at(k), fill: page-bg,
                stroke: (paint: page-bg, thickness: 0.35 * sizes.at(k), join: "round"))[#label-of(i)]
              box(width: avail, {
                place(top + left, box(width: avail, align(right, halo)))
                align(right, ink)
              })
            } else { ink }
            if is-last {
              place-centered(node-x.at(i) + node-width + label-gap, ys.at(k), body, width: avail, align: left)
            } else {
              place-centered(node-x.at(i) - label-gap - avail, ys.at(k), body, width: avail, align: right)
            }
          }
        }
      }
    ]
  ])
  })
}
