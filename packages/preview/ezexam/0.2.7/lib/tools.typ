#import "const-state.typ": heiti
// 一种页码格式: "第x页（共xx页）
#let zh-arabic(prefix: "", suffix: "") = (..nums) => {
  let arr = nums.pos()
  [#prefix 第#str(arr.at(0))页（共#str(arr.at(-1))页）#suffix]
}

#let tag(body, color: blue, font: auto, prefix: "【", suffix: "】") = context {
  let _font = font
  if font == auto { _font = text.font.slice(0, 1) + heiti }
  text(font: _font, color)[#prefix#body#suffix]
  h(.1em, weak: true)
}

#let multi = tag.with(prefix: $circle.filled.tiny$, suffix: none, color: maroon)[多选]()