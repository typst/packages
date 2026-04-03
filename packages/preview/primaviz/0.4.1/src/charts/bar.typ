// bar.typ - Bar charts (simple, horizontal, grouped, stacked, grouped-stacked)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data, nonzero, nice-ceil
#import "../validate.typ": validate-simple-data, validate-series-data, validate-grouped-stacked-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": cartesian-layout, draw-axis-lines, draw-grid, draw-axis-titles, draw-y-ticks, draw-x-ticks, draw-x-category-labels, draw-y-label
#import "../primitives/legend.typ": draw-legend-auto
#import "../primitives/annotations.typ": draw-annotations
#import "../primitives/polar.typ": separator-stroke

/// Renders a horizontal bar chart with category labels on the y-axis.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - bar-height (float): Bar thickness as fraction of slot (0 to 1)
/// - title (none, content): Optional chart title
/// - show-values (bool): Display value labels beside bars
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - theme (none, dictionary): Theme overrides
/// -> content
#let horizontal-bar-chart(
  data,
  width: 350pt,
  height: 200pt,
  bar-height: 0.6,
  title: none,
  show-values: true,
  x-label: none,
  y-label: none,
  theme: none,
) = context {
  validate-simple-data(data, "horizontal-bar-chart")
  let t = _resolve-ctx(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let max-val = nice-ceil(nonzero(calc.max(..values)))
  let n = values.len()

  let cl = cartesian-layout(width, height, t, extra-left: 40pt)

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y

    #box(width: width, height: height)[
      // Grid
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t)

      // X-axis ticks (numeric values along bottom)
      #draw-x-ticks(0, max-val, chart-width, origin-x, origin-y + 4pt, t, digits: 0)

      #let spacing = chart-height / n
      #let actual-bar-height = spacing * bar-height

      #for (i, val) in values.enumerate() {
        let bar-w = (val / max-val) * chart-width
        let y-pos = pad-top + i * spacing + (spacing - actual-bar-height) / 2

        // Bar
        place(
          left + top,
          dx: origin-x,
          dy: y-pos,
          rect(
            width: bar-w,
            height: actual-bar-height,
            fill: get-color(t, i),
            stroke: none,
          )
        )

        // Value label
        if show-values {
          place(
            left + top,
            dx: origin-x + bar-w + 5pt,
            dy: y-pos + actual-bar-height / 2,
            move(dy: -0.5em, text(size: t.value-label-size, fill: t.text-color)[#val])
          )
        }

        // Y-axis label (category) — right-aligned into the padding area
        draw-y-label(labels.at(i), y-pos + actual-bar-height / 2, origin-x, t)
      }

      // Axis titles
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, origin-y / 2, t)
    ]
  ]
}

/// Renders a vertical bar chart with one bar per category.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - bar-width (float): Bar width as fraction of slot (0 to 1)
/// - title (none, content): Optional chart title
/// - show-values (bool): Display value labels above bars
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// -> content
#let bar-chart(
  data,
  width: 300pt,
  height: 200pt,
  bar-width: 0.6,
  title: none,
  show-values: true,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
) = context {
  validate-simple-data(data, "bar-chart")
  let t = _resolve-ctx(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let max-val = nice-ceil(nonzero(calc.max(..values)))
  let n = values.len()

  let cl = cartesian-layout(width, height, t)

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y

    #box(width: width, height: height)[
      // Grid
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t)

      // Y-axis ticks
      #draw-y-ticks(0, max-val, chart-height, pad-top, origin-x, t)

      #let spacing = chart-width / n

      #for (i, val) in values.enumerate() {
        let bar-h = (val / max-val) * chart-height
        let actual-bar-width = spacing * bar-width
        let x-pos = origin-x + (i * spacing) + (spacing - actual-bar-width) / 2

        place(
          left + top,
          dx: x-pos,
          dy: origin-y - bar-h,
          rect(
            width: actual-bar-width,
            height: bar-h,
            fill: get-color(t, i),
            stroke: none,
          )
        )

        if show-values {
          place(
            left + top,
            dx: x-pos,
            dy: origin-y - bar-h - 1.2em,
            box(width: actual-bar-width,
              align(center, text(size: t.value-label-size, fill: t.text-color)[#val]))
          )
        }
      }

      // X-axis category labels
      #draw-x-category-labels(labels, origin-x, spacing, origin-y + 4pt, t)

      // Axis titles
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, origin-y / 2, t)

      // Annotations
      #draw-annotations(annotations, origin-x, pad-top, chart-width, chart-height, -0.5, n - 0.5, 0, max-val, t)
    ]
  ]
}

/// Renders a grouped bar chart with multiple series side by side.
///
/// - data (dictionary): Dict with `labels` and `series` (each with `name` and `values`)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-legend (bool): Show series legend
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - theme (none, dictionary): Theme overrides
/// -> content
#let grouped-bar-chart(
  data,
  width: 350pt,
  height: 200pt,
  title: none,
  show-legend: true,
  x-label: none,
  y-label: none,
  theme: none,
) = context {
  validate-series-data(data, "grouped-bar-chart")
  let t = _resolve-ctx(theme)
  let labels = data.labels
  let series = data.series
  let n-groups = labels.len()
  let n-series = series.len()

  let all-values = series.map(s => s.values).flatten()
  let max-val = nice-ceil(nonzero(calc.max(..all-values)))

  let cl = cartesian-layout(width, height, t)

  chart-container(width, height, title, t, extra-height: 50pt)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y

    #box(width: width, height: height)[
      // Grid
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t)

      // Y-axis ticks
      #draw-y-ticks(0, max-val, chart-height, pad-top, origin-x, t)

      #let group-width = chart-width / n-groups
      #let bw = (group-width * 0.8) / n-series

      #for (gi, _) in labels.enumerate() {
        for (si, s) in series.enumerate() {
          let val = s.values.at(gi)
          let bar-h = (val / max-val) * chart-height
          let x-pos = origin-x + gi * group-width + si * bw + (group-width * 0.1)

          place(
            left + top,
            dx: x-pos,
            dy: origin-y - bar-h,
            rect(
              width: bw - 2pt,
              height: bar-h,
              fill: get-color(t, si),
              stroke: none,
            )
          )
        }
      }

      // X-axis category labels
      #draw-x-category-labels(labels, origin-x, group-width, origin-y + 4pt, t)

      // Axis titles
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, origin-y / 2, t)
    ]

    #draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend)
  ]
}

/// Renders a stacked bar chart with series values stacked vertically.
///
/// - data (dictionary): Dict with `labels` and `series` (each with `name` and `values`)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-legend (bool): Show series legend
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - theme (none, dictionary): Theme overrides
/// -> content
#let stacked-bar-chart(
  data,
  width: 300pt,
  height: 200pt,
  title: none,
  show-legend: true,
  x-label: none,
  y-label: none,
  theme: none,
) = context {
  validate-series-data(data, "stacked-bar-chart")
  let t = _resolve-ctx(theme)
  let labels = data.labels
  let series = data.series
  let n = labels.len()

  let totals = ()
  for i in array.range(n) {
    let total = series.map(s => s.values.at(i)).sum()
    totals.push(total)
  }
  let max-val = nice-ceil(nonzero(calc.max(..totals)))

  let cl = cartesian-layout(width, height, t)

  chart-container(width, height, title, t, extra-height: 50pt)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y

    #box(width: width, height: height)[
      // Grid
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t)

      // Y-axis ticks
      #draw-y-ticks(0, max-val, chart-height, pad-top, origin-x, t)

      #let bar-spacing = chart-width / n
      #let bw = bar-spacing * 0.6

      #for (i, _) in labels.enumerate() {
        let x-pos = origin-x + i * bar-spacing + (bar-spacing - bw) / 2
        let y-offset = 0pt

        for (si, s) in series.enumerate() {
          let val = s.values.at(i)
          let bar-h = (val / max-val) * chart-height

          place(
            left + top,
            dx: x-pos,
            dy: origin-y - y-offset - bar-h,
            rect(
              width: bw,
              height: bar-h,
              fill: get-color(t, si),
              stroke: separator-stroke(t, thickness: 0.5pt),
            )
          )

          y-offset = y-offset + bar-h
        }
      }

      // X-axis category labels
      #draw-x-category-labels(labels, origin-x, bar-spacing, origin-y + 4pt, t)

      // Axis titles
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, origin-y / 2, t)
    ]

    #draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend)
  ]
}

/// Renders a grouped-stacked bar chart combining side-by-side groups with
/// stacked segments within each group.
///
/// - data (dictionary): Dict with `labels` (x-axis categories) and `groups`
///   (array of dicts each with `name` and `segments`, where each segment has
///   `name` and `values`)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-legend (bool): Show segment legend
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// -> content
#let grouped-stacked-bar-chart(
  data,
  width: 400pt,
  height: 250pt,
  title: none,
  show-legend: true,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
) = context {
  validate-grouped-stacked-data(data, "grouped-stacked-bar-chart")
  let t = _resolve-ctx(theme)
  let labels = data.labels
  let groups = data.groups
  let n-labels = labels.len()
  let n-groups = groups.len()

  // Guard: nothing to draw
  if n-labels == 0 or n-groups == 0 { return }

  // Collect unique segment names (preserving first-seen order) for legend & colors
  let segment-names = ()
  for g in groups {
    for seg in g.segments {
      if seg.name not in segment-names {
        segment-names.push(seg.name)
      }
    }
  }

  // Build a mapping from segment name -> color index
  let seg-color-map = (:)
  for (i, name) in segment-names.enumerate() {
    seg-color-map.insert(name, i)
  }

  // Compute the max stacked total across all (label, group) pairs
  let max-val = 0
  for li in array.range(n-labels) {
    for g in groups {
      let total = g.segments.map(seg => seg.values.at(li)).sum()
      if total > max-val { max-val = total }
    }
  }
  let max-val = nice-ceil(nonzero(max-val))

  let cl = cartesian-layout(width, height, t)

  chart-container(width, height, title, t, extra-height: 50pt)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y

    #box(width: width, height: height)[
      // Grid
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t)

      // Y-axis ticks
      #draw-y-ticks(0, max-val, chart-height, pad-top, origin-x, t)

      // Layout: each label gets a slot; inside each slot, groups sit side by side
      #let slot-width = chart-width / calc.max(n-labels, 1)
      #let group-bar-width = (slot-width * 0.85) / calc.max(n-groups, 1)

      #for li in array.range(n-labels) {
        let slot-x = origin-x + li * slot-width
        let group-start-x = slot-x + (slot-width * 0.075)

        for (gi, g) in groups.enumerate() {
          let bar-x = group-start-x + gi * group-bar-width
          let bw = group-bar-width - 2pt
          let y-offset = 0pt

          // Stack segments within this group bar
          for seg in g.segments {
            let val = seg.values.at(li)
            let bar-h = (val / max-val) * chart-height
            let ci = seg-color-map.at(seg.name)

            place(
              left + top,
              dx: bar-x,
              dy: origin-y - y-offset - bar-h,
              rect(
                width: bw,
                height: bar-h,
                fill: get-color(t, ci),
                stroke: separator-stroke(t, thickness: 0.5pt),
              )
            )

            y-offset = y-offset + bar-h
          }
        }
      }

      // X-axis category labels
      #draw-x-category-labels(labels, origin-x, slot-width, origin-y + 4pt, t)

      // Axis titles
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, origin-y / 2, t)

      // Annotations
      #draw-annotations(annotations, origin-x, pad-top, chart-width, chart-height, -0.5, n-labels - 0.5, 0, max-val, t)
    ]

    // Legend shows segment names (consistent colors across groups)
    #draw-legend-auto(segment-names, t, show-legend: show-legend)
  ]
}
