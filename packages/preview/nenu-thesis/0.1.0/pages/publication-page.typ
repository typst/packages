#import "../utils/style.typ": font_family, font_size
#import "../utils/invisible-heading.typ": invisible-heading
//! 成果页
//! 1. 标题: 黑体三号，居中无缩进，大纲级别1级，段前48磅，段后24磅，1.5倍行距
//! 2. 内容: 中文字体为宋体，英文和数字为Times New Roman字体，小四号，大纲级别正文文本，居中无缩进，段前0磅，段后0磅，1.5倍行距。
#let publication(
  //? thesis 传入的参数
  anonymous: false,
  twoside: false,
  fonts: (:),
  //? 其他参数
  pubs: (),
  outlined: true,
  outline-title: "在学期间取得创新性成果情况",
) = {
  //! 1.  默认参数
  pubs = (
    (
      (
        name: "论文名称1",
        class: "学术论文",
        publisher: "NENU",
        public-time: "2025-09",
        author-order: "1",
      ),
      (
        name: "论文名称2",
        class: "学术论文",
        publisher: "NENU",
        public-time: "2025-10",
        author-order: "3",
      ),
    )
      + pubs
  )

  fonts = font_family + fonts

  pagebreak(weak: true, to: if twoside { "odd" })

  //! 2. 标题渲染
  invisible-heading(level: 1, outlined: outlined, outline-title)
  set align(center)
  set par(leading: 1.5em, justify: true)
  {
    // FIXME 这里的 -48 磅需要被修复，大概是因为标题的规则被二次应用了
    v(-48pt)
    set text(font: fonts.黑体, size: font_size.三号)
    outline-title
  }

  //! 表格渲染

  show grid.cell: it => {
    set text(font: fonts.宋体, size: font_size.小四)
    set par(leading: 1.5em, spacing: 1.5em)
    pad(x: 6pt, y: 12pt, it) // 添加水平和垂直内边距
  }


  grid(
    columns: (2fr, 1fr, 2fr, 1fr, 1fr),
    // 调整列宽比例
    align: center + horizon,
    stroke: 1pt + black,
    "成果名称", "成果类别", "刊物名称/出版社名称", "刊发时间	", "作者次序",
    ..pubs
      .map(pub => (
        pub.name,
        pub.class,
        pub.publisher,
        pub.public-time,
        pub.author-order,
      ))
      .flatten(),
  )
}
