#import "const-state.typ": kai-ti
// 一种页码格式: "第x页（共xx页）
#let zh-arabic(prefix: "", suffix: "") = (..nums) => {
  let arr = nums.pos()
  [#prefix 第#str(arr.at(0))页（共#str(arr.at(-1))页）#suffix]
}

#let multi = text(maroon)[（多选）]

#let color-box(body, color: blue, dash: "dotted", radius: 3pt) = {
  box(
    outset: .35em,
    radius: radius,
    stroke: (
      thickness: .5pt,
      dash: dash,
      paint: color,
    ),
    text(font: kai-ti, color, body),
  )
  h(.8em)
}

#let underdot(body) = {
  assert(type(body) == str or body.func() == text, message: "expected str or text")

  let _body = body
  if type(body) == content { _body = body.text }

  for value in _body {
    box(
      baseline: 49%,
      grid(
        align: center,
        value,
        $dot$,
      ),
    )
  }
}