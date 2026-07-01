#import "../common/colors.typ": _light-gray
#import "../common/layout_math.typ": _clamp
#import "../common/axis_scale.typ": (
  _draw-coordinate-axis, _draw-horizontal-segment, _draw-scale-bar-row,
  _draw-vertical-segment,
)
#import "./genome_map_layout.typ": (
  _interval-geometry, _prepare-genome-map-layout,
)

/// Draws gene arrows and blocks.
///
/// - genes (array): Normalized gene dictionaries.
/// - region-start (int): Inclusive region start coordinate.
/// - x-scale (length): Rendered width per genomic position.
/// - track-top (length): Top offset of the gene track.
/// - gene-height (length): Height of gene arrows/blocks.
/// - head-length (length, auto): Arrowhead length.
/// - min-head-length (length): Minimum arrowhead length.
/// - gene-stroke (stroke): Stroke styling for genes.
/// -> content
#let _draw-genes(
  genes,
  region-start,
  x-scale,
  track-top,
  gene-height,
  head-length,
  min-head-length,
  gene-stroke,
) = {
  for gene in genes {
    let geometry = _interval-geometry(
      gene.start,
      gene.end,
      region-start,
      x-scale,
    )
    let start-x = geometry.start-x
    let gene-width = geometry.width
    let base-head = if head-length == auto { gene-height * 0.35 } else {
      head-length
    }
    let head = calc.min(gene-width, calc.max(min-head-length, base-head))

    let points = if gene.strand == 1 {
      if head >= gene-width {
        ((0pt, 0pt), (gene-width, gene-height / 2), (0pt, gene-height))
      } else {
        let body-width = gene-width - head
        (
          (0pt, 0pt),
          (body-width, 0pt),
          (gene-width, gene-height / 2),
          (body-width, gene-height),
          (0pt, gene-height),
        )
      }
    } else if gene.strand == -1 {
      if head >= gene-width {
        ((gene-width, 0pt), (0pt, gene-height / 2), (gene-width, gene-height))
      } else {
        let body-width = gene-width - head
        (
          (gene-width, 0pt),
          (head, 0pt),
          (0pt, gene-height / 2),
          (head, gene-height),
          (gene-width, gene-height),
        )
      }
    } else {
      (
        (0pt, 0pt),
        (gene-width, 0pt),
        (gene-width, gene-height),
        (0pt, gene-height),
      )
    }

    place(top + left, dx: start-x, dy: track-top, polygon(
      fill: gene.color,
      stroke: gene-stroke,
      ..points,
    ))
  }
}

/// Renders a genome map from an array of gene dictionaries.
///
/// Each gene dictionary in the input array can have the following fields:
/// - start (int): Gene start coordinate (required, 1-indexed inclusive).
/// - end (int): Gene end coordinate (required, 1-indexed inclusive).
/// - strand (int, str, none): Direction (1 or -1, "+" or "-"); none draws a block.
/// - label (content, none): Label text.
/// - color (color, none): Fill color (none uses default-color).
///
/// - genes (array): Gene dictionaries to render.
/// - width (length, auto, ratio, relative): Total map width (default: 100%).
/// - start (int, auto): 1-indexed inclusive region start coordinate (default: auto).
/// - end (int, auto): 1-indexed inclusive region end coordinate (default: auto).
/// - gene-height (length): Gene block height (default: 12pt).
/// - head-length (length, auto): Arrowhead length (default: auto).
/// - min-head-length (length): Minimum arrowhead length (default: 3.5pt).
/// - default-color (color): Default gene fill (default: light gray).
/// - gene-outline-color (color): Gene outline and label leader/underline color (default: black).
/// - label-color (color, none): Feature label color (default: none, inherits from the document).
/// - stroke-width (length): Stroke width for gene outlines, label leaders/underlines, and scale/axis lines (default: 0.75pt).
/// - label-size (length): Label font size (default: 0.8em).
/// - label-horizontal-gap (length): Horizontal spacing between labels (default: 0.8pt).
/// - label-vertical-gap (length): Vertical gap between label levels (default: 0.8em).
/// - label-line-distance (length): Horizontal clearance for line gaps (default: 0.7pt).
/// - label-leader-offset (length): Gap between leader and gene block (default: 4.5pt).
/// - label-track-gap (length): Gap between labels and track (default: 4.5pt).
/// - scale-bar (bool): Show scale bar (default: false).
/// - scale-length (auto, int, float): Scale length. Positive when specified (default: auto).
/// - min-auto-bar-width (length): Minimum auto-selected scale-bar width when space allows (default: 2.5em).
/// - unit (str, none): Unit suffix for scale bar and coordinate axis (default: none).
/// - coordinate-axis (bool): Show coordinate axis (default: false).
/// - coordinate-axis-track-gap (length): Gap between track and coordinate axis (default: 6pt).
/// - coordinate-axis-label-size (length): Coordinate-axis tick-label size (default: 0.8em).
/// - scale-bar-gap (length): Vertical gap above the scale bar (default: 6pt).
/// - scale-tick-height (length): Tick height for scale bar and coordinate axis (default: 4.25pt).
/// - scale-label-size (length): Scale-bar label size (default: 0.8em).
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
  label-color: none,
  stroke-width: 0.75pt,
  label-size: 0.8em,
  label-horizontal-gap: 0.8pt,
  label-vertical-gap: 0.8em,
  label-line-distance: 0.7pt,
  label-leader-offset: 4.5pt,
  label-track-gap: 4.5pt,
  scale-bar: false,
  scale-length: auto,
  min-auto-bar-width: 2.5em,
  unit: none,
  coordinate-axis: false,
  coordinate-axis-track-gap: 6pt,
  coordinate-axis-label-size: 0.8em,
  scale-bar-gap: 6pt,
  scale-tick-height: 4.25pt,
  scale-label-size: 0.8em,
) = block(width: width)[
  #layout(size => context {
    if coordinate-axis {
      assert(
        coordinate-axis-label-size > 0pt,
        message: "coordinate-axis-label-size must be positive.",
      )
    }
    if scale-bar {
      assert(
        scale-label-size > 0pt,
        message: "scale-label-size must be positive.",
      )
    }
    let prepared = _prepare-genome-map-layout(
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
      size,
    )

    let gene-stroke = (
      paint: gene-outline-color,
      thickness: stroke-width,
      join: "miter",
    )
    let label-stroke = (
      paint: gene-outline-color,
      thickness: stroke-width,
      cap: "round",
    )
    let scale-stroke = (paint: black, thickness: stroke-width, cap: "round")

    box(width: size.width, height: prepared.total-height, {
      // Baseline through the middle of the gene track.
      _draw-horizontal-segment(
        0pt,
        prepared.track-top + prepared.gene-height / 2,
        prepared.track-width,
        gene-stroke,
      )
      // Gene shapes
      _draw-genes(
        prepared.normalized,
        prepared.region-start,
        prepared.x-scale,
        prepared.track-top,
        prepared.gene-height,
        prepared.head-length,
        prepared.min-head-length,
        gene-stroke,
      )

      // Labels and leader lines
      if prepared.positioned-labels.len() > 0 {
        for label in prepared.positioned-labels {
          let line-x = label.gene-center
          let line-top = label.underline-y
          let line-bottom = prepared.track-top - prepared.label-leader-offset

          _draw-horizontal-segment(
            label.underline-left,
            label.underline-y,
            label.underline-width,
            label-stroke,
          )

          if line-bottom > line-top {
            let intervals = ()
            for other in prepared.positioned-labels {
              let hit = (
                line-x >= other.left - prepared.label-line-distance
                  and line-x <= other.right + prepared.label-line-distance
              )
              let overlap = (
                other.bottom >= line-top and other.top <= line-bottom
              )
              if hit and overlap {
                intervals.push((
                  start: other.top - prepared.label-line-clearance,
                  end: other.bottom + prepared.label-line-clearance,
                ))
              }
            }

            let sorted = intervals.sorted(key: it => it.start)
            let cursor = line-top
            for gap in sorted {
              let gap-start = _clamp(gap.start, line-top, line-bottom)
              let gap-end = _clamp(gap.end, line-top, line-bottom)
              if gap-start > cursor {
                _draw-vertical-segment(
                  line-x,
                  cursor,
                  gap-start - cursor,
                  label-stroke,
                )
              }
              if gap-end > cursor {
                cursor = gap-end
              }
            }

            if cursor < line-bottom {
              _draw-vertical-segment(
                line-x,
                cursor,
                line-bottom - cursor,
                label-stroke,
              )
            }
          }

          place(top + left, dx: label.left, dy: label.top, label.text)
        }
      }

      _draw-coordinate-axis(
        coordinate-axis,
        prepared.region-start,
        prepared.region-end,
        prepared.region-end - prepared.region-start,
        prepared.axis-width,
        prepared.coordinate-axis-top,
        prepared.scale-tick-height,
        prepared.coordinate-axis-label-gap,
        coordinate-axis-label-size,
        unit,
        none,
        scale-stroke,
        axis-left: prepared.axis-left,
      )

      // Scale bar
      if scale-bar {
        _draw-scale-bar-row(
          prepared.track-width,
          prepared.scale-top,
          0pt,
          prepared.scale-width,
          prepared.scale-tick-height,
          prepared.scale-label-gap,
          scale-label-size,
          none,
          prepared.scale-label,
          black,
          stroke-width,
        )
      }
    })
  })
]
