#import "/specifications/bachelor/cover.typ": cover
#import "/specifications/bachelor/titlepage.typ": titlepage
#import "/specifications/bachelor/declaration.typ": declaration
#import "/specifications/bachelor/abstract.typ": abstract, abstract-page
#import "/specifications/bachelor/abstract-en.typ": abstract-en, abstract-en-page
#import "/specifications/bachelor/appendix.typ": appendix, appendix-part
#import "/specifications/bachelor/acknowledgement.typ": acknowledgement, acknowledgement-page

#import "/utils/bilingual-bibliography.typ": bilingual-bibliography
#import "/utils/custom-heading.typ": active-heading, heading-display, current-heading
#import "/utils/style.typ": 字号, 字体, sysucolor

#import "@preview/numbly:0.1.0": numbly
#import "@preview/numblex:0.1.1": circle_numbers
#import "@preview/i-figured:0.2.4"

// 中山大学本科生毕业论文（设计）写作与印制规范
// 参考规范: https://spa.sysu.edu.cn/zh-hans/article/1744
#let doc(
  // 毕业论文基本信息
  thesis-info: (
    // 论文标题，将展示在封面、扉页与页眉上
    // 多行标题请使用数组传入 `("thesis title", "with part next line")`，或使用换行符：`"thesis title\nwith part next line"`
    title: ("中山大学本科生毕业论文（设计）", "写作与印制规范（2020-）"),
    title-en: ("The Specification of Writting and Printing", "for SYSU thesis"),

    // 论文作者信息：学号、姓名、院系、专业、指导老师
    author: (
      sno: "1xxxxxxx",
      name: "张三",
      grade: "2024",
      department: "某学院",
      major: "某专业",
    ),

    // 指导老师信息，以`("name", "title")` 数组方式传入
    supervisor: ("李四", "教授"),

    // 提交日期，默认为论文 PDF 生成日期
    submit-date: datetime.today(),
  ),

  // 参考文献来源
  bibliography: none,

  // 控制页面是否渲染
  pages: (
    // 封面可能由学院统一打印提供，因此可以不渲染
    cover: true,

    // 附录部分为可选。设置为 true 后，会在参考文献部分与致谢部分之间插入附录部分。
    appendix: false,
  ),

  // 论文内文各大部分的标题用“一、二…… （或1、2……）”， 次级标题为“（一）、（二）……（或
  // 1.1、2.1……）”，三级标题用“1、2……（或1.1.1、2.1.1……）”，四级标题用“（1）、（2）……
  //（或1.1.1.1、2.1.1.1……）”，不再使用五级以下标题。两类标题不要混编。
  numbering: none,

  // 双面模式，会加入空白页，便于打印
  twoside: false,

  // 论文正文信息，包括绪论、主体、结论
  content
) = {
  // 论文信息参数处理。要求必须传递，且符合规格的参数
  assert(type(thesis-info) == dictionary)
  assert(type(thesis-info.title) == array or type(thesis-info.title) == str)
  assert(type(thesis-info.title-en) == array
    or type(thesis-info.title-en) == str
  )
  // 论文信息默认参数。函数传入参数会完全覆盖参数值，因此需要提供默认参数补充。
  // 彩蛋：如果论文参数不传递作者参数，那么论文就会被署名论文模板作者
  let default-author = (
    sno: "13xxxx87",
    name: "Sunny Huang",
    grade: "2013",
    department: "数据科学与计算机学院",
    major: "软件工程",
  )
  thesis-info.author = thesis-info.at("author", default: default-author)

  let default-thesis-info = (
    title: ("中山大学本科生毕业论文（设计）", "写作与印制规范"),
    title-en: ("The Specification of Writting and Printing", "for SYSU thesis"),
    supervisor: ("李四", "教授"),
    submit-date: datetime.today(),
  )
  thesis-info = default-thesis-info + thesis-info

  // 论文渲染控制参数处理。设置可选页面的默认设置项
  let default-pages = (
    cover: true,
    appendix: false,
  )
  pages = default-pages + pages

  // 文档元数据处理
  if type(thesis-info.title) == str {
    thesis-info.title = thesis-info.title.split("\n")
  }
  if type(thesis-info.title-en) == str {
    thesis-info.title-en = thesis-info.title-en.split("\n")
  }

  set document(
    title: thesis-info.title.join(""),
    author: thesis-info.author.name,
    // keywords: thesis-info.abstract.keywords,
  )

  // 纸张大小：A4。页边距：上边距25 mm，下边距20 mm，左右边距均为30 mm。
  set page(paper: "a4", margin: (top: 25mm, bottom: 20mm, x: 30mm))

  // 行距：1.5倍行距
  // 行距理解为 word 默认行距（1em * 120%）的1.5倍，由于目前尚未实现 [line-height 模
  // 型]，故换算成行间距（leading）
  //
  // [line-height 模型]: https://github.com/typst/typst/issues/4224
  set par(leading: 1em * 120% * 1.5 - 1em)

  // 目录内容 宋体小四号
  // 正文内容 宋体小四号
  // 致谢、附录内容	宋体小四号
  set text(lang: "zh", font: 字体.宋体, size: 字号.小四)

  // 论文内文各大部分的标题用“一、二…… （或1、2……）”， 次级标题为“（一）、（二）……（或
  // 1.1、2.1……）”，三级标题用“1、2……（或1.1.1、2.1.1……）”，四级标题用“（1）、（2）……
  //（或1.1.1.1、2.1.1.1……）”，不再使用五级以下标题。两类标题不要混编。
  set heading(depth: 4, numbering: if numbering == "一" {
    numbly("{1:一}", "（{2:一}）", "{3}", "（{4}）")
  } else { "1.1.1.1 "})
  show heading: set text(weight: "regular")

  // 章和节标题段前段后各空0.5行
  // 行理解为当前行距，故在 "1.5倍行距" 的基准上再算一半，也即 "0.75倍行距"
  show heading.where(level: 1): set block(above: 1em * 120% * 0.75, below: 1em * 120% * 0.75)
  show heading.where(level: 2): set block(above: 1em * 120% * 0.75, below: 1em * 120% * 0.75)

  // 目录标题 黑体三号居中
  // 正文各章标题 黑体三号居中
  // 参考文献标题 黑体三号居中
  // 致谢、附录标题	黑体三号居中
  show heading.where(level: 1): set text(font: 字体.黑体, size: 字号.三号)
  show heading.where(level: 1): set align(center)

  // 正文各节一级标题 黑体四号左对齐
  show heading.where(level: 2): set text(font: 字体.黑体, size: 字号.四号)

  // 正文各节二级及以下标题 宋体小四号加粗左对齐空两格
  show heading.where(level: 3): set text(font: 字体.宋体, size: 字号.小四, weight: "bold")
  show heading.where(level: 4): set text(font: 字体.宋体, size: 字号.小四, weight: "bold")
  show heading.where(level: 3): it => pad(left: 2em, it)
  show heading.where(level: 4): it => pad(left: 2em, it)

  // 遇到一级标题重置图、表、公式编号计数
  show heading: i-figured.reset-counters
  show figure: i-figured.show-figure
  show math.equation: i-figured.show-equation

  // 图题、表题 宋体五号
  show figure.caption: set text(font: 字体.宋体, size: 字号.五号)

  // 标题放置在表格上方
  show figure.where(kind: table): set figure.caption(position: top)

  // 脚注、尾注 宋体小五号
  show footnote.entry: set text(font: 字体.宋体, size: 字号.小五)

  // 注释：毕业论文（设计）中有个别名词或情况需要解释时，可加注说明。注释采用脚注或尾注，
  // 应根据注释的先后顺序编排序号。注释序号以“①、②”等数字形式标示在正文中被注释词条的
  // 右上角，脚注或尾注内容中的序号应与被注释词条序号保持一致。
  show footnote: set footnote(numbering: circle_numbers)

  // 毕业论文应按以下顺序装订和存档：
  // 封面->扉页->学术诚信声明->摘要->目录->正文->参考文献（->附录）->致谢。
  if pages.cover {
    cover(info: thesis-info)
    pagebreak(weak: true, to: if twoside { "odd" })
  }

  titlepage(info: thesis-info)
  pagebreak(weak: true, to: if twoside { "odd" })

  declaration()
  pagebreak(weak: true, to: if twoside { "odd" })

  // 摘要开始至绪论之前以大写罗马数字（Ⅰ，Ⅱ，Ⅲ…）单独编连续码
  // 页眉与页脚 宋体五号居中
  set page(header: context {
      set text(font: 字体.宋体, size: 字号.五号, stroke: sysucolor.green)
      set align(center)
      let loc = here()
      let cur-heading = current-heading(level: 1, loc)
      let first-level-heading = heading-display(active-heading(level: 1, loc))

      if cur-heading != none {
        thesis-info.title.join("")
      } else if not twoside or calc.rem(loc.page(), 2) == 1 {
        first-level-heading
      } else {
        thesis-info.title.join("")
      }
      line(length: 200%, stroke: 0.1em + sysucolor.green);
  })
  set page(numbering: "I")
  counter(page).update(1)

  abstract-page()
  pagebreak(weak: true, to: if twoside { "odd" })
  abstract-en-page()
  pagebreak(weak: true, to: if twoside { "odd" })

  outline()
  pagebreak(weak: true, to: if twoside { "odd" })

  // 绪论开始至论文结尾，以阿拉伯数字（1，2，3…）编连续码
  set page(numbering: "1")
  counter(page).update(1)

  // 正文段落按照中文惯例缩进两格
  set par(first-line-indent: (amount: 2em, all: true))

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    it
  }

  content
  pagebreak(weak: true, to: if twoside { "odd" })

  // 参考文献
  {
    // 参考文献内容 宋体五号
    set text(font: 字体.宋体, size: 字号.五号)
    bilingual-bibliography(bibliography: bibliography, full: true)
  }
  pagebreak(weak: true, to: if twoside { "odd" })

  // 附录
  if pages.appendix {
    appendix-part()
    pagebreak(weak: true, to: if twoside { "odd" })
  }

  // 致谢
  acknowledgement-page()
  pagebreak(weak: true, to: if twoside { "odd" })
}

// 以下为校对用测试 preview 页面
#show: doc.with(
  bibliography: bibliography.with("/template/ref.bib"),
  pages: (
    appendix: true
  )
)


// 正文各部分的标题应简明扼要，不使用标点符号。
= 第某章 <chapter1>
== 节标题
=== 小节标题
==== 四级标题
写一下测试的内容 @chapter1-img，章节标题 @chapter1[("第一章")]

#figure(
  image("/template/images/sysu_logo.svg", width: 20%),
  caption: [图片测试],
) <chapter1-img>

// #show: appendix
= 第一章 <appendix>
== 节标题
=== 小节标题
==== 四级标题
在附录中引用图片 @appendix-img, 以及附录章节标题 @appendix[#numbering("附录A")]

#figure(
  image("/template/images/sysu_logo.svg", width: 20%),
  caption: [图片测试],
) <appendix-img>
