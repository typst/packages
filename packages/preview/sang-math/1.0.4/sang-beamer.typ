// =========================================================
// SANG-BEAMER.TYP v4.0 — Slide trình chiếu Premium
// ✅ Auto-counter: không cần nhập num tay
// ✅ Hỗ trợ offset riêng cho từng loại câu (mcq/tf/tln)
// =========================================================

#import "@preview/touying:0.7.4": *
#import themes.metropolis: *

#import "sang-exam.typ": (
  True, bode, classic, configure-step-reveal, dl, dn, draw-lines, luuy, lythuyet, meo, note, palette, ppgiai, reset-step, tc, vect,
)
// ── Answer registry cho beamer ─────────────────────────────
// Lưu integer thực (không dùng lazy context) tránh bug "tất cả câu 22"
#let _bm-ans-state = state("bm-ans", (q: 0, mcq: (), tf: (), sh: ()))

// ── Màu sắc sống động ──────────────────────────────────
#let bm-colors = (
  bg: rgb("#0f172a"), // Nền slide xanh đậm
  fg: white,
  accent: rgb("#3b82f6"), // Xanh dương sáng
  correct: rgb("#22c55e"), // Xanh lá tươi
  wrong: rgb("#ef4444"), // Đỏ
  card: rgb("#1e293b"), // Card tối
  card-hi: rgb("#172554"), // Card hover
  muted: rgb("#94a3b8"),
  gold: rgb("#f59e0b"), // Vàng accent
)

#let _bm-style-defaults = (
  text_size: 18pt,
  text_fill: none, // none = auto-detect from bg_color
  math_color: bm-colors.gold,
  question_size: 17pt,
  option_size: 15pt,
  label_size: 16pt,
  table_size: 13pt,
  answer_size: 24pt,
  solution_size: 13pt,
  solution_title_size: 14pt,
  solution_fill: none, // none = auto-detect from bg_color
  solution_text_fill: none, // none = auto-detect from bg_color
  card: none, // none = auto-detect from bg_color
  card_hi: none, // none = auto-detect from bg_color
  muted: none, // none = auto-detect from bg_color
)
#let _bm-style = state("bm-style", _bm-style-defaults)

// ── Auto-counter cho beamer ──────────────────────────────
// Mỗi loại câu (tn, tf, tln) có counter riêng.
// Có thể reset về bất kỳ số nào.
#let _bm-q-cnt = counter("bm-q")   // Toàn cục — tương tự exam engine

#let _resolve-loigiai(loigiai, args) = {
  if loigiai != none { loigiai } else { args.named().at("solution", default: none) }
}

// Đặt lại counter beamer (dùng đầu file slide)
// Ví dụ: #bm-resetcau() hoặc #bm-setcau(13)
#let bm-resetcau(start: 1) = [
  #_bm-q-cnt.update(if start > 0 { start - 1 } else { 0 })
]
#let bm-setcau(start) = bm-resetcau(start: start)

// ── Beamer Theme ────────────────────────────────────────
#let sang-beamer-theme(
  body,
  title: "ĐỀ THI THPT QUỐC GIA",
  subtitle: "TOÁN - LỚP 12",
  author: "GV Nguyễn Văn Sang",
  institution: "Sở GD&ĐT",
  date: datetime.today(),
  accent: bm-colors.accent,
  aspect-ratio: "16-9",
  code: "",
  total-q: 22,
  text_size: _bm-style-defaults.at("text_size"),
  text_fill: _bm-style-defaults.at("text_fill"),
  math_color: _bm-style-defaults.at("math_color"),
  question_size: _bm-style-defaults.at("question_size"),
  option_size: _bm-style-defaults.at("option_size"),
  label_size: _bm-style-defaults.at("label_size"),
  table_size: _bm-style-defaults.at("table_size"),
  answer_size: _bm-style-defaults.at("answer_size"),
  solution_size: _bm-style-defaults.at("solution_size"),
  solution_title_size: _bm-style-defaults.at("solution_title_size"),
  solution_fill: none,
  solution_text_fill: none,
  auto_step_pause: false,
  bg_color: bm-colors.bg,
) = {
  // ── Tự tính màu từ bg_color (nhận biết nền tối / sáng) ─────────
  let _comps = bg_color.components()
  let _r = float(_comps.at(0))
  let _g = float(_comps.at(1))
  let _b = float(_comps.at(2))
  let _bg-luma = 0.299 * _r + 0.587 * _g + 0.114 * _b
  let _is-dark = _bg-luma < 0.5 // components() returns 0.0–1.0 (ratio)
  // Màu tự sinh theo nền
  let _auto-fg = if _is-dark { white } else { rgb("#0f172a") }
  let _auto-card = if _is-dark { bg_color.lighten(13%) } else { bg_color.darken(8%) }
  let _auto-card-hi = if _is-dark { bg_color.lighten(24%) } else { bg_color.darken(15%) }
  let _auto-muted = if _is-dark { rgb("#94a3b8") } else { rgb("#475569") }
  let _auto-sol-fill = if _is-dark { bg_color.lighten(8%) } else { bg_color.darken(5%) }
  let _auto-sol-text = if _is-dark { rgb("#cbd5e1") } else { rgb("#1e293b") }
  // Honor overrides; use none → auto
  let _fg = if text_fill == none { _auto-fg } else { text_fill }
  let _sol-fill = if solution_fill == none { _auto-sol-fill } else { solution_fill }
  let _sol-text = if solution_text_fill == none { _auto-sol-text } else { solution_text_fill }
  show: metropolis-theme.with(
    aspect-ratio: aspect-ratio,
    // ── Footer: dùng param của metropolis (không dùng config-page) ──
    // config-page(footer:) bị override mỗi slide → dots chỉ slide 1
    footer: context {
      set text(size: 7pt, fill: _auto-muted)
      grid(
        columns: (auto, 1fr, auto),
        align: (left + horizon, center + horizon, right + horizon),
        pad(left: 4pt)[#author — #institution],
        // ── Nút nhảy câu tròn ──
        {
          let dots = ()
          for i in range(1, total-q + 1) {
            let lbl = label("bm-q-" + str(i))
            let has = query(lbl).len() > 0
            if has {
              dots.push(
                link(lbl, box(
                  width: 13pt,
                  height: 13pt,
                  radius: 50%,
                  fill: accent.lighten(70%),
                  stroke: 0.5pt + accent,
                  align(center + horizon)[
                    #text(size: 5.5pt, weight: "bold", fill: accent)[#i]
                  ],
                )),
              )
            } else {
              dots.push(
                box(
                  width: 10pt,
                  height: 10pt,
                  radius: 50%,
                  fill: bg_color.lighten(20%),
                  stroke: 0.4pt + _auto-muted.lighten(40%),
                ),
              )
            }
          }
          stack(dir: ltr, spacing: 3pt, ..dots)
        },
        pad(right: 4pt)[#counter(page).display() / #counter(page).final().first()],
      )
    },
    footer-right: none,
    footer-progress: false,
    config-info(
      title: [#title],
      subtitle: [#subtitle #if code != "" [— Mã đề: #code]],
      author: [#author],
      date: date,
      institution: [#institution],
    ),
    config-common(slide-fn: slide),
    config-colors(
      primary: accent,
      primary-light: accent.lighten(50%),
      secondary: bm-colors.gold,
      neutral-lightest: bg_color,
      neutral-darkest: _fg,
    ),
  )

  _bm-style.update((
    text_size: text_size,
    text_fill: _fg,
    math_color: math_color,
    question_size: question_size,
    option_size: option_size,
    label_size: label_size,
    table_size: table_size,
    answer_size: answer_size,
    solution_size: solution_size,
    solution_title_size: solution_title_size,
    solution_fill: _sol-fill,
    solution_text_fill: _sol-text,
    card: _auto-card,
    card_hi: _auto-card-hi,
    muted: _auto-muted,
  ))
  configure-step-reveal(before_nonfirst: if auto_step_pause { [#pause] } else { none })

  set text(font: "Libertinus Serif", size: text_size, fill: _fg, lang: "vi")
  show math.frac: math.display
  show math.equation: set text(fill: math_color)

  title-slide()
  body
}

// ── Helper hiện từng dòng theo click ─────────────────────
// Dùng: #bm-lines([Dòng 1], [Dòng 2], [Dòng 3])
#let bm-lines(..items) = {
  let lines = items.pos()
  context {
    for (index, line) in lines.enumerate() {
      if index > 0 { pause }
      line
    }
  }
}

// ── exam-part ────────────────────────────────────────────
// Tạo slide section riêng thay vì dùng metropolis heading
#let exam-part(title, count: auto, reset-counter: true, accent: bm-colors.accent) = {
  slide(title: none)[
    #align(center + horizon)[
      #v(-1em)
      #block(
        width: 78%,
        stroke: (top: 2.5pt + accent, bottom: 2.5pt + accent),
        inset: (x: 0pt, y: 20pt),
      )[
        #align(center)[
          #text(size: 11pt, fill: accent, weight: "bold", tracking: 2pt)[#upper("Chương trình")]
          #v(0.5em)
          #context {
            let fg = _bm-style.get().at("text_fill", default: white)
            text(size: 22pt, weight: "bold", fill: fg)[#title]
          }
        ]
      ]
    ]
  ]
}

// ── Nội hàm lấy số câu tiếp theo ────────────────────────
// num: auto  → tự tăng counter
// num: 5     → dùng đúng số 5 và đặt counter = 5
#let _bm-next-num(num) = context {
  if num == auto {
    _bm-q-cnt.step()
    _bm-q-cnt.get().first()
  } else {
    _bm-q-cnt.update(num)
    num
  }
}

// ── MCQ ──────────────────────────────────────────────────
#let mcq(
  stem,
  options,
  correct: (),
  loigiai: none,
  mode: "loigiai",
  accent: bm-colors.accent,
  fig: none,
  fig-pos: "right",
  fig-width: 40%,
  cols: 0,
  lines: 0,
  num: auto, // ← auto = tự đếm
  prefix: "Câu",
  card-fill: none, // none = auto tính từ style.card
  card-stroke: auto,
  ..args,
) = {
  let loigiai = _resolve-loigiai(loigiai, args)
  let card-stroke = if card-stroke == auto { 1.2pt + accent.lighten(30%) } else { card-stroke }
  let labels = ("A", "B", "C", "D", "E", "F")

  // ── Lấy số câu (hiển thị an toàn) ──
  // q-num-display chỉ HIỂN THỊ — không chứa step (tránh đếm 2 lần khi dùng ở 2 slide)
  let q-num-display = if num == auto {
    context { _bm-q-cnt.display() }
  } else {
    str(num)
  }

  let ai = -1
  let idx = 0
  for opt in options {
    let ok = if type(opt) == dictionary { opt.at("correct", default: false) } else { correct.contains(idx + 1) }
    if ok { ai = idx }
    idx += 1
  }
  let opt-texts = options.map(o => if type(o) == dictionary { o.body } else { o })
  let opt-oks = options
    .enumerate()
    .map(((i, o)) => if type(o) == dictionary { o.at("correct", default: false) } else { correct.contains(i + 1) })

  // Ghi đáp án vào registry (dùng bởi print-answer-key)
  let _ans-label = if ai >= 0 { ("A", "B", "C", "D", "E", "F").at(ai) } else { "?" }
  let _rn = num // capture: auto or int — dùng trong lambda thuần túy
  let _ra = _ans-label
  [#_bm-ans-state.update(s => {
    let n = if _rn == auto { s.q + 1 } else { _rn }
    (q: n, mcq: s.mcq + ((num: n, ans: _ra),), tf: s.tf, sh: s.sh)
  })]

  // SLIDE 1: Câu hỏi
  slide(title: none)[
    // Step counter đúng 1 lần, trước label context
    #if num == auto { _bm-q-cnt.step() } else { _bm-q-cnt.update(num) }
    #context {
      let n = _bm-q-cnt.get().first()
      [#metadata(n) #label("bm-q-" + str(n))]
    }
    #context {
      let style = _bm-style.get()
      let _cf = if card-fill == none { style.at("card", default: rgb("#1e293b")) } else { card-fill }
  show math.frac: math.display
      show math.equation: set text(fill: style.at("math_color", default: bm-colors.gold))

      v(-0.5em)
      grid(
        columns: (auto, 1fr),
        column-gutter: 10pt,
        align: (left + top, left + top),
        box(fill: accent, inset: (x: 10pt, y: 6pt), radius: 4pt)[
          #text(weight: "bold", fill: white, size: style.at("label_size", default: 16pt))[#prefix #q-num-display]
        ],
        text(size: style.at("question_size", default: 17pt), fill: style.at("text_fill", default: bm-colors.fg))[#stem],
      )

      if fig != none {
        v(0.3em)
        align(center, block(
          width: fig-width,
          fill: white,
          inset: 8pt,
          radius: 6pt,
        )[#fig])
      }

      v(0.5em)
      grid(
        columns: (1fr, 1fr), row-gutter: 10pt, column-gutter: 12pt,
        ..opt-texts
          .enumerate()
          .map(((i, t)) => {
            box(width: 100%, inset: (x: 0pt, y: 0pt), radius: 8pt, fill: _cf, stroke: card-stroke)[
              #grid(columns: (auto, 1fr), column-gutter: 0pt)[
                #box(fill: accent, inset: (x: 11pt, y: 10pt), radius: (top-left: 7pt, bottom-left: 7pt))[
                  #text(weight: "bold", fill: white, size: style.at("label_size", default: 16pt))[#labels.at(i).]
                ]
              ][
                #pad(x: 12pt, y: 10pt)[
                  #text(size: style.at("option_size", default: 15pt), fill: style.at(
                    "text_fill",
                    default: bm-colors.fg,
                  ))[#t]
                ]
              ]
            ]
          })
      )
    }
  ]

  // SLIDE 2: Đáp án
  if mode == "loigiai" and (ai >= 0 or loigiai != none) {
    slide(title: none)[
      #context {
        let style = _bm-style.get()
        let _cf = if card-fill == none { style.at("card", default: rgb("#1e293b")) } else { card-fill }
  show math.frac: math.display
        show math.equation: set text(fill: style.at("math_color", default: bm-colors.gold))

        v(-0.5em)
        grid(
          columns: (auto, 1fr),
          column-gutter: 10pt,
          align: (left + horizon, left + horizon),
          box(fill: bm-colors.correct, inset: (x: 10pt, y: 6pt), radius: 4pt)[
            #text(weight: "bold", fill: white, size: style.at(
              "label_size",
              default: 16pt,
            ))[#prefix #q-num-display — ĐÁP ÁN]
          ],
          [],
        )

        v(0.4em)
        grid(
          columns: (1fr, 1fr), row-gutter: 10pt, column-gutter: 12pt,
          ..opt-texts
            .enumerate()
            .map(((i, t)) => {
              let ok = opt-oks.at(i)
              let bg = if ok { bm-colors.correct.darken(55%) } else { _cf }
              let brd = if ok { 2pt + bm-colors.correct } else { 1pt + accent.lighten(20%) }
              let mark = if ok { [  ✓] } else { [] }
              let txt-col = if ok { white } else { style.at("text_fill", default: bm-colors.fg) }
              let lbl-bg = if ok { bm-colors.correct } else { accent }
              box(width: 100%, inset: (x: 0pt, y: 0pt), radius: 8pt, fill: bg, stroke: brd)[
                #grid(columns: (auto, 1fr), column-gutter: 0pt)[
                  #box(fill: lbl-bg, inset: (x: 11pt, y: 10pt), radius: (top-left: 7pt, bottom-left: 7pt))[
                    #text(weight: "bold", fill: white, size: style.at("label_size", default: 16pt))[#labels.at(i).#mark]
                  ]
                ][
                  #pad(x: 12pt, y: 10pt)[
                    #text(size: style.at("option_size", default: 15pt), fill: txt-col)[#t]
                  ]
                ]
              ]
            })
        )

        if loigiai != none {
          v(0.5em)
          block(
            width: 100%,
            fill: style.at("solution_fill", default: rgb("#0c1a3a")),
            stroke: (left: 3pt + style.at("math_color", default: bm-colors.gold)),
            inset: (x: 14pt, y: 10pt),
            radius: (right: 6pt),
          )[
            #text(weight: "bold", fill: style.at("math_color", default: bm-colors.gold), size: style.at(
              "solution_title_size",
              default: 14pt,
            ))[📝 Lời giải]
            #v(0.3em)
            #set text(size: style.at("solution_size", default: 13pt), fill: style.at(
              "solution_text_fill",
              default: rgb("#cbd5e1"),
            ))
            #reset-step()
            #loigiai
          ]
        }
      }
    ]
  }
}

// ── TF ───────────────────────────────────────────────────
#let tf(
  stem,
  statements,
  loigiai: none,
  mode: "loigiai",
  accent: bm-colors.accent,
  fig: none,
  fig-pos: "right",
  fig-width: 30%,
  lines: 0,
  num: auto, // ← auto = tự đếm
  prefix: "Câu",
  ..args,
) = {
  let loigiai = _resolve-loigiai(loigiai, args)
  let alpha = ("a", "b", "c", "d", "e", "f")

  // ── Lấy số câu (hiển thị an toàn) ──
  let q-num-display = if num == auto {
    context { _bm-q-cnt.display() }
  } else {
    str(num)
  }

  // Ghi đáp án tf vào registry
  let tf-row = statements.map(s => {
    let ok = if type(s) == dictionary { s.at("correct", default: false) } else { false }
    if ok { "Đ" } else { "S" }
  })
  let _rn = num
  let _rr = tf-row
  [#_bm-ans-state.update(s => {
    let n = if _rn == auto { s.q + 1 } else { _rn }
    (q: n, mcq: s.mcq, tf: s.tf + ((num: n, ans: _rr),), sh: s.sh)
  })]

  slide(title: none)[
    #if num == auto { _bm-q-cnt.step() } else { _bm-q-cnt.update(num) }
    #context {
      let n = _bm-q-cnt.get().first()
      [#metadata(n) #label("bm-q-" + str(n))]
    }
    #context {
      let style = _bm-style.get()
  show math.frac: math.display
      show math.equation: set text(fill: style.at("math_color", default: bm-colors.gold))

      v(-0.5em)
      box(fill: accent, inset: (x: 10pt, y: 6pt), radius: 4pt)[
        #text(weight: "bold", fill: white, size: style.at(
          "label_size",
          default: 16pt,
        ))[#prefix #q-num-display — Đúng/Sai]
      ]
      v(0.3em)
      text(size: style.at("question_size", default: 17pt), fill: style.at("text_fill", default: bm-colors.fg))[#stem]
      if fig != none {
        v(0.3em)
        align(center, block(
          fill: white,
          inset: 8pt,
          radius: 6pt,
        )[#fig])
      }

      v(0.3em)
      table(
        columns: (1fr, auto, auto),
        stroke: 0.5pt + rgb("#1e3a5f"),
        align: (left + horizon, center + horizon, center + horizon),
        table.cell(fill: accent, pad(x: 10pt, y: 7pt)[#text(
          fill: white,
          weight: "bold",
          size: style.at("table_size", default: 13pt) + 1pt,
        )[Phát biểu]]),
        table.cell(fill: accent, pad(x: 10pt, y: 7pt)[#text(
          fill: white,
          weight: "bold",
          size: style.at("table_size", default: 13pt) + 1pt,
        )[Đ]]),
        table.cell(fill: accent, pad(x: 10pt, y: 7pt)[#text(
          fill: white,
          weight: "bold",
          size: style.at("table_size", default: 13pt) + 1pt,
        )[S]]),
        ..statements
          .enumerate()
          .map(((i, s)) => {
            let txt = if type(s) == dictionary { s.body } else { s }
            let row-bg = if calc.odd(i) { style.at("card_hi", default: rgb("#1a2744")) } else {
              style.at("card", default: bm-colors.card)
            }
            (
              table.cell(fill: row-bg, pad(x: 10pt, y: 7pt)[#text(
                  weight: "bold",
                  fill: accent,
                  size: style.at("table_size", default: 13pt),
                )[#alpha.at(i))] #h(5pt) #text(size: style.at("table_size", default: 13pt), fill: style.at(
                  "text_fill",
                  default: bm-colors.fg,
                ))[#txt]]),
              table.cell(fill: row-bg, align(center)[#box(
                width: 1.8em,
                height: 1.8em,
                stroke: 0.6pt + accent.lighten(40%),
                radius: 3pt,
                fill: style.at("card", default: bm-colors.bg),
              )]),
              table.cell(fill: row-bg, align(center)[#box(
                width: 1.8em,
                height: 1.8em,
                stroke: 0.6pt + accent.lighten(40%),
                radius: 3pt,
                fill: style.at("card", default: bm-colors.bg),
              )]),
            )
          })
          .flatten(),
      )
    }
  ]

  if mode == "loigiai" {
    slide(title: none)[
      #context {
        let style = _bm-style.get()
  show math.frac: math.display
        show math.equation: set text(fill: style.at("math_color", default: bm-colors.gold))

        v(-0.5em)
        box(fill: bm-colors.correct, inset: (x: 10pt, y: 6pt), radius: 4pt)[
          #text(weight: "bold", fill: white, size: style.at(
            "label_size",
            default: 16pt,
          ))[#prefix #q-num-display — ĐÁP ÁN]
        ]
        v(0.3em)
        table(
          columns: (1fr, auto, auto),
          stroke: 0.6pt + rgb("#334155"),
          align: (left + horizon, center + horizon, center + horizon),
          table.cell(fill: accent, pad(x: 10pt, y: 7pt)[#text(
            fill: white,
            weight: "bold",
            size: style.at("table_size", default: 13pt) + 1pt,
          )[Phát biểu]]),
          table.cell(fill: accent, pad(x: 10pt, y: 7pt)[#text(
            fill: white,
            weight: "bold",
            size: style.at("table_size", default: 13pt) + 1pt,
          )[Đ]]),
          table.cell(fill: accent, pad(x: 10pt, y: 7pt)[#text(
            fill: white,
            weight: "bold",
            size: style.at("table_size", default: 13pt) + 1pt,
          )[S]]),
          ..statements
            .enumerate()
            .map(((i, s)) => {
              let ok = if type(s) == dictionary { s.at("correct", default: false) } else { false }
              let txt = if type(s) == dictionary { s.body } else { s }
              let row-bg = if calc.odd(i) { style.at("card_hi", default: rgb("#1a2744")) } else {
                style.at("card", default: bm-colors.card)
              }
              let _mut = style.at("muted", default: bm-colors.muted)
              let fd = if ok { bm-colors.correct.darken(50%) } else { row-bg }
              let fs = if not ok { bm-colors.wrong.darken(50%) } else { row-bg }
              let md = if ok {
                text(fill: bm-colors.correct, weight: "bold", size: style.at("table_size", default: 13pt) + 1pt)[✓]
              } else { none }
              let ms = if not ok {
                text(fill: bm-colors.wrong, weight: "bold", size: style.at("table_size", default: 13pt) + 1pt)[✓]
              } else { none }
              (
                table.cell(fill: row-bg, pad(x: 10pt, y: 7pt)[#text(
                    weight: "bold",
                    fill: accent,
                    size: style.at("table_size", default: 13pt),
                  )[#alpha.at(i))] #h(5pt) #text(size: style.at("table_size", default: 13pt), fill: style.at(
                    "text_fill",
                    default: bm-colors.fg,
                  ))[#txt]]),
                table.cell(fill: fd, align(center)[#box(
                  width: 1.8em,
                  height: 1.8em,
                  stroke: 0.6pt + _mut,
                  radius: 3pt,
                  fill: fd,
                  align(center + horizon)[#md],
                )]),
                table.cell(fill: fs, align(center)[#box(
                  width: 1.8em,
                  height: 1.8em,
                  stroke: 0.6pt + _mut,
                  radius: 3pt,
                  fill: fs,
                  align(center + horizon)[#ms],
                )]),
              )
            })
            .flatten(),
        )

        if loigiai != none {
          v(0.3em)
          block(
            width: 100%,
            fill: style.at("solution_fill", default: rgb("#0c1a3a")),
            stroke: (left: 3pt + style.at("math_color", default: bm-colors.gold)),
            inset: (x: 14pt, y: 8pt),
            radius: (right: 6pt),
          )[
            #text(weight: "bold", fill: style.at("math_color", default: bm-colors.gold), size: style.at(
              "solution_title_size",
              default: 13pt,
            ))[📝 Lời giải] #v(0.2em)
            #set text(size: style.at("solution_size", default: 12pt), fill: style.at(
              "solution_text_fill",
              default: rgb("#cbd5e1"),
            ))
            #reset-step()
            #loigiai
          ]
        }
      }
    ]
  }
}

// ── SHORT ────────────────────────────────────────────────
#let short(
  stem,
  answer,
  loigiai: none,
  mode: "loigiai",
  accent: bm-colors.accent,
  fig: none,
  fig-pos: "right",
  fig-width: 30%,
  show-boxes: true,
  lines: 0,
  num: auto, // ← auto = tự đếm
  prefix: "Câu",
  box-count: 4,
  ..args,
) = {
  let loigiai = _resolve-loigiai(loigiai, args)

  // ── Lấy số câu (hiển thị an toàn) ──
  let q-num-display = if num == auto {
    context { _bm-q-cnt.display() }
  } else {
    str(num)
  }

  // Ghi đáp án short vào registry
  let _rn = num
  let _ra = answer
  [#_bm-ans-state.update(s => {
    let n = if _rn == auto { s.q + 1 } else { _rn }
    (q: n, mcq: s.mcq, tf: s.tf, sh: s.sh + ((num: n, ans: _ra),))
  })]

  slide(title: none)[
    #if num == auto { _bm-q-cnt.step() } else { _bm-q-cnt.update(num) }
    #context {
      let n = _bm-q-cnt.get().first()
      [#metadata(n) #label("bm-q-" + str(n))]
    }
    #context {
      let style = _bm-style.get()
  show math.frac: math.display
      show math.equation: set text(fill: style.at("math_color", default: bm-colors.gold))

      v(-0.5em)
      box(fill: accent, inset: (x: 10pt, y: 6pt), radius: 4pt)[
        #text(weight: "bold", fill: white, size: style.at(
          "label_size",
          default: 16pt,
        ))[#prefix #q-num-display — Trả lời ngắn]
      ]
      v(0.4em)
      text(size: style.at("question_size", default: 17pt), fill: style.at("text_fill", default: bm-colors.fg))[#stem]
      if fig != none {
        v(0.3em)
        align(center, block(
          fill: white,
          inset: 8pt,
          radius: 6pt,
        )[#fig])
      }

      if show-boxes {
        v(0.8em)
        align(center)[
          #text(weight: "bold", fill: style.at("text_fill", default: bm-colors.fg), size: style.at(
            "question_size",
            default: 17pt,
          ))[Đáp số: ]
          #h(8pt)
          #stack(
            dir: ltr,
            spacing: 4pt,
            ..range(box-count).map(_ => box(
              width: 2em,
              height: 2em,
              stroke: 1.2pt + style.at("math_color", default: bm-colors.gold),
              radius: 4pt,
              fill: bm-colors.card,
            )),
          )
        ]
      }
    }
  ]

  if mode == "loigiai" {
    slide(title: none)[
      #context {
        let style = _bm-style.get()
  show math.frac: math.display
        show math.equation: set text(fill: style.at("math_color", default: bm-colors.gold))

        v(-0.5em)
        box(fill: bm-colors.correct, inset: (x: 10pt, y: 6pt), radius: 4pt)[
          #text(weight: "bold", fill: white, size: style.at(
            "label_size",
            default: 16pt,
          ))[#prefix #q-num-display — ĐÁP ÁN]
        ]
        v(0.6em)
        align(center)[
          #box(
            fill: bm-colors.correct.darken(40%),
            stroke: 2pt + bm-colors.correct,
            inset: (x: 24pt, y: 14pt),
            radius: 10pt,
          )[
            #text(
              weight: "bold",
              size: style.at("answer_size", default: 24pt),
              fill: bm-colors.correct,
            )[Đáp số: #answer]
          ]
        ]

        if loigiai != none {
          v(0.6em)
          block(
            width: 100%,
            fill: style.at("solution_fill", default: rgb("#0c1a3a")),
            stroke: (left: 3pt + style.at("math_color", default: bm-colors.gold)),
            inset: (x: 14pt, y: 10pt),
            radius: (right: 6pt),
          )[
            #text(weight: "bold", fill: style.at("math_color", default: bm-colors.gold), size: style.at(
              "solution_title_size",
              default: 14pt,
            ))[📝 Lời giải] #v(0.2em)
            #set text(size: style.at("solution_size", default: 13pt), fill: style.at(
              "solution_text_fill",
              default: rgb("#cbd5e1"),
            ))
            #reset-step()
            #loigiai
          ]
        }
      }
    ]
  }
}

#let tl(
  stem,
  loigiai: none,
  mode: "loigiai",
  accent: bm-colors.accent,
  fig: none,
  fig-pos: "right",
  fig-width: 30%,
  show-boxes: true,
  num: auto, // ← auto = tự đếm
  prefix: "Câu",
  ..args,
) = {
  let loigiai = _resolve-loigiai(loigiai, args)

  // ── Lấy số câu (hiển thị an toàn) ──
  let q-num-display = if num == auto {
    context { _bm-q-cnt.display() }
  } else {
    str(num)
  }

  slide(title: none)[
    #if num == auto { _bm-q-cnt.step() } else { _bm-q-cnt.update(num) }
    #context {
      let n = _bm-q-cnt.get().first()
      [#metadata(n) #label("bm-q-" + str(n))]
    }
    #context {
      let style = _bm-style.get()
  show math.frac: math.display
      show math.equation: set text(fill: style.at("math_color", default: bm-colors.gold))

      v(-0.5em)
      box(fill: accent, inset: (x: 10pt, y: 6pt), radius: 4pt)[
        #text(weight: "bold", fill: white, size: style.at(
          "label_size",
          default: 16pt,
        ))[#prefix #q-num-display — Tự luận]
      ]
      v(0.4em)
      text(size: style.at("question_size", default: 17pt), fill: style.at("text_fill", default: bm-colors.fg))[#stem]
      if fig != none {
        v(0.3em)
        align(center, block(
          fill: white,
          inset: 8pt,
          radius: 6pt,
        )[#fig])
      }

      if show-boxes {
        v(0.7em)
        block(
          width: 100%,
          fill: bm-colors.card,
          stroke: 1pt + accent.lighten(30%),
          inset: (x: 14pt, y: 12pt),
          radius: 8pt,
        )[
          #text(
            size: style.at("table_size", default: 14pt),
            fill: bm-colors.muted,
          )[Trình bày lời giải vào vở hoặc tài liệu phát tay.]
        ]
      }
    }
  ]

  if mode == "loigiai" and loigiai != none {
    slide(title: none)[
      #context {
        let style = _bm-style.get()
  show math.frac: math.display
        show math.equation: set text(fill: style.at("math_color", default: bm-colors.gold))

        v(-0.5em)
        box(fill: bm-colors.correct, inset: (x: 10pt, y: 6pt), radius: 4pt)[
          #text(weight: "bold", fill: white, size: style.at(
            "label_size",
            default: 16pt,
          ))[#prefix #q-num-display — LỜI GIẢI]
        ]
        v(0.6em)
        block(
          width: 100%,
          fill: style.at("solution_fill", default: rgb("#0c1a3a")),
          stroke: (left: 3pt + style.at("math_color", default: bm-colors.gold)),
          inset: (x: 14pt, y: 10pt),
          radius: (right: 6pt),
        )[
          #text(weight: "bold", fill: style.at("math_color", default: bm-colors.gold), size: style.at(
            "solution_title_size",
            default: 14pt,
          ))[📝 Lời giải]
          #v(0.2em)
          #set text(size: style.at("solution_size", default: 13pt), fill: style.at(
            "solution_text_fill",
            default: rgb("#cbd5e1"),
          ))
          #loigiai
        ]
      }
    ]
  }
}

// ── Alias ────────────────────────────────────────────────
#let tn = mcq
#let ds = tf
#let tln = short

// ── exam-mode ────────────────────────────────────────────
#let exam-mode(mode: "loigiai", accent: bm-colors.accent) = (
  tn: tn.with(mode: mode, accent: accent),
  ds: ds.with(mode: mode, accent: accent),
  tln: tln.with(mode: mode, accent: accent),
  tl: tl.with(mode: mode, accent: accent),
  mcq: mcq.with(mode: mode, accent: accent),
  tf: tf.with(mode: mode, accent: accent),
  short: short.with(mode: mode, accent: accent),
)

// ── het ──────────────────────────────────────────────────
#let het = slide(title: none)[
  #align(center + horizon)[
    #text(weight: "bold", size: 40pt, fill: bm-colors.gold)[— HẾT —]
    #v(0.6em)
    #text(size: 18pt, fill: bm-colors.muted)[
      Cảm ơn các em đã theo dõi bài giảng! \
      Chúc các em ôn thi tốt! 🎓
    ]
  ]
]

// ── No-ops ───────────────────────────────────────────────
#let print-answer-key() = slide(title: none)[
  #context {
    let style = _bm-style.get()
    let _bm-ans = _bm-ans-state.get()
    let mcq-ans = _bm-ans.mcq
    let tf-ans = _bm-ans.tf
    let sh-ans = _bm-ans.sh
    let fg = style.at("text_fill", default: white)
    let card = style.at("card", default: rgb("#1e293b"))
    let math-c = style.at("math_color", default: bm-colors.gold)

    v(-0.3em)
    box(fill: bm-colors.correct, inset: (x: 12pt, y: 6pt), radius: 4pt)[
      #text(weight: "bold", fill: white, size: 16pt)[📋 BẢNG ĐÁP ÁN]
    ]
    v(0.6em)

    // ── Trắc nghiệm ─────────────────────────────────
    if mcq-ans.len() > 0 {
      text(weight: "bold", fill: math-c, size: 12pt)[Trắc nghiệm:]
      v(0.3em)
      let cols = 6
      grid(
        columns: range(cols).map(_ => 1fr),
        row-gutter: 6pt,
        column-gutter: 6pt,
        ..mcq-ans.map(it => box(
          fill: card,
          inset: (x: 8pt, y: 5pt),
          radius: 4pt,
          width: 100%,
        )[
          #align(center)[
            #text(size: 10pt, fill: fg)[Câu #it.num]
            #h(4pt)
            #text(weight: "bold", size: 13pt, fill: math-c)[#it.ans]
          ]
        ])
      )
      v(0.5em)
    }

    // ── Đúng/Sai ────────────────────────────────────
    if tf-ans.len() > 0 {
      text(weight: "bold", fill: math-c, size: 12pt)[Đúng/Sai:]
      v(0.3em)
      let accent-c = style.at("accent", default: bm-colors.accent)
      grid(
        columns: range(4).map(_ => 1fr),
        row-gutter: 6pt,
        column-gutter: 6pt,
        ..tf-ans.map(it => box(
          fill: card,
          radius: 6pt,
          width: 100%,
          clip: true,
          inset: 1pt,
        )[
          // Header: nhãn câu
          #box(fill: accent-c.lighten(20%), width: 100%, inset: (x: 6pt, y: 3pt))[
            #align(center)[
              #text(weight: "bold", size: 10pt, fill: white)[Câu #it.num]
            ]
          ]
          // Body: 4 badge a/b/c/d
          #pad(4pt)[
            #grid(
              columns: (1fr, 1fr, 1fr, 1fr),
              column-gutter: 3pt,
              ..it
                .ans
                .enumerate()
                .map(((i, v)) => {
                  let col = if v == "Đ" { bm-colors.correct } else { bm-colors.wrong }
                  box(fill: col, radius: 3pt, width: 100%, inset: (x: 2pt, y: 3pt))[
                    #align(center)[
                      #text(size: 7.5pt, fill: white)[#("a", "b", "c", "d").at(i)]
                      #linebreak()
                      #text(weight: "bold", size: 11pt, fill: white)[#v]
                    ]
                  ]
                })
            )
          ]
        ])
      )
      v(0.5em)
    }

    // ── Điền số ─────────────────────────────────────
    if sh-ans.len() > 0 {
      text(weight: "bold", fill: math-c, size: 12pt)[Điền số:]
      v(0.3em)
      grid(
        columns: range(6).map(_ => 1fr),
        row-gutter: 6pt,
        column-gutter: 6pt,
        ..sh-ans.map(it => box(fill: card, inset: (x: 8pt, y: 5pt), radius: 4pt, width: 100%)[
          #align(center)[
            #text(size: 10pt, fill: fg)[Câu #it.num]
            #linebreak()
            #text(weight: "bold", size: 13pt, fill: math-c)[#it.ans]
          ]
        ])
      )
    }
  }
]
#let thpt-school-exam(body, ..args) = body
