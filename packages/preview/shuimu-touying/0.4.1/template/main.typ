#import "@preview/shuimu-touying:0.4.1": *

#show: shuimu-touying-theme.with(
  // shuimu-touying-theme：主题入口，通常配合 #show 使用。
  // aspect-ratio: "16-9",
  // align: horizon,
  // display-section-slides: true,
  // header-title: self => utils.display-current-heading(depth: self.slide-level),
  // footer-reporter: self => self.info.reporter,
  // footer-author: self => self.info.author,
  // footer-deck-title: self => self.info.title,
  // footer-slide-counter: context utils.slide-counter.display() + " / " + utils.last-slide-number,

  // 颜色自定义案例：默认使用清华紫默认配色。
  // theme-colors: shuimu-colors(
  //   primary: rgb("#660874"),
  //   primary-dark: rgb("#320439"),
  //   neutral-lightest: rgb("#ffffff"),
  //   neutral-darkest: rgb("#000000"),
  // ),

  // 字体自定义案例：默认使用 Linux Libertine + Noto Serif CJK SC 等默认字体。
  // theme-fonts: shuimu-fonts(
  //   main: ("Linux Libertine", "Palatino", "Noto Serif CJK SC", "Songti SC"),
  //   body-size: 20pt,
  //   footer-size: 0.5em,
  //   header-title-size: 1.3em,
  // ),

  config-info(
    title: [报告主标题],
    subtitle: [报告副标题],
    reporter: [报告人姓名],
    author: [作者姓名],
    supervisor: [导师姓名],
    date: datetime.today(),
    institution: [清华大学院系名称],
  ),
)

// title-slide：封面页；可用命名参数临时覆盖 config-info 中的字段。
// #title-slide(title: [临时封面标题], reporter: [临时报告人])
#title-slide()

// outline-slide：目录页；默认标题来自 Touying 的本地化设置。
// #outline-slide(title: [目录])
#outline-slide()

// 下面的示例章节用于展示模板用法，正式写作时可以删除或替换。
= 快速上手

== 修改报告信息

- 在 `config-info(...)` 中填写标题、作者、报告人、导师、日期和机构。
- `#title-slide()` 会读取这些信息生成封面。
- 需要临时覆盖封面信息时，可以写成 `#title-slide(title: [临时标题])`。

== 编写页面结构

- 使用一级标题 `= 章节名` 创建章节。
- 使用二级标题 `== 页面标题` 创建普通正文页。
- 目录页和顶部 mini-frame 导航会根据一级标题自动生成。

// slide：手动创建普通页时使用；标题、页眉、页脚和对齐方式都可临时覆盖。
// #slide(title: [手动页标题], align: top)[
//   - 手动页内容
// ]
#slide(title: [手动页面示例], align: top)[
  - 当标题层级不方便表达页面结构时，可以直接使用 `#slide(...)`。
  - `align: top` 适合内容较多的页面；默认 `horizon` 更适合内容较少的页面。
]

= 常用组件

== 普通正文页

- 这里可以放段落、列表、引用和图表。
- 正文默认使用模板设置的字体、字号、项目符号和页脚。
- 文献引用可以直接写在正文中，例如 @cai1985。

== 强调内容块

// titled-block：带标题栏的内容块，适合公式、定理、定义或阶段性结论。
// #titled-block(title: [示例块], [正文内容])
#titled-block(
  title: [结论示例],
  [这里放需要强调的公式、定义、结论或阶段性进展。],
)

== 公式与编号

// 设置*全局*公式编号格式为 (1)，(2)，...
// 也就是说在这个命令之后的公式都会带上编号，可以随意调整这个命令的位置
#set math.equation(numbering: "(1)")

#titled-block(
  title: [有编号公式],
  [$ e^(pi i) + 1 = 0 $],
)

#titled-block(
  title: [部分无编号公式],
  [#math.equation(block: true, numbering: none)[
    $ 1 + 1 = 2 $
  ]],
)

#titled-block(
  title: [继续编号],
  [$ 2+2=4 $],
)

= 收尾页面

// new-section-slide：章节页；通常设置 display-section-slides: true 后自动调用。
// #new-section-slide(title: [章节标题])[
//   章节说明
// ]

== 参考文献

- 使用 `@引用键` 插入文献引用，例如 @cai1985。
- `#bibliography(...)` 会读取 `refs.bib` 并生成参考文献页。

#set align(top) // 参考文献部分应该顶部对齐
#bibliography(
  "refs.bib",
  title: none, // 已手写 `== 参考文献` 作为页标题，避免重复生成标题影响导航。
  full: true, // 是否包括给定参考文献文件中的所有作品，即使它们在文档中没有被引用
  style: "gb-7714-2015-numeric", // 引文样式
)

// focus-slide：强调页或 Q&A 页，不计入幻灯片页码。
// #focus-slide([Q&A])
#focus-slide([
  Q&A])
