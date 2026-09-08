#import "../utils/indent.typ": indent
#import "../utils/style.typ": 字号, 字体
#import "../utils/str.typ": to-normal-str
#import "../utils/external-libs.typ":*
#import "@preview/cheq:0.4.0": checklist
// 研究生声明页
#let master-decl-page(anonymous: false, twoside: false, fonts: (:), info: (:), doctype: "master") = {
  if (not anonymous) {
    show :checklist.with(stroke: black, radius: .0em, light: true)
    show :zh-format
    // 1.  默认参数
    fonts = 字体 + fonts
    set page(header: none)
    set par(leading: 0em, spacing: 0em)
    // 3. 正式渲染。
    align(center)[
      #set text(size: 字号.小二, font: 字体.黑体)
      *同济大学学位论文原创性声明*
    ]

    v(.6em)
    v(.7em)
    v(.7em)

    block[
      #set par(leading: .8em, spacing: 0em)
      #set text(font: fonts.宋体, size: 字号.四号)
      // #set par(justify: true, first-line-indent: 2em, leading: 1em)
      本人郑重声明：所呈交的学位论文*《#info.title.cn》*，是本人在导师指导下，独立进行研究工作所取得的成果。除文中已经注明引用的内容外，本学位论文的研究成果不包含任何他人创作的、已公开发表或者没有公开发表的作品的内容。对本论文所涉及的研究工作做出贡献的其他个人和集体，均已在文中以明确方式标明。本学位论文原创性声明的法律责任由本人承担。

      #v(1.5em)
      #h(7em)*学位论文作者签名：*#box[]
      #v(1.1em)
      // #h(13em)*日期：*#h(2.5em)*年*#h(2.5em)*月*#h(2.5em)*日*
      #h(13em)*日期：**2026年7月12日*
    ]
    v(1.4em)
    line(length: 100%)
    v(1.7em)
    align(center)[
      #set text(size: 字号.小二, font: 字体.黑体)
      *同济大学学位论文版权使用授权书*
    ]
    v(2.1em)
    block[
      #set text(font: fonts.宋体, size: 字号.四号)
      // #set par(justify: true, first-line-indent: 2em, leading: 1em)
      #set par(justify: true, leading: .93em, spacing: 0em)

      本人完全了解同济大学关于收集、保存、使用学位论文的规定，同意如下各项内容：按照学校要求提交学位论文的印刷本和电子版；学校有权保存论文的印刷本和电子版，并采用影印、缩印、扫描、数字化或
      其它手段保存论文；学校有权提供目录检索以及提供本论文全文或部分
      的阅览服务；学校有权按有关规定向国家有关部门或机构送交论文的复
      印件和电子版；允许论文被查阅和借阅。学校有权将本论文的全部或部
      分内容授权编入有关数据库出版传播。
      #v(1.5em)
      *本学位论文属于（在以下方框内打“√”）：*
      #v(13pt)
      - [ ] * 保密，在\_\_\_\_\_年解密后适用本授权书。*
      #v(13pt)
      - [x] * 不保密。*
      // #v(30pt)
      #set par(first-line-indent: 0em)

      #v(2em)
      *学位论文作者签名：*#box(width: 5em)[]#h(3em)*指导教师签名：*#box(width: 5em)[]
      #v(1em)
      *日期：**2026年7月12日*#h(6em)
      *日期：**2026年7月12日*
    ]
    // if twoside {
    //   pagebreak() + " "
    // }
    //
  } else {}
}