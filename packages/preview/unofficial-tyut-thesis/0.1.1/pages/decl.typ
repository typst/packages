#import "@preview/pointless-size:0.1.1": zh
#let decl(
  anonymous: false,
  twoside: false,
  author-signature: none,
  supervisor-signature: none,
  info: (:),
) = {
  // 匿名送审不需要此页内容
  if anonymous {
    return
  }

  pagebreak(weak: true, to: if twoside { "odd" })

  set par(
    first-line-indent: (amount: 2em, all: true),
    leading: 1.5em,
  )

  [
    #v(24pt)
    #align(center)[
      #text(font: "SimHei", size: zh(3))[声明及论文使用的授权]]
    #v(10pt)

    #set text(size: zh(4), font: "SimSun")
    本人郑重声明：所呈交的毕业设计（论文）是本人在指导教师的指导下取得的研究成果，毕业设计（论文）写作严格遵循学术规范。除了文中特别加以标注和致谢的地方外，毕业设计（论文）中不包含其他人已经发表或撰写的研究成果。因本毕业设计（论文）引起的法律结果完全由本人承担。太原理工大学享有本毕业设计（论文）的研究成果。

    #v(5em)

    #stack(
      dir: ltr,
      stack(
        dir: ltr,
        [论文作者签名：],
        if author-signature != none { author-signature },
      ),
      1fr,
      if "author-sign-date" in info {
        info.author-sign-date.display("[year]年[month padding:none]月[day padding:none]日")
      } else {
        [年#h(1cm)月#h(1cm)日]
      },
      h(2cm),
    )
    #v(7em)

    本毕业设计（论文）作者和指导教师同意太原理工大学保留使用毕业设计（论文）的规定，即：学校有权保留送交毕业设计（论文）的复印件，允许毕业设计（论文）被查阅和借阅；学校可以上网公布全部内容，可以采用影印、缩印或其他复制手段保存毕业设计（论文）。

    #v(7em)

    #stack(
      dir: ltr,
      spacing: 2cm,
      stack(
        dir: ttb,
        spacing: 2em,
        stack(
          dir: ltr,
          [论文作者签名：],
          [#if author-signature != none { author-signature }],
        ),
        stack(
          dir: ltr,
          [签字日期：],
          if "author-sign-date" in info {
            h(0.2cm)
            info.author-sign-date.display("[year]年[month padding:none]月[day padding:none]日")
          } else { [#h(1cm)年#h(1cm)月#h(1cm)日] },
        ),
      ),

      stack(
        dir: ttb,
        spacing: 2em,
        stack(
          dir: ltr,
          [指导教师签名：],
          [#if supervisor-signature != none { supervisor-signature }],
        ),
        stack(
          dir: ltr,
          [签字日期：],
          if "supervisor-sign-date" in info {
            h(0.2cm)
            info.supervisor-sign-date.display("[year]年[month padding:none]月[day padding:none]日")
          } else { [#h(1cm)年#h(1cm)月#h(1cm)日] },
        ),
      ),
    )
  ]
}
