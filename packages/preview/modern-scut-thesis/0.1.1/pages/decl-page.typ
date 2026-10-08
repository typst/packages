// SCUT 原创性声明与版权授权书
// 版式还原自 local/SCUT_thesis/cover_file/master_cover.docx
#import "../utils/custom-cuti.typ": fakebold
#import "../utils/section-break.typ": section-break
#import "../utils/style.typ": 字体, 字号

#let decl-page(
  open-right: false,
  blind: "none",
  fonts: (:),
  address: "广东省广州市天河区华南理工大学（五山校区）3号楼",
) = {
  // 双盲评审不包含声明页
  if blind == "double" { return }

  fonts = 字体 + fonts

  section-break(open-right: open-right)

  set text(font: fonts.宋体, size: 字号.四号)
  set par(leading: 0.75em, spacing: 0.75em)

  // ====== 原创性声明 ======
  v(8pt)

  align(
    center,
    text(font: fonts.宋体, size: 字号.二号)[
      #set par(leading: 0.75em)
      #fakebold[华南理工大学] \
      #fakebold[学位论文原创性声明]
    ],
  )

  v(29pt)

  block[
    #set par(justify: true, first-line-indent: (amount: 2em, all: true))

    本人郑重声明：所呈交的论文是本人在导师的指导下独立进行研究所取得的研究成果。除了文中特别加以标注引用的内容外，本论文不包含任何其他个人或集体已经发表或撰写的成果作品。对本文的研究做出重要贡献的个人和集体，均已在文中以明确方式标明。本人完全意识到本声明的法律后果由本人承担。
  ]

  v(18pt)

  block[
    #set par(first-line-indent: (amount: 2em, all: true))

    作者签名：#h(8em)日期：#h(1.3em)年#h(1.3em)月#h(1.3em)日
  ]

  v(29pt)

  // ====== 版权使用授权书 ======
  align(
    center,
    text(font: fonts.宋体, size: 字号.二号, fakebold[学位论文版权使用授权书]),
  )

  v(29pt)

  block[
    #set par(justify: true, first-line-indent: (amount: 2em, all: true))

    本学位论文作者完全了解学校有关保留、使用学位论文的规定，即：研究生在校攻读学位期间论文工作的知识产权单位属华南理工大学。学校有权保存并向国家有关部门或机构送交论文的复印件和电子版，允许学位论文被查阅（除在保密期内的保密论文外）；学校可以公布学位论文的全部或部分内容，可以允许采用影印、缩印或其它复制手段保存、汇编学位论文。本人电子文档的内容和纸质论文的内容相一致。

    本学位论文属于：

    // 字符 □ 放大后笔画等比例变粗，参考为细线方框，改用等尺寸绘制
    #let checkbox() = box(baseline: 0pt, rect(width: 10pt, height: 10pt, stroke: 0.5pt))

    #checkbox()#h(0.2em)保密（校保密委员会审定为涉密学位论文时间：\_\_\_年\_\_月\_\_日），\
    于\_\_\_年\_\_月\_\_日解密后适用本授权书。

    #checkbox()#h(0.2em)不保密，同意在校园网上发布，供校内师生和与学校有共享协议的单位浏览；同意将本人学位论文编入有关数据库进行检索，传播学位论文的全部或部分内容。

  ]

  block[
    #set par(first-line-indent: (amount: 3.5em, all: true))

    （请在以上相应方框内打“√”）
  ]

  v(8pt)

  pad(
    left: 2em,
    grid(
      columns: (198pt, 1fr),
      row-gutter: 10pt,
      [作者签名：], [日期：],
      [指导教师签名：], [日期：],
      [作者联系电话：], [电子邮箱：],
    ),
  )

  v(6pt)

  // 参考中地址行顶格起排；字距微收避免末字溢出换行
  // 需显式清除缩进设置，防止 doc 布局的首行缩进渗入导致换行
  block[
    #set par(first-line-indent: (amount: 0em, all: true), justify: false)

    #text(tracking: -0.05em)[联系地址(含邮编)：#address]
  ]

  // 声明页单面印刷，背面留白
  if open-right {
    section-break(open-right: true)
  }
}
