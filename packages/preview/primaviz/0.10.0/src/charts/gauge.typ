// gauge.typ - Gauge/dial and progress indicators
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero, clamp
#import "../validate.typ": validate-number, validate-simple-data
#import "../primitives/container.typ": chart-container
#import "../primitives/polar.typ": pie-slice-points, place-donut-hole
#import "../primitives/layout.typ": font-for-space, resolve-size

/// Renders a semicircular gauge/dial chart with a needle indicator.
///
/// - value (int, float): Current value to display on the gauge
/// - min-val (int, float): Minimum scale value
/// - max-val (int, float): Maximum scale value
/// - size (length): Diameter of the gauge
/// - title (none, content): Optional chart title
/// - label (none, content): Descriptive label below the value
/// - show-value (bool): Display the numeric value in the center
/// - segments (none, array): Array of `(threshold, color)` pairs for colored arc segments
/// - needle-color (auto, color): Color of the needle and center cap
/// - theme (none, dictionary): Theme overrides
/// -> content
#let gauge-chart(
  value,
  min-val: 0,
  max-val: 100,
  size: 150pt,
  title: none,
  label: none,
  show-value: true,
  segments: none,
  needle-color: auto,
  theme: none,
) = context {
  layout(avail => {
  validate-number(value, "gauge-chart")
  let t = _resolve-ctx(theme)
  let size = resolve-size(size, size, avail).width
  let needle-color = if needle-color == auto { t.text-color } else { needle-color }
  let margin = calc.max(3pt, size * 0.07)
  let radius = size / 2 - margin
  let cx = size / 2
  let cy = size / 2 + margin

  let val-range = nonzero(max-val - min-val)
  let normalized = (value - min-val) / val-range
  normalized = clamp(normalized, 0, 1)

  // Angle: -180deg (left) to 0deg (right)
  let needle-angle = -180deg + normalized * 180deg

  let value-size-est = calc.max(5pt, size * 0.07)
  let sub-label-est = calc.max(5pt, size * 0.05)
  let extra-height = calc.max(10pt, value-size-est + sub-label-est + 15pt)
  chart-container(size, size / 2 + margin + 5pt, title, t, extra-height: extra-height)[
    #box(width: size, height: size / 2 + margin + extra-height)[
      // Draw segments or default arc
      #if segments != none {
        let prev-threshold = min-val
        for (i, seg) in segments.enumerate() {
          let threshold = seg.at(0)
          let seg-color = seg.at(1)

          let start-norm = (prev-threshold - min-val) / val-range
          let end-norm = (threshold - min-val) / val-range
          let start-deg = -180 + start-norm * 180
          let end-deg = -180 + end-norm * 180

          let pts = pie-slice-points(cx, cy, radius, start-deg, end-deg)
          place(left + top, polygon(fill: seg-color, stroke: t.marker-stroke, ..pts))

          prev-threshold = threshold
        }
      } else {
        // Default gradient arc (36 slices with color gradient)
        for i in array.range(36) {
          let start-deg = -180 + (i / 36) * 180
          let end-deg = -180 + ((i + 1) / 36) * 180

          let seg-progress = i / 36
          let gauge-low = if "gauge-low-color" in t { t.gauge-low-color } else { get-color(t, 4) }
          let gauge-mid = if "gauge-mid-color" in t { t.gauge-mid-color } else { get-color(t, 5) }
          let gauge-high = if "gauge-high-color" in t { t.gauge-high-color } else { get-color(t, 2) }
          let seg-color = if seg-progress < 0.5 {
            color.mix((gauge-low, 100% - seg-progress * 200%), (gauge-mid, seg-progress * 200%))
          } else {
            color.mix((gauge-mid, 100% - (seg-progress - 0.5) * 200%), (gauge-high, (seg-progress - 0.5) * 200%))
          }

          let pts = pie-slice-points(cx, cy, radius, start-deg, end-deg)
          place(left + top, polygon(fill: seg-color, stroke: none, ..pts))
        }
      }

      // Inner circle (donut effect)
      #let inner-radius = radius * 0.6
      #place-donut-hole(cx, cy, inner-radius, t)

      // Needle — scale thickness with chart size
      #let needle-len = radius * 0.85
      #let needle-end-x = cx + needle-len * calc.cos(needle-angle)
      #let needle-end-y = cy + needle-len * calc.sin(needle-angle)
      #let needle-w = calc.max(1pt, size * 0.016)

      #place(
        left + top,
        line(
          start: (cx, cy),
          end: (needle-end-x, needle-end-y),
          stroke: needle-color + needle-w
        )
      )

      // Center cap — scale with chart size
      #let cap-r = calc.max(2pt, size * 0.04)
      #place(
        left + top,
        dx: cx - cap-r,
        dy: cy - cap-r,
        circle(radius: cap-r, fill: needle-color, stroke: t.marker-stroke)
      )

      // Min/max labels — scale font with chart size
      #let scale-label-size = font-for-space(size, t.axis-label-size, min-size: 5pt, ratio: 0.07)
      #place(left + top, dx: cx - radius, dy: cy + 0.3em,
        move(dx: -1em, text(size: scale-label-size, fill: t.text-color)[#min-val]))
      #place(left + top, dx: cx + radius, dy: cy + 0.3em,
        text(size: scale-label-size, fill: t.text-color)[#max-val])

      // Value display — below the semicircle, in the open space
      #let value-size = font-for-space(size, 14pt, min-size: 7pt, ratio: 0.15)
      #if show-value {
        place(
          left + top,
          dx: cx - size * 0.2,
          dy: cy + cap-r + 2pt,
          box(width: size * 0.4, align(center,
            text(size: value-size, weight: "bold", fill: t.text-color)[#calc.round(value, digits: 1)]))
        )
      }

      // Label below value
      #let sub-label-size = font-for-space(size, t.value-label-size, min-size: 5pt, ratio: 0.06)
      #if label != none {
        place(
          left + top,
          dx: cx - size * 0.3,
          dy: cy + cap-r + value-size + 4pt,
          box(width: size * 0.6, align(center,
            text(size: sub-label-size, fill: t.text-color-light)[#label]))
        )
      }
    ]
  ]
  })
}

/// Renders a horizontal progress bar.
///
/// - value (int, float): Current progress value
/// - max-val (int, float): Maximum value (100% fill)
/// - width (length): Bar width
/// - height (length): Bar height
/// - title (none, content): Optional label above the bar
/// - show-value (bool): Display percentage text on the bar
/// - color (none, color): Override fill color
/// - background (color): Track background color
/// - rounded (bool): Use rounded ends
/// - theme (none, dictionary): Theme overrides
/// -> content
#let progress-bar(
  value,
  max-val: 100,
  width: 200pt,
  height: 20pt,
  title: none,
  show-value: true,
  color: none,
  background: auto,
  rounded: true,
  theme: none,
) = context {
  layout(size => {
  validate-number(value, "progress-bar")
  let t = _resolve-ctx(theme)
  let (width, height) = resolve-size(width, height, size, container: false)
  let progress = clamp(value / max-val, 0, 1)
  let bar-color = if color != none { color } else { get-color(t, 0) }
  let background = if background != auto { background } else if t.background != none { t.background.lighten(20%) } else { luma(230) }
  let radius = if rounded { height / 2 } else { 0pt }

  box(width: width, height: height + (if title != none { 20pt } else { 0pt }))[
    #if title != none {
      text(size: t.value-label-size, fill: t.text-color)[#title]
      v(3pt)
    }

    #box(width: width, height: height)[
      // Background
      #place(
        left + top,
        rect(
          width: width,
          height: height,
          fill: background,
          radius: radius,
        )
      )

      // Progress fill
      #if progress > 0 {
        place(
          left + top,
          rect(
            width: width * progress,
            height: height,
            fill: bar-color,
            radius: radius,
          )
        )
      }

      // Value label — centered in bar
      #if show-value {
        place(center + horizon,
          text(size: t.value-label-size, weight: "bold", fill: if progress > 0.5 { t.text-color-inverse } else { t.text-color })[
            #calc.round(progress * 100, digits: 0)%
          ]
        )
      }
    ]
  ]
  })
}

/// Renders a circular progress ring indicator.
///
/// - value (int, float): Current progress value
/// - max-val (int, float): Maximum value (100% fill)
/// - size (length): Outer diameter of the ring
/// - title (none, content): Optional label above the ring
/// - show-value (bool): Display percentage text in the center
/// - stroke-width (length): Thickness of the ring stroke
/// - color (none, color): Override ring color
/// - background (color): Track background color
/// - theme (none, dictionary): Theme overrides
/// -> content
#let circular-progress(
  value,
  max-val: 100,
  size: 80pt,
  title: none,
  show-value: true,
  stroke-width: 8pt,
  color: none,
  background: auto,
  theme: none,
) = context {
  layout(avail => {
  validate-number(value, "circular-progress")
  let t = _resolve-ctx(theme)
  let size = resolve-size(size, size, avail, container: false).width
  let progress = clamp(value / max-val, 0, 1)
  let bar-color = if color != none { color } else { get-color(t, 0) }
  let background = if background != auto { background } else if t.background != none { t.background.lighten(20%) } else { luma(230) }
  let radius = size / 2 - stroke-width / 2
  let cx = size / 2
  let cy = size / 2

  box(width: size, height: size + (if title != none { 25pt } else { 0pt }))[
    #if title != none {
      align(center, text(size: t.value-label-size, fill: t.text-color)[#title])
      v(3pt)
    }

    #box(width: size, height: size)[
      // Background circle
      #place(
        left + top,
        dx: stroke-width / 2,
        dy: stroke-width / 2,
        circle(
          radius: radius,
          fill: none,
          stroke: background + stroke-width
        )
      )

      // Progress arc (approximated with line segments)
      #if progress > 0 {
        let n-segments = calc.max(int(progress * 60), 1)
        let end-angle = -90deg + progress * 360deg

        for i in array.range(n-segments) {
          let a1 = -90deg + (i / n-segments) * progress * 360deg
          let a2 = -90deg + ((i + 1) / n-segments) * progress * 360deg

          let x1 = cx + radius * calc.cos(a1)
          let y1 = cy + radius * calc.sin(a1)
          let x2 = cx + radius * calc.cos(a2)
          let y2 = cy + radius * calc.sin(a2)

          place(
            left + top,
            line(
              start: (x1, y1),
              end: (x2, y2),
              stroke: bar-color + stroke-width
            )
          )
        }

        // Round end cap
        let end-x = cx + radius * calc.cos(end-angle)
        let end-y = cy + radius * calc.sin(end-angle)
        place(
          left + top,
          dx: end-x - stroke-width / 2,
          dy: end-y - stroke-width / 2,
          circle(radius: stroke-width / 2, fill: bar-color, stroke: none)
        )

        // Round start cap
        place(
          left + top,
          dx: cx - stroke-width / 2,
          dy: cy - radius - stroke-width / 2,
          circle(radius: stroke-width / 2, fill: bar-color, stroke: none)
        )
      }

      // Center value — centered in ring
      #if show-value {
        place(center + horizon,
          text(size: t.value-label-size, weight: "bold", fill: t.text-color)[#calc.round(progress * 100, digits: 0)%]
        )
      }
    ]
  ]
  })
}

/// Renders multiple labeled progress bars for comparing values.
///
/// - data (dictionary): Dict with `labels` and `values` arrays
/// - width (length): Overall width
/// - bar-height (length): Height of each bar
/// - title (none, content): Optional title above the bars
/// - show-values (bool): Display numeric values beside bars
/// - max-val (auto, int, float): Maximum scale value; `auto` uses the data maximum
/// - background (color): Track background color
/// - theme (none, dictionary): Theme overrides
/// -> content
#let progress-bars(
  data,
  width: 250pt,
  bar-height: 16pt,
  title: none,
  show-values: true,
  max-val: auto,
  background: auto,
  theme: none,
) = context {
  layout(size => {
  validate-simple-data(data, "progress-bars")
  let t = _resolve-ctx(theme)
  let width = resolve-size(width, 0pt, size, container: false).width
  let background = if background != auto { background } else if t.background != none { t.background.lighten(20%) } else { luma(230) }
  let labels = data.labels
  let values = data.values
  let n = labels.len()

  let actual-max = nonzero(if max-val == auto { calc.max(..values) } else { max-val })

  box(width: width)[
    #if title != none {
      align(center)[*#title*]
      v(8pt)
    }

    #grid(
      columns: (auto, 1fr, if show-values { auto } else { 0pt }),
      column-gutter: 6pt,
      row-gutter: 6pt,
      ..labels.enumerate().map(((i, lbl)) => {
        let val = values.at(i)
        let progress = val / actual-max
        (
          text(size: t.axis-label-size, fill: t.text-color)[#lbl],
          box(width: 100%, height: bar-height)[
            #rect(width: 100%, height: 100%, fill: background, radius: 3pt)
            #place(left + top, rect(width: 100% * progress, height: 100%, fill: get-color(t, i), radius: 3pt))
          ],
          if show-values { text(size: t.value-label-size, fill: t.text-color, weight: "bold")[#val] },
        )
      }).flatten()
    )
  ]
  })
}
