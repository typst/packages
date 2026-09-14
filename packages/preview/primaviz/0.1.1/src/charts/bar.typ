// bar.typ - Bar charts (simple, horizontal, grouped, stacked, grouped-stacked)
#import "../theme.typ": resolve-theme, get-color
#import "../util.typ": normalize-data
#import "../validate.typ": validate-simple-data, validate-series-data, validate-grouped-stacked-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": draw-axis-lines, draw-grid, draw-axis-titles
#import "../primitives/legend.typ": draw-legend, draw-legend-vertical
#import "../primitives/annotations.typ": draw-annotations

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
) = {
  validate-simple-data(data, "horizontal-bar-chart")
  let t = resolve-theme(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let max-val = calc.max(..values)
  if max-val == 0 { max-val = 1 }
  let n = values.len()

  let label-area = 80pt

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let chart-height = height - 10pt
    #let chart-width = width - label-area - 30pt

    #box(width: width, height: chart-height)[
      // Grid (no-op by default)
      #draw-grid(label-area, 0pt, chart-width, chart-height, t)

      // Y-axis
      #place(left + top, line(start: (label-area, 0pt), end: (label-area, chart-height), stroke: t.axis-stroke))
      // X-axis
      #place(left + bottom, line(start: (label-area, 0pt), end: (width - 10pt, 0pt), stroke: t.axis-stroke))

      #let spacing = chart-height / n
      #let actual-bar-height = spacing * bar-height

      #for (i, val) in values.enumerate() {
        let bar-w = (val / max-val) * chart-width
        let y-pos = i * spacing + (spacing - actual-bar-height) / 2

        // Bar
        place(
          left + top,
          dx: label-area,
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
            dx: label-area + bar-w + 5pt,
            dy: y-pos + actual-bar-height / 2 - 5pt,
            text(size: t.value-label-size, fill: t.text-color)[#val]
          )
        }

        // Y-axis label (category)
        place(
          left + top,
          dx: 5pt,
          dy: y-pos + actual-bar-height / 2 - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#labels.at(i)]
        )
      }

      // X-axis labels
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let x-val = calc.round(max-val * fraction, digits: 0)
        let x-pos = label-area + fraction * chart-width
        place(
          left + bottom,
          dx: x-pos - 10pt,
          dy: 8pt,
          text(size: t.axis-label-size, fill: t.text-color)[#x-val]
        )
      }

      // Axis titles
      #draw-axis-titles(x-label, y-label, label-area + chart-width / 2, chart-height / 2, t)
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
) = {
  validate-simple-data(data, "bar-chart")
  let t = resolve-theme(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let max-val = calc.max(..values)
  if max-val == 0 { max-val = 1 }
  let n = values.len()

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let chart-height = height - 20pt
    #let chart-width = width - 40pt

    #box(width: width, height: chart-height)[
      // Grid (no-op by default)
      #draw-grid(30pt, 0pt, chart-width + 10pt, chart-height, t)

      #place(left + top, line(start: (30pt, 0pt), end: (30pt, chart-height), stroke: t.axis-stroke))
      #place(left + bottom, line(start: (30pt, 0pt), end: (width, 0pt), stroke: t.axis-stroke))

      #for (i, val) in values.enumerate() {
        let bar-h = (val / max-val) * (chart-height - 10pt)
        let spacing = (chart-width) / n
        let actual-bar-width = spacing * bar-width
        let x-pos = 35pt + (i * spacing) + (spacing - actual-bar-width) / 2

        place(
          left + bottom,
          dx: x-pos,
          dy: 0pt,
          rect(
            width: actual-bar-width,
            height: bar-h,
            fill: get-color(t, i),
            stroke: none,
          )
        )

        if show-values {
          place(
            left + bottom,
            dx: x-pos + actual-bar-width / 2 - 8pt,
            dy: -bar-h - 12pt,
            text(size: t.value-label-size, fill: t.text-color)[#val]
          )
        }

        place(
          left + bottom,
          dx: x-pos + actual-bar-width / 2 - 15pt,
          dy: 12pt,
          text(size: t.axis-label-size, fill: t.text-color)[#labels.at(i)]
        )
      }

      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let y-val = calc.round(max-val * fraction, digits: 1)
        let y-pos = chart-height - fraction * (chart-height - 10pt)
        place(
          left + top,
          dx: 0pt,
          dy: y-pos - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#y-val]
        )
      }

      // Axis titles
      #draw-axis-titles(x-label, y-label, 30pt + chart-width / 2, chart-height / 2, t)

      // Annotations
      #draw-annotations(annotations, 35pt, 10pt, chart-width, chart-height - 10pt, -0.5, n - 0.5, 0, max-val, t)
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
) = {
  validate-series-data(data, "grouped-bar-chart")
  let t = resolve-theme(theme)
  let labels = data.labels
  let series = data.series
  let n-groups = labels.len()
  let n-series = series.len()

  let all-values = series.map(s => s.values).flatten()
  let max-val = calc.max(..all-values)
  if max-val == 0 { max-val = 1 }

  chart-container(width, height, title, t, extra-height: 50pt)[
    #let chart-height = height - 20pt
    #let chart-width = width - 50pt

    #box(width: width, height: chart-height)[
      // Grid (no-op by default)
      #draw-grid(40pt, 0pt, chart-width, chart-height, t)

      #place(left + top, line(start: (40pt, 0pt), end: (40pt, chart-height), stroke: t.axis-stroke))
      #place(left + bottom, line(start: (40pt, 0pt), end: (width, 0pt), stroke: t.axis-stroke))

      #let group-width = chart-width / n-groups
      #let bw = (group-width * 0.8) / n-series

      #for (gi, _) in labels.enumerate() {
        for (si, s) in series.enumerate() {
          let val = s.values.at(gi)
          let bar-h = (val / max-val) * (chart-height - 10pt)
          let x-pos = 45pt + gi * group-width + si * bw + (group-width * 0.1)

          place(
            left + bottom,
            dx: x-pos,
            rect(
              width: bw - 2pt,
              height: bar-h,
              fill: get-color(t, si),
              stroke: none,
            )
          )
        }

        let x-center = 45pt + gi * group-width + group-width / 2 - 15pt
        place(
          left + bottom,
          dx: x-center,
          dy: 12pt,
          text(size: t.axis-label-size, fill: t.text-color)[#labels.at(gi)]
        )
      }

      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let y-val = calc.round(max-val * fraction, digits: 1)
        let y-pos = chart-height - fraction * (chart-height - 10pt)
        place(
          left + top,
          dx: 5pt,
          dy: y-pos - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#y-val]
        )
      }

      // Axis titles
      #draw-axis-titles(x-label, y-label, 40pt + chart-width / 2, chart-height / 2, t)
    ]

    #if show-legend and t.legend-position != "none" {
      if t.legend-position == "right" {
        draw-legend-vertical(series.map(s => s.name), t)
      } else {
        draw-legend(series.map(s => s.name), t)
      }
    }
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
) = {
  validate-series-data(data, "stacked-bar-chart")
  let t = resolve-theme(theme)
  let labels = data.labels
  let series = data.series
  let n = labels.len()

  let totals = ()
  for i in array.range(n) {
    let total = series.map(s => s.values.at(i)).sum()
    totals.push(total)
  }
  let max-val = calc.max(..totals)
  if max-val == 0 { max-val = 1 }

  chart-container(width, height, title, t, extra-height: 50pt)[
    #let chart-height = height - 20pt
    #let chart-width = width - 50pt

    #box(width: width, height: chart-height)[
      // Grid (no-op by default)
      #draw-grid(40pt, 0pt, chart-width, chart-height, t)

      #place(left + top, line(start: (40pt, 0pt), end: (40pt, chart-height), stroke: t.axis-stroke))
      #place(left + bottom, line(start: (40pt, 0pt), end: (width, 0pt), stroke: t.axis-stroke))

      #let bar-spacing = chart-width / n
      #let bw = bar-spacing * 0.6

      #for (i, _) in labels.enumerate() {
        let x-pos = 45pt + i * bar-spacing + (bar-spacing - bw) / 2
        let y-offset = 0pt

        for (si, s) in series.enumerate() {
          let val = s.values.at(i)
          let bar-h = (val / max-val) * (chart-height - 10pt)

          place(
            left + bottom,
            dx: x-pos,
            dy: -y-offset,
            rect(
              width: bw,
              height: bar-h,
              fill: get-color(t, si),
              stroke: (if t.background != none { t.background } else { white }) + 0.5pt,
            )
          )

          y-offset = y-offset + bar-h
        }

        place(
          left + bottom,
          dx: x-pos + bw / 2 - 15pt,
          dy: 12pt,
          text(size: t.axis-label-size, fill: t.text-color)[#labels.at(i)]
        )
      }

      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let y-val = calc.round(max-val * fraction, digits: 1)
        let y-pos = chart-height - fraction * (chart-height - 10pt)
        place(
          left + top,
          dx: 5pt,
          dy: y-pos - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#y-val]
        )
      }

      // Axis titles
      #draw-axis-titles(x-label, y-label, 40pt + chart-width / 2, chart-height / 2, t)
    ]

    #if show-legend and t.legend-position != "none" {
      if t.legend-position == "right" {
        draw-legend-vertical(series.map(s => s.name), t)
      } else {
        draw-legend(series.map(s => s.name), t)
      }
    }
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
) = {
  validate-grouped-stacked-data(data, "grouped-stacked-bar-chart")
  let t = resolve-theme(theme)
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
  if max-val == 0 { max-val = 1 }

  chart-container(width, height, title, t, extra-height: 50pt)[
    #let chart-height = height - 20pt
    #let chart-width = width - 50pt

    #box(width: width, height: chart-height)[
      // Grid
      #draw-grid(40pt, 0pt, chart-width, chart-height, t)

      // Axes
      #place(left + top, line(start: (40pt, 0pt), end: (40pt, chart-height), stroke: t.axis-stroke))
      #place(left + bottom, line(start: (40pt, 0pt), end: (width, 0pt), stroke: t.axis-stroke))

      // Layout: each label gets a slot; inside each slot, groups sit side by side
      #let slot-width = chart-width / calc.max(n-labels, 1)
      #let group-bar-width = (slot-width * 0.85) / calc.max(n-groups, 1)

      #for li in array.range(n-labels) {
        let slot-x = 45pt + li * slot-width
        let group-start-x = slot-x + (slot-width * 0.075)

        for (gi, g) in groups.enumerate() {
          let bar-x = group-start-x + gi * group-bar-width
          let bw = group-bar-width - 2pt
          let y-offset = 0pt

          // Stack segments within this group bar
          for seg in g.segments {
            let val = seg.values.at(li)
            let bar-h = (val / max-val) * (chart-height - 10pt)
            let ci = seg-color-map.at(seg.name)

            place(
              left + bottom,
              dx: bar-x,
              dy: -y-offset,
              rect(
                width: bw,
                height: bar-h,
                fill: get-color(t, ci),
                stroke: (if t.background != none { t.background } else { white }) + 0.5pt,
              )
            )

            y-offset = y-offset + bar-h
          }
        }

        // X-axis label centered under the slot
        let x-center = slot-x + slot-width / 2 - 15pt
        place(
          left + bottom,
          dx: x-center,
          dy: 12pt,
          text(size: t.axis-label-size, fill: t.text-color)[#labels.at(li)]
        )
      }

      // Y-axis tick labels
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let y-val = calc.round(max-val * fraction, digits: 1)
        let y-pos = chart-height - fraction * (chart-height - 10pt)
        place(
          left + top,
          dx: 5pt,
          dy: y-pos - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#y-val]
        )
      }

      // Axis titles
      #draw-axis-titles(x-label, y-label, 40pt + chart-width / 2, chart-height / 2, t)

      // Annotations
      #draw-annotations(annotations, 45pt, 10pt, chart-width, chart-height - 10pt, -0.5, n-labels - 0.5, 0, max-val, t)
    ]

    // Legend shows segment names (consistent colors across groups)
    #if show-legend and t.legend-position != "none" {
      if t.legend-position == "right" {
        draw-legend-vertical(segment-names, t)
      } else {
        draw-legend(segment-names, t)
      }
    }
  ]
}
