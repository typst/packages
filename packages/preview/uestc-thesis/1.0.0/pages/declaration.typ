#let declaration() = [
  // #pagebreak()
  #import "@preview/pointless-size:0.1.1": zh
  #set page(numbering:none,header:none)
  // 独创性声明
  #align(center)[
    #text(font: "SimHei", size: 18pt, weight: "bold")[独创性声明]
  ]
  #v(12pt)

  #par(first-line-indent: 2em, justify: true, leading: 30pt)[
    本人声明所呈交的学位论文是本人在导师指导下进行的研究工作及取得的研究成果。据我所知，除了文中特别加以标注和致谢的地方外，论文中不包含其他人已经发表或撰写过的研究成果，也不包含为获得电子科技大学或其它教育机构的学位或证书而使用过的材料。与我一同工作的同志对本研究所做的任何贡献均已在论文中作了明确的说明并表示谢意。
  ]

  #v(16pt)
  #align(right)[
    作者签名：#h(128pt) 日期：#h(1cm)年#h(1cm)月#h(1cm)日
  ]

  #v(100pt)

  // 论文使用授权
  #align(center)[
    #text(font: "SimHei", size: 18pt, weight: "bold")[论文使用授权]
  ]
  #v(12pt)

  #par(first-line-indent: 2em, justify: true, leading: 30pt)[
    本学位论文作者完全了解电子科技大学有关保留、使用学位论文的规定，同意学校有权保留并向国家有关部门或机构送交论文的复印件和数字文档，允许论文被查阅。本人授权电子科技大学可以将学位论文的全部或部分内容编入有关数据库进行检索及下载，可以采用影印、扫描等复制手段保存、汇编学位论文。
    \
    （涉密的学位论文须按照国家及学校相关规定管理，在解密后适用于本授权。）
  ]

  #v(12pt)

  #align(right)[
    #align(center)[作者签名：#h(100pt) 导师签名：]
    #v(10pt)
    日期：#h(1cm)年#h(1cm)月#h(1cm)日
  ]

  // #pagebreak() 
]