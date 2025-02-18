#import "../style/font.typ": ziti, zihao
#import "../style/distr.typ": distr
#import "../style/uline.typ": uline

#let declare-page(
  info: (:),
) = {
  set text(font: ziti.songti, size: zihao.xiaosi)
  set par(justify: true,leading: 1.5em,spacing:1.5em)
  table(
    // stroke: 1pt,
    inset: 8.5pt,
    columns: (30%,28%,18%,19%),
    align: left,
    [姓#h(2em)名：],info.name, [学#h(2em)号:],info.student_id,
    [论文题目：],table.cell(colspan: 3)[#info.title]
  )
  v(1em)
  align(center)[
    #set text(font: ziti.songti, size: zihao.erhao, weight: "bold")
    #v(1em)
    原#h(0.7em)创#h(0.7em)性#h(0.7em)声#h(0.7em)明
  ]
  set text(font: ziti.songti, size: zihao.sihao)
  [
    #v(16pt)
    本人声明：所呈交的论文是本人在指导教师指导下进行的研究工作。除了文中特别加以标注和致谢的地方外，论文中不包含其他人已发表或撰写过的研究成果。参与同一工作的其他同志对本研究所做的任何贡献均已在论文中作了明确的说明并表示了谢意。#linebreak() #linebreak()

    签 名：#uline(5.5em,"")日 期：#uline(5.5em,"")
    #linebreak()
    #linebreak()
  ]
  // v(2em)
  align(center)[
    #set text(font: ziti.songti, size: zihao.erhao, weight: "bold")
    本论文使用授权说明
  ]
  v(2em)
  set text(font: ziti.songti, size: zihao.sihao)
  [
    本人完全了解上海大学有关保留、使用学位论文的规定，即：学校有权保留论文及送交论文复印件，允许论文被查阅和借阅；学校可以公布论文的全部或部分内容。#linebreak()
    
    *（保密的论文在解密后应遵守此规定）* #linebreak() #linebreak()

    签 名：#uline(5.5em,"")指导教师签名：#uline(5.5em,"")日 期：#uline(5.5em,"")
  ]

  pagebreak(weak: true)
}
