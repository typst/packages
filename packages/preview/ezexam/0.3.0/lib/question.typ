#import "state.typ": mode-state
#import "const.typ": HANDOUTS, QUESTION
#import "counter.typ": counter-chapter, counter-placeholder, counter-question
#import "tools.typ": _modify-space, _trim-math-start-spacing

#let _format-label(label, label-color, label-weight, with-heading-label) = context counter-question.display(num => {
  let _label = label
  let mode = mode-state.get()
  if label == auto {
    _label = "1."
    if mode == HANDOUTS and with-heading-label {
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
  if mode == HANDOUTS { return result }
  box(width: 1em, align(right, result))
})

#let _format-points(points, prefix, suffix, separate) = {
  if points == none { return }
  assert(type(points) == int and points > 0, message: "points be a positive integer!")
  [#prefix#points#suffix#if separate [ \ ]]
}

#let _ref-label(with-heading-label, supplement) = {
  let q-num = str(counter-question.get().first() + 1) // 题号
  if with-heading-label {
    let heading-label = counter(heading).get().filter(item => item != 0).map(str)
    if heading-label != () { q-num = (..heading-label, q-num).join(".") }
  }
  let chapter = counter-chapter.get().first()
  if chapter == 0 { chapter = "1" }
  label(supplement + str(chapter) + "-" + q-num)
}

#let question(
  body,
  indent: 0em,
  first-line-indent: 0em,
  hanging-indent: auto,
  label: auto,
  label-color: black,
  label-weight: 400,
  with-heading-label: false,
  points: none,
  points-separate: true,
  points-prefix: h(-.45em, weak: true) + "（",
  points-suffix: "分）",
  line-height: auto,
  top: 0pt,
  bottom: 0pt,
  ref-on: false,
  supplement: none,
) = context{
  let _label = _format-label(
    label,
    label-color,
    label-weight,
    with-heading-label,
  )
  let _hanging-indent = if hanging-indent == auto { measure(_label).width + 1em } else { hanging-indent }
  set par(leading: line-height) if line-height != auto

  v(top)
  [#figure(supplement: supplement, kind: QUESTION)[
      #let body = _trim-math-start-spacing[#body]
      #let modeify-space = _modify-space(body)
      #if modeify-space == none { panic("Block-level formulas are not allowed at the beginning!") }
      #terms(
        indent: indent,
        hanging-indent: _hanging-indent,
        separator: h(1em, weak: true),
        (
          _label,
          _format-points(
            points,
            points-prefix,
            points-suffix,
            points-separate,
          )
            + h(first-line-indent - modeify-space, weak: true)
            + body,
        ),
      )
    ]
    #if ref-on { _ref-label(with-heading-label, supplement) }
  ]
  v(bottom)
  // 更新占位符上的题号
  context counter-placeholder.update(..counter-question.get())
}
