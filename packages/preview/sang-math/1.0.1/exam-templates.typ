// ================================================================
// SANG-MATH EXAM TEMPLATES v1.0.1
// Bộ preset giao diện đề thi dùng chung với thpt-school-exam.
// Cách dùng:
//   #import "@preview/sang-math:1.0.1": *
//   #show: exam-ocean.with(school: "THPT ...", code: "101")
// ================================================================

#import "sang-exam.typ": thpt-school-exam, print-answer-key

#let _template(
  body,
  accent: rgb(0, 87, 184),
  q-style: "pill",
  show-topbar: true,
  header-border: true,
  watermark: none,
  watermark-opacity: 0.06,
  footer-left: none,
  body-font: "Times New Roman",
  header-font: "Times New Roman",
  two-columns: false,
  column-gutter: 14pt,
  answer-key: false,
  ..args,
) = {
  let content = if two-columns {
    columns(2, gutter: column-gutter)[#body]
  } else {
    body
  }

  let final-body = if answer-key {
    [
      #content
      #pagebreak(weak: true)
      #print-answer-key()
    ]
  } else {
    content
  }

  thpt-school-exam(
    final-body,
    accent: accent,
    q-color: accent,
    q-style: q-style,
    show-topbar: show-topbar,
    header-border: header-border,
    watermark: watermark,
    watermark-opacity: watermark-opacity,
    footer-left: footer-left,
    body-font: body-font,
    header-font: header-font,
    ..args,
  )
}

// 01. Cổ điển xanh: giống phong cách đề chính thức, gọn và nghiêm túc.
#let exam-classic(body, ..args) = _template(
  body,
  accent: rgb(0, 87, 184),
  q-style: "bold",
  show-topbar: false,
  header-border: true,
  ..args,
)

// 02. Ocean: xanh ngọc hiện đại, hợp đề luyện tập và đề online.
#let exam-ocean(body, ..args) = _template(
  body,
  accent: rgb(14, 116, 144),
  q-style: "pill",
  watermark: [SANG MATH],
  ..args,
)

// 03. Emerald: xanh lá nhẹ, dễ nhìn khi in lời giải.
#let exam-emerald(body, ..args) = _template(
  body,
  accent: rgb(4, 120, 87),
  q-style: "pill",
  watermark: [THPT],
  ..args,
)

// 04. Royal: xanh tím sang, hợp đề chọn lọc/chuyên đề.
#let exam-royal(body, ..args) = _template(
  body,
  accent: rgb(67, 56, 202),
  q-style: "boxed",
  watermark: [ROYAL],
  ..args,
)

// 05. Violet: nổi bật, hợp đề ôn tốc độ hoặc đề phân hóa.
#let exam-violet(body, ..args) = _template(
  body,
  accent: rgb(124, 58, 237),
  q-style: "pill",
  watermark: [VDC],
  ..args,
)

// 06. Crimson: đỏ học thuật, hợp đề thi thử hoặc đề kiểm tra.
#let exam-crimson(body, ..args) = _template(
  body,
  accent: rgb(190, 18, 60),
  q-style: "boxed",
  watermark: [EXAM],
  ..args,
)

// 07. Graphite: đen xám tối giản, in laser rất sạch.
#let exam-graphite(body, ..args) = _template(
  body,
  accent: rgb(51, 65, 85),
  q-style: "bold",
  show-topbar: false,
  watermark: none,
  ..args,
)

// 08. Amber: ấm, hợp phiếu luyện tập hoặc đề cuối tuần.
#let exam-amber(body, ..args) = _template(
  body,
  accent: rgb(180, 83, 9),
  q-style: "pill",
  watermark: [PRACTICE],
  ..args,
)

// 09. Teal Pro: cân bằng giữa trang trọng và hiện đại.
#let exam-teal-pro(body, ..args) = _template(
  body,
  accent: rgb(15, 118, 110),
  q-style: "boxed",
  watermark: [SANG],
  ..args,
)

// 10. Sky: nhẹ, thoáng, hợp tài liệu phát cho học sinh.
#let exam-sky(body, ..args) = _template(
  body,
  accent: rgb(2, 132, 199),
  q-style: "pill",
  watermark: [LEARN],
  watermark-opacity: 0.045,
  ..args,
)

// 11. Indigo Minimal: tiết chế màu, nhiều khoảng thở.
#let exam-indigo-minimal(body, ..args) = _template(
  body,
  accent: rgb(79, 70, 229),
  q-style: "bold",
  show-topbar: true,
  header-border: false,
  watermark: none,
  ..args,
)

// 12. Print Economy: tối ưu in đen trắng, vẫn có cấu trúc rõ.
#let exam-print-economy(body, ..args) = _template(
  body,
  accent: black,
  q-style: "bold",
  show-topbar: false,
  header-border: true,
  watermark: none,
  ..args,
)

// 13. Aurora: xanh sapphire + hơi ngọc, nổi bật nhưng vẫn sạch khi in.
#let exam-aurora(body, ..args) = _template(
  body,
  accent: rgb("#2563eb"),
  q-style: "pill",
  watermark: [AURORA],
  watermark-opacity: 0.04,
  ..args,
)

// 14. Lotus: hồng sen trang nhã, hợp phiếu chuyên đề và tài liệu luyện tập.
#let exam-lotus(body, ..args) = _template(
  body,
  accent: rgb("#be185d"),
  q-style: "pill",
  watermark: [LOTUS],
  watermark-opacity: 0.04,
  ..args,
)

// 15. Navy Gold: xanh than + vàng, phong cách đề chọn lọc cao cấp.
#let exam-navy-gold(body, ..args) = _template(
  body,
  accent: rgb("#1d4ed8"),
  q-style: "boxed",
  watermark: [ELITE],
  watermark-opacity: 0.035,
  ..args,
)

// 16. Jade: xanh ngọc sâu, dịu mắt cho đề có nhiều lời giải.
#let exam-jade(body, ..args) = _template(
  body,
  accent: rgb("#059669"),
  q-style: "pill",
  watermark: [JADE],
  watermark-opacity: 0.045,
  ..args,
)

// 17. Coral: đỏ cam hiện đại, hợp đề kiểm tra ngắn hoặc đề luyện tốc độ.
#let exam-coral(body, ..args) = _template(
  body,
  accent: rgb("#ea580c"),
  q-style: "pill",
  watermark: [FAST],
  watermark-opacity: 0.04,
  ..args,
)

// 18. Plum: tím mận học thuật, hợp chuyên đề nâng cao.
#let exam-plum(body, ..args) = _template(
  body,
  accent: rgb("#7e22ce"),
  q-style: "boxed",
  watermark: [VDC],
  watermark-opacity: 0.04,
  ..args,
)

// Dispatch theme theo chuỗi, giúp demo/HDSD không cần if-else dài.
#let exam-theme(body, theme: "royal", ..args) = {
  if theme == "classic" { exam-classic(body, ..args) }
  else if theme == "ocean" { exam-ocean(body, ..args) }
  else if theme == "emerald" { exam-emerald(body, ..args) }
  else if theme == "royal" { exam-royal(body, ..args) }
  else if theme == "violet" { exam-violet(body, ..args) }
  else if theme == "crimson" { exam-crimson(body, ..args) }
  else if theme == "graphite" { exam-graphite(body, ..args) }
  else if theme == "amber" { exam-amber(body, ..args) }
  else if theme == "teal-pro" { exam-teal-pro(body, ..args) }
  else if theme == "sky" { exam-sky(body, ..args) }
  else if theme == "indigo-minimal" { exam-indigo-minimal(body, ..args) }
  else if theme == "print-economy" { exam-print-economy(body, ..args) }
  else if theme == "aurora" { exam-aurora(body, ..args) }
  else if theme == "lotus" { exam-lotus(body, ..args) }
  else if theme == "navy-gold" { exam-navy-gold(body, ..args) }
  else if theme == "jade" { exam-jade(body, ..args) }
  else if theme == "coral" { exam-coral(body, ..args) }
  else if theme == "plum" { exam-plum(body, ..args) }
  else { exam-royal(body, ..args) }
}

#let _theme-style(theme) = {
  if theme == "classic" { (accent: rgb(0, 87, 184), opt-style: "circle", q-label-style: "underline", boxed: false) }
  else if theme == "ocean" { (accent: rgb(14, 116, 144), opt-style: "hexagon", q-label-style: "pill", boxed: false) }
  else if theme == "emerald" { (accent: rgb(4, 120, 87), opt-style: "solid-circle", q-label-style: "badge", boxed: false) }
  else if theme == "royal" { (accent: rgb(67, 56, 202), opt-style: "pentagon", q-label-style: "spark", boxed: true) }
  else if theme == "violet" { (accent: rgb(124, 58, 237), opt-style: "diamond", q-label-style: "flag", boxed: false) }
  else if theme == "crimson" { (accent: rgb(190, 18, 60), opt-style: "solid-hexagon", q-label-style: "solid-pill", boxed: true) }
  else if theme == "graphite" { (accent: rgb(51, 65, 85), opt-style: "double-circle", q-label-style: "underline", boxed: false) }
  else if theme == "amber" { (accent: rgb(180, 83, 9), opt-style: "rounded-square", q-label-style: "ribbon", boxed: false) }
  else if theme == "teal-pro" { (accent: rgb(15, 118, 110), opt-style: "solid-pentagon", q-label-style: "badge", boxed: true) }
  else if theme == "sky" { (accent: rgb(2, 132, 199), opt-style: "circle", q-label-style: "pill", boxed: false) }
  else if theme == "indigo-minimal" { (accent: rgb(79, 70, 229), opt-style: "plain", q-label-style: "underline", boxed: false) }
  else if theme == "print-economy" { (accent: black, opt-style: "plain", q-label-style: "plain", boxed: false) }
  else if theme == "aurora" { (accent: rgb("#2563eb"), opt-style: "solid-diamond", q-label-style: "spark", boxed: true) }
  else if theme == "lotus" { (accent: rgb("#be185d"), opt-style: "solid-triangle", q-label-style: "flag", boxed: false) }
  else if theme == "navy-gold" { (accent: rgb("#1d4ed8"), opt-style: "solid-hexagon", q-label-style: "solid-pill", boxed: true) }
  else if theme == "jade" { (accent: rgb("#059669"), opt-style: "hexagon", q-label-style: "badge", boxed: true) }
  else if theme == "coral" { (accent: rgb("#ea580c"), opt-style: "solid-square", q-label-style: "ribbon", boxed: false) }
  else if theme == "plum" { (accent: rgb("#7e22ce"), opt-style: "pentagon", q-label-style: "spark", boxed: true) }
  else { (accent: rgb(67, 56, 202), opt-style: "pentagon", q-label-style: "spark", boxed: true) }
}

#let _profile-mode(profile) = if profile == "loigiai" or profile == "solution" or profile == "beamer" or profile == "slide" or profile == "slides" {
  "loigiai"
} else {
  "dethi"
}

#let _bool-input(name, default: false) = {
  let v = sys.inputs.at(name, default: if default { "1" } else { "0" })
  v == "1" or v == "true" or v == "yes" or v == "on"
}

// Preset gọn cho đề PDF và beamer.
// Dùng: #let preset = exam-preset(theme: "royal", profile: "dethi")
// Sau đó: #let (tn, ds, tln, tl) = exam-mode(..preset.question)
#let exam-preset(
  theme: "royal",
  profile: "dethi",
  mode: auto,
  opt-style: auto,
  q-label-style: auto,
  show-tags: false,
  draft: auto,
  two-columns: auto,
  answer-key: auto,
  boxed: auto,
) = {
  let s = _theme-style(theme)
  let real-mode = if mode == auto { _profile-mode(profile) } else { mode }
  let is-beamer = profile == "beamer" or profile == "slide" or profile == "slides"
  let real-draft = if draft == auto { profile == "draft" } else { draft }
  let real-two-columns = if two-columns == auto { profile == "compact" or profile == "twocol" } else { two-columns }
  let real-answer-key = if answer-key == auto { profile == "answer" or profile == "loigiai" } else { answer-key }
  let real-boxed = if boxed == auto { s.boxed } else { boxed }
  let accent = s.accent
  (
    theme: theme,
    profile: profile,
    mode: real-mode,
    accent: accent,
    beamer: is-beamer,
    question: (
      mode: real-mode,
      accent: accent,
      opt-style: if opt-style == auto { "plain" } else if opt-style == "theme" { s.opt-style } else { opt-style },
      opt-label-color: if theme == "print-economy" { auto } else { accent },
      q-label-style: if q-label-style == auto { s.q-label-style } else { q-label-style },
      show-tags: show-tags,
      draft: real-draft,
      draft-width: 28%,
      draft-lines: 6,
      boxed: real-boxed,
      box-fill: accent.lighten(94%),
      box-stroke: 0.55pt + accent.lighten(55%),
    ),
    template: (
      two-columns: real-two-columns,
      answer-key: real-answer-key,
      beamer: is-beamer,
    ),
    beamer-theme: (
      accent: accent,
      bg_color: if theme == "print-economy" { white } else { rgb("#0f172a") },
      math_color: if theme == "amber" or theme == "coral" { rgb("#fbbf24") } else { rgb("#f59e0b") },
    ),
  )
}

// Preset đọc từ dòng lệnh compile:
// --input theme=royal --input profile=loigiai --input answer-key=1
#let exam-input-preset(default-theme: "royal", default-profile: "dethi") = {
  let theme = sys.inputs.at("theme", default: default-theme)
  let profile = if _bool-input("beamer", default: false) {
    "beamer"
  } else {
    sys.inputs.at("profile", default: sys.inputs.at("mode", default: default-profile))
  }
  exam-preset(
    theme: theme,
    profile: profile,
    mode: sys.inputs.at("mode", default: auto),
    opt-style: sys.inputs.at("opt-style", default: auto),
    q-label-style: sys.inputs.at("q-label-style", default: auto),
    draft: _bool-input("draft", default: profile == "draft"),
    two-columns: _bool-input("two-columns", default: profile == "compact" or profile == "twocol"),
    answer-key: _bool-input("answer-key", default: profile == "answer" or profile == "loigiai"),
  )
}

// Danh sách tên theme để dùng trong tài liệu/ứng dụng ngoài.
#let exam-template-names = (
  "classic",
  "ocean",
  "emerald",
  "royal",
  "violet",
  "crimson",
  "graphite",
  "amber",
  "teal-pro",
  "sky",
  "indigo-minimal",
  "print-economy",
  "aurora",
  "lotus",
  "navy-gold",
  "jade",
  "coral",
  "plum",
)
