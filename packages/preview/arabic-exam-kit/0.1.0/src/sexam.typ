// sexam-boxes.typ
// Reusable Arabic examination components inspired by the CTAN `sexam` model.
// All dimensions are derived from the measured component/page and support a
// normal or hand-drawn Scrawl variant.

#import "../vendor/scrawl/lib.typ": scrawl, rounded-rect-pts

#let sexam-palette = (
  ink: rgb("#101010"),
  rule: rgb("#202020"),
  paper: rgb("#FFFEFC"),
  grey: rgb("#5B5B5B"),
)

#let sexam-style(mode: "normal", roughness: 1.0, dir: rtl, seed: 1) = (
  mode: mode,
  roughness: roughness,
  dir: dir,
  seed: seed,
)

#let _sexam-resolve-width(width, available) = {
  if type(width) == ratio { available * width }
  else if width == auto { available }
  else { width }
}

#let _sexam-flow(body, dir) = align(if dir == rtl { right } else { left }, text(dir: dir)[#body])
#let _sexam-inset(inset) = {
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

// ---------------------------------------------------------------------------
// Header: three typographic rows separated by two full-width black rules.
// ---------------------------------------------------------------------------
#let sexam-header(
  school: [ثانوية الدكتور أحمد عروة],
  academic-year: [السنة الدراسية : 2017 – 2018],
  title: [امتحان الفصل الأول مادة الرياضيات],
  stream: [الشعبة : سنة ثالثة تسيير واقتصاد],
  duration: [المدة: ساعتان ◷],
  width: 100%,
  rule-weight: .12%,
  row-gap: .45em,
  dir: rtl,
  mode: "normal",
  roughness: 1.0,
  seed: 4101,
) = layout(area => {
  let total-w = _sexam-resolve-width(width, area.width)
  let school-text = text(dir: dir, weight: "bold", size: .95em)[#school]
  let year-text = text(dir: dir, weight: "bold", size: .90em)[#academic-year]
  let title-text = text(dir: dir, weight: "bold", size: 1.20em)[#title]
  let stream-text = text(dir: dir, weight: "bold", size: .95em)[#stream]
  let duration-text = text(dir: dir, weight: "bold", size: .92em)[#duration]
  let h1 = calc.max(measure(school-text).height, measure(year-text).height)
  let h2 = measure(title-text).height
  let h3 = calc.max(measure(stream-text).height, measure(duration-text).height)
  let gap = measure(box(height: row-gap)).height
  let total-h = h1 + h2 + h3 + 2 * gap + 2 * measure(box(height: .35em)).height
  let w = total-w / 1cm
  let h = total-h / 1cm
  let rule = total-w * rule-weight
  let y-rule-top = h - (h1 + gap / 2) / 1cm
  let y-rule-bottom = h - (h1 + gap + h2 + gap / 2) / 1cm
  let canvas = scrawl(width: total-w, height: total-h, hand: mode == "rough",
    roughness: roughness, seed: seed,
    (shape, ..) => {
      shape(((0, y-rule-top), (w, y-rule-top)), closed: false,
        paint: sexam-palette.rule, weight: rule, seed: seed)
      shape(((0, y-rule-bottom), (w, y-rule-bottom)), closed: false,
        paint: sexam-palette.rule, weight: rule, seed: seed + 1)
    },
  )
  block(width: total-w, height: total-h, {
    place(top + left, canvas)
    // Row 1: physical left = academic year, physical right = school.
    place(top + left, dx: 0pt, dy: 0pt,
      box(width: total-w * 43%, align(left, year-text)))
    place(top + right, dx: 0pt, dy: 0pt,
      box(width: total-w * 43%, align(right, school-text)))
    // Row 2: centred title.
    place(top + left, dy: h1 + gap,
      box(width: total-w, align(center, title-text)))
    // Row 3: physical left = duration, physical right = stream.
    place(top + left, dy: h1 + gap + h2 + gap,
      box(width: total-w * 38%, align(left, duration-text)))
    place(top + right, dy: h1 + gap + h2 + gap,
      box(width: total-w * 58%, align(right, stream-text)))
  })
})

// ---------------------------------------------------------------------------
// Exercise heading: bold heading at right with a continuous rule to its left.
// ---------------------------------------------------------------------------
#let sexam-exercise-heading(
  title: [التمرين الأول],
  points: [6 نقاط],
  width: 100%,
  rule-weight: .10%,
  dir: rtl,
  mode: "normal",
  roughness: 1.0,
  seed: 4201,
) = layout(area => {
  let total-w = _sexam-resolve-width(width, area.width)
  let heading = text(dir: dir, weight: "bold", size: 1.06em)[#title : (#points)]
  let hm = measure(heading)
  let gap = measure(box(width: .65em)).width
  let total-h = hm.height + measure(box(height: .28em)).height
  let w = total-w / 1cm
  let h = total-h / 1cm
  let text-w = hm.width + gap
  let rule-end = (total-w - text-w) / 1cm
  let canvas = scrawl(width: total-w, height: total-h, hand: mode == "rough",
    roughness: roughness, seed: seed,
    (shape, ..) => shape(((0, .28 * h), (rule-end, .28 * h)), closed: false,
      paint: sexam-palette.rule, weight: total-w * rule-weight, seed: seed),
  )
  block(width: total-w, height: total-h, {
    place(top + left, canvas)
    place(top + right, box(width: text-w, align(right, heading)))
  })
})

// Small margin score box (ج1, ج2, …), modeled after `sexam` point labels.
#let sexam-score-box(
  // Pass the number only; `unit` is drawn separately to control its side.
  label: "1",
  unit: "ن",
  width: auto,
  inset: (x: .36em, y: .18em),
  dir: rtl,
  mode: "normal",
  roughness: 1.0,
  seed: 4301,
) = layout(area => {
  // Lay out ن and its number as two independent text boxes. This avoids any
  // RTL/BiDi ambiguity and guarantees that ن is physically at left of 2.
  let mark-text = text(dir: rtl, size: .88em, weight: "bold")[#unit]
  let number-text = text(dir: ltr, size: .88em, weight: "bold")[#label]
  let mm = measure(mark-text)
  let nm = measure(number-text)
  let space = measure(box(width: .06em)).width
  let pad = _sexam-inset(inset)
  // Resolve em-based padding before arithmetic inside this measured component.
  let left-pad = measure(box(width: pad.left)).width
  let right-pad = measure(box(width: pad.right)).width
  let top-pad = measure(box(height: pad.top)).height
  let bottom-pad = measure(box(height: pad.bottom)).height
  let label-w = mm.width + space + nm.width
  let label-h = calc.max(mm.height, nm.height)
  let total-w = if width == auto { label-w + left-pad + right-pad } else {
    _sexam-resolve-width(width, area.width)
  }
  let total-h = label-h + top-pad + bottom-pad
  let w = total-w / 1cm
  let h = total-h / 1cm
  let canvas = scrawl(width: total-w, height: total-h, hand: mode == "rough",
    roughness: roughness, seed: seed,
    (shape, ..) => shape(((0, 0), (w, 0), (w, h), (0, h)),
      fill: white, paint: sexam-palette.ink, weight: total-w * .09%, seed: seed),
  )
  block(width: total-w, height: total-h, {
    place(top + left, canvas)
    place(top + left, dx: left-pad, dy: top-pad,
      box(width: mm.width, height: label-h, align(center + horizon, mark-text)))
    place(top + left, dx: left-pad + mm.width + space, dy: top-pad,
      box(width: nm.width, height: label-h, align(center + horizon, number-text)))
  })
})

// A question/part with an optional score box held in the physical left margin.
#let sexam-part(
  body,
  score: none,
  width: 100%,
  score-gap: 1.2em,
  inset: 0pt,
  dir: rtl,
  mode: "normal",
  roughness: 1.0,
  seed: 4401,
) = layout(area => {
  let total-w = _sexam-resolve-width(width, area.width)
  let score-box = if score == none { none } else {
    sexam-score-box(label: score, dir: dir, mode: mode, roughness: roughness, seed: seed)
  }
  let sm = if score == none { (width: 0pt, height: 0pt) } else { measure(score-box) }
  let gap = if score == none { 0pt } else { measure(box(width: score-gap)).width }
  let content-w = total-w - sm.width - gap
  let content = block(width: content-w, inset: inset, _sexam-flow(body, dir))
  let cm = measure(content)
  let total-h = calc.max(cm.height, sm.height)
  block(width: total-w, height: total-h, {
    if score != none {
      place(top + left, dy: (total-h - sm.height) / 2, score-box)
    }
    place(top + right, dy: (total-h - cm.height) / 2, content)
  })
})

// Footer with an upper rule, deliberately sized for use outside the main body.
#let sexam-footer(
  footer-left: [اقلب الورقة],
  footer-center: [صفحة 1 من 2],
  footer-right: [ركز جيدًا],
  width: 100%,
  rule-weight: .10%,
  dir: rtl,
  mode: "normal",
  roughness: 1.0,
  seed: 4501,
) = layout(area => {
  let total-w = _sexam-resolve-width(width, area.width)
  let left-text = text(dir: dir, weight: "bold", size: .84em)[#footer-left]
  let center-text = text(dir: ltr, weight: "bold", size: .84em)[#footer-center]
  let right-text = text(dir: dir, weight: "bold", size: .84em)[#footer-right]
  let row-h = calc.max(measure(left-text).height, measure(center-text).height,
    measure(right-text).height)
  let gap = measure(box(height: .42em)).height
  let total-h = row-h + gap
  let w = total-w / 1cm
  let h = total-h / 1cm
  let canvas = scrawl(width: total-w, height: total-h, hand: mode == "rough",
    roughness: roughness, seed: seed,
    (shape, ..) => shape(((0, h), (w, h)), closed: false,
      paint: sexam-palette.rule, weight: total-w * rule-weight, seed: seed),
  )
  block(width: total-w, height: total-h, {
    place(top + left, canvas)
    place(top + left, dy: gap,
      box(width: total-w * 30%, align(left, left-text)))
    place(top + left, dx: total-w * 35%, dy: gap,
      box(width: total-w * 30%, align(center, center-text)))
    place(top + right, dy: gap,
      box(width: total-w * 30%, align(right, right-text)))
  })
})

// Page shell with the footer pinned below the measured question content.
#let sexam-page(
  body,
  footer: none,
  width: 100%,
  height: auto,
  inset: 0pt,
  dir: rtl,
  // Accepted for uniform spreading of `sexam-style(...)`.
  mode: "normal",
  roughness: 1.0,
  seed: 1,
) = layout(area => {
  let total-w = _sexam-resolve-width(width, area.width)
  let inner = block(width: total-w, inset: inset, _sexam-flow(body, dir))
  let im = measure(inner)
  // Do not measure a percentage-width footer in an unconstrained context.
  // Reserve its stable typographic height, then give it the known page width
  // when it is placed below.
  let footer-h = if footer == none { 0pt } else { measure(box(height: 1.45em)).height }
  let gap = if footer == none { 0pt } else { measure(box(height: .5em)).height }
  let wanted-h = if height == auto { im.height + footer-h + gap }
    else if type(height) == ratio { area.height * height }
    else { height }
  let total-h = calc.max(wanted-h, im.height + footer-h + gap)
  block(width: total-w, height: total-h, {
    place(top + left, inner)
    if footer != none {
      place(bottom + left, box(width: total-w, footer))
    }
  })
})
