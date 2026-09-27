// ═══════════════════════════════════════════════════════════
// GEOMETRY.TYP v1.0 — Vẽ hình học nhanh với Cetz
// ═══════════════════════════════════════════════════════════
// Import: #import "@preview/cetz:0.5.2"
//         #import "geometry.typ": *
//
// Các hàm vẽ một canvas hoàn chỉnh bọc sẵn cetz.canvas().
// Mỗi hàm trả về 1 canvas — dùng trực tiếp làm fig: trong tn/ds/tln/tl.
// ─────────────────────────────────────────────────────────
// DANH SÁCH HÀM:
//   tri-xyz(a,b,c)             Tam giác ABC (toạ độ thật)
//   tri-angles(a,α,β)         Tam giác từ 1 cạnh + 2 góc
//   tri-right(...)            Tam giác vuông
//   rect-abc(a,b)             Hình chữ nhật / vuông
//   chóp-sabc(h,...)          Hình chóp S.ABC
//   chóp-sabcd(h,...)         Hình chóp S.ABCD
//   lang-tru-abc(h,...)       Lăng trụ đứng ABC.A'B'C'
//   circle-desc(r)            Đường tròn tâm O, bán kính r
//   angle-mark(A,O,B)         Đánh dấu góc ∠AOB
//   right-angle(A,O,B)        Đánh dấu góc vuông tại O
//   seg-label(A,B,text,pos)   Gán nhãn đoạn thẳng
//   point-label(p,text,pos)   Gán nhãn điểm
//   axis-xy(xmin,xmax,ymin,ymax)  Trục toạ độ Oxy
//   parabola(a,b,c,...)       Parabol y = ax²+bx+c
//   dashed-line(A,B)          Đường đứt nét
// ─────────────────────────────────────────────────────────

#import "@preview/cetz:0.5.2"

// ── Hằng ─────────────────────────────────────────────────
#let _ge-blue = rgb("#0057b8")
#let _ge-red = rgb("#cc2200")
#let _ge-green = rgb("#1a7a2e")
#let _ge-gray = rgb("#888")
#let _ge-bg = rgb("#fafafa")
#let _ge-scale = 0.7cm
#let _ge-padding = 0.4

// ── Tam giác từ 3 điểm cho trước ───────────────────────
// tri-xyz(A: (x,y), B: (x,y), C: (x,y), labels: (...))
#let tri-xyz(A, B, C, labels: ("A", "B", "C"), right-angle: none, scale: _ge-scale) = {
  cetz.canvas(length: scale, {
    import cetz.draw: *
    line(A, B, C, A, stroke: 1.2pt + black)
    for ((p, lbl)) in ((A, labels.at(0)), (B, labels.at(1)), (C, labels.at(2))) {
      circle(p, radius: 2.5pt, fill: black)
      let (x, y) = p
      let dx = 0.25; let dy = 0.25
      if p == A { (dx, dy) = (-0.3, -0.35) }
      if p == B { (dx, dy) = (0.3, -0.35) }
      if p == C { (dx, dy) = (0, 0.35) }
      content((x + dx, y + dy), text(size: 9pt, weight: "bold")[#lbl])
    }
    if right-angle != none {
      let pts = (A, B, C)
      let i = if right-angle == "A" { 0 } else if right-angle == "B" { 1 } else if right-angle == "C" { 2 } else { -1 }
      if i >= 0 {
        let p = pts.at(i)
        let p1 = pts.at(calc.rem(i + 1, 3))
        let p2 = pts.at(calc.rem(i + 2, 3))
        let s = 0.4
        let v1 = ((p1.at(0) - p.at(0), p1.at(1) - p.at(1)))
        let v2 = ((p2.at(0) - p.at(0), p2.at(1) - p.at(1)))
        let d1 = calc.sqrt(v1.at(0) * v1.at(0) + v1.at(1) * v1.at(1))
        let d2 = calc.sqrt(v2.at(0) * v2.at(0) + v2.at(1) * v2.at(1))
        let u1 = (v1.at(0) / d1 * s, v1.at(1) / d1 * s)
        let u2 = (v2.at(0) / d2 * s, v2.at(1) / d2 * s)
        line((p.at(0) + u1.at(0), p.at(1) + u1.at(1)),
             (p.at(0) + u1.at(0) + u2.at(0), p.at(1) + u1.at(1) + u2.at(1)),
             (p.at(0) + u2.at(0), p.at(1) + u2.at(1)),
             stroke: 0.6pt + black)
      }
    }
  })
}

// ── Tam giác thường — cạnh đáy ngang, đỉnh trên ────────
// base = độ dài đáy, height = chiều cao
#let tri-abc(base: 5, height: 3.5, labels: ("A", "B", "C"), scale: _ge-scale) = {
  let hw = base / 2
  tri-xyz(
    (-hw, 0), (hw, 0), (0, height),
    labels: labels,
    scale: scale,
  )
}

// ── Tam giác vuông tại A ────────────────────────────────
#let tri-right(leg1: 4, leg2: 3, labels: ("A", "B", "C"), right-angle-vertex: "A", scale: _ge-scale) = {
  tri-xyz(
    (0, 0), (leg1, 0), (0, leg2),
    labels: labels,
    right-angle: right-angle-vertex,
    scale: scale,
  )
}

// ── Hình chữ nhật / vuông ──────────────────────────────
#let rect-xyz(A: (0, 0), C: (5, 3), labels: ("A", "B", "C", "D"), scale: _ge-scale) = {
  cetz.canvas(length: scale, {
    import cetz.draw: *
    let (ax, ay) = A; let (cx, cy) = C
    let B = (cx, ay); let D = (ax, cy)
    line(A, B, C, D, A, stroke: 1.2pt + black)
    for ((p, lbl)) in ((A, labels.at(0)), (B, labels.at(1)), (C, labels.at(2)), (D, labels.at(3))) {
      circle(p, radius: 2.5pt, fill: black)
      let (x, y) = p
      let (dx, dy) = if p == A { (-0.3, -0.35) }
        else if p == B { (0.3, -0.35) }
        else if p == C { (0.3, 0.35) }
        else { (-0.3, 0.35) }
      content((x + dx, y + dy), text(size: 9pt, weight: "bold")[#lbl])
    }
  })
}

// ── Hình chữ nhật đơn giản ─────────────────────────────
#let rect-abc(width: 5, height: 3, labels: ("A", "B", "C", "D"), scale: _ge-scale) = {
  rect-xyz(A: (0, 0), C: (width, height), labels: labels, scale: scale)
}

// ── Hình vuông ─────────────────────────────────────────
#let square(a: 4, labels: ("A", "B", "C", "D"), scale: _ge-scale) = {
  rect-abc(width: a, height: a, labels: labels, scale: scale)
}

// ═══════════════════════════════════════════════════════════
// HÌNH HỌC KHÔNG GIAN (Phối cảnh Cavalier)
// ═══════════════════════════════════════════════════════════

// ── Hình chóp tam giác S.ABC ────────────────────────────
// base: 3 điểm đáy, S: đỉnh
#let chop-sabc(
  S: (0, 8),
  A: (-4, 0), B: (4, 0), C: (0, -2),
  labels: ("S", "A", "B", "C"),
  hidden: (), // tuple đỉnh bị che: ("AC",) → AC nét đứt
  scale: _ge-scale,
) = {
  cetz.canvas(length: scale, {
    import cetz.draw: *
    let pts = (S, A, B, C)
    let edges = ((0, 1), (0, 2), (0, 3), (1, 2), (2, 3), (3, 1))
    for e in edges {
      let (i, j) = e
      let lbl = labels.at(i) + labels.at(j)
      let rev = labels.at(j) + labels.at(i)
      let st = if hidden.contains(lbl) or hidden.contains(rev) {
        (paint: _ge-gray, thickness: 0.7pt, dash: "dashed")
      } else {
        1.1pt + black
      }
      line(pts.at(i), pts.at(j), stroke: st)
    }
    for (i, lbl) in labels.enumerate() {
      let (x, y) = pts.at(i)
      circle((x, y), radius: 2.5pt, fill: if i == 0 { _ge-blue } else { black })
      let (dx, dy) = if lbl == "S" { (0, 0.45) }
        else if lbl == "A" { (-0.4, -0.3) }
        else if lbl == "B" { (0.4, -0.3) }
        else { (0.1, -0.4) }
      content((x + dx, y + dy), text(size: 10pt, weight: "bold")[#lbl])
    }
  })
}

// ── Hình chóp tứ giác S.ABCD ────────────────────────────
#let chop-sabcd(
  S: (0, 7),
  A: (-3, 0), B: (3, 0), C: (2, -2), D: (-2, -2),
  labels: ("S", "A", "B", "C", "D"),
  hidden: (),
  scale: _ge-scale,
) = {
  cetz.canvas(length: scale, {
    import cetz.draw: *
    let pts = (S, A, B, C, D)
    let edges = ((0, 1), (0, 2), (0, 3), (0, 4), (1, 2), (2, 3), (3, 4), (4, 1))
    for e in edges {
      let (i, j) = e
      let lbl = labels.at(i) + labels.at(j)
      let rev = labels.at(j) + labels.at(i)
      let st = if hidden.contains(lbl) or hidden.contains(rev) {
        (paint: _ge-gray, thickness: 0.7pt, dash: "dashed")
      } else {
        1.1pt + black
      }
      line(pts.at(i), pts.at(j), stroke: st)
    }
    for (i, lbl) in labels.enumerate() {
      let (x, y) = pts.at(i)
      circle((x, y), radius: 2.5pt, fill: if i == 0 { _ge-blue } else { black })
      let (dx, dy) = if lbl == "S" { (0, 0.45) }
        else if lbl == "A" { (-0.35, -0.3) }
        else if lbl == "B" { (0.35, -0.3) }
        else if lbl == "C" { (0.3, 0.3) }
        else { (-0.3, 0.3) }
      content((x + dx, y + dy), text(size: 10pt, weight: "bold")[#lbl])
    }
  })
}

// ── Lăng trụ tam giác ABC.A'B'C' ────────────────────────
#let lang-tru-abc(
  A: (-3, 0), B: (3, 0), C: (0, -2),
  A2: (-3, 5), B2: (3, 5), C2: (0, 3),
  labels: ("A", "B", "C", "A'", "B'", "C'"),
  hidden: (), // "AA'" hoặc "AB" để đánh dấu nét đứt
  scale: _ge-scale,
) = {
  cetz.canvas(length: scale, {
    import cetz.draw: *
    let pts = (A, B, C, A2, B2, C2)
    let edges = ((0, 1), (1, 2), (2, 0), (3, 4), (4, 5), (5, 3), (0, 3), (1, 4), (2, 5))
    for e in edges {
      let (i, j) = e
      let lbl = labels.at(i) + labels.at(j)
      let rev = labels.at(j) + labels.at(i)
      let st = if hidden.contains(lbl) or hidden.contains(rev) {
        (paint: _ge-gray, thickness: 0.7pt, dash: "dashed")
      } else {
        1.1pt + black
      }
      line(pts.at(i), pts.at(j), stroke: st)
    }
    for (i, lbl) in labels.enumerate() {
      let (x, y) = pts.at(i)
      circle((x, y), radius: 2.5pt, fill: black)
      let (dx, dy) = if lbl == "A" or lbl == "A'" { (-0.35, -0.3) }
        else if lbl == "B" or lbl == "B'" { (0.35, -0.3) }
        else { (0, 0.35) }
      content((x + dx, y + dy), text(size: 10pt, weight: "bold")[#lbl])
    }
  })
}

// ═══════════════════════════════════════════════════════════
// ĐƯỜNG TRÒN & MARKERS
// ═══════════════════════════════════════════════════════════

// ── Đường tròn tâm O, bán kính R ────────────────────────
#let circle-desc(
  center: (0, 0),
  radius: 2,
  label: "O",
  scale: _ge-scale,
) = {
  cetz.canvas(length: scale, {
    import cetz.draw: *
    circle(center, radius: radius, stroke: 1.2pt + black, fill: none)
    circle(center, radius: 2.8pt, fill: black)
    content((center.at(0) - 0.3, center.at(1) - 0.35), text(size: 10pt, weight: "bold")[#label])
    // Vẽ 2 đường kính nét mảnh
    line(
      (center.at(0) - radius, center.at(1)),
      (center.at(0) + radius, center.at(1)),
      stroke: (paint: _ge-gray, thickness: 0.4pt, dash: "dotted"),
    )
    line(
      (center.at(0), center.at(1) - radius),
      (center.at(0), center.at(1) + radius),
      stroke: (paint: _ge-gray, thickness: 0.4pt, dash: "dotted"),
    )
  })
}

// ── Đánh dấu góc ────────────────────────────────────────
#let angle-mark(A, O, B, radius: 0.5, label: none, fill: rgb("#FFE0B2"), scale: _ge-scale) = {
  cetz.canvas(length: scale, {
    import cetz.draw: *
    let (ax, ay) = A
    let (ox, oy) = O
    let (bx, by) = B
    let angleA = calc.atan2(ay - oy, ax - ox)
    let angleB = calc.atan2(by - oy, bx - ox)
    let r = radius
    arc(O, r, angleA, angleB, stroke: 0.7pt + _ge-red, fill: fill)
    if label != none {
      let mx = ox + r * 1.5 * calc.cos((angleA + angleB) / 2)
      let my = oy + r * 1.5 * calc.sin((angleA + angleB) / 2)
      content((mx, my), text(size: 8pt, fill: _ge-red)[#label])
    }
  })
}

// ── Đường đứt nét giữa 2 điểm ──────────────────────────
#let dashed-seg(A, B, scale: _ge-scale) = {
  cetz.canvas(length: scale, {
    import cetz.draw: *
    line(A, B, stroke: (paint: _ge-gray, thickness: 0.7pt, dash: "dashed"))
  })
}

// ═══════════════════════════════════════════════════════════
// TRỤC TOẠ ĐỘ & ĐỒ THỊ
// ═══════════════════════════════════════════════════════════

// ── Hệ trục Oxy ─────────────────────────────────────────
#let axis-xy(
  xmin: -3, xmax: 3, ymin: -2, ymax: 4,
  xlabel: "x", ylabel: "y",
  xstep: 1, ystep: 1,
  scale: 1cm,
  ticks: true,
) = {
  cetz.canvas(length: scale, {
    import cetz.draw: *
    // Trục
    line((xmin, 0), (xmax, 0), mark: (end: ">"), stroke: 1.2pt + black)
    line((0, ymin), (0, ymax), mark: (end: ">"), stroke: 1.2pt + black)
    content((xmax - 0.4, 0.35), $#xlabel$)
    content((0.35, ymax - 0.3), $#ylabel$)
    content((-0.25, -0.25), $O$)
    // Tick marks
    if ticks {
      for x in range(xmin + 1, xmax) {
        if x != 0 {
          line((x, -0.15), (x, 0.15), stroke: 0.5pt + _ge-gray)
          content((x, -0.4), text(size: 7pt)[#x])
        }
      }
      for y in range(ymin + 1, ymax) {
        if y != 0 {
          line((-0.15, y), (0.15, y), stroke: 0.5pt + _ge-gray)
          content((-0.5, y - 0.1), text(size: 7pt)[#y])
        }
      }
    }
  })
}

// ── Đồ thị hàm số (plot từ danh sách điểm) ──────────────
#let plot(
  points,
  xmin: auto, xmax: auto, ymin: auto, ymax: auto,
  stroke-color: _ge-blue,
  stroke-width: 1.3pt,
  scale: 1cm,
) = {
  cetz.canvas(length: scale, {
    import cetz.draw: *
    if xmin != auto and xmax != auto and ymin != auto and ymax != auto {
      line((xmin, 0), (xmax, 0), mark: (end: ">"), stroke: 1pt + black)
      line((0, ymin), (0, ymax), mark: (end: ">"), stroke: 1pt + black)
      content((xmax - 0.4, 0.35), $x$)
      content((0.35, ymax - 0.3), $y$)
      content((-0.25, -0.25), $O$)
    }
    line(..points, stroke: stroke-width + stroke-color)
  })
}

// ── Parabol y = ax² + bx + c ────────────────────────────
#let parabola(
  a: 1, b: 0, c: 0,
  xmin: -3, xmax: 3,
  ymin: auto, ymax: auto,
  npts: 80,
  accent: _ge-blue,
  show-vertex: false,
  show-roots: false,
  scale: 1cm,
) = {
  cetz.canvas(length: scale, {
    import cetz.draw: *
    let dx = (xmax - xmin) / npts
    let pts = ()
    let yvals = ()
    for i in range(npts + 1) {
      let x = xmin + i * dx
      let y = a * x * x + b * x + c
      pts.push((x, y))
      yvals.push(y)
    }
    let mymin = if ymin == auto { calc.min(..yvals) - 0.5 } else { ymin }
    let mymax = if ymax == auto { calc.max(..yvals) + 0.5 } else { ymax }
    line((xmin, 0), (xmax, 0), mark: (end: ">"), stroke: 1pt + black)
    line((0, mymin), (0, mymax), mark: (end: ">"), stroke: 1pt + black)
    content((xmax - 0.4, 0.35), $x$)
    content((0.35, mymax - 0.3), $y$)
    content((-0.25, -0.25), $O$)
    line(..pts, stroke: 1.2pt + accent)
    // Đỉnh
    if show-vertex {
      let vx = -b / (2 * a)
      let vy = a * vx * vx + b * vx + c
      circle((vx, vy), radius: 3pt, fill: _ge-red)
      content((vx + 0.25, vy + 0.3), text(size: 8pt, fill: _ge-red)[đỉnh])
    }
    // Nghiệm
    if show-roots {
      let delta = b * b - 4 * a * c
      if delta >= 0 {
        let sd = calc.sqrt(delta)
        let r1 = (-b - sd) / (2 * a)
        let r2 = (-b + sd) / (2 * a)
        circle((r1, 0), radius: 3pt, fill: _ge-green)
        circle((r2, 0), radius: 3pt, fill: _ge-green)
      }
    }
  })
}

// ── Đường thẳng qua 2 điểm ─────────────────────────────
#let line-through(A, B, accent: _ge-blue, scale: 1cm) = {
  cetz.canvas(length: scale, {
    import cetz.draw: *
    let xmin = calc.min(A.at(0), B.at(0)) - 1
    let xmax = calc.max(A.at(0), B.at(0)) + 1
    let ymin = calc.min(A.at(1), B.at(1)) - 1
    let ymax = calc.max(A.at(1), B.at(1)) + 1
    axis-xy(xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax, scale: scale)
    line(A, B, stroke: 1.2pt + accent)
    circle(A, radius: 3pt, fill: black)
    circle(B, radius: 3pt, fill: black)
  })
}

// ── Nửa đường tròn (trên / dưới) ───────────────────────
#let semicircle(
  center: (0, 0), radius: 2,
  above: true,
  accent: _ge-blue,
  scale: 1cm,
) = {
  cetz.canvas(length: scale, {
    import cetz.draw: *
    let (cx, cy) = center
    let r = radius
    let n = 60
    let pts = ()
    for i in range(n + 1) {
      let angle = if above { calc.pi * i / n } else { calc.pi * (n - i) / n }
      let x = cx + r * calc.cos(angle)
      let y = if above { cy + r * calc.sin(angle) } else { cy - r * calc.sin(angle) }
      pts.push((x, y))
    }
    line(..pts, stroke: 1.2pt + accent)
    line((cx - r, cy), (cx + r, cy), stroke: 0.5pt + _ge-gray + dotted)
    circle((cx, cy), radius: 2.5pt, fill: black)
  })
}

// ── Điểm ────────────────────────────────────────────────
#let point(p, label: none, fill: black, radius: 2.5pt, scale: 0.5cm) = {
  cetz.canvas(length: scale, {
    import cetz.draw: *
    circle(p, radius: radius, fill: fill)
    if label != none {
      let (x, y) = p
      let (dx, dy) = (0.25, 0.25)
      content((x + dx, y + dy), text(size: 8pt)[#label])
    }
  })
}

// ── Đoạn thẳng ──────────────────────────────────────────
#let seg(A, B, stroke: 1.2pt + black, arrow: false, scale: 0.7cm) = {
  cetz.canvas(length: scale, {
    import cetz.draw: *
    let mark = if arrow { (end: ">") } else { none }
    line(A, B, stroke: stroke, mark: mark)
  })
}

// ── Elip ngang ──────────────────────────────────────────
#let ellipse-h(
  center: (0, 0), a: 3, b: 2,
  accent: _ge-blue,
  scale: 1cm,
) = {
  cetz.canvas(length: scale, {
    import cetz.draw: *
    let (cx, cy) = center
    let n = 100
    let pts = ()
    for i in range(n + 1) {
      let t = 2 * calc.pi * i / n
      pts.push((cx + a * calc.cos(t), cy + b * calc.sin(t)))
    }
    line(..pts, stroke: 1.2pt + accent)
    circle((cx, cy), radius: 2.5pt, fill: black)
    circle((cx + a, cy), radius: 2pt, fill: _ge-red)
    circle((cx - a, cy), radius: 2pt, fill: _ge-red)
    circle((cx, cy + b), radius: 2pt, fill: _ge-green)
    circle((cx, cy - b), radius: 2pt, fill: _ge-green)
  })
}
