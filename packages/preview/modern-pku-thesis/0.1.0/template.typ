// template.typ - PKU Thesis 模板入口
// 这是一个 facade，将所有模块功能组合并导出给用户

// ========== 命令行参数支持 ==========
// 通过 typst compile --input key=value 传递参数
// 支持的参数：
//   blind=true|false          - 盲审模式
//   preview=true|false        - 预览模式（链接显示蓝色）
//   alwaysstartodd=true|false - 章节是否总是从奇数页开始
//
// 示例：
//   typst compile thesis.typ --input blind=true
//   typst compile thesis.typ --input preview=false
//   typst compile thesis.typ --input alwaysstartodd=false

#let _parse-bool(value, default) = {
  if value == none { default } else if value == "true" or value == "1" {
    true
  } else if value == "false" or value == "0" { false } else { default }
}

#let _cli-blind = _parse-bool(sys.inputs.at("blind", default: none), none)
#let _cli-preview = _parse-bool(sys.inputs.at("preview", default: none), none)
#let _cli-alwaysstartodd = _parse-bool(
  sys.inputs.at("alwaysstartodd", default: none),
  none,
)

#import "@preview/itemize:0.2.0" as itemize
#import "@preview/cuti:0.4.0": show-cn-fakebold
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *

// 导入并重导出所有公共符号
#import "lib/config.typ": appendix, 字体, 字号
#import "lib/utils.typ": chinesenumbering
#import "lib/components.typ": booktab, chineseoutline, codeblock, listoffigures

// 高级用户 API：导出内部计数器和状态，用于自定义章节编号等场景
// 注意：这些是内部实现细节，未来版本可能会有变化
#import "lib/config.typ": (
  appendixcounter, chaptercounter, partcounter, skippedstate,
)

// 内部使用的模块
#import "lib/pages.typ"
#import "lib/styles.typ"

// 主配置函数
#let conf(
  cauthor: "张三",
  eauthor: "San Zhang",
  studentid: "23000xxxxx",
  blindid: "L2023XXXXX",
  cthesisname: "博士研究生学位论文",
  cheader: "北京大学博士学位论文",
  ctitle: "北京大学学位论文 Typst 模板",
  etitle: "Typst Template for Peking University Dissertations",
  school: "某个学院",
  cfirstmajor: "某个一级学科",
  cmajor: "某个专业",
  emajor: "Some Major",
  direction: "某个研究方向",
  csupervisor: "李四",
  esupervisor: "Si Li",
  date: (year: 2026, month: 6),
  // 学位类型："academic"（学术学位）或 "professional"（专业学位）
  degree-type: "academic",
  cabstract: [],
  ckeywords: (),
  eabstract: [],
  ekeywords: (),
  acknowledgements: [],
  // Word 模板中中文正文的首行缩进固定为 1.77em
  // 如果要求严格对应，请将 first-line-indent 设置为 1.77em
  // 这里设置为 2em 是为了更加美观
  first-line-indent: 2em,
  outlinedepth: 3,
  blind: false,
  listofimage: true,
  listoftable: true,
  listofcode: true,
  alwaysstartodd: true,
  // 是否清除原创性声明页的页眉和页码
  // 如果想要去除原创性声明页的页眉和页码，可以设置为 true
  // Word 模板中包含原创性声明页的页眉和页码，所以这里默认为 false
  cleandeclaration: false,
  // 预览模式下会将链接文本显示为蓝色
  // 在生成打印版时，可以设置为 false
  // 可通过命令行 --input preview=false 覆盖
  preview: true,
  // 代码块的额外参数
  codly-args: (:),
  doc,
) = {
  // 命令行参数覆盖配置文件中的值
  let blind = if _cli-blind != none { _cli-blind } else { blind }
  let preview = if _cli-preview != none { _cli-preview } else { preview }
  let alwaysstartodd = if _cli-alwaysstartodd != none {
    _cli-alwaysstartodd
  } else { alwaysstartodd }
  // 智能分页函数
  let smartpagebreak = () => {
    if alwaysstartodd {
      skippedstate.update(false)
      pagebreak(weak: true)
      skippedstate.update(true)
      pagebreak(to: "odd", weak: true)
      skippedstate.update(false)
    } else {
      pagebreak(weak: true)
    }
  }

  // ========== 页面设置 ==========
  set page(
    "a4",
    margin: (top: 3cm, bottom: 2.5cm, left: 2.6cm, right: 2.6cm),
    header: styles.make-header(cheader: cheader),
    footer: styles.make-footer(),
  )

  // ========== 全局样式 ==========
  set text(字号.小四, font: 字体.宋体, lang: "zh")
  set align(center + horizon)
  set heading(numbering: chinesenumbering)
  set figure(
    numbering: (..nums) => context {
      if appendixcounter.at(here()).first() < 10 {
        numbering("1.1", chaptercounter.at(here()).first(), ..nums)
      } else {
        numbering("A.1", chaptercounter.at(here()).first(), ..nums)
      }
    },
  )
  set math.equation(
    numbering: (..nums) => context {
      set text(font: 字体.宋体)
      if appendixcounter.at(here()).first() < 10 {
        numbering("(1.1)", chaptercounter.at(here()).first(), ..nums)
      } else {
        numbering("(A.1)", chaptercounter.at(here()).first(), ..nums)
      }
    },
  )
  set list(indent: 2em)
  set enum(indent: 2em)
  set footnote(numbering: "①")
  show footnote.entry: it => {
    let loc = it.note.location()
    numbering(it.note.numbering, ..counter(footnote).at(loc))
    h(0.5em)
    it.note.body
  }

  show: itemize.default-enum-list
  show strong: it => text(font: 字体.黑体, weight: "bold", it.body)
  show emph: it => text(font: 字体.楷体, style: "italic", it.body)
  show raw: set text(font: 字体.代码, size: 字号.五号, top-edge: "ascender")
  show: codly-init.with()
  codly(languages: codly-languages, ..codly-args)
  show link: it => if type(it.dest) == str and preview {
    text(fill: blue)[#it]
  } else { it }

  // 应用 show 规则
  show heading: it => styles.heading-show-rule(it, smartpagebreak)
  show figure: styles.figure-show-rule
  show ref: styles.ref-show-rule
  show bibliography: it => styles.bibliography-show-rule(it)

  // ========== 封面页 ==========
  if blind {
    pages.cover-page-blind(
      cheader: cheader,
      ctitle: ctitle,
      etitle: etitle,
      cfirstmajor: cfirstmajor,
      cmajor: cmajor,
      blindid: blindid,
      date: date,
      degree-type: degree-type,
    )
  } else {
    pages.cover-page-normal(
      cthesisname: cthesisname,
      ctitle: ctitle,
      cauthor: cauthor,
      studentid: studentid,
      school: school,
      cmajor: cmajor,
      direction: direction,
      csupervisor: csupervisor,
      date: date,
      degree-type: degree-type,
    )
  }

  smartpagebreak()

  // ========== 版权声明页 ==========
  pages.copyright-page()

  smartpagebreak()

  // ========== 中文摘要 ==========
  set align(left + top)
  pages.abstract-page-zh(
    ckeywords: ckeywords,
    first-line-indent: first-line-indent,
  )[#cabstract]

  smartpagebreak()

  // ========== 英文摘要 ==========
  pages.abstract-page-en(
    etitle: etitle,
    eauthor: eauthor,
    emajor: emajor,
    esupervisor: esupervisor,
    ekeywords: ekeywords,
    blind: blind,
  )[#eabstract]

  // ========== 目录和列表 ==========
  chineseoutline(
    title: "目录",
    depth: outlinedepth,
    indent: true,
  )

  if listofimage {
    listoffigures()
  }

  if listoftable {
    listoffigures(title: "表格", kind: table)
  }

  if listofcode {
    listoffigures(title: "代码", kind: "code")
  }

  // ========== 正文 ==========
  set align(left + top)
  set par(
    justify: true,
    first-line-indent: (amount: first-line-indent, all: true),
    leading: 10.5pt,
    spacing: 10.5pt,
  )
  doc

  smartpagebreak()

  // ========== 致谢和声明（非盲审） ==========
  if not blind {
    pages.acknowledgements-page(
      first-line-indent: first-line-indent,
    )[#acknowledgements]
    pages.declaration-page(cleandeclaration: cleandeclaration)
  }
}
