// sankey.typ - Sankey / flow diagrams
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-sankey-data
#import "../primitives/container.typ": chart-container

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
  width: 400pt,
  height: 250pt,
  title: none,
  node-width: 15pt,
  show-labels: true,
  show-values: false,
  theme: none,
) = {
  validate-sankey-data(data, "sankey-chart")
  let t = resolve-theme(theme)

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

  let max-layer = calc.max(..layer)
  if max-layer == 0 { max-layer = 1 }
  let num-layers = max-layer + 1

  // Group nodes by layer
  let layers = array.range(num-layers).map(_ => ())
  for i in array.range(n) {
    layers.at(layer.at(i)).push(i)
  }

  // ── Layout geometry ───────────────────────────────────────────────────
  let pad-x = 40pt   // horizontal padding for labels
  let pad-y = 10pt    // vertical padding top/bottom
  let chart-w = width - 2 * pad-x
  let chart-h = height - 2 * pad-y

  // Column x-positions (left edge of node rect)
  let col-spacing = if num-layers > 1 {
    (chart-w - node-width) / (num-layers - 1)
  } else {
    0pt
  }

  // Compute vertical positions for each node within its layer.
  // Nodes are stacked with small gaps, sized proportional to their value.
  let node-gap = 8pt
  let node-x = array.range(n).map(_ => 0pt)
  let node-y = array.range(n).map(_ => 0pt)
  let node-h = array.range(n).map(_ => 0pt)

  for li in array.range(num-layers) {
    let col-nodes = layers.at(li)
    let total-val = col-nodes.fold(0, (acc, i) => acc + node-value.at(i))
    let gap-total = node-gap * calc.max(col-nodes.len() - 1, 0)
    let avail-h = chart-h - gap-total
    if avail-h < 10pt { avail-h = 10pt }

    let y-cursor = pad-y
    for i in col-nodes {
      let h = if total-val > 0 {
        avail-h * (node-value.at(i) / total-val)
      } else {
        avail-h / col-nodes.len()
      }
      node-x.at(i) = pad-x + col-spacing * layer.at(i)
      node-y.at(i) = y-cursor
      node-h.at(i) = h
      y-cursor = y-cursor + h + node-gap
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
  chart-container(width, height, title, t)[
    #box(width: width, height: height)[
      // Draw flows first (behind nodes)
      #for f in sorted-flows {
        let src = f.from
        let dst = f.to
        let val = f.value
        let src-total = if node-out.at(src) > 0 { node-out.at(src) } else { 1 }
        let dst-total = if node-in.at(dst) > 0 { node-in.at(dst) } else { 1 }
        let src-h = node-h.at(src) * (val / src-total)
        let dst-h = node-h.at(dst) * (val / dst-total)

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

      // Draw labels
      #if show-labels {
        for i in array.range(n) {
          let lbl = nodes.at(i)
          let val-text = if show-values {
            let v = node-value.at(i)
            " (" + str(v) + ")"
          } else { "" }

          // Place label to the right for left/middle columns, left for rightmost
          if layer.at(i) == max-layer {
            // Right-side: label to the left of the node
            place(left + top,
              dx: node-x.at(i) - 4pt,
              dy: node-y.at(i) + node-h.at(i) / 2 - 6pt,
              align(right,
                text(size: 8pt, fill: t.text-color, str(lbl) + val-text),
              ),
            )
          } else {
            // Left/middle: label to the right of the node
            place(left + top,
              dx: node-x.at(i) + node-width + 4pt,
              dy: node-y.at(i) + node-h.at(i) / 2 - 6pt,
              text(size: 8pt, fill: t.text-color, str(lbl) + val-text),
            )
          }
        }
      }
    ]
  ]
}
