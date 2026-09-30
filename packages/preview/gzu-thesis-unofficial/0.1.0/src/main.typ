#import "@preview/numbly:0.1.0": numbly
#import "@preview/pointless-size:0.1.2": zh

#import "fonts.typ"
#import "styles.typ"
#import "pages/abstract.typ": abstract
#import "pages/integrity-statement.typ": integrity-statement
#import "pages/cover.typ": cover


// 这个函数仅仅用于为 PDF 元数据的 `author` 提供字符串
// 对非 content 和 str 类型将返回空字符串。
#let _to-string(it) = {
  if type(it) == str {
    it
  } else if type(it) != content {
    ""
  } else if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(_to-string).join()
  } else if it.has("body") {
    _to-string(it.body)
  } else {
    ""
  }
}

/// 模板入口函数。
/// -> content
#let gzu-thesis(
  /// 论文题目（中文）
  /// -> str | content
  title-zh: [],
  /// 论文题目（英文）
  /// -> str | content
  title-en: [],
  /// 封面和签名日期。省略时默认为当前日期。
  /// -> content | none
  date: datetime.today(),
  /// 论文作者
  ///
  /// 通常情况传入字符串即可，如若希望在封面页姓名中加入空白，可使用简单的 content，如
  /// `[姓#h(1em)名]` 可在姓名中插入一个字符宽度的空白。
  /// -> str | content
  author: [],
  /// 学院名称。同 @gzu-thesis.author
  /// -> str | content
  college: [],
  /// 专业名称。同 @gzu-thesis.author
  /// -> str | content
  major: [],
  /// 班级。同 @gzu-thesis.author
  /// -> str | content
  class: [],
  /// 学号。同 @gzu-thesis.author
  /// -> str | content
  id: [],
  /// 指导教师。同 @gzu-thesis.author
  /// -> str | content
  teacher: [],
  /// 用于「诚信责任书」的手写签名，通常使用图片，如 `image("签名图片.png")`。
  /// 理论上可以是任意 `content`。 如果为 `none`，则留白处理。
  /// -> content | none
  sign: none,
  /// 中文摘要和关键词。
  /// 接受一个字典，包含如下的键：
  /// - abstract: 摘要正文
  /// - keywords: 关键词数组，每个元素必须是字符串
  /// -> dictionary
  abstract-zh: (abstract: [], keywords: ()),
  /// 英文摘要和关键词，同 @gzu-thesis.abstract-zh
  /// -> dictionary
  abstract-en: (abstract: [], keywords: ()),
  /// 参考文献，必须是调用 `bibliography` 函数的返回值
  /// -> content | none
  bibliography: none,
  /// 致谢正文
  /// -> content | none
  acknowledgment: none,
  /// 附录正文
  /// -> content | none
  appendix: none,
  /// 正文内容
  /// -> content
  body,
) = {
  // 设置 PDF 元数据
  set document(
    title: title-zh,
    author: _to-string(author),
    keywords: abstract-zh.keywords,
  )

  // 基本版式设计
  set page("a4", footer: none, margin: (top: 30mm, bottom: 25mm, left: 30mm, right: 20mm))
  set text(
    font: fonts.serif,
    size: zh(-4),
    lang: "zh",
    region: "cn",
    top-edge: "bounds",
    bottom-edge: "bounds",
  )
  set par(
    justify: true,
    leading: 1.05em, // 模拟 Word 中的 1.5 倍行距
    spacing: 1.05em, // 行数：29 行，行长：37 字
    first-line-indent: (amount: 2em, all: true),
  )

  // 设置样式
  show: styles.heading
  show: styles.footnote
  // 由于需要在一级标题后重置图、表、公式的编号，不能在 styles.heading 前应用这些样式。
  show: styles.figure
  show: styles.table
  show: styles.math

  // === 文档开始 ===
  cover(author, college, major, class, id, teacher, date)
  integrity-statement(sign, date)

  counter(page).update(1) // 目录、摘要页码使用罗马数字
  set page(
    numbering: "I",
    header: context [
      #set text(zh(5))
      #v(1fr)
      #place(dx: 25%, dy: -25%, image("../assets/gzu_logo.png", height: 1.22cm))
      #place(center)[贵州大学毕业论文（设计）]
      #h(1fr)
      第#counter(page).display()页
      #v(3pt)
      #line(length: 100%, stroke: 0.08em + text.fill)
    ],
  )
  outline(depth: 3, title: "目录")
  pagebreak(weak: true)
  abstract(abstract-zh, abstract-en, title-en)

  // 从正文开始一级标题自动分页
  show heading: it => if it.level == 1 { pagebreak(weak: true) } + it
  counter(page).update(1) // 正文页码使用阿拉伯数字重新编号
  set page(numbering: "1")

  body

  if bibliography != none {
    heading(numbering: none)[参考文献]
    set text(font: fonts.serif, size: zh(5))
    // 模拟 Word 中的单倍行距
    set par(leading: 0.37em, spacing: 0.37em)
    set std.bibliography(style: "gb-7714-2015-numeric", title: none)
    bibliography
  }
  if acknowledgment != none {
    heading(numbering: none)[致谢]
    acknowledgment
  }
  if appendix != none {
    heading(numbering: none)[附录]
    appendix
  }
}
