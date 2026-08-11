// 字体常量
#let sans-fonts = (
  "PingFang SC",
  "Noto Sans CJK SC",
  "Noto Sans SC",
  "Source Han Sans SC",
  "Heiti SC",
  "SimHei",
)

#let serif-fonts = (
  "Noto Serif CJK SC",
  "Noto Serif SC",
  "Source Han Serif SC",
  "Songti SC",
  "SimSun",
)

#let code-fonts = (
  "Maple Mono",
  "Fira Code",
  "Cascadia Code",
  "JetBrains Mono",
  "Monaco",
  "Consolas",
)

// 颜色常量
#let colors = (
  bg: rgb("#fffef5"),        // 背景色：白偏黄
  text: rgb("#333333"),      // 字色：深灰
  highlight: rgb("#fff6c6"), // 高亮色：浅黄
  accent: rgb("#ff6b6b"),    // 强调色：小红书红
  footer-bg: rgb("#000000").transparentize(60%), // 页脚背景
  white: rgb("#ffffff"),
  code-bg: rgb("#2d2d2d"),   // 代码块背景色：深灰
  code-text: rgb("#f8f8f2"), // 代码块文字色：浅灰
)

// 页面尺寸常量（小红书 3:5 比例）
#let page-size = (
  width: 1080pt,
  height: 1800pt,
)

// 间距常量
#let spacing = (
  margin-x: 80pt,
  margin-y: 120pt,
  title-gap: 40pt,
  para-gap: 20pt,
  h1-gap: 40pt,        // 一级标题上间距
  h2-gap: 30pt,        // 二级标题上间距
  h3-gap: 20pt,        // 三级标题上间距
  h4-gap: 16pt,        // 四级标题上间距
  h3-after: 16pt,      // 三级标题下间距
  h4-after: 12pt,      // 四级标题下间距
  decor-gap: 16pt,     // 装饰条与文字间距
  decor-gap-sm: 12pt,  // 装饰条与文字间距（小）
  cover-title-gap: 16pt,  // 封面标题间距
  cover-subtitle-gap: 24pt, // 封面副标题间距
)

// 字号常量
#let font-sizes = (
  body: 42pt,
  title: 60pt,
  footer: 30pt,
  h2: 48pt,           // 二级标题字号
  h3: 42pt,           // 三级标题字号（同 body）
  h4: 38pt,           // 四级标题字号
  code: 32pt,         // 代码块字号
  cover-title: 72pt,  // 封面标题字号
  cover-subtitle: 36pt, // 封面副标题字号
  cover-author: 32pt, // 封面作者字号
)

// 装饰元素常量
#let decorations = (
  h1-bar-width: 12pt,    // 一级标题装饰条宽度
  h1-bar-height: 1.2em,  // 一级标题装饰条高度
  h1-bar-radius: 4pt,    // 一级标题装饰条圆角
  h1-underline-offset: 20pt, // 一级标题下划线偏移
  h1-underline-stroke: 3pt,   // 一级标题下划线粗细
  h2-bar-width: 6pt,     // 二级标题装饰条宽度
  h2-bar-height: 1.1em,  // 二级标题装饰条高度
  h2-bar-radius: 3pt,    // 二级标题装饰条圆角
  h3-radius: 8pt,        // 三级标题圆角
  h3-inset-x: 16pt,      // 三级标题内边距 x
  h3-inset-y: 8pt,       // 三级标题内边距 y
  code-inline-radius: 4pt, // 行内代码圆角
  code-inline-inset-x: 8pt, // 行内代码内边距 x
  code-inline-inset-y: 4pt, // 行内代码内边距 y
  code-inline-outset-y: 4pt, // 行内代码外边距 y
  code-block-radius: 12pt,  // 代码块圆角
  code-block-inset: 24pt,   // 代码块内边距
  cover-image-radius: 24pt, // 封面图片圆角
  cover-author-radius: 50pt, // 封面作者标签圆角
  cover-author-inset-x: 24pt, // 封面作者标签内边距 x
  cover-author-inset-y: 12pt, // 封面作者标签内边距 y
)

