#import "../utils/indent.typ": indent
#import "../utils/style.typ": 字号, 字体

// 本科生声明页
#let bachelor-decl-page(
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
) = {
  // 0. 如果需要匿名则短路返回
  if anonymous {
    return
  }

  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "南京大学学位论文"),
  ) + info

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  set text(font: fonts.宋体, size: 字号.小四)
  set par(leading: 12pt,first-line-indent: 2em)
  // 3.  正式渲染
  pagebreak(weak: true, to: "odd" )

  v(1em)

  align(center,text(font: fonts.黑体, size: 字号.三号, "学位论文原创性声明"))

  v(字号.三号)

  [
    郑重声明：所呈交的学位论文《#info.title.sum()》，是本人在导师的指导下，独立进行研究取得的成果。除文中已经注明引用的内容外，本论文不包括他人或集体已经发表或撰写过的作品成果。对本文的研究做出贡献的个人和集体，均已在文中以明确方式标明。本人完全意识到本声明的法律后果，并承诺因本声明而产生的法律结果由本人承担。
  ]
  v(1em)
  [学位论文作者签名：~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~日期：~~~~年~~~~月~~~~日] 
  v(3em)
  
  align(center,text(font: fonts.黑体, size: 字号.三号, "学位论文版权使用授权书"))

  v(字号.小三)
  
  [
    本学位论文作者完全了解学校有关保留、使用学位论文的规定，同意学校保留并向国家有关部门或机构送交论文的复印件和电子版，允许论文被查阅和借阅。本人授权燕山大学将本学位论文的全部或部分内容编入有关数据库进行检索，可以采用影印、缩印或扫描等复制手段保存和汇编本学位论文。
  ]

  v(1em)
  // typst 中第一行不会缩进，所以需要手动缩进
  [#h(8em) 保　密☐，在\_\_年解密后适用本授权书。]
  linebreak()
  [#indent 本学位论文属于]
  linebreak()
  [#indent #h(8em) 不保密☐。]
  linebreak()
  [#indent （请在以上相应方框内打“√”）] 
  v(1em) 
  [学位论文作者签名：~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~日期：~~~~年~~~~月~~~~日]
  v(1em)
  [指导教师签名：~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~日期：~~~~年~~~~月~~~~日]
  v(1em)
  pagebreak(weak: false, to: "even" )
}