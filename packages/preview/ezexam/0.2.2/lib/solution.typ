#import "const-state.typ": answer-state
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
  top: 0pt,
  bottom: 0pt,
  padding-top: 0pt,
  padding-bottom: 0pt,
  inset: (rest: 10pt, top: 20pt, bottom: 20pt),
  show-number: true,
) = context {
  if not answer-state.get() { return }
  assert(type(inset) == dictionary, message: "inset must be a dictionary")
  let _inset = (rest: 10pt, top: 20pt, bottom: 20pt) + inset
  v(top)
  block(
    width: 100%,
    breakable: breakable,
    inset: _inset,
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
      let _title-height = measure(title-box).height
      place(
        title-align,
        dx: title-x,
        dy: -_inset.top - _title-height / 2 + title-y,
      )[#title-box]
    }

    // 解析题号的格式化
    #counter("explain").step()
    #let format = context () => {
      numbering("1.", ..counter("explain").get())
    }

    #list(
      marker: if show-number { format } else { none },
      pad(top: padding-top, bottom: padding-bottom, text(color, body)),
    )
  ]
  v(bottom)
}

// 解析的分值
#let score(points, color: maroon, score-prefix: "", score-suffix: "分") = text(color)[
  #box(width: 1fr, repeat($dot$))#score-prefix#h(2pt)#points#score-suffix
]

#let answer(body, color: maroon) = par(text(weight: 700, color)[答案: #body])
