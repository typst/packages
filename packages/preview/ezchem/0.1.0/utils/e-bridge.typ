#let _stroke = .5pt
// ========================单/双线桥=======================
// 获取电子转移开始/结束位置
#let _get-pos = label => {
  let pos = 0pt
  for value in query(label) {
    pos = value.location().position().x - here().position().x + measure(value).width / 2
  }
  pos
}

// 得失电子转移描述及其位置
#let _desc(e-num, e-pos, sign, l-e-num, dir: "up", style) = {
  let e-desc = (
    if l-e-num != 0 and dir == "up" [得到] else if dir == "" [失去] + if e-num > 1 [$#e-num sign e^-$] else [$e^-$]
  )

  h((e-pos - measure(e-desc).width) / 2) + text(fill: style, e-desc)
}

// 箭头
#let _arrow(
  from: (),
  l1: (),
  to: (),
  l2: (),
  l3: (),
  m: (),
  l4: (),
  line-type,
) = curve(
  stroke: line-type,
  curve.move(from),
  curve.line(l1, relative: true),
  curve.line(to),
  curve.line(l2, relative: true),
  curve.line(l3, relative: true),
  curve.move(m, relative: true),
  curve.line(l4, relative: true),
)

// 化学方程式得失电子
#let e-bridge(
  equation: "",
  get: (from: "", to: "", e: 0, tsign: sym.times),
  lose: (from: "", to: "", e: 0, tsign: sym.times),
  color: black,
  thickness: _stroke,
  spacing: 2pt,
) = context {
  let (from: g-from, to: g-to, e: g-e-num, tsign: g-tsign) = (from: "", to: "", e: 0, tsign: sym.times) + get

  assert(type(g-e-num) == int and g-e-num > 0, message: "'e' must be positive integer")

  let (from: l-from, to: l-to, e: l-e-num, tsign: l-tsign) = (from: "", to: "", e: 0, tsign: sym.times) + lose

  let body = ()
  // 得电子化学式的开始/结束位置
  let g-from-pos = _get-pos(g-from)
  let g-to-pos = _get-pos(g-to)

  if g-from-pos == g-to-pos {
    // 特殊的单线桥,自己指向自己
    body += (
      _desc(g-e-num, g-from-pos + 6pt, g-tsign, l-e-num, color),
      _arrow(
        from: (g-from-pos, 6pt),
        l1: (-8pt, -6pt),
        to: (g-to-pos + 8pt, 0pt),
        l2: (-7pt, 6pt),
        l3: (2pt, -4.2pt),
        m: (-2pt, 4.2pt),
        l4: (4.5pt, -1.4pt),
        thickness + color,
      ),
    )
  } else {
    body += (
      _desc(g-e-num, g-from-pos + g-to-pos, g-tsign, l-e-num, color),
      _arrow(
        from: (g-from-pos, 6pt),
        l1: (0pt, -6pt),
        to: (g-to-pos, 0pt),
        l2: (0pt, 6pt),
        l3: (2pt, -4pt),
        m: (-2pt, 4pt),
        l4: (-2pt, -4pt),
        thickness + color,
      ),
    )
  }

  body.push(equation)

  // 双线桥则继续添加下面的电子转移
  if (l-e-num > 0) {
    // 失电子化学式的开始/结束位置
    let l-from-pos = _get-pos(l-from)
    let l-to-pos = _get-pos(l-to)
    body += (
      _arrow(
        from: (l-from-pos, 0pt),
        l1: (0pt, 6pt),
        to: (l-to-pos, 6pt),
        l2: (0pt, -6pt),
        l3: (2pt, 4pt),
        m: (-2pt, -4pt),
        l4: (-2pt, 4pt),
        thickness + color,
      ),
      _desc(l-e-num, l-to-pos + l-from-pos, l-tsign, l-e-num, dir: "", color),
    )
  }

  stack(
    spacing: spacing,
    ..body,
  )
}
