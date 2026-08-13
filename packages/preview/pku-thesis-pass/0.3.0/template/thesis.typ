// ============================================================
// 北京大学学位论文 Typst 模板使用指南
// 渲染文档：typst compile thesis.typ --root .
//
// 命令行参数（--input key=value）：
//   --input blind=true|false               盲审模式
//   --input preview=true|false             预览模式（默认 true，链接显示蓝色）
//   --input always-start-odd=true|false    章节是否总是从奇数页开始
//   --input system=windows|macos|linux     系统字体方案
// ============================================================

#import "@preview/pku-thesis-pass:0.3.0": config

#let cfg = config(
  // ========== 基本信息 ==========
  author-zh: "张三",
  author-en: "San Zhang",
  student-id: "23000xxxxx",
  blind-id: "L2023XXXXX",
  thesis-name: "博士研究生学位论文",
  header-text: "北京大学博士学位论文",
  title-zh: "北京大学学位论文 \nTypst 模板使用指南",
  title-en: "A Guide to Using the Typst Template for \nPeking University Theses",
  school: "信息科学技术学院",
  first-major: "计算机科学与技术",
  major-zh: "计算机软件与理论",
  major-en: "Computer Software and Theory",
  direction: "程序设计语言与编译技术",
  supervisor-zh: "李四 教授",
  supervisor-en: "Prof. Si Li",
  degree-type: "academic",
  year: 2026,
  month: 6,

  // ========== 排版配置 ==========
  system: "windows",
  blind: false,
  preview: true,
  first-line-indent: 2em,
  always-start-odd: false,
  clean-declaration: true,
  outline-depth: 3,
  word-count: true,
  achievement-outlined: true,
  supplements: (成果表: "攻读学位期间发表的论文"),
  use-latexref: true,
  latexref-prefixes: ("fig:", "tbl:", "eqt:"),
  codly-args: (:),
  logo: path("assets/pkulogo.pdf"),
  wordmark: path("assets/pkuword.pdf"),

  // ========== 参考文献 ==========
  override-bib: false,
  bib-file: path("ref.bib"),
  bib-style: "numeric",
  bib-version: "2015",
  bib-cn-first: true,
  bib-pinyin-override: (:),
)

// ========== 页面设置 ==========
#show: cfg.setup

// ========== 论文封面 ==========
#(cfg.cover)()

// ========== 论文书脊 ==========
// #(cfg.spine)()

// ========== 版权声明 ==========
#(cfg.copyright)()

// ========== 中文摘要 ==========
#(cfg.abstract-zh)(
  keywords-zh: ("Typst", "模板", "学位论文", "北京大学")
)[#include "content/abstract-zh.typ"]

// ========== 英文摘要 ==========
#(cfg.abstract-en)(
  keywords-en: ("Typst", "Template", "Thesis", "Peking University")
)[#include "content/abstract-en.typ"]

// ========== 论文目录 ==========
#(cfg.outline)()

// ========== 插图列表 ==========
#(cfg.list-of-figures)()

// ========== 表格列表 ==========
#(cfg.list-of-tables)()

// ========== 公式列表 ==========
#(cfg.list-of-equations)()

// ========== 代码列表 ==========
#(cfg.list-of-code)()

// ========== 主要符号对照表 ==========
#(cfg.notation)[#include "content/notation.typ"]

// ========== 正文部分 ==========
#show: cfg.body-wrap
#show: cfg.bibliography

= 快速开始 <quickstart>

#include "content/ch01-quickstart.typ"

= 模板配置 <config>

#include "content/ch02-config.typ"

= Typst 基本功能 <basics>

#include "content/ch03-basics.typ"

= 进阶使用技巧 <advanced>

#include "content/ch04-advanced.typ"

= 常见问题与解决方案 <faq>

#include "content/ch05-faq.typ"

// ========== 附录部分 ==========
#(cfg.appendix)()

= 关于 Typst <about>

#include "content/appendix-about.typ"

// ========== 攻读学位期间发表的论文 ==========
#(cfg.achievement)[#include "content/achievement.typ"]

// ========== 致谢部分 ==========
#(cfg.acknowledgements)[#include "content/acknowledgements.typ"]

// ========== 原创声明 ==========
#(cfg.declaration)()
