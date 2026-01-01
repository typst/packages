// 图片插入函数
#let insert-figure(
  path,
  caption: "",
  label: none,
  width: 90%,
  placement: auto
) = {
  figure(
    image(path, width: width),
    caption: caption,
    placement: placement,
  )
}

// 图表编号设置
#let figure-numbering-setup(style: "chapter") = {
  if style == "global" {
    set figure(numbering: "1")
  } else if style == "chapter" {
    set figure(numbering: n => {
      let ch = counter(heading.where(level: 1)).get().first()
      [#ch.#n]
    })
  } else if style == "chapter-dash" {
    set figure(numbering: n => {
      let ch = counter(heading.where(level: 1)).get().first()
      [#ch-#n]
    })
  }
}