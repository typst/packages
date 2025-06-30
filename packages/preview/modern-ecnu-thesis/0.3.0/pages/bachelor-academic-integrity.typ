#import "../utils/style.typ": 字号, 字体
#import "../utils/indent.typ": indent

#let bachelor-academic-integrity(twoside: false, fonts: (:), info: (:), anonymous: false) = {

  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "华东师范大学学位论文"),
  ) + info


  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  pagebreak(weak: true, to: if twoside { "odd" })

  v(6pt)

  // 第一部分：诚信承诺
  align(
    center,
    text(
      font: fonts.宋体,
      size: 字号.四号, 
      weight: "bold",
      "华东师范大学学位论文诚信承诺",
    ),
  )

  v(16pt) 

  block[
    #set text(font: fonts.宋体, size: 字号.小四) 
    #set par(justify: true, first-line-indent: 2em, leading: 1.5em)

    #indent 本毕业论文是本人在导师指导下独立完成的，内容真实、可靠。本人在撰写毕业论文过程中不存在请人代写、抄袭或者剽窃他人作品、伪造或者篡改数据以及其他学位论文作假行为。

    本人清楚知道学位论文作假行为将会导致行为人受到不授予/撤销学位、开除学籍等处理（处分）决定。本人如果被查证在撰写本毕业论文过程中存在学位论文作假行为，愿意接受学校依法作出的处理（处分）决定。
  ]

  v(36pt)

  align(right)[
    #set text(font: fonts.宋体, size: 字号.小四)
    承诺人签名：#h(12em)日期：#h(4em)年#h(2em)月#h(2em)日
  ]

  v(56pt) 

  // 第二部分：使用授权说明
  align(
    center,
    text(
      font: fonts.宋体, 
      size: 字号.四号,
      weight: "bold",
      "华东师范大学学位论文使用授权说明",
    ),
  )

  v(16pt)

  block[
    #set text(font: fonts.宋体, size: 字号.小四)
    #set par(justify: true, first-line-indent: 2em, leading: 1.5em)

    #indent 本论文的研究成果归华东师范大学所有，本论文的研究内容不得以其它单位的名义发表。本学位论文作者和指导教师完全了解华东师范大学有关保留、使用学位论文的规定，即：学校有权保留并向国家有关部门或机构送交论文的复印件和电子版，允许论文被查阅和借阅；本人授权华东师范大学可以将论文的全部或部分内容编入有关数据库进行检索、交流，可以采用影印、缩印或其他复制手段保存论文和汇编本学位论文。

    保密的毕业论文（设计）在解密后应遵守此规定。
  ]

  v(42pt)
  align(right)[
    #set text(font: fonts.宋体, size: 字号.小四)
    作者签名：#h(4em)导师签名：#h(4em)日期：#h(4em)年#h(2em)月#h(2em)日
  ]

  if twoside {
    pagebreak() + " "
  }
}