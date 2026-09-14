// wordcloud.typ - Word cloud chart (spiral placement with collision detection)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero
#import "../validate.typ": validate-wordcloud-data
#import "../primitives/container.typ": chart-container

/// Renders a word cloud using spiral placement (Wordle-style algorithm).
///
/// Words are placed largest-first, spiraling outward from the center.
/// Each word is tested for AABB collision with all previously placed words
/// and shape boundary containment before being committed.
///
/// - data (dictionary): Must contain a `words` array of dictionaries,
///   each with `text` (string) and `weight` (number) keys.
/// - width (length): Chart width
/// - height (length): Chart height
/// - min-size (length): Font size for the lowest-weight word
/// - max-size (length): Font size for the highest-weight word
/// - title (none, content): Optional chart title
/// - padding (length): Inner padding around the word area
/// - shape (str): Layout shape — `"rectangle"` (default),
///   `"circle"`, `"diamond"`, or `"triangle"`
/// - theme (none, dictionary): Theme overrides
/// -> content
#let word-cloud(
  data,
  width: 300pt,
  height: 200pt,
  min-size: 8pt,
  max-size: 36pt,
  title: none,
  padding: 8pt,
  shape: "rectangle",
  theme: none,
) = context {
  validate-wordcloud-data(data, "word-cloud")
  let t = _resolve-ctx(theme)
  let words = data.words

  if words.len() == 0 { return }

  // Sort by weight descending — largest words placed first
  let sorted-words = words.sorted(key: w => -w.weight)

  let max-weight = sorted-words.at(0).weight
  let min-weight = sorted-words.last().weight
  let weight-range = nonzero(max-weight - min-weight)

  // Font weight alternation for visual variety
  let font-weights = ("bold", "regular", "bold", "medium", "regular")

  // Resolve relative lengths (e.g. 100%) via layout()
  if type(width) != length or type(height) != length {
    return layout(size => {
      let abs-w = if type(width) == length { width } else { size.width }
      let abs-h = if type(height) == length { height } else { size.height }
      word-cloud(data, width: abs-w, height: abs-h, min-size: min-size, max-size: max-size,
        title: title, padding: padding, shape: shape, theme: theme)
    })
  }

  let inner-w = width - 2 * padding
  let inner-h = height - 2 * padding
  let cx = inner-w / 2
  let cy = inner-h / 2

  // Shape width at a given y-fraction (0 = top, 1 = bottom)
  let shape-width-at(y-frac) = {
    let dy = y-frac - 0.5
    if shape == "circle" {
      let tt = 2 * dy
      let sq = 1.0 - tt * tt
      if sq <= 0 { 0pt } else { inner-w * calc.sqrt(sq) }
    } else if shape == "diamond" {
      let tt = calc.abs(2 * dy)
      inner-w * calc.max(0, 1 - tt)
    } else if shape == "triangle" {
      inner-w * y-frac
    } else {
      inner-w
    }
  }

  // Check if bbox (x, y, w, h) fits within shape boundary
  let in-bounds(bx, by, bw, bh) = {
    if bx < 0pt or by < 0pt or bx + bw > inner-w or by + bh > inner-h {
      false
    } else if shape == "rectangle" {
      true
    } else {
      // All 4 corners must be inside the shape
      let corners = ((bx, by), (bx + bw, by), (bx, by + bh), (bx + bw, by + bh))
      let mid = inner-w / 2
      corners.all(c => {
        let yf = calc.max(0, calc.min(1, c.at(1) / inner-h))
        let half = shape-width-at(yf) / 2
        c.at(0) >= mid - half and c.at(0) <= mid + half
      })
    }
  }

  // Pre-compute word data with measured dimensions
  let word-data = sorted-words.enumerate().map(((i, w)) => {
    let frac = (w.weight - min-weight) / weight-range
    let sz = min-size + frac * (max-size - min-size)
    let color = get-color(t, i)
    let fw = font-weights.at(calc.rem(i, font-weights.len()))
    let content = text(size: sz, weight: fw)[#w.text]
    let dims = measure(content)
    (text: w.text, font-size: sz, color: color, fw: fw,
     w: dims.width + 8pt, h: dims.height + 4pt)
  })

  // Spiral placement with AABB collision detection
  // Each word spirals outward from center until a non-overlapping position is found
  let placed = ()
  let spiral-res = calc.max(1pt, calc.min(inner-w, inner-h) / 120)
  let theta-step = 18deg  // 20 points per revolution
  let max-spiral = calc.max(inner-w, inner-h)

  for (wi, wd) in word-data.enumerate() {
    let half-w = wd.w / 2
    let half-h = wd.h / 2
    let found = false
    let px = 0pt
    let py = 0pt

    // Golden angle offset per word for natural distribution
    let offset = wi * 137.5deg

    for step in range(500) {
      let theta = step * theta-step + offset
      let r = step * spiral-res
      if r > max-spiral { break }

      let try-x = cx + r * calc.cos(theta) - half-w
      let try-y = cy + r * calc.sin(theta) - half-h

      // Check shape/bounds
      if not in-bounds(try-x, try-y, wd.w, wd.h) { continue }

      // Check AABB overlap with all placed words
      let clear = placed.all(p =>
        try-x + wd.w <= p.x or p.x + p.w <= try-x or
        try-y + wd.h <= p.y or p.y + p.h <= try-y)

      if clear {
        px = try-x
        py = try-y
        found = true
        break
      }
    }

    if found {
      placed.push((x: px, y: py, w: wd.w, h: wd.h, word: wd))
    }
  }

  // Render all placed words
  chart-container(width, height, title, t, extra-height: 10pt)[
    #box(width: width, height: height, clip: true, inset: padding)[
      #for p in placed {
        let wd = p.word
        place(left + top,
          dx: p.x, dy: p.y,
          box(width: wd.w, height: wd.h,
            align(center + horizon,
              text(size: wd.font-size, fill: wd.color, weight: wd.fw)[#wd.text])))
      }
    ]
  ]
}
