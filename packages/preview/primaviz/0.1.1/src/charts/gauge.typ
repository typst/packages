// gauge.typ - Gauge/dial and progress indicators
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-number, validate-simple-data
#import "../primitives/container.typ": chart-container

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
) = {
  validate-number(value, "gauge-chart")
  let t = resolve-theme(theme)
  let needle-color = if needle-color == auto { t.text-color } else { needle-color }
  let radius = size / 2 - 10pt
  let cx = size / 2
  let cy = size / 2 + 10pt

  let val-range = max-val - min-val
  if val-range == 0 { val-range = 1 }
  let normalized = (value - min-val) / val-range
  normalized = calc.max(0, calc.min(1, normalized))  // clamp 0-1

  // Angle: -180deg (left) to 0deg (right)
  let needle-angle = -180deg + normalized * 180deg

  chart-container(size, size / 2 + 20pt, title, t, extra-height: 30pt)[
    #box(width: size, height: size / 2 + 30pt)[
      // Draw segments or default arc
      #if segments != none {
        let prev-threshold = min-val
        for (i, seg) in segments.enumerate() {
          let threshold = seg.at(0)
          let seg-color = seg.at(1)

          let start-norm = (prev-threshold - min-val) / val-range
          let end-norm = (threshold - min-val) / val-range

          let start-angle = -180deg + start-norm * 180deg
          let end-angle = -180deg + end-norm * 180deg
          let seg-angle = end-angle - start-angle

          let n-pts = calc.max(int(seg-angle.deg() / 5), 3)

          // Build arc segment
          let pts = ((cx, cy),)
          for j in array.range(n-pts + 1) {
            let angle = start-angle + (j / n-pts) * seg-angle
            pts.push((
              cx + radius * calc.cos(angle),
              cy + radius * calc.sin(angle)
            ))
          }

          place(
            left + top,
            polygon(
              fill: seg-color,
              stroke: white + 0.5pt,
              ..pts.map(p => (p.at(0), p.at(1)))
            )
          )

          prev-threshold = threshold
        }
      } else {
        // Default gradient arc
        for i in array.range(36) {
          let start-angle = -180deg + (i / 36) * 180deg
          let end-angle = -180deg + ((i + 1) / 36) * 180deg

          // Color gradient from green to yellow to red
          let seg-progress = i / 36
          let seg-color = if seg-progress < 0.5 {
            color.mix((rgb("#59a14f"), 100% - seg-progress * 200%), (rgb("#edc948"), seg-progress * 200%))
          } else {
            color.mix((rgb("#edc948"), 100% - (seg-progress - 0.5) * 200%), (rgb("#e15759"), (seg-progress - 0.5) * 200%))
          }

          let pts = ((cx, cy),)
          for j in array.range(4) {
            let angle = start-angle + (j / 3) * (end-angle - start-angle)
            pts.push((cx + radius * calc.cos(angle), cy + radius * calc.sin(angle)))
          }

          place(left + top, polygon(fill: seg-color, stroke: none, ..pts.map(p => (p.at(0), p.at(1)))))
        }
      }

      // Inner white circle (donut effect)
      #let inner-radius = radius * 0.6
      #place(
        left + top,
        dx: cx - inner-radius,
        dy: cy - inner-radius,
        circle(radius: inner-radius, fill: if t.background != none { t.background } else { white }, stroke: none)
      )

      // Needle
      #let needle-len = radius * 0.85
      #let needle-end-x = cx + needle-len * calc.cos(needle-angle)
      #let needle-end-y = cy + needle-len * calc.sin(needle-angle)

      #place(
        left + top,
        line(
          start: (cx, cy),
          end: (needle-end-x, needle-end-y),
          stroke: needle-color + 2.5pt
        )
      )

      // Center cap
      #place(
        left + top,
        dx: cx - 6pt,
        dy: cy - 6pt,
        circle(radius: 6pt, fill: needle-color, stroke: white + 1pt)
      )

      // Min/max labels
      #place(left + top, dx: cx - radius - 10pt, dy: cy + 5pt, text(size: t.axis-label-size, fill: t.text-color)[#min-val])
      #place(left + top, dx: cx + radius - 5pt, dy: cy + 5pt, text(size: t.axis-label-size, fill: t.text-color)[#max-val])

      // Value display
      #if show-value {
        place(
          left + top,
          dx: cx - 20pt,
          dy: cy - 25pt,
          text(size: 16pt, weight: "bold", fill: t.text-color)[#calc.round(value, digits: 1)]
        )
      }

      // Label below
      #if label != none {
        place(
          left + top,
          dx: cx - 30pt,
          dy: cy + 15pt,
          text(size: t.value-label-size, fill: t.text-color-light)[#label]
        )
      }
    ]
  ]
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
  background: luma(230),
  rounded: true,
  theme: none,
) = {
  validate-number(value, "progress-bar")
  let t = resolve-theme(theme)
  let progress = calc.min(1, calc.max(0, value / max-val))
  let bar-color = if color != none { color } else { get-color(t, 0) }
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

      // Value label
      #if show-value {
        place(
          left + top,
          dx: width / 2 - 15pt,
          dy: height / 2 - 6pt,
          text(size: 10pt, weight: "bold", fill: if progress > 0.5 { t.text-color-inverse } else { t.text-color })[
            #calc.round(progress * 100, digits: 0)%
          ]
        )
      }
    ]
  ]
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
  background: luma(230),
  theme: none,
) = {
  validate-number(value, "circular-progress")
  let t = resolve-theme(theme)
  let progress = calc.min(1, calc.max(0, value / max-val))
  let bar-color = if color != none { color } else { get-color(t, 0) }
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

      // Center value
      #if show-value {
        place(
          left + top,
          dx: cx - 18pt,
          dy: cy - 10pt,
          text(size: 14pt, weight: "bold", fill: t.text-color)[#calc.round(progress * 100, digits: 0)%]
        )
      }
    ]
  ]
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
  background: luma(230),
  theme: none,
) = {
  validate-simple-data(data, "progress-bars")
  let t = resolve-theme(theme)
  let labels = data.labels
  let values = data.values
  let n = labels.len()

  let actual-max = if max-val == auto { calc.max(..values) } else { max-val }
  if actual-max == 0 { actual-max = 1 }

  box(width: width)[
    #if title != none {
      align(center)[*#title*]
      v(8pt)
    }

    #for (i, lbl) in labels.enumerate() {
      let val = values.at(i)
      let progress = val / actual-max

      grid(
        columns: (70pt, 1fr, if show-values { 40pt } else { 0pt }),
        column-gutter: 8pt,
        row-gutter: 6pt,

        text(size: t.axis-label-size, fill: t.text-color)[#lbl],

        box(width: 100%, height: bar-height)[
          #rect(width: 100%, height: 100%, fill: background, radius: 3pt)
          #place(left + top, rect(width: 100% * progress, height: 100%, fill: get-color(t, i), radius: 3pt))
        ],

        if show-values { text(size: t.value-label-size, fill: t.text-color, weight: "bold")[#val] }
      )
      v(4pt)
    }
  ]
}
