// na-frame 0.1.0 — professional breakable frames for Arabic (RTL) and Latin (LTR).
// حزمة na-frame: إطارات احترافية قابلة للتقسيم بين الصفحات، عربية ولاتينية.
// كل تعريفات الإطارات في هذا الملف الواحد (lib.typ).
//
// Common parameters of every frame / المعاملات المشتركة:
//   body             : the content (first, positional) / المحتوى (أولًا)
//   title            : title content (auto = default by language) / العنوان
//   color            : frame color / لون الإطار
//   title-color      : title tab color (auto = color) / لون خانة العنوان
//   title-text-color : title text color / لون نص العنوان
//   breakable        : may break across pages (default true) / قابل للتقسيم
//   dir / lang       : per-frame direction & language (auto = document) / اتجاه ولغة كل إطار
//
// Usage / الاستخدام:
//   #import "@preview/na-frame:0.1.0": *
//   #theorem-frame(title: [مبرهنة])[ ... ]
//   #frame("blue", title: [تعريف])[ ... ]

// ═══════════════════════════════════════════════════════════════
// 1. Core helpers / الدوال المساعدة
// ═══════════════════════════════════════════════════════════════

// Offset toward the END side of the text direction.
// إزاحة نحو جهة النهاية (يسار في العربية، يمين في اللاتينية).
#let tend(is-rtl, v) = if is-rtl { -v } else { v }

// Mirror a purely graphical element (no text!) when the document is LTR.
// يعكس الرسوم فقط (بلا نص) عندما يكون الاتجاه لاتينيًا.
#let mirror-gfx(is-rtl, body) = if is-rtl {
  body
} else {
  scale(x: -100%, origin: center + horizon, reflow: false, body)
}

// ───────────────────────────────────────────────────────────────
// LTR mirroring helpers / دوال عكس التصميم في النسخة اللاتينية
// The right-tab frames are drawn once (title tab on the right, the
// Arabic design). In a Latin (LTR) document they are mirrored so the
// title tab sits on the LEFT. Arabic (RTL) output is not changed.
// ───────────────────────────────────────────────────────────────
#let flip-key(k) = (
  left: "right", right: "left",
  top-left: "top-right", top-right: "top-left",
  bottom-left: "bottom-right", bottom-right: "bottom-left",
).at(k, default: k)

// Mirror the side keys of a stroke / inset / radius dictionary (LTR only).
#let mirror-dict(is-rtl, d) = if is-rtl {
  d
} else {
  d.pairs().map(p => (flip-key(p.at(0)), p.at(1))).to-dict()
}

// Graphic ornament placed at (x, y) of a container of width `w`
// (RTL design coordinates); mirrored across the container in LTR.
#let rorn(is-rtl, w, x, y, body) = if is-rtl {
  place(top + left, dx: x, dy: y, body)
} else {
  place(top + left, scale(x: -100%, origin: center + top, reflow: false,
    block(width: w, height: 0pt, spacing: 0pt, breakable: false,
      place(top + left, dx: x, dy: y, body))))
}

// Text element (never mirrored) that occupies [x, x + bw] in the RTL
// design; moved to the mirrored position in LTR.
#let rtxt(is-rtl, w, x, y, bw, body) = place(
  top + left, dx: if is-rtl { x } else { w - x - bw }, dy: y, body,
)

// Frame color / title color resolution.
#let label-color(color, title-color) = if title-color == auto { color } else { title-color }

// Default title by language (must be called inside `context`).
// عنوان افتراضي حسب لغة المستند.
#let pick-title(title, ar, en) = if title != auto {
  title
} else if text.lang == "ar" {
  ar
} else {
  en
}

// Named color palette: `color: palette.red`.
#let palette = (
  blue: rgb("#100578"),
  red: rgb("#ff1616"),
  crimson: rgb("#bc393c"),
  green: rgb("#008800"),
  teal: rgb("#00a977"),
  orange: rgb("#e99500"),
  purple: rgb("#5d2490"),
  indigo: rgb("#514bbb"),
  gold: rgb("#b99a60"),
  gray: rgb("#555555"),
)

// Curved title banner shared by several frames (blue-frame, green-frame).
// Drawn for RTL, mirrored automatically for LTR. Call inside `context`.
#let curved-label(title, color, text-color, is-rtl, folded: false, rounded: true) = {
  let heading = text(size: 14pt, weight: "bold", fill: text-color)[#title]
  let w = measure(heading).width + 10mm
  let h = calc.max(9mm, measure(heading).height + 4mm)
  let rr = if rounded { 3mm } else { 0mm }
  let extra = if folded { 2mm } else { 0mm }
  let shape = box(width: w, height: h + extra)[
    #if folded {
      place(top + right, dy: h - .5mm, curve(
        fill: color.lighten(45%), stroke: none,
        curve.move((0mm, 0mm)),
        curve.line((1.5mm, 0mm)),
        curve.cubic((1.5mm, 1.5mm), (.75mm, 2.5mm), (0mm, 2.5mm)),
        curve.close(),
      ))
    }
    #place(top + left, curve(
      fill: color, stroke: none,
      curve.move((0mm, 0mm)),
      curve.line((w - rr, 0mm)),
      curve.cubic((w - rr / 3, 0mm), (w, rr / 3), (w, rr)),
      curve.line((w, h)),
      curve.line((6mm, h)),
      curve.cubic((2mm, h), (4mm, 0mm), (0mm, 0mm)),
      curve.close(),
    ))
  ]
  box(width: w, height: h + extra)[
    #mirror-gfx(is-rtl, shape)
    #place(top + left, dx: if is-rtl { 4mm } else { 1mm },
      block(width: w - 5mm, height: h, inset: 1mm, above: 0pt, below: 0pt, breakable: false)[
        #align(center + horizon)[#heading]
      ])
  ]
}

// ═══════════════════════════════════════════════════════════════
// 2. Shared ornaments / زخارف مشتركة للإطارات الجديدة
// ═══════════════════════════════════════════════════════════════

#let exercise-clipboard(color) = box(width: 18mm, height: 21mm)[
  // Soft ground shadow behind both objects.
  #place(top + left, dx: 1.2mm, dy: 17.8mm,
    ellipse(width: 15.8mm, height: 2.6mm,
      fill: gradient.linear(rgb("#e0e8dd"), white, angle: 90deg), stroke: none))
  // Green backing board, inclined slightly to the right.
  #place(top + left, curve(
    fill: gradient.linear(color.lighten(60%), color.darken(15%), angle: 0deg),
    stroke: .3pt + color.lighten(25%),
    curve.move((3.6mm, 2.2mm)), curve.line((12.9mm, 3mm)),
    curve.cubic((13.7mm, 3.1mm), (14mm, 3.6mm), (13.9mm, 4.4mm)),
    curve.line((12.5mm, 18.8mm)),
    curve.cubic((12.4mm, 19.6mm), (11.9mm, 20mm), (11.1mm, 19.9mm)),
    curve.line((1.9mm, 18.8mm)),
    curve.cubic((1.1mm, 18.7mm), (.7mm, 18.2mm), (.8mm, 17.4mm)),
    curve.line((2.3mm, 3.4mm)),
    curve.cubic((2.4mm, 2.6mm), (2.8mm, 2.1mm), (3.6mm, 2.2mm)),
    curve.close()))
  // Rounded ivory paper with a subtle highlight.
  #place(top + left, curve(
    fill: gradient.linear(white, rgb("#f1f5eb"), angle: 0deg),
    stroke: .35pt + rgb("#b6c9ad"),
    curve.move((3.3mm, 2.1mm)), curve.line((12.3mm, 2.9mm)),
    curve.cubic((13.1mm, 3mm), (13.4mm, 3.5mm), (13.3mm, 4.2mm)),
    curve.line((11.9mm, 18.5mm)),
    curve.cubic((11.8mm, 19.2mm), (11.4mm, 19.5mm), (10.7mm, 19.4mm)),
    curve.line((1.8mm, 18.3mm)),
    curve.cubic((1.1mm, 18.2mm), (.8mm, 17.8mm), (.9mm, 17.1mm)),
    curve.line((2.3mm, 3.2mm)),
    curve.cubic((2.4mm, 2.5mm), (2.7mm, 2mm), (3.3mm, 2.1mm)),
    curve.close()))
  // Raised metal clip: dark opening, back tab and curved front bar.
  #place(top + left, dx: 6.9mm, dy: .2mm,
    rect(width: 2.6mm, height: 2.8mm, radius: .6mm,
      fill: gradient.linear(rgb("#78909c"), rgb("#405663"), angle: 0deg), stroke: none))
  #place(top + left, dx: 7.7mm, dy: .7mm,
    rect(width: .9mm, height: 1mm, radius: .2mm, fill: rgb("#283f49"), stroke: none))
  #place(top + left, curve(
    fill: gradient.linear(rgb("#849aa3"), rgb("#3b535d"), angle: 90deg), stroke: none,
    curve.move((4.7mm, 1.6mm)), curve.line((10.8mm, 2.1mm)),
    curve.cubic((11.4mm, 2.2mm), (11.5mm, 3.6mm), (10.8mm, 3.7mm)),
    curve.line((4.7mm, 3.2mm)),
    curve.cubic((4.1mm, 3.1mm), (4.1mm, 1.6mm), (4.7mm, 1.6mm)), curve.close()))
  // Three slanted square frames and their short ruled lines.
  #for i in range(3) {
    place(top + left, dx: 3.7mm - i * .4mm, dy: 5.8mm + i * 4.1mm,
      curve(fill: color.lighten(75%), stroke: .35pt + color.lighten(55%),
        curve.move((.2mm, 0mm)), curve.line((2.5mm, .2mm)),
        curve.line((2.3mm, 2.5mm)), curve.line((0mm, 2.3mm)), curve.close()))
    place(top + left, dx: 7.7mm - i * .4mm, dy: 7mm + i * 4.1mm,
      curve(fill: none, stroke: .65pt + rgb("#65716c"),
        curve.move((0mm, 0mm)), curve.line((2.8mm, .3mm))))
    if i < 2 {
      place(top + left, dx: 3.7mm - i * .4mm, dy: 5.5mm + i * 4.1mm,
        curve(fill: none, stroke: .85pt + rgb("#218f8b"),
          curve.move((.3mm, 1.3mm)), curve.line((1mm, 2mm)),
          curve.line((2.8mm, 0mm))))
    }
  }
  // Pen tip, dark cap and shaded barrel, running diagonally beside the board.
  #place(top + left, curve(fill: rgb("#e6c58c"), stroke: none,
    curve.move((12mm, 17mm)), curve.line((13.6mm, 17.6mm)),
    curve.line((11.4mm, 20mm)), curve.close()))
  #place(top + left, curve(fill: rgb("#364b4c"), stroke: none,
    curve.move((11.7mm, 19mm)), curve.line((12.2mm, 19.2mm)),
    curve.line((11.4mm, 20mm)), curve.close()))
  #place(top + left, curve(fill: rgb("#345668"), stroke: none,
    curve.move((16.2mm, 4.4mm)),
    curve.cubic((16.4mm, 3.8mm), (17.9mm, 4.2mm), (17.7mm, 4.8mm)),
    curve.line((17.4mm, 5.8mm)), curve.line((15.9mm, 5.3mm)), curve.close()))
  #place(top + left, curve(
    fill: gradient.linear(rgb("#08777f"), rgb("#6bd3d0"), rgb("#138b94"), angle: 0deg),
    stroke: .35pt + rgb("#167b80"),
    curve.move((15.9mm, 5mm)), curve.line((17.8mm, 5.7mm)),
    curve.cubic((18mm, 5.8mm), (18mm, 6.2mm), (17.8mm, 6.7mm)),
    curve.line((13.6mm, 17.6mm)),
    curve.cubic((13.3mm, 18mm), (12.2mm, 17.5mm), (12mm, 17mm)),
    curve.line((15.5mm, 5.6mm)),
    curve.cubic((15.6mm, 5.2mm), (15.7mm, 4.9mm), (15.9mm, 5mm)), curve.close()))
  #place(top + left, curve(fill: none, stroke: .55pt + rgb("#a0e5df"),
    curve.move((16.1mm, 6.1mm)), curve.line((12.7mm, 16.8mm))))
  #place(top + left, curve(fill: none, stroke: .65pt + rgb("#244e57"),
    curve.move((17.4mm, 6.4mm)),
    curve.cubic((18.2mm, 6.5mm), (17.5mm, 8.7mm), (17mm, 10.2mm))))
  #place(top + left, curve(fill: none, stroke: .7pt + rgb("#315e65"),
    curve.move((14mm, 11.7mm)), curve.line((15.8mm, 12.3mm))))
]











#let ornament-at(horizontal, vertical, body) = place(
  top + left, dx: horizontal, dy: vertical, body,
)

#let framed-green = rgb("194E48")

#let framed-gold = rgb("B59B62")

#let framed-paper = rgb("FCF8EF")

#let framed-star(radius) = block(
  width: radius * 2, height: radius * 2, spacing: 0pt,
)[
  #let vertices = range(16).map(index => {
    let angle = index * 22.5deg
    let distance = if calc.rem(index, 2) == 0 { radius } else { radius * 0.55 }
    (radius + distance * calc.cos(angle), radius + distance * calc.sin(angle))
  })
  #ornament-at(0pt, 0pt, polygon(
    ..vertices, fill: framed-paper, stroke: 0.4pt + framed-green,
  ))
  #for rotation in (0deg, 45deg) {
    ornament-at(0pt, 0pt, polygon(
      ..range(4).map(index => (
        radius + radius * 0.7 * calc.cos(rotation + index * 90deg),
        radius + radius * 0.7 * calc.sin(rotation + index * 90deg),
      )),
      fill: none, stroke: 0.35pt + framed-gold,
    ))
  }
  #ornament-at(radius * 0.68, radius * 0.68, circle(
    radius: radius * 0.32, fill: framed-gold, stroke: none,
  ))
  #ornament-at(radius * 0.86, radius * 0.86, circle(
    radius: radius * 0.14, fill: framed-green, stroke: none,
  ))
]

#let notebook-ring-back() = box(width: 5mm, height: 9mm)[
  #for offset in (0mm, .6mm) {
    place(
      top + left,
      dx: offset,
      curve(
        fill: none,
        stroke: .65pt + black,
        curve.move((2.6mm, 3.6mm)),
        curve.cubic((2.6mm, 2mm), (2.9mm, 1.498mm), (2.4mm, .5359mm)),
        curve.cubic((2.2176mm, .1848mm), (2.0107mm, 0mm), (1.8mm, 0mm)),
        curve.cubic((1.2408mm, 0mm), (.771005mm, 1.274794mm), (.637803mm, 3mm)),
      ),
    )
  }
]

#let notebook-ring() = box(width: 5mm, height: 9mm)[
  #place(
    top + left,
    dx: 1mm,
    dy: 6.7mm,
    rect(width: 3mm, height: 3mm, fill: black.lighten(80%), stroke: .5pt + black),
  )
  #for offset in (0mm, .6mm) {
    place(
      top + left,
      dx: offset,
      curve(
        fill: none,
        stroke: .65pt + black,
        curve.move((.637803mm, 3mm)),
        curve.cubic((.613125mm, 3.319621mm), (.6mm, 3.654702mm), (.6mm, 4mm)),
        curve.cubic((.6mm, 6.2091mm), (1.1372mm, 8mm), (1.8mm, 8mm)),
        curve.cubic((2.1182mm, 8mm), (2.4235mm, 7.5786mm), (2.6485mm, 6.8284mm)),
      ),
    )
  }
]

// ═══════════════════════════════════════════════════════════════
// 3. Theorem / definition frames
// ═══════════════════════════════════════════════════════════════

// na-frame — theorem / definition / property style frames.

// 1. Bevelled board frame. إطار سبورة مشطوف.
#let board-frame-raw(
  body,
  title: auto,
  color: rgb("#e99500"),
  title-color: auto,
  title-text-color: auto,
  breakable: true,
) = context {
  let heading = pick-title(title, [السبورة], [Board])
  let tab-color = label-color(color, title-color)
  block(
    width: 100%, fill: color,
    stroke: (
      top: 1.5pt + color.lighten(30%), left: 1.5pt + color.lighten(30%),
      right: 1.5pt + color.darken(35%), bottom: 1.5pt + color.darken(35%),
    ),
    inset: 1.3mm, above: 5mm, below: 3mm, breakable: breakable,
  )[
    #block(
      width: 100%, fill: white,
      stroke: (
        top: 2pt + color.darken(55%), left: 2pt + color.darken(55%),
        right: 2pt + color.lighten(30%), bottom: 2pt + color.lighten(30%),
      ),
      inset: 5mm, above: 0pt, below: 0pt, breakable: breakable,
    )[
      #align(center)[#text(size: 15pt, weight: "bold",
        fill: if title-text-color == auto { tab-color } else { title-text-color })[#heading]]
      #v(3mm)
      #align(start)[#body]
    ]
  ]
}

// 2. Rounded frame with a curved title and a small fold. إطار مدوّر بعنوان منحنٍ.
#let blue-frame-raw(
  body,
  title: auto,
  color: rgb("#100578"),
  title-color: auto,
  title-text-color: white,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let heading = pick-title(title, [تعريف], [Definition])
  let tab-color = label-color(color, title-color)
  let label = curved-label(heading, tab-color, title-text-color, is-rtl, folded: true)
  let label-height = measure(label).height
  block(
    width: 100%, fill: white, stroke: .6pt + color,
    radius: 3mm, inset: 0pt, above: 5mm, below: 3mm, breakable: breakable,
  )[
    #place(top + start, dx: tend(is-rtl, -1.5mm), label)
    #pad(top: label-height + 3mm, bottom: 5mm, left: 6mm, right: 6mm)[
      #align(start)[#body]
    ]
  ]
}

// 3. Theorem frame: opposite rounded corners, hanging title, shadow.
#let theorem-frame-raw(
  body,
  title: auto,
  color: rgb("#ff1616"),
  title-color: rgb("#ae0000"),
  title-text-color: white,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let heading-txt = pick-title(title, [مبرهنة], [Theorem])
  let tab-color = label-color(color, title-color)
  let heading = text(size: 16pt, weight: "bold", fill: title-text-color)[#heading-txt]
  let w = measure(heading).width + 9mm
  let h = calc.max(10mm, measure(heading).height + 4mm)
  let corners = if is-rtl {
    (top-left: 4mm, top-right: 0pt, bottom-left: 0pt, bottom-right: 4mm)
  } else {
    (top-left: 0pt, top-right: 4mm, bottom-left: 4mm, bottom-right: 0pt)
  }
  let shadow-inset = if is-rtl { (right: 1mm, bottom: 1mm) } else { (left: 1mm, bottom: 1mm) }
  let shape = box(width: w + 3mm, height: h)[
    #place(top + left, rect(
      width: w + 3mm, height: 2mm,
      radius: (top-left: 2mm, top-right: 2mm),
      fill: tab-color.darken(45%), stroke: none,
    ))
    #place(top + left, dx: 1.5mm, curve(
      fill: tab-color, stroke: none,
      curve.move((0mm, 0mm)), curve.line((w, 0mm)),
      curve.line((w - .6mm, h - 1.5mm)),
      curve.cubic((w - .6mm, h), (w - 1mm, h), (w - 2mm, h)),
      curve.line((2mm, h)),
      curve.cubic((1mm, h), (.6mm, h), (.6mm, h - 1.5mm)),
      curve.close(),
    ))
  ]
  let label = box(width: w + 3mm, height: h)[
    #mirror-gfx(is-rtl, shape)
    #place(top + left, dx: 1.5mm,
      block(width: w, height: h, inset: 1mm, above: 0pt, below: 0pt, breakable: false)[
        #align(center + horizon)[#heading]
      ])
  ]
  block(
    width: 100%, fill: rgb("#dedede"), radius: corners,
    inset: shadow-inset, above: 6mm, below: 3mm, breakable: breakable,
  )[
    #block(
      width: 100%, fill: color.lighten(98%), stroke: .9pt + color,
      radius: corners, inset: 0pt, above: 0pt, below: 0pt, breakable: breakable,
    )[
      #place(top + start, dx: tend(is-rtl, 2mm), dy: -2mm, label)
      #pad(top: h + 3mm, bottom: 5mm, left: 6mm, right: 6mm)[
        #align(start)[#body]
      ]
    ]
  ]
}

// 4. White panel with a folded flag and a small pointed tail.
#let flag-frame-raw(
  body,
  title: auto,
  color: rgb("#e3343e"),
  title-color: rgb("#ff0808"),
  title-text-color: white,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let heading-txt = pick-title(title, [مبرهنة], [Theorem])
  let tab-color = label-color(color, title-color)
  let heading = text(size: 15pt, weight: "bold", fill: title-text-color)[#heading-txt]
  let w = measure(heading).width + 10mm
  let h = calc.max(9mm, measure(heading).height + 4mm)
  let corners = if is-rtl {
    (top-left: 4mm, top-right: 0pt, bottom-left: 0pt, bottom-right: 4mm)
  } else {
    (top-left: 0pt, top-right: 4mm, bottom-left: 4mm, bottom-right: 0pt)
  }
  let shadow-inset = if is-rtl { (right: .8mm, bottom: .8mm) } else { (left: .8mm, bottom: .8mm) }
  let shape = box(width: w + 3mm, height: h + 2mm)[
    #place(top + left, rect(
      width: w + 3mm, height: 2mm, fill: tab-color.lighten(45%),
      stroke: none, radius: (top-left: 2mm, top-right: 2mm),
    ))
    #place(top + left, dx: 1.5mm, curve(
      fill: tab-color, stroke: none,
      curve.move((0mm, 0mm)), curve.line((w, 0mm)),
      curve.line((w - 1mm, h)), curve.line((7mm, h)),
      curve.line((5mm, h + 2mm)), curve.line((3.5mm, h)),
      curve.line((1mm, h)), curve.close(),
    ))
  ]
  let label = box(width: w + 3mm, height: h + 2mm)[
    #mirror-gfx(is-rtl, shape)
    #place(top + left, dx: 1.5mm,
      block(width: w, height: h, inset: 1mm, above: 0pt, below: 0pt, breakable: false)[
        #align(center + horizon)[#heading]
      ])
  ]
  block(
    width: 100%, fill: rgb("#dedede"), radius: corners,
    inset: shadow-inset, above: 6mm, below: 3mm, breakable: breakable,
  )[
    #block(
      width: 100%, fill: white, stroke: .8pt + color,
      radius: corners, inset: 0pt, above: 0pt, below: 0pt, breakable: breakable,
    )[
      #place(top + start, dx: tend(is-rtl, 2mm), dy: -2mm, label)
      #pad(top: h + 3mm, bottom: 5mm, left: 5mm, right: 5mm)[
        #align(start)[#body]
      ]
    ]
  ]
}

// 5. Thick rounded frame with a double-outline title (proofs).
#let proof-frame-raw(
  body,
  title: auto,
  color: rgb("#ff0808"),
  title-color: auto,
  title-text-color: auto,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let heading-txt = pick-title(title, [الإثبات], [Proof])
  let tab-color = label-color(color, title-color)
  let ink = if title-text-color == auto { tab-color } else { title-text-color }
  let heading = text(size: 15pt, weight: "bold", fill: ink)[#heading-txt]
  let w = measure(heading).width + 8mm
  let h = calc.max(10mm, measure(heading).height + 4mm)
  let shadow-a = if is-rtl { (right: 1.5mm, bottom: 1.5mm) } else { (left: 1.5mm, bottom: 1.5mm) }
  let shadow-b = if is-rtl { (right: .7mm, bottom: .7mm) } else { (left: .7mm, bottom: .7mm) }
  block(
    width: 100%, fill: rgb("#e5e5e5"), radius: 8mm,
    inset: shadow-a, above: h / 2 + 4mm, below: 3mm, breakable: breakable,
  )[
    #block(
      width: 100%, fill: rgb("#bdbdbd"), radius: 8mm,
      inset: shadow-b, above: 0pt, below: 0pt, breakable: breakable,
    )[
      #block(
        width: 100%, fill: white, stroke: 2pt + color,
        radius: 8mm, inset: 0pt, above: 0pt, below: 0pt, breakable: breakable,
      )[
        #place(top + start, dx: tend(is-rtl, 5mm), dy: -h / 2,
          block(width: w, height: h, fill: white, stroke: 1.2pt + tab-color,
            radius: 2.5mm, inset: 1mm, above: 0pt, below: 0pt, breakable: false)[
            #block(width: w - 2mm, height: h - 2mm, stroke: .5pt + tab-color,
              radius: 1.5mm, inset: .5mm, above: 0pt, below: 0pt, breakable: false)[
              #align(center + horizon)[#heading]
            ]
          ])
        #pad(top: h / 2 + 4mm, bottom: 6mm, left: 6mm, right: 6mm)[
          #align(start)[#body]
        ]
      ]
    ]
  ]
}

// 6. Gradient title tab sitting above a thin frame.
#let gradient-frame-raw(
  body,
  title: auto,
  color: rgb("#00a977"),
  title-color: auto,
  title-text-color: black,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let heading-txt = pick-title(title, [مبرهنة], [Theorem])
  let tab-color = label-color(color, title-color)
  let heading = text(size: 16pt, weight: "bold", fill: title-text-color)[#heading-txt]
  let w = measure(heading).width + 7mm
  let h = calc.max(10mm, measure(heading).height + 4mm)
  let tab-radius = if is-rtl {
    (top-left: 4mm, bottom-right: 4mm)
  } else {
    (top-right: 4mm, bottom-left: 4mm)
  }
  block(
    width: 100%, fill: white, stroke: .5pt + color,
    inset: 0pt, above: h + 4mm, below: 3mm, breakable: breakable,
  )[
    #place(top + start, dy: -h,
      block(width: w, height: h, fill: gradient.linear(tab-color, white, angle: 90deg),
        stroke: .5pt + tab-color, radius: tab-radius,
        inset: 1mm, above: 0pt, below: 0pt, breakable: false)[
        #align(center + horizon)[#heading]
      ])
    #pad(top: 5mm, bottom: 5mm, left: 6mm, right: 6mm)[#align(start)[#body]]
  ]
}

// 7. Chapter panel: title tab with an arrow pointing to the end side.
#let chapter-frame-raw(
  body,
  title: auto,
  color: rgb("#514bbb"),
  title-color: auto,
  title-text-color: white,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let heading-txt = pick-title(title, [خطة الفصل], [Chapter outline])
  let tab-color = label-color(color, title-color)
  let heading = text(size: 14pt, weight: "bold", fill: title-text-color)[#heading-txt]
  let w = measure(heading).width + 10mm
  let h = calc.max(8mm, measure(heading).height + 3mm)
  let shape = box(width: w, height: h)[
    #place(top + left, curve(
      fill: tab-color, stroke: none,
      curve.move((w, 0mm)), curve.line((3mm, 0mm)),
      curve.line((0mm, h / 2)), curve.line((3mm, h)),
      curve.line((w, h)), curve.close(),
    ))
    #place(top + left, curve(
      fill: none, stroke: 1pt + white,
      curve.move((4mm, 0mm)), curve.line((2mm, h / 2)),
      curve.line((4mm, h)),
    ))
  ]
  let label = box(width: w, height: h)[
    #mirror-gfx(is-rtl, shape)
    #place(top + left, dx: if is-rtl { 4mm } else { 0mm },
      block(width: w - 4mm, height: h, inset: 1mm, above: 0pt, below: 0pt, breakable: false)[
        #align(center + horizon)[#heading]
      ])
  ]
  block(
    width: 100%, fill: color.lighten(96%), inset: 0pt,
    above: 6mm, below: 3mm, breakable: breakable,
  )[
    #place(top + start, dy: -3mm, label)
    #pad(top: h, bottom: 5mm, left: 5mm, right: 5mm)[#align(start)[#body]]
  ]
}

// 8. Full-width ribbon with folded ends outside the frame.
#let ribbon-frame-raw(
  body,
  title: auto,
  color: rgb("#1600ff"),
  title-color: auto,
  title-text-color: white,
  breakable: true,
) = context {
  let heading-txt = pick-title(title, [ملاحظة], [Note])
  let tab-color = label-color(color, title-color)
  let heading = text(size: 15pt, weight: "bold", fill: title-text-color)[#heading-txt]
  let h = calc.max(10mm, measure(heading).height + 4mm)
  let fold = tab-color.darken(30%)
  block(
    width: 100%, fill: white, stroke: .6pt + color,
    inset: 0pt, above: 6mm, below: 3mm, breakable: breakable,
  )[
    #place(top + left, dx: -2mm, curve(fill: fold, stroke: none,
      curve.move((2mm, 0mm)), curve.line((2mm, 2mm)),
      curve.line((0mm, 2mm)), curve.close()))
    #place(top + right, dx: 2mm, curve(fill: fold, stroke: none,
      curve.move((0mm, 0mm)), curve.line((2mm, 2mm)),
      curve.line((0mm, 2mm)), curve.close()))
    #place(top + left, dx: -2mm, dy: h + 2mm, curve(fill: fold, stroke: none,
      curve.move((0mm, 0mm)), curve.line((2mm, 0mm)),
      curve.line((2mm, 2mm)), curve.close()))
    #place(top + right, dx: 2mm, dy: h + 2mm, curve(fill: fold, stroke: none,
      curve.move((0mm, 0mm)), curve.line((2mm, 0mm)),
      curve.line((0mm, 2mm)), curve.close()))
    #place(top + left, dx: -2mm, dy: 2mm,
      block(width: 100% + 4mm, height: h, fill: tab-color, inset: 1mm,
        above: 0pt, below: 0pt, breakable: false)[
        #align(center + horizon)[#heading]
      ])
    #pad(top: h + 6mm, bottom: 5mm, left: 6mm, right: 6mm)[#align(start)[#body]]
  ]
}

// ═══════════════════════════════════════════════════════════════
// 4. Exercise frames
// ═══════════════════════════════════════════════════════════════

// na-frame — exercise / example style frames.

// 9. Exercise frame: dotted inner border, curved title, optional subtitle.
#let green-frame-raw(
  body,
  title: auto,
  color: rgb("#008800"),
  title-color: auto,
  title-text-color: white,
  subtitle: [],
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let heading = pick-title(title, [تمرين], [Exercise])
  let tab-color = label-color(color, title-color)
  let label = curved-label(heading, tab-color, title-text-color, is-rtl, rounded: false)
  let label-size = measure(label)
  block(
    width: 100%, fill: color.lighten(97%),
    stroke: (top: 1.5pt + color, right: .8pt + color, bottom: .8pt + color, left: .8pt + color),
    inset: 1mm, above: 5mm, below: 3mm, breakable: breakable,
  )[
    #block(
      width: 100%, stroke: (paint: color, thickness: .4pt, dash: "dotted"),
      inset: 0pt, above: 0pt, below: 0pt, breakable: breakable,
    )[
      #place(top + start, dx: tend(is-rtl, -1mm), dy: -1mm, label)
      #if subtitle != [] {
        place(top + start, dx: tend(is-rtl, label-size.width + 3mm), dy: 2mm,
          text(size: 11pt, fill: color)[#subtitle])
      }
      #pad(top: label-size.height + 3mm, bottom: 5mm, left: 5mm, right: 5mm)[
        #align(start)[#body]
      ]
    ]
  ]
}

// 10. Layered-shadow frame with a hanging title and a folded corner.
#let shadow-frame-raw(
  body,
  title: auto,
  color: rgb("#bc393c"),
  title-color: auto,
  title-text-color: white,
  frame-color: auto,
  frame-width: 0.45pt,
  shadow-color: auto,
  shadow-size: 1.2mm,
  background: white,
  fold-size: 6mm,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let heading-txt = pick-title(title, [مثال], [Example])
  let tab-color = label-color(color, title-color)
  let border-color = if frame-color == auto { color.darken(15%) } else { frame-color }
  let shade-color = if shadow-color == auto { color } else { shadow-color }
  let heading = text(size: 15pt, weight: "bold", fill: title-text-color)[#heading-txt]
  let label-width = measure(heading).width + 8mm
  let label-height = calc.max(11mm, measure(heading).height + 4mm)
  let has-title = heading-txt != []
  let label = box(width: label-width, height: label-height + 2mm)[
    #place(top + left, rect(width: label-width, height: label-height, fill: tab-color, stroke: none))
    #place(top + left, dx: if is-rtl { 2mm } else { label-width - 8mm }, dy: label-height,
      polygon((0mm, 0mm), (3mm, 2mm), (6mm, 0mm), fill: tab-color, stroke: none))
    #place(top + left,
      block(width: label-width, height: label-height, inset: 1mm, above: 0pt, below: 0pt, breakable: false)[
        #align(center + horizon)[#heading]
      ])
  ]
  let shadow-inset = if is-rtl {
    (left: shadow-size / 3, bottom: shadow-size / 3)
  } else {
    (right: shadow-size / 3, bottom: shadow-size / 3)
  }
  let fold = box(width: fold-size, height: fold-size)[
    #place(top + left,
      polygon(
        (-shadow-size - frame-width, 0mm),
        (0mm, 0mm),
        (fold-size, fold-size),
        (fold-size, fold-size + shadow-size + frame-width),
        (-shadow-size - frame-width, fold-size + shadow-size + frame-width),
        fill: white, stroke: none,
      ))
    #for (fraction, lightness) in ((1, 88%), (2 / 3, 75%), (1 / 3, 58%)) {
      let offset = shadow-size * fraction
      place(top + left,
        polygon(
          (0mm, 0mm),
          (fold-size, fold-size),
          (fold-size - offset, fold-size + offset),
          (-offset, offset),
          fill: shade-color.lighten(lightness), stroke: none,
        ))
    }
    #place(top + left,
      polygon(
        (0mm, 0mm),
        (fold-size, fold-size * 0.35),
        (fold-size, fold-size),
        fill: border-color.darken(40%), stroke: none,
      ))
  ]
  block(width: 100%, fill: shade-color.lighten(88%), inset: shadow-inset,
    above: 12mm, below: 3mm, breakable: breakable)[
    #block(width: 100%, fill: shade-color.lighten(75%), inset: shadow-inset,
      above: 0pt, below: 0pt, breakable: breakable)[
      #block(width: 100%, fill: shade-color.lighten(58%), inset: shadow-inset,
        above: 0pt, below: 0pt, breakable: breakable)[
        #block(width: 100%, fill: background, stroke: frame-width + border-color,
          inset: 0pt, above: 0pt, below: 0pt, breakable: breakable)[
          #if has-title {
            place(top + start, dx: tend(is-rtl, 10mm), dy: -5mm, label)
          }
          #pad(top: if has-title { label-height + 1mm } else { 5mm },
            bottom: calc.max(5mm, fold-size), x: 8mm)[
            #align(start)[#body]
          ]
          #if fold-size > 0mm {
            place(bottom + end, dx: tend(is-rtl, frame-width / 2), dy: frame-width / 2,
              mirror-gfx(is-rtl, fold))
          }
        ]
      ]
    ]
  ]
}

// ═══════════════════════════════════════════════════════════════
// 5. Paper / notebook frames
// ═══════════════════════════════════════════════════════════════

// na-frame — paper / sticky note / notebook style frames.

// Vector pushpin (no image, no emoji font).
#let note-pin() = box(width: 6mm, height: 8mm)[
  #place(top + left, dx: 1mm, dy: 2.4mm,
    ellipse(width: 4.8mm, height: 5mm, fill: rgb("#232620"), stroke: none))
  #place(top + left, dx: 1.5mm, dy: 3mm,
    ellipse(width: 3.5mm, height: 3.5mm, fill: none, stroke: .5pt + rgb("#8b8d80")))
  #place(top + left, dx: .6mm,
    ellipse(width: 3.5mm, height: 3mm, fill: rgb("#808079"), stroke: none))
]

// Shared pinned paper with a curled corner on the END side.
#let pinned-paper(
  body, title, color, title-color, title-text-color, fold-size, breakable,
) = context {
  let is-rtl = text.dir == rtl
  let r = fold-size
  let heading-color = label-color(title-text-color, title-color)
  let corner = if is-rtl { (bottom-left: r) } else { (bottom-right: r) }
  let shade = if is-rtl { (left: .7mm, bottom: .7mm) } else { (right: .7mm, bottom: .7mm) }
  let fold = box(width: r, height: r)[
    #curve(
      fill: color.darken(18%), stroke: none,
      curve.move((0mm, 0mm)),
      curve.cubic((r * .25, r * .1), (r * .45, r * .1), (r * .55, 0mm)),
      curve.cubic((r * .4, r * .5), (r * .6, r * .85), (r, r)),
      curve.cubic((r * .35, r * .8), (r * .1, r * .4), (0mm, 0mm)),
      curve.close(),
    )
  ]
  block(
    width: 100%, fill: rgb("#aaa9a5"), radius: corner,
    inset: shade, above: 6mm, below: 3mm, breakable: breakable,
  )[
    #block(
      width: 100%, fill: color, radius: corner,
      inset: 0pt, above: 0pt, below: 0pt, breakable: breakable,
    )[
      #place(top + center, dy: -.5mm, note-pin())
      #place(bottom + end, mirror-gfx(is-rtl, fold))
      #pad(top: 9mm, bottom: 6mm, left: 8mm, right: 8mm)[
        #if title != [] {
          block(width: 100%, above: 0pt, below: 0pt, breakable: false)[
            #text(size: 14pt, weight: "bold", fill: heading-color)[#title]
          ]
          v(3mm)
        }
        #align(start)[#body]
      ]
    ]
  ]
}

// 11. Cream pinned paper. ورقة مدبّسة.
#let paper-frame-raw(
  body,
  title: [],
  color: rgb("#fbf0e4"),
  title-color: auto,
  title-text-color: black,
  breakable: true,
) = pinned-paper(body, title, color, title-color, title-text-color, 11mm, breakable)

// 12. Yellow sticky note. ورقة لاصقة.
#let sticky-frame-raw(
  body,
  title: [],
  color: rgb("#fffba6"),
  title-color: auto,
  title-text-color: black,
  breakable: true,
) = pinned-paper(body, title, color, title-color, title-text-color, 4mm, breakable)

// Metal double rings: back arcs behind the sheet, fronts above it.
#let spiral-ring(back: false) = box(width: 5mm, height: 9mm)[
  #if not back {
    place(top + left, dx: .5mm, dy: 5.8mm,
      rect(width: 4mm, height: 3mm,
        fill: gradient.linear(rgb("#bdbdbd"), rgb("#777777"), angle: 90deg),
        stroke: .4pt + black))
  }
  #for offset in (0mm, 1.3mm) {
    for wire-stroke in (1.2pt + rgb("#333333"), .55pt + rgb("#bcbcbc")) {
      place(top + left, dx: offset,
        if back {
          curve(fill: none, stroke: wire-stroke,
            curve.move((.8mm, 3mm)),
            curve.cubic((.8mm, 1.3mm), (1.1mm, 0mm), (1.6mm, 0mm)),
            curve.cubic((2.2mm, 0mm), (2.5mm, 1.4mm), (2.5mm, 3mm)),
            curve.line((2.5mm, 5.8mm)),
          )
        } else {
          curve(fill: none, stroke: wire-stroke,
            curve.move((.8mm, 3mm)),
            curve.cubic((.8mm, 5.9mm), (1.1mm, 7.5mm), (1.6mm, 7.5mm)),
            curve.cubic((2.05mm, 7.5mm), (2.4mm, 6.7mm), (2.5mm, 5.8mm)),
          )
        },
      )
    }
  }
]

// 13. Spiral notebook frame. دفتر حلزوني.
#let notebook-frame-raw(
  body,
  title: [],
  color: rgb("#555555"),
  title-color: auto,
  title-text-color: auto,
  breakable: true,
) = {
  let heading-color = if title-text-color == auto {
    label-color(color, title-color)
  } else { title-text-color }
  block(
    width: 100%, fill: rgb("#c6c6c6"), radius: 1mm,
    inset: (right: .8mm, bottom: .8mm), above: 7mm, below: 3mm, breakable: breakable,
  )[
    #for ring-index in range(14) {
      place(top + left,
        dx: 8mm + ring-index * ((100% - 16mm) / 13) - 2.5mm,
        dy: -3mm, spiral-ring(back: true))
    }
    #block(
      width: 100%, fill: white, stroke: .6pt + color,
      radius: 1mm, inset: 0pt, above: 0pt, below: 0pt, breakable: breakable,
    )[
      #for ring-index in range(14) {
        place(top + left,
          dx: 8mm + ring-index * ((100% - 16mm) / 13) - 2.5mm,
          dy: -3mm, spiral-ring())
      }
      #pad(top: 9mm, bottom: 6mm, left: 8mm, right: 8mm)[
        #if title != [] {
          block(width: 100%, above: 0pt, below: 0pt, breakable: false)[
            #text(size: 14pt, weight: "bold", fill: heading-color)[#title]
          ]
          v(3mm)
        }
        #align(start)[#body]
      ]
    ]
  ]
}

// ═══════════════════════════════════════════════════════════════
// 6. Tab frames
// ═══════════════════════════════════════════════════════════════

// na-frame — frames with measured title tabs (corner rule, properties, folded...).

// 14. Open-top frame with a title tab on the START side and optional subtitle.
#let corner-rule-frame-raw(
  body,
  title: auto,
  subtitle: [],
  color: rgb("4B0082"),
  title-color: auto,
  title-text-color: white,
  subtitle-color: auto,
  background: rgb("FCFAFD"),
  border-thickness: 1pt,
  title-size: 12pt,
  title-raise: 0.6mm,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let heading = pick-title(title, [مبرهنة], [Theorem])
  let tab-fill = label-color(color, title-color)
  let sub-fill = if subtitle-color == auto { color } else { subtitle-color }
  let tab-outset = if is-rtl {
    (right: border-thickness / 2, rest: 0pt)
  } else {
    (left: border-thickness / 2, rest: 0pt)
  }
  let body-inset = if is-rtl {
    (left: 3mm, right: 5mm, top: 2mm, bottom: 6mm)
  } else {
    (left: 5mm, right: 3mm, top: 2mm, bottom: 6mm)
  }
  block(width: 100%, breakable: breakable, above: 7mm, below: 7mm)[
    #block(width: 100%, breakable: false, sticky: true, spacing: 0pt)[
      #layout(size => {
        let title-content = [
          #set par(leading: 2pt, spacing: 0pt)
          #text(size: title-size, weight: "bold", fill: title-text-color,
            top-edge: "ascender", bottom-edge: "descender", heading)
        ]
        let tab-width = calc.min(size.width, calc.max(24mm, measure(title-content).width + 8mm))
        let tab = block(width: tab-width, fill: tab-fill, outset: tab-outset,
          inset: (x: 4mm, y: 2mm), spacing: 0pt)[
          #align(center, move(dy: -title-raise, title-content))
        ]
        block(width: 100%, height: measure(tab).height, spacing: 0pt)[
          #place(top + start, tab)
        ]
      })
    ]
    #block(width: 100%, breakable: breakable, spacing: 0pt, fill: background,
      stroke: (left: border-thickness + color, right: border-thickness + color,
        bottom: border-thickness + color, top: none),
      inset: body-inset,
    )[
      #if subtitle != [] {
        block(width: 100%, breakable: false, sticky: true, above: 0pt, below: 3mm)[
          #set par(leading: 2pt, spacing: 0pt)
          #align(end)[#text(size: 11pt, weight: "bold", fill: sub-fill, subtitle)]
        ]
      }
      #align(start)[#body]
    ]
  ]
}

// 15. Thick colored frame, curved ribbon title and red subtitle.
#let properties-frame-raw(
  body,
  title: auto,
  subtitle: [],
  color: rgb("4B0082"),
  title-color: auto,
  title-text-color: white,
  subtitle-color: red,
  background: rgb("FAF7FC"),
  frame-width: 1.5mm,
  title-size: 13pt,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let heading = pick-title(title, [خواص], [Properties])
  let ribbon-color = label-color(color, title-color)
  block(width: 100%, breakable: breakable, above: 7mm, below: 7mm,
    fill: color, inset: frame-width)[
    #block(width: 100%, breakable: breakable, spacing: 0pt,
      fill: background, radius: 3mm, inset: 0pt)[
      #block(width: 100%, breakable: false, sticky: true, spacing: 0pt)[
        #layout(size => {
          assert(size.width >= 50mm,
            message: "properties-frame needs at least 50mm of inner width")
          let title-content = [
            #set par(leading: 2pt, spacing: 0pt)
            #text(size: title-size, weight: "bold", fill: title-text-color,
              top-edge: "ascender", bottom-edge: "descender", heading)
          ]
          let subtitle-content = [
            #set par(leading: 2pt, spacing: 0pt)
            #text(size: 10pt, fill: subtitle-color, subtitle)
          ]
          let tab-width = calc.min(size.width * 0.5,
            calc.max(26mm, measure(title-content).width + 12mm))
          let tab-height = calc.max(7mm,
            measure(title-content, width: tab-width - 10mm).height + 3mm)
          let subtitle-width = size.width - tab-width - 8mm
          let header-height = calc.max(tab-height + 3mm,
            if subtitle == [] { 0mm } else {
              measure(subtitle-content, width: subtitle-width).height + 4mm
            })
          let rib-x = if is-rtl { size.width - tab-width } else { 0mm }
          let txt-x = if is-rtl { size.width - tab-width + 7mm } else { 3mm }
          let sub-x = if is-rtl { 4mm } else { size.width - subtitle-width - 4mm }
          let ribbon = box(width: tab-width, height: tab-height + 3mm, curve(
            fill: ribbon-color, stroke: none,
            curve.move((0mm, 0mm)), curve.line((tab-width, 0mm)),
            curve.line((tab-width, tab-height + 3mm)),
            curve.cubic((tab-width, tab-height + 1mm),
              (tab-width - 1mm, tab-height), (tab-width - 3mm, tab-height)),
            curve.line((6mm, tab-height)),
            curve.cubic((3mm, tab-height), (3mm, 0mm), (0mm, 0mm)),
            curve.close(),
          ))
          block(width: 100%, height: header-height, spacing: 0pt)[
            #place(top + left, dx: rib-x, mirror-gfx(is-rtl, ribbon))
            #place(top + left, dx: txt-x,
              block(width: tab-width - 10mm, height: tab-height, spacing: 0pt)[
                #align(center + horizon, move(dy: -frame-width / 2, title-content))
              ])
            #if subtitle != [] {
              place(top + left, dx: sub-x, dy: 1mm,
                block(width: subtitle-width, spacing: 0pt)[
                  #align(start, subtitle-content)
                ])
            }
          ]
        })
      ]
      #block(width: 100%, breakable: breakable, spacing: 0pt,
        inset: (x: 5mm, top: 2mm, bottom: 5mm))[
        #align(start)[#body]
      ]
    ]
  ]
}

// 16. Definition frame with a folded gradient tab hanging above the frame.
#let folded-definition-frame-raw(
  body,
  title: auto,
  color: rgb("421B68"),
  frame-color: auto,
  title-text-color: white,
  background: white,
  title-size: 13pt,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let heading = pick-title(title, [تعريف], [Definition])
  let frame-col = if frame-color == auto { color } else { frame-color }
  block(width: 100%, breakable: breakable, above: 8mm, below: 7mm,
    fill: frame-col.lighten(84%), radius: 3mm, inset: 0.9mm)[
    #block(width: 100%, breakable: breakable, spacing: 0pt,
      fill: background, stroke: 0.45pt + frame-col.darken(70%), radius: 1.8mm, inset: 0pt)[
      #block(width: 100%, breakable: false, sticky: true, spacing: 0pt)[
        #layout(size => {
          assert(size.width >= 40mm, message: "folded-definition-frame needs 40mm of inner width")
          let label = [
            #set par(leading: 2pt, spacing: 0pt)
            #text(size: title-size, weight: "bold", fill: title-text-color, heading)
          ]
          let tab-width = calc.min(size.width - 14mm,
            calc.max(25mm, measure(label).width + 8mm))
          let tab-height = calc.max(8mm,
            measure(label, width: tab-width - 8mm).height + 3mm)
          let tab-left = if is-rtl { size.width - tab-width - 6mm } else { 6mm }
          let pointer-x = if is-rtl { tab-left + 2mm } else { tab-left + tab-width - 4.4mm }
          block(width: 100%, height: tab-height + 2mm, spacing: 0pt)[
            #place(top + left, dx: tab-left - 3mm, dy: -2mm,
              polygon((0mm, 2mm), (3mm, 0mm), (3mm, 2mm),
                fill: color.lighten(55%), stroke: none))
            #place(top + left, dx: tab-left + tab-width, dy: -2mm,
              polygon((0mm, 0mm), (3mm, 2mm), (0mm, 2mm),
                fill: color.lighten(55%), stroke: none))
            #place(top + left, dx: tab-left, dy: -1.4mm,
              rect(width: tab-width, height: tab-height,
                fill: rgb("666666"), stroke: none))
            #place(top + left, dx: pointer-x, dy: tab-height - 2mm,
              polygon((0mm, 0mm), (1.2mm, 2mm), (2.4mm, 0mm),
                fill: color.darken(40%), stroke: 0.35pt + rgb("666666")))
            #place(top + left, dx: tab-left, dy: -2mm,
              rect(width: tab-width, height: tab-height,
                fill: gradient.linear(rgb("888888"), color, angle: 0deg), stroke: none))
            #place(top + left, dx: tab-left + 4mm, dy: -2mm,
              block(width: tab-width - 8mm, height: tab-height, spacing: 0pt)[
                #align(center + horizon, label)
              ])
          ]
        })
      ]
      #block(width: 100%, breakable: breakable, spacing: 0pt,
        inset: (x: 6mm, top: 2mm, bottom: 6mm))[
        #align(start)[#body]
      ]
    ]
  ]
}

// 17. Centered title tab between two thick bands.
#let centered-info-frame-raw(
  body,
  title: auto,
  color: rgb("4B0082"),
  title-color: auto,
  frame-color: black,
  title-text-color: white,
  background: white,
  band-thickness: 1.5mm,
  title-size: 16pt,
  breakable: true,
) = context {
  let heading = pick-title(title, [معلومات هامة], [Important])
  let tab-fill = label-color(color, title-color)
  block(width: 100%, breakable: breakable, above: 7mm, below: 7mm,
    fill: background,
    stroke: (top: band-thickness + color, bottom: band-thickness + color,
      left: 0.45pt + frame-color, right: 0.45pt + frame-color), inset: 0pt,
  )[
    #block(width: 100%, breakable: false, sticky: true, spacing: 0pt)[
      #layout(size => {
        assert(size.width >= 40mm, message: "centered-info-frame needs at least 40mm of width")
        let label = [
          #set par(leading: 2pt, spacing: 0pt)
          #text(size: title-size, weight: "bold", top-edge: "bounds", bottom-edge: "bounds", fill: title-text-color, heading)
        ]
        let tab-width = calc.min(size.width - 12mm,
          calc.max(44mm, measure(label).width + 12mm))
        let tab-height = calc.max(10mm,
          measure(label, width: tab-width - 10mm).height + 4mm)
        let tab-left = (size.width - tab-width) / 2
        block(width: 100%, height: tab-height + 2mm, spacing: 0pt)[
          #place(top + left, dx: tab-left, curve(
            fill: tab-fill, stroke: none,
            curve.move((0mm, 0mm)), curve.line((tab-width, 0mm)),
            curve.cubic((tab-width - 3mm, 0mm), (tab-width - 1mm, tab-height),
              (tab-width - 4mm, tab-height)),
            curve.line((4mm, tab-height)),
            curve.cubic((1mm, tab-height), (3mm, 0mm), (0mm, 0mm)),
            curve.close(),
          ))
          #place(top + left, dx: tab-left + 5mm,
            block(width: tab-width - 10mm, height: tab-height, spacing: 0pt)[
              #align(center + horizon, move(dy: band-thickness / 4, label))
            ])
        ]
      })
    ]
    #block(width: 100%, breakable: breakable, spacing: 0pt,
      inset: (x: 6mm, top: 1mm, bottom: 6mm))[
      #align(start)[#body]
    ]
  ]
}

// 18. Two hanging tabs: a main title on the START side and a subtitle on the END side.
#let double-tab-frame-raw(
  body,
  title: auto,
  subtitle: [],
  title-color: rgb("290044"),
  title-text-color: white,
  title-border-color: auto,
  frame-color: rgb("888888"),
  subtitle-color: rgb("800000"),
  subtitle-background: rgb("EDE5F2"),
  subtitle-border-color: rgb("666666"),
  background: white,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let heading = pick-title(title, [خاصية], [Property])
  let tab(label, tab-width, tab-height, paint, border) = block(
    width: tab-width, height: tab-height, spacing: 0pt,
  )[
    #for mirrored in (false, true) {
      let point(horizontal, vertical) = (
        if mirrored { tab-width - horizontal } else { horizontal }, vertical,
      )
      place(top + left, curve(
        fill: paint.darken(30%), stroke: stroke(paint: border, thickness: 0.35pt, join: "round"),
        curve.move(point(-2mm, 1.5mm)),
        curve.cubic(point(-1.5mm, 0mm), point(0mm, 0mm), point(1mm, 0mm)),
        curve.line(point(3mm, 1.5mm)), curve.close(),
      ))
    }
    #place(top + left, curve(
      fill: paint, stroke: stroke(paint: border, thickness: 0.45pt, join: "round"),
      curve.move((tab-width / 2, 0mm)), curve.line((tab-width, 0mm)),
      curve.cubic((tab-width - 2mm, 1mm), (tab-width - 2mm, tab-height - 2mm),
        (tab-width - 3mm, tab-height)),
      curve.line((3mm, tab-height)),
      curve.cubic((2mm, tab-height - 2mm), (2mm, 1mm), (0mm, 0mm)),
      curve.line((tab-width / 2, 0mm)),
      curve.close(),
    ))
    #place(top + left, dx: 4mm,
      block(width: tab-width - 8mm, height: tab-height, spacing: 0pt)[
        #align(center + horizon, label)
      ])
  ]
  block(width: 100%, breakable: breakable, above: 7mm, below: 7mm,
    fill: background, stroke: 0.7pt + frame-color, radius: 1.5mm, inset: 0pt)[
    #block(width: 100%, breakable: false, sticky: true, spacing: 0pt)[
      #layout(size => {
        assert(size.width >= 60mm, message: "double-tab-frame needs at least 60mm of width")
        let label = [
          #set par(leading: 2pt, spacing: 0pt)
          #text(size: 12pt, weight: "bold", fill: title-text-color, heading)
        ]
        let secondary = [
          #set par(leading: 2pt, spacing: 0pt)
          #text(size: 10pt, weight: "bold", fill: subtitle-color, subtitle)
        ]
        let main-width = calc.min(size.width * 0.35,
          calc.max(24mm, measure(label).width + 10mm))
        let sub-width = calc.min(size.width - main-width - 16mm,
          calc.max(32mm, measure(secondary).width + 10mm))
        let main-height = calc.max(8mm, measure(label, width: main-width - 8mm).height + 3mm)
        let sub-height = if subtitle == [] { 0mm } else {
          calc.max(8mm, measure(secondary, width: sub-width - 8mm).height + 3mm)
        }
        let main-x = if is-rtl { size.width - main-width - 6mm } else { 6mm }
        let sub-x = if is-rtl { 6mm } else { size.width - sub-width - 6mm }
        block(width: 100%, height: calc.max(main-height, sub-height) + 2mm, spacing: 0pt)[
          #place(top + left, dx: main-x, dy: -2mm,
            tab(label, main-width, main-height, title-color,
              if title-border-color == auto { title-color } else { title-border-color }))
          #if subtitle != [] {
            place(top + left, dx: sub-x, dy: -2mm,
              tab(secondary, sub-width, sub-height, subtitle-background, subtitle-border-color))
          }
        ]
      })
    ]
    #block(width: 100%, breakable: breakable, spacing: 0pt,
      inset: (x: 6mm, top: 2mm, bottom: 6mm))[
      #align(start)[#body]
    ]
  ]
}

// ═══════════════════════════════════════════════════════════════
// 7. Notes / numbered exercise frames
// ═══════════════════════════════════════════════════════════════

// na-frame — notebook / torn paper / numbered exercise frames.

// 19. Torn paper: jagged edges, optional title and subtitle.
#let torn-paper-frame-raw(
  body,
  title: [],
  subtitle: [],
  title-color: rgb("4B0082"),
  subtitle-color: rgb("800000"),
  frame-color: rgb("444444"),
  background: rgb("EAE1F0"),
  outside-color: white,
  shadow-color: rgb("BFBFBF"),
  breakable: true,
) = context {
  let doc-dir = text.dir
  let edge(horizontal: true, reverse: false, shadow: false) = {
    let point(along, across) = {
      let depth = if reverse { 2mm - across } else { across }
      if horizontal { (along, depth) } else { (depth, along) }
    }
    let teeth = ((0mm, 0.8mm), (0.7mm, 1.1mm), (1.4mm, 0.6mm),
      (2mm, 0.9mm), (3.1mm, 0.7mm), (3.8mm, 1.2mm),
      (4.2mm, 0.6mm), (5.3mm, 1mm), (6mm, 0.8mm))
    tiling(size: if horizontal { (6mm, 2mm) } else { (2mm, 6mm) }, {
      place(top + left, rect(width: if horizontal { 6mm } else { 2mm },
        height: if horizontal { 2mm } else { 6mm }, fill: outside-color, stroke: none))
      if shadow {
        place(top + left, polygon(
          ..teeth.map(vertex => point(vertex.at(0), vertex.at(1) - 0.5mm)),
          point(6mm, 2mm), point(0mm, 2mm), fill: shadow-color, stroke: none))
      }
      place(top + left, polygon(..teeth.map(vertex => point(..vertex)),
        point(6mm, 2mm), point(0mm, 2mm), fill: background, stroke: none))
      place(top + left, curve(
        curve.move(point(..teeth.first())),
        ..teeth.slice(1).map(vertex => curve.line(point(..vertex))),
        stroke: 0.35pt + frame-color,
      ))
    })
  }
  block(width: 100%, breakable: breakable, above: 7mm, below: 7mm)[
    #set text(dir: ltr)
    #grid(columns: (2mm, 1fr, 2mm), gutter: 0pt, inset: 0pt, stroke: none,
      grid.cell(colspan: 3, fill: edge(),
        block(height: 2mm, sticky: true, spacing: 0pt)),
      grid.cell(fill: edge(horizontal: false), breakable: breakable)[],
      grid.cell(fill: background, inset: (x: 4mm, y: 3mm), breakable: breakable)[
        #set text(dir: doc-dir)
        #set align(start)
        #if title != [] or subtitle != [] {
          block(width: 100%, breakable: false, sticky: true, below: 3mm)[
            #set par(leading: 2pt, spacing: 2mm)
            #if title != [] { text(size: 13pt, weight: "bold", fill: title-color, title) }
            #if title != [] and subtitle != [] { parbreak() }
            #if subtitle != [] { text(size: 10pt, fill: subtitle-color, subtitle) }
          ]
        }
        #body
      ],
      grid.cell(fill: edge(horizontal: false, reverse: true, shadow: true),
        breakable: breakable)[],
      grid.cell(colspan: 3, fill: edge(reverse: true, shadow: true),
        block(height: 2mm, spacing: 0pt)),
    )
  ]
}

// 20. Colored title bar above a page with a metal binding on the START side.
#let spiral-banner-frame-raw(
  body,
  title: auto,
  title-color: rgb("663399"),
  title-text-color: white,
  frame-color: rgb("FFECD9"),
  binding-color: rgb("888888"),
  title-size: 16pt,
  title-raise: 0mm,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let doc-dir = text.dir
  let heading = pick-title(title, [عنوان الإطار], [Frame title])
  let tile = box(width: 8mm, height: 5mm, {
    place(top + left, rect(width: 8mm, height: 5mm, fill: white, stroke: none))
    place(top + left, rect(width: 6mm, height: 5mm, fill: frame-color, stroke: none))
    place(top + left, dx: 2.2mm, dy: 0.8mm, circle(
      radius: 1mm, fill: white, stroke: 0.4pt + binding-color.darken(55%)))
    place(top + left, dx: 2.8mm, dy: 1.4mm, circle(
      radius: 0.4mm, fill: binding-color.darken(65%), stroke: none))
    place(top + left, curve(
      fill: binding-color, stroke: 0.4pt + binding-color.darken(65%),
      curve.move((3.1mm, 1.8mm)),
      curve.cubic((2.7mm, 2mm), (2.7mm, 3.1mm), (4mm, 3.3mm)),
      curve.cubic((7.8mm, 3.3mm), (8mm, 2mm), (6.8mm, 1.8mm)),
      curve.line((6.6mm, 2.2mm)),
      curve.cubic((7.5mm, 2.6mm), (5.5mm, 2.9mm), (3.8mm, 2.8mm)),
      curve.cubic((3.4mm, 2.7mm), (3.1mm, 2.2mm), (3.4mm, 1.9mm)),
      curve.close(),
    ))
  })
  let binding = tiling(size: (8mm, 5mm), mirror-gfx(is-rtl, tile))
  let body-cell = grid.cell(fill: frame-color, breakable: breakable,
    inset: if is-rtl { (left: 5mm, right: 2mm, y: 3mm) } else { (left: 2mm, right: 5mm, y: 3mm) })[
    #set text(dir: doc-dir)
    #set align(start)
    #body
  ]
  let bind-cell = grid.cell(fill: binding, breakable: breakable)[]
  let cells = if is-rtl { (body-cell, bind-cell) } else { (bind-cell, body-cell) }
  block(width: 100%, breakable: breakable, above: 7mm, below: 7mm)[
    #set align(if is-rtl { left } else { right })
    #block(width: 100% - 2mm, height: 11mm, breakable: false, sticky: true, spacing: 0pt,
      fill: gradient.linear(title-color.lighten(35%), title-color, angle: 0deg),
      inset: (x: 7mm, y: 0pt))[
      #set par(leading: 2pt, spacing: 0pt)
      #align(horizon + start)[
        #move(dy: -title-raise)[
          #text(size: title-size, weight: "bold", fill: title-text-color, heading)
        ]
      ]
    ]
    #block(width: 100%, breakable: breakable, spacing: 0pt)[
      #set text(dir: ltr)
      #grid(columns: if is-rtl { (1fr, 8mm) } else { (8mm, 1fr) },
        gutter: 0pt, inset: 0pt, stroke: none, ..cells)
    ]
  ]
}

// 21. Ruled notebook page with a spiral binding on the END side and an underlined title.
#let notebook-page-frame-raw(
  body,
  title: auto,
  title-color: rgb("A32142"),
  text-color: rgb("202858"),
  paper-color: rgb("FFFEF2"),
  rule-color: rgb("B9DEDF"),
  major-rule-color: rgb("C995AF"),
  binding-color: rgb("AFB99A"),
  title-size: 16pt,
  title-raise: 0mm,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let doc-dir = text.dir
  let heading = pick-title(title, [مبرهنة], [Theorem])
  let paper = tiling(size: (8mm, 8mm), {
    place(top + left, rect(width: 8mm, height: 8mm, fill: paper-color, stroke: none))
    for offset in (2mm, 4mm, 6mm) {
      place(top + left, curve(
        curve.move((0mm, offset)), curve.line((8mm, offset)),
        stroke: 0.3pt + rule-color,
      ))
    }
    place(top + left, curve(
      curve.move((0mm, 0mm)), curve.line((8mm, 0mm)),
      stroke: 0.45pt + major-rule-color,
    ))
    place(top + left, curve(
      curve.move((0mm, 0mm)), curve.line((0mm, 8mm)),
      stroke: 0.45pt + major-rule-color,
    ))
  })
  let ring-tile = box(width: 12mm, height: 8mm, {
    place(top + left, rect(width: 12mm, height: 8mm, fill: white, stroke: none))
    place(top + left, rect(width: 8mm, height: 8mm, fill: paper, stroke: none))
    place(top + left, dx: 4mm, dy: 1.8mm, circle(
      radius: 1.2mm, fill: white, stroke: 0.4pt + binding-color.darken(55%)))
    for offset in (0.6mm, 1.8mm) {
      place(top + left, dx: 4.8mm, dy: 1.4mm + offset, circle(
        radius: 0.4mm, fill: binding-color.darken(65%), stroke: none))
      place(top + left, dx: 2mm, dy: offset, curve(
        fill: binding-color, stroke: 0.4pt + binding-color.darken(65%),
        curve.move((3.1mm, 1.8mm)),
        curve.cubic((2.7mm, 2mm), (2.7mm, 3.1mm), (4mm, 3.3mm)),
        curve.cubic((7.8mm, 3.3mm), (8mm, 2mm), (6.8mm, 1.8mm)),
        curve.line((6.6mm, 2.2mm)),
        curve.cubic((7.5mm, 2.6mm), (5.5mm, 2.9mm), (3.8mm, 2.8mm)),
        curve.cubic((3.4mm, 2.7mm), (3.1mm, 2.2mm), (3.4mm, 1.9mm)),
        curve.close(),
      ))
    }
  })
  let rings = tiling(size: (12mm, 8mm), mirror-gfx(is-rtl, ring-tile))
  let paper-cell = grid.cell(fill: paper, breakable: breakable,
    inset: if is-rtl {
      (left: 6mm, right: 5mm, top: 6mm, bottom: 6mm)
    } else {
      (left: 5mm, right: 6mm, top: 6mm, bottom: 6mm)
    })[
    #set text(dir: doc-dir, fill: text-color)
    #set align(start)
    #block(width: 100%, breakable: false, sticky: true, above: 0pt, below: 5mm)[
      #set par(leading: 2pt, spacing: 0pt)
      #move(dy: -title-raise)[
        #text(size: title-size, weight: "bold", fill: title-color)[
          #underline(stroke: 0.7pt + title-color, heading)
        ]
      ]
    ]
    #body
  ]
  let ring-cell = grid.cell(fill: rings, breakable: breakable)[]
  let cells = if is-rtl { (paper-cell, ring-cell) } else { (ring-cell, paper-cell) }
  block(width: 100%, breakable: breakable, above: 7mm, below: 7mm)[
    #set text(dir: ltr)
    #grid(columns: if is-rtl { (1fr, 12mm) } else { (12mm, 1fr) },
      gutter: 0pt, inset: 0pt, stroke: none, ..cells)
  ]
}

// Counter used by numbered-exercise-frame (reset with `exercise-counter.update(0)`).
#let exercise-counter = counter("na-frame-numbered-exercise")

// 22. Auto-numbered exercise header: pill badge with a number circle, points arrow, third title.
#let numbered-exercise-frame-raw(
  body,
  title: auto,
  subtitle: [],
  third-title: [],
  color: rgb("D9688C"),
  secondary-color: rgb("0099C7"),
  title-color: auto,
  title-text-color: white,
  number-color: black,
  title-size: 14pt,
  title-raise: 0mm,
  number-raise: 0mm,
  subtitle-raise: 0mm,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let heading = pick-title(title, [التمرين], [Exercise])
  let badge-fill = label-color(color, title-color)
  block(width: 100%, breakable: breakable, above: 7mm, below: 7mm)[
    #block(width: 100%, breakable: false, sticky: true, above: 0pt, below: 3mm)[
      #exercise-counter.step()
      #layout(size => {
        let label = [
          #set par(leading: 2pt, spacing: 0pt)
          #text(size: title-size, weight: "bold", top-edge: "bounds", bottom-edge: "bounds", fill: title-text-color, heading)
        ]
        let secondary = [
          #set par(leading: 2pt, spacing: 0pt)
          #text(size: 12pt, weight: "bold", top-edge: "bounds", bottom-edge: "bounds", fill: title-text-color, subtitle)
        ]
        let third = [
          #set par(leading: 2pt, spacing: 0pt)
          #text(size: 10pt, weight: "bold", fill: secondary-color, third-title)
        ]
        assert(size.width >= 90mm,
          message: "numbered-exercise-frame needs at least 90mm of width")
        let badge-width = calc.min(size.width * 0.35,
          calc.max(34mm, measure(label).width + 18mm))
        let badge-height = calc.max(10mm,
          measure(label, width: badge-width - 16mm).height + 3mm)
        let points-width = if subtitle == [] { 0mm } else {
          calc.min(size.width * 0.25, calc.max(20mm, measure(secondary).width + 9mm))
        }
        let points-height = if subtitle == [] { 0mm } else {
          calc.max(8mm, measure(secondary, width: points-width - 7mm).height + 3mm)
        }
        let third-width = size.width - badge-width - points-width - 8mm
        let header-height = calc.max(badge-height, points-height,
          if third-title == [] { 0mm } else { measure(third, width: third-width).height })
        let badge-x = if is-rtl { size.width - badge-width } else { 0mm }
        let pill-x = if is-rtl { badge-height / 2 } else { 0mm }
        let circle-x = if is-rtl { 0mm } else { badge-width - badge-height }
        let pill-inset = if is-rtl {
          (left: badge-height / 2 + 2mm, right: 4mm)
        } else {
          (left: 4mm, right: badge-height / 2 + 2mm)
        }
        let points-x = if is-rtl { third-width + 4mm } else { badge-width + 4mm }
        let third-x = if is-rtl { 0mm } else { size.width - third-width }
        let arrow = if is-rtl {
          ((3mm, 0mm), (points-width, 0mm), (points-width, points-height),
            (3mm, points-height), (0mm, points-height / 2))
        } else {
          ((0mm, 0mm), (points-width - 3mm, 0mm), (points-width, points-height / 2),
            (points-width - 3mm, points-height), (0mm, points-height))
        }
        let points-inset = if is-rtl { (left: 4mm, right: 3mm) } else { (left: 3mm, right: 4mm) }
        block(width: 100%, height: header-height, spacing: 0pt)[
          #place(top + left, dx: badge-x,
            dy: (header-height - badge-height) / 2,
            block(width: badge-width, height: badge-height, spacing: 0pt)[
              #place(top + left, dx: pill-x,
                block(width: badge-width - badge-height / 2, height: badge-height,
                  fill: badge-fill, radius: badge-height / 2, spacing: 0pt,
                  inset: pill-inset)[
                  #align(center + horizon, move(dy: -title-raise, label))
                ])
              #place(top + left, dx: circle-x,
                circle(radius: badge-height / 2, fill: white, stroke: 0.8pt + badge-fill))
              #place(top + left, dx: circle-x,
                block(width: badge-height, height: badge-height, spacing: 0pt)[
                  #set text(dir: ltr, size: 13pt, weight: "bold", top-edge: "bounds", bottom-edge: "bounds", fill: number-color)
                  #set par(leading: 2pt, spacing: 0pt)
                  #align(center + horizon)[
                    #move(dy: -number-raise)[#context exercise-counter.display("1")]
                  ]
                ])
            ])
          #if subtitle != [] {
            place(top + left, dx: points-x,
              dy: (header-height - points-height) / 2,
              block(width: points-width, height: points-height, spacing: 0pt)[
                #place(top + left, polygon(..arrow, fill: secondary-color, stroke: none))
                #block(width: 100%, height: 100%, spacing: 0pt, inset: points-inset)[
                  #align(center + horizon, move(dy: -subtitle-raise, secondary))
                ]
              ])
          }
          #if third-title != [] {
            place(top + left, dx: third-x,
              block(width: third-width, height: header-height, spacing: 0pt)[
                #align(start + horizon, third)
              ])
          }
        ]
      })
    ]
    #block(width: 100%, breakable: breakable, spacing: 0pt)[
      #align(start)[#body]
    ]
  ]
}

// ═══════════════════════════════════════════════════════════════
// 8. Additional frames / إطارات إضافية
// ═══════════════════════════════════════════════════════════════

#let numbered-frame-raw(
  body,
  title: auto, number: [1], subtitle: [], color: rgb("#850b16"), title-color: auto, title-text-color: black, breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  // `side`: where the title tab sits (right in RTL, LEFT in LTR).
  let side = if is-rtl { right } else { left }
  let far = if is-rtl { left } else { right }
  let sx(v) = if is-rtl { v } else { -v }
  let title = pick-title(title, [التمرين رقم], [Exercise])
  let tab-color = label-color(color, title-color)
  let heading = text(size: 15pt, weight: "bold", top-edge: "bounds", bottom-edge: "bounds", fill: title-text-color)[#title]
  let numeral = text(size: 14pt, weight: "bold", top-edge: "bounds", bottom-edge: "bounds", fill: title-text-color)[#number]
  let w = measure(heading).width + 12mm
  let d = calc.max(10mm, measure(numeral).width + 5mm)
  let h = calc.max(d, measure(heading).height + 4mm)
  let label = box(width: w + d / 2, height: h)[
    #place(top + side,
      block(width: w, height: h, fill: tab-color.lighten(90%),
        stroke: mirror-dict(is-rtl, (top: .8pt + tab-color, right: .8pt + tab-color,
          bottom: 2pt + tab-color, left: none)),
        inset: mirror-dict(is-rtl, (left: d / 2, right: 3mm)),
        breakable: breakable)[#align(center + horizon)[#heading]])
    #place(top + side, mirror-gfx(is-rtl, curve(fill: tab-color, stroke: none,
      curve.move((0mm, 0mm)), curve.line((4mm, 0mm)),
      curve.line((4mm, 4mm)), curve.close())))
    #place(top + far, dy: (h - d) / 2,
      box(width: d, height: d)[
        #place(top + left, curve(fill: white, stroke: .9pt + tab-color,
          curve.move((d / 2, 0mm)), curve.line((d, d / 2)),
          curve.line((d / 2, d)), curve.line((0mm, d / 2)), curve.close()))
        #place(top + left,
          block(width: d, height: d, breakable: breakable)[#align(center + horizon)[#numeral]])
      ])
  ]
  block(width: 100%, height: auto, fill: white,
    stroke: mirror-dict(is-rtl, (right: 1.5pt + color, bottom: 1.5pt + color, top: none, left: none)),
    inset: 0pt, above: 5mm, breakable: breakable)[
    #place(top + side, label)
    #place(top + side, dx: sx(-w - d / 2 - 2mm), dy: (h - 5mm) / 2,
      mirror-gfx(is-rtl, box(width: 8mm, height: 5mm)[
        #for i in range(4) {
          place(top + left, dx: i * 2mm,
            curve(fill: none, stroke: 1.2pt + tab-color.lighten((3 - i) * 20%),
              curve.move((1.5mm, 0mm)), curve.line((0mm, 2.5mm)),
              curve.line((1.5mm, 5mm))))
        }
      ]))
    #if subtitle != [] {
      place(top + side, dx: sx(-w - d / 2 - 13mm),
        block(height: h, breakable: breakable)[
          #align(start + horizon)[#text(size: 12pt, weight: "bold", fill: color)[#subtitle]]
        ])
    }
    #pad(top: h + 5mm, bottom: 5mm, left: 5mm, right: 5mm)[#align(start)[#body]]
  ]
}

#let property-frame-raw(
  body,
  title: auto, color: rgb("#e600d5"), title-color: auto, title-text-color: black, badge-top: auto, badge-bottom: auto, badge-color: rgb("#efb500"), breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let side = if is-rtl { right } else { left }
  let far = if is-rtl { left } else { right }
  let title = pick-title(title, [خاصية], [Property])
  let badge-top = pick-title(badge-top, [أضف إلى], [Add to])
  let badge-bottom = pick-title(badge-bottom, [معلوماتك], [your notes])
  let tab-color = label-color(color, title-color)
  let heading = text(size: 15pt, weight: "bold", fill: title-text-color)[#title]
  let w = measure(heading).width + 10mm
  let h = calc.max(9mm, measure(heading).height + 3mm)
  let reminder = text(size: 9pt, weight: "bold")[#badge-bottom]
  let b = calc.max(16mm, measure(reminder).width + 4mm)
  let paper = color.lighten(97%)
  let band = block(width: 100%, height: h, inset: 0pt, breakable: breakable)[
    #layout(size => {
      // Drawn for RTL (title tab on the right); x is mirrored in LTR.
      let X(x) = if is-rtl { x } else { size.width - x }
      curve(
        fill: gradient.linear(tab-color, paper, angle: 90deg), stroke: .6pt + tab-color,
        curve.move((X(0mm), 0mm)), curve.line((X(size.width), 0mm)),
        curve.line((X(size.width), h)), curve.line((X(size.width - w), h)),
        curve.cubic((X(size.width - w - 3mm), h), (X(size.width - w - 3mm), 4mm),
          (X(size.width - w - 7mm), 4mm)),
        curve.line((X(b + 7mm), 4mm)),
        curve.cubic((X(b + 3mm), 4mm), (X(b + 3mm), h), (X(b), h)),
        curve.line((X(0mm), h)), curve.close(),
      )
    })
    #place(top + side,
      block(width: w, height: h, inset: 1mm, breakable: breakable)[#align(center + horizon)[#heading]])
    #place(top + far,
      block(width: b, height: h, inset: 1mm, breakable: breakable)[
        #align(center + horizon)[#text(size: 9pt, weight: "bold")[#badge-top]]
      ])
    #place(top + far, dy: h + .8mm,
      box(width: b, height: 7mm)[
        #place(top + left, curve(fill: badge-color, stroke: none,
          curve.move((0mm, 0mm)), curve.line((b, 0mm)), curve.line((b, 7mm)),
          curve.line((b / 2, 5.5mm)), curve.line((0mm, 7mm)), curve.close()))
        #place(top + left,
          block(width: b, height: 5.5mm, inset: .5mm, breakable: breakable)[
            #align(center + horizon)[#reminder]
          ])
      ])
  ]
  block(width: 100%, height: auto, fill: paper, stroke: .6pt + color,
    radius: 1mm, inset: 0pt, above: 5mm, breakable: breakable)[
    #place(top + left, band)
    #pad(top: h + 10mm, bottom: 5mm, left: 5mm, right: 5mm)[#align(start)[#body]]
  ]
}

#let exercise-card-raw(
  body,
  title: auto, points: [], subtitle: [], color: rgb("#348c43"), title-color: auto, title-text-color: white, icon: true, breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let side = if is-rtl { right } else { left }
  let sx(v) = if is-rtl { v } else { -v }
  let title = pick-title(title, [تمرين], [Exercise])
  let tab-color = label-color(color, title-color)
  let heading = text(size: 14pt, weight: "bold", fill: title-text-color)[#title]
  let score = text(size: 11pt, weight: "bold", fill: color)[#points]
  let w = measure(heading).width + 10mm
  let p = if points == [] { 0mm } else { measure(score).width + 6mm }
  let h = calc.max(10mm, measure(heading).height + 4mm)
  let corner = 2.5mm
  let label-width = w + p + 8mm
  let label = box(width: label-width, height: h + 2mm)[
    // Same fold geometry, color and layering as the second (blue) frame.
    #place(top + side, dy: h - .5mm,
      mirror-gfx(is-rtl, curve(fill: tab-color.lighten(45%), stroke: none,
        curve.move((0mm, 0mm)),
        curve.line((1.5mm, 0mm)),
        curve.cubic((1.5mm, 1.5mm), (.75mm, 2.5mm), (0mm, 2.5mm)),
        curve.close())))
    #place(top + left, mirror-gfx(is-rtl, curve(fill: tab-color.lighten(75%), stroke: none,
      curve.move((0mm, 0mm)), curve.line((label-width - corner, 0mm)),
      curve.cubic((label-width - corner * .4477, 0mm),
        (label-width, corner * .4477), (label-width, corner)),
      curve.line((label-width, h)), curve.line((8mm, h)),
      curve.cubic((5mm, h), (3mm, 0mm), (0mm, 0mm)), curve.close())))
    #place(top + side, dx: 0pt, dy: 0pt,
      block(width: w + p / 2, height: h, fill: tab-color,
        stroke: mirror-dict(is-rtl, (top: .6pt + color, right: .6pt + color, bottom: none, left: none)),
        radius: mirror-dict(is-rtl, (top-right: corner)),
        inset: mirror-dict(is-rtl, (left: p / 2, right: 2mm)),
        breakable: breakable)[#align(center + horizon)[#heading]])
    #if points != [] {
      place(top + side, dx: sx(-w),
        block(width: p, height: h, fill: white, stroke: .5pt + color,
          radius: h / 2, inset: 1mm, breakable: breakable)[#align(center + horizon)[#score]])
    }
  ]
  block(width: 100%, height: auto, fill: color.lighten(98%), stroke: .6pt + color,
    radius: corner, inset: 0pt, above: 5mm, breakable: breakable)[
    // Match the blue frame overhang: the inner end of the fold meets the frame.
    #place(top + side, dx: sx(1.5mm), dy: 0pt, label)
    #if subtitle != [] {
      place(top + side, dx: sx(-w - p - 10mm),
        block(height: h, breakable: breakable)[
          #align(start + horizon)[#text(size: 11pt, fill: color)[#subtitle]]
        ])
    }
    #pad(top: h + 4mm, bottom: 5mm, left: 5mm, right: 5mm)[
      #if icon {
        // RTL grid: text on the right and illustration on the left, both at the top.
        grid(
          columns: (1fr, 18mm),
          rows: auto,
          column-gutter: 4mm,
          align: top,
          inset: 0pt,
          stroke: none,
          grid.cell(breakable: breakable)[#align(start)[#body]],
          grid.cell(breakable: breakable)[#exercise-clipboard(color)],
        )
      } else {
        align(start)[#body]
      }
    ]
  ]
}

#let tab-frame-raw(
  body,
  title: auto, title-color: black, title-text-color: white, title-width: auto, background: white, border-color: rgb("777777"), breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let title = pick-title(title, [تعريف], [Definition])
  // The tab fits the title: its width and height follow the title text and the
  // title is centered inside it. / اللسان يتبع العنوان والعنوان في وسطه تمامًا.
  let label = text(size: 11pt, weight: "bold", fill: title-text-color,
    top-edge: "ascender", bottom-edge: "baseline", title)
  let label-size = measure(label)
  // 1mm above the title and 5mm below it (room for descenders, any size).
  // مسافة 1 مم فوق العنوان و5 مم تحته ليظهر كاملًا مهما كبر.
  let tab-h = label-size.height + 6mm
  let wanted-width = if title-width == auto { calc.max(25mm, label-size.width + 14mm) } else { title-width }
  block(
  width: 100%, breakable: breakable, above: 6mm, below: 6mm,
  fill: background, stroke: 0.6pt + border-color, radius: 2mm, inset: 0pt,
)[
  #set align(start)
  #block(width: 100%, height: tab-h + 3mm, breakable: false, sticky: true,
    above: 0pt, below: 0pt)[
    #layout(size => {
      let tab-width = calc.min(wanted-width, size.width)
      let tab-left = size.width - tab-width + 1.3mm
      rorn(is-rtl, size.width, size.width, tab-h - 0.5mm, curve(
        fill: gradient.linear(rgb("B8B8B8"), rgb("777777")), stroke: none,
        curve.move((0mm, 0mm)),
        curve.cubic((0.8mm, 0mm), (1.3mm, 0.7mm), (1.3mm, 1.7mm)),
        curve.cubic((1.3mm, 2.3mm), (0.8mm, 2.8mm), (0mm, 3mm)),
        curve.close(mode: "straight"),
      ))
      rorn(is-rtl, size.width, tab-left, 0mm, curve(
        fill: title-color, stroke: none,
        curve.move((0mm, 0mm)),
        curve.line((tab-width - 2.5mm, 0mm)),
        curve.cubic((tab-width - 1.1mm, 0mm), (tab-width, 1.1mm), (tab-width, 2.5mm)),
        curve.line((tab-width, tab-h + 1.2mm)),
        curve.cubic((tab-width - 0.3mm, tab-h + 0.4mm), (tab-width - 1.3mm, tab-h), (tab-width - 2.5mm, tab-h)),
        curve.line((6.5mm, tab-h)),
        curve.close(mode: "straight"),
      ))
      rtxt(is-rtl, size.width, tab-left + 7mm, 1mm, tab-width - 10mm,
        block(width: tab-width - 10mm, height: label-size.height, spacing: 0pt)[
          #set par(leading: 0.3em, spacing: 0pt)
          #align(center + top)[#label]
        ])
    })
  ]
  #block(width: 100%, breakable: breakable, inset: (x: 6mm, top: 3mm, bottom: 6mm),
    above: 0pt, below: 0pt)[
    #body
  ]
]
}

#let curved-tab-frame-raw(
  body,
  title: auto, breakable: true, title-color: black, title-text-color: white, title-width: auto, background: rgb("FAFAFA"), border-color: rgb("444444"),
) = context {
  let is-rtl = text.dir == rtl
  let title = pick-title(title, [تعريف], [Definition])
  block(
  width: 100%, breakable: breakable, above: 6mm, below: 6mm,
  fill: background, stroke: 0.55pt + border-color, radius: 2.5mm, inset: 0pt,
)[
  #set align(start)
  #block(width: 100%, breakable: false, sticky: true,
    above: 0pt, below: 0pt)[
    #layout(size => {
      let title-content = [
        #set par(leading: 0.3em, spacing: 0pt)
        #text(size: 11pt, weight: "bold", fill: title-text-color,
          top-edge: "cap-height", bottom-edge: "baseline", title)
      ]
      let natural-width = measure(title-content).width + 10mm
      let tab-width = calc.min(size.width, if title-width == auto {
        calc.max(25mm, natural-width)
      } else { title-width })
      let tab-height = calc.max(8mm,
        measure(title-content, width: tab-width - 9mm).height + 4mm)
      let tab-left = size.width - tab-width + 0.9mm
      block(width: 100%, height: tab-height + 2mm, spacing: 0pt, {
        rorn(is-rtl, size.width, size.width, tab-height - 0.5mm, curve(
          fill: gradient.linear(rgb("BBBBBB"), rgb("777777")), stroke: none,
          curve.move((0mm, 0mm)),
          curve.cubic((0.6mm, 0mm), (0.9mm, 0.5mm), (0.9mm, 1mm)),
          curve.cubic((0.9mm, 1.7mm), (0.5mm, 2mm), (0mm, 2.1mm)),
          curve.close(mode: "straight"),
        ))
        rorn(is-rtl, size.width, tab-left, 0mm, curve(
          fill: title-color, stroke: none,
          curve.move((0mm, 0mm)),
          curve.line((tab-width - 2mm, 0mm)),
          curve.cubic((tab-width - 0.9mm, 0mm), (tab-width, 0.9mm), (tab-width, 2mm)),
          curve.line((tab-width, tab-height + 0.9mm)),
          curve.cubic((tab-width - 0.2mm, tab-height + 0.3mm), (tab-width - 0.9mm, tab-height), (tab-width - 1.8mm, tab-height)),
          curve.line((5.5mm, tab-height)),
          curve.cubic((2mm, tab-height), (3mm, 0mm), (0mm, 0mm)),
          curve.close(mode: "straight"),
        ))
        rtxt(is-rtl, size.width, tab-left + 6mm, -1mm, tab-width - 9mm,
          block(width: tab-width - 9mm, height: tab-height, spacing: 0pt)[
            #align(start + horizon, title-content)
          ])
      })
    })
  ]
  #block(width: 100%, breakable: breakable, inset: (x: 5.5mm, top: 1mm, bottom: 6mm),
    above: 0pt, below: 0pt)[
    #body
  ]
]
}

#let speech-frame-raw(
  body,
  title: auto, breakable: true, title-color: white, title-text-color: black, border-color: black, rule-color: rgb("555555"), background: white,
) = context {
  let is-rtl = text.dir == rtl
  let title = pick-title(title, [ملاحظة], [Note])
  block(
  width: 100%, breakable: breakable, above: 7mm, below: 6mm, fill: background,
)[
  #set align(start)
  #block(width: 100%, breakable: false, sticky: true, spacing: 0pt)[
    #layout(size => {
      let title-content = [
        #set par(leading: 0.4em, spacing: 0pt)
        #text(size: 11pt, weight: "bold", fill: title-text-color, title)
      ]
      let tab-width = calc.min(size.width,
        calc.max(32mm, measure(title-content).width + 8mm))
      let title-width = tab-width - 8mm
      let tab-height = calc.max(10mm,
        measure(title-content, width: title-width).height + 4mm)
      let tab-left = size.width - tab-width + 2mm
      block(width: 100%, height: tab-height, breakable: false, spacing: 0pt)[
        #rorn(is-rtl, size.width, size.width, tab-height, polygon(
          (0mm, 0mm), (2mm, 0mm), (0mm, 3mm),
          fill: rule-color, stroke: none,
        ))
        #rorn(is-rtl, size.width, tab-left, 0mm, polygon(
          (0mm, 0mm), (tab-width, 0mm),
          (tab-width, tab-height), (5.5mm, tab-height),
          (4mm, tab-height + 3mm), (2.5mm, tab-height),
          (0mm, tab-height),
          fill: title-color, stroke: 0.8pt + border-color,
        ))
        #rtxt(is-rtl, size.width, tab-left + 4mm, 0mm, title-width,
          block(width: title-width, height: tab-height, spacing: 0pt)[
            #align(center + horizon, title-content)
          ])
      ]
    })
  ]
  #block(
    width: 100%, breakable: breakable, above: 0pt, below: 0pt,
    stroke: mirror-dict(is-rtl, (right: 2pt + rule-color, rest: none)),
    inset: mirror-dict(is-rtl, (left: 2mm, right: 4mm, top: 4mm, bottom: 4mm)),
  )[
    #body
  ]
]
}

#let rounded-tab-frame-raw(
  body,
  title: auto, color: rgb("91B735"), title-text-color: white, background: auto, breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let title = pick-title(title, [تعريف], [Definition])
  block(
  width: 100%, breakable: breakable, above: 8mm, below: 7mm,
  fill: rgb("DDDDDD"),
  radius: mirror-dict(is-rtl, (top-left: 5mm, bottom-right: 5mm, rest: 0pt)),
  inset: mirror-dict(is-rtl, (right: 0.8mm, bottom: 1mm, rest: 0pt)),
)[
  #set align(start)
  #block(
    width: 100%, breakable: breakable, spacing: 0pt,
    fill: if background == auto { color.lighten(96%) } else { background },
    stroke: 0.65pt + color,
    radius: mirror-dict(is-rtl, (top-left: 5mm, bottom-right: 5mm, rest: 0pt)),
    inset: 0pt,
  )[
    #block(width: 100%, breakable: false, sticky: true, spacing: 0pt)[
      #layout(size => {
        let title-content = [
          #set par(leading: 0.4em, spacing: 0pt)
          #text(size: 11pt, weight: "bold", fill: title-text-color,
            top-edge: "cap-height", bottom-edge: "baseline", title)
        ]
        let tab-width = calc.min(size.width - 12mm,
          calc.max(24mm, measure(title-content).width + 10mm))
        let title-width = tab-width - 8mm
        let tab-height = calc.max(9mm,
          measure(title-content, width: title-width).height + 4mm)
        let tab-left = size.width - tab-width - 2mm
        let tab-rise = 2mm
        block(width: 100%, height: tab-height, breakable: false, spacing: 0pt)[
          #for mirrored in (false, true) {
            let point(horizontal, vertical) = (
              if mirrored { tab-left + tab-width - horizontal } else {
                tab-left + horizontal
              },
              vertical,
            )
            rorn(is-rtl, size.width, 0mm, -tab-rise, curve(
              fill: color.darken(48%), stroke: none,
              curve.move(point(-1.5mm, tab-rise)),
              curve.cubic(point(-1.5mm, 0.5mm), point(-0.6mm, 0mm),
                point(1mm, 0mm)),
              curve.line(point(3mm, 0mm)),
              curve.line(point(3mm, tab-rise)),
              curve.line(point(-1.5mm, tab-rise)),
              curve.close(mode: "straight"),
            ))
          }
          #rorn(is-rtl, size.width, tab-left, -tab-rise, curve(
            fill: gradient.linear(color.darken(12%), color.lighten(12%), color),
            stroke: none,
            curve.move((0mm, 0mm)),
            curve.line((tab-width, 0mm)),
            curve.cubic((tab-width - 0.7mm, 1mm), (tab-width - 0.7mm, 2mm),
              (tab-width - 0.7mm, 3mm)),
            curve.line((tab-width - 0.7mm, tab-height - 1.5mm)),
            curve.cubic((tab-width - 0.7mm, tab-height - 0.5mm),
              (tab-width - 1.2mm, tab-height), (tab-width - 2.2mm, tab-height)),
            curve.line((2.2mm, tab-height)),
            curve.cubic((1.2mm, tab-height), (0.7mm, tab-height - 0.5mm),
              (0.7mm, tab-height - 1.5mm)),
            curve.line((0.7mm, 3mm)),
            curve.cubic((0.7mm, 2mm), (0.7mm, 1mm), (0mm, 0mm)),
            curve.close(mode: "straight"),
          ))
          #rtxt(is-rtl, size.width, tab-left + 4mm, -tab-rise, title-width,
            block(width: title-width, height: tab-height, spacing: 0pt)[
              #align(center + horizon, title-content)
            ])
        ]
      })
    ]
    #block(
      width: 100%, breakable: breakable, spacing: 0pt,
      inset: (x: 5mm, top: 2mm, bottom: 5mm),
    )[
      #body
    ]
  ]
]
}

#let exam-frame-raw(
  body,
  number: 1, title: auto, source: [], color: rgb("514BB2"), title-background: auto, title-text-color: white, number-color: black, background: white, breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let title = pick-title(title, [التمرين رقم], [Exercise])
  block(width: 100%, breakable: breakable, above: 7mm, below: 7mm)[
  #set align(start)
  #block(width: 100%, breakable: false, sticky: true, spacing: 0pt)[
    #layout(size => {
      let title-content = text(size: 14pt, weight: "bold",
        fill: title-text-color, title)
      let tab-width = calc.min(size.width * 0.45,
        calc.max(43mm, measure(title-content).width + 8mm))
      let number-width = 14mm
      let header-height = calc.max(10mm,
        measure(title-content, width: tab-width - 6mm).height + 4mm)
      let tab-left = size.width - tab-width
      let number-left = tab-left - number-width
      let number-label = if type(number) == int and number >= 0 and number < 10 {
        "0" + str(number)
      } else { str(number) }
      block(width: 100%, height: header-height, spacing: 0pt)[
        #rtxt(is-rtl, size.width, tab-left, 0mm, tab-width, block(
          width: tab-width, height: header-height,
          fill: if title-background == auto { color } else { title-background },
          stroke: 0.9pt + color,
          inset: (x: 3mm, y: 0pt), spacing: 0pt,
        )[
          #align(center + horizon, move(dy: -1.2mm, title-content))
        ])
        #rtxt(is-rtl, size.width, number-left, 0mm, number-width, block(
          width: number-width, height: header-height,
          fill: background, stroke: 0.9pt + color,
          radius: mirror-dict(is-rtl, (top-left: 3mm, rest: 0pt)), spacing: 0pt,
        )[
          #align(center + horizon, move(dy: -1.2mm)[
            #text(dir: ltr, size: 18pt, weight: "bold",
              fill: number-color, number-label)
          ])
        ])
        #for index in range(4) {
          let arrow-left = number-left - 4mm - index * 1.5mm
          rorn(is-rtl, size.width, arrow-left, (header-height - 6mm) / 2, curve(
            fill: none, stroke: 0.9pt + color.lighten(index * 22%),
            curve.move((2mm, 0mm)), curve.line((0mm, 3mm)),
            curve.line((2mm, 6mm)),
          ))
        }
        #rtxt(is-rtl, size.width, 0mm, 0mm, calc.max(0mm, number-left - 13mm), block(
          width: calc.max(0mm, number-left - 13mm),
          height: header-height, spacing: 0pt,
        )[
          #align(start + horizon)[
            #text(size: 9pt, fill: rgb("151820"), source)
          ]
        ])
      ]
    })
  ]
  #block(
    width: 100%, breakable: breakable, spacing: 0pt,
    fill: background,
    stroke: (left: 1pt + color, right: 1pt + color,
      bottom: 1pt + color, top: none),
    inset: (x: 5mm, top: 5mm, bottom: 5mm),
  )[
    #body
  ]
]
}

#let right-rule-frame-raw(
  body,
  title: auto, title-color: rgb("2DCC2D"), title-text-color: white, rule-color: auto, background: rgb("FAFAFA"), shadow-color: rgb("D6D6D6"), breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let title = pick-title(title, [تعريف], [Definition])
  block(
  width: 100%, breakable: breakable, above: 8mm, below: 7mm,
  fill: shadow-color, inset: mirror-dict(is-rtl, (right: 0.8mm, bottom: 0.8mm, rest: 0pt)),
)[
  #set align(start)
  #block(
    width: 100%, breakable: breakable, spacing: 0pt,
    fill: background, inset: 0pt,
    stroke: mirror-dict(is-rtl, (right: 2mm + (if rule-color == auto { title-color } else { rule-color }),
      rest: none)),
  )[
    #block(width: 100%, breakable: false, sticky: true, spacing: 0pt)[
      #layout(size => {
        let title-content = [
          #set par(leading: 0.4em, spacing: 0pt)
          #text(size: 13pt, weight: "bold", fill: title-text-color,
            top-edge: "cap-height", bottom-edge: "baseline", title)
        ]
        let tab-width = calc.min(size.width,
          calc.max(24mm, measure(title-content).width + 10mm))
        let tab-height = calc.max(9mm,
          measure(title-content, width: tab-width - 8mm).height + 4mm)
        let tab-left = size.width - tab-width + 2mm
        block(width: 100%, height: tab-height + 2mm, breakable: false, spacing: 0pt)[
          #rorn(is-rtl, size.width, tab-left, 0.8mm, polygon(
            (0mm, 0mm), (tab-width, 0mm), (tab-width, tab-height),
            (4.5mm, tab-height), (3.3mm, tab-height + 1.8mm),
            (2.1mm, tab-height), (0mm, tab-height),
            fill: shadow-color.darken(25%), stroke: none,
          ))
          #rorn(is-rtl, size.width, size.width, tab-height, polygon(
            (0mm, 0mm), (2mm, 0mm), (0mm, 2mm),
            fill: title-color.darken(35%), stroke: none,
          ))
          #rorn(is-rtl, size.width, tab-left, 0mm, polygon(
            (0mm, 0mm), (tab-width, 0mm), (tab-width, tab-height),
            (4.5mm, tab-height), (3.3mm, tab-height + 1.8mm),
            (2.1mm, tab-height), (0mm, tab-height),
            fill: title-color, stroke: none,
          ))
          #rtxt(is-rtl, size.width, tab-left + 4mm, 0mm, tab-width - 8mm, block(
            width: tab-width - 8mm, height: tab-height, spacing: 0pt,
          )[
            #align(center + horizon, move(dy: -0.8mm, title-content))
          ])
        ]
      })
    ]
    #block(
      width: 100%, breakable: breakable, spacing: 0pt,
      inset: mirror-dict(is-rtl, (left: 5mm, right: 6mm, top: 3mm, bottom: 6mm)),
    )[
      #body
    ]
  ]
]
}

#let folded-corner-frame-raw(
  body,
  title: auto, color: rgb("1600FF"), title-text-color: white, background: auto, breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let title = pick-title(title, [نشاط], [Activity])
  block(
  width: 100%, breakable: breakable, above: 8mm, below: 8mm,
  fill: if background == auto { color.lighten(96%) } else { background },
  stroke: mirror-dict(is-rtl, (right: 0.8pt + color, rest: none)), inset: 0pt,
)[
  #set align(start)
  #block(width: 100%, breakable: false, sticky: true, spacing: 0pt)[
    #layout(size => {
      let title-content = [
        #set par(leading: 0.4em, spacing: 0pt)
        #text(size: 13pt, weight: "bold", fill: title-text-color,
          top-edge: "cap-height", bottom-edge: "baseline", title)
      ]
      let tab-width = calc.min(size.width,
        calc.max(28mm, measure(title-content).width + 17mm))
      let tab-height = calc.max(9mm,
        measure(title-content, width: tab-width - 16mm).height + 4mm)
      let tab-left = size.width - tab-width
      block(width: 100%, height: tab-height + 3mm, breakable: false, spacing: 0pt)[
        #rorn(is-rtl, size.width, tab-left + 0.8mm, 1mm, block(
          width: tab-width - 0.8mm, height: tab-height,
          fill: rgb("D1D1D8"), radius: 1mm, spacing: 0pt,
        ))
        #rorn(is-rtl, size.width, tab-left, 0mm, block(
          width: tab-width, height: tab-height,
          fill: color, radius: 1mm, spacing: 0pt,
        ))
        #rtxt(is-rtl, size.width, tab-left + 2mm, 0mm, tab-width - 16mm, block(
          width: tab-width - 16mm, height: tab-height, spacing: 0pt,
        )[
          #align(center + horizon, move(dy: -0.8mm, title-content))
        ])
        #rorn(is-rtl, size.width, size.width - tab-height - 2mm, -2mm, polygon(
          (0mm, 2mm), (2mm, 0mm), (4mm, 2mm),
          fill: rgb("73737D"), stroke: none,
        ))
        #rorn(is-rtl, size.width, size.width, tab-height, polygon(
          (0mm, 0mm), (2mm, 2mm), (0mm, 4mm),
          fill: rgb("73737D"), stroke: none,
        ))
        #rorn(is-rtl, size.width, size.width - tab-height - 2mm, 0mm, polygon(
          (0mm, 0mm), (2mm, 0mm),
          (tab-height + 2mm, tab-height), (tab-height, tab-height),
          fill: color.lighten(22%), stroke: none,
        ))
        #rorn(is-rtl, size.width, size.width - tab-height, -2mm, curve(
          fill: color, stroke: none,
          curve.move((0mm, 0mm)), curve.line((tab-height + 1mm, 0mm)),
          curve.cubic((tab-height + 1.6mm, 0mm),
            (tab-height + 2mm, 0.4mm), (tab-height + 2mm, 1mm)),
          curve.line((tab-height + 2mm, tab-height + 4mm)),
          curve.close(mode: "straight"),
        ))
      ]
    })
  ]
  #block(
    width: 100%, breakable: breakable, spacing: 0pt,
    inset: (left: 5mm, right: 5mm, top: 2mm, bottom: 1mm),
  )[
    #body
  ]
  #block(width: 100%, height: 7mm, breakable: false, spacing: 0pt)[
  #layout(size => {
    rorn(is-rtl, size.width, -2mm, -5mm, polygon(
      (0mm, 2mm), (2mm, 0mm), (2mm, 4mm),
      fill: rgb("73737D"), stroke: none,
    ))
    rorn(is-rtl, size.width, 8mm, 7mm, polygon(
      (0mm, 0mm), (4mm, 0mm), (2mm, 2mm),
      fill: rgb("73737D"), stroke: none,
    ))
    rorn(is-rtl, size.width, -2mm, -3mm, polygon(
      (0mm, 0mm), (2mm, 0mm), (12mm, 10mm), (12mm, 12mm),
      fill: rgb("D1D1D8"), stroke: none,
    ))
    rorn(is-rtl, size.width, -2mm, -3mm, curve(
      fill: color, stroke: none,
      curve.move((0mm, 0mm)), curve.line((12mm, 12mm)),
      curve.line((1mm, 12mm)),
      curve.cubic((0.4mm, 12mm), (0mm, 11.6mm), (0mm, 11mm)),
      curve.close(mode: "straight"),
    ))
  })
  ]
]
}

#let subtitle-frame-raw(
  body,
  title: auto, subtitle: [], color: rgb("100099"), title-text-color: white, subtitle-color: rgb("151820"), background: auto, breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let title = pick-title(title, [تمرين], [Exercise])
  block(
  width: 100%, breakable: breakable, above: 7mm, below: 7mm,
  fill: if background == auto { color.lighten(98%) } else { background },
  stroke: 0.8pt + color, radius: 0.4mm, inset: 0pt,
)[
  #set align(start)
  #block(width: 100%, breakable: false, sticky: true, spacing: 0pt)[
    #layout(size => {
      let title-content = [
        #set par(leading: 0.4em, spacing: 0pt)
        #text(size: 13pt, weight: "bold", fill: title-text-color,
          top-edge: "cap-height", bottom-edge: "baseline", title)
      ]
      let subtitle-content = [
        #set par(leading: 0.5em, spacing: 0pt)
        #text(size: 10.5pt, fill: subtitle-color)[#underline(subtitle)]
      ]
      let tab-width = calc.min(size.width * 0.45,
        calc.max(35mm, measure(title-content).width + 12mm))
      let tab-left = size.width - tab-width
      let subtitle-width = tab-left - 8mm
      let header-height = calc.max(10mm,
        measure(title-content, width: tab-width - 10mm).height + 4mm,
        measure(subtitle-content, width: subtitle-width).height + 4mm)
      block(width: 100%, height: header-height + 3mm, breakable: false, spacing: 0pt)[
        #rorn(is-rtl, size.width, 0mm, 0mm, rect(
          width: size.width, height: 1.5mm, fill: color, stroke: none,
        ))
        #rorn(is-rtl, size.width, tab-left, 0mm, curve(
          fill: color, stroke: none,
          curve.move((0mm, 0mm)), curve.line((tab-width, 0mm)),
          curve.line((tab-width, header-height + 3mm)),
          curve.cubic((tab-width, header-height + 1.3mm),
            (tab-width - 1.3mm, header-height), (tab-width - 3mm, header-height)),
          curve.line((6mm, header-height)),
          curve.cubic((2mm, header-height), (4mm, 1.5mm), (0mm, 1.5mm)),
          curve.close(mode: "straight"),
        ))
        #rtxt(is-rtl, size.width, tab-left + 7mm, 0mm, tab-width - 10mm, block(
          width: tab-width - 10mm, height: header-height, spacing: 0pt,
        )[
          #align(center + horizon, move(dy: -0.6mm, title-content))
        ])
        #rtxt(is-rtl, size.width, 4mm, 1.5mm, subtitle-width, block(
          width: subtitle-width, height: header-height - 1.5mm, spacing: 0pt,
        )[
          #align(start + horizon, subtitle-content)
        ])
      ]
    })
  ]
  #block(
    width: 100%, breakable: breakable, spacing: 0pt,
    inset: (left: 5mm, right: 5mm, top: 1mm, bottom: 6mm),
  )[
    #body
  ]
]
}

#let outlined-tab-frame-raw(
  body,
  title: auto, color: black, title-color: black, title-text-color: white, title-border-color: black, background: rgb("FAFAFA"), shadow-color: rgb("858585"), breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let title = pick-title(title, [تعريف], [Definition])
  block(
  width: 100%, breakable: breakable, above: 7mm, below: 7mm,
  fill: shadow-color, radius: 3mm,
  inset: (bottom: 1.2mm, rest: 0pt),
)[
  #set align(start)
  #block(
    width: 100%, breakable: breakable, spacing: 0pt,
    fill: background, stroke: 0.6pt + color, radius: 3mm, inset: 0pt,
  )[
    #block(width: 100%, breakable: false, sticky: true, spacing: 0pt)[
      #layout(size => {
        let title-content = [
          #set par(leading: 0.4em, spacing: 0pt)
          #text(size: 13pt, weight: "bold", fill: title-text-color,
            top-edge: "cap-height", bottom-edge: "baseline", title)
        ]
        let tab-width = calc.min(size.width - 6mm,
          calc.max(24mm, measure(title-content).width + 11mm))
        let title-width = tab-width - 10mm
        let tab-height = calc.max(8mm,
          measure(title-content, width: title-width).height + 4mm)
        let tab-left = size.width - tab-width
        block(width: 100%, height: tab-height + 1mm, spacing: 0pt)[
          #rorn(is-rtl, size.width, tab-left, 0mm, curve(
            fill: title-color, stroke: none,
            curve.move((0mm, 0mm)),
            curve.line((tab-width - 3mm, 0mm)),
            curve.cubic((tab-width - 1.3mm, 0mm),
              (tab-width, 1.3mm), (tab-width, 3mm)),
            curve.line((tab-width, tab-height)),
            curve.line((5mm, tab-height)),
            curve.cubic((1.5mm, tab-height), (3.5mm, 0mm), (0mm, 0mm)),
            curve.close(mode: "straight"),
          ))
          #rorn(is-rtl, size.width, tab-left, 0mm, curve(
            fill: none, stroke: 0.55pt + title-border-color,
            curve.move((-1mm, 0mm)),
            curve.cubic((2.5mm, 0mm), (0.5mm, tab-height + 0.7mm),
              (5mm, tab-height + 0.7mm)),
            curve.line((tab-width, tab-height + 0.7mm)),
          ))
          #rtxt(is-rtl, size.width, tab-left + 7mm, 0mm, title-width, block(
            width: title-width, height: tab-height, spacing: 0pt,
          )[
            #align(center + horizon, move(dy: -0.6mm, title-content))
          ])
        ]
      })
    ]
    #block(
      width: 100%, breakable: breakable, spacing: 0pt,
      inset: (x: 5mm, top: 2mm, bottom: 6mm),
    )[
      #body
    ]
  ]
]
}

#let inset-tab-frame-raw(
  body,
  title: auto, color: black, title-text-color: white, background: rgb("FAFAFA"), breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let title = pick-title(title, [تعريف], [Definition])
  block(
  width: 100%, breakable: breakable, above: 7mm, below: 7mm,
  fill: background, stroke: 0.6pt + color, radius: 2.5mm, inset: 0pt,
)[
  #set align(start)
  #block(width: 100%, breakable: false, sticky: true, spacing: 0pt)[
    #layout(size => {
      let title-content = [
        #set par(leading: 0.4em, spacing: 0pt)
        #text(size: 13pt, weight: "bold", fill: title-text-color,
          top-edge: "cap-height", bottom-edge: "baseline", title)
      ]
      let tab-width = calc.min(size.width - 6mm,
        calc.max(28mm, measure(title-content).width + 12mm))
      let title-width = tab-width - 10mm
      let tab-height = calc.max(8mm,
        measure(title-content, width: title-width).height + 4mm)
      let tab-left = size.width - tab-width - 2.5mm
      block(width: 100%, height: tab-height, spacing: 0pt)[
        #rorn(is-rtl, size.width, tab-left, 0mm, curve(
          fill: color, stroke: none,
          curve.move((0mm, 0mm)),
          curve.line((tab-width, 0mm)),
          curve.cubic((tab-width - 3mm, 0mm),
            (tab-width - 1mm, tab-height), (tab-width - 5mm, tab-height)),
          curve.line((5mm, tab-height)),
          curve.cubic((1mm, tab-height), (3mm, 0mm), (0mm, 0mm)),
          curve.close(mode: "straight"),
        ))
        #rtxt(is-rtl, size.width, tab-left + 5mm, 0mm, title-width, block(
          width: title-width, height: tab-height, spacing: 0pt,
        )[
          #align(center + horizon, move(dy: -0.6mm, title-content))
        ])
      ]
    })
  ]
  #block(
    width: 100%, breakable: breakable, spacing: 0pt,
    inset: (x: 5mm, top: 3mm, bottom: 6mm),
  )[
    #body
  ]
]
}

#let side-notebook-frame-raw(
  body,
  title: auto, color: rgb("100099"), border-color: black, title-background: white, background: white, binding-color: black, binding-background: rgb("BBBBBB"), breakable: true,
) = context {
  let title = pick-title(title, [تمرين], [Exercise])
  block(width: 100%, breakable: breakable, above: 7mm, below: 7mm)[
  #set align(start)
  #layout(size => {
    let title-text = text(size: 13pt, weight: "bold", fill: color,
      top-edge: "cap-height", bottom-edge: "baseline", title)
    let title-content = rotate(-90deg, reflow: true, block(
      width: calc.min(100mm, measure(title-text).width), spacing: 0pt,
    )[
      #set par(leading: 0.4em, spacing: 0pt)
      #align(center, title-text)
    ])
    let title-size = measure(title-content)
    let spine-width = calc.max(10mm, title-size.width + 2mm)
    let title-height = title-size.height + 3mm
    let sheet-height = calc.max(90mm, title-height + 38mm)
    let title-top = (sheet-height - title-height) / 2
    let ring-height = 3mm
    let ring-count = calc.max(1, calc.floor((title-top - 4mm) / 4.8mm))
    let ring-gap = title-top / (ring-count + 1)
    let binding = block(width: spine-width, height: sheet-height,
      breakable: false, spacing: 0pt)[
      #for index in range(ring-count) {
        let ring-top = (index + 1) * ring-gap - ring-height / 2
        for vertical in (ring-top, sheet-height - ring-top - ring-height) {
          for offset in (0.5mm, 1.5mm) {
            ornament-at(spine-width - 3.5mm, vertical + offset, curve(
              fill: none, stroke: 0.65pt + binding-color,
              curve.move((6mm, 0.5mm)),
              curve.cubic((6mm, 1.3mm), (4.7mm, 1.5mm), (2.8mm, 1.5mm)),
            ))
          }
        }
      }
      #block(width: 100%, height: sheet-height, spacing: 0pt,
        fill: background,
        stroke: (right: 0.6pt + border-color, rest: none), inset: 0pt)[
        #ornament-at(0mm, title-top, block(
          width: spine-width, height: title-height, spacing: 0pt,
          fill: title-background,
          stroke: (top: 1.8pt + color, bottom: 1.8pt + color, rest: none),
        )[
          #align(center + horizon, title-content)
        ])
        #for index in range(ring-count) {
          let ring-top = (index + 1) * ring-gap - ring-height / 2
          for vertical in (ring-top, sheet-height - ring-top - ring-height) {
            ornament-at(spine-width - 4.5mm, vertical, rect(
              width: 3mm, height: ring-height, fill: binding-background,
              stroke: 0.35pt + binding-color,
            ))
            for offset in (0.5mm, 1.5mm) {
              ornament-at(spine-width - 3.5mm, vertical + offset + 0.45mm, rect(
                width: 0.8mm, height: 0.7mm,
                fill: binding-color, stroke: none,
              ))
              ornament-at(spine-width - 3.5mm, vertical + offset, curve(
                fill: none, stroke: 0.65pt + binding-color,
                curve.move((0.4mm, 0.8mm)),
                curve.cubic((-0.6mm, -0.2mm), (6mm, -0.4mm), (6mm, 0.5mm)),
              ))
            }
          }
        }
      ]
    ]
    block(width: 100%, breakable: breakable, spacing: 0pt,
      fill: background, stroke: 0.6pt + border-color, inset: 0pt)[
      #ornament-at(0mm, 0mm, polygon(
        (0mm, 1.5mm), (1.5mm, 0mm), (2.2mm, 1.3mm),
        fill: border-color.lighten(85%), stroke: 0.3pt + border-color,
      ))
      #grid(
        columns: (spine-width, 1fr), inset: 0pt,
        align: right + top, stroke: none,
        grid.vline(x: 1, stroke: 0.5pt + border-color),
        grid.cell(breakable: breakable, binding),
        grid.cell(breakable: breakable,
          inset: (x: 6mm, y: 5mm))[
          #set align(start)
          #body
        ],
      )
    ]
  })
]
}

#let binder-notebook-frame-raw(
  body,
  title: auto, color: black, title-background: rgb("FFF8A6"), title-text-color: rgb("1539C8"), background: white, binding-color: rgb("#9a9797"), breakable: true,
) = context {
  let title = pick-title(title, [ملاحظة], [Note])
  let sheet = block(
    width: 100%, breakable: breakable, spacing: 0pt,
    fill: background, stroke: 0.55pt + color, inset: 0pt,
  )[
    #set align(start)
    #block(
      width: 100%, breakable: false, sticky: true, spacing: 0pt,
      inset: 0pt,
    )[
      #layout(size => {
        let title-content = [
          #set par(leading: 0.4em, spacing: 0pt)
          #text(size: 12pt, weight: "bold", fill: title-text-color,
            top-edge: "cap-height", bottom-edge: "baseline", title)
        ]
        let tab-width = calc.min(size.width * 0.65,
          calc.max(size.width * 0.234, measure(title-content).width + 8mm))
        let tab-left = (size.width - tab-width) / 2
        let tab-height = calc.max(7.8mm,
          measure(title-content, width: tab-width - 6mm).height + 3mm)
        let ring-count = calc.max(0, calc.floor((tab-left - 3mm) / 7mm))
        let ring-gap = tab-left / (ring-count + 1)
        block(width: 100%, height: tab-height + 1.3mm, breakable: false, spacing: 0pt)[
          #ornament-at(0mm, tab-height, rect(
            width: size.width, height: 1.3mm, fill: color, stroke: none,
          ))
          #ornament-at(tab-left, 0mm, block(
            width: tab-width, height: tab-height, spacing: 0pt,
            fill: title-background,
            stroke: (left: 0.5pt + color, right: 0.5pt + color, rest: none),
            inset: (x: 3mm, y: 0pt),
          )[
            #align(center + horizon, move(dy: -1.1mm, title-content))
          ])
          #for index in range(ring-count) {
            let ring-left = (index + 1) * ring-gap - 1.1mm
            for horizontal in (ring-left, size.width - ring-left - 2.2mm) {
              ornament-at(horizontal - 0.25mm, 1.8mm, rect(
                width: 2.6mm, height: 2.6mm,
                fill: binding-color, stroke: 0.25pt + binding-color.darken(10%),
              ))
              for offset in (0mm, 0.9mm) {
                ornament-at(horizontal + offset + 0.35mm, 2.25mm, rect(
                  width: 0.7mm, height: 0.9mm,
                  fill: binding-color.darken(20%), stroke: none,
                ))
                ornament-at(horizontal + offset, -1.6mm, curve(
                  fill: none, stroke: 0.65pt + color,
                  curve.move((1.2mm, 1.6mm)),
                  curve.cubic((1.2mm, 0.4mm), (0.9mm, 0mm), (0.6mm, 0mm)),
                  curve.cubic((0.1mm, 0mm), (0mm, 1.2mm), (0mm, 2.5mm)),
                  curve.cubic((0mm, 4mm), (0.2mm, 4.8mm), (0.7mm, 4.8mm)),
                  curve.cubic((1.1mm, 4.8mm), (1.2mm, 4.55mm), (1.2mm, 4.2mm)),
                ))
              }
            }
          }
          #ornament-at(0mm, 0mm, line(
            length: size.width, stroke: 0.55pt + color,
          ))
        ]
      })
    ]
    #block(
      width: 100%, breakable: breakable, spacing: 0pt,
      inset: (x: 6mm, top: 3.5mm, bottom: 5.5mm),
    )[
      #body
    ]
  ]
  for layer in range(4) {
    let layer-offset = (layer + 1) * 0.45mm
    sheet = block(
      width: 100%, breakable: breakable, spacing: 0pt,
      stroke: 0.35pt + color, fill: background,
      inset: (left: 0.45mm, bottom: 0.45mm, rest: 0pt),
      outset: (top: -layer-offset, right: -layer-offset, rest: 0pt),
      sheet,
    )
  }
  block(width: 100%, breakable: breakable, above: 8mm, below: 7mm, sheet)
}

#let framed-exercise-raw(
  body,
  title: auto, title-color: framed-gold, title-size: 12pt, breakable: true,
  ..ignored,
) = context {
  let title = pick-title(title, [تمرين], [Exercise])
  block(
  width: 100%, breakable: breakable, above: 6mm, below: 6mm,
  fill: framed-paper, stroke: 0.65pt + framed-green, inset: 1.2mm,
)[
  #set par(leading: 0.65em, spacing: 2.5mm)
  #show math.equation: set text(font: "New Computer Modern Math", size: 12pt)
  #block(width: 100%, breakable: breakable, stroke: 0.3pt + framed-gold, inset: 0.9mm)[
    #block(width: 100%, height: 14mm, breakable: false, sticky: true, below: 2mm)[
      #layout(size => {
        let banner-width = size.width - 16mm
        ornament-at(8mm, 0mm, polygon(
          (0mm, 6mm), (2.5mm, 2mm), (7mm, 2mm), (7mm, 0mm),
          (banner-width - 7mm, 0mm), (banner-width - 7mm, 2mm),
          (banner-width - 2.5mm, 2mm), (banner-width, 6mm),
          (banner-width - 2.5mm, 10mm), (banner-width - 7mm, 10mm),
          (banner-width - 7mm, 12mm), (7mm, 12mm), (7mm, 10mm), (2.5mm, 10mm),
          fill: framed-green, stroke: 0.55pt + framed-gold,
        ))
        ornament-at(16mm, 0.8mm, line(
          length: banner-width - 16mm, stroke: 0.25pt + framed-paper,
        ))
        ornament-at(16mm, 11.2mm, line(
          length: banner-width - 16mm, stroke: 0.25pt + framed-paper,
        ))
        ornament-at(0.8mm, 2.8mm, framed-star(3.2mm))
        ornament-at(size.width - 7.2mm, 2.8mm, framed-star(3.2mm))
        ornament-at(16mm, 0mm, block(width: size.width - 32mm, height: 12mm, spacing: 0pt)[
          #align(center + horizon)[
            #text(size: title-size, weight: "bold", top-edge: "bounds", bottom-edge: "bounds",
              fill: title-color, title)
          ]
        ])
      })
    ]
    #block(width: 100%, breakable: breakable, inset: (x: 7mm, y: 1mm))[
      #body
    ]
    #block(width: 100%, height: 6mm, breakable: false, above: 1mm, below: 0pt)[
      #layout(size => {
        for horizontal in (0mm, size.width - 6mm) {
          ornament-at(horizontal, 0mm, framed-star(3mm))
        }
        ornament-at(7mm, 3mm, line(
          length: size.width / 2 - 12mm, stroke: 0.45pt + framed-green,
        ))
        ornament-at(size.width / 2 + 5mm, 3mm, line(
          length: size.width / 2 - 12mm, stroke: 0.45pt + framed-green,
        ))
        ornament-at(size.width / 2 - 2.5mm, 0.5mm, framed-star(2.5mm))
      })
    ]
  ]
]
}

#let sheet-frame-raw(
  body,
  title: auto, width: 100%, body-height: auto, border-color: rgb("#f15aaa"), title-color: rgb("#e88ab7"), title-border-color: rgb("#f15aaa"), title-text-color: white, shadow-color: rgb("#f8d9e8"), body-color: white, title-size: 24pt, breakable: true,
) = context {
  let title = pick-title(title, [تمرين], [Exercise])
  let is-rtl = text.dir == rtl
  let doc-dir = text.dir
  let title-height = 15mm
  let shadow-offset = 2.5mm
  let rendered-title = text(
    size: title-size,
    weight: "bold",
    top-edge: "bounds",
    bottom-edge: "bounds",
    fill: title-text-color,
    stroke: 0.4pt + rgb("#555555"),
  )[#title]
  let measured-title = measure(rendered-title)
  let wanted-title-width = measured-title.width + 20mm

  // The frame breaks across pages: the title tab stays with the first
  // lines, the body block (and its bottom shadow) may continue.
  block(width: width, above: 6mm, below: 6mm, breakable: breakable, spacing: 0pt)[
    #block(width: 100%, height: title-height, breakable: false, sticky: true,
      above: 0pt, below: 0pt)[
      #layout(size => {
        let title-width = calc.min(size.width, calc.max(55mm, wanted-title-width))
        let title-start = if is-rtl { size.width - title-width } else { 0mm }
        place(top + left, dx: title-start, mirror-gfx(is-rtl, curve(
          fill: title-color,
          stroke: 0.75pt + title-border-color,
          curve.move((0mm, title-height)),
          curve.line((0mm, 0mm)),
          curve.line((title-width - 15mm, 0mm)),
          curve.cubic(
            (title-width - 5mm, 0mm),
            (title-width - 12mm, title-height - 4mm),
            (title-width - 7mm, title-height - 2mm),
          ),
          curve.cubic(
            (title-width - 5mm, title-height - 0.5mm),
            (title-width - 2mm, title-height),
            (title-width, title-height),
          ),
          curve.close(mode: "straight"),
        )))
        place(top + left, dx: title-start + (if is-rtl { 0mm } else { 12mm }),
          block(
            width: title-width - 12mm,
            height: title-height,
            inset: mirror-dict(is-rtl, (left: 4mm, right: 2mm, top: 1mm, bottom: 1mm)),
          )[
            #align(center + horizon)[#rendered-title]
          ])
      })
    ]
    // Shadow strip under the body (the shadow side follows the direction).
    #block(
      width: 100%, above: 0pt, below: 0pt, breakable: breakable,
      fill: shadow-color,
      inset: mirror-dict(is-rtl, (right: 0pt, bottom: shadow-offset)),
    )[
      #block(
        width: 100%, above: 0pt, below: 0pt, breakable: breakable,
        height: body-height,
        fill: body-color,
        stroke: 0.75pt + border-color,
        inset: (x: 7mm, top: 8mm, bottom: 6mm),
      )[
        #set text(dir: doc-dir)
        #set par(justify: true, leading: 0.65em)
        #align(start)[#body]
      ]
    ]
  ]
}

#let warning-note-raw(
  body,
  title: auto, width: 170mm, body-color: rgb("#fff0b3"),
  title-color: white, title-size: 10pt, title-font: "Noto Kufi Arabic",
) = context {
  let title = pick-title(title, [ملاحظة], [Note])
  let is-rtl = text.dir == rtl
  let heading = text(font: title-font, size: title-size, weight: "bold", fill: title-color)[#title]
  // طول الشريط العمودي يتبع طول العنوان.
  let title-length = calc.max(16mm, measure(heading).width + 2mm)
  let olive = rgb("#bd984b")
  let dark-olive = rgb("#755729")
  let yellow = body-color
  let pale-yellow = rgb("#fffdf3")
  let fold = rgb("#e6c66f")
  let side-width = 8mm

  let body-content = block(
    width: width - side-width - 12mm,
    inset: 0pt,
    above: 0pt,
    below: 0pt,
  )[
    #align(start)[#body]
  ]

  let body-height = measure(body-content).height
  let note-height = calc.max(25mm, body-height + 12mm, title-length + 10mm)
  let fold-width = 8mm
  let fold-height = 6mm

  block(
    width: width + 1.4mm,
    height: note-height + 1.7mm,
    inset: 0pt,
    above: 0pt,
    below: 0pt,
  )[
    #mirror-gfx(is-rtl, block(width: width + 1.4mm, height: note-height + 1.7mm, inset: 0pt, above: 0pt, below: 0pt, breakable: false)[
    // ظل خفيف أسفل الملاحظة.
    #place(
      top + left,
      dx: -.7mm,
      dy: 1.7mm,
      curve(
        fill: rgb("#ece5d2"),
        stroke: none,
        curve.move((0mm, 2mm)),
        curve.cubic((0mm, .9mm), (.9mm, 0mm), (2mm, 0mm)),
        curve.line((width - 2mm, 0mm)),
        curve.cubic((width - .9mm, 0mm), (width, .9mm), (width, 2mm)),
        curve.line((width, note-height)),
        curve.line((fold-width, note-height)),
        curve.line((0mm, note-height - fold-height)),
        curve.close(),
      ),
    )

    // جسم الورقة الصفراء.
    #place(
      top + left,
      curve(
        fill: gradient.linear(
          pale-yellow,
          yellow,
          yellow,
          angle: 90deg,
        ),
        stroke: .4pt + rgb("#d5bd80"),
        curve.move((0mm, 2mm)),
        curve.cubic((0mm, .9mm), (.9mm, 0mm), (2mm, 0mm)),
        curve.line((width - 2mm, 0mm)),
        curve.cubic((width - .9mm, 0mm), (width, .9mm), (width, 2mm)),
        curve.line((width, note-height)),
        curve.line((fold-width, note-height)),
        curve.line((0mm, note-height - fold-height)),
        curve.close(),
      ),
    )

    // الشريط الجانبي في اليمين لاتجاه العربية.
    #place(
      top + right,
      dx: -1.4mm,
      rect(
        width: side-width,
        height: note-height,
        fill: gradient.linear(
          rgb("#caa451"),
          olive,
          dark-olive,
          angle: 0deg,
        ),
        stroke: none,
        radius: (top-right: 2mm),
      ),
    )

    #place(
      top + left,
      dx: 3mm,
      dy: 1.1mm,
      line(length: width - side-width - 5mm, stroke: .6pt + white),
    )
    #place(
      top + left,
      dx: width - side-width + .6mm,
      dy: 2mm,
      line(
        start: (0mm, 0mm),
        end: (0mm, note-height - 4mm),
        stroke: .4pt + rgb("#e5cd95"),
      ),
    )

    #for position in (
      (note-height - title-length) / 2 - 2mm,
      (note-height + title-length) / 2 + 1.1mm,
    ) {
      place(
        top + right,
        dx: -4.95mm,
        dy: position,
        circle(radius: .45mm, fill: rgb("#f6e4b8"), stroke: none),
      )
    }

    #place(
      top + left,
      dy: note-height - fold-height,
      curve(
        fill: rgb("#b39851"),
        stroke: none,
        curve.move((0mm, 0mm)),
        curve.line((fold-width, fold-height)),
        curve.cubic(
          (fold-width * .9, fold-height * .65),
          (fold-width * .9, fold-height * .3),
          (fold-width * .94, -.5mm),
        ),
        curve.cubic(
          (fold-width * .5, .7mm),
          (fold-width * .25, .5mm),
          (0mm, 0mm),
        ),
        curve.close(),
      ),
    )

    #place(
      top + left,
      dy: note-height - fold-height,
      curve(
        fill: gradient.linear(
          rgb("#fff7d8"),
          fold,
          rgb("#bc994e"),
          angle: 45deg,
        ),
        stroke: none,
        curve.move((0mm, 0mm)),
        curve.line((fold-width, fold-height)),
        curve.cubic(
          (fold-width * .72, fold-height * .72),
          (fold-width * .76, fold-height * .22),
          (fold-width * .82, -1mm),
        ),
        curve.cubic(
          (fold-width * .5, -.3mm),
          (fold-width * .22, .3mm),
          (0mm, 0mm),
        ),
        curve.close(),
      ),
    )

    ])

    #place(
      if is-rtl { top + right } else { top + left },
      dx: if is-rtl { -2.9mm } else { 2.9mm },
      dy: (note-height - title-length) / 2,
      block(width: 5mm, height: title-length, inset: 0pt)[
        #align(center + horizon)[
          #rotate(90deg, reflow: true)[
            #box[#heading]
          ]
        ]
      ],
    )

    // النص داخل الملاحظة.
    #place(
      top + left,
      dx: if is-rtl { 6mm } else { side-width + 7.4mm },
      dy: 6mm,
      body-content,
    )
  ]
}

#let homework-sheet-raw(
  body,
  title: [], title-color: rgb("#303942"),
  breakable: true,
) = context {
  block(
  width: 100%,
  height: auto,
  fill: rgb("#bfbfbf"),
  radius: 4mm,
  inset: (right: 1mm, bottom: 1mm),
  above: 3mm,
  breakable: breakable,
)[
  #for ring-index in range(14) {
    place(
      top + left,
      dx: 8mm + ring-index * ((100% - 17mm) / 13) - 3.2485mm,
      dy: -3mm,
      notebook-ring-back(),
    )
  }
  #block(
    width: 100%,
    height: auto,
    fill: white,
    stroke: .5pt + black,
    radius: 4mm,
    inset: 0pt,
    breakable: breakable,
  )[
    #for ring-index in range(14) {
      place(
        top + left,
        dx: 8mm + ring-index * ((100% - 17mm) / 13) - 3.2485mm,
        dy: -3mm,
        notebook-ring(),
      )
    }
    #pad(top: 15mm, bottom: 10mm, left: 9mm, right: 9mm)[
      #if title != [] {
        block(width: 100%, above: 0pt, below: 3mm, breakable: false)[
          #text(size: 14pt, weight: "bold", fill: title-color)[#title]
        ]
      }
      #align(start)[#body]
    ]
  ]
]
}

#let homework-sheet-modern-raw(
  body,
  title: auto,
  header: [],
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let title = pick-title(title, [تطبيق], [Application])
  block(
    width: 100%,
    height: auto,
    fill: rgb("#cccccc"),
    radius: 0pt,
    inset: (bottom: 1.5mm),
    above: 6mm,
    breakable: breakable,
  )[
    #block(
      width: 100%,
      height: auto,
      fill: rgb("#fffef8"),
      stroke: mirror-dict(is-rtl, (top: .8pt + rgb("#ff713e"), right: 2.5pt + rgb("#ff713e"), left: none, bottom: none)),
      radius: 0pt,
      inset: 0pt,
      breakable: breakable,
    )[
      #place(
        if is-rtl { top + right } else { top + left },
        dx: if is-rtl { -7mm } else { 7mm },
        dy: -5mm,
        rect(
          width: 34mm,
          height: 10mm,
          fill: rgb("#08b9eb"),
          stroke: .8pt + rgb("#248bce"),
          radius: 3mm,
          inset: 1mm,
        )[
          #align(center + horizon)[
            #text(size: 14pt, weight: "bold", fill: white)[
              #title
            ]
          ]
        ],
      )
      #place(
        if is-rtl { top + left } else { top + right },
        dx: if is-rtl { 8mm } else { -8mm },
        dy: -7mm,
        text(font: ("Noto Color Emoji", "Twemoji Mozilla", "Arial"), size: 19pt)[
          #emoji.face.think #h(1mm) #emoji.face.think
        ],
      )
      #pad(top: 13mm, bottom: 10mm, left: 9mm, right: 9mm)[
        #if header != [] {
          block(width: 100%, breakable: false, above: 0pt, below: 5mm)[#header]
        }
        #align(start)[#body]
      ]
    ]
  ]
}

#let practical-notebook-draw(
  body,
  title: auto, title-font: ("Noto Kufi Arabic", "Noto Sans Arabic", "Libertinus Serif"), title-size: 12pt, title-color: white, title-box-color: rgb("#303942"), width: 170mm, height: auto, min-height: 60mm, ring-spacing: 12mm, paper-color: white, border-color: rgb("#91b5bb"), wire-color: rgb("#364f55"), hole-color: rgb("#dbe8eb"), rule-color: rgb("#dce9ed"), fine-rule-color: rgb("#f1f6f8"), margin-color: rgb("#e4c8c2"), accent-color: rgb("#b99a60"),
) = context {
  let title = pick-title(title, [أعمال تطبيقية], [Practical work])
  let is-rtl = text.dir == rtl
  let title-label = text(
    font: title-font,
    size: title-size,
    weight: "bold",
    fill: title-color,
  )[#title]
  let title-width = calc.min(measure(title-label).width + 46mm, width - 22mm)

  let content = block(
    width: width - 22mm,
    breakable: true,
    above: 0pt,
    below: 0pt,
  )[
    #set text(fill: rgb("#293e44"))
    // قلم رصاص آلي فحمي، بمقدمة معدنية مخددة وسن رفيع.
    #block(
      width: 100%,
      height: 14mm,
      breakable: false,
      fill: paper-color,
      inset: 0pt,
      above: 0pt,
      below: 0pt,
    )[
      #place(
        if is-rtl { top + right } else { top + left },
        dx: if is-rtl { 10mm } else { -10mm },
        box(width: title-width, height: 14mm)[
          #mirror-gfx(is-rtl, box(width: title-width, height: 14mm)[
          #place(
            top + left,
            curve(
              fill: title-box-color,
              stroke: .7pt + accent-color,
              curve.move((18mm, 0mm)),
              curve.line((title-width - 3.5mm, 0mm)),
              curve.cubic(
                (title-width - 1.57mm, 0mm),
                (title-width, 1.57mm),
                (title-width, 3.5mm),
              ),
              curve.line((title-width, 14mm)),
              curve.line((18mm, 14mm)),
              curve.line((18mm, 0mm)),
              curve.close(),
            ),
          )
          // حافة مضيئة وأخرى داكنة توحيان بأوجه جسم القلم.
          #place(
            top + left,
            dx: 18mm,
            dy: 1mm,
            rect(
              width: title-width - 22mm,
              height: 1.2mm,
              fill: rgb("#89949e"),
              stroke: none,
            ),
          )
          #place(
            top + left,
            dx: 18mm,
            dy: 11.5mm,
            rect(
              width: title-width - 18mm,
              height: 2.2mm,
              fill: rgb("#20272e"),
              stroke: none,
            ),
          )
          #place(
            top + left,
            curve(
              fill: rgb("#aab4bc"),
              stroke: .6pt + rgb("#67747f"),
              curve.move((3mm, 6mm)),
              curve.line((8mm, 3mm)),
              curve.line((12mm, 3mm)),
              curve.line((18mm, 0mm)),
              curve.line((18mm, 14mm)),
              curve.line((12mm, 11mm)),
              curve.line((8mm, 11mm)),
              curve.line((3mm, 8mm)),
              curve.close(),
            ),
          )
          #place(
            top + left,
            curve(
              fill: rgb("#edf2f5"),
              stroke: none,
              curve.move((3mm, 6mm)),
              curve.line((8mm, 3mm)),
              curve.line((12mm, 3mm)),
              curve.line((18mm, 0mm)),
              curve.line((18mm, 7mm)),
              curve.line((3mm, 7mm)),
              curve.close(),
            ),
          )
          // تخديدات المقبض المعدني، مستقلة عن مساحة العنوان.
          #for groove in range(4) {
            place(
              top + left,
              dx: 8.5mm + groove * 1mm,
              dy: 3.4mm,
              line(
                start: (0mm, 0mm),
                end: (0mm, 7.2mm),
                stroke: .45pt + rgb("#73808c"),
              ),
            )
          }
          #place(
            top + left,
            dy: 6.65mm,
            rect(
              width: 3.5mm,
              height: .7mm,
              radius: .2mm,
              fill: rgb("#282d33"),
              stroke: none,
            ),
          )
          // زر خلفي داكن يحافظ على انحناء ركن الإطار.
          #place(
            top + right,
            curve(
              fill: rgb("#535f6b"),
              stroke: .5pt + rgb("#303942"),
              curve.move((0mm, 0mm)),
              curve.line((6.5mm, 0mm)),
              curve.cubic((8.43mm, 0mm), (10mm, 1.57mm), (10mm, 3.5mm)),
              curve.line((10mm, 14mm)),
              curve.line((0mm, 14mm)),
              curve.close(),
            ),
          )
          #place(
            top + right,
            dx: -10mm,
            rect(
              width: 7mm,
              height: 14mm,
              fill: rgb("#c9b079"),
              stroke: .5pt + rgb("#967b48"),
            ),
          )
          #place(
            top + right,
            dx: -10.5mm,
            dy: 1.2mm,
            rect(
              width: 6mm,
              height: 1mm,
              fill: white,
              stroke: none,
            ),
          )
          #place(
            top + right,
            dx: -12mm,
            dy: 2.8mm,
            line(
              start: (0mm, 0mm),
              end: (0mm, 8.4mm),
              stroke: .35pt + rgb("#967b48"),
            ),
          )
          ])
          #place(
            if is-rtl { top + right } else { top + left },
            dx: if is-rtl { -22mm } else { 22mm },
            dy: 3mm,
            block(width: title-width - 46mm)[
              #align(if is-rtl { right } else { left })[#title-label]
            ],
          )
        ],
      )
    ]
    #v(5mm)
    #align(start)[#body]
  ]
  let content-height = measure(content).height + 12mm
  let height = calc.max(
    min-height,
    content-height,
    if height == auto { 0mm } else { height },
  )
  let hole-radius = 2mm
  let hole-center = width - 6mm
  // عدد صحيح من الحلقات: ارتفاع الإطار يساوي عددًا كاملًا من وحدات التكرار.
  // يتغير موضع الثقوب أفقيًا مع width، وعددها رأسيًا مع height.
  let ring-count = calc.max(
    1,
    calc.floor(height / calc.max(ring-spacing, 6mm)),
  )
  let fitted-spacing = height / ring-count

  // رسم التجليد مستقل عن الورقة، حتى يمكن وضعه فوق شارة العنوان.
  let draw-rings(stroke-color: wire-color, limit: height) = {
    for ring-index in range(ring-count) {
      let ring-position = fitted-spacing * (ring-index + .5)
      if ring-position + hole-radius <= limit {
        place(
          top + left,
          dx: hole-center - hole-radius,
          dy: ring-position - hole-radius,
          circle(
            radius: hole-radius,
            fill: hole-color,
            stroke: .9pt + stroke-color,
          ),
        )
        place(
          top + left,
          dx: hole-center,
          dy: ring-position,
          curve(
            fill: none,
            stroke: .85pt + stroke-color,
            curve.move((1.65mm, -.85mm)),
            curve.cubic((.15mm, -.6mm), (.15mm, .4mm), (1.3mm, .9mm)),
            curve.cubic((2.8mm, 1.65mm), (6.3mm, 1.65mm), (7.3mm, .85mm)),
            curve.cubic((8.05mm, .2mm), (7.45mm, -.8mm), (6.25mm, -.85mm)),
          ),
        )
        place(
          top + left,
          dx: hole-center,
          dy: ring-position,
          curve(
            fill: none,
            stroke: .85pt + stroke-color,
            curve.move((1.65mm, -.2mm)),
            curve.cubic((.1mm, .1mm), (.2mm, 1.1mm), (1.4mm, 1.6mm)),
            curve.cubic((3mm, 2.3mm), (6.5mm, 2.3mm), (7.4mm, 1.5mm)),
            curve.cubic((8.1mm, .85mm), (7.6mm, -.15mm), (6.25mm, -.2mm)),
          ),
        )
      }
    }
  }
  let title-binding = tiling(
    size: (width + 4mm, height),
    offset: (0pt, 0pt),
    relative: "self",
    mirror-gfx(is-rtl, block(width: width + 4mm, height: height, inset: 0pt, above: 0pt, below: 0pt, breakable: false)[
      #draw-rings(stroke-color: wire-color, limit: 14mm)
    ]),
  )

  // شبكة ملليمترية ثابتة كل 1 مم، مستقلة عن عدد الحلقات وارتفاع الإطار.
  let binding = tiling(
    size: (width + 4mm, height),
    offset: (0pt, 0pt),
    relative: "self",
    mirror-gfx(is-rtl, block(width: width + 4mm, height: height, inset: 0pt, above: 0pt, below: 0pt, breakable: false)[#{
      place(
        top + left,
        rect(
          width: width + 4mm,
          height: height,
          fill: white,
          stroke: none,
        ),
      )
      place(
        top + left,
        rect(
          width: width,
          height: height,
          fill: paper-color,
          stroke: none,
        ),
      )

      // الخطوط الأفقية: كل 1 مم، وخطوط أوضح كل 2 مم و8 مم.
      for rule-index in range(1, calc.ceil(height / 1mm)) {
        let main-rule = calc.rem(rule-index, 8) == 0
        let intermediate-rule = calc.rem(rule-index, 2) == 0
        place(
          top + left,
          dy: rule-index * 1mm,
          line(
            length: width,
            stroke: if main-rule {
              .45pt + rule-color
            } else if intermediate-rule {
              .3pt + fine-rule-color
            } else {
              .2pt + fine-rule-color
            },
          ),
        )
      }

      // الخطوط العمودية تكمل المربعات الملليمترية على مساحة الورقة.
      for grid-index in range(1, calc.ceil(width / 1mm)) {
        let main-grid = calc.rem(grid-index, 8) == 0
        place(
          top + left,
          dx: grid-index * 1mm,
          line(
            start: (0mm, 0mm),
            end: (0mm, height),
            stroke: if main-grid {
              .4pt + rule-color
            } else {
              .2pt + fine-rule-color
            },
          ),
        )
      }

      // هامش الكراس الأحمر المزدوج، بجوار الثقوب وبعيدًا عن النص.
      place(
        top + left,
        dx: width - 9mm,
        line(
          start: (0mm, 0mm),
          end: (0mm, height),
          stroke: .65pt + margin-color,
        ),
      )

      place(
        top + left,
        dx: width - 8.5mm,
        line(
          start: (0mm, 0mm),
          end: (0mm, height),
          stroke: .3pt + margin-color,
        ),
      )

      draw-rings()
    }]),
  )

  // النص داخل كتلة قابلة للتجزئة، دون ظل وهامش أيمن 1 سم.
  block(
    width: width + 4mm,
    breakable: true,
    inset: 0pt,
    above: 0pt,
    below: 0pt,
  )[
    #block(
      width: width + 4mm,
      breakable: true,
      fill: binding,
      inset: 0pt,
      above: 0pt,
      below: 0pt,
    )[
      #align(if is-rtl { left } else { right })[
        #block(
          width: width,
          height: height,
          breakable: true,
          stroke: .8pt + border-color,
          radius: 3.5mm,
          inset: mirror-dict(is-rtl, (top: 0mm, bottom: 12mm, left: 12mm, right: 10mm)),
          above: 0pt,
          below: 0pt,
        )[
          #content
          // طبقة أمامية شفافة: السلك والثقوب فوق العنوان، لا خلفه.
          #place(
            top + left,
            dx: if is-rtl { -12mm } else { -14mm },
            rect(
              width: width + 4mm,
              height: 14mm,
              fill: title-binding,
              stroke: none,
            ),
          )
        ]
      ]
    ]
  ]
}

// `width: auto` (default) = full available width, paper border aligned with the
// other frames; the rings stick out 4mm into the margin. A length = fixed width.
// العرض الافتراضي `auto` = عرض المساحة المتاحة بمحاذاة بقية الإطارات.
#let practical-notebook-raw(body, width: auto, ..rest) = context {
  let is-rtl = text.dir == rtl
  if width == auto {
    layout(size => pad(
      ..(if is-rtl { (right: -4mm) } else { (left: -4mm) }),
      practical-notebook-draw(body, width: size.width, ..rest),
    ))
  } else {
    practical-notebook-draw(body, width: width, ..rest)
  }
}

#let ribbon-banner-raw(
  title: auto, color: rgb("FFC2C2"), text-color: black, border-color: rgb("777777"), fold-color: rgb("B5B5B5"), title-size: 20pt,
) = context {
  let title = pick-title(title, [بسم الله الرحمن الرحيم], [Title])
  block(width: 100%, breakable: false, above: 7mm, below: 7mm)[
  #set par(leading: 0.5em, spacing: 0pt)
  #layout(size => {
    let wing-width = calc.min(12mm, size.width * 0.12)
    let front-width = size.width - 2 * wing-width
    let title-width = front-width - 8mm
    let title-content = text(size: title-size, weight: "bold",
      fill: text-color, title)
    let front-height = calc.max(24mm,
      measure(title-content, width: title-width).height + 8mm)
    let total-height = front-height + 6mm
    block(width: 100%, height: total-height, breakable: false, spacing: 0pt)[
      #for mirrored in (false, true) {
        let point(horizontal, vertical) = (
          if mirrored { size.width - horizontal } else { horizontal },
          vertical,
        )
        ornament-at(0mm, 0mm, curve(
          fill: color, stroke: 0.55pt + border-color,
          curve.move(point(0mm, 0mm)),
          curve.line(point(wing-width * 2 - 2mm, 0mm)),
          curve.cubic(point(wing-width * 2 + 1mm, 0mm),
            point(wing-width * 2 + 1mm, 3mm), point(wing-width * 2 - 2mm, 3mm)),
          curve.line(point(wing-width * 2, total-height - 4mm)),
          curve.line(point(0mm, total-height - 4mm)),
          curve.line(point(wing-width * 0.8, (total-height - 4mm) / 2)),
          curve.close(mode: "straight"),
        ))
        ornament-at(0mm, 0mm, curve(
          fill: fold-color, stroke: 0.55pt + border-color,
          curve.move(point(wing-width * 2, 1.5mm)),
          curve.cubic(point(wing-width * 2, 3mm),
            point(wing-width * 2 - 1mm, 3mm), point(wing-width * 2 - 2mm, 3mm)),
          curve.line(point(wing-width + 2mm, 3mm)),
          curve.cubic(point(wing-width - 2mm / 3, 3mm),
            point(wing-width - 2mm / 3, 6mm), point(wing-width + 2mm, 6mm)),
          curve.line(point(wing-width * 2, 6mm)),
          curve.close(mode: "straight"),
        ))
      }
      #ornament-at(wing-width, 6mm, curve(
        fill: color, stroke: 0.55pt + border-color,
        curve.move((2mm, 0mm)),
        curve.line((front-width - 2mm, 0mm)),
        curve.cubic((front-width - 2mm / 3, 0mm),
          (front-width, -0.75mm), (front-width, -1.5mm)),
        curve.line((front-width, front-height - 2mm)),
        curve.cubic((front-width, front-height - 0.9mm),
          (front-width - 0.9mm, front-height), (front-width - 2mm, front-height)),
        curve.line((2mm, front-height)),
        curve.cubic((0.9mm, front-height),
          (0mm, front-height - 0.9mm), (0mm, front-height - 2mm)),
        curve.line((0mm, -1.5mm)),
        curve.cubic((0mm, -0.75mm), (2mm / 3, 0mm), (2mm, 0mm)),
        curve.close(mode: "straight"),
      ))
      #ornament-at(wing-width + 4mm, 6mm,
        block(width: title-width, height: front-height, spacing: 0pt)[
          #align(center + horizon, title-content)
        ])
    ]
  })
]
}

#let arched-ribbon-raw(
  title: auto, color: rgb("E5E5E5"), text-color: black, border-color: black, title-size: 20pt,
) = context {
  let title = pick-title(title, [عنوان], [Title])
  block(width: 100%, breakable: false, above: 7mm, below: 7mm)[
  #set par(leading: 0.5em, spacing: 0pt)
  #layout(size => {
    let wing-width = calc.min(16mm, size.width * 0.12)
    let front-width = size.width - 2 * wing-width
    let title-width = front-width - 8mm
    let title-content = text(size: title-size, weight: "bold",
      fill: text-color, title)
    let front-height = calc.max(24mm,
      measure(title-content, width: title-width).height + 8mm)
    let total-height = front-height + 7mm
    block(width: 100%, height: total-height, spacing: 0pt)[
      #for mirrored in (false, true) {
        let point(horizontal, vertical) = (
          if mirrored { size.width - horizontal } else { horizontal },
          vertical,
        )
        ornament-at(0mm, 0mm, curve(
          fill: color, stroke: 0.55pt + border-color,
          curve.move(point(0mm, 5mm)),
          curve.cubic(point(wing-width / 3, 4mm),
            point(wing-width, 4mm), point(wing-width + 4mm, 5mm)),
          curve.line(point(wing-width + 4mm, total-height)),
          curve.cubic(point(wing-width, total-height - 1mm),
            point(wing-width / 3, total-height - 1mm), point(0mm, total-height)),
          curve.line(point(wing-width * 0.45, (total-height + 5mm) / 2)),
          curve.close(mode: "straight"),
        ))
        ornament-at(0mm, 0mm, polygon(
          point(wing-width, front-height + 3mm),
          point(wing-width + 4mm, front-height + 2mm),
          point(wing-width + 4mm, total-height),
          fill: color.darken(45%), stroke: 0.35pt + border-color,
        ))
      }
      #ornament-at(wing-width, 0mm, curve(
        fill: color, stroke: 0.65pt + border-color,
        curve.move((0mm, 3mm)),
        curve.cubic((front-width / 3, -1mm),
          (front-width * 2 / 3, -1mm), (front-width, 3mm)),
        curve.line((front-width, front-height + 3mm)),
        curve.cubic((front-width * 2 / 3, front-height - 1mm),
          (front-width / 3, front-height - 1mm), (0mm, front-height + 3mm)),
        curve.close(mode: "straight"),
      ))
      #ornament-at(wing-width + 4mm, 2mm, block(
        width: title-width, height: front-height - 1mm, spacing: 0pt,
      )[
        #align(center + horizon, title-content)
      ])
    ]
  })
]
}





// 58. Ribbon notes: one-piece gradient header ribbon with a main title on the
// RTL-right side, a small "add to" caption and a gradient tag hanging under it
// on the opposite side. In LTR the whole header is mirrored (text is not).
// إطار ملاحظات هامة: شريط علوي متدرج، عنوان رئيسي، عنوان فرعي صغير وشارة ملوّنة.
#let ribbon-notes-frame-raw(
  body,
  title: auto,
  subtitle: auto,
  tag-title: auto,
  color: rgb("4B0082"),
  title-color: auto,
  title-text-color: white,
  background: rgb("E4DAEC"),
  subtitle-color: black,
  tag-color: rgb("FFFF00"),
  tag-end-color: rgb("FF9900"),
  tag-text-color: black,
  title-size: 14pt,
  title-raise: 0mm,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let heading = pick-title(title, [ملاحظات هامة], [Important notes])
  let sub = pick-title(subtitle, [أضف إلى], [Add to])
  let tag = pick-title(tag-title, [معلوماتك], [your notes])
  let ribbon-color = label-color(color, title-color)
  // Offset along the design direction (RTL design; mirrored in LTR).
  let sx(v) = if is-rtl { v } else { -v }
  block(width: 100%, breakable: breakable, above: 7mm, below: 7mm,
    fill: gradient.linear(background.lighten(85%), background, angle: 90deg),
    stroke: 0.6pt + color, radius: 1mm, inset: 0pt,
  )[
    #block(width: 100%, breakable: false, sticky: true, spacing: 0pt)[
      #layout(size => {
        let label = [
          #set par(leading: 2pt, spacing: 0pt)
          #text(size: title-size, weight: "bold", fill: title-text-color, heading)
        ]
        let secondary = [
          #set par(leading: 2pt, spacing: 0pt)
          #text(size: 10pt, weight: "bold", fill: subtitle-color, sub)
        ]
        let tag-label = [
          #set par(leading: 2pt, spacing: 0pt)
          #text(size: 10pt, weight: "bold", fill: tag-text-color,
            top-edge: "ascender", bottom-edge: "descender", tag)
        ]
        assert(size.width >= 70mm,
          message: "ribbon-notes-frame needs at least 70mm of width")
        // Drawn for RTL (main title on the right); x is mirrored in LTR.
        let X(x) = if is-rtl { x } else { size.width - x }
        let main-width = calc.min(size.width * 0.45,
          calc.max(32mm, measure(label).width + 8mm))
        let side-width = calc.min(size.width * 0.25,
          calc.max(20mm, measure(secondary).width + 6mm, measure(tag-label).width + 6mm))
        // 3mm above and 3mm below the title, which is centered in the frame.
        // مسافة 3 مم فوق العنوان و3 مم تحته والعنوان في وسط الإطار.
        let main-height = measure(label, width: main-width - 6mm).height + 6mm
        let side-height = calc.max(9mm, measure(secondary, width: side-width - 6mm).height + 3mm)
        let tag-height = if tag == [] { 0mm } else {
          calc.max(8mm, measure(tag-label, width: side-width - 6mm).height + 4mm)
        }
        block(width: 100%, height: calc.max(main-height, side-height + tag-height + 2mm),
          spacing: 0pt)[
          #place(top + left, curve(
            fill: gradient.linear(ribbon-color, ribbon-color.lighten(75%), angle: 90deg),
            stroke: 0.45pt + color,
            curve.move((X(0mm), 0mm)), curve.line((X(size.width), 0mm)),
            curve.line((X(size.width), main-height)),
            curve.line((X(size.width - main-width), main-height)),
            curve.cubic((X(size.width - main-width - 3mm), main-height),
              (X(size.width - main-width - 4mm), 4mm),
              (X(size.width - main-width - 8mm), 4mm)),
            curve.line((X(side-width + 5mm), 4mm)),
            curve.cubic((X(side-width + 1mm), 4mm), (X(side-width + 2mm), side-height),
              (X(side-width - 2mm), side-height)),
            curve.line((X(0mm), side-height)), curve.close(),
          ))
          #place(if is-rtl { top + right } else { top + left },
            block(width: main-width, height: main-height, inset: (x: 3mm), spacing: 0pt)[
              #align(center + horizon, move(dy: -title-raise, label))
            ])
          #if sub != [] {
            place(if is-rtl { top + left } else { top + right },
              block(width: side-width, height: side-height, inset: (x: 3mm), spacing: 0pt)[
                #align(center + horizon, move(dy: -1mm, secondary))
              ])
          }
          #if tag != [] {
            let tag-width = side-width - 2mm
            let tag-shape(paint, edge: none) = curve(
              fill: paint, stroke: edge,
              curve.move((0mm, 1mm)),
              curve.cubic((tag-width * 0.35, 2.8mm),
                (tag-width * 0.65, 2.8mm), (tag-width, 1mm)),
              curve.line((tag-width, tag-height - 1mm)),
              curve.cubic((tag-width * 0.65, tag-height + 0.8mm),
                (tag-width * 0.35, tag-height + 0.8mm), (0mm, tag-height - 1mm)),
              curve.close(mode: "straight"),
            )
            let tag-x = if is-rtl { 0mm } else { side-width - tag-width }
            place(top + left,
              dx: if is-rtl { 1mm } else { size.width - side-width - 1mm },
              dy: side-height + 1mm,
              block(width: side-width, height: tag-height, spacing: 0pt)[
                #place(top + left, dx: tag-x + sx(0.7mm), dy: 0.7mm,
                  tag-shape(rgb("BFBFBF")))
                #place(top + left, dx: tag-x, tag-shape(
                  gradient.linear(tag-color, tag-end-color,
                    angle: if is-rtl { 0deg } else { 180deg }),
                ))
                #place(top + left, dx: tag-x,
                  block(width: tag-width, height: tag-height, inset: (x: 2mm), spacing: 0pt)[
                    #align(center + horizon, move(dy: 1.3mm, tag-label))
                  ])
              ])
          }
        ]
      })
    ]
    #block(width: 100%, breakable: breakable, spacing: 0pt,
      inset: (x: 4mm, top: 2mm, bottom: 5mm))[
      #align(start)[#body]
    ]
  ]
}


// 59. Blue millimetre-grid notebook with metal rings and a curved title badge.
// دفتر أزرق بشبكة ملليمترية وحلقات معدنية وشارة عنوان منحنية (النسخة اللاتينية: ينعكس التجليد).
#let grid-notebook-draw(
  body,
  title: auto, title-font: ("Noto Kufi Arabic", "Noto Sans Arabic", "Libertinus Serif"), title-size: 12pt, title-color: white, width: 195mm, height: auto, min-height: 60mm, ring-spacing: 12mm, paper-color: white, border-color: rgb("#76899e"), wire-color: rgb("#354454"), hole-color: rgb("#d9dfe5"), rule-color: rgb("#d0dfed"), fine-rule-color: rgb("#edf3f9"), margin-color: rgb("#e6c4c4"), accent-color: rgb("#243e5b"),
) = context {
  let title = pick-title(title, [تمرين تطبيقي], [Applied exercise])
  let is-rtl = text.dir == rtl
  let title-label = text(
    font: title-font,
    size: title-size,
    weight: "bold",
    fill: title-color,
  )[#title]
  let title-width = calc.min(measure(title-label).width + 25mm, width - 46mm)

  let content = block(
    width: width - 22mm,
    breakable: true,
    above: 0pt,
    below: 0pt,
  )[
    #set text(fill: rgb("#263440"))
    // Title badge flush with the top of the frame (blue curved tab).
    #block(
      width: 100%,
      height: 16mm,
      breakable: false,
      fill: paper-color,
      inset: 0pt,
      above: 0pt,
      below: 0pt,
    )[
      #place(
        if is-rtl { top + right } else { top + left },
        dx: if is-rtl { 10mm } else { -10mm },
        box(width: title-width, height: 16mm)[
          #mirror-gfx(is-rtl, box(width: title-width, height: 16mm)[
            #place(
              top + left,
              curve(
                fill: accent-color,
                stroke: none,
                curve.move((0mm, 0mm)),
                curve.line((title-width - 3.5mm, 0mm)),
                curve.cubic(
                  (title-width - 1.57mm, 0mm),
                  (title-width, 1.57mm),
                  (title-width, 3.5mm),
                ),
                curve.line((title-width, 16mm)),
                curve.line((21mm, 16mm)),
                curve.cubic((9mm, 16mm), (13mm, 4mm), (0mm, 0mm)),
                curve.close(),
              ),
            )
          ])
          #place(
            if is-rtl { top + right } else { top + left },
            dx: if is-rtl { -12mm } else { 12mm },
            dy: 4mm,
            block(width: title-width - 25mm)[
              #align(if is-rtl { right } else { left })[#title-label]
            ],
          )
        ],
      )
    ]
    #v(5mm)
    #align(start)[#body]
  ]
  let content-height = measure(content).height + 12mm
  let height = calc.max(
    min-height,
    content-height,
    if height == auto { 0mm } else { height },
  )
  let hole-radius = 2mm
  let hole-center = width - 6mm
  // عدد صحيح من الحلقات: ارتفاع الإطار يساوي عددًا كاملًا من وحدات التكرار.
  // يتغير موضع الثقوب أفقيًا مع width، وعددها رأسيًا مع height.
  let ring-count = calc.max(
    1,
    calc.floor(height / calc.max(ring-spacing, 6mm)),
  )
  let fitted-spacing = height / ring-count

  // رسم التجليد مستقل عن الورقة، حتى يمكن وضعه فوق شارة العنوان.
  let draw-rings(stroke-color: wire-color, limit: height) = {
    for ring-index in range(ring-count) {
      let ring-position = fitted-spacing * (ring-index + .5)
      if ring-position + hole-radius <= limit {
        place(
          top + left,
          dx: hole-center - hole-radius,
          dy: ring-position - hole-radius,
          circle(
            radius: hole-radius,
            fill: hole-color,
            stroke: .9pt + stroke-color,
          ),
        )
        place(
          top + left,
          dx: hole-center,
          dy: ring-position,
          curve(
            fill: none,
            stroke: .85pt + stroke-color,
            curve.move((1.65mm, -.85mm)),
            curve.cubic((.15mm, -.6mm), (.15mm, .4mm), (1.3mm, .9mm)),
            curve.cubic((2.8mm, 1.65mm), (6.3mm, 1.65mm), (7.3mm, .85mm)),
            curve.cubic((8.05mm, .2mm), (7.45mm, -.8mm), (6.25mm, -.85mm)),
          ),
        )
        place(
          top + left,
          dx: hole-center,
          dy: ring-position,
          curve(
            fill: none,
            stroke: .85pt + stroke-color,
            curve.move((1.65mm, -.2mm)),
            curve.cubic((.1mm, .1mm), (.2mm, 1.1mm), (1.4mm, 1.6mm)),
            curve.cubic((3mm, 2.3mm), (6.5mm, 2.3mm), (7.4mm, 1.5mm)),
            curve.cubic((8.1mm, .85mm), (7.6mm, -.15mm), (6.25mm, -.2mm)),
          ),
        )
      }
    }
  }
  let title-binding = tiling(
    size: (width + 4mm, height),
    offset: (0pt, 0pt),
    relative: "self",
    mirror-gfx(is-rtl, block(width: width + 4mm, height: height, inset: 0pt, above: 0pt, below: 0pt, breakable: false)[
      #draw-rings(stroke-color: wire-color, limit: 16mm)
    ]),
  )

  // شبكة ملليمترية ثابتة كل 1 مم، مستقلة عن عدد الحلقات وارتفاع الإطار.
  let binding = tiling(
    size: (width + 4mm, height),
    offset: (0pt, 0pt),
    relative: "self",
    mirror-gfx(is-rtl, block(width: width + 4mm, height: height, inset: 0pt, above: 0pt, below: 0pt, breakable: false)[#{
      place(
        top + left,
        rect(
          width: width + 4mm,
          height: height,
          fill: white,
          stroke: none,
        ),
      )
      place(
        top + left,
        rect(
          width: width,
          height: height,
          fill: paper-color,
          stroke: none,
        ),
      )

      // الخطوط الأفقية: كل 1 مم، وخطوط أوضح كل 2 مم و8 مم.
      for rule-index in range(1, calc.ceil(height / 1mm)) {
        let main-rule = calc.rem(rule-index, 8) == 0
        let intermediate-rule = calc.rem(rule-index, 2) == 0
        place(
          top + left,
          dy: rule-index * 1mm,
          line(
            length: width,
            stroke: if main-rule {
              .45pt + rule-color
            } else if intermediate-rule {
              .3pt + fine-rule-color
            } else {
              .2pt + fine-rule-color
            },
          ),
        )
      }

      // الخطوط العمودية تكمل المربعات الملليمترية على مساحة الورقة.
      for grid-index in range(1, calc.ceil(width / 1mm)) {
        let main-grid = calc.rem(grid-index, 8) == 0
        place(
          top + left,
          dx: grid-index * 1mm,
          line(
            start: (0mm, 0mm),
            end: (0mm, height),
            stroke: if main-grid {
              .4pt + rule-color
            } else {
              .2pt + fine-rule-color
            },
          ),
        )
      }

      // هامش الكراس الأحمر المزدوج، بجوار الثقوب وبعيدًا عن النص.
      place(
        top + left,
        dx: width - 9mm,
        line(
          start: (0mm, 0mm),
          end: (0mm, height),
          stroke: .65pt + margin-color,
        ),
      )

      place(
        top + left,
        dx: width - 8.5mm,
        line(
          start: (0mm, 0mm),
          end: (0mm, height),
          stroke: .3pt + margin-color,
        ),
      )

      draw-rings()
    }]),
  )

  // النص داخل كتلة قابلة للتجزئة، دون ظل وهامش أيمن 1 سم.
  block(
    width: width + 4mm,
    breakable: true,
    inset: 0pt,
    above: 0pt,
    below: 0pt,
  )[
    #block(
      width: width + 4mm,
      breakable: true,
      fill: binding,
      inset: 0pt,
      above: 0pt,
      below: 0pt,
    )[
      #align(if is-rtl { left } else { right })[
        #block(
          width: width,
          height: height,
          breakable: true,
          stroke: .8pt + border-color,
          radius: 3.5mm,
          inset: mirror-dict(is-rtl, (top: 0mm, bottom: 12mm, left: 12mm, right: 10mm)),
          above: 0pt,
          below: 0pt,
        )[
          #content
          // طبقة أمامية شفافة: السلك والثقوب فوق العنوان، لا خلفه.
          #place(
            top + left,
            dx: if is-rtl { -12mm } else { -14mm },
            rect(
              width: width + 4mm,
              height: 16mm,
              fill: title-binding,
              stroke: none,
            ),
          )
        ]
      ]
    ]
  ]
}

// `width: auto` (default) = full available width like the other frames;
// give a length (e.g. `width: 150mm`) for a fixed width.
// العرض الافتراضي `auto` = عرض المساحة المتاحة مثل بقية الإطارات.
// The paper border lines up with the other frames; only the rings stick out
// (4mm) into the page margin on the binding side.
// حدّ الورقة بمحاذاة بقية الإطارات، والحلقات وحدها تبرز 4 مم في الهامش.
#let grid-notebook-frame-raw(body, width: auto, ..rest) = context {
  let is-rtl = text.dir == rtl
  if width == auto {
    layout(size => pad(
      ..(if is-rtl { (right: -4mm) } else { (left: -4mm) }),
      grid-notebook-draw(body, width: size.width, ..rest),
    ))
  } else {
    grid-notebook-draw(body, width: width, ..rest)
  }
}

// 60. Prerequisites card: gradient sheet with a folded corner, a soft shadow and
// metal rings on the END side of the sheet; labeled items in red.
// بطاقة المكتسبات القبلية: ورقة بزاوية مطوية وحلقات سلك؛ تنعكس في النسخة اللاتينية.
#let binder-ring(wire, out) = {
  let cx = 2.5mm
  let cy = 2.3mm
  box(width: 8.5mm + out, height: 4.6mm, {
    place(top + left, dx: cx - 2mm, dy: cy - 2mm,
      circle(radius: 2mm,
        fill: gradient.linear(luma(140), white, luma(140), angle: 0deg),
        stroke: .9pt + wire))
    place(top + left, dx: cx, dy: cy,
      curve(
        fill: none,
        stroke: (paint: wire, thickness: 1pt, cap: "round"),
        curve.move((1.65mm, -.85mm)),
        curve.cubic((.15mm, -.6mm), (.15mm, .4mm), (1.3mm, .9mm)),
        curve.cubic((2.8mm, 1.65mm), (6.3mm, 1.65mm), (7.3mm, .85mm)),
        curve.cubic((8.05mm, .2mm), (7.45mm, -.8mm), (6.25mm, -.85mm)),
      ))
    place(top + left, dx: cx, dy: cy,
      curve(
        fill: none,
        stroke: (paint: wire, thickness: 1pt, cap: "round"),
        curve.move((1.65mm, -.2mm)),
        curve.cubic((.1mm, .1mm), (.2mm, 1.1mm), (1.4mm, 1.6mm)),
        curve.cubic((3mm, 2.3mm), (6.5mm, 2.3mm), (7.4mm, 1.5mm)),
        curve.cubic((8.1mm, .85mm), (7.6mm, -.15mm), (6.25mm, -.2mm)),
      ))
  })
}

// `items`: array of (label, content) pairs; `body` (optional) follows them.
#let prerequisites-frame-raw(
  items: (),
  color: luma(60),
  fill-color: rgb("#cdeaf8"),
  label-color: red,
  fold-color: rgb("#bdeaf7"),
  fold-border-color: rgb("#2a9fd0"),
  shadow-color: luma(185),
  wire-color: luma(40),
  ring-spacing: 7mm,
  ring-out: 2.2mm,
  ..rest,
) = context {
  let is-rtl = text.dir == rtl
  let body = rest.pos().at(0, default: [])
  block(width: 100%, breakable: false, above: 7mm, below: 7mm)[
    #layout(size => {
      let k = 0.55cm
      let sh = 3pt
      let rendered = items.map(pair => [#text(fill: label-color)[#pair.at(0)] : #pair.at(1)])
      let text-block = block(
        width: size.width, breakable: false, spacing: 0pt,
        inset: mirror-dict(is-rtl, (top: 9pt, bottom: 9pt, left: 10pt, right: 1.3cm)),
      )[
        #set align(start)
        #rendered.join(parbreak())
        #if body != [] and items.len() > 0 { parbreak() }
        #body
      ]
      let h = measure(text-block).height
      let decor = box(width: size.width, height: h)[
        #place(top + left,
          polygon(fill: shadow-color, stroke: none,
            (0pt, 0pt), (size.width, 0pt), (size.width + sh, sh),
            (size.width + sh, h + sh), (k, h + sh), (0pt, h - k + sh)))
        #place(top + left,
          rect(width: size.width, height: h,
            fill: gradient.linear(white, fill-color, angle: 60deg),
            stroke: 0.5pt + color))
        #place(bottom + left, dx: -1pt, dy: 1pt,
          polygon(fill: white, stroke: none,
            (0pt, -1pt), (k + 1pt, k + 1pt), (-1pt, k + 1pt)))
        #place(top + left,
          polygon(fill: shadow-color, stroke: none,
            (0pt, h - k), (k, h), (k, h + sh), (0pt, h - k + sh)))
        #place(bottom + left, line(start: (0pt, 0pt), end: (k, k), stroke: 0.5pt + color))
        #place(bottom + left,
          polygon(fill: fold-color, stroke: 0.6pt + fold-border-color,
            (0pt, 0pt), (k, k), (k, 0pt)))
        #let n = calc.max(1, calc.floor(h / ring-spacing))
        #let start = (h - n * ring-spacing) / 2
        #for i in range(n) {
          place(top + right, dx: ring-out,
            dy: start + ring-spacing * (i + 0.5) - 2.3mm,
            binder-ring(wire-color, ring-out))
        }
      ]
      box(width: size.width, height: h)[
        #mirror-gfx(is-rtl, decor)
        #place(top + left, text-block)
      ]
    })
  ]
}

// ═══════════════════════════════════════════════════════════════
// 61-64. New frames (batch 4) / إطارات الدفعة الرابعة
// Auto width: when `width: auto` the frame fills the available width,
// exactly like the other frames. / العرض التلقائي = عرض المساحة المتاحة.
// ═══════════════════════════════════════════════════════════════
#let fit-width(width, extra, draw) = if width == auto {
  layout(size => draw(size.width - extra))
} else {
  draw(width)
}

// 61. Sheet with a wide ribbon (notched end) and two folded corners.
// ورقة بشريط عريض بنهاية مشطوفة وطيّتين صغيرتين.
#let folded-ribbon-frame-raw(
  body,
  title: auto,
  color: rgb("#780505"),
  title-color: auto,
  title-text-color: white,
  fold-color: rgb("#655eb3"),
  paper-color: white,
  ribbon-width: 100mm,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let title = pick-title(title, [الواجب المنزلي], [Homework])
  let ribbon-color = label-color(color, title-color)
  let side = if is-rtl { top + right } else { top + left }
  let out = if is-rtl { 2mm } else { -2mm }
  let ribbon = box(width: ribbon-width, height: 12mm)[
    #mirror-gfx(is-rtl, box(width: ribbon-width, height: 12mm)[
      #place(top + left, curve(
        fill: ribbon-color,
        stroke: none,
        curve.move((0mm, 6mm)),
        curve.line((5mm, 0mm)),
        curve.line((ribbon-width, 0mm)),
        curve.line((ribbon-width, 12mm)),
        curve.line((5mm, 12mm)),
        curve.close(),
      ))
    ])
    #place(
      top + left,
      dx: if is-rtl { 5mm } else { 0mm },
      block(width: ribbon-width - 5mm, height: 12mm, inset: 1mm)[
        #align(center + horizon)[
          #text(size: 16pt, weight: "bold", fill: title-text-color)[#title]
        ]
      ],
    )
  ]
  let fold-top = mirror-gfx(is-rtl, box(width: 2mm, height: 2mm)[
    #place(top + left, curve(
      fill: fold-color,
      stroke: none,
      curve.move((0mm, 0mm)),
      curve.line((2mm, 2mm)),
      curve.line((0mm, 2mm)),
      curve.close(),
    ))
  ])
  let fold-bottom = mirror-gfx(is-rtl, box(width: 2mm, height: 2mm)[
    #place(top + left, curve(
      fill: fold-color,
      stroke: none,
      curve.move((0mm, 0mm)),
      curve.line((2mm, 0mm)),
      curve.line((0mm, 2mm)),
      curve.close(),
    ))
  ])
  block(
    width: 100%,
    height: auto,
    fill: paper-color,
    stroke: .6pt + color,
    inset: 0pt,
    above: 6mm,
    below: 4mm,
    breakable: breakable,
  )[
    #place(side, dx: out, fold-top)
    #place(side, dx: out, dy: 14mm, fold-bottom)
    #place(side, dx: out, dy: 2mm, ribbon)
    #pad(top: 20mm, bottom: 8mm, left: 6mm, right: 6mm)[
      #align(start)[#body]
    ]
  ]
}

// 62. Sheet with a top rule and a curved title tab hanging over the rule
// on the START side. / ورقة بخط علوي ولسان عنوان منحنٍ معلّق على جهة البداية.
#let hanging-tab-frame-raw(
  body,
  title: auto,
  color: black,
  title-color: auto,
  title-text-color: white,
  paper-color: white,
  breakable: true,
) = context {
  let is-rtl = text.dir == rtl
  let title = pick-title(title, [تمرين], [Exercise])
  let tab-color = label-color(color, title-color)
  let title-text = text(size: 16pt, weight: "bold", fill: title-text-color)[#title]
  let title-width = measure(title-text).width + 12mm
  let title-height = calc.max(12mm, measure(title-text).height + 6mm)
  let tab = box(width: title-width, height: title-height + 3mm)[
    #mirror-gfx(is-rtl, box(width: title-width, height: title-height + 3mm)[
      #place(top + left, curve(
        fill: tab-color,
        stroke: none,
        curve.move((0mm, title-height)),
        curve.line((0mm, title-height * .55)),
        curve.cubic(
          (0mm, title-height * .2),
          (title-width * .025, 0mm),
          (title-width * .085, 0mm),
        ),
        curve.line((title-width * .91, title-height * .18)),
        curve.cubic(
          (title-width * .97, title-height * .18),
          (title-width, title-height * .35),
          (title-width, title-height * .65),
        ),
        curve.line((title-width, title-height + 3mm)),
        curve.cubic(
          (title-width, title-height + .5mm),
          (title-width * .96, title-height),
          (title-width * .91, title-height),
        ),
        curve.close(),
      ))
    ])
    #place(
      top + left,
      dx: 4mm,
      dy: 2mm,
      block(
        width: title-width - 8mm,
        height: title-height - 3mm,
        inset: 1mm,
        breakable: false,
      )[
        #align(center + horizon)[#title-text]
      ],
    )
  ]
  block(
    width: 100%,
    height: auto,
    fill: paper-color,
    stroke: (top: .8pt + color),
    inset: 0pt,
    above: title-height + 3mm,
    below: 4mm,
    breakable: breakable,
  )[
    #place(if is-rtl { top + right } else { top + left }, dy: -title-height, tab)
    #pad(top: 5mm, bottom: 5mm, left: 5mm, right: 5mm)[
      #align(start)[#body]
    ]
  ]
}

// 63. Sheet with a centered title label that has two pointed wings and a
// dotted inner border. / ورقة بعنوان في الوسط بجناحين مدبّبين وحدّ منقّط داخلي.
#let winged-tab-frame-raw(
  body,
  title: auto,
  color: black,
  title-color: auto,
  title-text-color: auto,
  tab-fill: white,
  paper-color: white,
  breakable: true,
) = context {
  let title = pick-title(title, [ملاحظة], [Note])
  let wing-color = label-color(color, title-color)
  let label-fill = if title-text-color == auto { wing-color } else { title-text-color }
  let title-text = text(size: 16pt, weight: "bold", fill: label-fill)[#title]
  let title-width = measure(title-text).width + 8mm
  let title-height = calc.max(10mm, measure(title-text).height + 4mm)
  let wing-width = 3mm
  let tab = box(width: title-width + 2 * wing-width, height: title-height)[
    #place(top + left, curve(
      fill: wing-color,
      stroke: none,
      curve.move((0mm, title-height / 2)),
      curve.line((wing-width, 0mm)),
      curve.line((wing-width, title-height)),
      curve.close(),
    ))
    #place(top + right, curve(
      fill: wing-color,
      stroke: none,
      curve.move((0mm, 0mm)),
      curve.line((wing-width, title-height / 2)),
      curve.line((0mm, title-height)),
      curve.close(),
    ))
    #place(
      top + left,
      dx: wing-width,
      block(
        width: title-width,
        height: title-height,
        fill: tab-fill,
        stroke: .5pt + wing-color,
        inset: 1mm,
        breakable: false,
      )[
        #block(
          width: title-width - 2mm,
          height: title-height - 2mm,
          stroke: (paint: wing-color, thickness: .4pt, dash: "dotted"),
          inset: (x: 2mm, y: .5mm),
          breakable: false,
        )[
          #align(center + horizon)[#title-text]
        ]
      ],
    )
  ]
  block(
    width: 100%,
    height: auto,
    fill: paper-color,
    stroke: .5pt + color,
    inset: 0pt,
    above: title-height / 2 + 3mm,
    below: 4mm,
    breakable: breakable,
  )[
    #place(top + center, dy: -title-height / 2, tab)
    #pad(top: title-height / 2 + 4mm, bottom: 5mm, left: 5mm, right: 5mm)[
      #align(start)[#body]
    ]
  ]
}

// 64. Layered card with a slanted title badge, a gold underline and a dotted
// footer. `width: auto` = full available width.
// بطاقة بطبقتين وشارة عنوان مائلة وخط ذهبي وتذييل منقّط.
#let badge-notebook-frame-raw(
  body,
  title: auto,
  title-font: ("Noto Kufi Arabic", "Noto Sans Arabic", "Libertinus Serif"),
  title-size: 12pt,
  title-color: white,
  title-box-color: rgb("#173f49"),
  width: auto,
  height: auto,
  min-height: 60mm,
  paper-color: rgb("#fffdf7"),
  border-color: rgb("#cbdad7"),
  accent-color: rgb("#d6a94f"),
  text-fill: rgb("#30464a"),
) = fit-width(width, 2mm, w => context {
  let is-rtl = text.dir == rtl
  let title = pick-title(title, [أعمال تطبيقية], [Practical work])
  let side = if is-rtl { top + right } else { top + left }
  let title-label = text(
    font: title-font, size: title-size,
    weight: "bold", fill: title-color,
  )[#title]
  let badge-width = calc.min(measure(title-label).width + 42mm, w - 24mm)

  let header = block(
    width: w, height: 20mm, breakable: false,
    above: 0pt, below: 0pt,
  )[
    #place(
      side, dx: 0mm, dy: 0mm,
      box(width: badge-width, height: 15mm, clip: true)[
        #mirror-gfx(is-rtl, box(width: badge-width, height: 15mm)[
          #place(
            top + left,
            curve(
              fill: title-box-color, stroke: .65pt + title-box-color.darken(30%),
              curve.move((11mm, 0mm)),
              curve.line((badge-width - 4mm, 0mm)),
              curve.cubic(
                (badge-width - 1.8mm, 0mm),
                (badge-width, 1.8mm), (badge-width, 4mm),
              ),
              curve.line((badge-width, 15mm)),
              curve.line((0mm, 15mm)),
              curve.line((7mm, 7.5mm)),
              curve.line((0mm, 0mm)),
              curve.close(),
            ),
          )
        ])
      ],
    )
    #place(
      side, dx: if is-rtl { -7mm } else { 7mm }, dy: 1mm,
      block(width: badge-width - 30mm, height: 10mm)[
        #align((if is-rtl { right } else { left }) + horizon)[#box[#title-label]]
      ],
    )
    #place(
      side, dx: 0mm, dy: 14mm,
      rect(width: 28mm, height: 1.2mm,
        radius: mirror-dict(is-rtl, (bottom-left: .6mm)),
        fill: accent-color, stroke: none),
    )
  ]

  let content = block(
    width: w, breakable: true, above: 0pt, below: 0pt,
  )[
    #header
    #block(
      width: w, breakable: true,
      inset: mirror-dict(is-rtl, (top: 3mm, bottom: 9mm, left: 17mm, right: 7mm)),
      above: 0pt, below: 0pt,
    )[
      #set text(fill: text-fill)
      #set par(leading: .9em)
      #align(start)[#body]
    ]
    #block(
      width: w, height: 8mm, breakable: false,
      above: 0pt, below: 0pt,
    )[
      #place(
        top + left, dx: 14mm, dy: 2mm,
        line(length: w - 28mm,
          stroke: .35pt + border-color),
      )
      #place(
        top + left, dx: if is-rtl { 14mm } else { w - 15.4mm }, dy: 1.3mm,
        circle(radius: .7mm, fill: accent-color, stroke: none),
      )
    ]
  ]

  let fitted-height = calc.max(
    min-height, measure(content).height,
    if height == auto { 0mm } else { height },
  )

  block(
    width: w + 2mm, height: fitted-height + 2mm,
    breakable: true, fill: title-box-color,
    radius: 7mm, inset: 0pt, above: 6mm, below: 6mm,
  )[
    #align(side)[
      #block(
        width: w, height: fitted-height, breakable: true,
        fill: paper-color,
        stroke: .7pt + border-color,
        radius: mirror-dict(is-rtl, (top-right: 7mm, top-left: 3mm,
          bottom-right: 3mm, bottom-left: 7mm)),
        inset: 0pt, above: 0pt, below: 0pt,
      )[#content]
    ]
  ]
})

// ═══════════════════════════════════════════════════════════════
// Former ornamental frames → now the spiral-banner style
// الإطارات المزخرفة السابقة صارت بنمط شريط العنوان + السلك الجانبي،
// كلٌّ بلون مختلف. المعاملات الخاصة القديمة (footer, series, ...) تُتجاهل.
// ═══════════════════════════════════════════════════════════════
#let spiral-variant(body, title, color, title-color, title-text-color, breakable) = spiral-banner-frame-raw(
  body,
  title: title,
  title-color: label-color(color, title-color),
  title-text-color: if title-text-color == auto { white } else { title-text-color },
  frame-color: color.lighten(88%),
  breakable: breakable,
)

#let lace-frame-raw(
  body,
  title: auto, color: rgb("#975568"), title-color: auto, title-text-color: auto, breakable: true,
  ..ignored,
) = spiral-variant(body, title, color, title-color, title-text-color, breakable)

#let illuminated-frame-raw(
  body,
  title: auto, color: rgb("#4f7c70"), title-color: auto, title-text-color: auto, breakable: true,
  ..ignored,
) = spiral-variant(body, title, color, title-color, title-text-color, breakable)

#let geometric-frame-raw(
  body,
  title: auto, color: rgb("#1f6f8b"), title-color: auto, title-text-color: auto, breakable: true,
  ..ignored,
) = spiral-variant(body, title, color, title-color, title-text-color, breakable)

#let math-cover-frame-raw(
  body,
  title: auto, color: rgb("#1d4e89"), title-color: auto, title-text-color: auto, breakable: true,
  ..ignored,
) = spiral-variant(body, title, color, title-color, title-text-color, breakable)

#let vintage-frame-raw(
  body,
  title: auto, color: rgb("#8a5a2b"), title-color: auto, title-text-color: auto, breakable: true,
  ..ignored,
) = spiral-variant(body, title, color, title-color, title-text-color, breakable)

#let jewel-frame-raw(
  body,
  title: auto, color: rgb("#2e7d6b"), title-color: auto, title-text-color: auto, breakable: true,
  ..ignored,
) = spiral-variant(body, title, color, title-color, title-text-color, breakable)

#let star-chain-frame-raw(
  body,
  title: auto, color: rgb("#6a4c93"), title-color: auto, title-text-color: auto, breakable: true,
  ..ignored,
) = spiral-variant(body, title, color, title-color, title-text-color, breakable)

#let lantern-frame-raw(
  body,
  title: auto, color: rgb("#b8741a"), title-color: auto, title-text-color: auto, breakable: true,
  ..ignored,
) = spiral-variant(body, title, color, title-color, title-text-color, breakable)

#let botanical-frame-raw(
  body,
  title: auto, color: rgb("#4d7a3a"), title-color: auto, title-text-color: auto, breakable: true,
  ..ignored,
) = spiral-variant(body, title, color, title-color, title-text-color, breakable)

#let emerald-frame-raw(
  body,
  title: auto, color: rgb("#0b6e4f"), title-color: auto, title-text-color: auto, breakable: true,
  ..ignored,
) = spiral-variant(body, title, color, title-color, title-text-color, breakable)

#let right-scroll-frame-raw(
  body,
  title: auto, color: rgb("#8b2e2e"), title-color: auto, title-text-color: auto, breakable: true,
  ..ignored,
) = spiral-variant(body, title, color, title-color, title-text-color, breakable)

#let bevel-frame-raw(
  body,
  title: auto, color: rgb("#3a3a6e"), title-color: auto, title-text-color: auto, breakable: true,
  ..ignored,
) = spiral-variant(body, title, color, title-color, title-text-color, breakable)

// ═══════════════════════════════════════════════════════════════
// 9. Per-frame direction / اتجاه مستقل لكل إطار
// ═══════════════════════════════════════════════════════════════
// Every frame accepts two extra named parameters:
//   dir  : auto (follow the document) | rtl | ltr
//   lang : auto (ar for rtl, en for ltr) | any language code
// كل إطار يقبل dir و lang: يمكنك استعمال إطار عربي وآخر لاتيني في نفس الملف.
//   #theorem-frame(dir: ltr)[Pythagoras ...]
//   #theorem-frame(dir: rtl)[مبرهنة فيثاغورس ...]
// Per-language text: any text parameter may be a dictionary
//   title: (ar: [مبرهنة], en: [Theorem])
// and the version matching the frame language is used.
// كل معامل نصي يقبل قاموسًا (ar: ..., en: ...) فيُختار حسب لغة الإطار.
#let lang-params = (
  "title", "subtitle", "third-title", "points", "source",
  "badge-top", "badge-bottom", "header", "tag-title",
)

#let pick-lang(value) = {
  let l = text.lang
  if l in value { value.at(l) }
  else if l == "ar" and "ar" in value { value.at("ar") }
  else if "en" in value { value.at("en") }
  else if "ar" in value { value.at("ar") }
  else { value.values().first() }
}

#let with-dir(f) = (dir: auto, lang: auto, ..args) => {
  let run() = context {
    let named = args.named()
    for key in lang-params {
      if key in named {
        let value = named.at(key)
        if type(value) == dictionary { named.insert(key, pick-lang(value)) }
        else if value == none { named.insert(key, []) }
      }
    }
    f(..args.pos(), ..named)
  }
  if dir == auto and lang == auto {
    run()
  } else {
    set text(dir: dir) if dir != auto
    set text(lang: if lang != auto { lang } else if dir == rtl { "ar" } else { "en" })
    run()
  }
}

#let board-frame = with-dir(board-frame-raw)
#let blue-frame = with-dir(blue-frame-raw)
#let theorem-frame = with-dir(theorem-frame-raw)
#let flag-frame = with-dir(flag-frame-raw)
#let proof-frame = with-dir(proof-frame-raw)
#let gradient-frame = with-dir(gradient-frame-raw)
#let chapter-frame = with-dir(chapter-frame-raw)
#let ribbon-frame = with-dir(ribbon-frame-raw)
#let green-frame = with-dir(green-frame-raw)
#let shadow-frame = with-dir(shadow-frame-raw)
#let paper-frame = with-dir(paper-frame-raw)
#let sticky-frame = with-dir(sticky-frame-raw)
#let notebook-frame = with-dir(notebook-frame-raw)
#let corner-rule-frame = with-dir(corner-rule-frame-raw)
#let properties-frame = with-dir(properties-frame-raw)
#let folded-definition-frame = with-dir(folded-definition-frame-raw)
#let centered-info-frame = with-dir(centered-info-frame-raw)
#let double-tab-frame = with-dir(double-tab-frame-raw)
#let torn-paper-frame = with-dir(torn-paper-frame-raw)
#let spiral-banner-frame = with-dir(spiral-banner-frame-raw)
#let notebook-page-frame = with-dir(notebook-page-frame-raw)
#let numbered-exercise-frame = with-dir(numbered-exercise-frame-raw)
#let numbered-frame = with-dir(numbered-frame-raw)
#let property-frame = with-dir(property-frame-raw)
#let exercise-card = with-dir(exercise-card-raw)
#let lace-frame = with-dir(lace-frame-raw)
#let illuminated-frame = with-dir(illuminated-frame-raw)
#let geometric-frame = with-dir(geometric-frame-raw)
#let math-cover-frame = with-dir(math-cover-frame-raw)
#let vintage-frame = with-dir(vintage-frame-raw)
#let jewel-frame = with-dir(jewel-frame-raw)
#let star-chain-frame = with-dir(star-chain-frame-raw)
#let lantern-frame = with-dir(lantern-frame-raw)
#let botanical-frame = with-dir(botanical-frame-raw)
#let emerald-frame = with-dir(emerald-frame-raw)
#let right-scroll-frame = with-dir(right-scroll-frame-raw)
#let tab-frame = with-dir(tab-frame-raw)
#let curved-tab-frame = with-dir(curved-tab-frame-raw)
#let speech-frame = with-dir(speech-frame-raw)
#let rounded-tab-frame = with-dir(rounded-tab-frame-raw)
#let exam-frame = with-dir(exam-frame-raw)
#let right-rule-frame = with-dir(right-rule-frame-raw)
#let folded-corner-frame = with-dir(folded-corner-frame-raw)
#let subtitle-frame = with-dir(subtitle-frame-raw)
#let outlined-tab-frame = with-dir(outlined-tab-frame-raw)
#let inset-tab-frame = with-dir(inset-tab-frame-raw)
#let side-notebook-frame = with-dir(side-notebook-frame-raw)
#let binder-notebook-frame = with-dir(binder-notebook-frame-raw)
#let framed-exercise = with-dir(framed-exercise-raw)
#let sheet-frame = with-dir(sheet-frame-raw)
#let bevel-frame = with-dir(bevel-frame-raw)
#let warning-note = with-dir(warning-note-raw)
#let homework-sheet = with-dir(homework-sheet-raw)
#let homework-sheet-modern = with-dir(homework-sheet-modern-raw)
#let practical-notebook = with-dir(practical-notebook-raw)
#let ribbon-banner = with-dir(ribbon-banner-raw)
#let arched-ribbon = with-dir(arched-ribbon-raw)
#let ribbon-notes-frame = with-dir(ribbon-notes-frame-raw)
#let grid-notebook-frame = with-dir(grid-notebook-frame-raw)
#let prerequisites-frame = with-dir(prerequisites-frame-raw)
#let folded-ribbon-frame = with-dir(folded-ribbon-frame-raw)
#let hanging-tab-frame = with-dir(hanging-tab-frame-raw)
#let winged-tab-frame = with-dir(winged-tab-frame-raw)
#let badge-notebook-frame = with-dir(badge-notebook-frame-raw)

// ═══════════════════════════════════════════════════════════════
// 10. Registry / السجل
// ═══════════════════════════════════════════════════════════════


// Registry: `#frame("theorem", title: [..], color: ..)[..]`
#let frames = (
  board: board-frame,
  blue: blue-frame,
  theorem: theorem-frame,
  flag: flag-frame,
  proof: proof-frame,
  gradient: gradient-frame,
  chapter: chapter-frame,
  ribbon: ribbon-frame,
  green: green-frame,
  shadow: shadow-frame,
  paper: paper-frame,
  sticky: sticky-frame,
  notebook: notebook-frame,
  corner-rule: corner-rule-frame,
  properties: properties-frame,
  folded: folded-definition-frame,
  centered: centered-info-frame,
  double-tab: double-tab-frame,
  torn: torn-paper-frame,
  spiral: spiral-banner-frame,
  notebook-page: notebook-page-frame,
  numbered-exercise: numbered-exercise-frame,
  numbered: numbered-frame,
  property: property-frame,
  exercise-card: exercise-card,
  lace: lace-frame,
  illuminated: illuminated-frame,
  geometric: geometric-frame,
  math-cover: math-cover-frame,
  vintage: vintage-frame,
  jewel: jewel-frame,
  star-chain: star-chain-frame,
  lantern: lantern-frame,
  botanical: botanical-frame,
  emerald: emerald-frame,
  right-scroll: right-scroll-frame,
  tab: tab-frame,
  curved-tab: curved-tab-frame,
  speech: speech-frame,
  rounded-tab: rounded-tab-frame,
  exam: exam-frame,
  right-rule: right-rule-frame,
  folded-corner: folded-corner-frame,
  subtitle-frame: subtitle-frame,
  outlined-tab: outlined-tab-frame,
  inset-tab: inset-tab-frame,
  side-notebook: side-notebook-frame,
  binder-notebook: binder-notebook-frame,
  framed-exercise: framed-exercise,
  sheet: sheet-frame,
  bevel-frame: bevel-frame,
  warning-note: warning-note,
  homework-sheet: homework-sheet,
  homework-sheet-modern: homework-sheet-modern,
  practical-notebook: practical-notebook,
  ribbon-banner: ribbon-banner,
  arched-ribbon: arched-ribbon,
  ribbon-notes: ribbon-notes-frame,
  grid-notebook: grid-notebook-frame,
  prerequisites: prerequisites-frame,
  folded-ribbon: folded-ribbon-frame,
  hanging-tab: hanging-tab-frame,
  winged-tab: winged-tab-frame,
  badge-notebook: badge-notebook-frame,
)

#let frame(style, ..args) = (frames.at(style))(..args)
