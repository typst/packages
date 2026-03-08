#import "const-state.typ": *

// 封面
#let cover(
  title: "ezexam",
  subtitle: none,
  author: none,
  date: auto,
) = {
  set page(footer: none, header: none, columns: 1)
  set align(center + horizon)
  text(size: 25pt)[#title]

  if subtitle != none {
    text(font: hei-ti, size: 22pt)[\ #subtitle]
  }

  if author != none {
    text(font: kai-ti, size: 15pt)[\ 作者：#author]
  }

  if date != none [
    \ #if date == auto [
      #datetime.today().year()/#datetime.today().month()/#(
        datetime.today().day()
      )]
  ]
}

#let chapter(body) = {
  pagebreak(weak: true)
  counter("chapter").step()
  set heading(numbering: _ => counter("chapter").display("一、"))
  place(hide[= #body <chapter>])
}

#let title(
  body,
  size: 15pt,
  weight: 700,
  font: auto,
  color: luma(0),
  position: center,
  top: 0pt,
  bottom: 18pt,
) = context {
  v(top)
  let _font = font
  if _font == auto { _font = text.font }
  align(position, text(font: _font, size, weight: weight, color)[#body <title>])
  v(bottom)
  counter(heading).update(0)
  counter("question").update(0)
}

#let subject(body, size: 21.5pt, spacing: 1em, font: hei-ti, top: -20pt, bottom: 0pt) = {
  v(top)
  align(center, text(
    font: font,
    size: size,
    [#body].text.split("").slice(1, -1).join(h(spacing)),
  ))
  v(bottom)
  subject-state.update([#body].text)
}

#let secret(body: [绝密★启用前]) = place(top, float: true, clearance: 20pt, text(font: hei-ti, body))

#let exam-type(type, prefix: "试卷类型: ") = context place(top + right, text(
  font: text.font.slice(0, 2) + hei-ti,
)[#prefix#type])

#let exam-info(
  info: (
    时间: "120分钟",
    满分: "150分",
  ),
  weight: 500,
  font: auto,
  size: 11pt,
  gap: 2em,
  top: 0pt,
  bottom: 0pt,
) = context {
  assert(info.len() > 0, message: "info cannot be empty")
  set text(font: text.font.slice(0, 2) + hei-ti, size: size, weight: weight)
  set align(center)
  grid(
    columns: info.len(),
    gutter: gap,
    inset: (top: top, bottom: bottom),
    align: center + horizon,
    ..for (key, value) in info {
      ([#key: #value],)
    }
  )
}

#let scoring-box(x: 0pt, y: 0pt) = place(dx: x, dy: y, right + top, table(
  columns: 2,
  inset: 8pt,
)[得分][~~~~~~~~~][阅卷人])

#let score-box(x: 0pt, y: 0pt) = place(dx: x, dy: y, right + top, table(
  inset: 8pt,
)[得分][~~~~~~~~~#v(10pt)])

#let notice(format: "1.", indent: 2em, hanging-indent: auto, ..children) = context {
  text(font: hei-ti)[注意事项:]
  set enum(numbering: format, indent: indent)
  set par(hanging-indent: if hanging-indent == auto {
    -indent - enum.body-indent - measure(format).width
  } else { hanging-indent })
  for value in children.pos() [+ #par(value)]
}

