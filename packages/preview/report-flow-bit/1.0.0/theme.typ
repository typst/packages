// #import "@preview/chic-hdr:0.4.0": *
#import "lib.typ": *

#let CODE_SIZE=8pt
#let TEXT_SIZE=10pt

#let Heiti = ("Times New Roman", "Heiti SC", "Heiti TC", "SimHei")
#let Songti = ("Times New Roman", "Songti SC", "Songti TC", "SimSun")
#let Zhongsong = ("Times New Roman", "STZhongsong", "SimSun")
#let Xbs = ("Times New Roman", "FZXiaoBiaoSong-B05", "FZXiaoBiaoSong-B05S")

// #let indent() = {
//   box(width: 2em)
// }
// 


#let info_key(body) = {
  rect(width: 100%, inset: 2pt, stroke: none, text(font: Zhongsong, size: 16pt, body))
}

#let info_value(body) = {
  rect(
    width: 100%,
    inset: 2pt,
    stroke: (bottom: 1pt + black),
    text(font: Zhongsong, size: 16pt, bottom-edge: "descender")[ #body ],
  )
}

#let project(
  course: "COURSE",
  lab_name: "LAB NAME",
  stu_name: "NAME",
  stu_num: "1234567",
  major: "MAJOR",
  department: "DEPARTMENT",
  date: (2077, 1, 1),
  show_content_figure: false,
  watermark: "",
  body,
) = {

  show raw: set text(font: ("Jetbrains Mono NL","PingFang SC","Iosevka", "Fira Mono"), size: CODE_SIZE)
  set page("a4",
  margin: (x: 1.5cm,y: 2cm)
  )
  // 封面
  align(center)[
    #image("./assets/ustc-name.svg", width: 70%)
    #v(1em)
    // #set text(
    //   size: 26pt,
    //   font: Zhongsong,
    //   weight: "bold",
    // )

    // 课程名
    #text(size: 25pt, font: Xbs)[
      _#course _课程实验报告
    ]
    // #v(1em)

    // 报告名
    #text(size: 22pt, font: Xbs)[
      _#lab_name _
    ]
    // #v(0.5em)

    #image("./assets/USTC-NO-TEXT.svg", width: 60%)
    // #v(0.5em)

    // 个人信息
    #grid(
      columns: (40pt, 270pt,40pt),
      rows: (40pt, 40pt),
      gutter: 0pt,
      info_key("学院"),
      info_value(department),
      rect(
        width: 100%,
        inset: 2pt,
        stroke: (bottom: 1pt + black),
        text(font: Zhongsong, size: 16pt, bottom-edge: "descender", fill: white)[#department.at(0)],
      ),
      info_key("专业"),
      info_value(major),
      rect(
        width: 100%,
        inset: 2pt,
        stroke: (bottom: 1pt + black),
        text(font: Zhongsong, size: 16pt, bottom-edge: "descender", fill: white)[#major.at(0)],
      ),
      info_key("姓名"),
      info_value(stu_name),
      rect(
        width: 100%,
        inset: 2pt,
        stroke: (bottom: 1pt + black),
        text(font: Zhongsong, size: 16pt, bottom-edge: "descender", fill: white)[#stu_name.at(0)],
      ),
      info_key("学号"),
      info_value(stu_num),
      rect(
        width: 100%,
        inset: 2pt,
        stroke: (bottom: 1pt + black),
        text(font: Zhongsong, size: 16pt, bottom-edge: "descender", fill: white)[#stu_num.at(0)],
      ),
    )
    #v(2em)

    // 日期
    #text(font: Zhongsong, size: 14pt)[
      #date.at(0) 年 #date.at(1) 月 #date.at(2) 日
    ]
  ]
  pagebreak()



    // 水印
  set page(background: rotate(-60deg,
  text(240pt,tracking: 60pt, fill: rgb("#005c330f"), font:"Times New Roman")[
      #strong()[#watermark]
    ]
  ),
  )

  // 目录
  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    strong(it)
  }
  show outline.entry: it => {
    set text(
      font: Xbs,
      size: 12pt,
    )
    it
  }
  outline(
    title: text(font: Xbs, size: 16pt, fill: rgb("#034ea1"))[目录],
    indent: auto,
  )
  if show_content_figure {
    text(font: Xbs, size: 10pt)[
      #i-figured.outline(title: [图表])
    ]
  }
  pagebreak()

  set page(
  columns: 2,
  header: [
    #set text(8pt)
    #course -- #lab_name
    #h(1fr) #text(font:Xbs,fill:rgb("#a13f3d"))[BIT]
  ],
  // number-align: right,
  // numbering: "壹 / 壹",
)

set page(
    footer: context {
      // 获取当前页码
      let i = counter(page).at(here()).first()

      // 根据奇偶页设置对齐方式
      let is-odd = calc.odd(i)
      let aln = if is-odd { right } else { left }

      // 获取所有一级和二级标题
      let level1_headings = heading.where(level: 1)
      let level2_headings = heading.where(level: 2)

      // 检查当前页是否包含一级标题
      if query(level1_headings).any(it => it.location().page() == i) {
        // 仅显示页码
        return align(aln)[#text(fill: rgb("#034ea1"), size: 2em)[#i]]
      }

      // 检查当前页是否包含二级标题
      if query(level2_headings).any(it => it.location().page() == i) {
        // 获取当前的一级标题（在当前位置之前的最后一个）
        let previous_level1 = query(level1_headings.before(here())).last()
        let gap = 0.5em  // 调整间距
        let chapter = upper(text(size: 0.68em, previous_level1.body))

        // 显示页码和一级标题
        if is-odd {
          return align(aln)[
            #grid(
              columns: (40em,2em),
              [#chapter],
              text(fill: rgb("#034ea1"))[#i], 
            )
            
          ]
        } else {
          return align(aln)[
            #grid(
              columns: (2em,40em),
              text(fill: rgb("#034ea1"))[#i],
              [#chapter],
              
            )
            
          ]
        }
      }

      // 当前页既不包含一级标题也不包含二级标题
      // 获取当前的一级和二级标题
      let previous_level1 = query(level1_headings.before(here())).last()
      let previous_level2_query = query(level2_headings.before(here()))
      let previous_level2 = if previous_level2_query.len() > 0 {
        previous_level2_query.last()
      } else {
        none
      }

      // let gap = 0.01em  // 调整间距
      let chapter = upper(text(size: 0.68em, previous_level1.body))

      // 检查是否存在二级标题
      if previous_level2 != none {
        let section = upper(text(size: 0.6em, previous_level2.body))  // 二级标题字号更小

        // 显示页码、一级标题和二级标题，二级标题在一级标题下方
        if is-odd {
          return align(aln)[
            #grid(
              columns: (40em,2em),
              rows: (1fr,1fr,1fr),
              gutter: 0pt,
              [#chapter],
              grid.cell(
                rowspan: 2,
                align(horizon)[#text(fill: rgb("#034ea1"))[#i]]
              ),
              [#section],
              
              
            
            )
            
            
          ]
        } else {
          return align(aln)[
            #grid(
              columns: (2em,40em),
              rows: (1fr,1fr,1fr),
              gutter: 0pt,
              grid.cell(
                rowspan: 2,
                align(horizon)[#text(fill: rgb("#034ea1"))[#i]]
              ),
              [#chapter],
              [#section],
              
            )
          ]
        }
      } else {
        // 如果没有二级标题，仅显示页码和一级标题
        if is-odd {
          return align(aln)[
            #grid(
              columns: (40em,2em),
              [#chapter],
              text(fill: rgb("#034ea1"))[#i], 
            )
            
              // #chapter
              // #v(gap)
              // #i
            
          ]
        } else {
          return align(aln)[
            #grid(
              columns: (2em,40em),
              text(fill: rgb("#034ea1"))[#i],
              [#chapter],
              
            )
            
              // #i
              // #v(gap)
              // #chapter
            
          ]
        }
      }
    },
)




  // 页眉页脚设置
  // show: chic.with(
  //   chic-header(
  //     left-side: smallcaps(
  //       text(size: 10pt, font: Xbs)[
  //         #course -- #lab_name
  //       ],
  //     ),
  //     right-side: text(size: 10pt, font: Xbs)[
  //       #chic-heading-name(dir: "prev")
  //     ],
  //     side-width: (60%, 0%, 35%),
  //   ),
  //   chic-footer(
  //     center-side: text(size: 11pt, font: Xbs)[
  //       #chic-page-number()
  //     ],
  //   ),
  //   chic-separator(1pt),
  //   // chic-separator(on: "header", chic-styled-separator("bold-center")),
  //   chic-separator(on: "footer", stroke(dash: "loosely-dashed", paint: gray)),
  //   chic-offset(40%),
  //   chic-height(2cm),
  // )

  // 正文设置
  // 
  set heading(numbering: "1.1.1.")
  set figure(supplement: [图])
  show heading: i-figured.reset-counters.with(level: 2)
  show figure: i-figured.show-figure.with(level: 2)
  // set math.equation(numbering: none)
  // show math.equation: i-figured.show-equation
  set text(
    font: Songti,
    // font:"Linux Libertine",
    size: TEXT_SIZE,
  )
  set par(    // 段落设置
    justify: false,
    // leading: 1.04em,
    // first-line-indent: 2em,
  )
  show heading: it => box(width: 100%)[ // 标题设置
    #v(0.45em)
    #set text(font: Xbs)
    #if it.numbering != none {
      counter(heading).display()
    }
    #h(0.75em)
    #it.body
    #v(5pt)
  ]
  show link: it => {          // 链接
    set text(fill: rgb("#034ea1"))
    it
  }
  show: gentle-clues.with(    // gentle块
    headless: false, // never show any headers
    breakable: true, // default breaking behavior
    header-inset: 0.4em, // default header-inset
    content-inset: 1em, // default content-inset
    stroke-width: 2pt, // default left stroke-width
    border-radius: 2pt, // default border-radius
    border-width: 0.5pt, // default boarder-width
  )
  show: checklist.with(fill: luma(95%), stroke: blue, radius: .2em)   // 复选框

  // 代码段设置
  show: codly-init.with()
  // codly(
  //   display-icon: true,
  //   stroke-color: luma(200),
  //   zebra-color: luma(0).transparentize(96%),
  //   fill: rgb("ffffff").transparentize(100%),
  //   enable-numbers: true,
  //   breakable: true,
  //   languages: (
  //     rust: (
  //       name: "Rust",
  //       icon: text(font: "tabler-icons", "\u{fa53}"),
  //       color: rgb("#CE412B")
  //     ),
  //   )
  // )

  codly(
    display-icon: true,
    // default-color: rgb("#283593"),
    fill: rgb("ffffff").transparentize(100%),
    stroke: 1pt + luma(200),
    // fill:none,
    zebra-fill: luma(0).transparentize(96%),
    breakable: true,
    // number-format: none,
    languages: (
      rust: (
        name: "Rust",
        icon: text(font: "tabler-icons", "\u{fa53}"),
        color: rgb("#CE412B")
      ),
    )
  )
  show :show-cn-fakebold

  // show raw.where(lang: "pintora"): it => pintorita.render(it.text)
  

  body

  
}
