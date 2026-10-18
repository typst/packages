#import "@preview/shuimu-touying:0.5.0": *

// 下面列出了本模板的全部接口，注释掉的参数保持默认值，需要修改时取消注释。
#show: shuimu-touying-theme.with(
  // aspect-ratio: "16-9", // 幻灯片比例，如 "4-3"
  // lang: "zh", // 文档语言，英文报告改为 "en"
  // align: horizon, // 正文页的默认对齐方式
  // display-section-slides: false, // 是否在每个一级标题处自动插入章节页
  // header-title: auto, // 标题栏文字，也可以是 self => ... 函数：auto 为当前标题，none 为不显示
  // footer-reporter: self => self.info.at("reporter", default: none), // 页脚第一栏，none 时收起
  // footer-author: self => self.info.author, // 页脚第二栏
  // footer-deck-title: self => if self.info.short-title == auto { self.info.title } else { self.info.short-title }, // 页脚第三栏
  // footer-slide-counter: context utils.slide-counter.display() + " / " + utils.last-slide-number, // 页脚第四栏

  // theme-colors: shuimu-colors(
  //   primary: rgb("#660874"), // 主色：标题栏、页脚、内容块、焦点页
  //   primary-dark: auto, // 导航栏背景和目录文字，auto 为由主色加深
  //   neutral-lightest: rgb("#ffffff"), // 主色背景上的文字
  //   neutral-darkest: rgb("#000000"), // 正文文字
  // ),

  // theme-fonts: shuimu-fonts(
  //   main: ("Libertinus Serif", "Noto Serif CJK SC"), // 正文字体，西文在前、中文在后
  //   mono: "DejaVu Sans Mono", // 等宽字体
  //   math: "New Computer Modern Math", // 数学字体
  //   body-size: 20pt, // 正文字号，以下 em 值都相对正文
  //   navigation-size: 0.7em, // 导航栏
  //   header-title-size: 1.3em, // 标题栏
  //   title-slide-title-size: 1.2em, // 封面标题
  //   title-slide-subtitle-size: 1.0em, // 封面副标题
  //   title-slide-info-size: 0.7em, // 封面机构与日期
  //   outline-size: 1.2em, // 目录文字
  //   outline-number-size: 0.75em, // 目录编号（相对目录文字）
  //   section-title-size: 2.5em, // 章节页标题
  //   section-body-size: 0.8em, // 章节页说明
  //   focus-size: 1.5em, // 焦点页
  //   footer-size: 0.5em, // 页脚
  //   caption-size: 0.6em, // 图表标题
  //   footnote-size: 0.6em, // 脚注
  // ),

  // config-common(datetime-format: "[year]年[month padding:none]月[day padding:none]日"), // 日期格式示例，默认 auto

  config-info(
    title: [报告主标题],
    // short-title: [短标题], // 页脚显示的短标题
    subtitle: [报告副标题],
    reporter: [报告人姓名], // 多人时写成数组
    author: [作者姓名], // 多人时写成字符串数组，如 ("张三", "李四")
    supervisor: [导师姓名],
    institution: [清华大学院系名称],
    date: datetime.today(),
  ),
)

// 全局的 set/show 规则写在这里：#show 这一行之后、第一张幻灯片之前。
// 不要把 set 规则单独写在一级标题和它的第一个二级标题之间，否则会多出一张空白页。
#set math.equation(numbering: "(1)") // 公式编号格式为 (1)、(2)……

// 封面页
#title-slide(
  // role-labels: (reporter: [汇报人：]), // 修改角色标签，默认随 lang 显示
  // title: [临时标题], // 命名参数可临时覆盖 config-info 中的字段
  // config: (:), // 本页的 Touying 配置，所有页面函数都有这个参数
)

// 目录页
#outline-slide(
  // title: [目录], // 标题栏文字，默认随 lang 显示
)

// 以下示例章节演示模板用法，正式写作时可以删除或替换。
= 快速上手

== 修改报告信息

- 在 `config-info(...)` 中填写标题、作者、报告人、导师、日期和机构，不需要的字段直接删掉。
- 多人时写成字符串数组，例如 `author: ("张三", "李四")`。
- `#title-slide()` 读取这些信息生成封面。

== 编写页面结构

- 一级标题 `= 章节名` 创建章节，二级标题 `== 页面标题` 创建正文页。
- 目录页和顶部导航栏根据一级标题自动生成，每张正文页对应一个圆点。
- 内容放不下时会自动续页，续页与原页共用一个导航圆点，页码照常递增。

// 手动创建正文页，参数只影响本页
#slide(
  title: [手动页面与多栏], // 标题栏文字
  align: top, // 正文对齐方式
  composer: (1fr, 1fr), // 分栏，每个 [...] 是一栏
  // header: none, // 替换标题栏，导航栏保留
  // footer: none, // 替换页脚
  // repeat: auto, // 动画子页数量，通常自动推断
  // setting: body => body, // 本页的 show/set 规则
)[
  - `#slide(...)` 适合标题层级不方便表达的页面。
  - `align: top` 适合内容较多的页面，默认的 `horizon` 适合内容较少的页面。
][
  - `composer: (1fr, 1fr)` 把正文分成两栏。
]

= 常用组件

== 动画与强调

- *加粗文字*用主色强调，也可以写 `#alert[...]`。
- 脚注写在正文中#footnote[脚注显示在页面底部。]，外链（如 #link("https://typst.app")[Typst]）用主色标出。
- 用 `#pause` 分步显示内容：
#pause
- 这一条在下一步才出现。

== 图表

#figure(
  table(
    columns: 3,
    [方法], [准确率], [耗时],
    [基线方法], [85%], [1.0 s],
    [本文方法], [92%], [0.8 s],
  ),
  caption: [表格的标题显示在表格上方],
)

== 强调内容块

// 带标题栏的内容块，内容中也可以使用 #pause
#titled-block(
  title: [结论示例], // 标题，none 时只显示内容区
)[
  这里放需要强调的公式、定义、结论或阶段性进展。
]

== 公式与编号

#titled-block(title: [有编号公式])[
  $ e^(pi i) + 1 = 0 $
]

#titled-block(title: [无编号公式])[
  #set math.equation(numbering: none) // 只在这个块内关闭编号
  $ 1 + 1 = 2 $
]

#titled-block(title: [继续编号])[
  $ 2 + 2 = 4 $
]

= 收尾页面

// 章节页：display-section-slides 为 true 时自动生成；手动调用时放在 `= 章节名` 之后。
// #new-section-slide(
//   title: auto, // 章节标题，默认为当前一级标题
// )[章节说明]

== 参考文献

- 用 `@引用键` 插入文献引用，例如 @cai1985；连续引用会自动合并，例如 @cai2012 @cai1995。
- `#bibliography(...)` 读取 `refs.bib`，只列出正文中引用过的文献。

#bibliography(
  "refs.bib",
  style: "gb-7714-2015-numeric", // 引文样式
  // full: true, // 列出 refs.bib 中的全部文献，包括未引用的
)

// 焦点页，不计入页码
#focus-slide(
  // align: horizon + center, // 内容对齐方式
)[Q&A]
