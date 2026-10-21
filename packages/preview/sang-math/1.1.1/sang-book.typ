// ═══════════════════════════════════════════════════════════
// STEXGV BOOK MODULE
// Phân hệ biên soạn Sách, Chuyên đề, SGK và Phụ lục học tập
// ═══════════════════════════════════════════════════════════

#import "sang-exam.typ": palette, classic, draw-lines, _sol as _exam-sol
#import "sang-exam.typ": lythuyet as _lythuyet, luuy as _luuy, note as _note, dn as _dn, dl as _dl, tc as _tc, bode as _bode

#let _part-cnt = counter("stx-part")
#let _chap-cnt = counter("stx-chap")
#let _lesson-cnt = counter("stx-lesson")
#let _section-cnt = counter("stx-section")
#let _subsection-cnt = counter("stx-subsection")
#let _micro-cnt = counter("stx-micro")
#let _appendix-cnt = counter("stx-appendix")
#let _appendix-topic-cnt = counter("stx-appendix-topic")
#let _vd-cnt = counter("stx-vd")
#let _bt-cnt = counter("stx-bt")
#let _cauhoi-cnt = counter("stx-cauhoi")
#let _activity-cnt = counter("stx-activity")

#let _letters = (
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
  "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
)

#let _advance(counter, num: auto) = {
  let resolved = if num == auto { counter.get().first() + 1 } else { num }
  (
    num: resolved,
    update: if num == auto { counter.step() } else { counter.update(num) },
  )
}

#let _reset-to(counter, start: 1) = [
  #counter.update(if start > 0 { start - 1 } else { 0 })
]

#let _reset-learning-counters() = [
  #_lesson-cnt.update(0)
  #_section-cnt.update(0)
  #_subsection-cnt.update(0)
  #_micro-cnt.update(0)
  #_appendix-topic-cnt.update(0)
  #_vd-cnt.update(0)
  #_bt-cnt.update(0)
  #_cauhoi-cnt.update(0)
  #_activity-cnt.update(0)
]

#let _resolve-loigiai(loigiai, args) = {
  if loigiai != none { loigiai } else { args.named().at("solution", default: none) }
}

#let _outline-heading(level, body) = hide(heading(level: level, outlined: true, bookmarked: auto)[#body])

#let _doc-label(doc-type) = {
  let kind = lower(str(doc-type))
  if kind == "sgk" or kind == "textbook" {
    [SÁCH GIÁO KHOA]
  } else if kind == "chuyende" {
    [CHUYÊN ĐỀ]
  } else if kind == "outline" or kind == "decuong" {
    [ĐỀ CƯƠNG HỌC TẬP]
  } else if kind == "bo-de" or kind == "exam-set" {
    [BỘ ĐỀ THI]
  } else {
    [SÁCH HỌC TẬP]
  }
}

#let _hero-banner(
  title,
  number: none,
  prefix: none,
  accent: classic.blue,
  kicker: none,
  fill: auto,
  stroke: auto,
  inset: 18pt,
  radius: 10pt,
) = {
  let body-fill = if fill == auto { accent.lighten(92%) } else { fill }
  let body-stroke = if stroke == auto { 0.8pt + accent.lighten(45%) } else { stroke }
  let badge-text = if number != none and prefix != none {
    [#upper(prefix) #number]
  } else if prefix != none {
    [#upper(prefix)]
  } else if number != none {
    [#number]
  } else {
    none
  }

  block(width: 100%, fill: body-fill, inset: inset, radius: radius, stroke: body-stroke)[
    #if badge-text != none {
      grid(columns: (auto, 1fr), column-gutter: 16pt, align: (left + horizon, left + horizon),
        box(fill: accent, inset: (x: 16pt, y: 12pt), radius: 8pt)[
          #text(size: 11pt, weight: "bold", fill: white)[#badge-text]
        ],
        [
          #if kicker != none {
            text(size: 10pt, weight: "bold", fill: accent)[#kicker]
            v(0.35em)
          }
          #text(size: 22pt, weight: "bold", fill: accent.darken(10%))[#title]
        ],
      )
    } else {
      [
        #if kicker != none {
          text(size: 10pt, weight: "bold", fill: accent)[#kicker]
          v(0.35em)
        }
        #text(size: 22pt, weight: "bold", fill: accent.darken(10%))[#title]
      ]
    }
    #v(0.85em)
    #line(length: 100%, stroke: 1pt + accent.lighten(55%))
  ]
}

#let _section-banner(
  title,
  label,
  accent: classic.blue,
  fill: auto,
  stroke: auto,
  radius: 5pt,
) = {
  block(
    width: 100%,
    fill: if fill == auto { accent.lighten(95%) } else { fill },
    inset: (x: 12pt, y: 10pt),
    radius: radius,
    stroke: if stroke == auto { (left: 4pt + accent) } else { stroke },
  )[
    #text(size: 14pt, weight: "bold", fill: accent)[#label #title]
  ]
}

#let _rule-heading(
  title,
  label,
  accent: classic.blue,
  fill: auto,
  stroke: auto,
  radius: 5pt,
) = {
  block(
    width: 100%,
    fill: if fill == auto { accent.lighten(97%) } else { fill },
    inset: (x: 12pt, y: 9pt),
    radius: radius,
    stroke: if stroke == auto { (bottom: 0.8pt + accent.lighten(35%)) } else { stroke },
  )[
    #text(size: 12.5pt, weight: "bold", fill: accent)[#label #title]
  ]
}

#let _chip-heading(
  title,
  label,
  accent: classic.blue,
  fill: auto,
  stroke: auto,
  radius: 999pt,
) = {
  let chip-fill = accent.lighten(93%)
  let chip-stroke = if stroke == auto { 0.6pt + accent.lighten(45%) } else { stroke }
  grid(
    columns: (auto, 1fr),
    column-gutter: 10pt,
    align: (left + horizon, left + horizon),
    box(fill: chip-fill, stroke: chip-stroke, inset: (x: 10pt, y: 4pt), radius: radius)[
      #text(size: 10pt, weight: "bold", fill: accent)[#label]
    ],
    block(fill: if fill == auto { white } else { fill }, inset: (x: 0pt, y: 2pt))[
      #text(size: 11.5pt, weight: "bold", fill: accent.darken(10%))[#title]
    ],
  )
}

#let _minimal-heading(title, label, accent: classic.blue) = [
  #text(size: 11pt, weight: "bold", fill: accent)[#label]
  #h(0.35em)
  #text(size: 12pt, weight: "bold", fill: accent.darken(10%))[#title]
]

#let _smart-structure-heading(
  title,
  prefix,
  num,
  accent: classic.blue,
  level: "section",
  look: auto,
  fill: auto,
  stroke: auto,
  radius: 5pt,
  kicker: none,
) = {
  let chosen = if look == auto {
    if ("part", "chapter", "appendix").contains(level) {
      "hero"
    } else if level == "lesson" {
      "band"
    } else if level == "section" {
      "rule"
    } else if level == "subsection" {
      "chip"
    } else {
      "minimal"
    }
  } else {
    look
  }
  let label = [#prefix #num. ]

  if chosen == "hero" {
    _hero-banner(title, number: num, prefix: prefix, accent: accent, kicker: kicker, fill: fill, stroke: stroke)
  } else if chosen == "band" {
    _section-banner(title, label, accent: accent, fill: fill, stroke: stroke, radius: radius)
  } else if chosen == "rule" {
    _rule-heading(title, label, accent: accent, fill: fill, stroke: stroke, radius: radius)
  } else if chosen == "chip" {
    _chip-heading(title, label, accent: accent, fill: fill, stroke: stroke, radius: radius)
  } else {
    _minimal-heading(title, label, accent: accent)
  }
}

#let _front-section(
  body,
  title,
  theme-color: classic.blue,
  pagebreak-before: false,
  level: 1,
  kicker: none,
  fill: auto,
  stroke: auto,
) = [
  #if pagebreak-before { pagebreak(weak: true) }
  #_outline-heading(level, title)
  #v(1.2em)
  #_hero-banner(
    title,
    accent: theme-color,
    kicker: kicker,
    fill: fill,
    stroke: stroke,
  )
  #v(0.9em)
  #body
  #v(1.2em)
]

#let _numbered-card(
  body,
  step,
  prefix,
  loigiai: none,
  lines: 0,
  theme-color: classic.blue,
  boxed: true,
  fill: white,
  stroke: auto,
  inset: (x: 10pt, y: 10pt),
  radius: 4pt,
  header-fill: auto,
  title-fill: auto,
) = {
  let num = step.num
  let border = if stroke == auto { 0.5pt + theme-color } else { stroke }
  let banner-fill = if header-fill == auto { theme-color.lighten(85%) } else { header-fill }
  let heading-fill = if title-fill == auto { theme-color.darken(20%) } else { title-fill }

  [
    #step.update
    #v(1em)
    #if boxed {
      block(width: 100%, stroke: border, radius: radius, inset: 0pt, fill: fill, clip: true)[
        #block(width: 100%, fill: banner-fill, inset: (x: 10pt, y: 8pt), stroke: (bottom: 0.5pt + theme-color))[
          #text(weight: "bold", fill: heading-fill)[#prefix #num.]
        ]
        #block(width: 100%, inset: inset)[
          #body
          #if lines > 0 { draw-lines(lines) }
          #if loigiai != none {
            v(0.8em)
            _exam-sol(loigiai, theme-color)
          }
        ]
      ]
    } else {
      [
        #text(weight: "bold", fill: heading-fill)[#prefix #num.]
        #v(0.5em)
        #body
        #if lines > 0 { draw-lines(lines) }
        #if loigiai != none {
          v(0.8em)
          _exam-sol(loigiai, theme-color)
        }
      ]
    }
    #v(0.5em)
  ]
}

#let setcounter(env, start) = {
  let name = if type(env) == str { lower(env) } else { env }
  if ("part", "phan", "unit").contains(name) {
    _reset-to(_part-cnt, start: start)
  } else if ("chapter", "chuong").contains(name) {
    _reset-to(_chap-cnt, start: start)
  } else if ("lesson", "bai", "topic", "dang").contains(name) {
    _reset-to(_lesson-cnt, start: start)
  } else if ("section", "muc").contains(name) {
    _reset-to(_section-cnt, start: start)
  } else if ("subsection", "tieumuc").contains(name) {
    _reset-to(_subsection-cnt, start: start)
  } else if ("microsection", "y").contains(name) {
    _reset-to(_micro-cnt, start: start)
  } else if ("appendix", "phuluc").contains(name) {
    _reset-to(_appendix-cnt, start: start)
  } else if ("appendix-section", "mucphuluc").contains(name) {
    _reset-to(_appendix-topic-cnt, start: start)
  } else if ("vd", "vidu").contains(name) {
    _reset-to(_vd-cnt, start: start)
  } else if ("bt", "baitap").contains(name) {
    _reset-to(_bt-cnt, start: start)
  } else if ("cauhoi", "question").contains(name) {
    _reset-to(_cauhoi-cnt, start: start)
  } else if ("activity", "hoatdong").contains(name) {
    _reset-to(_activity-cnt, start: start)
  } else {
    none
  }
}

#let setbookcounter = setcounter
#let resetbookcounter(env, start: 1) = setcounter(env, start)
#let setchuong(start) = setcounter("chapter", start)
#let resetchuong(start: 1) = setcounter("chapter", start)
#let setbai(start) = setcounter("lesson", start)
#let resetbai(start: 1) = setcounter("lesson", start)
#let setmuc(start) = setcounter("section", start)
#let resetmuc(start: 1) = setcounter("section", start)
#let settieumuc(start) = setcounter("subsection", start)
#let resettieumuc(start: 1) = setcounter("subsection", start)
#let sety(start) = setcounter("microsection", start)
#let resety(start: 1) = setcounter("microsection", start)
#let setphuluc(start) = setcounter("appendix", start)
#let resetphuluc(start: 1) = setcounter("appendix", start)
#let setvd(start) = setcounter("vd", start)
#let resetvd(start: 1) = setcounter("vd", start)
#let setbt(start) = setcounter("bt", start)
#let resetbt(start: 1) = setcounter("bt", start)

#let stexgv-book(
  title: "TÀI LIỆU TOÁN HỌC",
  subtitle: none,
  author: "Nguyễn Văn Sang",
  theme-color: classic.blue,
  doc-type: "book",
  institution: none,
  subject: none,
  grade: none,
  series: none,
  academic-year: none,
  publisher: none,
  cover-note: none,
  show-cover: true,
  show-outline: true,
  outline-depth: 4,
  margin: auto,
  body,
) = {
  set document(title: title, author: author)
  set page(
    paper: "a4",
    margin: if margin == auto { (top: 2.5cm, bottom: 2.5cm, inside: 2.5cm, outside: 2cm) } else { margin },
    header: context {
      let page-num = counter(page).get().first()
      if show-cover and page-num == 1 { return none }

      set text(size: 10pt, fill: theme-color)
      grid(columns: (1fr, auto), align: (left, right),
        text(weight: "bold")[#title],
        text(weight: "bold")[#author],
      )
      v(-4pt)
      line(length: 100%, stroke: 0.8pt + theme-color)
    },
    footer: context {
      let page-num = counter(page).get().first()
      if show-cover and page-num == 1 { return none }

      set text(size: 10pt, fill: palette.muted)
      line(length: 100%, stroke: 0.4pt + palette.border)
      v(2pt)
      align(center)[Trang #page-num]
    },
  )

  set text(font: "Libertinus Serif", size: 12pt, lang: "vi")
  set par(justify: true, leading: 0.75em)
  show math.frac: math.display
  set enum(numbering: "1.")

  if show-cover {
    align(center + horizon)[
      #if institution != none {
        text(size: 12pt, weight: "bold", fill: theme-color)[#institution]
        v(0.8em)
      }
      #text(size: 11pt, weight: "bold", tracking: 0.08em, fill: theme-color)[#_doc-label(doc-type)]
      #v(1.2em)
      #text(size: 30pt, weight: "bold", fill: theme-color)[#title]
      #if subtitle != none {
        v(0.8em)
        text(size: 18pt, style: "italic")[#subtitle]
      }
      #v(1.2em)
      #if subject != none {
        text(size: 14pt)[Môn: #subject]
        v(0.3em)
      }
      #if grade != none {
        text(size: 13pt)[Khối/Lớp: #grade]
        v(0.3em)
      }
      #if series != none {
        text(size: 13pt)[Bộ tài liệu: #series]
        v(0.3em)
      }
      #if academic-year != none {
        text(size: 12pt, fill: palette.muted)[Năm học: #academic-year]
      }
      #v(2.4em)
      #box(fill: theme-color.lighten(94%), stroke: 0.8pt + theme-color, inset: (x: 18pt, y: 12pt), radius: 10pt)[
        #text(size: 18pt, style: "italic")[Biên soạn: #author]
        #if publisher != none {
          v(0.4em)
          text(size: 11pt, fill: palette.muted)[#publisher]
        }
      ]
      #if cover-note != none {
        [
          #v(2em)
          note(cover-note, title: [Ghi chú xuất bản])
        ]
      }
      #v(3em)
    ]
    pagebreak()
  }

  if show-outline {
    outline(title: heading(level: 1, outlined: false)[MỤC LỤC], depth: outline-depth, indent: auto)
    pagebreak()
  }

  body
}

#let loinoidau(body, title: [Lời nói đầu], theme-color: classic.blue, pagebreak-before: false, ..args) = {
  _front-section(body, title, theme-color: theme-color, pagebreak-before: pagebreak-before, kicker: [Định hướng tài liệu], ..args)
}

#let gioithieu(body, title: [Giới thiệu], theme-color: classic.blue, pagebreak-before: false, ..args) = {
  _front-section(body, title, theme-color: theme-color, pagebreak-before: pagebreak-before, kicker: [Tổng quan nội dung], ..args)
}

#let huongdansudung(body, title: [Hướng dẫn sử dụng], theme-color: classic.emerald, pagebreak-before: false, ..args) = {
  _front-section(body, title, theme-color: theme-color, pagebreak-before: pagebreak-before, kicker: [Cách khai thác tài liệu], ..args)
}

#let muctieuchung(body, title: [Mục tiêu tổng quát], theme-color: classic.blue, pagebreak-before: false, ..args) = {
  _front-section(body, title, theme-color: theme-color, pagebreak-before: pagebreak-before, kicker: [Chuẩn đầu ra], ..args)
}

#let bangthuatngu(body, title: [Bảng thuật ngữ], theme-color: rgb("#0f766e"), pagebreak-before: true, ..args) = {
  _front-section(body, title, theme-color: theme-color, pagebreak-before: pagebreak-before, kicker: [Từ khóa và khái niệm], ..args)
}

#let tailieuthamkhao(body, title: [Tài liệu tham khảo], theme-color: classic.crimson, pagebreak-before: true, ..args) = {
  _front-section(body, title, theme-color: theme-color, pagebreak-before: pagebreak-before, kicker: [Nguồn tham khảo], ..args)
}

#let references(body, ..args) = {
  tailieuthamkhao(body, ..args)
}

#let glossary(body, ..args) = {
  bangthuatngu(body, ..args)
}

#let preface(body, ..args) = {
  loinoidau(body, ..args)
}

#let introduction(body, ..args) = {
  gioithieu(body, ..args)
}

#let part(
  title,
  prefix: "Phần",
  theme-color: classic.emerald,
  pagebreak-before: true,
  look: auto,
  boxed: true,
  fill: auto,
  stroke: auto,
  num: auto,
) = context {
  let step = _advance(_part-cnt, num: num)
  let num = step.num
  [
    #step.update
    #_chap-cnt.update(0)
    #_reset-learning-counters()
    #_outline-heading(1, [#upper(prefix) #num. #title])
    #if pagebreak-before { pagebreak(weak: true) }
    #v(2em)
    #if boxed or look != "minimal" {
      _smart-structure-heading(title, prefix, num, accent: theme-color, level: "part", look: look, fill: fill, stroke: stroke, kicker: [Khung nội dung lớn])
    } else {
      [
        #text(size: 16pt, weight: "bold", fill: theme-color)[#upper(prefix) #num.]
        #v(0.5em)
        #text(size: 22pt, weight: "bold", fill: theme-color.darken(10%))[#title]
      ]
    }
    #v(1.6em)
  ]
}

#let unit = part

#let chapter(
  title,
  prefix: "Chương",
  theme-color: classic.blue,
  pagebreak-before: true,
  look: auto,
  boxed: true,
  fill: auto,
  stroke: auto,
  num: auto,
) = context {
  let step = _advance(_chap-cnt, num: num)
  let num = step.num

  [
    #step.update
    #_lesson-cnt.update(0)
    #_section-cnt.update(0)
    #_subsection-cnt.update(0)
    #_micro-cnt.update(0)
    #_appendix-topic-cnt.update(0)
    #_vd-cnt.update(0)
    #_bt-cnt.update(0)
    #_cauhoi-cnt.update(0)
    #_activity-cnt.update(0)
    #_outline-heading(2, [#upper(prefix) #num. #title])
    #if pagebreak-before { pagebreak(weak: true) }
    #v(1.8em)
    #if boxed or look != "minimal" {
      _smart-structure-heading(title, prefix, num, accent: theme-color, level: "chapter", look: look, fill: fill, stroke: stroke, kicker: [Nội dung trọng tâm])
    } else {
      [
        #text(size: 16pt, weight: "bold", fill: theme-color)[#upper(prefix) #num.]
        #v(0.5em)
        #text(size: 22pt, weight: "bold", fill: theme-color.darken(10%))[#title]
      ]
    }
    #v(1.5em)
  ]
}

#let lesson(
  title,
  prefix: "Bài",
  theme-color: classic.blue,
  look: auto,
  boxed: true,
  fill: auto,
  stroke: auto,
  radius: 5pt,
  num: auto,
) = context {
  let step = _advance(_lesson-cnt, num: num)
  let num = step.num

  [
    #step.update
    #_section-cnt.update(0)
    #_subsection-cnt.update(0)
    #_micro-cnt.update(0)
    #_vd-cnt.update(0)
    #_bt-cnt.update(0)
    #_cauhoi-cnt.update(0)
    #_activity-cnt.update(0)
    #_outline-heading(3, [#prefix #num. #title])
    #v(1.5em)
    #if boxed or look != "minimal" {
      _smart-structure-heading(title, prefix, num, accent: theme-color, level: "lesson", look: look, fill: fill, stroke: stroke, radius: radius)
    } else {
      text(size: 14pt, weight: "bold", fill: theme-color)[#prefix #num. #title]
    }
    #v(0.9em)
  ]
}

#let bai = lesson

#let topic(title, prefix: "Chủ Đề", theme-color: classic.blue, look: auto, boxed: true, fill: auto, stroke: auto, radius: 5pt, num: auto) = {
  lesson(title, prefix: prefix, theme-color: theme-color, look: look, boxed: boxed, fill: fill, stroke: stroke, radius: radius, num: num)
}

#let dang = topic

#let section(
  title,
  prefix: "Mục",
  theme-color: classic.blue,
  look: auto,
  boxed: true,
  fill: auto,
  stroke: auto,
  radius: 4pt,
  num: auto,
) = context {
  let step = _advance(_section-cnt, num: num)
  let num = step.num

  [
    #step.update
    #_subsection-cnt.update(0)
    #_micro-cnt.update(0)
    #_outline-heading(4, [#prefix #num. #title])
    #v(1em)
    #if boxed or look != "minimal" {
      _smart-structure-heading(title, prefix, num, accent: theme-color, level: "section", look: look, fill: fill, stroke: stroke, radius: radius)
    } else {
      text(size: 13pt, weight: "bold", fill: theme-color)[#prefix #num. #title]
    }
    #v(0.7em)
  ]
}

#let muc = section

#let subsection(
  title,
  prefix: "Tiểu mục",
  theme-color: classic.blue,
  look: auto,
  boxed: true,
  fill: auto,
  stroke: auto,
  radius: 999pt,
  num: auto,
) = context {
  let step = _advance(_subsection-cnt, num: num)
  let num = step.num

  [
    #step.update
    #_micro-cnt.update(0)
    #_outline-heading(5, [#prefix #num. #title])
    #v(0.9em)
    #if boxed or look != "minimal" {
      _smart-structure-heading(title, prefix, num, accent: theme-color, level: "subsection", look: look, fill: fill, stroke: stroke, radius: radius)
    } else {
      text(size: 12pt, weight: "bold", fill: theme-color)[#prefix #num. #title]
    }
    #v(0.55em)
  ]
}

#let tieumuc = subsection

#let microsection(
  title,
  prefix: "Ý",
  theme-color: rgb("#475569"),
  look: auto,
  boxed: true,
  fill: auto,
  stroke: auto,
  radius: 999pt,
  num: auto,
) = context {
  let step = _advance(_micro-cnt, num: num)
  let num = step.num

  [
    #step.update
    #_outline-heading(6, [#prefix #num. #title])
    #v(0.75em)
    #if boxed or look != "minimal" {
      _smart-structure-heading(title, prefix, num, accent: theme-color, level: "micro", look: look, fill: fill, stroke: stroke, radius: radius)
    } else {
      text(size: 11pt, weight: "bold", fill: theme-color)[#prefix #num. #title]
    }
    #v(0.45em)
  ]
}

#let y = microsection

#let appendix(
  title,
  prefix: "Phụ lục",
  theme-color: classic.crimson,
  pagebreak-before: true,
  look: auto,
  boxed: true,
  fill: auto,
  stroke: auto,
  num: auto,
) = context {
  let step = _advance(_appendix-cnt, num: num)
  let num = step.num
  let label = if num <= _letters.len() { _letters.at(num - 1) } else { str(num) }

  [
    #step.update
    #_appendix-topic-cnt.update(0)
    #_vd-cnt.update(0)
    #_bt-cnt.update(0)
    #_cauhoi-cnt.update(0)
    #_activity-cnt.update(0)
    #_outline-heading(1, [#prefix #label. #title])
    #if pagebreak-before { pagebreak(weak: true) }
    #v(1.8em)
    #if boxed or look != "minimal" {
      _smart-structure-heading(title, prefix, label, accent: theme-color, level: "appendix", look: look, fill: fill, stroke: stroke, kicker: [Hệ thống phụ lục])
    } else {
      [
        #text(size: 16pt, weight: "bold", fill: theme-color)[#upper(prefix) #label.]
        #v(0.5em)
        #text(size: 22pt, weight: "bold", fill: theme-color.darken(10%))[#title]
      ]
    }
    #v(1.5em)
  ]
}

#let phuluc = appendix

#let appendix-section(
  title,
  prefix: "Mục phụ lục",
  theme-color: classic.crimson,
  look: auto,
  boxed: true,
  fill: auto,
  stroke: auto,
  radius: 4pt,
  num: auto,
) = context {
  let step = _advance(_appendix-topic-cnt, num: num)
  let num = step.num
  [
    #step.update
    #_outline-heading(2, [#prefix #num. #title])
    #v(1em)
    #if boxed or look != "minimal" {
      _smart-structure-heading(title, prefix, num, accent: theme-color, level: "section", look: look, fill: fill, stroke: stroke, radius: radius)
    } else {
      text(size: 13pt, weight: "bold", fill: theme-color)[#prefix #num. #title]
    }
    #v(0.7em)
  ]
}

#let mucphuluc = appendix-section

#let vd(
  stem,
  loigiai: none,
  lines: 0,
  theme-color: classic.blue,
  prefix: "Ví dụ",
  boxed: true,
  fill: white,
  stroke: auto,
  inset: (x: 10pt, y: 10pt),
  radius: 4pt,
  header-fill: auto,
  title-fill: auto,
  num: auto,
  ..args,
) = context {
  let step = _advance(_vd-cnt, num: num)
  let loigiai = _resolve-loigiai(loigiai, args)
  _numbered-card(stem, step, prefix, loigiai: loigiai, lines: lines, theme-color: theme-color, boxed: boxed, fill: fill, stroke: stroke, inset: inset, radius: radius, header-fill: header-fill, title-fill: title-fill)
}

#let bt(
  stem,
  loigiai: none,
  lines: 0,
  theme-color: classic.emerald,
  prefix: "Bài tập",
  boxed: true,
  fill: white,
  stroke: auto,
  inset: (x: 10pt, y: 10pt),
  radius: 4pt,
  header-fill: auto,
  title-fill: auto,
  num: auto,
  ..args,
) = context {
  let step = _advance(_bt-cnt, num: num)
  let loigiai = _resolve-loigiai(loigiai, args)
  _numbered-card(stem, step, prefix, loigiai: loigiai, lines: lines, theme-color: theme-color, boxed: boxed, fill: fill, stroke: stroke, inset: inset, radius: radius, header-fill: header-fill, title-fill: title-fill)
}

#let cauhoi(
  stem,
  loigiai: none,
  lines: 0,
  theme-color: classic.crimson,
  prefix: "Câu hỏi",
  boxed: true,
  fill: white,
  stroke: auto,
  inset: (x: 10pt, y: 10pt),
  radius: 4pt,
  header-fill: auto,
  title-fill: auto,
  num: auto,
  ..args,
) = context {
  let step = _advance(_cauhoi-cnt, num: num)
  let loigiai = _resolve-loigiai(loigiai, args)
  _numbered-card(stem, step, prefix, loigiai: loigiai, lines: lines, theme-color: theme-color, boxed: boxed, fill: fill, stroke: stroke, inset: inset, radius: radius, header-fill: header-fill, title-fill: title-fill)
}

#let hoatdongn(
  stem,
  loigiai: none,
  lines: 0,
  theme-color: rgb("#0369a1"),
  prefix: "Hoạt động",
  boxed: true,
  fill: white,
  stroke: auto,
  inset: (x: 10pt, y: 10pt),
  radius: 4pt,
  header-fill: auto,
  title-fill: auto,
  num: auto,
  ..args,
) = context {
  let step = _advance(_activity-cnt, num: num)
  let loigiai = _resolve-loigiai(loigiai, args)
  _numbered-card(stem, step, prefix, loigiai: loigiai, lines: lines, theme-color: theme-color, boxed: boxed, fill: fill, stroke: stroke, inset: inset, radius: radius, header-fill: header-fill, title-fill: title-fill)
}

#let vidu = vd
#let baitap = bt
#let onluyen = bt
#let hd = hoatdongn

#let _smartbox-theme(kind) = {
  let name = if type(kind) == str { lower(kind) } else { "note" }
  if ("lythuyet", "theory").contains(name) {
    (accent: classic.blue, fill: rgb("#eef4ff"), title: [Lý thuyết], title-fill: classic.blue, style: "ribbon")
  } else if ("phuongphap", "method").contains(name) {
    (accent: classic.emerald, fill: rgb("#ecfdf5"), title: [Phương pháp], title-fill: classic.emerald, style: "ribbon")
  } else if ("ghinho", "memory").contains(name) {
    (accent: rgb("#0369a1"), fill: rgb("#eff6ff"), title: [Ghi nhớ], title-fill: rgb("#075985"), style: "bar")
  } else if ("tomtat", "summary").contains(name) {
    (accent: rgb("#0f766e"), fill: rgb("#ecfeff"), title: [Tóm tắt], title-fill: rgb("#115e59"), style: "bar")
  } else if ("luuy", "warning").contains(name) {
    (accent: rgb("#c2410c"), fill: rgb("#fff7ed"), title: [Lưu ý], title-fill: rgb("#9a3412"), style: "bar")
  } else if ("nhanxet", "remark").contains(name) {
    (accent: rgb("#9a3412"), fill: rgb("#fff7ed"), title: [Nhận xét], title-fill: rgb("#9a3412"), style: "minimal")
  } else if ("baitap", "exercise").contains(name) {
    (accent: classic.emerald, fill: white, title: [Bài tập], title-fill: classic.emerald, style: "minimal")
  } else {
    (accent: rgb("#0f766e"), fill: rgb("#f8fafc"), title: [Ghi chú], title-fill: rgb("#115e59"), style: "bar")
  }
}

#let _smart-panel(
  body,
  title: none,
  accent: classic.blue,
  fill: white,
  stroke: auto,
  inset: (x: 12pt, y: 9pt),
  radius: 8pt,
  title-fill: auto,
  style: "ribbon",
  boxed: true,
) = {
  let border = if stroke == auto { 0.6pt + accent.lighten(55%) } else { stroke }
  let heading-fill = if title-fill == auto { accent.darken(12%) } else { title-fill }

  if not boxed {
    [
      #if title != none {
        text(weight: "bold", fill: heading-fill)[#title]
        v(0.35em)
      }
      #body
    ]
  } else if style == "minimal" {
    block(width: 100%, fill: fill, stroke: border, inset: inset, radius: radius)[
      #if title != none {
        text(size: 11pt, weight: "bold", fill: heading-fill)[#title]
        v(0.35em)
        line(length: 100%, stroke: 0.6pt + accent.lighten(45%))
        v(0.45em)
      }
      #body
    ]
  } else if style == "bar" {
    block(width: 100%, fill: fill, stroke: border, inset: 0pt, radius: radius, clip: true)[
      #if title != none {
        block(width: 100%, fill: accent.lighten(93%), inset: (x: 12pt, y: 8pt), stroke: (bottom: 0.6pt + accent.lighten(45%)))[
          #text(size: 11pt, weight: "bold", fill: heading-fill)[#title]
        ]
      }
      #block(width: 100%, inset: inset)[#body]
    ]
  } else {
    block(width: 100%, fill: fill, stroke: border, inset: inset, radius: radius)[
      #if title != none {
        box(fill: accent, inset: (x: 10pt, y: 4pt), radius: 999pt)[
          #text(size: 10.5pt, weight: "bold", fill: white)[#title]
        ]
        v(0.5em)
      }
      #body
    ]
  }
}

#let smartbox(
  body,
  kind: "note",
  title: auto,
  accent: auto,
  fill: auto,
  stroke: auto,
  title-fill: auto,
  style: auto,
  compact: false,
  radius: auto,
  boxed: true,
) = {
  let theme = _smartbox-theme(kind)
  let resolved-accent = if accent == auto { theme.accent } else { accent }
  let resolved-fill = if fill == auto { theme.fill } else { fill }
  let resolved-title = if title == auto { theme.title } else { title }
  let resolved-title-fill = if title-fill == auto { theme.title-fill } else { title-fill }
  let resolved-style = if style == auto { theme.style } else { style }
  let resolved-radius = if radius == auto { if compact { 6pt } else { 8pt } } else { radius }

  _smart-panel(
    body,
    title: resolved-title,
    accent: resolved-accent,
    fill: resolved-fill,
    stroke: stroke,
    inset: if compact { (x: 10pt, y: 6pt) } else { (x: 12pt, y: 9pt) },
    radius: resolved-radius,
    title-fill: resolved-title-fill,
    style: resolved-style,
    boxed: boxed,
  )
}

#let khung = smartbox

#let muctieu(body, title: [Mục tiêu bài học], ..args) = _lythuyet(body, title: title, accent: classic.blue, fill: rgb("#eef4ff"), title-fill: classic.blue, ..args)
#let chuanbi(body, title: [Chuẩn bị], ..args) = _note(body, title: title, accent: rgb("#334155"), fill: rgb("#f8fafc"), title-fill: rgb("#1e293b"), ..args)
#let khoidong(body, title: [Khởi động], ..args) = _note(body, title: title, accent: rgb("#ea580c"), fill: rgb("#fff7ed"), title-fill: rgb("#c2410c"), ..args)
#let khampha(body, title: [Khám phá], ..args) = _lythuyet(body, title: title, accent: rgb("#7c3aed"), fill: rgb("#f5f3ff"), title-fill: rgb("#6d28d9"), ..args)
#let hoatdong(body, title: [Hoạt động], ..args) = _note(body, title: title, accent: rgb("#0369a1"), fill: rgb("#eff6ff"), title-fill: rgb("#075985"), ..args)
#let luyentap(body, title: [Luyện tập], ..args) = _note(body, title: title, accent: classic.emerald, fill: rgb("#ecfdf5"), title-fill: classic.emerald, ..args)
#let vandung(body, title: [Vận dụng], ..args) = _note(body, title: title, accent: rgb("#b45309"), fill: rgb("#fff7ed"), title-fill: rgb("#9a3412"), ..args)
#let morang(body, title: [Mở rộng], ..args) = _note(body, title: title, accent: rgb("#6d28d9"), fill: rgb("#f5f3ff"), title-fill: rgb("#5b21b6"), ..args)
#let tomtat(body, title: [Tóm tắt], ..args) = _note(body, title: title, accent: rgb("#0f766e"), fill: rgb("#ecfeff"), title-fill: rgb("#115e59"), ..args)
#let duan(body, title: [Dự án học tập], ..args) = _note(body, title: title, accent: rgb("#991b1b"), fill: rgb("#fef2f2"), title-fill: rgb("#991b1b"), ..args)
#let nhanxet(body, title: [Nhận xét], ..args) = _note(body, title: title, accent: rgb("#b45309"), fill: rgb("#fff7ed"), title-fill: rgb("#9a3412"), ..args)
#let ghinho(body, title: [Ghi nhớ], ..args) = _note(body, title: title, accent: rgb("#0369a1"), fill: rgb("#eff6ff"), title-fill: rgb("#075985"), ..args)
#let phuongphap(body, title: [Phương pháp], ..args) = _lythuyet(body, title: title, accent: classic.emerald, fill: rgb("#ecfdf5"), title-fill: classic.emerald, ..args)

#let lythuyet(body, ..args) = _lythuyet(body, ..args)
#let luuy(body, ..args) = _luuy(body, ..args)
#let note(body, ..args) = _note(body, ..args)
#let dn(body, ..args) = _dn(body, ..args)
#let dl(body, ..args) = _dl(body, ..args)
#let tc(body, ..args) = _tc(body, ..args)
#let bode(body, ..args) = _bode(body, ..args)

#let definition(body, ..args) = dn(body, ..args)
