// sunburst.typ - Multi-level pie/donut chart for hierarchical data
#import "../theme.typ": _resolve-ctx, get-color
#import "../validate.typ": validate-sunburst-data
#import "../primitives/container.typ": chart-container
#import "../primitives/polar.typ": place-wedge, separator-stroke
#import "../primitives/polar-labels.typ": fit-wedge-label, label-ink, place-centred, place-outside-labels, polar-label-extent
#import "../primitives/layout.typ": resolve-size

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

/// A name of several words as two lines, broken where they come out most
/// alike in length; `none` for a name without a space (or not a string).
///
/// - name (str, content): A segment's name
/// -> none, array of two strings
#let _two-lines(name) = {
  if type(name) != str or " " not in name { return none }
  let words = name.split(" ").filter(w => w != "")
  if words.len() < 2 { return none }
  let best = 1
  let best-gap = none
  for k in range(1, words.len()) {
    let gap = calc.abs(words.slice(0, k).join(" ").clusters().len() - words.slice(k).join(" ").clusters().len())
    if best-gap == none or gap < best-gap {
      best = k
      best-gap = gap
    }
  }
  (words.slice(0, best).join(" "), words.slice(best).join(" "))
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
/// A name is written inside its segment, as large as fits and in a colour
/// readable on that fill; if only a narrow segment is left it is turned along
/// the radius or the arc. An outermost segment that still cannot hold its name
/// gets it outside, on a leader line.
///
/// - data (dictionary): Hierarchical data with `name`, `value`, and `children` keys
/// - size (length): Diameter of the chart
/// - inner-radius (length): Radius of the empty center hole
/// - ring-width (length): Width of each concentric ring
/// - max-depth (none, int): Maximum number of rings to render
/// - total-angle (angle): Total angle swept by the rings
/// - start-angle (angle): Angle at which the first segment starts, measured
///   clockwise from 3 o'clock; the default `-90deg` starts at 12 o'clock
/// - min-angle (angle): Minimum angle for a segment to be rendered
/// - title (none, content): Optional chart title
/// - show-labels (bool): Display name labels on segments
/// - theme (none, dictionary): Theme overrides
/// -> content
#let sunburst-chart(
  data,
  size: 300pt,
  inner-radius: 40pt,
  ring-width: 35pt,
  max-depth: none,
  total-angle: 360deg,
  start-angle: -90deg,
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
  let rim = inner-radius + ring-width * total-depth
  let chart-size = calc.max(size, 2 * rim + 10pt)

  // Collect arc segments
  let segments = _collect-segments(
    data,
    start-angle.deg(),
    total-angle.deg() + start-angle.deg(),
    0,
    max-depth,
    0
  )

  // Resolve geometry and color once per visible segment, so the wedges and the
  // labels can be drawn in separate passes below. Segments too thin to see
  // are dropped here rather than in each pass.
  let visible = segments
    .filter(seg => seg.end-angle - seg.start-angle >= min-angle.deg())
    .map(seg => {
      let depth = seg.depth  // 1-based (1 = innermost ring)
      // Color: base color from palette, lighten for deeper levels
      let base-color = get-color(t, seg.color-index)
      (
        ..seg,
        span: seg.end-angle - seg.start-angle,
        mid: (seg.start-angle + seg.end-angle) / 2,
        r-inner: inner-radius + (depth - 1) * ring-width,
        r-outer: inner-radius + depth * ring-width,
        color: if depth == 1 {
          base-color
        } else if depth == 2 {
          base-color.lighten(25%)
        } else if depth == 3 {
          base-color.lighten(45%)
        } else {
          base-color.lighten(60%)
        },
      )
    })

  // Labels: inside when they fit, else (outermost ring only) outside
  let plan = {
    let inside = ()
    let outside = ()
    if show-labels {
      for seg in visible {
        let weight = if seg.depth == 1 { "bold" } else { "regular" }
        let ink = label-ink(seg.color, t)
        let make(sz) = text(size: sz, weight: weight, fill: ink, top-edge: "cap-height", bottom-edge: "descender")[#seg.name]
        let fit = fit-wedge-label(make, seg.mid, seg.span / 2, seg.r-inner, seg.r-outer, t.value-label-size, t.axis-label-size, rotate: true)
        // A sunburst has no legend to carry a name that does not fit, and
        // type below the theme's smallest is not read. A name of several words
        // that fits nowhere on one line is tried on two (still no smaller than
        // that); a name that fits nowhere goes outside, with a leader from
        // inside its segment unless it is on the outermost ring
        let body-of = make
        let lines = _two-lines(seg.name)
        if fit == none and lines != none {
          let make2(sz) = {
            set par(leading: 0.3em)
            text(size: sz, weight: weight, fill: ink, top-edge: "cap-height", bottom-edge: "descender")[#lines.at(0) #linebreak() #lines.at(1)]
          }
          fit = fit-wedge-label(make2, seg.mid, seg.span / 2, seg.r-inner, seg.r-outer, t.value-label-size, t.axis-label-size, rotate: true)
          body-of = make2
        }
        let outer = seg.r-outer >= rim - 0.01pt
        if fit != none {
          inside.push((seg: seg, fit: fit, body: body-of(fit.size)))
        } else {
          // Inner rings first when there is no room for everything
          outside.push((angle: seg.mid, priority: seg.span + 20 * (total-depth - seg.depth),
            from: if outer { none } else { (seg.r-inner + seg.r-outer) / 2 },
            body: text(size: t.axis-label-size, fill: t.text-color, top-edge: "cap-height", bottom-edge: "descender")[#seg.name]))
        }
      }
    }
    (inside: inside, outside: outside)
  }
  let ext = polar-label-extent(plan.outside, rim, gap: 4pt)
  let (box-w, box-h) = (calc.max(chart-size, 2 * ext.x), calc.max(chart-size, 2 * ext.y))
  let (cx, cy) = (box-w / 2, box-h / 2)

  align(center, chart-container(box-w, box-h, title, t)[
    #box(width: box-w, height: box-h)[
      // Wedges first: placed content paints in order, so every label ends up
      // above every wedge, not under the next ring out
      #for seg in visible {
        place-wedge(cx, cy, seg.r-inner, seg.r-outer, seg.start-angle, seg.end-angle, seg.color,
          stroke: separator-stroke(t, thickness: 0.75pt))
      }
      #for l in plan.inside {
        let (x, y) = (cx + l.fit.r * calc.cos(l.seg.mid * 1deg), cy + l.fit.r * calc.sin(l.seg.mid * 1deg))
        place-centred(x, y, l.fit.w, l.fit.h, l.body, rot: l.fit.rot)
      }
      #place-outside-labels(plan.outside, cx, cy, rim, (left: 0pt, right: box-w, top: 0pt, bottom: box-h),
        leader-stroke: 0.5pt + t.text-color-light)
    ]
  ])
  })
}
