#import "@preview/cuti:0.3.0": show-cn-fakebold

#let school-title-pic = "./template/images/sdu-title-image.jpg"
#let school-logo-pic = "./template/images/sdu-pic-image.jpg"
#let school-title = "shandong university"
#let main-show-pic = "./template/images/sdu-report-image.png"
#let main-show-text = "实验报告展示"

#let field(label, content) = (
  [
    #set align(left + horizon)
    #block(
      width: 100%,
      stroke: (bottom: white + 0.5pt), 
      inset: (top: 0pt, bottom: 5pt),
    )[
      #set text(font: ("KaiTi"))
      #text(size: 16pt)[#label]
    ]
  ],
  [
    #set align(center + horizon)
    #block(
      width: 100%, 
      stroke: (bottom: 0.5pt), 
      inset: (top: 0pt, bottom: 5pt),
    )[
      #set text(font: ("Times New Roman", "KaiTi"), size: 16pt)
      #set par(first-line-indent: 0pt, leading: 0em)
      #content
    ]
  ]
)
#let showpage(
  course : "", 
  class : "", 
  author : "", 
  stdid : "", 
  college : "", 
  title : "",
) = {
  set page(
    paper: "a4",
    margin: (top: 2.12cm,bottom: 3cm,left: 1cm,right: 1cm),
    numbering: none,
  )
  show: show-cn-fakebold
  align(center)[
    #image(school-title-pic,width: 10.8cm)
    #text(font: "Times New Roman",size: 20pt,)[#upper(school-title)]
    #v(0.5cm)
    #text(size: 16pt)[#underline(course) 课程实验报告]
    #image(school-logo-pic,width: 12cm)
    #v(0.0cm)
    #grid(
      columns: (80pt, 180pt),
      column-gutter: 0em,
      row-gutter: 10pt,
      ..field([主#h(2em)题],title),
      ..field([学#h(2em)院:],college),
      ..field([班#h(2em)级:],class),
      ..field([姓#h(2em)名:], author),
      ..field([学#h(2em)号:],stdid),
    )
  ]
}
#let reportpage(
  body,
) = {
  set page(
    paper: "a4",
    margin: (top: 2.58cm,bottom: 2cm,left: 1.2cm,right: 1.2cm),
    numbering : none,
    header-ascent: 0.0cm,
    header: [
      #set text(font: ("Times New Roman", "KaiTi"),size: 18pt)
      #grid(
        columns: (1fr,1fr),
        align: bottom,
        image(main-show-pic,width: 6.8cm),
        [
          #align(right)[#text(size: 16pt)[#main-show-text]]
          #v(0.45cm)
        ]
      )
      #v(-1.05em)
      #line(length: 100%,stroke: 1.5pt)
    ],
    background: place(top+left,dx: 1.2cm,dy: 2.58cm + 0.5cm)[
      #box(
        width: 100% - 1.2cm - 1.2cm,
        height: 100% - 2.58cm - 2cm - 0.5cm,
        stroke: 1pt
      )
    ],
    footer: align(center)[
      #set text(font: ("Times New Roman", "KaiTi"),size: 16pt)
      #context[
         #counter(page).display("1") 
      ]
    ],
  )
  show : rest => pad(
    top: 0.75cm,
    bottom: 0.3cm,
    left: 0.2cm,
    right: 0.2cm,
    rest
  )
  set text(font : ("JetBrains Mono", "KaiTi"),size: 12pt)
  set par(
    justify: true,
    leading: 1.2em, //行间距
    spacing: 1.5em, //段间距
  )
  show strong: set text(stroke: 0.02857em) 
  show emph: it => {
    show regex("[\p{Unified_Ideograph}\p{Punctuation}]"): char => {
      box(skew(ax: -12deg, char))
    }
    it
  }
  set heading(numbering: "一 I")
  show heading : it => {
    let nums = if it.numbering != none { counter(heading).at(it.location()) } else {none}
    let font_pattern = ""
    let title_size = 12pt
    let numbering_str = none
    if it.level == 1 {
      font_pattern = ("Times New Roman", "KaiTi")
      title_size = 16pt
      numbering_str = numbering("一",..nums)
      //colbreak(weak : true)
    }else{
      font_pattern = ("Times New Roman", "KaiTi")
      if nums != none {
        nums = nums.slice(1)
        numbering_str = numbering("I",..nums)
      }
    }
    set text(font : font_pattern,size : title_size,weight : "bold")
    if it.level > 1 {
      v(2em,weak : true)
    }
    grid(
      columns: (auto,1fr),
      column-gutter: 0.6em,
      align : bottom,
      [#numbering_str],
      [#it.body]
    )
    v(1.5em,weak : true)
  }
  show raw.where(block : true) : block.with(
    fill: luma(81.81%, 74.7%), // 浅灰色背景
    inset: 10pt,     // 内边距
    radius: 6pt,     // 圆角
    width: 100%,     // 宽度填满
  )
  show raw : set text(font: "JetBrains Mono",size : 12pt)
  body
}