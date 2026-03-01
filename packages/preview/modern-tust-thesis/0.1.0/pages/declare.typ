#import "../utils/style.typ": zihao, ziti
#import "../utils/uline.typ": center-box, uline
#import "../utils/checkbox.typ": checkbox

#let declare-page(
  doctype: "bachelor",
  twoside: false,
  anonymous: false,
  original-statement-sign: none,
  authorization-author-sign: none,
  supervisor-sign: none,
  info: (:),
) = {
  if anonymous {
    return
  }

  pagebreak()
  set page(header: none, footer: none)

  align(center, text(
    font: ziti.heiti,
    size: zihao.sanhao,
    weight: "bold",
  )[
    天津科技大学

    学位论文原创性声明
  ])

  set text(font: ziti.songti, size: zihao.xiaosi)
  set par(first-line-indent: 2em, leading: 16pt, spacing: 16pt)

  v(1em)

  [本人郑重声明：所呈交的学位论文，是本人在导师的指导下，独立进行研究工作所取得的成果。除文中已经注明引用的内容外，本论文不包含任何其他个人或集体已经发表或撰写过的作品成果。对本文的研究做出重要贡献的个人和集体，均已在文中以明确方式标明。本人完全知晓本声明的法律后果由本人承担。]

  linebreak()
  linebreak()

  align(right, text()[
    学位论文作者签名：#h(6.6em)
    #if original-statement-sign != none {
      original-statement-sign
    }

    日期：#center-box(2.5em)[] 年 #center-box(1.25em)[] 月 #center-box(1.25em)[] 日 #h(3.4em)
  ])

  v(2fr)

  align(center, text(
    font: ziti.heiti,
    size: zihao.sanhao,
    weight: "bold",
  )[
    天津科技大学

    学位论文使用授权书
  ])

  v(1em)

  [本人同意学校保留并向国家有关部门或机构送交论文的复印件和电子版，允许论文被查阅和借阅。]

  v(0.3em)

  h(-2em)
  [
    本学位论文属于：

    #checkbox *公开论文*

    $square$ *内部论文*，保密 $square$ 1年/ $square$ 2年/ $square$ 3年，过保密期后适用本授权书。

    $square$ *秘密论文*，保密#uline(2.5em)[]年（不超过10年），过保密期后适用本授权书。

    $square$ *机密论文*，保密#uline(2.5em)[]年（不超过20年），过保密期后适用本授权书。
  ]

  linebreak()
  h(8em)
  [（请在以上方框内选择打"$checkmark$"）]
  linebreak()
  linebreak()

  columns(2)[
    #align(right, text()[
      学位论文作者签名：#h(6.6em)
      #if authorization-author-sign != none {
        authorization-author-sign
      }

      日期：#center-box(2.5em)[] 年 #center-box(1.25em)[] 月 #center-box(1.25em)[] 日 #h(3.4em)
    ])
    #colbreak()
    #align(right, text()[
      指导教师签名：#h(8.6em)
      #if supervisor-sign != none {
        supervisor-sign
      }

      日期：#center-box(2.5em)[] 年 #center-box(1.25em)[] 月 #center-box(1.25em)[] 日 #h(3.4em)
    ])
  ]

  v(1fr)

  pagebreak(weak: true, to: if twoside {
    "odd"
  })
}
