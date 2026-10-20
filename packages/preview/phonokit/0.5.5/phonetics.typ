#import "@preview/lilaq:0.6.0" as lq
#import "ipa.typ": ipa-to-unicode
#import "_config.typ": phonokit-font
#import "vowels.typ": language-vowels

#let formants-default-vowel-size = 18pt

#let phonetic-vowel-presets = (
  "i": (f1: 280, f2: 2290),
  "y": (f1: 310, f2: 1990),
  "ɨ": (f1: 300, f2: 1750),
  "ʉ": (f1: 320, f2: 1400),
  "ɯ": (f1: 300, f2: 1100),
  "ɪ": (f1: 390, f2: 1990),
  "ʏ": (f1: 400, f2: 1750),
  "e": (f1: 390, f2: 2200),
  "ø": (f1: 390, f2: 1800),
  "ɘ": (f1: 420, f2: 1650),
  "ɵ": (f1: 420, f2: 1400),
  "ɤ": (f1: 420, f2: 1200),
  "ɛ": (f1: 530, f2: 1840),
  "œ": (f1: 540, f2: 1600),
  "ɜ": (f1: 560, f2: 1500),
  "ɞ": (f1: 560, f2: 1300),
  "æ": (f1: 660, f2: 1720),
  "ɐ": (f1: 650, f2: 1450),
  "a": (f1: 730, f2: 1500),
  "ɶ": (f1: 780, f2: 1450),
  "ɑ": (f1: 730, f2: 1090),
  "ɒ": (f1: 700, f2: 900),
  "ə": (f1: 500, f2: 1500),
  "ʌ": (f1: 610, f2: 1300),
  "ɔ": (f1: 570, f2: 840),
  "o": (f1: 430, f2: 930),
  "ʊ": (f1: 440, f2: 1020),
  "u": (f1: 300, f2: 870),
)

// Sourced English preset adapted from the male values in Hillenbrand et al. (1995),
// as provided by the user from a secondary table reproducing those averages.
// For legibility in a teaching plot, a few values are slightly regularized so
// categories do not collapse visually. This is used only when the input preset
// is "english". Other presets remain schematic/illustrative for teaching.
#let english-hillenbrand-male = (
  "i": (f1: 342, f2: 2322),
  "ɪ": (f1: 427, f2: 2034),
  "e": (f1: 476, f2: 2089),
  "ɛ": (f1: 580, f2: 1799),
  "æ": (f1: 588, f2: 1952),
  "a": (f1: 768, f2: 1425),
  "ɑ": (f1: 768, f2: 1225),
  "ɔ": (f1: 652, f2: 997),
  "o": (f1: 497, f2: 910),
  "u": (f1: 378, f2: 997),
  "ʊ": (f1: 469, f2: 1122),
  "ʌ": (f1: 623, f2: 1200),
  "ə": (f1: 474, f2: 1379),
  "ɚ": (f1: 474, f2: 1379),
)

#let _unique(items) = {
  let seen = ()
  for item in items {
    if item not in seen {
      seen.push(item)
    }
  }
  seen
}

#let _index-of(items, target) = {
  for (idx, item) in items.enumerate() {
    if item == target {
      return idx
    }
  }
  none
}

#let _normalize-vowel-string(vowels) = {
  let cleaned = vowels
  if cleaned in language-vowels {
    return language-vowels.at(cleaned).clusters()
  }
  let normalized = ipa-to-unicode(cleaned)
    .replace("/", " ")
    .replace("[", " ")
    .replace("]", " ")
    .replace(",", " ")
    .replace(";", " ")
    .replace("|", " ")

  let split-tokens = normalized.split(" ").filter(token => token != "")
  if split-tokens.len() > 0 {
    let expanded = ()
    for token in split-tokens {
      if token in phonetic-vowel-presets {
        expanded.push(token)
      } else {
        let pieces = token.clusters()
        if pieces.all(piece => piece in phonetic-vowel-presets) {
          for piece in pieces {
            expanded.push(piece)
          }
        } else {
          expanded.push(token)
        }
      }
    }
    expanded
  } else {
    normalized.clusters().filter(token => token in phonetic-vowel-presets)
  }
}

#let _next-rand(state) = calc.rem(state * 48271 + 1, 2147483647)

#let _rand-unit(state) = {
  let next = _next-rand(state)
  (next, calc.abs(float(next)) / 2147483646.0)
}

#let _rand-symmetric(state, spread) = {
  let state-0 = state
  let acc = 0.0
  for _ in range(6) {
    let sample = _rand-unit(state-0)
    state-0 = sample.at(0)
    acc += sample.at(1)
  }
  (state-0, (acc - 3.0) * spread)
}

#let _token-cloud(vowels, preset-map, n, sd, sd2, seed) = {
  let tokens = ()
  let state = calc.max(seed, 1)
  for (index, vowel) in vowels.enumerate() {
    let mean = preset-map.at(vowel)
    for token-index in range(n) {
      let jitter-f1 = _rand-symmetric(state + index * 101 + token-index * 17, sd)
      let jitter-f2 = _rand-symmetric(jitter-f1.at(0) + 29, sd2)
      state = jitter-f2.at(0)
      tokens.push((
        vowel: vowel,
        f1: mean.f1 + jitter-f1.at(1),
        f2: mean.f2 + jitter-f2.at(1),
      ))
    }
  }
  tokens
}

#let _centroid-pairs(vowels, preset-map) = {
  vowels.map(vowel => {
    let mean = preset-map.at(vowel)
    (
      vowel: vowel,
      f1: mean.f1,
      f2: mean.f2,
    )
  })
}

#let _mean(values) = values.sum() / values.len()

#let _sd(values) = {
  if values.len() <= 1 { return 0.0 }
  let mean = _mean(values)
  let variance = values.map(value => calc.pow(value - mean, 2)).sum() / (values.len() - 1)
  calc.sqrt(variance)
}

#let _csv-tokens(source) = {
  if type(source) != array {
    return (error: [*Error:* `source` must be tabular data from `csv(..., row-type: dictionary)`], tokens: ())
  }
  if source.len() == 0 {
    return (error: [*Error:* `source` is empty], tokens: ())
  }

  let first = source.at(0)
  let tokens = ()
  if type(first) == dictionary {
    if not ("vowel" in first and "f1" in first and "f2" in first) {
      return (error: [*Error:* CSV source must contain columns `"vowel"`, `"f1"`, and `"f2"`], tokens: ())
    }
    for row in source {
      if type(row) != dictionary or not ("vowel" in row and "f1" in row and "f2" in row) {
        return (error: [*Error:* Every CSV row must contain `"vowel"`, `"f1"`, and `"f2"`], tokens: ())
      }
      let vowel = ipa-to-unicode(str(row.at("vowel")))
      let f1 = float(row.at("f1"))
      let f2 = float(row.at("f2"))
      tokens.push((vowel: vowel, f1: f1, f2: f2))
    }
  } else if type(first) == array {
    if first.len() < 3 {
      return (error: [*Error:* CSV source must contain columns `"vowel"`, `"f1"`, and `"f2"`], tokens: ())
    }
    let headers = first.map(value => str(value))
    let vowel-idx = _index-of(headers, "vowel")
    let f1-idx = _index-of(headers, "f1")
    let f2-idx = _index-of(headers, "f2")
    if vowel-idx == none or f1-idx == none or f2-idx == none {
      return (error: [*Error:* CSV source must contain columns `"vowel"`, `"f1"`, and `"f2"`], tokens: ())
    }
    for row in source.slice(1) {
      if type(row) != array or calc.max(vowel-idx, f1-idx, f2-idx) >= row.len() {
        return (error: [*Error:* Every CSV row must contain values for `"vowel"`, `"f1"`, and `"f2"`], tokens: ())
      }
      let vowel = ipa-to-unicode(str(row.at(vowel-idx)))
      let f1 = float(row.at(f1-idx))
      let f2 = float(row.at(f2-idx))
      tokens.push((vowel: vowel, f1: f1, f2: f2))
    }
  } else {
    return (error: [*Error:* `source` must be tabular data from `csv(...)`], tokens: ())
  }
  (error: none, tokens: tokens)
}

#let _centroids-from-tokens(tokens) = {
  let vowels = _unique(tokens.map(token => token.vowel))
  vowels.map(vowel => {
    let subset = tokens.filter(token => token.vowel == vowel)
    (
      vowel: vowel,
      f1: _mean(subset.map(token => token.f1)),
      f2: _mean(subset.map(token => token.f2)),
      sd-f1: _sd(subset.map(token => token.f1)),
      sd-f2: _sd(subset.map(token => token.f2)),
    )
  })
}

#let _warn(body) = text(fill: red.darken(20%), weight: "bold")[⚠ #body]

#let _nice-tick-step(span, target: 6) = {
  let rough = span / target
  if rough <= 50 { 50 } else if rough <= 100 { 100 } else if rough <= 200 { 200 } else if rough <= 250 { 250 } else if (
    rough <= 500
  ) { 500 } else { 1000 }
}

#let _make-ticks(minimum, maximum, step) = {
  let start = int(calc.ceil(minimum / step) * step)
  let stop = int(calc.floor(maximum / step) * step)
  let ticks = ()
  let current = start
  while current <= stop {
    ticks.push(current)
    current += step
  }
  ticks
}

/// Create an illustrative F1/F2 vowel cloud for teaching.
///
/// This function generates synthetic vowel tokens around built-in F1/F2 means
/// and displays them on an inverted F1/F2 diagram in the style common in
/// phonetics teaching.
///
/// Data policy:
/// - If `vowels` is `"english"`, the means are based on the male averages in
///   Hillenbrand et al. (1995), lightly regularized for pedagogical clarity.
/// - Other vowel means in this module are schematic/illustrative defaults for
///   teaching and are not tied to a single empirical source.
///
/// Arguments:
/// - vowels (string): Tipa-style/IPA vowel string or a built-in language name
///   such as `"english"`.
/// - source (array, optional): Tabular data from `csv(...)` with required
///   columns `vowel`, `f1`, and `f2`. Extra columns are ignored.
/// - sd (float): Standard deviation used for F1 jitter in Hz.
/// - sd2 (float, optional): Standard deviation for F2 jitter in Hz; defaults to `sd`.
/// - n (int): Number of synthetic tokens per vowel (default: 10).
/// - seed (int): Seed for deterministic token placement (default: 1).
/// - labels (bool): Show vowel labels at preset means (default: true).
/// - points (bool): Show synthetic tokens (default: true).
/// - centers (bool): Show explicit `+` mean markers (default: false).
/// - ellipse (bool): Show 1-SD ellipses centered on the vowel means (default: false).
/// - ellipse-stroke (stroke or auto): Stroke used for SD ellipses
///   (default: `0.8pt + luma(190)`).
/// - ellipse-fill (fill): Fill used for SD ellipses (default: none).
/// - grid (bool): Show the background grid (default: true).
/// - color-by-vowel (bool): Use a color cycle by vowel category (default: true).
/// - point-size (int): Marker size for synthetic tokens (default: 50).
/// - point-color (color or auto): Override token color; `auto` uses the plot cycle
///   (default: auto).
/// - point-alpha (ratio): Token transparency (default: 20%).
/// - vowel-color (color): Color used for vowel labels (default: black).
/// - vowel-size (length): Font size used for vowel labels (default: 20pt).
/// - vowel-weight (str): Font weight used for vowel labels (default: `"regular"`).
/// - axis-size (length): Font size used for axis labels and tick labels
///   (default: 10pt).
/// - scale (float): Overall scale factor for the figure (default: 1.0).
/// - x-label (content): X-axis label (default: `[F2 (Hz)]`).
/// - y-label (content): Y-axis label (default: `[F1 (Hz)]`).
/// - width (length): Diagram width (default: 10cm).
/// - height (length): Diagram height (default: 7cm).
///
/// Notes:
/// - Language-name input is checked first. If `vowels` matches a built-in
///   language preset such as `"english"` or `"french"`, that inventory is used.
/// - Otherwise, the input is parsed through `ipa-to-unicode` by default, so
///   tipa-style strings like `"a e E o O i u"` work directly.
/// - In CSV mode, `source: csv("...")` assumes the first row is a header row.
/// - In synthetic mode, ellipses visualize the user-provided spread parameters
///   (`sd`, `sd2`); in CSV mode, they reflect sample standard deviations
///   computed from the observed tokens.
///
/// Example:
/// ```
/// #formants("i ɪ e ɛ æ a ə ɔ o ʊ u", sd: 80)
/// ```
#let _formants_impl(
  vowels: none,
  source: none,
  sd: 60,
  sd2: none,
  n: 10,
  seed: 1,
  labels: true,
  points: true,
  centers: false,
  ellipse: false,
  ellipse-stroke: 0.8pt + luma(190),
  ellipse-fill: none,
  grid: true,
  color-by-vowel: true,
  point-size: 50,
  point-color: auto,
  point-alpha: 20%,
  vowel-color: black,
  vowel-size: formants-default-vowel-size,
  vowel-weight: "regular",
  axis-size: 10pt,
  scale: 1.0,
  x-label: [F2 (Hz)],
  y-label: [F1 (Hz)],
  width: 10cm,
  height: 7cm,
) = {
  let tokens = ()
  let centroids = ()
  let spread2 = if sd2 == none { sd } else { sd2 }
  let unknown = ()

  if source != none {
    let parsed = _csv-tokens(source)
    if parsed.error != none {
      return parsed.error
    }
    tokens = parsed.tokens
    centroids = _centroids-from-tokens(tokens)
    if tokens.len() == 0 {
      return [*Error:* `source` is empty]
    }
  } else {
    let preset-map = if vowels == "english" {
      english-hillenbrand-male
    } else {
      phonetic-vowel-presets
    }
    let requested = _normalize-vowel-string(vowels)
    let known = requested.filter(vowel => vowel in preset-map)
    unknown = _unique(requested.filter(vowel => vowel not in preset-map))

    if known.len() == 0 {
      return _warn([No supported vowels found in input: "#vowels".])
    }

    tokens = _token-cloud(known, preset-map, n, sd, spread2, seed)
    centroids = _centroid-pairs(known, preset-map).map(ct => (..ct, sd-f1: sd, sd-f2: spread2))
  }

  let f1-values = tokens.map(t => t.f1) + centroids.map(t => t.f1)
  let f2-values = tokens.map(t => t.f2) + centroids.map(t => t.f2)
  let pad-f1 = if source != none {
    calc.max(calc.max(..centroids.map(ct => ct.sd-f1)) * 1.5, 60)
  } else {
    calc.max(sd * 1.5, 60)
  }
  let pad-f2 = if source != none {
    calc.max(calc.max(..centroids.map(ct => ct.sd-f2)) * 1.5, 80)
  } else {
    calc.max(spread2 * 1.5, 80)
  }
  let f1-min = calc.min(..f1-values) - pad-f1
  let f1-max = calc.max(..f1-values) + pad-f1
  let f2-min = calc.min(..f2-values) - pad-f2
  let f2-max = calc.max(..f2-values) + pad-f2
  let x-step = _nice-tick-step(f2-max - f2-min)
  let y-step = _nice-tick-step(f1-max - f1-min)
  let x-ticks = _make-ticks(f2-min, f2-max, x-step)
  let y-ticks = _make-ticks(f1-min, f1-max, y-step)
  let groups = _unique(tokens.map(token => token.vowel)).map(vowel => (
    vowel,
    tokens.filter(token => token.vowel == vowel),
  ))

  let cycle = if color-by-vowel {
    (
      rgb("#3b82f6"),
      rgb("#ef4444"),
      rgb("#10b981"),
      rgb("#f59e0b"),
      rgb("#8b5cf6"),
      rgb("#ec4899"),
      rgb("#14b8a6"),
      rgb("#f97316"),
      rgb("#06b6d4"),
      rgb("#84cc16"),
    )
  } else {
    (rgb("#64748b"),)
  }

  [
    #if unknown.len() > 0 {
      _warn([Skipped unsupported vowel(s): #unknown.join(", ").])
      v(0.5em)
    }
    #context {
      let doc-font = text.font
      let scaled-width = width * scale
      let scaled-height = height * scale
      let scaled-point-size = point-size * scale
      let scaled-vowel-size = vowel-size * scale
      let scaled-axis-size = axis-size * scale
      let axis-tick-color = gray.darken(35%)
      let scaled-axis-stroke = 0.8pt * scale + axis-tick-color
      let scaled-grid-stroke = 0.5pt * scale + luma(220)
      let scaled-center-size = 48 * scale
      let scaled-center-stroke = 1pt * scale
      let tick-pad = scaled-axis-size * 0.35
      show lq.selector(lq.tick-label): it => []
      let x-tick-labels = x-ticks.map(value => text(font: doc-font, size: scaled-axis-size)[#str(value)])
      let y-tick-labels = y-ticks.map(value => text(font: doc-font, size: scaled-axis-size)[#str(value)])
      let max-x-tick-height = calc.max(..x-tick-labels.map(label => measure(label).height))
      let max-y-tick-width = calc.max(..y-tick-labels.map(label => measure(label).width))
      let x-label-pad = max-x-tick-height + scaled-axis-size * 0.9
      let y-label-pad = max-y-tick-width + scaled-axis-size * 1.05
      let axis-label-color = black
      let x-axis-label = text(font: doc-font, size: scaled-axis-size, fill: axis-label-color)[#x-label]
      let y-axis-label = rotate(
        -90deg,
        text(font: doc-font, size: scaled-axis-size, fill: axis-label-color)[#y-label],
        reflow: true,
      )
      lq.diagram(
        width: scaled-width,
        height: scaled-height,
        xlim: (f2-max, f2-min),
        ylim: (f1-max, f1-min),
        xlabel: none,
        ylabel: none,
        xscale: "linear",
        yscale: "linear",
        xaxis: (
          position: top,
          stroke: scaled-axis-stroke,
          mirror: false,
          exponent: none,
          tick-distance: x-step,
        ),
        yaxis: (
          position: right,
          stroke: scaled-axis-stroke,
          mirror: false,
          exponent: none,
          tick-distance: y-step,
        ),
        grid: if grid { scaled-grid-stroke } else { none },
        fill: white,
        cycle: cycle,
        legend: none,
        ..centroids.map(ct => if ellipse {
          lq.ellipse(
            ct.f2 - ct.sd-f2,
            ct.f1 - ct.sd-f1,
            width: ct.sd-f2 * 2,
            height: ct.sd-f1 * 2,
            stroke: ellipse-stroke,
            fill: ellipse-fill,
          )
        } else {
          none
        }),
        ..groups.map(group => {
          let vowel = group.at(0)
          let cloud = group.at(1)
          if points {
            lq.scatter(
              cloud.map(token => token.f2),
              cloud.map(token => token.f1),
              mark: "o",
              color: point-color,
              size: cloud.map(_ => scaled-point-size),
              stroke: none,
              alpha: point-alpha,
              label: if color-by-vowel { context text(font: phonokit-font.get())[#vowel] } else { none },
            )
          } else {
            none
          }
        }),
        ..centroids.map(ct => if centers {
          lq.scatter(
            (ct.f2,),
            (ct.f1,),
            mark: "+",
            size: (scaled-center-size,),
            color: black,
            stroke: (paint: black, thickness: scaled-center-stroke),
          )
        } else {
          none
        }),
        ..centroids.map(ct => if labels {
          lq.place(
            ct.f2,
            ct.f1,
            align: center + horizon,
            context text(
              font: phonokit-font.get(),
              weight: vowel-weight,
              size: scaled-vowel-size,
              fill: vowel-color,
            )[#ct.vowel],
          )
        } else {
          none
        }),
        ..x-ticks.map(value => lq.place(
          value,
          0%,
          align: bottom + center,
          pad(bottom: tick-pad, text(font: doc-font, size: scaled-axis-size, fill: axis-tick-color)[#str(value)]),
        )),
        ..y-ticks.map(value => lq.place(
          100%,
          value,
          align: left + horizon,
          pad(left: tick-pad, text(font: doc-font, size: scaled-axis-size, fill: axis-tick-color)[#str(value)]),
        )),
        lq.place(
          50%,
          0%,
          align: bottom + center,
          pad(bottom: x-label-pad, x-axis-label),
        ),
        lq.place(
          100%,
          50%,
          align: left + horizon,
          pad(left: y-label-pad, y-axis-label),
        ),
      )
    }
  ]
}

#let formants(..args) = {
  let pos = args.pos()
  let named = args.named()
  let vowels = if "vowels" in named { named.at("vowels") } else { pos.at(0, default: none) }

  _formants_impl(
    vowels: vowels,
    source: named.at("source", default: none),
    sd: named.at("sd", default: 60),
    sd2: named.at("sd2", default: none),
    n: named.at("n", default: 10),
    seed: named.at("seed", default: 1),
    labels: named.at("labels", default: true),
    points: named.at("points", default: true),
    centers: named.at("centers", default: false),
    ellipse: named.at("ellipse", default: false),
    ellipse-stroke: named.at("ellipse-stroke", default: 0.8pt + luma(190)),
    ellipse-fill: named.at("ellipse-fill", default: none),
    grid: named.at("grid", default: true),
    color-by-vowel: named.at("color-by-vowel", default: true),
    point-size: named.at("point-size", default: 50),
    point-color: named.at("point-color", default: auto),
    point-alpha: named.at("point-alpha", default: 20%),
    vowel-color: named.at("vowel-color", default: black),
    vowel-size: named.at("vowel-size", default: formants-default-vowel-size),
    vowel-weight: named.at("vowel-weight", default: "regular"),
    axis-size: named.at("axis-size", default: 10pt),
    scale: named.at("scale", default: 1.0),
    x-label: named.at("x-label", default: [F2 (Hz)]),
    y-label: named.at("y-label", default: [F1 (Hz)]),
    width: named.at("width", default: 10cm),
    height: named.at("height", default: 7cm),
  )
}
