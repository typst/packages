#import "../utils/fonts.typ": 字体, 字号

#let degree-statement-conf(
  anonymous: false,
) = page(
  header: none,
  footer: none,
  numbering: none,
  margin: 2.5cm,
  {

    show heading.where(level: 1): it => {
      set align(center)
      set text(font: 字体.黑体, size: 15pt)
      it.body.text.clusters().join(h(0.3em))
      v(2em)
    }

    set text(font: 字体.宋体, size: 10.6pt, lang: "zh")
    // 字号来自“附件1：学位论文独创性和使用授权声明.pdf”

    set par(first-line-indent: 2em, leading: 1.5em, justify: true)
    set block(spacing: 1.5em)

    set align(horizon)
    block({
      align(
        center,
        text(
          font: 字体.黑体,
          size: 15pt,
          tracking: 0.3em,
        )[东南大学学位论文独创性声明],
      )
      v(1.5em)

      [
        本人声明所呈交的学位论文是我个人在导师指导下进行的研究工作及取得的研究成果。尽我所知，除了文中特别加以标注和致谢的地方外，论文中不包含其他人已经发表或撰写过的研究成果，也不包含为获得东南大学或其它教育机构的学位或证书而使用过的材料。与我一同工作的同志对本研究所做的任何贡献均已在论文中作了明确的说明并表示了谢意。
      ]

      v(1cm)

      align(
        right,
        grid(
          columns: (auto, 6em, auto, 6em),
          column-gutter: 3pt,
          [研究生签名：],
          line(start: (0pt, 0.9em), length: 6em, stroke: 0.5pt),
          [日期：],
          line(start: (0pt, 0.9em), length: 6em, stroke: 0.5pt),
        ),
      )

      v(4cm)

      align(
        center,
        text(
          font: 字体.黑体,
          size: 15pt,
          tracking: 0.3em,
        )[东南大学学位论文使用授权声明],
      )

      v(1.5em)

      [
        东南大学、中国科学技术信息研究所、国家图书馆、《中国学术期刊（光盘版）》电子杂志社有限公司、万方数据电子出版社、北京万方数据股份有限公司有权保留本人所送交学位论文的复印件和电子文档，可以采用影印、缩印或其他复制手段保存论文。本人电子文档的内容和纸质论文的内容相一致。除在保密期内的保密论文外，允许论文被查阅和借阅，可以公布（包括以电子信息形式刊登）论文的全部内容或中、英文摘要等部分内容。论文的公布（包括以电子信息形式刊登）授权东南大学研究生院办理。
      ]

      v(1cm)

      align(
        right,
        grid(
          columns: (auto, 6em, auto, 6em, auto, 6em),
          column-gutter: 3pt,
          [研究生签名：],
          line(start: (0pt, 0.9em), length: 6em, stroke: 0.5pt),
          [导师签名：],
          line(start: (0pt, 0.9em), length: 6em, stroke: 0.5pt),
          [日期：],
          line(start: (0pt, 0.9em), length: 6em, stroke: 0.5pt),
        ),
      )
    })
  },
)

#degree-statement-conf(anonymous: false)