#import "../utils/zh-aio.typ": *
#import "../utils/custom-heading.typ": header
// #import "../utils/invisible-heading.typ": invisible-heading
// #import "../utils/pagebreak-from-odd.typ": pagebreak-from-odd
#import "../utils/style.typ":字体, 字号
#let resume(anonymous: false, ..args) = {
  set page(header: header())
  let title = "个人简历、在读期间发表的学术成果"
  heading(title, numbering: none, level: 1, outlined: true)
  set text(font: 字体.宋体, size: zh(5))
  let ls = 5.05pt
  set par(leading: ls, spacing: ls, first-line-indent: 0em)
  v(6pt)
  if (not anonymous) {
    block[
      *个人简历：*

      XX，男/女，X年X月生。

      X年X月毕业于XX大学 XX专业 获学士学位。

      X年X月入同济大学攻读硕士/博士学位。
      #linebreak()
      #linebreak()
      *已发表论文：*

      [1] XX，XX.结构……研究. 地震工程与工程振动，2020，Vol.21（3）: 70-74.
      #linebreak()
      #linebreak()

      *待发表论文：*

      [1] XX，XX. 随机结构分析中的……研究.力学季刊（已接收）


      #linebreak()
      #linebreak()
      *待发表专利：*

      [1] XX，XX. 一种XX方法

    ]
  } else {
    block[
      *个人简历：*

      #linebreak()
      #linebreak()
      *已发表论文：*

      [1] 第一作者. XXX学术会议.

      [2] 第二作者. Journal of XX.

      [3] 第二作者. XX.

      #linebreak()
      #linebreak()
      *待发表论文：*

      [1] 第一作者. Journal of XX.（在投）

      #linebreak()
      #linebreak()
      *研究报告：*
    ]
  }
}