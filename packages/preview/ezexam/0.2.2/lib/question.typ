#import "const-state.typ": HANDOUTS, mode-state

#let question(
  body,
  body-indent: .88em,
  indent: 0pt,
  label: auto,
  label-color: luma(0),
  label-weight: 400,
  with-heading-label: false,
  points: none,
  points-separate: true,
  points-prefix: "（",
  points-suffix: "分）",
  top: 0pt,
  bottom: 0pt,
  padding-top: 0pt,
  padding-bottom: 0pt,
) = {
  // 分数设置
  assert(type(points) == int or points == none, message: "points must be a int or none")
  if points != none {
    body = [#points-prefix#points#points-suffix #if points-separate [ \ ] #body]
  }

  // 格式化题号
  counter("question").step()
  let _format = context counter("question").display(num => {
    let _label = label
    if label == auto {
      if mode-state.get() == HANDOUTS {
        _label = "【1.1.1.1.1.1】"
      } else {
        _label = "1."
      }
    }

    let arr = (num,)
    if with-heading-label {
      // 去除heading label数组中的0
      arr = counter(heading).get().filter(item => item != 0) + arr
    }
    text(
      label-color,
      weight: label-weight,
      box(
        align(right, numbering(_label, ..arr)),
        width: 1em,
      ),
    )
  })

  v(top - padding-top)
  list(
    marker: _format,
    body-indent: body-indent,
    indent: indent,
    pad(top: padding-top, bottom: padding-bottom, body),
  )
  v(bottom)

  // 更新占位符上的题号
  context counter("placeholder").update(counter("question").get().first())
}
