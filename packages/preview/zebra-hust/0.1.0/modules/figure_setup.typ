#let figure_setup(font: "FandolHei", body) = {
  // 创建章节计数器
  let chapter = counter("chapter")

  // 每次遇到一级标题时，自动增加章节号
  show heading.where(level: 1): it => {
    chapter.step()
    it
  }

  // 自定义图片编号
  show figure.where(kind: image): set figure(numbering: n => {
    let ch = chapter.get().first()
    [#ch.#n]
  })

  // 自定义图片显示
  show figure.where(kind: image): it => {
    set align(center)
    it.body
    v(0.5em)
    text(font: font, weight: "bold")[
      图 #it.counter.display(it.numbering) #h(0.5em) #it.caption.body
    ]
    v(1em)
  }

  body
}

#let img(
  dir,
  width: 80%,
  caption: "这是 Go, 一个很好的编程语言。",
) = {
  figure(
    image(dir, width: width),
    caption: caption,
  )
}
