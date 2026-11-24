// 日常只需修改这个文件。所有可用配置与默认值见包导出的 defaults 和 README。
#let config = (
  // 仅切换颜色：teal 青绿（原版）/ indigo 靛蓝 / sepia 暖赭棕。
  theme: "sepia",
  title: "数学笔记",
  subtitle: "Mathematical Notes",
  author: "你的名字",
  institution: "",
  date: "2026 · 秋",
  edition: "VOL. 01",
  description: [在定义中建立语言，在证明中理解结构。],

  // zh：中文环境名；en：英文；bilingual：中英并列。
  lang: "bilingual",
  cover: true,
  toc: true,
  toc-depth: 2,
  chapter-break: true,

  // 开源字体；中文字体的安装方式见 README。各用途可分别替换。
  font-latin: "Libertinus Serif",
  font-cjk: "Noto Serif SC",
  font-heading: "Noto Sans SC",
  font-math: "New Computer Modern Math",
  font-code: "DejaVu Sans Mono",
  font-size: 10.5pt,
  leading: 0.8em,

  // 章首题辞：引文区宽度、字号、整体位置（left / center / right）。
  epigraph-width: 72%,
  epigraph-size: 9.5pt,
  epigraph-align: right,
  // auto：单行短题辞右对齐，需换行的题辞左对齐；也可强制 left / right。
  epigraph-text-align: auto,
  chapter-after: 4mm,
  epigraph-after: 8mm,
  math-scale: 98%,
  equation-spacing: 0.95em,
  // 数学环境、证明、札记的标题与正文之间额外增加的留白。
  environment-title-gap: 3pt,

  // 代码块与行内代码：原生支持的语言共享此样式。
  code-size: 9pt,
  code-leading: 0.55em,
  code-header: true,
  code-line-numbers: false,
  code-tab-size: 4,
  code-theme: auto, // auto 使用项目配色；none 关闭语法高亮

  // 数字引用默认 [1]；可改为 "apa" 或 "gb-7714-2015-numeric"。
  bibliography-style: "ieee",
  bibliography-title: auto,
  bibliography-new-page: true,
  bibliography-size: 9.5pt,
  bibliography-spacing: 1.1em,
  link-color: auto, // auto 跟随 accent
  link-underline: true, // 仅给外部链接加细下划线
  citation-color: auto,

  // 可选：取消注释以覆盖当前主题中的单个颜色。
  // accent: rgb("22645E"),
  // tint: rgb("F1F6F4"),
  // rule: rgb("D5E1DD"),
  // cover-paper: rgb("F6F5F0"),
  // epigraph-color: rgb("505D60"),
  // code-fill: rgb("F4F6F5"),
)
