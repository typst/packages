
#let show-figure(body) = {
  // 图片编号
  show figure.where(kind: image): set figure(
    supplement: [图],
    numbering: (..args) => context {
      let chapters = counter(heading).get()
      if chapters.len() > 0 {
        str(chapters.at(0)) + "-" + str(args.pos().at(0))
      } else {
        str(args.pos().at(0))
      }
    },
  )

  // 表格编号
  show figure.where(kind: table): set figure(
    supplement: [表],
    numbering: (..args) => context {
      let chapters = counter(heading).get()
      if chapters.len() > 0 {
        str(chapters.at(0)) + "-" + str(args.pos().at(0))
      } else {
        str(args.pos().at(0))
      }
    },
  )

  // 一级标题下重置图、表、公式的计数
  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)
    it
  }

  body
}
