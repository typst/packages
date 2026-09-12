#import "@preview/pointless-size:0.1.1": zh
#import "@preview/cuti:0.3.0": show-cn-fakebold
#show: show-cn-fakebold
#set page(margin: (
  top: 3.5cm,
  bottom: 2.5cm,
  left: 2.5cm,
  right: 2.5cm
))
#set par(
  justify: true,
  first-line-indent: 1.01cm,
  leading: 17pt
)

//! 独创性声明标题
#v(23pt)
#align(
  center,
  text(
    font: "SimHei",
    size: zh(2),
    tracking: 4pt
  )[
    #strong("独创性声明")
  ]
)

//! 独创性声明正文
#v(19pt)
#set text(font: "SimSun", size: zh(-3))
本人声明所呈交的论文是我个人在导师指导下进行的研究工作及取得的研究成果。尽我所知，除了文中特别加以标注和致谢的地方外，论文中不包含其他人已经发表或撰写的研究成果，也不包含为获得江西财经大学或其他教育机构的学位或证书所使用过的材料。与我一同工作的同志对本研究所做的任何贡献均已在论文中作了明确的说明并表示了谢意。

//! 签名与日期
#v(3*17.5pt)
#set text(font: "SimSun", size: zh(4))
#par(
  justify: true,
  first-line-indent: 6.75cm,
  leading: 15pt
)[
  签名：#underline("         ")日期：#underline("         ")
]

//! 使用授权标题
#v(2*19.5pt)
#align(
  center,
  text(
    font: "SimHei",
    size: zh(2)
  )[
    #strong("关于论文使用授权的说明")
  ]
)

//! 使用授权正文
#v(19pt)
#set text(font: "SimSun", size: zh(-3))
本人完全了解江西财经大学有关保留、使用学位论文的规定，即：学校有权保留送交论文的复印件，允许论文被查阅和借阅；学校可以公布论文的全部或部分内容，可以采用影印、缩印或其他复制手段保存论文。

*（保密的论文在解密后遵守此规定）*

//! 签名、导师签名与日期
#v(3*17pt)
#set text(font: "SimSun", size: zh(4))
#par(
  justify: true,
  first-line-indent: 1.5cm,
  leading: 15pt
)[
  签名：#underline("         ")导师签名：#underline("         ")日期：#underline("         ")
]
