#import "../utils/style.typ": get-fonts, 字号

// 研究生声明页
#let master-decl-page(
  anonymous: false,
  twoside: false,
  fontset: "mac",
  fonts: (:),
) = {
  // 0. 如果需要匿名则短路返回
  if anonymous {
    return
  }

  // 1.  默认参数
  fonts = get-fonts(fontset) + fonts

  // 2.  正式渲染
  pagebreak(weak: true, to: if twoside {
    "odd"
  })

  v(48pt)

  align(center, text(
    font: fonts.黑体,
    size: 字号.四号,
    weight: "bold",
    "中国科学院大学 \n 学位论文原创性声明",
  ))

  v(15pt)

  block[
    #set text(font: fonts.宋体, size: 字号.小四)
    #set par(
      justify: true,
      first-line-indent: (amount: 2em, all: true),
      leading: 1.2em,
    )

    本人郑重声明：所呈交的学位论文是本人在导师的指导下独立进行研究工作所取得的成果。
    承诺除文中已经注明引用的内容外，本论文不包含任何其他个人或集体享有著作权的研究成果，
    未在以往任何学位申请中全部或部分提交。对本论文所涉及的研究工作做出贡献的其他个人或集体，
    均已在文中以明确方式标明或致谢。本人完全意识到本声明的法律结果由本人承担。
  ]

  v(12pt)

  align(center)[
    #set text(font: fonts.宋体, size: 字号.小四)

    #h(8em)作者签名：#h(5.8em)

    #h(8em)日#h(2em)期：#h(5.8em)
  ]

  v(48pt)

  align(center, text(
    font: fonts.黑体,
    size: 字号.四号,
    weight: "bold",
    "中国科学院大学 \n 学位论文授权使用声明",
  ))

  v(15pt)

  block[
    #set text(font: fonts.宋体, size: 字号.小四)
    #set par(
      justify: true,
      first-line-indent: (amount: 2em, all: true),
      leading: 1.2em,
    )

    本人完全了解并同意遵守中国科学院大学有关收集、保存和使用学位论文
    的规定，即中国科学院大学有权按照学术研究公开原则和保护知识产权的原则，
    保留并向国家指定或中国科学院指定机构送交学位论文的电子版和印刷版文件，
    且电子版与印刷版内容应完全相同，允许该论文被检索、查阅和借阅，公布本学
    位论文的全部或部分内容，可以采用扫描、影印、缩印等复制手段以及其他法律
    许可的方式保存、汇编本学位论文。

    涉密及延迟公开的学位论文在解密或延迟期后适用本声明。
  ]
  v(18pt)

  align(center)[
    #set text(font: fonts.宋体, size: 字号.小四)

    #h(2.5em)作者签名：#h(10em) 导师签名：#h(6em)

    #h(2.5em)日#h(2em)期：#h(10em) 日#h(2em)期：#h(6em)
  ]
}
