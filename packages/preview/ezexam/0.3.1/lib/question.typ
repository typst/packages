#import "state.typ": mode-state
#import "const.typ": HANDOUTS, QUESTION
#import "counter.typ": counter-chapter, counter-placeholder, counter-question
#import "tools.typ": _modify-space, _trim-math-start-spacing

#let _format-label(label, label-color, label-weight, with-heading-label) = context counter-question.display(num => {
  let numbers = if with-heading-label { counter(heading).get().filter(item => item != 0) } + (num,)
  let result = text(label-color, weight: label-weight, numbering(label, ..numbers))
  if mode-state.get() == HANDOUTS { return result }
  box(width: 1em, align(right, result))
})

#let _format-points(points, prefix, suffix, separate) = {
  if points == none { return }
  assert(type(points) == int and points > 0, message: "points expected positive integer!")
  [#prefix#points#suffix#if separate [ \ ]]
}

#let _format-ref-prefix() = {
  let chapter = counter-chapter.get().first()
  if chapter == 0 { chapter = "1" }
  let heading-label = counter(heading).get().filter(item => item != 0)
  str(chapter) + if heading-label != () { "-" + heading-label.map(str).join(".") } + "-"
}

#let question(
  body,
  indent: 0em,
  first-line-indent: 0em,
  hanging-indent: auto,
  label: "1.1.1.1.1.1.",
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
  show-ref-prefix: true,
  supplement: none,
) = context {
  assert(supplement != auto, message: "supplement expected none, str, content, function")
  let _label = _format-label(label, label-color, label-weight, with-heading-label)
  set par(leading: line-height) if line-height != auto
  let _ref-prefix = none
  v(top)
  [#figure(
      supplement: if ref-on {
        _ref-prefix = _format-ref-prefix()
        supplement + if show-ref-prefix [#_ref-prefix.replace("-", " - ")#h(-.25em, weak: true)]
        _ref-prefix = std.label(_ref-prefix + str(counter-question.get().first() + 1))
      },
      kind: QUESTION,
    )[
      #let body = _trim-math-start-spacing[#body]
      #let modeify-space = _modify-space(body)
      #if modeify-space == none { panic("Block-level formulas are not allowed at the beginning!") }
      #terms(
        indent: indent,
        hanging-indent: if hanging-indent == auto { measure(_label).width + 1em } else { hanging-indent },
        separator: h(1em, weak: true),
        (
          _label,
          _format-points(points, points-prefix, points-suffix, points-separate)
            + h(first-line-indent - modeify-space, weak: true)
            + body,
        ),
      )
    ]
    #_ref-prefix
  ]
  v(bottom)
  // 更新占位符上的题号
  context counter-placeholder.update(..counter-question.get())
}
