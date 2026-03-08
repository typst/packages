#import "const-state.typ": heiti
#import "outline.typ": title
#let _special-char = "《（【"
// 为了解决数学公式、特殊字符在最左侧没有内容时加间距的问题
#let _math-or-special-char(body) = {
  if body.func() == math.equation { return "math" }
  if body.has("text") and body.text.first() in _special-char { "char" }
}

#let _check-content-starts-with(body) = {
  if body.has("children") {
    let children = body.children
    if children.len() == 0 { return }
    body = children.first()
    if body == [ ] { body = children.at(1) }
  }
  _math-or-special-char(body)
}

#let _content-start-space(body) = {
  if _check-content-starts-with(body) == "math" { return .25em }
  if _check-content-starts-with(body) == "char" { return .4em }
  0em
}

#let _trim-content-start-parbreak(body) = {
  if body.has("children") {
    let children = body.children
    if children.len() > 0 and children.first() == parbreak() {
      return children.slice(1).join()
    }
  }
  body
}

#let _create-seal(
  dash: "dashed",
  supplement: none,
  info: (:),
) = {
  assert(type(info) == dictionary, message: "expected dictionary, found " + str(type(info)))
  set par(spacing: 10pt)
  set text(font: heiti, size: 12pt)
  set align(center)
  set grid(columns: 2, align: horizon, gutter: .5em)
  if supplement != none { text(tracking: .8in, supplement) }
  grid(
    columns: if info.len() == 0 { 1 } else { info.len() },
    gutter: 1em,
    ..for (key, value) in info {
      (
        grid(
          key,
          value,
        ),
      )
    }
  )
  line(length: 100%, stroke: (dash: dash))
}

#let draft(
  name: "草稿纸",
  student-info: (
    姓名: underline[~~~~~~~~~~~~~],
    准考证号: underline[~~~~~~~~~~~~~~~~~~~~~~~~~~],
    考场号: underline[~~~~~~~],
    座位号: underline[~~~~~~~],
  ),
  dash: "solid",
  supplement: none,
) = {
  set page(margin: .5in, header: none, footer: none)
  title(name.split("").join(h(1em)), bottom: 0pt)
  _create-seal(dash: dash, supplement: supplement, info: student-info)
}

// 一种页码格式: "第x页（共xx页）
#let zh-arabic(prefix: "", suffix: "") = (..nums) => {
  let arr = nums.pos()
  [#prefix 第#str(arr.at(0))页（共#str(arr.at(-1))页）#suffix]
}

#let tag(body, color: blue, font: auto, weight: 400, prefix: "【", suffix: "】", x: -.4em) = context {
  let _font = font
  if font == auto { _font = text.font.slice(0, -1) + heiti }
  h(x, weak: true)
  text(font: _font, weight: weight, color)[#prefix#body#suffix]
  h(.1em, weak: true)
}
