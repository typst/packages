// SCUT 研究成果
#import "../utils/section-break.typ": section-break
#import "../utils/style.typ": 字体, 字号, 章标题字体, 章标题字号, 辅助字体, 辅助字号

#let publications(
  doctype: "master",
  open-right: false,
  blind: "none",
  fonts: (:),
  title: auto,
  outlined: true,
  body,
) = {
  fonts = 字体 + fonts
  if title == auto {
    title = "攻读" + (if doctype == "doctor" { "博士" } else { "硕士" }) + "学位期间取得的研究成果"
  }

  section-break(open-right: open-right)

  heading(level: 1, numbering: none, outlined: outlined, title)

  v(2pt)

  text(font: fonts.宋体, size: 字号.五号)[
    一、已发表（包括已接受待发表）的论文，以及已投稿、或已成文打算投稿、或拟成文投稿的论文情况#box(stroke: (bottom: 0.5pt + black), inset: (bottom: 1.5pt))[*（只填写与学位论文内容相关的部分）*]：
  ]

  v(4pt)

  set text(font: 辅助字体, size: 辅助字号)
  if blind == "double" {
    // 双盲版：不填题目与卷期页码，作者仅注明第几作者
    table(
      align: center + horizon,
      columns: (24pt, 178pt, 70pt, 56pt, 70pt, 56pt),
      rows: (62pt, 56pt, 56pt, 56pt, 56pt, 56pt),
      stroke: 0.5pt,
      table.header(
        [*序号*],
        [*发表或投稿刊物/会议名称*],
        [*作者（仅注明第几作者）*],
        [*发表年份*],
        [*与学位论文哪一部分（章、节）相关*],
        [*被索引收录情况*],
      ),
      ..range(5).map(_ => ([], [], [], [], [], [])).flatten(),
    )
  } else {
    table(
      align: center + horizon,
      columns: 7,
      stroke: 0.5pt,
      table.header(
        [序号],
        [作者（全体作者，按顺序排列）],
        [题　目],
        [发表或投稿刊物名称、级别],
        [发表的卷期、年月、页码],
        [与学位论文哪一部分（章、节）相关],
        [被索引收录情况],
      ),
      [1], [], [], [], [], [], [],
      [2], [], [], [], [], [], [],
      [3], [], [], [], [], [], [],
      [4], [], [], [], [], [], [],
      [5], [], [], [], [], [], [],
    )
  }

  v(0pt)

  // “注：”占 2em，后续行统一缩进使编号对齐
  text(font: fonts.宋体, size: 字号.五号, block(
    inset: (left: 2em),
    {
      set par(leading: 0.35em)
      if blind == "double" {
        [#h(-2em)注：1. 请在“作者”一栏填写本人是第几作者，例：“第一作者”或“导师第一，本人第二”等；\
          2. 若文章未发表或未被接受，请在“发表年份”一栏据实填写“已投稿”，“拟投稿”。\
          不够请另加页。]
      } else {
        [#h(-2em)注：在“发表的卷期、年月、页码”栏：\
          1. 如果论文已发表，请填写发表的卷期、年月、页码；\
          2. 如果论文已被接受，填写将要发表的卷期、年月；\
          3. 以上都不是，请据实填写“已投稿”，“拟投稿”。\
          不够请另加页。]
      }
    },
  ))

  v(6pt)

  text(font: fonts.宋体, size: 字号.五号)[
    二、与学位内容相关的其它成果（包括专利、著作、获奖项目等）
  ]

  if blind == "double" {
    v(4pt)
    // 参考附件中的填写示范
    text(font: fonts.宋体, size: 字号.五号, block(
      inset: (left: 2em),
      {
        set par(first-line-indent: 0em, leading: 0.9em)
        [填写示例：\
          专利：已授权一项发明专利，第一发明人，2020\
          著作：参与编写一本著作，第二作者，2020]
      },
    ))
    v(4pt)
  } else {
    v(12pt)
  }

  body
}
