// =========================================================
// SANG-EXAM.TYP v6.0 — Engine thi THPT chuẩn ex_test.sty
// =========================================================

// ── Beamer-mode flag (set by sang-beamer.typ to suppress print-only elements) ──
#let _beamer-mode = state("_beamer-mode", false)
#let set-beamer-mode() = { _beamer-mode.update(true) }

// ── Font viết tay toàn cục ────────────────────────────────
// Được set bởi thpt-school-exam(handwriting-font: ...)
// Dùng #hw[text] ở bất kỳ đâu trong file .typ
#let _hw-font = state("_hw-font", none)
#let _hw-size = state("_hw-size", 1em)
#let hw(it) = context {
  let f = _hw-font.get()
  if f != none {
    text(font: f, size: _hw-size.get())[#it]
  } else {
    text(style: "italic")[#it]
  }
}

// ── Màu ──────────────────────────────────────────────────
#let palette = (
  ink: black,
  muted: rgb("#555"),
  border: rgb("#bbb"),
  accent: rgb("#0057b8"),
  correct: rgb("#1a7a2e"),
  wrong: rgb("#cc2200"),
  sol-bg: rgb("#f0f6ff"),
)
#let classic = (
  blue: rgb("#0057b8"),
  emerald: rgb("#1a7a2e"),
  crimson: rgb("#cc2200"),
  ink: black,
)

// ── sang-setup: wrapper đặt show rules ───────────────────
// Dùng: #show: sang-setup
//       #show: sang-setup.with(math-color: accent)
#let sang-setup(body, math-color: black) = {
  // Chỉ phóng riêng phân số; giữ baseline tự nhiên của phương trình inline.
  show math.frac: math.display
  show math.equation: set text(fill: math-color)

  // Tự động chuyển C, A, P (những chữ số gán sub/sup) thành chữ đứng để in đúng C_n^k
  show math.attach: it => {
    let f = it.base.fields()
    if "text" in f and f.text in ("C", "A", "P") {
      return math.attach(math.upright(f.text), t: it.t, b: it.b, tl: it.tl, bl: it.bl, tr: it.tr, br: it.br)
    }
    it
  }

  show list: it => {
    let any-frac = it.children.any(item => {
      let r = repr(item.body)
      r.contains("frac") and not r.contains("list(")
    })
    if any-frac {
      {
        set list(spacing: 2.8em)
        it
      }
    } else { it }
  }
  body
}

// ── Helpers ───────────────────────────────────────────────
#let True(body) = (body: body, correct: true)
#let False(body) = (body: body, correct: false)

// ═══════════════════════════════════════════════════════════
// HỘP SƯ PHẠM — 5 kiểu hình thức khác nhau
// ═══════════════════════════════════════════════════════════
//
// ① BANNER   — thanh tiêu đề màu trên cùng (ppgiai, lythuyet)
// ② ALERT    — viền trái 6pt + all-around thin border (luuy)
// ③ PILL     — full border 2pt + góc tròn 10pt, tiêu đề inline (meo)
// ④ DASHED   — viền chấm-chấm + dải phân cách (nhanxet, note)
// ⑤ THEOREM  — đường kẻ trên 2.5pt + dưới 1pt (dn, dl, tc, bode)

// ① BANNER ─────────────────────────────────────────────────
#let _panel-banner(body, title, hdr-fill, body-fill) = block(
  width: 100%,
  below: 0.85em,
  radius: 5pt,
  clip: true,
)[
  #block(width: 100%, fill: hdr-fill, inset: (x: 12pt, y: 6pt))[
    #text(fill: white, weight: "bold", size: 10.5pt)[#title]
  ]
  #block(width: 100%, fill: body-fill, inset: (x: 13pt, y: 9pt))[
    #set text(fill: luma(30))
    #body
  ]
]

// ② ALERT ──────────────────────────────────────────────────
#let _panel-alert(body, title, accent, fill) = block(
  width: 100%,
  below: 0.85em,
  stroke: (left: 6pt + accent, rest: 0.8pt + accent.lighten(50%)),
  inset: (left: 14pt, right: 12pt, top: 8pt, bottom: 8pt),
  radius: (right: 5pt),
  fill: fill,
)[
  #text(weight: "bold", fill: accent)[#title]
  #v(0.25em)
  #set text(fill: luma(30))
  #body
]

// ③ PILL ───────────────────────────────────────────────────
#let _panel-pill(body, title, accent, fill) = block(
  width: 100%,
  below: 0.85em,
  stroke: 2pt + accent,
  inset: (x: 14pt, y: 9pt),
  radius: 10pt,
  fill: fill,
)[
  #set text(fill: luma(30))
  #text(weight: "bold", fill: accent)[#title] #h(3pt) #body
]

// ④ DASHED ─────────────────────────────────────────────────
#let _panel-dashed(body, title, accent, fill) = block(
  width: 100%,
  below: 0.85em,
  stroke: (paint: accent, thickness: 1pt, dash: "dashed"),
  inset: (x: 12pt, y: 8pt),
  radius: 4pt,
  fill: fill,
)[
  #text(weight: "bold", fill: accent)[#title]
  #v(0.15em)
  #line(length: 100%, stroke: (paint: accent, thickness: 0.5pt, dash: "dotted"))
  #v(0.2em)
  #set text(fill: luma(30))
  #body
]

// ⑤ THEOREM ────────────────────────────────────────────────
#let _panel-theorem(body, title, accent, fill) = block(
  width: 100%,
  below: 0.85em,
)[
  #line(length: 100%, stroke: 2.5pt + accent)
  #block(
    width: 100%,
    fill: fill,
    inset: (x: 13pt, top: 7pt, bottom: 9pt),
  )[
    #set text(fill: luma(30))
    #text(weight: "bold", fill: accent, style: "italic")[#title.] #h(4pt) #body
  ]
  #line(length: 100%, stroke: 1pt + accent.lighten(35%))
]

// ── Hộp lời giải ──────────────────────────────────────────

// 💡 Phương pháp giải — Banner xanh lá
#let ppgiai(body, title: [💡 Phương pháp giải], ..args) = _panel-banner(
  body,
  title,
  rgb("#1a7a2e"),
  rgb("#eef6ed"),
)

// ⚠ Lưu ý — Alert cam, viền trái 6pt
#let luuy(body, title: [⚠ Lưu ý], ..args) = _panel-alert(
  body,
  title,
  rgb("#e65100"),
  rgb("#fff4e5"),
)

// 🚀 Mẹo nhanh — Pill tròn hồng, tiêu đề inline
#let meo(body, title: [🚀 Mẹo nhanh], ..args) = _panel-pill(
  body,
  title,
  rgb("#c2185b"),
  rgb("#fce4ec"),
)

// 📝 Nhận xét — Dashed tím, có gạch phân cách
#let nhanxet(body, title: [📝 Nhận xét], ..args) = _panel-dashed(
  body,
  title,
  rgb("#6b21a8"),
  rgb("#faf5ff"),
)

#let giainhanh(body, title: [🚀 Mẹo nhanh], ..args) = meo(body, title: title)

// 📖 Lý thuyết — Banner xanh dương
#let lythuyet(body, title: [📖 Lý thuyết], ..args) = _panel-banner(
  body,
  title,
  rgb("#1553a0"),
  rgb("#eef4ff"),
)

// Ghi chú — Dashed teal
#let note(body, title: [Ghi chú], ..args) = _panel-dashed(
  body,
  title,
  rgb("#0f766e"),
  rgb("#f0fdfa"),
)

// ── Hộp học thuật — Kiểu Theorem (⑤) ─────────────────────

// Định nghĩa — đường kẻ xanh dương
#let dn(body, title: [Định nghĩa], ..args) = _panel-theorem(
  body,
  title,
  rgb("#1d4ed8"),
  rgb("#eff6ff"),
)

// Định lý — đường kẻ đỏ đậm
#let dl(body, title: [Định lý], ..args) = _panel-theorem(
  body,
  title,
  rgb("#b91c1c"),
  rgb("#fff1f2"),
)

// Tính chất — đường kẻ xanh lá
#let tc(body, title: [Tính chất], ..args) = _panel-theorem(
  body,
  title,
  rgb("#15803d"),
  rgb("#f0fdf4"),
)

// Bổ đề — đường kẻ cam đậm
#let bode(body, title: [Bổ đề], ..args) = _panel-theorem(
  body,
  title,
  rgb("#c2410c"),
  rgb("#fff7ed"),
)

// ── Bộ đếm & state ────────────────────────────────────────
#let _q-cnt = counter("se-q")
#let _global-q-cnt = counter("se-g-q")
#let _part-cnt = counter("se-p-cnt")
#let _mcq-meta = state("se-mcq", ())
#let _tf-meta = state("se-tf", ())
#let _sh-meta = state("se-sh", ())
#let _tl-meta = state("se-tl", ())

// - #resetexamstate() -> xoá đáp án đã gom, reset số câu và số phần về đầu đề mới
#let resetexamstate(question-start: 1, part-start: 1) = {
  let current-question = if question-start > 0 { question-start - 1 } else { 0 }
  let current-part = if part-start > 0 { part-start - 1 } else { 0 }
  [
    #_q-cnt.update(current-question)
    #_global-q-cnt.update(current-question)
    #_part-cnt.update(current-part)
    #_mcq-meta.update(_ => ())
    #_tf-meta.update(_ => ())
    #_sh-meta.update(_ => ())
    #_tl-meta.update(_ => ())
    #metadata((kind: "question", current: current-question)) <se-q-reset>
  ]
}

#let _q-marker = <se-q-marker>
#let _q-reset-marker = <se-q-reset>

#let _resolve-loigiai(loigiai, args) = {
  if loigiai != none { loigiai } else { args.named().at("solution", default: none) }
}

// Helper: scale fig so its rendered width = fig-width × available width, then center.
// Scales geometry + labels proportionally (uniform scale). To keep label size fixed
// while changing figure geometry size, adjust `length:` inside cetz.canvas() instead.
#let _fig-scaled-center(fig, fig-width) = layout(size => context {
  let sz = measure(fig)
  if sz.width > 0pt {
    let target-w = size.width * fig-width
    let r = target-w / sz.width
    align(center, scale(fig, x: r * 100%, y: r * 100%, origin: top + center, reflow: true))
  } else {
    align(center, fig)
  }
})

#let _question-frame(
  body,
  below: 1em,
  boxed: false,
  fill: white,
  stroke: 0.6pt + palette.border,
  inset: (x: 10pt, y: 8pt),
  radius: 4pt,
) = {
  if boxed {
    block(width: 100%, below: below, fill: fill, stroke: stroke, inset: inset, radius: radius)[#body]
  } else {
    block(width: 100%, below: below)[#body]
  }
}

#let _next-question-num(num: auto) = {
  let resets = query(selector(_q-reset-marker).before(here()))
  let resolved = if num == auto {
    if resets.len() == 0 {
      query(selector(_q-marker).before(here())).len() + 1
    } else {
      let reset = resets.last()
      let base = reset.value.current
      let seen = query(selector(_q-marker).after(reset.location()).before(here())).len()
      base + seen + 1
    }
  } else {
    num
  }
  (
    num: resolved,
    markers: [
      #if num != auto {
        [#metadata((kind: "question", current: num - 1)) <se-q-reset>]
      }
      #metadata("question") <se-q-marker>
      #counter("se-step").update(0)
    ],
  )
}

// ── Điều khiển bộ đếm ────────────────────────────────────
// - #resetcau()      -> câu kế tiếp là Câu 1
// - #setcau(13)      -> câu kế tiếp là Câu 13
// - #resetphan()     -> phần kế tiếp là PHẦN I
// - #setphan(3)      -> phần kế tiếp là PHẦN III
// - #exam-part(..., reset-counter: true) -> reset số câu về 1 ngay đầu phần đó
#let setcounter(env, start) = {
  let current = if start > 0 { start - 1 } else { 0 }
  let name = if type(env) == str { lower(env) } else { env }
  if ("cau", "question", "tn", "ds", "tln", "tl").contains(name) {
    [
      #metadata((kind: "question", current: current)) <se-q-reset>
    ]
  } else if ("part", "phan").contains(name) {
    [#_part-cnt.update(current)]
  } else {
    none
  }
}

#let resetcounter(env, start: 1) = setcounter(env, start)
#let setcau(start) = setcounter("cau", start)
#let resetcau(start: 1) = resetcounter("cau", start: start)
#let setphan(start) = setcounter("part", start)
#let resetphan(start: 1) = resetcounter("part", start: start)

// ── Kẻ dòng chấm cho HS ───────────────────────────────────
#let draw-lines(n) = {
  v(0.2em)
  for i in range(n) {
    v(0.6em)
    line(length: 100%, stroke: (paint: rgb("#b0b0b0"), thickness: 0.6pt, dash: "dotted"))
    v(0.8em)
  }
}

// ── Ô ly và điền khuyết ──────────────────────────────────
#let dien-khuyet(lines: 4) = {
  v(0.5em)
  for _ in range(lines) {
    box(width: 100%, stroke: (bottom: 0.5pt + luma(150), rest: none), height: 1.5em)
    v(0em)
  }
}

#let o-ly(rows: 5) = {
  v(0.5em)
  let cell-content = []
  let grid-content = grid(
    columns: (1.5em,) * 25,
    rows: (1.5em,) * rows,
    stroke: 0.5pt + luma(200),
    ..([#cell-content],) * 25 * rows
  )
  align(center, grid-content)
}

// ─────────────────────────────────────────────────────────
// CÁC BƯỚC GIẢI CHI TIẾT (có tự động đổi màu)
// ─────────────────────────────────────────────────────────
#let _step-colors = (
  rgb("#1565c0"),
  rgb("#e65100"),
  rgb("#2e7d32"),
  rgb("#6a1b9a"),
  rgb("#00838f"),
  rgb("#c62828"),
)
#let _step-cnt = counter("se-step")
#let _step-reveal-config = state("se-step-reveal-config", (before_nonfirst: none))
#let configure-step-reveal(before_nonfirst: none) = [
  #_step-reveal-config.update((before_nonfirst: before_nonfirst))
]
#let step(body, color: auto, before_nonfirst: auto) = {
  _step-cnt.step()
  context {
    let n = _step-cnt.get().first()
    let c = _step-colors.at(calc.rem(n - 1, _step-colors.len()))
    let text-color = if color != auto { color } else { c.darken(10%) }
    let border-color = if color != auto { color } else { c }
    let reveal = if before_nonfirst != auto {
      before_nonfirst
    } else if n > 1 {
      _step-reveal-config.get().at("before_nonfirst", default: none)
    } else {
      none
    }
    let step-block = block(
      width: 100%,
      stroke: (left: 1.5pt + border-color),
      inset: (left: 8pt, right: 0pt, top: 1.5pt, bottom: 1.5pt),
      below: 0.3em,
      above: 0.3em,
    )[
      #text(fill: text-color, weight: "bold")[Bước #n.] #h(0.3em) #body
    ]
    if reveal == none {
      step-block
    } else {
      [#reveal #step-block]
    }
  }
}
#let reset-step() = [#_step-cnt.update(0)]

// ── Lời giải block ────────────────────────────────────────
#let _sol(s, a) = block(
  width: 100%,
  fill: palette.sol-bg,
  stroke: (left: 3pt + a),
  inset: (left: 10pt, right: 8pt, top: 6pt, bottom: 6pt),
  radius: (right: 4pt),
)[#reset-step()#text(weight: "bold", fill: a)[Lời giải.] #s]

#let _q-label(prefix, num, accent, style: "plain") = {
  if style == "pill" {
    box(
      fill: accent.lighten(82%),
      stroke: 0.7pt + accent.lighten(35%),
      inset: (x: 7pt, y: 2pt),
      radius: 999pt,
      text(weight: "bold", fill: accent)[#prefix #num.]
    )
    h(4pt)
  } else if style == "badge" {
    box(
      fill: accent,
      inset: (x: 7pt, y: 2.5pt),
      radius: 4pt,
      text(weight: "bold", fill: white)[#prefix #num.]
    )
    h(5pt)
  } else if style == "solid-pill" {
    box(
      fill: accent,
      inset: (x: 8pt, y: 2.3pt),
      radius: 999pt,
      text(weight: "bold", fill: white)[#prefix #num]
    )
    text(weight: "bold", fill: accent)[. ]
  } else if style == "underline" {
    box(
      stroke: (bottom: 1.1pt + accent),
      inset: (bottom: 1.5pt),
      text(weight: "bold", fill: accent)[#prefix #num]
    )
    text(weight: "bold", fill: accent)[. ]
  } else if style == "ribbon" {
    box(width: 3pt, height: 1.25em, fill: accent, radius: 1pt)
    h(4pt)
    text(weight: "bold", fill: accent)[#prefix #num.]
    h(3pt)
  } else if style == "flag" {
    box(
      fill: accent,
      inset: (left: 7pt, right: 10pt, y: 2pt),
      radius: (left: 3pt),
      text(weight: "bold", fill: white)[#prefix #num]
    )
    text(weight: "bold", fill: accent)[. ]
  } else if style == "spark" {
    box(
      stroke: 0.8pt + accent,
      fill: accent.lighten(88%),
      inset: (x: 6pt, y: 2pt),
      radius: 3pt,
      text(weight: "bold", fill: accent)[#prefix #num]
    )
    text(weight: "bold", fill: accent)[. ]
  } else {
    text(weight: "bold", fill: accent)[#prefix #num. ]
  }
}

#let _option-label(label, col, style: "plain") = {
  let content = text(size: 0.86em, weight: "bold", fill: col)[#label]
  let white-content = text(size: 0.86em, weight: "bold", fill: white)[#label]
  let poly-label(vertices, fill: col.lighten(88%), stroke: 0.75pt + col, label-body: content, angle: 0deg) = box(width: 1.45em, height: 1.45em)[
    #place(center + horizon)[
      #rotate(angle)[
        #polygon.regular(
          vertices: vertices,
          size: 1.35em,
          fill: fill,
          stroke: stroke,
        )
      ]
    ]
    #place(center + horizon)[#label-body]
  ]
  if style == "circled" or style == "circle" {
    box(stroke: 0.75pt + col, radius: 50%, width: 1.35em, height: 1.35em, align(center + horizon)[#content])
  } else if style == "double-circle" {
    box(stroke: 1.25pt + col, radius: 50%, inset: 1.1pt)[
      #box(stroke: 0.45pt + col.lighten(35%), radius: 50%, width: 1.2em, height: 1.2em, align(center + horizon)[#content])
    ]
  } else if style == "solid-circle" {
    box(fill: col, radius: 50%, width: 1.35em, height: 1.35em, align(center + horizon)[#text(size: 0.86em, weight: "bold", fill: white)[#label]])
  } else if style == "square" {
    box(stroke: 0.75pt + col, width: 1.28em, height: 1.28em, align(center + horizon)[#content])
  } else if style == "solid-square" {
    box(fill: col, width: 1.28em, height: 1.28em, align(center + horizon)[#white-content])
  } else if style == "rounded-square" {
    box(stroke: 0.75pt + col, fill: col.lighten(90%), radius: 3pt, width: 1.35em, height: 1.35em, align(center + horizon)[#content])
  } else if style == "diamond" {
    poly-label(4, angle: 45deg)
  } else if style == "solid-diamond" {
    poly-label(4, fill: col, stroke: 0.75pt + col, label-body: white-content, angle: 45deg)
  } else if style == "triangle" {
    poly-label(3)
  } else if style == "solid-triangle" {
    poly-label(3, fill: col, stroke: 0.75pt + col, label-body: white-content)
  } else if style == "pentagon" {
    poly-label(5)
  } else if style == "solid-pentagon" {
    poly-label(5, fill: col, stroke: 0.75pt + col, label-body: white-content)
  } else if style == "hexagon" {
    poly-label(6)
  } else if style == "solid-hexagon" {
    poly-label(6, fill: col, stroke: 0.75pt + col, label-body: white-content)
  } else if style == "badge" {
    box(fill: col.lighten(85%), stroke: 0.55pt + col, inset: (x: 5pt, y: 1.2pt), radius: 3pt)[#content]
  } else {
    text(weight: "bold", fill: col)[#label.]
  }
}

#let _draft-box(lines: 5, title: [Nháp], accent: palette.accent) = block(
  width: 100%,
  fill: luma(252),
  stroke: (paint: accent.lighten(45%), thickness: 0.7pt, dash: "dotted"),
  inset: (x: 7pt, y: 6pt),
  radius: 4pt,
)[
  #text(size: 8.5pt, weight: "bold", fill: accent)[#title]
  #v(0.35em)
  #for _ in range(lines) {
    line(length: 100%, stroke: 0.35pt + luma(210))
    v(0.72em)
  }
]

#let _maybe-draft(body, draft: false, draft-width: 30%, draft-lines: 5, draft-title: [Nháp], accent: palette.accent) = {
  if draft {
    grid(
      columns: (1fr, draft-width),
      column-gutter: 10pt,
      align: (left + top, left + top),
      body,
      _draft-box(lines: draft-lines, title: draft-title, accent: accent),
    )
  } else {
    body
  }
}

// ─────────────────────────────────────────────────────────
// MCQ
// Auto-col: đo text width vs 0.25L / 0.50L (chuẩn ex_test)
// fig: / fig-pos: "right"|"left"|"center" / fig-width: / cols: 0|1|2|4
// opt-fig: true  → 4 options là hình vẽ (cetz canvas…), bỏ qua measure()
// opt-fig-cols:  → số cột khi options là hình (mặc định 2)
// ─────────────────────────────────────────────────────────
#let mcq(
  stem,
  options,
  correct: (),
  loigiai: none,
  mode: "dethi",
  accent: palette.accent,
  fig: none,
  fig-pos: "right",
  fig-width: 35%,
  cols: 0,
  row-gutter: auto,
  opt-fig: false,
  opt-fig-cols: 2,
  opt-style: "plain",
  opt-label-color: auto,
  lines: 0,
  num: auto,
  prefix: "Câu",
  q-label-style: "plain",
  tags: (),
  show-tags: true,
  draft: false,
  draft-width: 30%,
  draft-lines: 5,
  draft-title: [Nháp],
  boxed: false,
  box-fill: white,
  box-stroke: 0.6pt + palette.border,
  box-inset: (x: 10pt, y: 8pt),
  box-radius: 4pt,
  ..args,
) = context {
  let loigiai = _resolve-loigiai(loigiai, args)
  let q-state = _next-question-num(num: num)
  let num = q-state.num
  let labels = ("A", "B", "C", "D", "E", "F")

  let render-label(i, col) = {
    let label-col = if opt-label-color == auto { col } else { opt-label-color }
    _option-label(labels.at(i), label-col, style: opt-style)
  }

  // Tìm đáp án đúng & lưu state
  let ai = -1
  let idx = 0
  for opt in options {
    let ok = if type(opt) == dictionary { opt.at("correct", default: false) } else { correct.contains(idx + 1) }
    if ok { ai = idx }
    idx += 1
  }
  // Mảng text và correct cho từng option
  let opt-texts = options.map(o => if type(o) == dictionary { o.body } else { o })
  let opt-oks = options
    .enumerate()
    .map(((i, o)) => if type(o) == dictionary { o.at("correct", default: false) } else { correct.contains(i + 1) })

  // ── Phát hiện options là hình ────────────────────────────
  // cetz canvas dùng layout() bên trong → measure() sẽ crash.
  // Kiểm tra repr: nếu bất kỳ option nào chứa "layout(" thì coi là hình.
  // Người dùng cũng có thể đặt opt-fig: true để ép chế độ hình.
  let _is-fig = opt-fig or opt-texts.any(t => repr(t).contains("layout("))

  let em-sz = text.size
  let label-width = 1.6 * em-sz
  let label-gap = 0.3 * em-sz
  let option-top-gap = 0.16em
  let option-indent = if _is-fig { 0pt } else { 1.1 * em-sz }

  // Đo inline width và height — BỎ QUA nếu options là hình
  let mw = 0pt
  let max-inline-h = 0pt
  let has-frac = false
  if not _is-fig {
    for t in opt-texts {
      let sz = measure(box[#t])
      if sz.width > mw { mw = sz.width }
      if sz.height > max-inline-h { max-inline-h = sz.height }
      let rt = repr(t)
      if (
        rt.contains("frac(")
          or rt.contains("binom(")
          or rt.contains("integral(")
          or rt.contains("sum(")
          or rt.contains("limits(")
          or rt.contains("mat(")
          or rt.contains("cases(")
          or rt.contains("vec(")
      ) {
        has-frac = true
      }
    }
  }
  let has-tall-math = max-inline-h > 1.45 * em-sz or has-frac
  let option-leading = if has-tall-math { 1.8em } else { 0.95em }

  // ── Render options ──────────────────────────────────────
  let opts-r = if _is-fig {
    // Chế độ hình: thẻ card 2×2, label ở góc trên-trái, hình căn giữa
    let is_arr = type(cols) == array
    let nc = if is_arr { cols.len() } else if cols != 0 { cols } else { opt-fig-cols }
    let grid-cols = if is_arr { cols } else { nc }
    grid(
      columns: grid-cols,
      row-gutter: 8pt,
      column-gutter: 8pt,
      align: left + top,
      ..opt-texts
        .enumerate()
        .map(((i, t)) => {
          let hi = (mode == "loigiai" or mode == "solcolor") and opt-oks.at(i)
          let col = if hi { rgb("#cc2200") } else { black }
          let card-stroke = if hi {
            (paint: col, thickness: 2pt)
          } else {
            0.7pt + luma(180)
          }
          block(
            width: 100%,
            stroke: card-stroke,
            radius: 5pt,
            inset: (x: 8pt, top: 6pt, bottom: 8pt),
            fill: if hi { rgb("#fff5f5") } else { white },
          )[
            #render-label(i, col)
            #v(0.3em)
            #align(center)[#t]
          ]
        })
    )
  } else {
    // Chế độ văn bản / toán — logic cũ
    layout(sz => {
      let lw = sz.width
      let nc = if cols != 0 {
        cols
      } else {
        let chosen = 1
        for candidate in (4, 2) {
          if chosen == 1 {
            let gutter = if candidate == 4 { 11pt } else { 13pt }
            let cell-width = (lw - gutter * (candidate - 1)) / candidate
            let text-width = cell-width - label-width - label-gap
            if text-width > 0pt and mw <= text-width * 0.95 {
              chosen = candidate
            }
          }
        }
        chosen
      }
      let column-gutter = if nc == 1 { 0pt } else if nc == 4 { 11pt } else { 13pt }
      let calc-row-gutter = if row-gutter != auto { row-gutter } else if nc == 4 { 0.45em } else {
        option-leading
      }
      grid(
        columns: if type(cols) == array { cols } else { (1fr,) * nc },
        row-gutter: calc-row-gutter,
        column-gutter: column-gutter,
        align: left + top,
        ..opt-texts
          .enumerate()
          .map(((i, t)) => {
            let hi = (mode == "loigiai" or mode == "solcolor") and opt-oks.at(i)
            let col = if hi { rgb("#cc2200") } else { black }
            // Hanging indent giữ nhãn A/B/C/D cùng baseline với phương án,
            // kể cả khi phương án bắt đầu bằng số mũ hoặc phân số cao.
            par(
              justify: false,
              leading: option-leading,
              hanging-indent: label-width + label-gap,
            )[
              #box(width: label-width)[#render-label(i, col)]#h(label-gap)#text(
                fill: col,
                weight: if hi { "bold" } else { "regular" },
              )[#t]
            ]
          })
      )
    })
  }

  // ── Sinh Tags (Nếu có) ─────────────────────────────────
  let _render-tags = if show-tags and tags.len() > 0 {
    (
      h(1fr)
        + box[
          #for t in tags {
            box(fill: luma(240), inset: (x: 4pt, y: 3pt), radius: 2pt, text(
              size: 0.7em,
              fill: luma(80),
              weight: "bold",
              t,
            ))
            h(2pt)
          }]
    )
  } else { none }

  // Stem row: [Câu N.] [stem] [fig?]
  let q-label = _q-label(prefix, num, accent, style: q-label-style)
  let _stem-w-tags = [#stem #_render-tags]
  let stem-row = if fig != none and (fig-pos == "right" or fig-pos == "left") {
    if fig-pos == "right" {
      grid(
        columns: (1fr, fig-width),
        column-gutter: 14pt,
        align: (left + top, center + top),
        [#q-label #_stem-w-tags], fig,
      )
    } else {
      grid(
        columns: (fig-width, 1fr),
        column-gutter: 14pt,
        align: (center + top, left + top),
        fig, [#q-label #_stem-w-tags],
      )
    }
  } else if fig != none and fig-pos == "center" {
    [#q-label #_stem-w-tags]
    v(0.4em)
    _fig-scaled-center(fig, fig-width)
  } else {
    [#q-label #_stem-w-tags]
  }

  [
    #q-state.markers
    #_mcq-meta.update(m => (
      m
        + (
          (
            num: num,
            id: args.named().at("id", default: none),
            tags: tags,
            ans: if ai >= 0 { labels.at(ai) } else { "?" },
          ),
        )
    ))
    #_question-frame(
      [
        #_maybe-draft(
          [
            #stem-row
            #v(option-top-gap)
            #pad(left: option-indent)[#opts-r]
            #if lines > 0 { draw-lines(lines) }
            #if mode == "loigiai" and loigiai != none {
              v(0.7em)
              _sol(loigiai, accent)
            }
          ],
          draft: draft,
          draft-width: draft-width,
          draft-lines: draft-lines,
          draft-title: draft-title,
          accent: accent,
        )
      ],
      below: 1.05em,
      boxed: boxed,
      fill: box-fill,
      stroke: box-stroke,
      inset: box-inset,
      radius: box-radius,
    )
  ]
}

// ─────────────────────────────────────────────────────────
// TF — True([...]) = đúng, [...] = sai
// Bảng: Phát biểu | □Đ | □S
// ─────────────────────────────────────────────────────────
#let tf(
  stem,
  statements,
  loigiai: none,
  mode: "dethi",
  accent: palette.accent,
  fig: none,
  fig-pos: "right",
  fig-width: 30%,
  ds-style: "table",
  lines: 0,
  num: auto,
  prefix: "Câu",
  q-label-style: "plain",
  tags: (),
  show-tags: true,
  draft: false,
  draft-width: 30%,
  draft-lines: 5,
  draft-title: [Nháp],
  boxed: false,
  box-fill: white,
  box-stroke: 0.6pt + palette.border,
  box-inset: (x: 10pt, y: 8pt),
  box-radius: 4pt,
  ..args,
) = context {
  let loigiai = _resolve-loigiai(loigiai, args)
  let q-state = _next-question-num(num: num)
  let num = q-state.num
  let vis-ans = mode != "dethi"
  let alpha = ("a", "b", "c", "d", "e", "f")

  // Lưu state TF: mảng Đ/S cho từng phát biểu
  let tf-row = statements.map(s => if type(s) == dictionary and s.at("correct", default: false) { "Đ" } else { "S" })

  // Xây dựng bảng
  let rows = statements
    .enumerate()
    .map(((i, s)) => {
      let ok = if type(s) == dictionary { s.at("correct", default: false) } else { false }
      let txt = if type(s) == dictionary { s.body } else { s }
      let md = if vis-ans and ok { text(fill: palette.correct, weight: "bold")[✓] } else { none }
      let ms = if vis-ans and not ok { text(fill: palette.wrong, weight: "bold")[✓] } else { none }
      let fd = if vis-ans and ok { palette.correct.lighten(80%) } else { white }
      let fs = if vis-ans and not ok { palette.wrong.lighten(85%) } else { white }
      (
        pad(x: 6pt, y: 4pt)[#text(weight: "bold")[#alpha.at(i))] #h(3pt) #txt],
        align(center + horizon)[
          #box(width: 1.8em, height: 1.8em, stroke: 0.6pt + palette.border, fill: fd, align(center + horizon)[#md])
        ],
        align(center + horizon)[
          #box(width: 1.8em, height: 1.8em, stroke: 0.6pt + palette.border, fill: fs, align(center + horizon)[#ms])
        ],
      )
    })
    .flatten()

  let tbl = table(
    columns: (1fr, auto, auto),
    stroke: 0.5pt + palette.border,
    align: (left + horizon, center + horizon, center + horizon),
    table.cell(fill: accent, align: center + horizon, pad(left: 6pt, y: 5pt)[#text(
      fill: white,
      weight: "bold",
    )[Phát biểu]]),
    table.cell(fill: accent, align: center + horizon, pad(x: 8pt, y: 5pt)[#text(fill: white, weight: "bold")[Đ]]),
    table.cell(fill: accent, align: center + horizon, pad(x: 8pt, y: 5pt)[#text(fill: white, weight: "bold")[S]]),
    ..rows,
  )

  // ── Sinh Tags (Nếu có) ─────────────────────────────────
  let _render-tags = if show-tags and tags.len() > 0 {
    (
      h(1fr)
        + box[
          #for t in tags {
            box(fill: luma(240), inset: (x: 4pt, y: 3pt), radius: 2pt, text(
              size: 0.7em,
              fill: luma(80),
              weight: "bold",
              t,
            ))
            h(2pt)
          }]
    )
  } else { none }

  let q-label = _q-label(prefix, num, accent, style: q-label-style)
  let _stem-w-tags = [#stem #_render-tags]
  let stem-row = if fig != none and (fig-pos == "right" or fig-pos == "left") {
    if fig-pos == "right" {
      grid(
        columns: (1fr, fig-width),
        column-gutter: 14pt,
        align: (left + top, center + top),
        [#q-label #_stem-w-tags], fig,
      )
    } else {
      grid(
        columns: (fig-width, 1fr),
        column-gutter: 14pt,
        align: (center + top, left + top),
        fig, [#q-label #_stem-w-tags],
      )
    }
  } else if fig != none and fig-pos == "center" {
    [#q-label #_stem-w-tags]
    v(0.4em)
    _fig-scaled-center(fig, fig-width)
  } else {
    [#q-label #_stem-w-tags]
  }

  [
    #q-state.markers
    #_tf-meta.update(m => m + ((num: num, id: args.named().at("id", default: none), tags: tags, ans: tf-row),))
    #_question-frame(
      [
        #_maybe-draft(
          [
            #stem-row
            #v(0.6em)
            #pad(left: 1.5em)[#tbl]
            #if lines > 0 { draw-lines(lines) }
            #if mode == "loigiai" and loigiai != none {
              v(0.7em)
              _sol(loigiai, accent)
            }
          ],
          draft: draft,
          draft-width: draft-width,
          draft-lines: draft-lines,
          draft-title: draft-title,
          accent: accent,
        )
      ],
      below: 1.4em,
      boxed: boxed,
      fill: box-fill,
      stroke: box-stroke,
      inset: box-inset,
      radius: box-radius,
    )
  ]
}
#let hoac(..args) = math.cases(delim: "[", ..args.named(), ..args.pos().map(math.display))
#let heva(..args) = math.cases(delim: "{", ..args.named(), ..args.pos().map(math.display))
// tfrac: phân số cỡ inline — dùng trong math mode: $tfrac(1, 2)$
#let tfrac(a, b) = {
  show math.frac: f => f
  scale(x: 72%, y: 72%, origin: center + horizon, reflow: true, math.inline(math.frac(a, b)))
}
// ── Hệ thống STEP — tô màu từng bước lời giải ─────────────────
// Dùng: #step[Bước...] #step[Bước...] #reset-step()
#let _step-colors = (
  rgb("#1565c0"),
  rgb("#e65100"),
  rgb("#2e7d32"),
  rgb("#6a1b9a"),
  rgb("#00838f"),
  rgb("#c62828"),
)
#let _step-cnt = counter("se-step")
#let _step-reveal-config = state("se-step-reveal-config", (before_nonfirst: none))
#let configure-step-reveal(before_nonfirst: none) = [
  #_step-reveal-config.update((before_nonfirst: before_nonfirst))
]
#let step(body, color: auto, before_nonfirst: auto) = {
  _step-cnt.step()
  context {
    let n = _step-cnt.get().first()
    let c = _step-colors.at(calc.rem(n - 1, _step-colors.len()))
    let text-color = if color != auto { color } else { c.darken(10%) }
    let border-color = if color != auto { color } else { c }
    let reveal = if before_nonfirst != auto {
      before_nonfirst
    } else if n > 1 {
      _step-reveal-config.get().at("before_nonfirst", default: none)
    } else {
      none
    }
    let step-block = block(
      width: 100%,
      stroke: (left: 1.5pt + border-color),
      inset: (left: 8pt, right: 0pt, top: 1.5pt, bottom: 1.5pt),
      below: 0.3em,
      above: 0.3em,
    )[
      #text(fill: text-color, weight: "bold")[Bước #n.] #h(0.3em) #body
    ]
    if reveal == none {
      step-block
    } else {
      [#reveal #step-block]
    }
  }
}
#let reset-step() = [#_step-cnt.update(0)]
// ─────────────────────────────────────────────────────────
// SHORT — 4 ô trống / hiện đáp án
// ─────────────────────────────────────────────────────────
#let short(
  stem,
  answer,
  loigiai: none,
  mode: "dethi",
  accent: palette.accent,
  fig: none,
  fig-pos: "right",
  fig-width: 30%,
  show-boxes: true,
  lines: 0,
  num: auto,
  prefix: "Câu",
  q-label-style: "plain",
  tags: (),
  show-tags: true,
  draft: false,
  draft-width: 30%,
  draft-lines: 5,
  draft-title: [Nháp],
  box-count: 4,
  boxed: false,
  box-fill: white,
  box-stroke: 0.6pt + palette.border,
  box-inset: (x: 10pt, y: 8pt),
  box-radius: 4pt,
  ..args,
) = context {
  let loigiai = _resolve-loigiai(loigiai, args)
  let q-state = _next-question-num(num: num)
  let num = q-state.num

  let widget = if mode == "dethi" {
    stack(dir: ltr, spacing: 3pt, ..range(box-count).map(_ => box(width: 1.9em, height: 1.9em, stroke: 0.7pt + black)))
  } else {
    box(fill: palette.correct.lighten(85%), stroke: 1pt + palette.correct, inset: (x: 10pt, y: 3pt), radius: 3pt)[
      #text(weight: "bold", fill: palette.correct, size: 1.05em)[#answer]
    ]
  }

  // ── Sinh Tags (Nếu có) ─────────────────────────────────
  let _render-tags = if show-tags and tags.len() > 0 {
    (
      h(1fr)
        + box[
          #for t in tags {
            box(fill: luma(240), inset: (x: 4pt, y: 3pt), radius: 2pt, text(
              size: 0.7em,
              fill: luma(80),
              weight: "bold",
              t,
            ))
            h(2pt)
          }]
    )
  } else { none }

  let q-label = _q-label(prefix, num, accent, style: q-label-style)
  let _stem-w-tags = [#stem #_render-tags]
  let stem-row = if fig != none and (fig-pos == "right" or fig-pos == "left") {
    if fig-pos == "right" {
      grid(
        columns: (1fr, fig-width),
        column-gutter: 14pt,
        align: (left + top, center + top),
        [#q-label #_stem-w-tags], fig,
      )
    } else {
      grid(
        columns: (fig-width, 1fr),
        column-gutter: 14pt,
        align: (center + top, left + top),
        fig, [#q-label #_stem-w-tags],
      )
    }
  } else if fig != none and fig-pos == "center" {
    [#q-label #_stem-w-tags]
    v(0.4em)
    _fig-scaled-center(fig, fig-width)
  } else {
    [#q-label #_stem-w-tags]
  }

  [
    #q-state.markers
    #_sh-meta.update(m => m + ((num: num, id: args.named().at("id", default: none), tags: tags, ans: answer),))
    #_question-frame(
      [
        #_maybe-draft(
          [
            #stem-row
            #if show-boxes {
              v(0.6em)
              pad(left: 1.5em)[
                #stack(dir: ltr, spacing: 6pt, text(weight: "bold")[Đáp số:], widget)
              ]
            }
            #if lines > 0 { draw-lines(lines) }
            #if mode == "loigiai" and loigiai != none {
              v(0.7em)
              _sol(loigiai, accent)
            }
          ],
          draft: draft,
          draft-width: draft-width,
          draft-lines: draft-lines,
          draft-title: draft-title,
          accent: accent,
        )
      ],
      below: 1.4em,
      boxed: boxed,
      fill: box-fill,
      stroke: box-stroke,
      inset: box-inset,
      radius: box-radius,
    )
  ]
}

#let tl(
  stem,
  loigiai: none,
  mode: "dethi",
  accent: palette.accent,
  fig: none,
  fig-pos: "right",
  fig-width: 30%,
  lines: 6,
  num: auto,
  prefix: "Câu",
  q-label-style: "plain",
  draft: false,
  draft-width: 30%,
  draft-lines: 6,
  draft-title: [Nháp],
  boxed: false,
  box-fill: white,
  box-stroke: 0.6pt + palette.border,
  box-inset: (x: 10pt, y: 8pt),
  box-radius: 4pt,
  ..args,
) = context {
  let loigiai = _resolve-loigiai(loigiai, args)
  let q-state = _next-question-num(num: num)
  let num = q-state.num

  let q-label = _q-label(prefix, num, accent, style: q-label-style)
  let stem-row = if fig != none and (fig-pos == "right" or fig-pos == "left") {
    if fig-pos == "right" {
      grid(
        columns: (1fr, fig-width),
        column-gutter: 14pt,
        align: (left + top, center + top),
        [#q-label #stem], fig,
      )
    } else {
      grid(
        columns: (fig-width, 1fr),
        column-gutter: 14pt,
        align: (center + top, left + top),
        fig, [#q-label #stem],
      )
    }
  } else if fig != none and fig-pos == "center" {
    [#q-label #stem]
    v(0.4em)
    _fig-scaled-center(fig, fig-width)
  } else {
    [#q-label #stem]
  }

  [
    #q-state.markers
    #_tl-meta.update(m => m + ((num: num, id: args.named().at("id", default: none)),))
    #_question-frame(
      [
        #_maybe-draft(
          [
            #stem-row
            #if lines > 0 { draw-lines(lines) }
            #if mode == "loigiai" and loigiai != none {
              v(0.7em)
              _sol(loigiai, accent)
            }
          ],
          draft: draft,
          draft-width: draft-width,
          draft-lines: draft-lines,
          draft-title: draft-title,
          accent: accent,
        )
      ],
      below: 1.4em,
      boxed: boxed,
      fill: box-fill,
      stroke: box-stroke,
      inset: box-inset,
      radius: box-radius,
    )
  ]
}

#let tn = mcq
#let ds = tf
#let tln = short

// ── exam-mode ─────────────────────────────────────────────
#let exam-mode(
  mode: "dethi",
  accent: palette.accent,
  opt-style: "plain",
  opt-label-color: auto,
  q-label-style: "plain",
  show-tags: true,
  draft: false,
  draft-width: 30%,
  draft-lines: 5,
  boxed: false,
  box-fill: white,
  box-stroke: 0.6pt + palette.border,
) = (
  tn: tn.with(mode: mode, accent: accent, opt-style: opt-style, opt-label-color: opt-label-color, q-label-style: q-label-style, show-tags: show-tags, draft: draft, draft-width: draft-width, draft-lines: draft-lines, boxed: boxed, box-fill: box-fill, box-stroke: box-stroke),
  ds: ds.with(mode: mode, accent: accent, q-label-style: q-label-style, show-tags: show-tags, draft: draft, draft-width: draft-width, draft-lines: draft-lines, boxed: boxed, box-fill: box-fill, box-stroke: box-stroke),
  tln: tln.with(mode: mode, accent: accent, q-label-style: q-label-style, show-tags: show-tags, draft: draft, draft-width: draft-width, draft-lines: draft-lines, boxed: boxed, box-fill: box-fill, box-stroke: box-stroke),
  tl: tl.with(mode: mode, accent: accent, q-label-style: q-label-style, draft: draft, draft-width: draft-width, draft-lines: draft-lines, boxed: boxed, box-fill: box-fill, box-stroke: box-stroke),
  mcq: mcq.with(mode: mode, accent: accent, opt-style: opt-style, opt-label-color: opt-label-color, q-label-style: q-label-style, show-tags: show-tags, draft: draft, draft-width: draft-width, draft-lines: draft-lines, boxed: boxed, box-fill: box-fill, box-stroke: box-stroke),
  tf: tf.with(mode: mode, accent: accent, q-label-style: q-label-style, show-tags: show-tags, draft: draft, draft-width: draft-width, draft-lines: draft-lines, boxed: boxed, box-fill: box-fill, box-stroke: box-stroke),
  short: short.with(mode: mode, accent: accent, q-label-style: q-label-style, show-tags: show-tags, draft: draft, draft-width: draft-width, draft-lines: draft-lines, boxed: boxed, box-fill: box-fill, box-stroke: box-stroke),
)

// ── het (HẾT ĐỀ) ───────────────────────────────────────────
#let het = align(center)[
  #v(2.5em)
  #text(weight: "bold")[----------- HẾT -----------] <end-exam>
  #v(0.4em)
  #text(style: "italic", size: 11pt)[
    Thí sinh không được sử dụng tài liệu. \
    Giám thị không giải thích gì thêm.
  ]
  #v(1.5em)
]

// ── exam-part ─────────────────────────────────────────────
// Mặc định `reset-counter: false` để số câu chạy liên tục toàn đề.
// Nếu muốn một phần bắt đầu lại từ Câu 1, dùng `reset-counter: true`.
#let exam-part(title, count: auto, reset-counter: false) = {
  // In beamer mode: skip print-only section headers
  if sys.inputs.at("beamer", default: "0") == "1" { return }
  [
    #if reset-counter {
      [#metadata((kind: "question", current: 0)) <se-q-reset>]
    }
    #_part-cnt.step()
    #metadata("part") <ep-marker>
    #v(0.9em)
    #block(
      width: 100%,
      fill: rgb("#e8f0fc"),
      stroke: (left: 4pt + palette.accent),
      inset: (left: 10pt, right: 8pt, top: 7pt, bottom: 7pt),
      radius: (right: 4pt),
    )[
      #text(weight: "bold")[#title]
      #context {
        let c = count
        if c == auto {
          let markers = query(<ep-marker>)
          let ends = query(<end-exam>)
          let p-idx = query(selector(<ep-marker>).before(here())).len()
          let current-marker = markers.at(p-idx - 1)

          if p-idx < markers.len() {
            c = query(selector(_q-marker).after(current-marker.location()).before(markers.at(p-idx).location())).len()
          } else if ends.len() > 0 {
            c = query(selector(_q-marker).after(current-marker.location()).before(ends.last().location())).len()
          } else {
            c = query(selector(_q-marker).after(current-marker.location())).len()
          }
        }
        let title-str = repr(title)
        let has-cau = title-str.contains("câu") or title-str.contains("câ u")
        if c > 0 and not has-cau {
          h(1fr)
          text(style: "italic", fill: palette.muted)[(#c câu)]
        }
      }
    ]
    #v(0.5em)
  ]
}

// ─────────────────────────────────────────────────────────
// HEADER — Tiêu đề đề thi (v7 — nhiều tuỳ chọn)
// ─────────────────────────────────────────────────────────
#let thpt-school-exam(
  body,
  department: "BỘ GIÁO DỤC VÀ ĐÀO TẠO",
  school: "SỞ GIÁO DỤC VÀ ĐÀO TẠO",
  exam-title: "THI THỬ THPT QUỐC GIA 2026",
  subject: "TOÁN - LỚP 12",
  duration: "90 phút",
  structure: auto, // auto = tự đếm từ exam-part
  code: "101",
  footer-left: none,
  accent: palette.accent,
  // ── Tuỳ chọn nâng cao ──
  show-topbar: false, // thanh màu accent trên đỉnh trang
  header-border: true, // đường kẻ dưới tiêu đề
  header-font: "Times New Roman",
  body-font: "Times New Roman",
  body-size: 12pt,
  // ── Font viết tay (tuỳ chọn) ──
  // Truyền tên font để dùng #hw[...] trong nội dung
  // Ví dụ: handwriting-font: "HP001 4 hàng"
  //         handwriting-font: "Bradley Hand"
  handwriting-font: none,
  handwriting-size: 1em, // cỡ chữ tương đối so với body-size
  q-style: "bold", // "bold" | "boxed" | "pill"
  q-color: auto, // auto = accent
  watermark: none, // Chữ in chìm phía sau bộ đề
  watermark-opacity: 0.1,
  watermark-angle: -30deg,
  beamer: sys.inputs.at("beamer", default: "0") == "1", // auto-detect via --input beamer=1
) = {
  // In beamer mode: skip all page/header setup, just return body
  if beamer { return body }

  let _q-color = if q-color == auto { accent } else { q-color }

  set page(
    paper: "a4",
    margin: (top: 2cm, bottom: 2cm, x: 1.5cm),
    background: if watermark != none {
      rotate(watermark-angle, text(
        size: 60pt,
        fill: luma(100).transparentize(100% - watermark-opacity * 100%),
        weight: "bold",
      )[#watermark])
    } else { none },
    footer: context {
      set text(size: 9pt, fill: palette.muted)
      line(length: 100%, stroke: 0.4pt + palette.border)
      v(1pt)
      let locs = query(<end-exam>)
      let total = if locs.len() > 0 { locs.last().location().page() } else { counter(page).final().first() }
      grid(
        columns: (1fr, auto),
        align: (left, right),
        if footer-left != none { footer-left } else { [#exam-title — #subject] },
        [Trang #counter(page).display() / #total #if code != "" [— Mã Đề: #code]],
      )
    },
  )
  set text(font: body-font, size: body-size, lang: "vi")
  set par(justify: true, leading: 0.75em)
  show math.frac: math.display

  // ── Kích hoạt font viết tay toàn cục ─────────────────────
  // Hàm #hw[...] đã được export ở đầu sang-exam.typ
  // Chỉ cần update state để hw() đọc đúng font
  _hw-font.update(handwriting-font)
  _hw-size.update(handwriting-size)

  // Thanh màu accent trên đỉnh (tuỳ chọn)
  if show-topbar {
    place(top + left, dx: -1.5cm, dy: -2cm, rect(width: 21cm, height: 5pt, fill: accent))
  }

  // Tự đếm structure nếu = auto
  let struct-content = if structure != auto { structure } else {
    context {
      let mc = _mcq-meta.final().len()
      let tf = _tf-meta.final().len()
      let sh = _sh-meta.final().len()
      let essay = _tl-meta.final().len()
      let parts = ()
      if mc > 0 { parts.push([#mc câu trắc nghiệm]) }
      if tf > 0 { parts.push([#tf đúng/sai]) }
      if sh > 0 { parts.push([#sh trả lời ngắn]) }
      if essay > 0 { parts.push([#essay câu tự luận]) }
      parts.join([, ])
    }
  }

  // Header 2 cột
  v(0.3em)
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    align(center)[
      #set text(font: header-font)
      #text(weight: "bold", size: 12pt)[#department] \
      #text(weight: "bold", size: 12pt, fill: accent)[#school] \
      #v(-3pt) #line(length: 35%, stroke: 1pt + accent) #v(1pt)
      #text(style: "italic", size: 10pt)[
        (Đề thi có #context {
          let locs = query(<end-exam>)
          if locs.len() > 0 { locs.last().location().page() } else { counter(page).final().first() }
        } trang)
      ]
    ],
    align(center)[
      #set text(font: header-font)
      #text(weight: "bold", size: 13.5pt, fill: accent)[#upper(exam-title)] \
      #text(weight: "bold", size: 12pt)[MÔN #upper(subject)] \
      #text(style: "italic", size: 10.5pt)[Thời gian làm bài: #duration] \
      #text(style: "italic", size: 10pt)[(Đề có #struct-content)]
    ],
  )

  v(1.4em)
  grid(
    columns: (1fr, auto),
    column-gutter: 14pt,
    align: (left + bottom, center + bottom),
    {
      set text(size: 11.5pt)
      grid(
        columns: (auto, 1fr),
        row-gutter: 9pt,
        column-gutter: 3pt,
        align: (left + bottom, left + bottom),
        text(weight: "bold")[Họ và tên thí sinh:],
        line(length: 100%, stroke: (paint: black, thickness: 0.6pt, dash: "dotted")),

        text(weight: "bold")[Số Báo Danh:],
        line(length: 100%, stroke: (paint: black, thickness: 0.6pt, dash: "dotted")),
      )
    },
    if code != "" {
      box(stroke: 0.8pt + black, inset: (x: 12pt, y: 7pt))[
        #text(weight: "bold", size: 12pt)[Mã đề thi #code]
      ]
    },
  )
  v(0.9em)
  if header-border { line(length: 100%, stroke: 0.8pt + black) }
  v(1em)
  body
}


// ─────────────────────────────────────────────────────────
// PRINT-ANSWER-KEY — 3 bảng đáp án: MCQ / TF / Short
// ─────────────────────────────────────────────────────────
#let _chunk(arr, n) = {
  let out = ()
  let cur = ()
  for x in arr {
    cur.push(x)
    if cur.len() == n {
      out.push(cur)
      cur = ()
    }
  }
  if cur.len() > 0 { out.push(cur) }
  out
}

#let print-answer-key() = context {
  let mcq-ans = _mcq-meta.get()
  let tf-ans = _tf-meta.get()
  let sh-ans = _sh-meta.get()

  v(1.5em)

  // ── Bảng 1: Trắc nghiệm ──────────────────────────────
  if mcq-ans.len() > 0 {
    v(0.8em)
    align(center)[
      #text(weight: "bold", size: 12pt, fill: palette.accent)[BẢNG ĐÁP ÁN — TRẮC NGHIỆM]
    ]
    v(0.3em)
    align(center, table(
      columns: (1fr,) * 5,
      stroke: 0.5pt + rgb("#cbd5e1"),
      align: center + horizon,
      inset: (x: 8pt, y: 6pt),
      ..mcq-ans.map(it => [
        #text(weight: "bold", fill: rgb("#475569"))[#it.num.]
        #h(0.3em)
        #text(weight: "bold", fill: palette.accent)[#it.ans]
      ])
    ))
    v(1em)
  }

  // ── Bảng 2: Đúng/Sai ─────────────────────────────────
  if tf-ans.len() > 0 {
    v(0.8em)
    align(center)[
      #text(weight: "bold", size: 12pt, fill: palette.accent)[BẢNG ĐÁP ÁN — ĐÚNG/SAI]
    ]
    v(0.3em)
    align(center, table(
      columns: (1.5fr, 1fr, 1fr, 1fr, 1fr),
      stroke: 0.5pt + rgb("#cbd5e1"),
      align: center + horizon,
      inset: (x: 8pt, y: 6pt),
      table.cell(fill: rgb("#f1f5f9"), pad(y: 4pt)[#text(weight: "bold", fill: rgb("#334155"))[Câu]]),
      ..(
        ("a", "b", "c", "d").map(l => {
          table.cell(fill: rgb("#f1f5f9"), pad(y: 4pt)[#text(weight: "bold", fill: rgb("#334155"))[#l)]])
        })
      ),
      ..tf-ans
        .map(item => {
          let cells = (
            table.cell(fill: rgb("#f8fafc"), pad(y: 4pt)[#text(weight: "bold", fill: rgb("#475569"))[Câu #item.num]]),
          )
          for vv in item.ans {
            let col = if vv == "Đ" { palette.correct } else { palette.wrong }
            cells = cells + (pad(y: 4pt)[#text(weight: "bold", fill: col)[#vv]],)
          }
          cells
        })
        .flatten(),
    ))
    v(1em)
  }

  // ── Bảng 3: Điền số ───────────────────────────────────
  if sh-ans.len() > 0 {
    v(0.8em)
    align(center)[
      #text(weight: "bold", size: 12pt, fill: palette.accent)[BẢNG ĐÁP ÁN — ĐIỀN SỐ]
    ]
    v(0.3em)
    align(center, table(
      columns: (1fr,) * 5,
      stroke: 0.5pt + rgb("#cbd5e1"),
      align: center + horizon,
      inset: (x: 8pt, y: 6pt),
      ..sh-ans.map(it => [
        #text(weight: "bold", fill: rgb("#475569"))[#it.num.]
        #h(0.3em)
        #text(weight: "bold", fill: palette.accent)[#it.ans]
      ])
    ))
  }
}

// ─────────────────────────────────────────────────────────
// CÔNG CỤ TOÁN HỌC (MATH TOOLS)
// ─────────────────────────────────────────────────────────
// vect(AB) → dấu mũi tên chuẩn LaTeX \overrightarrow
#let vect(..args) = {
  let body = args.pos().map(a => if type(a) == str { math.upright(a) } else { a }).join()
  math.accent(body, math.arrow.r)
}
