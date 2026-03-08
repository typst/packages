#import "../utils/utils.typ": ziti, zihao

#let statement-page-conf(
  form: "thesis",
) = page(
  header: none,
  footer: none,
  numbering: none,
  margin: 3.2cm,
  {

    set text(font: ziti.宋体, size: zihao.四号, lang: "zh")

    set par(first-line-indent: 2em, leading: 1.2em, justify: true)

    v(1.5cm)

    align(
        center,
        text(
          font: ziti.宋体,
          size: zihao.二号,
          weight: "bold",
        )[郑 重 声 明],
      )
      v(1cm)

      if form == "thesis" {
        [
            本人呈交的毕业论文，是在导师的指导下，独立进行研究工作所取得的成果，所有数据、图片资料真实可靠。尽我所知，除文中已经注明引用的内容外，本论文的研究成果不包含他人享有著作权的内容。对本论文所涉及的研究工作做出贡献的其他个人和集体，均已在文中以明确的方式标明。本论文的知识产权归属于培养单位。
        ]
      } else if form == "design" {
        [
            本人呈交的毕业设计，是在导师的指导下，独立进行研究工作所取得的成果，所有数据、图片资料真实可靠。尽我所知，除文中已经注明引用的内容外，本设计的研究成果不包含他人享有著作权的内容。对本设计所涉及的研究工作做出贡献的其他个人和集体，均已在文中以明确的方式标明。本设计的知识产权归属于培养单位。
        ]
      } else {
        [错误：form 参数填写错误，只能在 `report`、`thesis`、`design` 中选择]
      }

      v(4cm)

      align(
        left,
        grid(
          columns: (auto, 6em, 3em, auto, 6em),
          column-gutter: 10pt,
          [本人签名：],
          line(start: (0pt, 0.9em), length: 6em, stroke: 0.5pt),
          [],
          [日期：],
          line(start: (0pt, 0.9em), length: 6em, stroke: 0.5pt),
        ),
      )
  },
)

#statement-page-conf()
