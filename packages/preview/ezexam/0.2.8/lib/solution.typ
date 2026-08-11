#import "const-state.typ": answer-state
#import "tools.typ": _trim-content-start-parbreak
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
  assert(type(inset) == dictionary, message: "inset must be a dictionary")
  v(top)
  block(
    width: 100%,
    breakable: breakable,
    inset: (top: 20pt, bottom: 20pt) + inset,
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
    #if show-number {
      _label = context numbering("1.", ..counter("explain").get())
    }
    #set par(leading: line-height) if line-height != auto
    #let _space = 0em
    #if show-number { _space = .75em }
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
