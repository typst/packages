#import "@preview/i-figured:0.2.4"
#import "../utils/custom-numbering.typ": custom-numbering

//! 附录
//! 附录依顺序用大写字母A、B、C、……编序号，如附录A、附录B、附录C、……。只有一个附录时也要编序号，即附录A。
//! 每个附录应有标题。附录序号与附录标题之间空2个半角空格。例如：“附录A  XXXX统计数据”。
//! 附录中的图、表、数学表达式、参考文献等另行编序号，与正文分开，一律用阿拉伯数字编码，但在数码前冠以附录的序号，例如“图A.1”，“表B.2”，“式（C.3）”等。
//! 附录标题，三号黑体字，居中无缩进，大纲级别1级，段前48磅，段后24磅，1.5倍行距。附录内容中文采用宋体，英文和数字采用Times New Roman字体，均为小四号，大纲级别正文文本，两端对齐，首行缩进2字符，段前0行，段后0行，1.5倍行距。
#let appendix(
  numbering: custom-numbering.with(first-level: "A", depth: 1),
  // figure 计数
  show-figure: i-figured.show-figure.with(numbering: "A.1"),
  // equation 计数
  show-equation: i-figured.show-equation.with(numbering: "(A.1)"),
  // 重置计数
  reset-counter: true,
  it,
) = {
  if reset-counter {
    counter(heading).update(0)
  }
  set heading(
    numbering: (..nums) => {
      let vals = nums.pos()
      let currentPosition = vals.at(0)
      let numberingTopHeading = "ABCDEFGHIJHIJKLMNOPQRSTUVWXYZ".at(vals.at(0) - 1)
      if vals.len() == 1 {
        return "附录" + numberingTopHeading + "  "
      } else {
        return numberingTopHeading + "." + nums.pos().slice(1).map(str).join(".")
      }
    },
    supplement: [],
  )

  // 设置 figure 的编号
  show figure: show-figure
  // 设置 equation 的编号
  show math.equation.where(block: true): show-equation
  it
}
