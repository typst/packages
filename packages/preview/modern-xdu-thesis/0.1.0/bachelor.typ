// 西安电子科技大学本科毕业设计（论文）Typst 模板 — 独立包入口
//
// 用法：#import "@preview/modern-xdu-thesis:0.1.0": bachelor
//      #let (...) = bachelor.documentclass(...)
// 本文件是本科实现入口；lib.typ 只导出 bachelor 模块命名空间，不复用硕士页面或版式代码。

#import "bachelor/layout.typ": doc
#import "bachelor/pages.typ": cover, abstract, abstract-en, outline-page, acknowledgement, references, appendix
#import "bachelor/mainmatter.typ": mainmatter, 引用
#import "utils/bilingual-bib.typ": 双语文献

#let documentclass(
  cover-enabled: true,
  fonts: (:),
  info: (:),
) = {
  assert(type(cover-enabled) == bool, message: "cover-enabled 必须是布尔值")
  let 默认info = (
    title: ("基于 Typst 的西安电子科技大学", "本科毕业设计论文模板"),
    author: "张三",
    department: "电子工程学院",
    major: "电子信息工程",
    supervisor: ("李四", "王五"),
    class-id: "2101011",
    student-id: "21010100001",
    abstract: [请在此填写不少于 300 字的中文摘要。],
    abstract-en: [Please replace this text with an English abstract of at least 300 words.],
    keywords: ("关键词一", "关键词二", "关键词三"),
    keywords-en: ("keyword one", "keyword two", "keyword three"),
    acknowledgement: [请在此撰写致谢。],
    appendix: [请在此撰写附录内容。],
    references: (),
  )
  let 合并info = 默认info + info
  (
    info: 合并info,
    fonts: fonts,
    doc: (..args) => doc(info: 合并info, fonts: fonts, ..args),
    cover: (enabled: none, ..args) => cover(
      info: 合并info, fonts: fonts,
      enabled: if enabled == none { cover-enabled } else { enabled },
      ..args,
    ),
    abstract: (..args) => abstract(info: 合并info, fonts: fonts, ..args),
    abstract-en: (..args) => abstract-en(info: 合并info, fonts: fonts, ..args),
    outline-page: (..args) => outline-page(info: 合并info, fonts: fonts, ..args),
    mainmatter: (..args) => mainmatter(info: 合并info, fonts: fonts, ..args),
    appendix: (..args) => appendix(info: 合并info, fonts: fonts, ..args),
    references: (..args) => references(info: 合并info, fonts: fonts, ..args),
    acknowledgement: (..args) => acknowledgement(info: 合并info, fonts: fonts, ..args),
    引用: 引用,
    双语文献: 双语文献,
  )
}

#let bachelor-documentclass = documentclass
