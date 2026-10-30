// wordcloud.typ - Word cloud chart (spiral placement with collision detection)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero
#import "../validate.typ": validate-wordcloud-data
#import "../primitives/container.typ": chart-container
#import "../primitives/polar-labels.typ": legible
#import "../primitives/layout.typ": resolve-size

// (the `color` parameter shadows the type inside the chart)
#let _mix = color.mix

/// Renders a word cloud using spiral placement (Wordle-style algorithm).
///
/// Words are placed largest-first, spiraling outward from the center.
/// Each word is tested for AABB collision with all previously placed words
/// and shape boundary containment before being committed. When the words do
/// not all fit, the font sizes shrink in proportion (down to the theme's
/// smallest type for every word) until they do; only words that still do not
/// fit then are left out, smallest first.
///
/// Size says the weight, and so does colour: one hue, the theme's first
/// palette colour, from pale (light words) to full (heavy ones), and the
/// heavier half in bold. `color: auto` gives each word a colour of its own
/// from the palette instead (colour then says nothing), with the weight of
/// the type alternating. Colours too pale to read on the background are
/// darkened (or lightened on a dark one).
///
/// - data (dictionary): Must contain a `words` array of dictionaries,
///   each with `text` (string) and `weight` (number) keys.
/// - width (length): Chart width
/// - height (length): Chart height
/// - min-size (length): Font size for the lowest-weight word
/// - max-size (length): Font size for the highest-weight word
/// - color (none, auto, color): `none` (default): the theme's first colour, paler for lighter words. A colour: that colour for every word. `auto`: a palette colour per word
/// - title (none, content): Optional chart title
/// - padding (length): Inner padding around the word area
/// - shape (str): Layout shape — `"rectangle"` (default),
///   `"circle"`, `"diamond"`, or `"triangle"`
/// - theme (none, dictionary): Theme overrides
/// -> content
#let word-cloud(
  data,
  width: auto,
  height: auto,
  min-size: 8pt,
  max-size: 36pt,
  color: none,
  title: none,
  padding: 8pt,
  shape: "rectangle",
  theme: none,
) = context {
  layout(size => {
  validate-wordcloud-data(data, "word-cloud")
  let t = _resolve-ctx(theme)
  let (width, height) = resolve-size(width, height, size, n: 10, theme: t)
  let words = data.words

  if words.len() == 0 { return }

  // Sort by weight descending — largest words placed first
  let sorted-words = words.sorted(key: w => -w.weight)

  let max-weight = sorted-words.at(0).weight
  let min-weight = sorted-words.last().weight
  let weight-range = nonzero(max-weight - min-weight)

  // Font weight alternation for visual variety
  let font-weights = ("bold", "regular", "bold", "medium", "regular")

  let bg = if t.background != none { t.background } else { white }
  let inner-w = width - 2 * padding
  let inner-h = height - 2 * padding

  // Geometry runs in unitless points: the placement below is the inner loop
  let (iw, ih) = (inner-w / 1pt, inner-h / 1pt)

  // Shape width at a given y-fraction (0 = top, 1 = bottom)
  let shape-width-at(y-frac) = {
    let dy = y-frac - 0.5
    if shape == "circle" {
      let tt = 2 * dy
      let sq = 1.0 - tt * tt
      if sq <= 0 { 0.0 } else { iw * calc.sqrt(sq) }
    } else if shape == "diamond" {
      let tt = calc.abs(2 * dy)
      iw * calc.max(0, 1 - tt)
    } else if shape == "triangle" {
      iw * y-frac
    } else {
      iw
    }
  }

  // Check if bbox (x, y, w, h) fits within shape boundary
  let in-bounds(bx, by, bw, bh) = {
    if bx < 0 or by < 0 or bx + bw > iw or by + bh > ih {
      false
    } else if shape == "rectangle" {
      true
    } else {
      // All 4 corners must be inside the shape
      let corners = ((bx, by), (bx + bw, by), (bx, by + bh), (bx + bw, by + bh))
      let mid = iw / 2
      corners.all(c => {
        let yf = calc.max(0, calc.min(1, c.at(1) / ih))
        let half = shape-width-at(yf) / 2
        c.at(0) >= mid - half and c.at(0) <= mid + half
      })
    }
  }

  // Colour: what a word's colour says. By default one hue (the theme's first
  // colour) from pale to full by weight, so colour repeats what size says;
  // `color: auto` gives every word its own palette colour (it says nothing).
  let base = if color == none or color == auto { get-color(t, 0) } else { color }
  // (the heaviest words in ink, the lightest still readable at the smallest size)
  let ink = legible(base, bg, min-ratio: 6.5)
  let pale = legible(_mix((base, 50%), (bg, 50%), space: oklab), bg, min-ratio: 3.6)
  let word-color(i, frac) = if color == auto { legible(get-color(t, i), bg) }
    else if color != none { legible(color, bg) }
    else { _mix((ink, frac * 100%), (pale, (1 - frac) * 100%), space: oklab) }

  // Size of the smallest word, at least: below this the cloud is not read
  let size-floor = calc.min(min-size, t.axis-label-size)

  // Each word with what does not depend on the scale: where it stands in the
  // weights, its type weight and colour, and its width and height per point of
  // type size (a word's box grows in proportion to its type size, so one
  // measurement serves every scale)
  let proto = sorted-words.enumerate().map(((i, w)) => {
    // (equal weights are all middle-sized, not all the smallest)
    let frac = if max-weight == min-weight { 0.5 } else { (w.weight - min-weight) / weight-range }
    // (the weight alternation is for `color: auto` only: otherwise the heavier half is bold)
    let fw = if color == auto { font-weights.at(calc.rem(i, font-weights.len())) }
      else if frac >= 0.5 { "bold" } else { "regular" }
    let dims = measure(text(size: 10pt, weight: fw)[#w.text])
    (text: w.text, frac: frac, fw: fw, color: word-color(i, frac), em-w: dims.width / 10pt, em-h: dims.height / 10pt)
  })
  let n-words = proto.len()

  // The words at a given `scale`, largest first: the size range, from the
  // floor up, is scaled by `scale` (1 is what was asked for, 0 is every word
  // at the floor). Sizes and boxes are unitless points.
  let words-at(scale) = proto.map(w => {
    let sz = (size-floor + (min-size + w.frac * (max-size - min-size) - size-floor) * scale) / 1pt
    // (the room around a word is 8pt by 4pt, less for small type)
    (: ..w, size: sz, w: w.em-w * sz + calc.min(8.0, sz * 0.4), h: w.em-h * sz + calc.min(4.0, sz * 0.2))
  })

  // Spiral placement with AABB collision detection
  // Each word spirals outward from center until a non-overlapping position
  // is found. The spiral is an ellipse as wide as the canvas is, so a wide
  // canvas fills from the middle outwards evenly, and its turns lie closer
  // together for a small word (half a word's height apart) than for a big one.
  // With `strict` the first word that finds no room ends it (the caller only
  // wants to know whether everything fits).
  let aspect = iw / calc.max(ih, 1)
  let (cxf, cyf) = (iw / 2, ih / 2)
  let max-spiral = cyf * 1.45  // (out to the corners)
  let place-words(word-data, strict: false) = {
    let placed = ()
    for (wi, wd) in word-data.enumerate() {
      let (ww, wh) = (wd.w, wd.h)
      let (half-w, half-h) = (ww / 2, wh / 2)
      let found = false
      let px = 0.0
      let py = 0.0
      let spiral-res = calc.max(0.15, wh / 48)

      // Golden angle offset per word for natural distribution
      let offset = wi * 137.5

      for step in range(3000) {
        let theta = (step * 15 + offset) * 1deg  // (24 points per revolution)
        let r = step * spiral-res
        if r > max-spiral { break }

        let try-x = cxf + r * aspect * calc.cos(theta) - half-w
        let try-y = cyf + r * calc.sin(theta) - half-h

        // Check shape/bounds
        if not in-bounds(try-x, try-y, ww, wh) { continue }

        // Check AABB overlap with all placed words
        let clear = placed.all(p =>
          try-x + ww <= p.x or p.x + p.w <= try-x or
          try-y + wh <= p.y or p.y + p.h <= try-y)

        if clear {
          px = try-x
          py = try-y
          found = true
          break
        }
      }

      if found {
        placed.push((x: px, y: py, w: ww, h: wh, word: wd))
      } else if strict {
        break
      }
    }
    placed
  }

  // Every word is wanted: shrink the cloud (big words first, in proportion)
  // until all fit; only words that still do not fit with every word at the
  // legible floor are left out, smallest first. The size asked for goes first
  // if the words could fill that little of the shape. After that each try is
  // sized by area, from how much of the shape a spiral typically fills, and
  // the next one is smaller by the area that was too much.
  let shape-area = iw * ih * (if shape == "circle" { 0.785 } else if shape == "rectangle" { 1.0 } else { 0.5 })
  let area-at(scale) = words-at(scale).map(w => w.w * w.h).sum()
  let scale-for(area) = {
    let best = 0.0
    for k in range(20, 0, step: -1) {
      if area-at(k / 20) <= area { best = k / 20; break }
    }
    best
  }
  let placed = ()
  if area-at(1.0) <= 0.85 * shape-area {
    placed = place-words(words-at(1.0), strict: true)
  }
  if placed.len() < n-words {
    placed = ()
    let limit = shape-area * (if shape == "rectangle" { 0.6 } else if shape == "circle" { 0.55 } else { 0.42 })
    for _ in range(8) {
      let scale = scale-for(limit)
      let tried = place-words(words-at(scale), strict: scale > 0)
      if scale == 0 or tried.len() == n-words {
        placed = tried
        break
      }
      limit = area-at(scale) * 0.85
    }
    // (eight rounds did not reach the floor: whatever fits there)
    if placed.len() == 0 { placed = place-words(words-at(0.0)) }
  }

  // Render all placed words
  chart-container(width, height, title, t)[
    #box(width: width, height: height, clip: true, inset: padding)[
      #for p in placed {
        let wd = p.word
        place(left + top,
          dx: p.x * 1pt, dy: p.y * 1pt,
          box(width: p.w * 1pt, height: p.h * 1pt,
            align(center + horizon,
              text(size: wd.size * 1pt, fill: wd.color, weight: wd.fw)[#wd.text])))
      }
    ]
  ]
  })
}
