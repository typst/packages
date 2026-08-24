// wexam-boxes.typ
// A Typst recreation of the decorative Arabic `sexam` / Wexam model supplied
// by the user. All decoration is vector-based and can switch to Scrawl rough.

#import "../vendor/scrawl/lib.typ": scrawl, rounded-rect-pts, circle-pts
#import "@preview/ctz-euclide:0.2.0": *

#let wexam-palette = (
  blue: rgb("#00A3F3"),
  blue-dark: rgb("#008FCB"),
  blue-pale: rgb("#EAF9FF"),
  blue-line: rgb("#9EDDF3"),
  yellow: rgb("#FFD128"),
  red: rgb("#E83322"),
  ink: rgb("#151515"),
  grey: rgb("#5B5B5B"),
  paper: rgb("#FFFEFC"),
  door: rgb("#EEE2F7"),
)

#let wexam-style(mode: "normal", roughness: 1.0, dir: rtl, seed: 1) = (
  mode: mode,
  roughness: roughness,
  dir: dir,
  seed: seed,
)

#let _wexam-resolve-width(width, available) = {
  if type(width) == ratio { available * width }
  else if width == auto { available }
  else { width }
}
#let _wexam-flow(body, dir) = align(if dir == rtl { right } else { left }, text(dir: dir)[#body])
#let _wexam-star(center, outer, inner, rotation: 0deg) = {
  let out = ()
  for i in range(10) {
    let r = if calc.rem(i, 2) == 0 { outer } else { inner }
    let a = rotation + i * 36deg - 90deg
    out.push((center.at(0) + r * calc.cos(a), center.at(1) + r * calc.sin(a)))
  }
  out
}

// ---------------------------------------------------------------------------
// Decorative first-page header.
// ---------------------------------------------------------------------------
#let wexam-header(
  republic: [الجمهورية الجزائرية الديمقراطية الشعبية],
  school: [متوسطة : عيسات إيدير],
  level: [🎓 المستوى : السنة ② متوسط],
  title: [اختبار الفصل الثاني في الرياضيات],
  year: [2023 – 2024],
  duration: [المدة : 02 سا],
  width: 100%,
  header-height: 17%,
  dir: rtl,
  mode: "normal",
  roughness: 1.0,
  seed: 6101,
) = layout(area => {
  let total-w = _wexam-resolve-width(width, area.width)
  let total-h = if type(header-height) == ratio { total-w * header-height } else { header-height }
  let w = total-w / 1cm
  let h = total-h / 1cm
  let line = total-w * .10%
  let republic-text = text(dir: dir, size: 1.03em, weight: "bold")[#republic]
  let school-text = text(dir: dir, size: .94em, weight: "bold")[#school]
  let level-text = text(dir: dir, size: .94em, weight: "bold")[#level]
  let title-text = text(dir: dir, size: 1.35em, weight: "bold", fill: wexam-palette.blue-dark)[#title]
  let year-text = text(dir: ltr, size: .90em)[#year]
  let duration-text = text(dir: dir, size: .90em)[#duration]
  let clock-text = text(dir: ltr, size: .92em, weight: "bold")[◷]
  let canvas = scrawl(width: total-w, height: total-h, hand: mode == "rough",
    roughness: roughness, seed: seed,
    (shape, ..) => {
      // Star-patterned cyan banner.
      shape(((0, .15 * h), (w, .15 * h), (w, .55 * h), (0, .55 * h)),
        fill: wexam-palette.blue-pale, paint: none, weight: 0pt, seed: seed)
      // Keep every star safely inside the blue band: no overflow at right.
      for ix in range(15) {
        for iy in range(3) {
          let x = .04 * w + ix * .064 * w + calc.rem(iy, 2) * .020 * w
          let y = .21 * h + iy * .11 * h
          shape(_wexam-star((x, y), .010 * w, .0045 * w, rotation: 18deg),
            fill: wexam-palette.blue-line, paint: none, weight: 0pt,
            seed: seed + ix * 11 + iy)
        }
      }
      // White title, year and duration cards set on the patterned band.
      shape(rounded-rect-pts((.31 * w, .20 * h), (.70 * w, .50 * h), radius: .025 * h),
        fill: white, paint: none, weight: 0pt, seed: seed + 100)
      shape(rounded-rect-pts((.77 * w, .22 * h), (.96 * w, .48 * h), radius: .025 * h),
        fill: white, paint: none, weight: 0pt, seed: seed + 101)
      shape(rounded-rect-pts((.04 * w, .22 * h), (.23 * w, .48 * h), radius: .025 * h),
        fill: white, paint: none, weight: 0pt, seed: seed + 102)
      // A fine blue separator below the header.
      shape(((0, .10 * h), (w, .10 * h)), closed: false,
        paint: wexam-palette.blue-line, weight: line, seed: seed + 103)
    },
  )
  block(width: total-w, height: total-h, {
    place(top + left, canvas)
    place(top + left, dy: total-h * 1%, box(width: total-w, align(center, republic-text)))
    place(top + right, dy: total-h * 18%, box(width: total-w * 32%, align(right, school-text)))
    place(top + left, dx: total-w * 4%, dy: total-h * 18%, box(width: total-w * 38%, align(left, level-text)))
    // Cards occupy the lower patterned band (not the upper school-information rows).
    place(top + left, dx: total-w * 31%, dy: total-h * 57%, box(width: total-w * 39%, align(center, title-text)))
    place(top + left, dx: total-w * 78%, dy: total-h * 59%, box(width: total-w * 17%, align(center, year-text)))
    // Duration is centred in its own white card; clock is physically at right.
    place(top + left, dx: total-w * 5.5%, dy: total-h * 59%, box(width: total-w * 12.5%, align(center, duration-text)))
    place(top + left, dx: total-w * 19.0%, dy: total-h * 59%, box(width: total-w * 2.5%, align(center, clock-text)))
  })
})

#let wexam-notice(
  body: [تجنب الشطب و استعمال المصحح.],
  width: 100%,
  dir: rtl,
) = layout(area => {
  let total-w = _wexam-resolve-width(width, area.width)
  let message = text(dir: dir, size: .90em)[#body]
  let danger = text(size: .95em, weight: "bold", fill: wexam-palette.red)[⚠]
  let mm = measure(message)
  let dm = measure(danger)
  let gap = measure(box(width: .35em)).width
  let group-w = mm.width + gap + dm.width
  let x = (total-w - group-w) / 2
  let h = calc.max(mm.height, dm.height)
  block(width: total-w, height: h, {
    // Text first, red danger panel physically to its right.
    place(top + left, dx: x, box(width: mm.width, height: h, align(center + horizon, message)))
    place(top + left, dx: x + mm.width + gap, box(width: dm.width, height: h, align(center + horizon, danger)))
  })
})

// ---------------------------------------------------------------------------
// Exercise heading with blue rule, rounded white pill, pencil and info badge.
// ---------------------------------------------------------------------------
#let wexam-exercise-heading(
  title: [التمرين الأول],
  points: [3 ن],
  width: 100%,
  dir: rtl,
  mode: "normal",
  roughness: 1.0,
  seed: 6201,
) = layout(area => {
  let total-w = _wexam-resolve-width(width, area.width)
  let label = text(dir: dir, size: 1.05em, fill: wexam-palette.ink)[✎ #title : #text(fill: wexam-palette.red)[(#points)]]
  let lm = measure(label)
  let pad = measure(box(width: .8em)).width
  let pill-w = lm.width + 2 * pad
  let total-h = lm.height + measure(box(height: .62em)).height
  let w = total-w / 1cm
  let h = total-h / 1cm
  let pill = pill-w / 1cm
  let canvas = scrawl(width: total-w, height: total-h, hand: mode == "rough",
    roughness: roughness, seed: seed,
    (shape, ..) => {
      shape(((0, .50 * h), (w, .50 * h)), closed: false,
        paint: wexam-palette.blue-line, weight: total-w * .15%, seed: seed)
      shape(rounded-rect-pts((w - pill, .08 * h), (w - .055 * h, .92 * h), radius: .42 * h),
        fill: white, paint: wexam-palette.blue-line, weight: total-w * .10%, seed: seed + 1)
      shape(circle-pts((w - .018 * w, .50 * h), .045 * h),
        fill: wexam-palette.yellow, paint: wexam-palette.blue, weight: total-w * .08%, seed: seed + 2)
    },
  )
  block(width: total-w, height: total-h, {
    place(top + left, canvas)
    place(top + left, dx: total-w - pill-w, dy: (total-h - lm.height) / 2,
      box(width: pill-w - measure(box(width: .08em)).width, align(center, label)))
    place(top + right, dx: -total-w * 1%, dy: (total-h - measure(text(size: .72em)[i]).height) / 2,
      box(width: total-w * 4%, align(center, text(size: .72em, weight: "bold")[i])))
  })
})

#let wexam-number-box(
  label: "1",
  width: auto,
  inset: (x: .30em, y: .14em),
  mode: "normal",
  roughness: 1.0,
  seed: 6301,
) = layout(area => {
  let label-text = text(dir: ltr, size: .90em, fill: wexam-palette.blue-dark)[#label]
  let lm = measure(label-text)
  let pad-x = measure(box(width: inset.at("x", default: 0pt))).width
  let pad-y = measure(box(height: inset.at("y", default: 0pt))).height
  let total-w = if width == auto { lm.width + 2 * pad-x } else { _wexam-resolve-width(width, area.width) }
  let total-h = lm.height + 2 * pad-y
  let w = total-w / 1cm
  let h = total-h / 1cm
  let canvas = scrawl(width: total-w, height: total-h, hand: mode == "rough",
    roughness: roughness, seed: seed,
    (shape, ..) => shape(((0, 0), (w, 0), (w, h), (0, h)),
      fill: white, paint: wexam-palette.blue-line, weight: total-w * .10%, seed: seed),
  )
  block(width: total-w, height: total-h, {
    place(top + left, canvas)
    place(top + left, dx: pad-x, dy: pad-y,
      box(width: lm.width, height: lm.height, align(center + horizon, label-text)))
  })
})

#let wexam-question(
  body,
  number: none,
  width: 100%,
  number-gap: .8em,
  dir: rtl,
  mode: "normal",
  roughness: 1.0,
  seed: 6401,
) = layout(area => {
  let total-w = _wexam-resolve-width(width, area.width)
  let badge = if number == none { none } else {
    wexam-number-box(label: str(number), mode: mode, roughness: roughness, seed: seed)
  }
  let bm = if badge == none { (width: 0pt, height: 0pt) } else { measure(badge) }
  let gap = if badge == none { 0pt } else { measure(box(width: number-gap)).width }
  let content = block(width: total-w - bm.width - gap, _wexam-flow(body, dir))
  let cm = measure(content)
  let total-h = calc.max(cm.height, bm.height)
  block(width: total-w, height: total-h, {
    if badge != none { place(top + right, dy: (total-h - bm.height) / 2, badge) }
    place(top + left, dy: (total-h - cm.height) / 2, content)
  })
})

#let wexam-footer(
  footer-left: [اقلب الورقة ↩],
  footer-center: [صفحة 1 من 2],
  footer-right: [ركز جيدًا ☺],
  width: 100%,
  dir: rtl,
  mode: "normal",
  roughness: 1.0,
  seed: 6501,
) = layout(area => {
  let total-w = _wexam-resolve-width(width, area.width)
  let left-text = text(dir: dir, size: .86em, weight: "bold", fill: wexam-palette.blue-dark)[#footer-left]
  let center-text = text(dir: ltr, size: .86em, weight: "bold")[#footer-center]
  let right-text = text(dir: dir, size: .86em, weight: "bold", fill: wexam-palette.ink)[#footer-right]
  let rh = calc.max(measure(left-text).height, measure(center-text).height, measure(right-text).height)
  let gap = measure(box(height: .38em)).height
  let total-h = rh + gap
  let w = total-w / 1cm
  let h = total-h / 1cm
  let canvas = scrawl(width: total-w, height: total-h, hand: mode == "rough",
    roughness: roughness, seed: seed,
    (shape, ..) => shape(((0, h), (w, h)), closed: false,
      paint: wexam-palette.grey, weight: total-w * .10%, seed: seed),
  )
  block(width: total-w, height: total-h, {
    place(top + left, canvas)
    place(top + left, dy: gap, box(width: total-w * 28%, align(left, left-text)))
    place(top + left, dx: total-w * 35%, dy: gap, box(width: total-w * 30%, align(center, center-text)))
    place(top + right, dy: gap, box(width: total-w * 28%, align(right, right-text)))
  })
})

#let wexam-page(
  body,
  footer: none,
  width: 100%,
  height: auto,
  dir: rtl,
  mode: "normal",
  roughness: 1.0,
  seed: 1,
) = layout(area => {
  let total-w = _wexam-resolve-width(width, area.width)
  let inner = block(width: total-w, _wexam-flow(body, dir))
  let im = measure(inner)
  let footer-h = if footer == none { 0pt } else { measure(box(height: 1.4em)).height }
  let gap = if footer == none { 0pt } else { measure(box(height: .5em)).height }
  let wanted-h = if height == auto { im.height + footer-h + gap }
    else if type(height) == ratio { area.height * height }
    else { height }
  let total-h = calc.max(wanted-h, im.height + footer-h + gap)
  block(width: total-w, height: total-h, {
    place(top + left, inner)
    if footer != none { place(bottom + left, box(width: total-w, footer)) }
  })
})

// ---------------------------------------------------------------------------
// Geometry figures from the supplied 2AM examination (ctz-euclide).
// ---------------------------------------------------------------------------
#let wexam-angle-figure(
  width: 100%,
  // Accepted for uniform `..wexam-style(...)` spreading.
  dir: auto,
  mode: "normal",
  roughness: 1.0,
  seed: 6601,
) = layout(area => {
  let target-w = _wexam-resolve-width(width, area.width)
  let unit = target-w / 6.5
  let stroke-len = target-w * .20%
  let sketch = mode == "rough"
  let figure = ctz-canvas(length: unit, clip-canvas: (-.5, -.6, 6.0, 5.2), {
    import cetz.draw: *
    ctz-init()
    ctz-style(point: (shape: "dot", size: .045, stroke: wexam-palette.ink + stroke-len))
    ctz-def-points(
      A: (1.6, 2.3), D: (1.6, 4.6), E: (1.6, .25), B: (4.7, 2.3), C: (3.95, 3.65),
      H: (.25, 2.3), P: (.25, 1.52), Q: (.35, -.58),
    )
    let seg(a, b, i) = ctz-draw(segment: (a, b), stroke: wexam-palette.ink + stroke-len,
      sketchy: sketch, roughness: roughness, seed: seed + i)
    // The three geometric lines deliberately continue to the left of A/E.
    seg("D", "E", 1)
    seg("H", "B", 2)
    seg("P", "C", 3)
    seg("Q", "B", 4)
    ctz-draw-mark-right-angle("D", "A", "B", size: .20, color: wexam-palette.ink)
    ctz-draw-angle("A", "D", "C", label: [55°], radius: .45)
    ctz-draw-angle("B", "A", "E", label: [35°], radius: .42)
    ctz-draw-points("A", "B", "C", "D", "E")
    ctz-draw-labels("A", "B", "C", "D", "E", A: "below", B: "below", C: "above", D: "left", E: "below")
  })
  align(center, figure)
})

#let wexam-house-figure(
  width: 100%,
  // Accepted for uniform `..wexam-style(...)` spreading.
  dir: auto,
  mode: "normal",
  roughness: 1.0,
  seed: 6701,
) = layout(area => {
  let target-w = _wexam-resolve-width(width, area.width)
  let unit = target-w / 7.2
  let stroke-len = target-w * .18%
  let sketch = mode == "rough"
  let figure = ctz-canvas(length: unit, clip-canvas: (-.6, -.8, 6.6, 7.0), {
    import cetz.draw: *
    ctz-init()
    ctz-style(point: (shape: "dot", size: .04, stroke: wexam-palette.ink + stroke-len))
    ctz-def-points(A: (.6, 3.1), B: (5.8, 3.1), C: (5.8, 0), D: (.6, 0), E: (3.2, 5.9), N: (3.2, 3.1))
    let seg(a, b, i) = ctz-draw(segment: (a, b), stroke: wexam-palette.ink + stroke-len,
      sketchy: sketch, roughness: roughness, seed: seed + i)
    seg("A", "B", 1); seg("B", "C", 2); seg("C", "D", 3); seg("D", "A", 4)
    seg("A", "E", 5); seg("E", "B", 6); seg("E", "N", 7)
    ctz-draw-mark-right-angle("D", "A", "B", size: .16, color: wexam-palette.ink)
    ctz-draw-mark-right-angle("A", "B", "C", size: .16, color: wexam-palette.ink)
    ctz-draw-mark-right-angle("B", "C", "D", size: .16, color: wexam-palette.ink)
    ctz-draw-mark-right-angle("C", "D", "A", size: .16, color: wexam-palette.ink)
    ctz-draw-mark-right-angle("E", "N", "A", size: .16, color: wexam-palette.ink)
    // Door/window colors are deliberate soft accents from the source model.
    rect((3.05, 0), (4.15, 1.7), fill: wexam-palette.door, stroke: wexam-palette.ink + stroke-len)
    rect((1.55, 1.65), (2.65, 2.75), fill: rgb("#FFF8E7"), stroke: wexam-palette.ink + stroke-len)
    circle((2.65, 4.05), radius: .34, fill: none, stroke: wexam-palette.blue + stroke-len)
    content((3.2, -.42), text(size: 8pt)[5,20 m])
    // Horizontal labels remain readable in both normal and rough canvases.
    content((.14, 1.55), text(size: 8pt)[3,10 m])
    content((3.35, 4.28), text(size: 8pt)[2,80 m])
    ctz-draw-points("A", "B", "C", "D", "E", "N")
    ctz-draw-labels("A", "B", "C", "D", "E", "N", A: "above left", B: "above right", C: "below right", D: "below left", E: "above", N: "below")
  })
  align(center, figure)
})
