// exam-boxes.typ
// Reusable components inspired by the supplied Arabic mathematics examination.
// The page furniture is Scrawl-based; the geometry diagram is drawn through
// ctz-euclide as explicitly requested.

#import "../vendor/scrawl/lib.typ": scrawl, rounded-rect-pts
#import "@preview/ctz-euclide:0.2.0": *

#let exam-palette = (
  red: rgb("#FF4C38"),
  red-dark: rgb("#E9392A"),
  red-pale: rgb("#FFD9D2"),
  red-mid: rgb("#FF9A8D"),
  ink: rgb("#171717"),
  paper: rgb("#FFFEFC"),
  rule: rgb("#D9D0CA"),
)

#let exam-style(mode: "normal", roughness: 1.0, dir: rtl, seed: 1) = (
  mode: mode,
  roughness: roughness,
  dir: dir,
  seed: seed,
)

#let _exam-resolve-width(width, available) = {
  if type(width) == ratio { available * width }
  else if width == auto { available }
  else { width }
}

#let _exam-rel(value, basis) = if type(value) == ratio { basis * value } else { value }
#let _exam-num(value, basis) = if type(value) == ratio { basis * value / 100% } else { value }
#let _exam-inset-values(inset) = {
  if type(inset) == length {
    return (left: inset, right: inset, top: inset, bottom: inset)
  }
  if type(inset) == dictionary {
    let x = inset.at("x", default: 0pt)
    let y = inset.at("y", default: x)
    return (
      left: inset.at("left", default: x),
      right: inset.at("right", default: x),
      top: inset.at("top", default: y),
      bottom: inset.at("bottom", default: y),
    )
  }
  (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt)
}
#let _exam-start(dir) = if dir == rtl { right } else { left }
#let _exam-flow(body, dir) = align(_exam-start(dir), text(dir: dir)[#body])

// ---------------------------------------------------------------------------
// Outer examination sheet frame
// ---------------------------------------------------------------------------
#let exam-page-frame(
  body,
  width: 100%,
  // Set `height: 100%` in a page entry to make the red frame span the whole
  // available page height rather than only the measured content height.
  height: auto,
  // Optional footer is anchored to the bottom of a full-page frame.
  footer: none,
  inset: (x: 1.15em, y: 1.0em),
  fill: exam-palette.paper,
  paint: exam-palette.red,
  radius: 1.2%,
  weight: .16%,
  dir: rtl,
  mode: "normal",
  roughness: 1.0,
  seed: 2101,
) = layout(area => {
  let total-w = _exam-resolve-width(width, area.width)
  let inner = block(width: total-w, inset: inset, _exam-flow(body, dir))
  let m = measure(inner)
  let wanted-h = if height == auto { m.height }
    else if type(height) == ratio { area.height * height }
    else { height }
  let total-h = calc.max(m.height, wanted-h)
  let w = m.width / 1cm
  let h = total-h / 1cm
  let line = _exam-rel(weight, m.width)
  let corner = _exam-num(radius, calc.min(w, h))
  let canvas = scrawl(width: m.width, height: total-h, hand: mode == "rough",
    roughness: roughness, seed: seed,
    (shape, ..) => shape(
      rounded-rect-pts((0, 0), (w, h), radius: corner),
      fill: fill, paint: paint, weight: line, seed: seed,
    ),
  )
  let pad = _exam-inset-values(inset)
  block(width: m.width, height: total-h, {
    place(top + left, canvas)
    place(top + left, inner)
    if footer != none {
      place(bottom + left, dx: pad.left,
        box(width: m.width - pad.left - pad.right, footer))
    }
  })
})

// ---------------------------------------------------------------------------
// Header, warning and footer
// ---------------------------------------------------------------------------
#let _exam-left-arrow(x0, x1, y0, y1, tip) = (
  (x0, y0), (x1, y0), (x1, y1), (x0, y1), (x0 - tip, (y0 + y1) / 2),
)

// Rounded polygon contour: it takes the hard triangular tip off each arrow
// while retaining the clearly left-pointing construction of the source model.
#let _exam-smooth(points, radius: .12, samples: 5) = {
  let n = points.len()
  let out = ()
  for i in range(n) {
    let prev = points.at(calc.rem(i - 1 + n, n))
    let cur = points.at(i)
    let next = points.at(calc.rem(i + 1, n))
    let d0 = calc.sqrt(calc.pow(prev.at(0) - cur.at(0), 2)
      + calc.pow(prev.at(1) - cur.at(1), 2))
    let d1 = calc.sqrt(calc.pow(next.at(0) - cur.at(0), 2)
      + calc.pow(next.at(1) - cur.at(1), 2))
    let d = calc.min(radius, d0 * .28, d1 * .28)
    if d <= .001 { out.push(cur); continue }
    let a = (cur.at(0) + (prev.at(0) - cur.at(0)) * d / d0,
             cur.at(1) + (prev.at(1) - cur.at(1)) * d / d0)
    let b = (cur.at(0) + (next.at(0) - cur.at(0)) * d / d1,
             cur.at(1) + (next.at(1) - cur.at(1)) * d / d1)
    out.push(a)
    for j in range(1, samples + 1) {
      let t = j / samples
      let u = 1 - t
      out.push((u * u * a.at(0) + 2 * u * t * cur.at(0) + t * t * b.at(0),
        u * u * a.at(1) + 2 * u * t * cur.at(1) + t * t * b.at(1)))
    }
  }
  out
}

#let _exam-rounded-left-arrow(x0, x1, y0, y1, tip, round: auto) = {
  let radius = if round == auto { calc.min((y1 - y0) * .15, tip * .32) } else { round }
  _exam-smooth(_exam-left-arrow(x0, x1, y0, y1, tip), radius: radius)
}

// Three perfectly equal arrow boxes: their rectangular bodies share exactly
// the same width and alignment. Only their rounded tips recede by `gap`,
// producing the requested 2–3 mm colour spacing with zero inset/outset.
#let _exam-draw-arrow-stack(shape, x0, width, y0, y1, gap, tip, seed) = {
  shape(_exam-rounded-left-arrow(x0, x0 + width, y0, y1, tip + 2 * gap),
    fill: exam-palette.red-pale, paint: none, weight: 0pt, seed: seed)
  shape(_exam-rounded-left-arrow(x0, x0 + width, y0, y1, tip + gap),
    fill: exam-palette.red-mid, paint: none, weight: 0pt, seed: seed + 1)
  shape(_exam-rounded-left-arrow(x0, x0 + width, y0, y1, tip),
    fill: exam-palette.red, paint: none, weight: 0pt, seed: seed + 2)
}

// Header arrow with a true rounded rectangular right edge. Its body can meet
// the enclosing header frame exactly, while its gently rounded wedge projects
// only on the left.
#let _exam-header-arrow(shape, x0, x1, y0, y1, tip, right-round, fill, seed) = {
  let mid = (y0 + y1) / 2
  let left-round = calc.min((y1 - y0) * .18, tip * .45)
  let wedge = _exam-smooth((
    (x0 + left-round, y0 + left-round),
    (x0 - tip, mid),
    (x0 + left-round, y1 - left-round),
    (x0 + left-round * .7, y1 - left-round * .3),
    (x0 + left-round * .7, y0 + left-round * .3),
  ), radius: left-round * .55)
  shape(wedge, fill: fill, paint: none, weight: 0pt, seed: seed)
  shape(rounded-rect-pts((x0, y0), (x1, y1), radius: right-round),
    fill: fill, paint: none, weight: 0pt, seed: seed + 1)
}

// Two-line header. The duration is intentionally handled by `exam-duration`
// outside this block, as in the supplied subject.
#let exam-header(
  school: [متوسطة عيسات إيدير],
  year: [2024 - 2025],
  title: [اختبار الفصل الأول في الرياضيات],
  level-label: [المستوى],
  level-value: [1 متوسط],
  width: 100%,
  header-height: 8.8%,
  // Equal-width arrows stagger by this small amount (2–3 mm by default).
  arrow-gap: 3mm,
  dir: rtl,
  mode: "normal",
  roughness: 1.0,
  seed: 2201,
) = layout(area => {
  let total-w = _exam-resolve-width(width, area.width)
  let total-h = _exam-rel(header-height, total-w)
  let w = total-w / 1cm
  let h = total-h / 1cm
  let school-text = text(dir: dir, size: .86em, fill: exam-palette.ink)[#school]
  let year-text = text(dir: ltr, size: .84em, fill: exam-palette.ink)[#year]
  let title-text = text(dir: dir, size: 1.26em, weight: "bold", fill: exam-palette.ink)[#title]
  // Kept separately so the two lines can breathe inside the level arrow.
  let level-label-text = text(dir: dir, size: .80em, weight: "bold", fill: white)[#level-label]
  let level-value-text = text(dir: dir, size: .88em, weight: "bold", fill: white)[#level-value]
  let line = total-w * .15%
  // The front arrow width follows the actual two-line label plus its padding.
  let label-pad = measure(box(width: .65em)).width
  let level-content-width = calc.max(measure(level-label-text).width,
    measure(level-value-text).width)
  let front-width = (level-content-width + 2 * label-pad) / 1cm
  let gap = if type(arrow-gap) == ratio { w * arrow-gap / 100% } else { arrow-gap / 1cm }
  let front-left = w - front-width
  let mid-left = front-left - gap
  let back-left = front-left - 2 * gap
  let frame-round = .045 * h
  let tip = calc.min(h * .20, front-width * .18)
  let canvas = scrawl(width: total-w, height: total-h, hand: mode == "rough",
    roughness: roughness, seed: seed,
    (shape, ..) => {
      // One compact two-line rectangular header.
      shape(rounded-rect-pts((0, 0), (w, h), radius: .045 * h),
        fill: white, paint: exam-palette.red, weight: line, seed: seed)
      // Each arrow ends on the header's right, top and bottom edges. Their
      // left bases are parallel and separated by exactly `arrow-gap`.
      _exam-header-arrow(shape, back-left, w, 0, h, tip, frame-round,
        exam-palette.red-pale, seed + 11)
      _exam-header-arrow(shape, mid-left, w, 0, h, tip, frame-round,
        exam-palette.red-mid, seed + 12)
      _exam-header-arrow(shape, front-left, w, 0, h, tip, frame-round,
        exam-palette.red, seed + 13)
      // Redraw the enclosing rule above the arrows: the header remains framed.
      shape(rounded-rect-pts((0, 0), (w, h), radius: frame-round),
        fill: none, paint: exam-palette.red, weight: line, seed: seed + 14)
    },
  )
  block(width: total-w, height: total-h, {
    place(top + left, canvas)
    // One last small leftward shift, while keeping both lines centred in the
    // same compact physical column.
    place(top + left, dx: 0pt, dy: total-h * 14%,
      box(width: total-w * 16%, align(center, school-text)))
    place(top + left, dx: 0pt, dy: total-h * 55%,
      box(width: total-w * 16%, align(center, year-text)))
    place(top + left, dx: total-w * 28%, dy: total-h * 24%,
      box(width: total-w * 40%, align(center, title-text)))
    // Wider leading and larger type: the title rises while the level descends.
    place(top + left, dx: (front-left + front-width * .12) * 1cm,
      dy: total-h * 12%,
      box(width: front-width * .76cm, height: total-h * .23,
        align(center + horizon, level-label-text)))
    place(top + left, dx: (front-left + front-width * .12) * 1cm,
      dy: total-h * 61%,
      box(width: front-width * .76cm, height: total-h * .23,
        align(center + horizon, level-value-text)))
  })
})

#let exam-duration(
  body: [المدة : 2 سا],
  width: 100%,
  dir: rtl,
) = block(width: width)[
  #align(left)[#text(dir: dir, size: .88em, fill: exam-palette.ink)[#body]]
]

#let exam-notice(
  body: [⚠ الآلة الحاسبة ممنوعة],
  width: 100%,
  dir: rtl,
  color: exam-palette.red-dark,
) = {
  let message = text(dir: dir, weight: "bold", size: .90em, fill: color)[#body]
  block(width: width, align(center, message))
}

// Duration on the physical left and calculator notice in the middle, matching
// the single metadata line beneath the header in the source model.
#let exam-meta-line(
  duration: [المدة : 2 سا],
  notice: [⚠ الآلة الحاسبة ممنوعة],
  width: 100%,
  dir: rtl,
) = layout(area => {
  let total-w = _exam-resolve-width(width, area.width)
  let duration-text = text(dir: dir, size: .88em, fill: exam-palette.ink)[#duration]
  let notice-text = text(dir: dir, weight: "bold", size: .90em,
    fill: exam-palette.red-dark)[#notice]
  let h = calc.max(measure(duration-text).height, measure(notice-text).height)
  // Use placed physical columns so RTL flow cannot reverse their order:
  // duration stays at left, notice is centred on the same baseline.
  block(width: total-w, height: h, {
    place(top + left,
      box(width: total-w * 28%, align(left, duration-text)))
    place(top + left, dx: total-w * 31%,
      box(width: total-w * 38%, align(center, notice-text)))
  })
})

#let exam-footer(
  footer-left: [↩ اقلب الورقة],
  footer-center: [صفحة 1 من 2],
  footer-right: [☺ ركز جيدًا],
  width: 100%,
  dir: rtl,
) = block(width: width)[
  #grid(columns: (1fr, 1fr, 1fr),
    [#align(left)[#text(dir: dir, size: .78em, weight: "bold")[#footer-left]]],
    [#align(center)[#text(dir: ltr, size: .78em)[#footer-center]]],
    [#align(right)[#text(dir: dir, size: .78em, weight: "bold")[#footer-right]]],
  )
]

// ---------------------------------------------------------------------------
// Exercise ribbon and content panel
// ---------------------------------------------------------------------------
#let exam-exercise-ribbon(
  title: [التمرين الأول],
  points: [3 ن],
  width: auto,
  // The same 3 mm layer spacing and rounded arrow profile as the header.
  arrow-gap: 3mm,
  dir: rtl,
  mode: "normal",
  roughness: 1.0,
  seed: 2301,
) = layout(area => {
  let label = text(dir: dir, size: 1.04em, weight: "bold", fill: white)[#title : (#points)]
  let lm = measure(label)
  let label-pad = measure(box(width: .55em)).width
  let total-h = lm.height + measure(box(height: .65em)).height * 2
  let h = total-h / 1cm
  let gap-len = if type(arrow-gap) == ratio { area.width * arrow-gap } else { arrow-gap }
  let desired-front-w = lm.width + 2 * label-pad
  let tip-len = calc.min(total-h * .20, desired-front-w * .18)
  let total-w = if width == auto {
    desired-front-w + 2 * gap-len + tip-len
  } else { _exam-resolve-width(width, area.width) }
  let w = total-w / 1cm
  let gap = gap-len / 1cm
  let tip = tip-len / 1cm
  let front-width = if width == auto { desired-front-w / 1cm }
    else { w - 2 * gap - tip }
  let front-left = w - front-width
  let mid-left = front-left - gap
  let back-left = front-left - 2 * gap
  let pad-num = label-pad / 1cm
  let frame-round = .045 * h
  let canvas = scrawl(width: total-w, height: total-h, hand: mode == "rough",
    roughness: roughness, seed: seed,
    (shape, ..) => {
      _exam-header-arrow(shape, back-left, w, 0, h, tip, frame-round,
        exam-palette.red-pale, seed)
      _exam-header-arrow(shape, mid-left, w, 0, h, tip, frame-round,
        exam-palette.red-mid, seed + 1)
      _exam-header-arrow(shape, front-left, w, 0, h, tip, frame-round,
        exam-palette.red, seed + 2)
    },
  )
  block(width: total-w, height: total-h, {
    place(top + left, canvas)
    place(top + left, dx: (front-left + pad-num) * 1cm,
      dy: (total-h - lm.height) / 2,
      box(width: (front-width - 2 * pad-num) * 1cm, align(center, label)))
  })
})

#let exam-exercise-box(
  body,
  title: [التمرين الأول],
  points: [3 ن],
  width: 100%,
  inset: (x: .25em, top: .25em, bottom: .45em),
  ribbon-width: auto,
  arrow-gap: 3mm,
  dir: rtl,
  mode: "normal",
  roughness: 1.0,
  seed: 2401,
) = layout(area => {
  let total-w = _exam-resolve-width(width, area.width)
  let ribbon = exam-exercise-ribbon(title: title, points: points,
    width: ribbon-width, arrow-gap: arrow-gap, dir: dir, mode: mode,
    roughness: roughness, seed: seed)
  let rm = measure(ribbon)
  let gap = measure(box(height: .65em)).height
  let pad = _exam-inset-values(inset)
  let inner = block(width: total-w,
    inset: (left: pad.left, right: pad.right,
      top: rm.height + gap + pad.top, bottom: pad.bottom),
    _exam-flow(body, dir),
  )
  let m = measure(inner)
  block(width: m.width, height: m.height, {
    place(top + right, ribbon)
    place(top + left, inner)
  })
})

// ---------------------------------------------------------------------------
// ctz-euclide geometry figure matching page 2 of the supplied model
// ---------------------------------------------------------------------------
#let exam-problem-box = exam-exercise-box
#let exam-integration-box = exam-exercise-box.with(title: [الوضعية الإدماجية])

#let exam-circle-geometry(
  width: 100%,
  ink: exam-palette.ink,
  // Kept for uniform `..exam-style(...)` spreading; labels are geometric.
  dir: auto,
  mode: "normal",
  roughness: 1.0,
  seed: 2501,
) = layout(area => {
  let target-w = _exam-resolve-width(width, area.width)
  let unit = target-w / 8.6
  let stroke-len = target-w * .22%
  let sketch = mode == "rough"
  let figure = ctz-canvas(length: unit, clip-canvas: (-.45, -.60, 8.15, 6.10), {
    import cetz.draw: *
    ctz-init()
    ctz-style(point: (shape: "cross", size: .068, stroke: ink + stroke-len))
    ctz-def-points(
      A: (3.8, 2.8), D: (.8, 2.8), B: (6.8, 2.8),
      E: (3.8, -.2), C: (5.45, 5.3),
    )
    let segment(a, b, index) = ctz-draw(
      segment: (a, b), stroke: ink + stroke-len,
      sketchy: sketch, roughness: roughness, seed: seed + index,
    )
    ctz-draw(circle-r: ("A", 3), stroke: ink + stroke-len,
      sketchy: sketch, roughness: roughness, seed: seed + 1)
    segment("D", "B", 10)
    segment("D", "C", 20)
    segment("C", "B", 30)
    segment("C", "A", 40)
    segment("D", "E", 50)
    segment("A", "E", 60)
    ctz-draw-mark-segment("D", "A", mark: 2, size: .13, thickness: stroke-len)
    ctz-draw-mark-segment("A", "B", mark: 2, size: .13, thickness: stroke-len)
    ctz-draw-mark-segment("C", "A", mark: 2, size: .13, thickness: stroke-len)
    ctz-draw-mark-segment("C", "B", mark: 2, size: .13, thickness: stroke-len)
    ctz-draw-mark-segment("A", "E", mark: 2, size: .13, thickness: stroke-len)
    ctz-draw-mark-right-angle("D", "A", "E", size: .22, color: ink)
    ctz-draw-points("A", "B", "C", "D", "E")
    ctz-draw-labels("A", "B", "C", "D", "E",
      A: "below", B: "right", C: "above", D: "left", E: "below")
  })
  align(center, figure)
})
