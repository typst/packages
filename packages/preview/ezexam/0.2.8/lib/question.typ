#import "const-state.typ": HANDOUTS, mode-state
#import "tools.typ": _content-start-space, _trim-content-start-parbreak

#let _format-label(label, label-color, label-weight, with-heading-label) = context counter(
  "question",
).display(num => {
  let _label = label
  if label == auto {
    _label = "1."
    if mode-state.get() == HANDOUTS and with-heading-label {
      _label = "1.1.1.1.1.1."
    }
  }
  let arr = (num,)
  if with-heading-label {
    // 去除heading label数组中的0
    arr = counter(heading).get().filter(item => item != 0) + arr
  }

  let result = text(
    label-color,
    weight: label-weight,
    numbering(_label, ..arr),
  )

  if mode-state.get() == HANDOUTS { return result }
  box(width: 1em, align(right, result))
})

#let _format-points(points, prefix, suffix, separate) = {
  if points == none { return }
  assert(type(points) == int and points > 0, message: "points be a positive integer!")
  [#prefix#points#suffix#if separate [ \ ]]
}

#let question(
  body,
  indent: 0em,
  first-line-indent: 0em,
  hanging-indent: auto,
  label: auto,
  label-color: luma(0),
  label-weight: 400,
  with-heading-label: false,
  points: none,
  points-separate: true,
  points-prefix: h(-0.45em, weak: true) + "（",
  points-suffix: "分）",
  line-height: auto,
  top: 0pt,
  bottom: 0pt,
) = context {
  counter("question").step()
  set par(leading: line-height) if line-height != auto
  let _label = _format-label(
    label,
    label-color,
    label-weight,
    with-heading-label,
  )
  let _hanging-indent = hanging-indent
  if hanging-indent == auto { _hanging-indent = measure(_label).width + 1em }

  v(top)
  terms(
    indent: indent,
    hanging-indent: _hanging-indent,
    separator: h(.9em, weak: true),
    (
      _label,
      _format-points(
        points,
        points-prefix,
        points-suffix,
        points-separate,
      )
        + h(first-line-indent - _content-start-space[#body], weak: true)
        + _trim-content-start-parbreak[#body],
    ),
  )
  v(bottom)
  // 更新占位符上的题号
  context counter("placeholder").update(counter("question").get().first())
}
