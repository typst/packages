#import "../utils/indent.typ": indent
#import "../utils/style.typ": 字号, 字体
#import "../utils/str.typ": to-normal-str

// 研究生声明页
#let master-decl-page(anonymous: false, twoside: false, fonts: (:), info: (:), doctype: "master") = {

  // 1.  默认参数
  fonts = 字体 + fonts

  // 2. 处理标题
  let title = to-normal-str(src: info.title)

  // 3. 正式渲染。
  pagebreak(weak: true)

  align(center, text(font: fonts.黑体, size: 字号.三号, weight: "bold", "华东师范大学学位论文原创性声明"))

  v(12pt)

  block[
    #set text(font: fonts.宋体, size: 11.5pt)
    #set par(justify: true, first-line-indent: 2em, leading: 1em)

    #indent 郑重声明：本人呈交的学位论文《#title》，是在华东师范大学攻读硕士/博士（请勾选）学位期间，在导师的指导下进行的研究工作及取得的研究成果。除文中已经注明引用的内容外，本论文不包含其他个人已经发表或撰写过的研究成果。对本文的研究做出重要贡献的个人和集体，均已在文中作了明确说明并表示谢意。

    #v(1.5em)

    #block(inset: (left: 2em), grid(columns: (1fr, 1fr), [*作者签名：*], [*日#h(2em)期：*#h(4em)年#h(2em)月#h(2em)日]))
  ]

  v(36pt)

  align(center, text(font: fonts.黑体, size: 字号.三号, weight: "bold", "华东师范大学学位论文著作权使用声明 "))

    v(12pt)

  block[
    #set text(font: fonts.宋体, size: 11.5pt)
    #set par(justify: true, first-line-indent: 2em, leading: 1em)

    #indent《#title》系本人在华东师范大学攻读学位期间在导师指导下完成的硕士/博士（请勾选）学位论文，本论文的著作权归本人所有。本人同意华东师范大学根据相关规定保留和使用此学位论文，并向主管部门和学校指定的相关机构送交学位论文的印刷版和电子版；允许学位论文进入华东师范大学图书馆及数据库被查阅、借阅；同意学校将学位论文加入全国博士、硕士学位论文共建单位数据库进行检索，将学位论文的标题和摘要汇编出版，采用影印、缩印或者其它方式合理复制学位论文。

    本学位论文属于（请勾选）

    （#h(1em)）1. 经华东师范大学相关部门审查核定的“内部”或“涉密”学位论文 $#sym.ast.op$，\ 于#h(4em)年 #h(2em)月#h(2em)日解密，解密后适用上述授权。

    （#h(1em)）2. 不保密，适用上述授权。

    #v(1em)

    #block(inset: (left: 2em), grid(columns: (1fr, 1fr), row-gutter: 2em,
     [*导师签名：*], [*作者签名：*], [], [*日#h(2em)期：*#h(4em)年#h(2em)月#h(2em)日]))

    #v(3em)

     #indent $#sym.ast.op$ “涉密” 学位论文应是已经华东师范大学学位管理办公室或保密委员会审定过的学位论文（需附获批的《华东师范大学研究生申请学位论文 “涉密”  审批表》方为有效），未经上述部门审定的学位论文均为公开学位论文。此声明栏不填写的，默认为公开学位论文，均适用上述授权）。

  ]

  if twoside {
    pagebreak() + " "
  }
}