#import "@preview/pointless-size:0.1.2": zh

// 目录
#let outline_with_sizes(depth: 3, font_sizes: (), font: "FandolSong", title-font: "FandolHei", title-size: zh(2)) = {
  set par(first-line-indent: 0pt)
  assert(depth == font_sizes.len(), message: "字体大小数组长度必须与目录深度相等")

  show outline.entry: it => {
    if it.level <= depth and it.level <= font_sizes.len() {
      let size = font_sizes.at(it.level - 1)
      let weight = if it.level == 1 { "bold" } else { "regular" }
      v(0.4em)
      text(font: font, size: size, weight: weight, it)
    } else {
      it
    }
  }

  align(center, text(font: title-font, title-size)[目 ~ 录])

  v(-1em)

  align(center, box(
    outline(
      title: none,
      indent: auto,
      depth: depth,
    ),
  ))
  pagebreak()
}
