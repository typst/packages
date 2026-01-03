// lib/config.typ - 常量与状态定义
// 字号、字体、计数器、状态、辅助函数等基础配置

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
  小四: 12pt,
  五号: 10.5pt,
  小五: 9pt,
  六号: 7.5pt,
  小六: 6.5pt,
  七号: 5.5pt,
  小七: 5pt,
  // 下面是 Word 模板中不同组件的默认字号
  一级标题: 16pt,
  二级标题: 14pt,
  三级标题: 13pt,
  图题: 11pt,
  表题: 11pt,
  表文: 10.5pt,
  正文: 12pt,
  脚注: 9pt,
)

#let 字体 = (
  仿宋: ("Times New Roman", "FangSong", "STFangsong"),
  宋体: ("Times New Roman", "SimSun", "STSong"),
  黑体: ("Times New Roman", "SimHei", "STHeiti"),
  楷体: ("Times New Roman", "KaiTi_GB2312", "STKaiti"),
  代码: ("New Computer Modern Mono", "Times New Roman", "SimSun"),
)

// 计数器定义
// partcounter 状态:
//   0 = 封面区域（无页眉页脚）
//   1 = 前置部分（罗马数字页码，有页眉）
//   2 = 正文部分（阿拉伯数字页码，有页眉）
#let partcounter = counter("part")
#let chaptercounter = counter("chapter")
#let appendixcounter = counter("appendix")
#let footnotecounter = counter(footnote)
#let rawcounter = counter(figure.where(kind: "code"))
#let imagecounter = counter(figure.where(kind: image))
#let tablecounter = counter(figure.where(kind: table))
#let equationcounter = counter(math.equation)

// 状态
#let skippedstate = state("skipped", false)

// 附录切换函数
#let appendix() = {
  appendixcounter.update(10)
  chaptercounter.update(0)
  counter(heading).update(0)
}

// ========== Heading 元数据辅助函数 ==========
// 使用 supplement 字段传递元数据，避免硬编码字符串匹配
//
// 元数据字段定义：
//   pagebreak: bool       - 是否在此 heading 前分页（默认 true）
//   part: int | none      - 状态转换目标 (0/1/2/none)
//   reset-page: bool      - 是否重置页码为 1（默认 false）
//   show-header: bool     - 是否显示页眉（默认 true）
//   header: content | none - 自定义页眉文本

/// 创建前置部分的 heading（摘要、目录等）
/// - title: 标题文本
/// - pagebreak: 是否分页（默认 true）
/// - enter-front: 是否进入前置部分并重置页码（默认 false）
/// - extra-meta: 额外的元数据参数（如 header、spacing-before 等）
#let front-heading(
  title,
  pagebreak: true,
  enter-front: false,
  ..extra-meta,
) = {
  heading(
    numbering: none,
    outlined: false,
    supplement: [#metadata((
      pagebreak: pagebreak,
      part: if enter-front { 1 } else { none },
      reset-page: enter-front,
      show-header: true,
      ..extra-meta.named(),
    ))],
  )[#title]
}

/// 创建后置部分的 heading（致谢、声明等）
/// - title: 标题文本
/// - pagebreak: 是否分页（默认 true）
/// - show-header: 是否显示页眉（默认 true）
#let back-heading(
  title,
  pagebreak: true,
  show-header: true,
  ..extra-meta,
) = {
  heading(
    numbering: none,
    outlined: true,
    supplement: [#metadata((
      pagebreak: pagebreak,
      show-header: show-header,
      ..extra-meta.named(),
    ))],
  )[#title]
}
