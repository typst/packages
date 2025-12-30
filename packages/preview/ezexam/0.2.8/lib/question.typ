#import "const-state.typ": HANDOUTS, mode-state
#import "tools.typ": _content-start-space, _trim-content-start-parbreak

#let _format-label(label, label-color, label-weight, with-heading-label) = box(width: 1em, align(right)[
  #context counter(
    "question",
  ).display(num => {
    let _label = label
    if label == auto { _label = "1." }
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
])

#let _format-points(points, prefix, suffix, separate) = {
  if points == none { return }
  assert(type(points) == int and points > 0, message: "points be a positive integer!")
  [#prefix#points#suffix#if separate [ \ ]]
}

#let question(
  body,
  indent: 0em,
  first-line-indent: 0em,
  hanging-indent: 2em,
  label: auto,
  label-color: luma(0),
  label-weight: 400,
  with-heading-label: false,
  points: none,
  points-separate: true,
  points-prefix: h(-.4em, weak: true) + "（",
  points-suffix: "分）",
  line-height: auto,
  top: 0pt,
  bottom: 0pt,
) = /* context */ {
  counter("question").step()
  set par(leading: line-height) if line-height != auto
  first-line-indent -= _content-start-space[#body]
  v(top)
  terms(
    indent: indent,
    hanging-indent: hanging-indent,
    separator: h(.9em, weak: true),
    (
      _format-label(
        label,
        label-color,
        label-weight,
        with-heading-label,
      ),
      _format-points(
        points,
        points-prefix,
        points-suffix,
        points-separate,
      )
        + h(first-line-indent, weak: true)
        + _trim-content-start-parbreak[#body],
    ),
  )
  v(bottom)
  // 更新占位符上的题号
  context counter("placeholder").update(counter("question").get().first())
}
