
#import "src/pipeline.typ": pipeline

// 衬线体
#let default-font-serif = (
  "Times New Roman",
  "Source Han Serif",
  "SimSun",
  "STSong",
)

// 无衬线体（黑体）
#let default-font-sans = (
  "Arial",
  "Source Han Sans",
  "Microsoft YaHei",
  "SimHei",
)

/// 西北大学学年论文 Typst 模板函数
///
/// - body (content): 论文正文内容。
/// - doc-show-cover (bool): 是否渲染封面页。默认为 `true`。
/// - doc-show-zh-abstract (bool): 是否渲染中文摘要页。默认为 `true`。
/// - doc-show-en-abstract (bool): 是否渲染英文摘要页。默认为 `true`。
/// - doc-show-outline (bool): 是否生成大目录。默认为 `false`。
///
/// - font-serif (string, array): 正文默认衬线字体。
/// - font-sans (string, array): 标题默认无衬线字体。
///
/// - font-title (dictionary): 封面大标题字体配置，包含 `font` 和 `size`。
/// - font-chapter (dictionary): 一级标题（章）字体配置。
/// - font-heading-1 (dictionary): 二级标题字体配置。
/// - font-heading-2 (dictionary): 三级标题字体配置。
/// - font-heading-3 (dictionary): 四级标题字体配置。
/// - font-body (dictionary): 正文文本字体配置。
///
/// - font-abstract-zh-title (dictionary): 中文摘要标题字体配置。
/// - font-abstract-zh-body (dictionary): 中文摘要正文字体配置。
/// - font-abstract-en-title (dictionary): 英文摘要标题字体配置。
/// - font-abstract-en-body (dictionary): 英文摘要正文字体配置。
///
/// - font-bibliography-title (dictionary): 参考文献标题字体配置（默认 14pt）。
/// - font-bibliography-body (dictionary): 参考文献正文字体配置（默认五号字 10.5pt）。
///
/// - meta-lang (string): 文档主语言，默认 `"zh"`。
/// - meta-title (content): 论文题目。
/// - meta-stu-name (content): 学生姓名。
/// - meta-stu-number (content, string): 学号。
/// - meta-tch-name (content): 指导老师姓名及职称。
/// - meta-department (content): 学院名称。
/// - meta-major (content): 专业名称。
/// - meta-grade (content, string): 年级。
/// - meta-zh-keywords (array): 中文关键词列表，如 `([关键词1], [关键词2])`。
/// - meta-en-keywords (array): 英文关键词列表，如 `([Keyword 1], [Keyword 2])`。
/// - meta-bib-path (none, string): 参考文献 `.bib` 文件路径。
/// - meta-zh-abstract (none, content): 中文摘要内容。
/// - meta-en-abstract (none, content): 英文摘要内容。
#let template(
  body,
  // === 结构与组件开关 ===
  doc-show-cover: true, // 是否渲染封面
  doc-show-zh-abstract: true, // 是否渲染中文摘要页
  doc-show-en-abstract: true, // 是否渲染英文摘要页
  doc-show-outline: false, // 是否生成大目录
  // === 常用字体 ===
  font-serif: default-font-serif, // 衬线字体
  font-sans: default-font-sans, // 无衬线字体
  // === 文档元素字体 ===
  font-title: (font: default-font-sans, size: 22pt),
  font-chapter: (font: default-font-sans, size: 18pt),
  font-heading-1: (font: default-font-sans, size: 16pt),
  font-heading-2: (font: default-font-sans, size: 14pt),
  font-heading-3: (font: default-font-sans, size: 12pt),
  font-body: (font: default-font-serif, size: 12pt),
  // === 摘要字体 ===
  font-abstract-zh-title: (font: default-font-sans, size: 18pt, weight: "bold"),
  font-abstract-zh-body: (font: default-font-serif, size: 12pt),
  font-abstract-en-title: (
    font: default-font-sans,
    size: 18pt,
    weight: "bold",
  ),
  font-abstract-en-body: (
    font: default-font-serif,
    size: 12pt,
  ),
  // === 参考文献字体 ===
  font-bibliography-title: (font: default-font-sans, size: 14pt, weight: "bold"), // 对应旧模板的 14pt
  font-bibliography-body: (font: default-font-serif, size: 10.5pt), // 对应五号字
  // === 文档元数据 ===
  meta-lang: "zh",
  meta-title: [论文题目],
  meta-stu-name: [张三],
  meta-stu-number: [2026000001],
  meta-tch-name: [李四 教授],
  meta-department: [计算机科学与技术学院],
  meta-major: [软件工程],
  meta-grade: [2026级],
  meta-zh-keywords: ([关键词1], [关键词2]),
  meta-en-keywords: ([Keyword 1], [keyword 2]),
  meta-bib-path: none,
  meta-zh-abstract: none,
  meta-en-abstract: none,
) = {
  let cfg = (
    document: (
      cover: doc-show-cover,
      zh-abstract: doc-show-zh-abstract,
      en-abstract: doc-show-en-abstract,
      outline: doc-show-outline,
    ),
    meta: (
      lang: meta-lang,
      title: meta-title,
      stu-name: meta-stu-name,
      stu-number: meta-stu-number,
      tch-name: meta-tch-name,
      department: meta-department,
      major: meta-major,
      grade: meta-grade,
      zh-abstract-content: meta-zh-abstract,
      en-abstract-content: meta-en-abstract,
      zh-keywords: meta-zh-keywords,
      en-keywords: meta-en-keywords,
      bib-path: meta-bib-path,
    ),
    fonts: (
      serif: font-serif,
      sans: font-sans,
      body: font-body,
      title: font-title,
      heading-1: font-heading-1,
      heading-2: font-heading-2,
      heading-3: font-heading-3,
      abstract-zh-title: font-abstract-zh-title,
      abstract-en-title: font-abstract-en-title,
      abstract-zh-body: font-abstract-zh-body,
      abstract-en-body: font-abstract-en-body,
      bibliography-title: font-bibliography-title,
      bibliography-body: font-bibliography-body,
    ),
  )
  pipeline(
    body,
    cfg,
  )
}
