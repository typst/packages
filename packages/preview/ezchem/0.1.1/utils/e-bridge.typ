// 获取电子转移开始/结束位置
#let _get-pos = label => {
  let pos = 0pt
  for element in query(label) {
    pos = locate(label).position().x - here().position().x + measure(element).width / 2
  }
  pos
}

// 得失电子转移描述及其位置
#let _e-desc(e-num, e-pos, sign, l-e-num, dir: none, color) = {
  let e-desc-content = {
    if l-e-num != 0 and dir == none [得到] else if dir == "down" [失去]
    [#if e-num > 1 [#e-num#sign]_e_#super[--]]
  }

  h((e-pos - measure(e-desc-content).width) / 2) + text(color, e-desc-content)
}

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

#let default-e-info = (from: "", to: "", e: 0, tsign: "×")
#let self-get-arrow-pos = (
  l1: (-8pt, -6pt),
  l2: (-7pt, 6pt),
  l3: (2pt, -4pt),
  m: (-2pt, 4pt),
  l4: (4.4pt, -1.4pt),
)
#let get-arrow-pos = (
  l1: (0pt, -6pt),
  l2: (0pt, 6pt),
  l3: (2pt, -4pt),
  m: (-2pt, 4pt),
  l4: (-2pt, -4pt),
)
#let lost-arrow-pos = (
  l1: (0pt, 6pt),
  l2: (0pt, -6pt),
  l3: (2pt, 4pt),
  m: (-2pt, -4pt),
  l4: (-2pt, 4pt),
)
// 单、双线桥
#let e-bridge(
  equation: "",
  get: default-e-info,
  lose: default-e-info,
  color: black,
  thickness: .5pt,
  spacing: 2pt,
) = context {
  let (from: g-from, to: g-to, e: g-e-num, tsign: g-tsign) = default-e-info + get
  assert(type(g-e-num) == int and g-e-num > 0, message: "'e' must be a positive integer")
  let (from: l-from, to: l-to, e: l-e-num, tsign: l-tsign) = default-e-info + lose

  // 得电子化学式的开始/结束位置
  let g-from-pos = _get-pos(g-from)
  let g-to-pos = _get-pos(g-to)
  // 得电子转移箭头
  let arrow = if g-from-pos == g-to-pos {
    // 特殊的单线桥,自己指向自己
    _arrow(
      from: (g-from-pos, 6pt),
      to: (g-from-pos + 8pt, 0pt),
      ..self-get-arrow-pos,
      thickness + color,
    )
  } else {
    _arrow(
      from: (g-from-pos, 6pt),
      to: (g-to-pos, 0pt),
      ..get-arrow-pos,
      thickness + color,
    )
  }
  let body = ()
  body += (_e-desc(g-e-num, g-from-pos + g-to-pos, g-tsign, l-e-num, color), arrow, equation)

  // 双线桥则继续添加下面的电子转移
  assert(type(l-e-num) == int, message: "'e' must be a integer")
  if (l-e-num > 0) {
    let l-from-pos = _get-pos(l-from)
    let l-to-pos = _get-pos(l-to)
    body += (
      _arrow(
        from: (l-from-pos, 0pt),
        to: (l-to-pos, 6pt),
        ..lost-arrow-pos,
        thickness + color,
      ),
      _e-desc(l-e-num, l-from-pos + l-to-pos, l-tsign, l-e-num, dir: "down", color),
    )
  }

  stack(spacing: spacing, ..body)
}
