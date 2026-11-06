#import "dependency.typ" : *
#let font = (
  main: "Source Han Serif",
  mono: "IBM Plex Mono",
  cjk: "Noto Serif CJK SC",
)
#let cjk-markers = regex("[“”‘’．，。、？！：；（）｛｝［］〔〕〖〗《》〈〉「」【】『』─—＿·…\u{30FC}]+")

#let 字号 = (
  初号: 42pt,
  小初: 36pt,
  一号: 26pt,
  小一: 24pt,
  二号: 22pt,
  小二: 18pt,
  三号: 16pt,
  小三: 15pt,
  四号: 14pt,
  中四: 13pt,
  小四: 12pt,
  五号: 10.5pt,
  小五: 9pt,
  六号: 7.5pt,
  小六: 6.5pt,
  七号: 5.5pt,
  小七: 5pt,
)

#let report(
  institute: "计算机科学与技术",
  course: "人工智能引论",
  student-id: "你的学号",
  student-name: "李明",
  date: datetime.today(),
  lab-title: "实验题目",
  class: "你的班级",
  exp-time: "实验时间",
  body
) = {

  set text(
    font: ("Source Han Serif", "Fira Sans"),
    size: 10.5pt,
    lang: "zh", region: "cn"
    // leading: 1.6
  )
  set page(
    paper: "a4",
    margin: (top: 2.6cm, bottom: 2.3cm, inside: 2cm, outside: 2cm),
    footer: [
      #set align(center)
      #set text(9pt)
      #context {
        counter(page).display("1")
      }
    ],
  )
  set document(title: lab-title, author: student-name)
  
  set heading(
    numbering: numbly(
    "{1:一}、", // use {level:format} to specify the format
    "{2:1}.", // if format is not specified, arabic numbers will be used
    "({3:1})", // here, we only want the 3rd level
  ),)
  set par(justify: true)
  show math.equation.where(block: true): it => block(width: 100%, align(center, it))

  set raw(tab-size: 4)
  show raw: set text(font: (font.mono, font.cjk))
  // Display inline code in a small box
  // that retains the correct baseline.
  show raw.where(block: false): box.with(fill: luma(240), inset: (x: 3pt, y: 0pt), outset: (y: 3pt), radius: 2pt)
  show raw: it => {
    show ".": "." + sym.zws
    show "=": "=" + sym.zws
    show ";": ";" + sym.zws
    it
  }
  let style-number(number) = text(gray)[#number]
  show raw.where(block: true): it => {
    align(center)[
      #block(
        fill: luma(240),
        inset: 10pt,
        radius: 4pt,
        width: 100%,
      )[
        #place(top + right, dy: -15pt)[
          #set text(size: 9pt, fill: white, style: "italic")
          #block(
            fill: gray,
            outset: 4pt,
            radius: 4pt,
            // width: 100%,
            context {
              it.lang
            }
          )
        ]
        #set par(justify: false, linebreaks: "simple")
        #grid(
          columns: (1em, 1fr),
          align: (right, left),
          column-gutter: 0.7em,
          row-gutter: 0.6em,
          // stroke: 1pt,
          ..it.lines.enumerate().map(((i, line)) => (style-number(i + 1), line)).flatten(),
        )

      ]]
  }

  show link: it => {
    set text(fill: blue)
    underline(it)
  }

  set list(indent: 6pt)
  set enum(indent: 6pt)
  set enum(
    numbering: numbly(
      "{1:1})",
      "{2:a}.",
    ),
    full: true,
  )

  counter(page).update(1)
  [
    #show heading: it => {
      set align(center)
      set text(size: 字号.小二, weight: "bold")
      it
    }
    #set text(tracking: 0.1em)
    #heading(numbering: none, depth: 1)[山东大学 #underline(extent:2pt,[#institute] ) 学院
    
    #underline(extent:2pt,[#course] ) 课程实验报告]
  ]

  show heading: set block(spacing: 1.5em)
  // show heading: set block(above: 1.4em, below: 1em)

  show heading.where(depth: 1): it => {
    show h.where(amount: 0.3em): none
    set text(size: 字号.小四)
    it
  }

  show heading: it => {
    set text(size: 字号.小四)
    it
  }

  set text(size: 字号.小四)
  set par(first-line-indent: 2em)
  let fakepar = context {
    box()
    v(-measure(block() + block()).height)
  }
  show math.equation.where(block: true): it => it + fakepar // 公式后缩进
  show heading: it => it + fakepar // 标题后缩进
  show figure: it => it + fakepar // 图表后缩进
  show enum: it => {
    // it.numbering + fakepar
    it
    // for item in it.children {
    //   context {
    //     counter(it.numbering).display()
    //   }
    //   [
    //     #item.body
    //   ]
    // }

    fakepar
  }
  // show enum.item: it => {
  //   repr(it)
  //   it
  // }
  show list: it => {
    it
    fakepar
  }
  show grid: it => it + fakepar // 列表后缩进
  show table: it => it + fakepar // 表格后缩进
  show raw.where(block: true): it => it + fakepar

  [
    #set par(justify: true)
    #set text(size: 字号.小四)
    #table(
      align: left + horizon,
      inset: 0.5em,
      columns: (3.1fr, 2.7fr, 2.9fr),
      [学号： #student-id], [姓名：  #student-name], [班级：#class]
    )
    #v(0em, weak: true)
    #table(
      inset: 0.5em,
      align: left + horizon,
      columns: (4fr),
      [实验题目：#lab-title],
    )
    #v(0em, weak: true)
    #table(
      inset: 0.5em,
      align: left + horizon,
      columns: (2fr,2fr),
      [实验学时：#exp-time], [实验日期：#date.display()],
    )
  ]
  v(0em, weak: true)
  show heading.where(depth: 1): it => {
    show h.where(amount: 0.3em): none
    set text(size: 字号.小四)
    [
      #block(
        width: 100%,
        inset: 0em,
        stroke: none,
        breakable: true,
        it
      )
    ]
  }
  body
  
}
#let exp-block(content) ={
v(0em, weak: true)
block(
  width: 100%,
  inset: 1em,
  stroke: 1pt,
  breakable: true,
  content+v(1em)
)
}