#import "../utils/style.typ": 字号, 字体
#import "../utils/custom-cuti.typ": fakebold

//本科生版权使用授权书

#let bachelor-copyright(
  anonymous:false,
  twoside: false,
  fonts:(),

) = {
  fonts = 字体 + fonts
  pagebreak(weak: true, to: if twoside { "odd" })
  v(30pt)

  align(center,
  text(font: fonts.黑体, size: 字号.小二, weight: "bold", "西南交通大学\n本科毕业设计（论文）版权使用授权书"),
  )
  v(30pt)

  block[
    #set text(font: fonts.宋体,size: 字号.小三)
    #set par(justify: true, first-line-indent: (amount: 2em, all: true), leading: 1em)

    本毕业设计（论文）作者同意学校保留并向国家有关部门或机构送交论文的复印件和电子版，允许论文被查阅和借阅。本人授权西南交通大学可以将本毕业设计（论文）的全部或部分内容编入有关数据库进行检索，可以采用影印、缩印或扫描等复制手段保存和汇编本毕业设计（论文）。

 

    #set par(first-line-indent: 2em, justify: false, leading: 2em)
    #grid(
      columns: (2em, 6em, auto),
      align: (left, left, left),
      row-gutter: 1.5em,
      [], [], [#fakebold[保密] $square$，在 \_\_ 年解密后适用本授权书。],
      [], [本论文属于], [],
      [], [], [#fakebold[不保密] $square$。],
    )

    #v(0em)
    #block[
      #set par(first-line-indent: 0em)
      #h(2em)（请在以上方框内打 “$checkmark$”）
    ]
    
    #v(5em)

    #block[
      #set par(first-line-indent: 0em, leading: 4em)
      #grid(
        columns: (70%, 50%),
        [
          作者签名：\
          日期：#h(1em)年#h(1em)月#h(1em)日
        ],
        [
          指导教师签名：\
          日期：#h(1em)年#h(1em)月#h(1em)日
        ]
      )
    ]
  ]

}