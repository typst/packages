// ============================================================
// 北京大学学位论文模板
// 渲染文档：typst compile thesis.typ --font-path fonts
//
// 命令行参数（--input key=value）：
//   --input blind=true|false                    盲审模式
//   --input preview=true|false                  预览模式（默认 true，链接显示蓝色，打印时请设置为 false）
//   --input always-start-odd=true|false         章节是否总是从奇数页开始
//   --input system=default|mac|windows|linux    系统字体方案
// ============================================================

#import "@preview/pku-thesis-pass:0.1.0": config
// 本地测试时，注释上一行并取消注释下一行：
// #import "../format/config.typ": config

#let (
  setup,
  cover,
  copyright,
  abstract-zh,
  abstract-en,
  outline,
  list-of-figures,
  list-of-tables,
  list-of-code,
  body-wrap,
  bibliography,
  acknowledgements,
  declaration,
  appendix,
  font,
  blind,
) = config(
  // ========== 基本信息 ==========
  author-zh: "张三",
  author-en: "San Zhang",
  student-id: "23000xxxxx",
  blind-id: "L2023XXXXX",
  thesis-name: "博士研究生学位论文",
  header-text: "北京大学博士学位论文",
  title-zh: "论文中文题目",
  title-en: "English Title of the Thesis",
  school: "信息科学技术学院",
  first-major: "计算机科学与技术",
  major-zh: "计算机软件与理论",
  major-en: "Computer Software and Theory",
  direction: "研究方向",
  supervisor-zh: "李四 教授",
  supervisor-en: "Prof. Si Li",
  degree-type: "academic",
  year: 2026,
  month: 6,

  // ========== 样式参数 ==========
  system: "default",
  blind: false,
  preview: true,
  first-line-indent: 2em,
  always-start-odd: false,
  clean-declaration: true,
  outline-depth: 3,
  supplements: (:),
  codly-args: (:),

  // ========== 参考文献 ==========
  bib-file: "ref.bib",
  bib-style: "numeric",
  bib-version: "2025",
)

// ========== 页面设置 ==========
#show: setup

// ========== 论文封面 ==========
#cover()

// ========== 版权声明 ==========
#copyright()

// ========== 中文摘要 ==========
#abstract-zh(keywords-zh: ("关键词1", "关键词2"))[
  #include "content/abstract-zh.typ"
]

// ========== 英文摘要 ==========
#abstract-en(keywords-en: ("Keyword 1", "Keyword 2"))[
  #include "content/abstract-en.typ"
]

// ========== 论文目录 ==========
#outline()

// ========== 图片列表 ==========
#list-of-figures()

// ========== 表格列表 ==========
#list-of-tables()

// ========== 代码列表 ==========
#list-of-code()  // 如不需要注释掉即可

// ========== 正文部分 ==========
#show: body-wrap
#show: bibliography

= 引言 <intro>

#include "content/ch01-intro.typ"

= 文献综述 <litrev>

#include "content/ch02-litrev.typ"

= 研究方法

在此处撰写研究方法...

= 实验与结果

在此处撰写实验和结果...

= 总结与展望

在此处撰写总结和展望...

// ========== 附录 ==========
#appendix()

= 实验数据

在此处添加实验数据...

// ========== 致谢、原创声明和使用授权 ==========
#if not blind {
  acknowledgements[#include "content/acknowledgements.typ"]
  declaration()
}
