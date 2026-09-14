//! 致谢页
//! 1. 标题: 黑体三号，居中无缩进，“后记”二字中间空2个汉字字符或4个半角空格，大纲级别1级，段前48磅，段后24磅，1.5倍行距。
//! 2. 内容: 中文字体为宋体，英文和数字为Times New Roman字体，大纲级别正文文本，两端对齐，首行缩进2字符，段前0行，段后0行，1.5倍行距。
#let acknowledgement(
  // thesis 传入参数
  anonymous: false,
  twoside: false,
  // 其他参数
  title: "后　　记",
  outlined: true,
  body,
) = {
  if not anonymous {
    pagebreak(weak: true, to: if twoside { "odd" })
    [
      #heading(level: 1, numbering: none, outlined: outlined, title) <no-auto-pagebreak>
    ]

    body
  }
}
