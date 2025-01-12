// lib.typ
// 库

// 页面
// 
// 页面函数
#import "../pages/cover.typ": cover
#import "../pages/preface.typ": preface-content

// 布局
// 
// 布局.变量
#import "../layouts/heading-styles.typ": heading-styles
#import "../layouts/ordinary-layouts.typ": ordinary-layouts
//
// 布局.函数
#import "../layouts/cornell-lines.typ": cornell-lines
#import "../layouts/cornell-layouts.typ": cornell-layouts

// 工具
// 
// 工具.变量
#import "../utils/sectionline.typ": sectionline
// 
// 工具.函数
#import "../utils/colors.typ": *
#import "../utils/color-box.typ": *
#import "../utils/left-note.typ": left-note
#import "../utils/bottom-note.typ": bottom-note
#import "../utils/bibliography.typ": bibliography-content
// 
// 工具.外部库
#import "../utils/codly.typ":*
#import "../utils/codly-languages.typ":*

// cornell-note 模板函数
// 此函数用于创建康奈尔笔记风格的文档
#let cornell-note(
  title: "",
  author: "",
  abstract: "",
  createtime: "",
  bibliography-style: "ieee",
  lang: "zh",
  preface: none,
  body,
  bibliography-file: none,
) = {
  set text(lang: lang)
  set document(author: author, date: auto, title: title)

  // 标题计数器
  let chaptercounter = counter("chapter")
  set heading(numbering: "1.1.1.1.1.")

  // 将页面设置和其他依赖于 context 的操作包装在 context 块中
  context {
    
    // 标题样式
    show heading: heading-styles.main
    show heading.where(level: 1): heading-styles.level1
    show heading: heading-styles.other

    // 设置目录样式
    set  outline(fill: repeat[~.], indent: 1em)
    show outline: set heading(numbering: none)
    show outline: set par(first-line-indent: 0em)
    show outline.entry.where(level: 1): it => {
      text(font: "libertinus serif", rgb("#2196F3"))[#strong[#it]]
    }
    show outline.entry: it => {
      h(1em)
      text(font: "libertinus serif", rgb("#2196F3"))[#it]
    }

    // 设置首行缩进
    set par(first-line-indent: 2em)
    let fakepar = context {
      let b = par(box())
      b
      v(-measure(b + b).height)
    }
    show math.equation.where(block: true): it => it + fakepar                            // 公式后缩进
    show heading: it => it + fakepar   // 标题后缩进
    show figure: it => it + fakepar    // 图表后缩进
    show enum.item: it => it + fakepar
    show list.item: it => it + fakepar // 列表后缩进

    // 调用封面
    cover(
      title: title,
      author: author,
      abstract: abstract,
      createtime: createtime,
      lang: lang
    )

    // 调用序（如果提供）
    if preface != none {
        preface-content(content: preface, lang: lang)
    }
    
    // 设置表格样式
    set table(
      fill: (_, row) => {
        if row == 0 {
          rgb("#2c3338").lighten(10%) // 表头深色背景
        } else if calc.odd(row) {
          rgb("#ffffff")              // 奇数行为白色
        } else {
          rgb("#000000").lighten(85%) // 偶数行为浅灰色
        }
      },
      stroke: 0.1pt + rgb("#000000"),
    )

    // 设置表头字体为浅色且加粗
    show table.cell.where(y: 0): it => {
      set text(fill: white)
      strong(it)
    }

    // 设置引用块样式
    set quote(block: true)

    // 设置内联代码样式
    show raw.where(block: false): it => box(fill: rgb("#d7d7d7"), inset: (x: 2pt), outset: (y: 3pt), radius: 1pt)[#it]

    // 设置链接下划线样式
    show link: {
      underline.with(stroke: rgb("#0074d9"), offset: 2pt)
    }

    // codly 支持代码显示
    show: codly-init                  //初始化 codly
    codly(languages: codly-languages) //设置语言图标

    // 设置公式编号样式
    set math.equation(
      numbering: (..nums) => (
        context {
          set text(size: 9pt)
          numbering("(1.1)", chaptercounter.at(here()).first(), ..nums)
        }
      ),
    )

    // 设置图表编号样式
    set figure(
      numbering: (..nums) => (
        context {
          set text(font: ("Libertinus Serif", "KaiTi"), size: 9pt)
          numbering("1.1", chaptercounter.at(here()).first(), ..nums)
        }
      ),
    )

    // 设置图片表格 caption 字体字号
    show figure.caption: set text(font: ("Libertinus Serif", "KaiTi"), size: 9pt)

    // 设置正文字体字号
    set text(
      font: ("Libertinus Serif", "KaiTi"),
    )

    pagebreak()

    counter(page).update(0)

    outline()

    pagebreak()

    // 普通文档页面布局
    set page(
      ..ordinary-layouts.page-settings,
      header: ordinary-layouts.header,
      footer: ordinary-layouts.footer
    )

    // 康纳尔笔记页面布局
    cornell-layouts(body)
  }

  // 添加参考文献（如果提供）
  if bibliography-file != none {
    bibliography-content(bibliography-style, bibliography-file)
  }
}