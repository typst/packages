// 导入外部包
#import "@preview/pointless-size:0.1.1": zh
#import "@preview/muchpdf:0.1.0": muchpdf
#import "@preview/numbly:0.1.0": numbly
#import "@preview/i-figured:0.2.4"
#import "@preview/zebraw:0.5.4": *

//导入组件函数
#import "components/figure.typ": thesis-figure
#import "components/table.typ": thesis-table

//导入工具函数
#import "utils/header.typ": dynamic-header

//导入页面函数
#import  "pages/abstract.typ": abstract
#import "pages/declaration.typ": declaration
#import "pages/toc.typ": toc
#import "pages/list-of-figures.typ": list-of-figures,list-of-tables
#import "pages/acknowledgements.typ": acknowledgements
#import "pages/references.typ": references
#import "pages/appendix.typ": appendix





#let global-conf(title:none,body) =  {

//**********文档元数据设置**********
set document(
  title: title,
  author: "author",
  keywords: "keyword1,keyword2,keyoword3"
)


//**********页面设置**********
set page(
  paper: "a4",
  margin: (top: 30mm, bottom: 30mm, left: 30mm, right: 30mm),
  header: dynamic-header,
  numbering: "1", 
)
counter(page).update(1)


//**********文本设置**********
// 设置全文默认字体
set text(font: ("SimSun", "Times New Roman"), size: zh(-4))  
// 设置段落属性
set par(justify: true, first-line-indent: (amount:2em,all:true), leading: 1em) 
// 设置标题格式
// 设置标题序号
set heading(numbering: (..args) => {
  let nums = args.pos()
  if nums.len() == 1 {
    return numbly("第{1:一}章 ")(..nums)
  } else if nums.len() == 2 {
    // 二级标题：1.1格式（带点）
    return numbering("1.1", ..nums)
  } else if nums.len() == 3 {
    // 三级标题：1.1.1格式（不带点）
    return numbering("1.1.1", ..nums)
  } else {
    // 更深层级：使用默认格式
    return numbering("1.1.1.1", ..nums)
  }
})
//设置标题格式
show heading.where(level: 1): it => {
  v(24pt)
  set text(font: "SimHei", size: zh(-3), weight: "regular")
  align(center, it)
  v(18pt, weak: false)
}
show heading.where(level: 2): it => {
  v(18pt,weak: true)
  set text(font: "SimHei", size: zh(4), weight: "regular")
  it
  v(6pt, weak: false)
}
show heading.where(level: 3): it => {
  set text(font: "SimHei", size: zh(4), weight: "regular")
  v(12pt)
  it
  v(6pt, weak: false)
}
show heading.where(level: 4): it => {
  set text(font: "SimSun", size: zh(-4), weight: "regular")
  v(12pt)
  it
  v(6pt, weak: false)
}

// **********图表设置**********
//设置图表编号
//  为图表编号设置x-y样式
show heading: i-figured.reset-counters.with(level: 1) //分章节重置计数
show figure: i-figured.show-figure.with(
  level: 1,
  zero-fill: false,
  leading-zero: false,
  numbering: "1-1",   //x-y样式
)
//去除图表编号和文本间的默认分隔符 ：
show figure.where(
  kind: image,
): set figure.caption(separator: [ ])
show figure.where(
  kind: table,
): set figure.caption(separator: [ ])
// 设置图表标题位置朝上
show figure.where(kind: table): it => {
  set figure.caption(position: top)
  it
}
//设置图表编号的引用格式
show ref.where(form: "normal"): it => {
  let el = it.element
  if el != none and el.func() == figure {
    let supplement = el.supplement
    let chapterNum = counter(heading).at(el.location()).at(0)
    let counterSelector = if supplement == "图" {
      figure.where(kind: "i-figured-image")
    } else {
      figure.where(kind: "i-figured-table")
    }
    let figureNum = if supplement == "图" {
      counter(counterSelector).at(el.location()).first()
    } else {
      counter(counterSelector).at(el.location()).first()
    }

    link(el.location(), [#supplement#(chapterNum)-#(figureNum)])
  } else { it }
}



//**********数学公式设置**********
// 设置数学公式编号
set math.equation(numbering: {
  let chapterNum = context counter(heading).get().at(0)
  it => {
    set text(size: zh(-4), font: "Times New Roman")
    "(" + chapterNum + "-" + str(it) + ")"
  }
})


//**********脚注设置**********
show footnote.entry: set text(font: "SimSun", size: zh(5))


// **********代码格式美化设置**********
show: zebraw

body

}






