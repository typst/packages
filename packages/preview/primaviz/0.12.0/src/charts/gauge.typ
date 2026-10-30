// gauge.typ - Gauge/dial and progress indicators
#import "../theme.typ": _resolve-ctx, get-color, _shade
#import "../util.typ": nonzero, clamp, normalize-data
#import "../validate.typ": validate-number, validate-simple-data
#import "../primitives/container.typ": chart-container, container-inset
#import "../primitives/title.typ": draw-title
#import "../primitives/polar.typ": place-wedge, place-arc-band, separator-stroke
#import "../primitives/polar-labels.typ": label-ink, fit-text-size
#import "../primitives/radial.typ": title-for-size
#import "../primitives/layout.typ": resolve-size

// A theme with a background (a dark one) brings it behind these standalone
// indicators, padded as a chart container pads a chart: their title and values
// are in the theme's light text, which a white page swallows. A theme without
// a background draws them bare, as they always were, to sit inline in a card.
#let _backed(t, body) = if t.background == none { body } else {
  box(fill: t.background, stroke: t.border, inset: t.at("container-inset", default: container-inset), body)
}

// The empty part of a progress indicator: a step off the background
#let _track(t, background) = {
  if background != auto { background }
  else if t.background != none { _shade(t, 20%) }
  else { luma(230) }
}

/// Renders a semicircular gauge/dial chart with a needle indicator.
///
/// Without `segments` the dial is a quiet track filled up to the value; with
/// `segments` it is a set of flat coloured bands and the needle alone marks
/// the value. The title scales down on a small dial so it never outshouts
/// the heading of whatever the dial sits in.
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
  let (r, hole) = (size / 2, size / 2 * 0.6)
  let (cx, cy) = (size / 2, size / 2)

  let val-range = nonzero(max-val - min-val)
  let normalized = clamp((value - min-val) / val-range, 0, 1)
  // The dial runs from -180 (left) to 0 (right)
  let at-deg(v) = -180 + clamp((v - min-val) / val-range, 0, 1) * 180

  // Text under the hub: value, caption; scale ends sit under the band
  let cap-r = calc.max(2pt, size * 0.04)
  let value-text(sz) = text(size: sz, weight: "bold", fill: t.text-color, top-edge: "cap-height", bottom-edge: "baseline")[#calc.round(value, digits: 1)]
  let scale-text(v) = text(size: t.axis-label-size, fill: t.text-color-light, top-edge: "cap-height", bottom-edge: "baseline")[#v]
  let scale-w = calc.max(measure(scale-text(min-val)).width, measure(scale-text(max-val)).width)
  // The value must stay clear of the scale ends either side of it
  let value-size = fit-text-size(value-text, calc.max(r * 0.5, 2 * (r * 0.8 - scale-w / 2 - 3pt)),
    calc.max(t.value-label-size, calc.min(size * 0.15, 14pt)), t.axis-label-size)
  let value-h = if show-value { measure(value-text(value-size)).height } else { 0pt }
  let caption = if label != none {
    text(size: t.axis-label-size, fill: t.text-color-light, top-edge: "cap-height", bottom-edge: "descender")[#label]
  }
  let caption-h = if caption != none { measure(caption).height } else { 0pt }
  let below = calc.max(
    cap-r + 3pt + (if show-value { value-h + 3pt } else { 0pt }) + (if caption != none { caption-h + 1pt } else { 0pt }),
    2pt + measure(scale-text(max-val)).height)
  let total-h = cy + below

  let ts = title-for-size(t, size)
  chart-container(size, total-h, title, ts)[
    #box(width: size, height: total-h)[
      // The dial: a flat track, then either the bands or the filled value
      #place-wedge(cx, cy, hole, r, -180, 0, _track(t, auto))
      #if segments != none {
        let prev = min-val
        for seg in segments {
          place-wedge(cx, cy, hole, r, at-deg(prev), at-deg(seg.at(0)), seg.at(1),
            stroke: separator-stroke(t, thickness: 0.75pt))
          prev = seg.at(0)
        }
      } else if "gauge-low-color" in t or "gauge-mid-color" in t or "gauge-high-color" in t {
        // Opt-in zones through the theme: thirds of the dial
        let zones = (
          t.at("gauge-low-color", default: get-color(t, 4)),
          t.at("gauge-mid-color", default: get-color(t, 5)),
          t.at("gauge-high-color", default: get-color(t, 2)),
        )
        for (i, zc) in zones.enumerate() {
          place-wedge(cx, cy, hole, r, -180 + i * 60, -180 + (i + 1) * 60, zc,
            stroke: separator-stroke(t, thickness: 0.75pt))
        }
      } else {
        place-wedge(cx, cy, hole, r, -180, -180 + normalized * 180, get-color(t, 0))
      }

      // Needle and hub
      #let needle-angle = (-180 + normalized * 180) * 1deg
      #place(left + top, line(start: (cx, cy),
        end: (cx + r * 0.85 * calc.cos(needle-angle), cy + r * 0.85 * calc.sin(needle-angle)),
        stroke: needle-color + calc.max(1pt, size * 0.016)))
      #place(left + top, dx: cx - cap-r, dy: cy - cap-r,
        circle(radius: cap-r, fill: needle-color, stroke: none))

      // Scale ends, centred under the band
      #for (v, sign) in ((min-val, -1), (max-val, 1)) {
        place(left + top, dx: cx + sign * r * 0.8 - 20pt, dy: cy + 2pt,
          box(width: 40pt, align(center, scale-text(v))))
      }

      // Value and caption, centred under the hub
      #if show-value {
        place(left + top, dx: cx - r, dy: cy + cap-r + 3pt, box(width: 2 * r, align(center, value-text(value-size))))
      }
      #if caption != none {
        place(left + top, dx: cx - r, dy: cy + cap-r + 3pt + (if show-value { value-h + 3pt } else { 0pt }),
          box(width: 2 * r, align(center, caption)))
      }
    ]
  ]
  })
}

/// Renders a horizontal progress bar.
///
/// The percentage sits inside the fill when it fits, and just past the end
/// of the fill, on the track, when it does not.
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
  set text(size: 11pt)  // sized by the theme, not the document font
  let (width, height) = resolve-size(width, height, size, theme: t, container: t.background != none)
  let progress = clamp(value / nonzero(max-val), 0, 1)
  let bar-color = if color != none { color } else { get-color(t, 0) }
  let corner = if rounded { height / 2 } else { 0pt }

  // Digits are about 0.7 em tall: as big as the bar allows, never below the
  // theme's smallest type, and no label at all in a bar too thin to hold one
  let pct-size = calc.max(t.axis-label-size, calc.min(t.value-label-size, (height - 3pt) / 0.7))
  let pct-text(ink) = text(size: pct-size, weight: "bold", fill: ink,
    top-edge: "cap-height", bottom-edge: "baseline")[#calc.round(progress * 100, digits: 0)%]
  let pct-w = measure(pct-text(black)).width
  let pad = calc.max(4pt, corner * 0.8)
  let fill-w = width * progress
  let inside = progress > 0 and fill-w >= pct-w + 2 * pad
  let pct-x = if inside { fill-w - pad - pct-w } else { calc.min(fill-w + pad, width - pad - pct-w) }
  let pct-ink = if inside { label-ink(bar-color, t) } else { t.text-color }

  _backed(t, box(width: width)[
    #stack(dir: ttb, spacing: 3pt,
      if title != none { text(size: t.value-label-size, fill: t.text-color, bottom-edge: "descender")[#title] },
      box(width: width, height: height)[
        #place(left + top, rect(width: width, height: height, fill: _track(t, background), radius: corner))
        #if progress > 0 {
          place(left + top, rect(width: fill-w, height: height, fill: bar-color, radius: corner))
        }
        #if show-value and height >= 6pt {
          place(left + horizon, dx: pct-x, pct-text(pct-ink))
        }
      ])
  ])
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
  set text(size: 11pt)  // sized by the theme, not the document font
  let size = resolve-size(size, size, avail, theme: t, container: t.background != none).width
  let progress = clamp(value / nonzero(max-val), 0, 1)
  let bar-color = if color != none { color } else { get-color(t, 0) }
  let sw = calc.min(stroke-width, size * 0.3)
  let (cx, cy) = (size / 2, size / 2)
  let ring-r = size / 2 - sw / 2

  // The percentage, as big as the hole allows
  let pct-text(sz) = text(size: sz, weight: "bold", fill: t.text-color, top-edge: "cap-height", bottom-edge: "baseline")[#calc.round(progress * 100, digits: 0)%]
  let pct-size = fit-text-size(pct-text, (ring-r - sw / 2) * 1.5, t.value-label-size, t.axis-label-size)

  _backed(t, box(width: size)[
    #stack(dir: ttb, spacing: 3pt,
      if title != none { align(center, text(size: t.value-label-size, fill: t.text-color)[#title]) },
      box(width: size, height: size)[
        #place-arc-band(cx, cy, ring-r, sw, -90, 270, _track(t, background))
        #place-arc-band(cx, cy, ring-r, sw, -90, -90 + progress * 360, bar-color, round: true)
        #if show-value {
          place(center + horizon, pct-text(pct-size))
        }
      ])
  ])
  })
}

/// Renders multiple labeled progress bars for comparing values.
///
/// - data (dictionary, array): Dict with `labels` and `values` arrays, or an array of label-value pairs
/// - width (length): Overall width
/// - bar-height (length): Height of each bar
/// - title (none, content): Optional title above the bars
/// - show-values (bool): Display numeric values beside bars
/// - max-val (auto, int, float): Maximum scale value; `auto` uses the data maximum
/// - color (none, auto, color): Fill of the bars. `none` (default): the theme's first colour for every bar, the labels say which is which. A colour: that colour. `auto`: the next palette colour for each bar
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
  color: none,
  background: auto,
  theme: none,
) = context {
  layout(size => {
  validate-simple-data(data, "progress-bars")
  let t = _resolve-ctx(theme)
  set text(size: 11pt)  // sized by the theme, not the document font
  let width = resolve-size(width, 0pt, size, theme: t, container: t.background != none).width
  let norm = normalize-data(data)
  let (labels, values) = (norm.labels, norm.values)
  let actual-max = nonzero(if max-val == auto { calc.max(..values) } else { max-val })
  // (a bar's colour does not say which bar it is: the label beside it does)
  let fill-of(i) = if color == auto { get-color(t, i) } else if color != none { color } else { get-color(t, 0) }

  // Names are as wide as they are, up to 40% of the whole: past that they wrap
  // rather than squeeze the bars to stubs
  let name-w = calc.min(width * 0.4,
    calc.max(..labels.map(l => measure(text(size: t.value-label-size)[#l]).width)))

  _backed(t, box(width: width)[
    #draw-title(title, t)
    #grid(
      columns: if show-values { (name-w, 1fr, auto) } else { (name-w, 1fr) },
      column-gutter: 6pt,
      row-gutter: 6pt,
      align: (right + horizon, left + horizon, left + horizon),
      ..labels.enumerate().map(((i, lbl)) => {
        let progress = clamp(values.at(i) / actual-max, 0, 1)
        let row = (
          text(size: t.value-label-size, fill: t.text-color)[#lbl],
          box(width: 100%, height: bar-height)[
            #rect(width: 100%, height: 100%, fill: _track(t, background), radius: bar-height / 2)
            #place(left + top, rect(width: 100% * progress, height: 100%, fill: fill-of(i), radius: bar-height / 2))
          ],
        )
        if show-values { row.push(text(size: t.value-label-size, fill: t.text-color, weight: "bold")[#values.at(i)]) }
        row
      }).flatten()
    )
  ])
  })
}
