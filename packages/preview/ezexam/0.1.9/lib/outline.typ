#import "const-state.typ": *

#let chapter(body) = {
  pagebreak(weak: true)
  counter("chapter").step()
  set heading(numbering: _ => counter("chapter").display("一、"))
  place(top, hide[= #body <chapter>])
}

#let title(
  body,
  size: 15pt,
  weight: "bold",
  font: source-han,
  color: black,
  position: center,
  top: 0pt,
  bottom: 18pt,
) = {
  v(top)
  align(position, text(font: font, size, weight: weight, color)[#body <title>])
  v(bottom)
  counter(heading).update(0)
  counter("question").update(0)
}

#let subject(body, size: 21.5pt, spacing: 1em, font: hei-ti, top: -20pt, bottom: 0pt) = {
  v(top)
  align(center, text(
    font: font,
    size: size,
    body.text.split("").slice(1, -1).join(h(spacing)),
  ))
  v(bottom)
  subject-state.update(body.text)
}

#let secret(body: [绝密★启用前]) = place(top, float: true, clearance: 20pt, text(font: "SimHei", body))

#let exam-type(type, prefix: "试卷类型: ") = place(top + right, text(
  font: hei-ti,
)[#prefix#type])

#let exam-info(
  info: (
    时间: "120分钟",
    满分: "150分",
  ),
  weight: 500,
  font: hei-ti,
  size: 11pt,
  gap: 2em,
  top: 0pt,
  bottom: 0pt,
) = {
  assert(info.len() > 0, message: "info cannot be empty")
  set align(center)
  grid(
    columns: info.len(),
    gutter: gap,
    inset: (top: top, bottom: bottom),
    align: center + horizon,
    ..for (key, value) in info {
      (text(size: size, font: font, weight: weight)[#key: #value],)
    }
  )
}

#let scoring-box(x: 0pt, y: 0pt) = place(dx: x, dy: y, right + top)[
  #table(
    columns: (auto, 1.6cm),
    inset: 8pt,
  )[得分][][阅卷人]
]

#let score-box(x: 0pt, y: 0pt) = place(dx: x, dy: y, right + top)[
  #table(
    rows: (auto, 1.2cm),
    inset: 8pt,
  )[得分][#h(3em)]
]

#let notice(format: "1.", indent: 2em, hanging-indent: auto, ..children) = context {
  text(font: hei-ti)[注意事项:]
  set enum(numbering: format, indent: indent)
  set par(hanging-indent: if hanging-indent == auto {
    -indent - enum.body-indent - measure(format).width
  } else { hanging-indent })
  for value in children.pos() [+ #par(value)]
}

#let _create-seal(
  dash: "dashed",
  supplement: "",
  info: (:),
) = {
  assert(type(info) == dictionary, message: "expected dictionary, found " + str(type(info)))
  set par(spacing: 10pt)
  set text(font: hei-ti, size: 12pt)
  set align(center)
  set grid(columns: 2, align: horizon, gutter: .5em)
  if supplement != "" { text(tracking: .8in, supplement) }
  grid(
    columns: if info.len() == 0 { 1 } else { info.len() },
    gutter: 1em,
    ..for (key, value) in info {
      (
        grid(
          key,
          value,
        ),
      )
    }
  )
  line(length: 100%, stroke: (dash: dash))
}

#let draft(
  name: "草稿纸",
  student-info: (
    姓名: underline[~~~~~~~~~~~~~],
    准考证号: underline[~~~~~~~~~~~~~~~~~~~~~~~~~~],
    考场号: underline[~~~~~~~],
    座位号: underline[~~~~~~~],
  ),
  dash: "solid",
  supplement: "",
) = {
  set page(margin: .5in, header: none, footer: none)
  title(name.split("").join(h(1em)), bottom: 0pt)
  _create-seal(dash: dash, supplement: supplement, info: student-info)
}
