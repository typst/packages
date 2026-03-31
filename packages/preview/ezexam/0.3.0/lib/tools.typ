#import "const.typ": EXAM, INLINE_MATH_SPACE
#import "config.typ": heiti
#import "counter.typ": counter-title
#import "state.typ": chapter-pages-state, mode-state, page-restart-state

#let _is_empty(body) = body in ([ ], parbreak(), [])

// 去除content开头的空行，换行
#let _trim-content(body) = {
  if _is_empty(body) { return body }
  if body.has("children") {
    let children = body.children
    if _is_empty(children.first()) { return children.slice(1).join() }
  }
  body
}

#let _SPECIAL-CHAR = "《（【"
#let _SPECIAL-CHAR-SPACE = .45em
// 为了解决数学公式、特殊字符在最左侧没有内容时加间距的问题
#let _modify-space(body) = {
  if _is_empty(body) { return }
  if body.has("children") { body = body.children.first() }
  if body.func() == math.equation {
    if body.block { return }
    return INLINE_MATH_SPACE
  }
  if body.has("text") and body.text.first() in _SPECIAL-CHAR { return _SPECIAL-CHAR-SPACE }
  0em
}

// 去除数学公式在 question 方法中，换行后以数学公式开头时，最左侧加间距的问题
// typst留下的坑
#let _trim-math-start-spacing(body) = {
  body = _trim-content(body)
  if not body.has("children") { return body }

  let children = body.children
  if parbreak() not in children { return body }
  children.map(child => if child == parbreak() [ \ ] else { child }).join()
}

// 生成弥封线
#let _create-seal(
  info: (:),
  line-type: "dashed",
  decoration: none,
  supplement: none,
  rotate-deg: 0deg,
  rotate-origin: center + horizon,
) = rotate(rotate-deg, origin: rotate-origin)[
  #assert(type(info) == dictionary, message: "expected dictionary, found " + str(type(info)))
  #set par(spacing: 10pt)
  #set text(font: heiti, 12pt)
  #set align(center)
  #set grid(columns: 2, align: horizon, gutter: .5em)
  #if supplement != none { text(tracking: .8in, supplement) }
  #grid(
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
  #if decoration == none {
    line(length: 100%, stroke: (dash: line-type))
  } else {
    let data = (
      "circle": 4 * (circle(width: 1.25em, stroke: .5pt),),
      "text": ("弥", "封", "线", none),
    )
    let seal-line = (4 * (line(length: 100%, stroke: (dash: line-type)),))
      .zip(data.at(decoration))
      .flatten()
      .slice(0, -1)
    grid(
      columns: seal-line.len(),
      align: horizon,
      ..seal-line,
    )
  }
]

// 一种页码格式: "第x页（共xx页）
#let zh-arabic(prefix: none, suffix: none) = (..nums) => {
  let arr = nums.pos()
  [#prefix;第#arr.first()页（共#arr.last()页）#suffix]
}

#let tag(
  body,
  color: blue,
  font: auto,
  weight: 400,
  prefix: h(-_SPECIAL-CHAR-SPACE, weak: true) + "【",
  suffix: "】",
) = context {
  let _font = if font == auto { heiti + text.font } else { font }
  text(font: _font, weight: weight, color)[#prefix#body#suffix#h(0em, weak: true)]
}

// 图文混排
#let _TEXT_LEFT_FIGURE_RIGHT = "tf"
#let _FIGURE_LEFT_TEXT_RIGHT = "ft"
#let text-figure(
  figure: none,
  figure-x: 0pt,
  figure-y: 0pt,
  top: 0pt,
  bottom: 0pt,
  gap: 0pt,
  style: _TEXT_LEFT_FIGURE_RIGHT,
  text,
) = context {
  assert(
    style in (_TEXT_LEFT_FIGURE_RIGHT, _FIGURE_LEFT_TEXT_RIGHT),
    message: "style expected " + _TEXT_LEFT_FIGURE_RIGHT + ", " + _FIGURE_LEFT_TEXT_RIGHT,
  )
  let body = (
    text, // [ \ ] 是为了在当前页还有一行时，换页
    [ \ ] + box(place(dx: figure-x, dy: figure-y - par.leading * 2, figure)),
  )

  let _columns = (1fr, measure(figure).width)
  let _gap = -figure-x + gap
  if style == _FIGURE_LEFT_TEXT_RIGHT {
    body = body.rev()
    _columns = _columns.rev()
    _gap = figure-x + gap
  }

  grid(
    columns: _columns,
    inset: (
      top: top,
      bottom: bottom,
    ),
    gutter: _gap,
    ..body,
  )
}

#let page-restart(num: 1) = context {
  assert(type(num) == int, message: "num expected integer")
  pagebreak(weak: true)
  let chapter-index = counter-title.get().first() - 1
  let chapter-final = counter-title.final().first() - 1
  if chapter-index < 0 or chapter-index == chapter-final { return } // 处于目录页或最后一页时，不重新开始页码
  let current = counter(page).get().first() - 1
  let page-restart = page-restart-state.get()
  // 如果重新开始页码，则将之前的页码总数更新到当前页码 - 1
  chapter-pages-state.update(pre => {
    for index in range(page-restart, chapter-index + 1) {
      pre.at(index).total-page = current
    }
    pre
  })
  page-restart-state.update(chapter-index + 1)
  counter(page).update(num)
}
