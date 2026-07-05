#import "const-state.typ": HANDOUTS, mode-state

#let _question-points-set(points, prefix, suffix, separate, body) = {
  assert(type(points) == int or points == none, message: "points must be a int or none")

  if points == none { return body }

  [#prefix#points#suffix #if separate [ \ ] #body]
}

#let _format-question-number(label, label-color, label-weight, with-heading-label) = {
  // 格式化题号
  counter("question").step()
  context counter("question").display(num => {
    let _label = label
    if label == auto {
      _label = "1."
    }

    let arr = (num,)
    if with-heading-label {
      _label = "1.1.1.1.1.1."
      // 去除heading label数组中的0
      arr = counter(heading).get().filter(item => item != 0) + arr
    }
    text(
      label-color,
      weight: label-weight,
      numbering(_label, ..arr),
    )
  })
}

#let question(
  body,
  body-indent: .85em,
  indent: 0pt,
  label: auto,
  label-color: luma(0),
  label-weight: 400,
  with-heading-label: false,
  points: none,
  points-separate: true,
  points-prefix: "（",
  points-suffix: "分）",
  line-height: auto,
  top: 0pt,
  bottom: 0pt,
  padding-top: 0pt,
  padding-bottom: 0pt,
) = context {
  // 分数设置
  let _body = _question-points-set(
    points,
    points-prefix,
    points-suffix,
    points-separate,
    body,
  )

  // 格式化题号
  let _marker = _format-question-number(
    label,
    label-color,
    label-weight,
    with-heading-label,
  )

  set par(leading: line-height) if line-height != auto

  let _indent = indent
  if mode-state.get() == HANDOUTS {
    _indent -= 1em - measure(_marker).width + .14em
  }

  v(top - padding-top)
  list(
    marker: box(align(right, _marker), width: 1em, inset: (top: .5pt)),
    body-indent: body-indent,
    indent: _indent,
    pad(top: padding-top, bottom: padding-bottom, _body),
  )
  v(bottom)

  // 更新占位符上的题号
  context counter("placeholder").update(counter("question").get().first())
}
