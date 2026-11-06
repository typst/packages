// 利用 state 捕获摘要参数，并通过 context 传递给渲染函数
#import "/utils/style.typ": 字号, 字体

// 致谢内容
#let acknowledgement-content = state("acknowledgement", [
致谢应以简短的文字对课题研究与论文撰写过程中曾直接给予帮助的人员(例如指导教师、答疑教师
及其他人员)表达自己的谢意，这不仅是一种礼貌，也是对他人劳动的尊重，是治学者应当遵循的学
术规范。内容限一页。
])

#let acknowledgement(
  body
) = {
  context acknowledgement-content.update(body)
}

#let acknowledgement-page() = {
  // 致谢、附录内容	宋体小四号
  set text(font: 字体.宋体, size: 字号.小四)

  // 致谢、附录标题 黑体三号居中
  show heading.where(level: 1): set text(font: 字体.黑体, size: 字号.三号)

  // 致谢标题不编号
  show heading.where(level: 1): set heading(numbering: none)

  [
    = 致谢

    #set par(first-line-indent: (amount: 2em, all: true))
    #context acknowledgement-content.final()

    #v(1em)

  ]
}
