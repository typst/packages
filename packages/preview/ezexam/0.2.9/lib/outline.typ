#import "const-state.typ": *
#import "tools.typ": _trim-content-start-parbreak

// 封面
#let cover(
  title: EXAM,
  subtitle: none,
  author: none,
  date: auto,
) = {
  set page(footer: none, columns: 1)
  set align(center + horizon)
  text(size: 25pt, title)

  if subtitle != none {
    text(font: heiti, size: 22pt)[\ #subtitle]
  }

  if author != none {
    text(font: "STKaiti", size: 15pt)[\ 作者：#author \ ]
  }

  if date == auto { datetime.today().display("[year]年[month]月[day]日") } else { date }
}

#let chapter(body) = {
  pagebreak(weak: true)
  counter("chapter").step()
  set heading(numbering: _ => counter("chapter").display(it => box(width: .6em, align(right)[#it.~])))
  place(hide[= #body <chapter>])
}

#let title(
  body,
  size: auto,
  weight: 400,
  font: auto,
  color: luma(0),
  position: center,
  top: 0pt,
  bottom: 0pt,
) = context {
  let mode = mode-state.get()
  v(top)
  align(
    position,
    text(
      weight: weight + if mode != EXAM { 300 },
      font: if font == auto { text.font } else { font },
      size: if size == auto {
        if mode == HANDOUTS { 20pt } else { 16pt }
      } else { size },
      color,
      body,
    ),
  )
  v(bottom)
  counter(heading).update(0)
  counter("question").update(0)
  counter("title").step()

  // 收集章节的第一页和最后一页
  let current-page = counter(page).get()
  let final-page = counter(page).final()
  let final-chapter = counter("title").final().first()
  chapter-pages-state.update(pre => {
    if pre != () and pre.last().len() == 1 {
      pre.last() += (current-page.first() - 1, ..final-page)
    }
    pre.push(current-page)
    pre
  })
}

#let subject(body, size: 21.5pt, spacing: 1em, font: heiti, top: 0pt, bottom: 0pt) = {
  v(top)
  align(center, text(
    font: font,
    size: size,
    [#body].text.split("").slice(1, -1).join(h(spacing)),
  ))
  v(bottom)
  subject-state.update([#body].text)
}

#let secret(body: "绝密★启用前") = place(top, float: true, clearance: 1.5em, text(font: heiti, body, size: 10.5pt))

#let exam-type(type, prefix: "试卷类型: ") = context place(top + right, text(
  font: heiti + text.font,
  prefix + type,
))

#let exam-info(
  info: (
    时间: "120分钟",
    满分: "150分",
  ),
  weight: 500,
  font: auto,
  size: 1em,
  gap: 2em,
  top: 0pt,
  bottom: 0pt,
) = context {
  assert(info.len() > 0, message: "info cannot be empty")
  set text(font: heiti + text.font, size: size, weight: weight)
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

#let notice(label: "1.", indent: 2em, hanging-indent: auto, ..children) = context {
  text(font: heiti)[注意事项:]
  set enum(numbering: label, indent: indent)
  set par(
    hanging-indent: if hanging-indent == auto {
      -indent - enum.body-indent - measure(label).width
    } else { hanging-indent },
    leading: 1.3em,
  )
  for child in children.pos() [+ #par(child)]
}

#let solution-block(name: "参考答案", body) = context {
  if not answer-state.get() { return }
  let pre-mode = mode-state.get()
  let set-mode(_mode) = mode-state.update(_mode)
  counter("explain").update(0) // 解析题号从 1 开始重新编号
  pagebreak(weak: true)
  set-mode(SOLUTION)
  title(name)
  body
  pagebreak(weak: true)
  set-mode(pre-mode)
}

#let solution(
  body,
  title: none,
  title-size: 12pt,
  title-weight: 700,
  title-color: luma(100%),
  title-bg-color: maroon,
  title-radius: 5pt,
  title-align: top + center,
  title-x: 0pt,
  title-y: 0pt,
  border-style: "dashed",
  border-width: .5pt,
  border-color: maroon,
  color: blue,
  radius: 5pt,
  bg-color: luma(100%),
  breakable: true,
  line-height: auto,
  top: 0pt,
  bottom: 0pt,
  inset: (x: 10pt, top: 20pt, bottom: 20pt),
  show-number: true,
) = context {
  if not answer-state.get() { return }
  assert(type(inset) == dictionary, message: "inset expected dictionary, found " + str(type(inset)))
  v(top)
  block(
    width: 100%,
    breakable: breakable,
    inset: (x: 10pt, top: 20pt, bottom: 20pt) + inset,
    radius: radius,
    stroke: (thickness: border-width, paint: border-color, dash: border-style),
    fill: bg-color,
  )[
    // 标题
    #if title != none {
      let title-box = box(fill: title-bg-color, inset: 6pt, radius: title-radius, text(
        size: title-size,
        weight: title-weight,
        tracking: 3pt,
        title-color,
        title,
      ))
      place(
        title-align,
        dx: title-x,
        dy: -inset.top - measure(title-box).height / 2 + title-y,
        title-box,
      )
    }

    // 解析题号的格式化
    #counter("explain").step()
    #let _label = none
    #let _space = 0em
    #if show-number {
      _label = context numbering("1.", ..counter("explain").get())
      _space = .75em
    }
    #set par(leading: line-height) if line-height != auto
    #terms(
      hanging-indent: 0em,
      separator: h(_space, weak: true),
      (
        _label,
        text(color, _trim-content-start-parbreak(body)),
      ),
    )
  ]
  v(bottom)
}

// 解析的分值
#let score(points, color: maroon, score-prefix: h(.2em), score-suffix: "分") = text(color)[#box(width: 1fr, repeat(
    $dot$,
  ))#score-prefix#points#score-suffix]


