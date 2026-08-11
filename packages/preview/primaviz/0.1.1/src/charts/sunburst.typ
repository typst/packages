// sunburst.typ - Multi-level pie/donut chart for hierarchical data
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-sunburst-data
#import "../primitives/container.typ": chart-container

/// Computes the maximum depth of a hierarchical node tree.
///
/// - node (dictionary): A node with optional `children` array
/// -> int
#let _max-depth(node) = {
  if "children" not in node or node.children.len() == 0 {
    return 1
  }
  let deepest = 0
  for child in node.children {
    let d = _max-depth(child)
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
/// - color-index (int): Index into the theme palette for this branch
/// -> array
#let _collect-segments(node, start-angle, end-angle, depth, color-index) = {
  let segments = ()

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
    let current = start-angle
    for (i, child) in node.children.enumerate() {
      let span = if total-child-value > 0 {
        (child.value / total-child-value) * (end-angle - start-angle)
      } else { 0 }
      let child-color = if depth == 0 { i } else { color-index }
      let child-segs = _collect-segments(child, current, current + span, depth + 1, child-color)
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
/// - title (none, content): Optional chart title
/// - show-labels (bool): Display name labels on segments large enough to fit them
/// - theme (none, dictionary): Theme overrides
/// -> content
#let sunburst-chart(
  data,
  size: 300pt,
  inner-radius: 40pt,
  ring-width: 35pt,
  title: none,
  show-labels: true,
  theme: none,
) = {
  validate-sunburst-data(data, "sunburst-chart")
  let t = resolve-theme(theme)

  // Compute depth (excluding root) to determine how many rings we need
  let total-depth = _max-depth(data) - 1  // rings = depth levels below root
  let total-depth = calc.min(total-depth, 4)  // cap at 4 rings

  // Adjust size if rings would overflow
  let needed-diameter = 2 * (inner-radius + ring-width * total-depth)
  let chart-size = calc.max(size, needed-diameter + 10pt)

  let radius = chart-size / 2

  // Collect all arc segments
  let segments = _collect-segments(data, 0, 360, 0, 0)

  chart-container(chart-size, chart-size, title, t, extra-height: 40pt)[
    #box(width: chart-size, height: chart-size)[
      #let cx = radius
      #let cy = radius

      #for seg in segments {
        let depth = seg.depth  // 1-based (1 = innermost ring)
        let r-inner = inner-radius + (depth - 1) * ring-width
        let r-outer = inner-radius + depth * ring-width

        let angle-span = seg.end-angle - seg.start-angle
        if angle-span < 0.1 { continue }  // skip tiny segments

        // Number of line segments to approximate arcs
        let arc-segments = calc.max(int(angle-span / 5), 4)

        // Build polygon: outer arc forward, then inner arc backward
        let pts = ()

        // Outer arc (start -> end)
        for j in array.range(arc-segments + 1) {
          let angle = seg.start-angle + (j / arc-segments) * angle-span
          let x = cx + r-outer * calc.cos(angle * 1deg)
          let y = cy + r-outer * calc.sin(angle * 1deg)
          pts.push((x, y))
        }

        // Inner arc (end -> start)
        for j in array.range(arc-segments + 1) {
          let angle = seg.end-angle - (j / arc-segments) * angle-span
          let x = cx + r-inner * calc.cos(angle * 1deg)
          let y = cy + r-inner * calc.sin(angle * 1deg)
          pts.push((x, y))
        }

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
            stroke: (if t.background != none { t.background } else { white }) + 0.75pt,
            ..pts.map(p => (p.at(0), p.at(1)))
          )
        )

        // Label on segments that are wide enough
        if show-labels and angle-span >= 15 {
          let mid-angle = (seg.start-angle + seg.end-angle) / 2
          let mid-r = (r-inner + r-outer) / 2
          let lx = cx + mid-r * calc.cos(mid-angle * 1deg)
          let ly = cy + mid-r * calc.sin(mid-angle * 1deg)

          // Determine text color based on depth
          let label-color = if seg.depth <= 2 { t.text-color-inverse } else { t.text-color }

          place(
            left + top,
            dx: lx - 18pt,
            dy: ly - 5pt,
            text(
              size: calc.max(t.value-label-size - 1pt, 5pt),
              fill: label-color,
              weight: if seg.depth == 1 { "bold" } else { "regular" },
            )[#seg.name]
          )
        }
      }
    ]
  ]
}
