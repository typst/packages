
/* 版面属性（初始16开） */
#let page-all = (
  width: 185mm, // 页面宽度
  height: 260mm, // 页面高度
  mar-t: 23mm, // 上页边距
  mar-b: 17mm, // 下页边距
  mar-x: 20mm, // 左右页边距
)

/* 前辅助页属性（初始16开） */
#let page-pre = (
  index: false, // 前辅助页序号显示
  pagenum: true, //前辅助页页码显示
  outline: true, // 前辅助页目录显示
  header: false, // 前辅助页页眉显示
)

/* 语言设置 */
#let lans = (
  language: "zh", // 语言
  region: "cn", // 地区
  part-sty: "第一部分", // 正文部分样式
  chapter-sty: "第一章", // 正文一级标题样式
  appendix-sty: "附录 A", // 附录一级标题样式
  preface-prefix: [前], // 引用前辅助页一级标题前缀
  chapter-prefix: [章], // 引用正文一级标题前缀
  appendix-prefix: [附], // 引用附录一级标题前缀
  equation: auto, // 公式前缀
  image: auto, // 图片前缀
  table: auto, // 表格前缀
  cite-sty: "gb-7714-2015-note", // 参考文献样式
)

/* 衬线字体与无衬线字体 */
#let serif-font = (
  (name: "Source Han Serif SC", covers: "latin-in-cjk"),
  "Source Han Serif SC"
) // 衬线字体
#let sans-font = (
  (name: "Source Han Sans SC", covers: "latin-in-cjk"),
  "Source Han Sans SC"
) // 无衬线字体
#let code-font = (
  (name: "Consolas", covers: "latin-in-cjk"),
  "Source Han Sans SC"
) // 代码字体
#let math-font = (
  "New Computer Modern Math"
) // 数学字体

/* 正文的字号、字体、颜色 */
#let main-text = (
  size: 10.5pt, // 正文字号
  font: serif-font, // 正文字体
  fill: black, // 正文颜色
  ligatures: false, // 连字开关，例如 fi
)

/* 段落布局 */
#let paras = (
  indent: (amount: 2em, all: true), // 首行缩进
  lstind: 1em, // 列表缩进
  wspace: 1.5em, // 文字间距
  ispace: main-text.size * 2, // 图像表格和文字间距
  bspace: main-text.size * 1.2 // block和文字间距
)

/* 标题的段落和高级样式与字体样式（按照typst的文本属性） */
#let heading1-sty = (
  upspace: page-all.height * 0.1, // 一级标题距离上边距
  downspace: paras.wspace + 0.6em, // 一级标题距离下边距
  image: true, // 一级标题页头图（推荐图片尺寸：页面宽度 x 页面高度*0.3）
  part: false, // 部分页是否影响章节计数
  appendix: true, // 附录独立计数器
  index: false, // 正文公式图像表格统一计数
  text: (
    size: 18pt, // 一级标题字号
    font: sans-font, // 一级标题字体
    weight: "regular", // 一级标题字重
  )
)
#let heading2-sty = (
  upspace: paras.wspace + 1.00em, // 二级标题上边距
  downspace: paras.wspace + 0.40em, // 二级标题下边距
  mark: "", // 二级标题前标
  mark-gutter: 2mm,
  text: (
    size: 15pt, // 一级标题字号
    font: serif-font, // 一级标题字体
    weight: "bold", // 一级标题字重
  )
)
#let heading3-sty = (
  upspace: paras.wspace + 0.50em, // 三级标题上边距
  downspace: paras.wspace + 0.35em, // 三级标题下边距
  mark: "", // 三级标题前标
  mark-gutter: 2mm,
  text: (
    size: 12pt, // 一级标题字号
    font: serif-font, // 一级标题字体
    weight: "bold", // 一级标题字重
  )
)
#let heading4-sty = (
  upspace: paras.wspace + 0.00em, // 四级标题上边距
  downspace: paras.wspace + 0.30em, // 四级标题下边距
  mark: "", // 四级标题前标
  mark-gutter: 2mm,
  text: (
    size: 11pt, // 四级标题字号
    font: serif-font, // 四级标题字体
    weight: "regular", // 四级标题字重
  )
)

/* 目录样式（最高三层） */
#let outline-sty = (
  depth: 3, // 目录层级
  partbox: true, // 部分底栏显示
  partbox-color: gray, // 部分底栏颜色
  part-text: (
    size: 12pt, // 部分字号
    font: sans-font, // 部分字体
    fill: black, // 部分颜色
  ),
  level1-text: (
    size: 10.5pt, // 一级标题字号
    font: sans-font, // 一级标题字体
    fill: black, // 一级标题颜色
  ),
  level2-text: (
    size: 10.5pt, // 二级标题字号
    font: serif-font, // 二级标题字体
    fill: black, // 二级标题颜色
  ),
  level3-text: (
    size: 9pt, // 三级标题字号
    font: serif-font, // 三级标题字体
    fill: black, // 三级标题颜色
  ),
  other-text: (
    size: 10.5pt, // 页码，填充字号
    font: serif-font, // 页码，填充字体
  ),
  fill: "·", // 标题和页码之间的填充
)

#outline-sty.insert("headbox-size", outline-sty.level1-text.size * 5) // 目录页一级标题前缀盒子大小

/* 辅助文字的字体样式（按照typst的文本属性） */
#let aux-text = (
  header-text: (
    size: 9pt, // 页眉字号
    font: serif-font, // 页眉字体
    fill: black, // 页眉颜色
  ),
  footer-text: (
    size: 9pt, // 页脚字号
    font: serif-font, // 页脚字体
    fill: black, // 页脚颜色
  ),
)

/* 其他文字颜色 */
#let colour = (
  theme: black, // 主题颜色
  sect: black, // 小节前缀颜色
  cite: rgb("#13752e"), // 引用颜色
  link: rgb("#681818") // 链接颜色
)

