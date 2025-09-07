#import "const-state.typ": *

#let chapter(name) = context {
  pagebreak(weak: true)
  counter("chapter").step()
  set heading(numbering: _ => counter("chapter").display("一、"))
  place(top, hide[= #name <chapter>])
}

#let title(
  name,
  size: 15pt,
  weight: "bold",
  font: source-han,
  color: black,
  position: center,
  top: 0pt,
  bottom: 18pt,
) = {
  v(top)
  align(position, text(font: font, size, weight: weight, color)[#name <title>])
  v(bottom)
  counter(heading).update(0)
  counter("question").update(0)
}

#let subject(name, size: 21.5pt, spacing: 1em, font: hei-ti, top: -20pt, bottom: 0pt) = {
  v(top)
  align(center, text(
    font: font,
    size: size,
    name.text.split("").slice(1, -1).join(h(spacing)),
  ))
  v(bottom)
  subject-state.update(name.text)
}

#let secret(body: [绝密★启用前]) = {
  place(top, text(font: "SimHei", body))
}

#let exam-type(type, prefix: "试卷类型: ") = {
  place(top + right, text(font: hei-ti)[#prefix#type])
}

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
  if info.len() == 0 { return }
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

#let scoring-box(x: 0pt, y: 0pt) = {
  place(dx: x, dy: y, right + top)[
    #table(
      columns: (auto, 1.6cm),
      inset: 8pt,
    )[得分][][阅卷人]
  ]
}

#let score-box(x: 0pt, y: 0pt) = {
  place(dx: x, dy: y, right + top)[
    #table(
      rows: (auto, 1.2cm),
      inset: 8pt,
    )[得分][#h(3em)]
  ]
}

#let notice(format: "1.", ..items) = context {
  text(font: hei-ti)[注意事项:]
  let indent = 2em
  set enum(numbering: format, indent: indent)
  set par(hanging-indent: -indent - enum.body-indent - measure(format).width)
  let arr = items.pos()
  for value in arr [+ #par(value)]
}

// 一种页码格式: "第x页（共xx页）
#let zh-arabic(prefix: "", suffix: "") = (..nums) => {
  let arr = nums.pos()
  [#prefix#h(1em)#subject-state.get()#suffix#h(1em)第#str(arr.at(0))页（共#str(arr.at(-1))页）]
}

#let inline-square(num, width: 1.5em, gap: 0pt, body: "") = {
  set square(stroke: .5pt, width: width)
  grid(
    columns: num,
    gutter: gap,
    ..num * (square(body),)
  )
}

#let _create-seal(
  dash: "dashed",
  supplement: "",
  info: (:),
) = {
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
