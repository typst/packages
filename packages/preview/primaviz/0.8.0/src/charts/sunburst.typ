// sunburst.typ - Multi-level pie/donut chart for hierarchical data
#import "../theme.typ": _resolve-ctx, get-color
#import "../validate.typ": validate-sunburst-data
#import "../primitives/container.typ": chart-container
#import "../primitives/polar.typ": annular-wedge-points, separator-stroke
#import "../primitives/layout.typ": try-fit-label, resolve-size

/// Computes the depth of a hierarchical node tree.
///
/// - node (dictionary): A node with optional `children` array
/// -> int
#let _get-node-depth(node) = {
  if "children" not in node or node.children.len() == 0 {
    return 1
  }
  let deepest = 0
  for child in node.children {
    let d = _get-node-depth(child)
    if d > deepest {
      deepest = d
    }
  }
  return 1 + deepest
}

/// Builds a flat list of arc segments from the hierarchical data.
/// Each segment has: start-angle, end-angle, depth, color-index, name, value.
///
/// - node (dictionary): Current node
/// - start-angle (float): Start angle in degrees
/// - end-angle (float): End angle in degrees
/// - depth (int): Current depth (0 = root, 1 = first visible ring)
/// - max-depth (none, int): Maximum depth to include in segments
/// - color-index (int): Index into the theme palette for this branch
/// -> array
#let _collect-segments(node, start-angle, end-angle, depth, max-depth, color-index) = {
  let segments = ()

  // Stop the recursion if maximum depth is reached
  if max-depth != none and depth > max-depth {
    return segments
  }

  // Only emit a segment for depth >= 1 (skip the root)
  if depth >= 1 {
    segments.push((
      start-angle: start-angle,
      end-angle: end-angle,
      depth: depth,
      color-index: color-index,
      name: node.name,
      value: node.value,
    ))
  }

  // Recurse into children
  if "children" in node and node.children.len() > 0 {
    let total-child-value = node.children.map(c => c.value).sum()
    let child-end-angle = if (
      total-child-value > 0 and "value" in node and node.value > 0
    ) {
      start-angle + calc.min(total-child-value / node.value, 1.0) * (end-angle - start-angle)
    } else { end-angle }
    let current = start-angle
    for (i, child) in node.children.enumerate() {
      let span = if total-child-value > 0 {
        (child.value / total-child-value) * (child-end-angle - start-angle)
      } else { 0 }
      let child-color = if depth == 0 { i } else { color-index }
      let child-segs = _collect-segments(child, current, current + span, depth + 1, max-depth, child-color)
      segments = segments + child-segs
      current = current + span
    }
  }

  segments
}

/// Renders a sunburst chart from hierarchical data.
///
/// Inner ring represents the root's children; outer rings represent deeper levels.
/// Each segment's angular span is proportional to its value relative to siblings.
///
/// - data (dictionary): Hierarchical data with `name`, `value`, and `children` keys
/// - size (length): Diameter of the chart
/// - inner-radius (length): Radius of the empty center hole
/// - ring-width (length): Width of each concentric ring
/// - max-depth (none, int): Maximum number of rings to render
/// - min-angle (angle): Minimum angle for a segment to be rendered
/// - title (none, content): Optional chart title
/// - show-labels (bool): Display name labels on segments large enough to fit them
/// - theme (none, dictionary): Theme overrides
/// -> content
#let sunburst-chart(
  data,
  size: 300pt,
  inner-radius: 40pt,
  ring-width: 35pt,
  max-depth: none,
  min-angle: 0.1deg,
  title: none,
  show-labels: true,
  theme: none,
) = context {
  layout(avail => {
  validate-sunburst-data(data, "sunburst-chart")
  let t = _resolve-ctx(theme)
  let size = resolve-size(size, size, avail).width

  // Compute depth (excluding root) to determine how many rings we need
  let total-depth = _get-node-depth(data) - 1  // rings = depth levels below root
  let total-depth = if max-depth != none {
    calc.min(total-depth, max-depth)
  } else { total-depth }  // cap at max-depth

  // Adjust size if rings would overflow
  let needed-diameter = 2 * (inner-radius + ring-width * total-depth)
  let chart-size = calc.max(size, needed-diameter + 10pt)

  let radius = chart-size / 2

  // Collect arc segments
  let segments = _collect-segments(data, 0, 360, 0, max-depth, 0)

  align(center, chart-container(chart-size, chart-size, title, t, extra-height: 40pt)[
    #box(width: chart-size, height: chart-size)[
      #let cx = radius
      #let cy = radius

      #for seg in segments {
        let depth = seg.depth  // 1-based (1 = innermost ring)
        let r-inner = inner-radius + (depth - 1) * ring-width
        let r-outer = inner-radius + depth * ring-width

        let angle-span = seg.end-angle - seg.start-angle
        if angle-span < min-angle.deg() { continue }  // skip tiny segments

        let pts = annular-wedge-points(cx, cy, r-inner, r-outer, seg.start-angle, seg.end-angle)

        // Color: base color from palette, lighten for deeper levels
        let base-color = get-color(t, seg.color-index)
        let seg-color = if seg.depth == 1 {
          base-color
        } else if seg.depth == 2 {
          base-color.lighten(25%)
        } else if seg.depth == 3 {
          base-color.lighten(45%)
        } else {
          base-color.lighten(60%)
        }

        place(
          left + top,
          polygon(
            fill: seg-color,
            stroke: separator-stroke(t, thickness: 0.75pt),
            ..pts,
          )
        )

        // Label on segments — estimate arc width and try fitting
        if show-labels and angle-span >= 5 {
          let mid-angle = (seg.start-angle + seg.end-angle) / 2
          let mid-r = (r-inner + r-outer) / 2
          // Approximate available width from arc length at mid-radius
          let arc-w = (mid-r / 1pt) * angle-span / 360 * 2 * calc.pi * 1pt
          let arc-h = r-outer - r-inner
          let lbl-len = seg.name.len()
          let fit = try-fit-label(arc-w, arc-h, t.value-label-size, lbl-len, shrink-min: 5pt)

          if fit.fits {
            let lx = cx + mid-r * calc.cos(mid-angle * 1deg)
            let ly = cy + mid-r * calc.sin(mid-angle * 1deg)
            // All labels sit on colored pill backgrounds — use inverse text for contrast
            let label-color = t.text-color-inverse
            // Measure actual text dimensions for tight-fitting pill
            let label-content = text(
              size: fit.size,
              fill: label-color,
              weight: if seg.depth == 1 { "bold" } else { "regular" },
            )[#seg.name]
            let text-size = measure(label-content)
            let label-w = text-size.width + 4pt
            let pill-h = text-size.height + 3pt
            // Semi-transparent background pill matching segment color
            let pill-fill = seg-color.transparentize(20%)
            place(
              left + top,
              dx: lx - label-w / 2,
              dy: ly - pill-h / 2,
              box(width: label-w, height: pill-h,
                fill: pill-fill, radius: 2pt,
                align(center + horizon,
                  label-content))
            )
          }
        }
      }
    ]
  ])
  })
}
