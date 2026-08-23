#import "@preview/shuimu-touying:0.4.0": *

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

  // 颜色自定义案例：不写时使用清华紫默认配色。
  // theme-colors: shuimu-colors(
  //   primary: rgb("#660874"),
  //   primary-dark: rgb("#320439"),
  //   neutral-lightest: rgb("#ffffff"),
  //   neutral-darkest: rgb("#000000"),
  // ),

  // 字体自定义案例：不写时使用 Linux Libertine + Noto Serif CJK SC 等默认字体。
  // theme-fonts: shuimu-fonts(
  //   main: ("Linux Libertine", "Palatino", "Noto Serif CJK SC", "Songti SC"),
  //   body-size: 20pt,
  //   footer-size: 0.5em,
  //   header-title-size: 1.3em,
  // ),

  config-info(
    title: [报告主标题],
    subtitle: [报告副标题],
    reporter: [*陈海翔*],
    author: [*CHEN MASON*],
    supervisor: [*蔡继明*],
    date: datetime.today(),
    institution: [清华大学社科学院经济学研究所],
  ),
)

// title-slide：封面页；可用命名参数临时覆盖 config-info 中的字段。
// #title-slide(title: [临时封面标题], reporter: [临时报告人])
#title-slide()

// outline-slide：目录页；默认标题来自 Touying 的本地化设置。
// #outline-slide(title: [目录])
#outline-slide()

= 研究背景

- #lorem(50)

// slide：手动创建普通页时使用；标题、页眉、页脚和对齐方式都可临时覆盖。
// #slide(title: [手动页标题], align: top)[
//   - 手动页内容
// ]

= 研究内容
== 研究计划

- #lorem(150)

// titled-block：带标题栏的内容块，适合公式、定理、定义或阶段性结论。
// #titled-block(title: [示例块], [正文内容])
#titled-block(
  title: [无编号公式],
  [$ e^(pi i)+1=0 $],
)

== 工作进度

// 设置*全局*公式编号格式为 (1)，(2)，...
// 也就是说在这个命令之后的公式都会带上编号，可以随意调整这个命令的位置
#set math.equation(numbering: "(1)")

#titled-block(
  title: [有编号公式],
  [$ 0+0=0 $],
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

// focus-slide：强调页或 Q&A 页，不计入幻灯片页码。
// #focus-slide([Q&A])
#focus-slide([Wake Up!])

= 后期安排

== 问题与解决方案

// new-section-slide：章节页；通常设置 display-section-slides: true 后自动调用。
// #new-section-slide(title: [章节标题])[
//   章节说明
// ]

- #lorem(50)@cai1985
- #lorem(50)

#set align(top) // 参考文献部分应该顶部对齐
#bibliography(
  "refs.bib",
  title: "参考文献", // 参考文献部分的标题
  full: true, // 是否包括给定参考文献文件中的所有作品，即使它们在文档中没有被引用
  style: "gb-7714-2015-numeric", // 引文样式
)

#focus-slide([
  向大家致敬！

  Q&A])
