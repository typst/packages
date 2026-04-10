#import "constants.typ": _light-gray
#import "utils.typ": _clamp, _round-scale

/// Normalizes gene dictionaries and applies defaults.
///
/// - genes (array): Array of gene dictionaries (strand may be 1, -1, "+", or "-").
/// - default-color (color): Default fill color for genes.
/// -> array
#let _normalize-genes(genes, default-color) = {
  let normalized = ()

  for gene in genes {
    assert(type(gene) == dictionary, message: "Each gene must be a dictionary")
    assert("start" in gene and "end" in gene, message: "Each gene must define start and end")

    let gene-start = calc.min(gene.start, gene.end)
    let gene-end = calc.max(gene.start, gene.end)
    let strand = if "strand" in gene { gene.strand } else { none }
    let normalized-strand = if strand == "+" { 1 } else if strand == "-" { -1 } else { strand }
    assert(
      normalized-strand in (1, -1, none),
      message: "strand must be 1, -1, '+', '-', or none",
    )

    let label = if "label" in gene { gene.label } else { none }
    let color = if "color" in gene and gene.color != none { gene.color } else { default-color }

    normalized.push((start: gene-start, end: gene-end, strand: normalized-strand, label: label, color: color))
  }

  normalized
}

/// Assigns labels to levels to avoid overlap.
///
/// Greedy first-fit dodging: labels are processed in order, placed into the
/// first level that has enough horizontal room, and new levels are created
/// as needed. Lower level indices are positioned closer to the gene track,
/// so this strategy keeps labels as close to the genes as possible while
/// still preventing overlaps.
///
/// - labels (array): Label dictionaries with computed positions.
/// - spacing (length): Minimum horizontal spacing between labels.
/// -> dictionary
#let _assign-label-levels(labels, spacing) = {
  let level-intervals = ()
  let assigned = ()

  for label in labels {
    let left = label.dodge-left
    let right = label.dodge-right
    let level = none

    for (idx, intervals) in level-intervals.enumerate() {
      // First level that fits keeps the label closest to the gene track.
      let overlaps = false
      for interval in intervals {
        if left < interval.right + spacing and right > interval.left - spacing {
          overlaps = true
          break
        }
      }
      if not overlaps {
        level = idx
        level-intervals.at(idx) = intervals + ((left: left, right: right),)
        break
      }
    }

    if level == none {
      level = level-intervals.len()
      level-intervals.push(((left: left, right: right),))
    }

    assigned.push((..label, level: level))
  }

  (labels: assigned, levels: level-intervals.len())
}

/// Draws a horizontal line segment.
///
/// - x (length): Starting x-position.
/// - y (length): Starting y-position.
/// - length (length): Segment length.
/// - stroke (stroke): Line stroke styling.
/// -> content
#let _draw-horizontal-segment(x, y, length, stroke) = {
  if length > 0pt {
    place(top + left, dx: x, dy: y, line(
      start: (0pt, 0pt),
      end: (length, 0pt),
      stroke: stroke,
    ))
  }
}

/// Draws a vertical line segment.
///
/// - x (length): Starting x-position.
/// - y (length): Starting y-position.
/// - length (length): Segment length.
/// - stroke (stroke): Line stroke styling.
/// -> content
#let _draw-vertical-segment(x, y, length, stroke) = {
  if length > 0pt {
    place(top + left, dx: x, dy: y, line(
      start: (0pt, 0pt),
      end: (0pt, length),
      stroke: stroke,
    ))
  }
}

/// Computes label layout and level positions.
///
/// - genes (array): Normalized gene dictionaries.
/// - region-start (float): Region start coordinate.
/// - region-length (float): Region length.
/// - track-width (length): Width of the genome track.
/// - label-size (length): Label font size.
/// - label-color (color): Label text color.
/// - label-horizontal-gap (length): Horizontal spacing between labels.
/// - label-vertical-gap (length): Vertical gap between label levels.
/// -> dictionary
#let _layout-labels(
  genes,
  region-start,
  region-length,
  track-width,
  label-size,
  label-color,
  label-horizontal-gap,
  label-vertical-gap,
) = {
  let label-height = measure(text("pjfI", size: label-size, bottom-edge: "descender")).height
  let label-data = ()

  for gene in genes {
    if gene.label != none {
      let center-bp = (gene.start + gene.end) / 2
      let gene-center = track-width * ((center-bp - region-start) / region-length)
      let gene-width = track-width * ((gene.end - gene.start) / region-length)
      let label-text = text(size: label-size, fill: label-color)[#gene.label]
      let label-width = measure(label-text).width
      let raw-left = gene-center - label-width / 2
      let max-left = track-width - label-width
      let left = if max-left < 0pt { 0pt } else { _clamp(raw-left, 0pt, max-left) }
      let right = left + label-width
      let text-center = left + label-width / 2
      let underline-width = calc.max(0.75pt, gene-width - 0.75pt)
      let underline-left = gene-center - underline-width / 2
      let underline-right = underline-left + underline-width
      let dodge-left = calc.min(left, underline-left)
      let dodge-right = calc.max(right, underline-right)
      label-data.push((
        center: text-center,
        left: left,
        right: right,
        dodge-left: dodge-left,
        dodge-right: dodge-right,
        underline-left: underline-left,
        underline-width: underline-width,
        gene-center: gene-center,
        width: label-width,
        gene-width: gene-width,
        text: label-text,
      ))
    }
  }

  // Prefer longer dodge spans closer to the track while keeping render order by center.
  let sorted-for-dodging = label-data.sorted(
    key: label => (-(label.dodge-right - label.dodge-left), label.center),
  )
  let label-layout = _assign-label-levels(sorted-for-dodging, label-horizontal-gap)
  let labels = label-layout.labels.sorted(key: label => label.center)
  let level-count = label-layout.levels
  let level-block-height = if level-count == 0 {
    0pt
  } else {
    level-count * label-height + (level-count - 1) * label-vertical-gap
  }
  let level-step = label-height + label-vertical-gap
  let level-base-top = level-block-height - label-height
  let positioned-labels = labels.map(label => {
    let top = level-base-top - label.level * level-step
    let bottom = top + label-height
    let underline-y = bottom + 0.5pt
    (
      ..label,
      top: top,
      bottom: bottom,
      underline-y: underline-y,
      underline-left: label.underline-left,
      underline-width: label.underline-width,
    )
  })

  (
    labels: positioned-labels,
    level-count: level-count,
    label-height: label-height,
    level-block-height: level-block-height,
  )
}

/// Draws gene arrows and blocks.
///
/// - genes (array): Normalized gene dictionaries.
/// - region-start (float): Region start coordinate.
/// - region-length (float): Region length.
/// - track-width (length): Width of the genome track.
/// - track-top (length): Top offset of the gene track.
/// - gene-height (length): Height of gene arrows/blocks.
/// - head-length (length, auto): Arrowhead length.
/// - min-head-length (length): Minimum arrowhead length.
/// - gene-stroke (stroke): Stroke styling for genes.
/// -> content
#let _draw-genes(
  genes,
  region-start,
  region-length,
  track-width,
  track-top,
  gene-height,
  head-length,
  min-head-length,
  gene-stroke,
) = {
  for gene in genes {
    let start-x = track-width * ((gene.start - region-start) / region-length)
    let end-x = track-width * ((gene.end - region-start) / region-length)
    let gene-width = end-x - start-x
    let base-head = if head-length == auto { gene-height * 0.35 } else { head-length }
    let head = calc.min(gene-width, calc.max(min-head-length, base-head))

    if gene.strand == 1 {
      if head >= gene-width {
        place(top + left, dx: start-x, dy: track-top, polygon(
          fill: gene.color,
          stroke: gene-stroke,
          (0pt, 0pt),
          (gene-width, gene-height / 2),
          (0pt, gene-height),
        ))
      } else {
        let body-width = gene-width - head
        place(top + left, dx: start-x, dy: track-top, polygon(
          fill: gene.color,
          stroke: gene-stroke,
          (0pt, 0pt),
          (body-width, 0pt),
          (gene-width, gene-height / 2),
          (body-width, gene-height),
          (0pt, gene-height),
        ))
      }
    } else if gene.strand == -1 {
      if head >= gene-width {
        place(top + left, dx: start-x, dy: track-top, polygon(
          fill: gene.color,
          stroke: gene-stroke,
          (gene-width, 0pt),
          (0pt, gene-height / 2),
          (gene-width, gene-height),
        ))
      } else {
        let body-width = gene-width - head
        place(top + left, dx: start-x, dy: track-top, polygon(
          fill: gene.color,
          stroke: gene-stroke,
          (gene-width, 0pt),
          (head, 0pt),
          (0pt, gene-height / 2),
          (head, gene-height),
          (gene-width, gene-height),
        ))
      }
    } else {
      place(top + left, dx: start-x, dy: track-top, polygon(
        fill: gene.color,
        stroke: gene-stroke,
        (0pt, 0pt),
        (gene-width, 0pt),
        (gene-width, gene-height),
        (0pt, gene-height),
      ))
    }
  }
}

/// Draws the scale bar and label.
///
/// - scale-bar (bool): Whether to draw the scale bar.
/// - scale-top (length): Top offset for the scale bar.
/// - scale-width (length): Scale bar width.
/// - scale-tick-height (length): Tick height.
/// - scale-label-gap (length): Gap between scale bar and label.
/// - scale-label-text (content): Label content.
/// - scale-label-width (length): Label width.
/// - scale-stroke (stroke): Stroke styling for scale bar.
/// -> content
#let _draw-scale-bar(
  scale-bar,
  scale-top,
  scale-width,
  scale-tick-height,
  scale-label-gap,
  scale-label-text,
  scale-label-width,
  scale-stroke,
) = {
  if scale-bar {
    // Draw the scale line centered on the tick height.
    _draw-horizontal-segment(0pt, scale-top + scale-tick-height / 2, scale-width, scale-stroke)
    _draw-vertical-segment(0pt, scale-top, scale-tick-height, scale-stroke)
    _draw-vertical-segment(scale-width, scale-top, scale-tick-height, scale-stroke)
    place(
      top + left,
      dx: scale-width / 2 - scale-label-width / 2,
      dy: scale-top + scale-tick-height + scale-label-gap,
      scale-label-text,
    )
  }
}

/// Draws the coordinate axis with ticks and labels.
///
/// - coordinate-axis (bool): Whether to draw the axis.
/// - region-start (float): Region start coordinate.
/// - region-end (float): Region end coordinate.
/// - region-length (float): Region length.
/// - track-width (length): Track width.
/// - axis-top (length): Axis top offset.
/// - tick-height (length): Tick height.
/// - label-gap (length): Gap between tick and label.
/// - label-size (length): Label font size.
/// - unit (str, none): Unit suffix.
/// - axis-color (color): Axis label color.
/// - axis-stroke (stroke): Stroke styling.
/// -> content
#let _draw-coordinate-axis(
  coordinate-axis,
  region-start,
  region-end,
  region-length,
  track-width,
  axis-top,
  tick-height,
  label-gap,
  label-size,
  unit,
  axis-color,
  axis-stroke,
) = {
  if coordinate-axis {
    let tick-step = _round-scale(region-length / 10)
    let first-tick = calc.ceil(region-start / tick-step) * tick-step
    let tick = first-tick

    _draw-horizontal-segment(0pt, axis-top, track-width, axis-stroke)

    while tick <= region-end {
      let x = track-width * ((tick - region-start) / region-length)
      let label-value = if tick >= 1 {
        int(calc.round(tick))
      } else {
        calc.round(tick, digits: 2)
      }
      let label = if unit == none {
        str(label-value)
      } else {
        str(label-value) + " " + unit
      }
      let label-text = text(size: label-size, fill: axis-color, bottom-edge: "descender")[#label]
      let label-width = measure(label-text).width
      _draw-vertical-segment(x, axis-top, tick-height, axis-stroke)
      place(
        top + left,
        // Keep the label centered but within track bounds.
        dx: _clamp(x - label-width / 2, 0pt, track-width - label-width),
        dy: axis-top + tick-height + label-gap,
        label-text,
      )

      tick += tick-step
    }
  }
}

/// Renders a genome map from an array of gene dictionaries.
///
/// Each gene dictionary in the input array can have the following fields:
/// - start (float): Gene start coordinate (required).
/// - end (float): Gene end coordinate (required).
/// - strand (int, str, none): Direction (1 or -1, "+" or "-"); none draws a block.
/// - label (content, none): Label text.
/// - color (color, none): Fill color (none uses default-color).
///
/// Parameters:
/// - genes (array): Gene dictionaries to render.
/// - width (length, fraction): Total map width (default: 100%).
/// - start (float, auto): Region start (default: auto).
/// - end (float, auto): Region end (default: auto).
/// - gene-height (length): Gene block height (default: 12pt).
/// - head-length (length, auto): Arrowhead length (default: auto).
/// - min-head-length (length): Minimum arrowhead length (default: 3.5pt).
/// - default-color (color): Default gene fill (default: light gray).
/// - gene-outline-color (color): Gene outline color (default: black).
/// - stroke-width (length): Stroke width for gene outlines, label leaders/underlines, and scale/axis lines (default: 0.7pt).
/// - label-size (length): Label font size (default: 0.8em).
/// - label-color (color): Label text color (default: black).
/// - label-horizontal-gap (length): Horizontal spacing between labels (default: 0.8pt).
/// - label-vertical-gap (length): Vertical gap between label levels (default: 0.8em).
/// - label-line-distance (length): Horizontal clearance for line gaps (default: 0.7pt).
/// - label-leader-offset (length): Gap between leader and gene block (default: 4pt).
/// - label-track-gap (length): Gap between labels and track (default: 4pt).
/// - scale-bar (bool): Show scale bar (default: false).
/// - scale-length (float, auto): Scale length (default: auto).
/// - unit (str, none): Unit suffix for scale bar and coordinate axis (default: none).
/// - coordinate-axis (bool): Show coordinate axis (default: false).
/// - coordinate-axis-track-gap (length): Gap between track and coordinate axis (default: 6pt).
/// - scale-track-gap (length): Gap between coordinate axis and scale bar (default: 6pt).
/// - tick-height (length): Tick height for scale bar and coordinate axis (default: 4.5pt).
/// -> content
#let render-genome-map(
  genes,
  width: 100%,
  start: auto,
  end: auto,
  gene-height: 12pt,
  head-length: auto,
  min-head-length: 3.5pt,
  default-color: _light-gray,
  gene-outline-color: black,
  stroke-width: 0.7pt,
  label-size: 0.8em,
  label-color: black,
  label-horizontal-gap: 0.8pt,
  label-vertical-gap: 0.8em,
  label-line-distance: 0.7pt,
  label-leader-offset: 4pt,
  label-track-gap: 4pt,
  scale-bar: false,
  scale-length: auto,
  unit: none,
  coordinate-axis: false,
  coordinate-axis-track-gap: 6pt,
  scale-track-gap: 6pt,
  tick-height: 4.5pt,
) = block(width: width)[
  #layout(size => context {
    assert(type(genes) == array, message: "genes must be an array")
    assert(genes.len() > 0, message: "genes cannot be empty")

    let normalized = _normalize-genes(genes, default-color)
    let region-start = if start == auto {
      calc.min(..normalized.map(gene => gene.start))
    } else {
      start
    }
    let region-end = if end == auto {
      calc.max(..normalized.map(gene => gene.end))
    } else {
      end
    }

    let region-length = region-end - region-start
    assert(region-length > 0, message: "region length must be positive")

    let track-width = size.width
    let scale-label-height = measure(text("pjfI", size: label-size, bottom-edge: "descender")).height
    let resolve-gap = gap => measure(box(width: gap)[]).width
    let label-vertical-gap = resolve-gap(label-vertical-gap)
    let label-line-distance = resolve-gap(label-line-distance)
    let coordinate-axis-label-gap = 2.5pt
    let scale-label-gap = 1.5pt

    let label-layout = _layout-labels(
      normalized,
      region-start,
      region-length,
      track-width,
      label-size,
      label-color,
      label-horizontal-gap,
      label-vertical-gap,
    )
    let positioned-labels = label-layout.labels
    let level-count = label-layout.level-count
    let label-height = label-layout.label-height
    let level-block-height = label-layout.level-block-height
    let label-line-clearance = label-height * 0.225

    let track-top = if level-count == 0 {
      0pt
    } else {
      level-block-height + label-track-gap
    }

    let track-bottom = track-top + gene-height

    let scale-length = if scale-bar {
      if scale-length == auto {
        _round-scale(region-length / 5)
      } else {
        scale-length
      }
    } else {
      0
    }

    let scale-label-value = if scale-length >= 1 {
      int(calc.round(scale-length))
    } else {
      calc.round(scale-length, digits: 2)
    }

    let scale-label = if unit == none {
      str(scale-label-value)
    } else {
      str(scale-label-value) + " " + unit
    }

    let scale-label-text = text(size: label-size, fill: black, bottom-edge: "descender")[#scale-label]
    let scale-label-width = measure(scale-label-text).width

    let scale-width = if scale-bar {
      track-width * (scale-length / region-length)
    } else {
      0pt
    }

    let coordinate-axis-height = if coordinate-axis {
      tick-height + coordinate-axis-label-gap + scale-label-height
    } else {
      0pt
    }
    let coordinate-axis-top = track-bottom + (if coordinate-axis { coordinate-axis-track-gap } else { 0pt })
    let scale-top = if scale-bar {
      (
        track-bottom
          + (
            if coordinate-axis {
              coordinate-axis-track-gap + coordinate-axis-height + scale-track-gap
            } else { scale-track-gap }
          )
      )
    } else { 0pt }
    let total-height = (
      track-bottom
        + (if coordinate-axis { coordinate-axis-track-gap + coordinate-axis-height } else { 0pt })
        + (if scale-bar { scale-track-gap + tick-height + scale-label-gap + scale-label-height } else { 0pt })
    )

    let gene-stroke = (paint: gene-outline-color, thickness: stroke-width, join: "miter")
    let label-stroke = (paint: label-color, thickness: stroke-width, cap: "round")
    let scale-stroke = (paint: black, thickness: stroke-width, cap: "round")

    block(width: size.width, height: total-height, breakable: false, {
      // Baseline through the middle of the gene track.
      _draw-horizontal-segment(0pt, track-top + gene-height / 2, track-width, gene-stroke)
      // Gene shapes
      _draw-genes(
        normalized,
        region-start,
        region-length,
        track-width,
        track-top,
        gene-height,
        head-length,
        min-head-length,
        gene-stroke,
      )

      // Labels and leader lines
      if positioned-labels.len() > 0 {
        for label in positioned-labels {
          let line-x = label.gene-center
          let line-top = label.underline-y
          let line-bottom = track-top - label-leader-offset

          _draw-horizontal-segment(
            label.underline-left,
            label.underline-y,
            label.underline-width,
            label-stroke,
          )

          if line-bottom > line-top {
            let intervals = ()
            for other in positioned-labels {
              let hit = line-x >= other.left - label-line-distance and line-x <= other.right + label-line-distance
              let overlap = other.bottom >= line-top and other.top <= line-bottom
              if hit and overlap {
                intervals.push((
                  start: other.top - label-line-clearance,
                  end: other.bottom + label-line-clearance,
                ))
              }
            }

            let sorted = intervals.sorted(key: it => it.start)
            let cursor = line-top
            for gap in sorted {
              let gap-start = _clamp(gap.start, line-top, line-bottom)
              let gap-end = _clamp(gap.end, line-top, line-bottom)
              if gap-start > cursor {
                _draw-vertical-segment(line-x, cursor, gap-start - cursor, label-stroke)
              }
              if gap-end > cursor {
                cursor = gap-end
              }
            }

            if cursor < line-bottom {
              _draw-vertical-segment(line-x, cursor, line-bottom - cursor, label-stroke)
            }
          }

          place(top + left, dx: label.left, dy: label.top, label.text)
        }
      }

      _draw-coordinate-axis(
        coordinate-axis,
        region-start,
        region-end,
        region-length,
        track-width,
        coordinate-axis-top,
        tick-height,
        coordinate-axis-label-gap,
        label-size,
        unit,
        black,
        scale-stroke,
      )

      // Scale bar
      _draw-scale-bar(
        scale-bar,
        scale-top,
        scale-width,
        tick-height,
        scale-label-gap,
        scale-label-text,
        scale-label-width,
        scale-stroke,
      )
    })
  })
]
