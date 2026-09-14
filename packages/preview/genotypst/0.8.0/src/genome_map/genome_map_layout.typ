#import "../common/layout_math.typ": _clamp, _resolve-length
#import "../common/interval.typ": (
  _validate-interval, _validate-optional-int-at-least,
)
#import "../common/axis_scale.typ": (
  _format-scale-label, _make-axis-scale-label, _resolve-scale-bar-length,
)

/// Returns the inclusive span between two 1-indexed coordinates.
///
/// - start (int): Inclusive start coordinate.
/// - end (int): Inclusive end coordinate.
/// -> int
#let _inclusive-span(start, end) = end - start + 1

/// Maps an inclusive genomic coordinate to the left edge of its rendered span.
///
/// - coord (int): Inclusive genomic coordinate.
/// - region-start (int): Inclusive region start coordinate.
/// - x-scale (length): Rendered width per genomic position.
/// -> length
#let _coord-to-x(coord, region-start, x-scale) = (
  (coord - region-start) * x-scale
)

/// Resolves rendered geometry for an inclusive genomic interval.
///
/// - start (int): Inclusive interval start coordinate.
/// - end (int): Inclusive interval end coordinate.
/// - region-start (int): Inclusive region start coordinate.
/// - x-scale (length): Rendered width per genomic position.
/// -> dictionary
#let _interval-geometry(start, end, region-start, x-scale) = {
  let start-x = _coord-to-x(start, region-start, x-scale)
  let width = _inclusive-span(start, end) * x-scale
  (start-x: start-x, width: width, center-x: start-x + width / 2)
}

/// Normalizes gene dictionaries and applies defaults.
///
/// - genes (array): Array of gene dictionaries (strand may be 1, -1, "+", or "-").
/// - default-color (color): Default fill color for genes.
/// -> array
#let _normalize-genes(genes, default-color) = {
  let normalized = ()

  for gene in genes {
    assert(type(gene) == dictionary, message: "each gene must be a dictionary.")
    assert(
      "start" in gene and "end" in gene,
      message: "each gene must define start and end.",
    )
    assert(gene.start != none, message: "gene.start must be an integer >= 1.")
    assert(gene.end != none, message: "gene.end must be an integer >= 1.")
    _validate-optional-int-at-least(gene.start, "gene.start", 1)
    _validate-optional-int-at-least(gene.end, "gene.end", 1)

    let gene-start = calc.min(gene.start, gene.end)
    let gene-end = calc.max(gene.start, gene.end)
    let strand = gene.at("strand", default: none)
    let normalized-strand = if strand == "+" { 1 } else if strand == "-" {
      -1
    } else { strand }
    assert(
      normalized-strand in (1, -1, none),
      message: "strand must be 1, -1, '+', '-', or none.",
    )

    let label = gene.at("label", default: none)
    let raw-color = gene.at("color", default: none)
    let color = if raw-color != none { raw-color } else { default-color }

    normalized.push((
      start: gene-start,
      end: gene-end,
      strand: normalized-strand,
      label: label,
      color: color,
    ))
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

/// Computes label layout and level positions.
///
/// - genes (array): Normalized gene dictionaries.
/// - region-start (int): Inclusive region start coordinate.
/// - x-scale (length): Rendered width per genomic position.
/// - track-width (length): Width of the genome track.
/// - label-color (color, none): Feature label color.
/// - label-size (length): Label font size.
/// - label-horizontal-gap (length): Horizontal spacing between labels.
/// - label-vertical-gap (length): Vertical gap between label levels.
/// -> dictionary
#let _layout-labels(
  genes,
  region-start,
  x-scale,
  track-width,
  label-color,
  label-size,
  label-horizontal-gap,
  label-vertical-gap,
) = {
  let label-height = measure(text(
    "pjfI",
    size: label-size,
    bottom-edge: "bounds",
  )).height
  let label-data = ()

  for gene in genes {
    if gene.label != none {
      let geometry = _interval-geometry(
        gene.start,
        gene.end,
        region-start,
        x-scale,
      )
      let gene-center = geometry.center-x
      let gene-width = geometry.width
      let label-text = text(
        size: label-size,
        ..if label-color != none { (fill: label-color) },
      )[#gene.label]
      let label-width = measure(label-text).width
      let raw-left = gene-center - label-width / 2
      let max-left = track-width - label-width
      let left = if max-left < 0pt { 0pt } else {
        _clamp(raw-left, 0pt, max-left)
      }
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
  let label-layout = _assign-label-levels(
    sorted-for-dodging,
    label-horizontal-gap,
  )
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
    let underline-y = bottom + label-height * 0.14
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

/// Resolves normalized data and derived geometry for `render-genome-map`.
///
/// - genes (array): Gene dictionaries to render.
/// - start (int, auto): 1-indexed inclusive region start coordinate.
/// - end (int, auto): 1-indexed inclusive region end coordinate.
/// - default-color (color): Default fill color for genes.
/// - label-color (color, none): Feature label color.
/// - label-size (length): Label font size.
/// - label-horizontal-gap (length): Horizontal spacing between labels.
/// - label-vertical-gap (length): Vertical gap between label levels.
/// - label-line-distance (length): Horizontal clearance for line gaps.
/// - label-leader-offset (length): Gap between leader and gene block.
/// - label-track-gap (length): Gap between labels and track.
/// - scale-bar (bool): Whether to draw a scale bar.
/// - scale-length (auto, int, float): Requested scale-bar length. Positive when not auto.
/// - min-auto-bar-width (length): Minimum rendered width used in auto mode.
/// - unit (str, none): Optional unit suffix.
/// - coordinate-axis (bool): Whether to draw the coordinate axis.
/// - coordinate-axis-track-gap (length): Gap between track and coordinate axis.
/// - coordinate-axis-label-size (length): Coordinate-axis tick-label size.
/// - scale-bar-gap (length): Vertical gap above the scale bar.
/// - scale-tick-height (length): Tick height.
/// - scale-label-size (length): Scale-bar label size.
/// - gene-height (length): Gene block height.
/// - head-length (length, auto): Arrowhead length.
/// - min-head-length (length): Minimum arrowhead length.
/// - layout-size (dictionary): Layout callback size.
/// -> dictionary
#let _prepare-genome-map-layout(
  genes,
  start,
  end,
  default-color,
  label-color,
  label-size,
  label-horizontal-gap,
  label-vertical-gap,
  label-line-distance,
  label-leader-offset,
  label-track-gap,
  scale-bar,
  scale-length,
  min-auto-bar-width,
  unit,
  coordinate-axis,
  coordinate-axis-track-gap,
  coordinate-axis-label-size,
  scale-bar-gap,
  scale-tick-height,
  scale-label-size,
  gene-height,
  head-length,
  min-head-length,
  layout-size,
) = {
  assert(type(genes) == array, message: "genes must be an array.")
  assert(genes.len() > 0, message: "genes cannot be empty.")
  assert(
    start != none,
    message: "start must be auto or an integer >= 1.",
  )
  assert(
    end != none,
    message: "end must be auto or an integer >= 1.",
  )

  let region-start-input = if start == auto { none } else { start }
  let region-end-input = if end == auto { none } else { end }
  _validate-interval(region-start-input, region-end-input, min: 1)

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

  let region-span = _inclusive-span(region-start, region-end)
  assert(region-span >= 1, message: "region span must be at least 1 bp.")

  let track-width = layout-size.width
  // Resolve relative lengths to absolute values for layout comparisons.
  let label-horizontal-gap = _resolve-length(label-horizontal-gap)
  let label-vertical-gap = _resolve-length(label-vertical-gap)
  let label-line-distance = _resolve-length(label-line-distance)
  let label-track-gap = _resolve-length(label-track-gap)
  let label-leader-offset = _resolve-length(label-leader-offset)
  let scale-tick-height = _resolve-length(scale-tick-height)
  let gene-height = _resolve-length(gene-height)
  let min-head-length = _resolve-length(min-head-length)
  let head-length = if head-length == auto { auto } else {
    _resolve-length(head-length)
  }
  let coordinate-axis-label-gap = 2.5pt
  let scale-label-gap = 1.5pt
  let x-scale = track-width / region-span

  let label-layout = _layout-labels(
    normalized,
    region-start,
    x-scale,
    track-width,
    label-color,
    label-size,
    label-horizontal-gap,
    label-vertical-gap,
  )
  let positioned-labels = label-layout.labels
  let label-line-clearance = label-layout.label-height * 0.25

  let track-top = if label-layout.level-count == 0 {
    0pt
  } else {
    label-layout.level-block-height + label-track-gap
  }
  let track-bottom = track-top + gene-height

  let resolved-scale = if scale-bar {
    _resolve-scale-bar-length(
      scale-length,
      region-span,
      x-scale,
      track-width,
      min-auto-bar-width: min-auto-bar-width,
      zero-length-message: "region span must be at least 1 bp",
    )
  } else {
    (length: 0, width: 0pt)
  }

  let scale-label = if scale-bar {
    _format-scale-label(resolved-scale.length, unit)
  } else {
    none
  }

  let scale-label-height = if scale-label == none {
    0pt
  } else {
    measure(_make-axis-scale-label(scale-label, scale-label-size)).height
  }

  let axis-label-height = if coordinate-axis {
    let axis-start-label = _make-axis-scale-label(
      _format-scale-label(region-start, unit),
      coordinate-axis-label-size,
    )
    let axis-end-label = _make-axis-scale-label(
      _format-scale-label(region-end, unit),
      coordinate-axis-label-size,
    )
    calc.max(
      measure(axis-start-label).height,
      measure(axis-end-label).height,
    )
  } else {
    0pt
  }

  let coordinate-axis-height = if coordinate-axis {
    scale-tick-height + coordinate-axis-label-gap + axis-label-height
  } else {
    0pt
  }
  let axis-left = x-scale / 2
  let axis-width = track-width - x-scale
  let axis-gap = if coordinate-axis { coordinate-axis-track-gap } else { 0pt }
  let coordinate-axis-top = track-bottom + axis-gap
  let scale-top = if scale-bar {
    track-bottom + axis-gap + coordinate-axis-height + scale-bar-gap
  } else {
    0pt
  }
  let total-height = (
    track-bottom
      + axis-gap
      + coordinate-axis-height
      + (
        if scale-bar {
          (
            scale-bar-gap
              + scale-tick-height
              + scale-label-gap
              + scale-label-height
          )
        } else { 0pt }
      )
  )

  (
    normalized: normalized,
    region-start: region-start,
    region-end: region-end,
    track-width: track-width,
    x-scale: x-scale,
    positioned-labels: positioned-labels,
    label-line-clearance: label-line-clearance,
    label-line-distance: label-line-distance,
    label-leader-offset: label-leader-offset,
    track-top: track-top,
    coordinate-axis-top: coordinate-axis-top,
    axis-width: axis-width,
    axis-left: axis-left,
    scale-top: scale-top,
    scale-width: resolved-scale.width,
    scale-label: scale-label,
    total-height: total-height,
    coordinate-axis-label-gap: coordinate-axis-label-gap,
    scale-label-gap: scale-label-gap,
    scale-tick-height: scale-tick-height,
    gene-height: gene-height,
    head-length: head-length,
    min-head-length: min-head-length,
  )
}
