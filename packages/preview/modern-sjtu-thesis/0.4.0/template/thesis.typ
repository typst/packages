#import "@preview/modern-sjtu-thesis:0.4.0": *

#let (
  doctype,
  date,
  twoside,
  anonymous,
  info,
  doc,
  preface,
  mainmatter,
  appendix,
  cover,
  cover-en,
  declare,
  abstract,
  abstract-en,
  outline,
  image-outline,
  table-outline,
  algorithm-outline,
  bib,
  acknowledgement,
  achievement,
  summary-en,
) = documentclass(
  doctype: "master", // 文档类型: "master" | "doctor" | "bachelor"
  date: datetime(year: 2024, month: 11, day: 11), // 日期，如果需要显示今天的日期，可以使用 datetime.today() 函数
  twoside: false, // 双面模式
  print: false, // 打印模式, 设置为 true 时，根据奇偶页调整页边距
  anonymous: false, // 盲审模式
  info: (
    student_id: "520XXXXXXXX",
    name: "张三",
    name_en: "Zhang San",
    degree: "工学硕士",
    supervisor: "李四教授",
    supervisor_en: "Prof. Li Si",
    title: "上海交通大学学位论文格式模板",
    title_en: "DISSERTATION TEMPLATE FOR MASTER DEGREE OF ENGINEERING IN SHANGHAI JIAO TONG UNIVERSITY",
    school: "某某学院",
    school_en: "School of XXXXXXX",
    major: "某某专业",
  ),
)

#show: doc

#cover()

#cover-en()

#declare(
  confidentialty-level: "internal", // 保密级别: "public" | "internal" | "secret" | "confidential"
  confidentialty-year: 2, // 保密年份数，请根据保密级别的要求填写
  // date: datetime.today(),
)

#show: preface

#abstract(
  keywords: (
    "学位论文",
    "论文格式",
    "规范化",
    "模板",
  ),
)[
  学位论文是研究生从事科研工作的成果的主要表现，集中表明了作者在研究工作中获得的新的发明、理论或见解，是研究生申请硕士或博士学位的重要依据，也是科研领域中的重要文献资料和社会的宝贵财富。

  为了提高研究生学位论文的质量，做到学位论文在内容和格式上的规范化与统一化，特制作本模板。
]

#abstract-en(keywords: ("dissertation", "dissertation format", "standardization", "template"))[
  As a primary means of demonstrating research findings for postgraduate students, dissertation is a systematic and standardized record of the new inventions, theories or insights obtained by the author in the research work. It can not only function as an important reference when students pursue further studies, but also contribute to scientific research and social development.

  This template is therefore made to improve the quality of postgraduates' dissertations and to further standardize it both in content and in format.
]

#outline()

#image-outline() // 插图目录，按需设置

#table-outline() // 表格目录，按需设置

#algorithm-outline() // 算法目录，按需设置

#show: mainmatter
#show: word-count-cjk // 正文字数统计

= 绪论

== 引言

学位论文......

=== 三级标题

......

==== 四级标题

......

== 本文研究主要内容

本文......

== 本文研究意义

本文......

== 本章小结

本文......

= 格式要求

== 论文正文

论文正文是主体，一般由标题、文字叙述、图、表格和公式等部分构成 @liu_survey_2024。一般可包括理论分析、计算方法、实验装置和测试方法，经过整理加工的实验结果分析和讨论，与理论计算结果的比较以及本研究方法与已有研究方法的比较等，因学科性质不同可有所变化。

论文内容一般应由十个主要部分组成，依次为：1. 封面，2. 中文摘要，3. 英文摘要，4. 目录，5. 符号说明，6. 论文正文，7. 参考文献，8. 附录，9. 致谢，10. 攻读学位期间发表的学术论文目录@wang_overview_2025。

以上各部分独立为一部分，每部分应从新的一页开始，且纸质论文应装订在论文的右侧。

== 字数要求

=== 硕士论文要求

各学科和学院自定。

=== 博士论文要求

各学科和学院自定。

== 其他要求

=== 页面设置

页边距：上3.5厘米，下4厘米，左右均为2.5厘米，装订线靠左0.5厘米位置。

页眉：2.5厘米。页脚：3厘米。

无网格。

=== 字体

英文与数字字体要求为Times New Roman。如果英文与数字夹杂出现在黑体中文中，则将英文与数字采用Times New Roman字体再加粗。

== 本章小结

本章介绍了......

= 图表、公式格式

== 图表格式

=== 单张图片

#imagex(
  image(
    "figures/energy-distribution.png",
    width: 70%,
  ),
  caption: [内热源沿径向的分布],
  caption-en: [Energy distribution along radial],
  label-name: "image",
)

=== 多个子图

#imagex(
  subimagex(
    image("figures/emissions-variation.png"),
    caption: [温室气体排放量随时间变化的情况],
    // caption-en: [Greenhouse gas emissions over time],
    label-name: "test1",
  ),
  subimagex(
    image("figures/emissions-2050.png"),
    caption: [2050 年的温室气体排放量],
    // caption-en: [Greenhouse gas emissions in 2050],
    label-name: "test2",
  ),
  columns: (1fr, 1fr),
  caption: [不同情景下上海市乘用车的温室气体排放量],
  // caption-en: [Greenhouse gas emissions from passenger cars in Shanghai under different scenarios],
  label-name: "subfigures",
)

// 图的引用请以 img 开头
如@img:image 和@img:subfigures:test2 所示，......

// 表的引用请以 tbl 开头
我们来看@tbl:table，

#tablex(
  ..for i in range(20) {
    ([250], [88], [5900], [1.65])
  },
  header: (
    [感应频率 #linebreak() (kHz)],
    [感应发生器功率 #linebreak() (%×80kW)],
    [工件移动速度 #linebreak() (mm/min)],
    [感应圈与零件间隙 #linebreak() (mm)],
  ),
  columns: (25%, 25%, 25%, 25%),
  caption: [高频感应加热的基本参数],
  caption-en: [XXXXXXX],
  label-name: "table",
)

== 公式格式

// 公式的引用请以 eqt 开头
我要引用@eqt:equation。

$ 1 / mu nabla^2 Alpha - j omega sigma Alpha - nabla(1 / mu) times (nabla times Alpha) + J_0 = 0 $<equation>

== 算法格式

// 算法的引用请以 algo 开头
我们可以通过@algo:fibonacci 来计算斐波那契数列第 $n$ 项。

#let tmp = math.italic("tmp")
#algox(
  label-name: "fibonacci",
  caption: [斐波那契数列计算],
  pseudocode-list(line-gap: 1em, indentation: 2em)[
    - #h(-1.5em) *input:* integer $n$
    - #h(-1.5em) *output:* Fibonacci number $F(n)$
    + *if* $n = 0$ *then return* $0$
    + *if* $n = 1$ *then return* $1$
    + $a <- 0$
    + $b <- 1$
    + *for* $i$ *from* $2$ *to* $n$ *do*
      + $tmp <- a + b$
      + $a <- b$
      + $b <- tmp$
    + *end*
    + *return* $b$
  ],
)

== 本章小结

本章介绍了……

= 全文总结

== 主要结论

本文主要……

正文与附录的总字数为：#total-words。 // 字数统计功能，仅供参考

== 研究展望

更深入的研究……

// 参考文献
#bib(
  bibfunc: bibliography.with("ref.bib"),
  full: false,
)// full: false 表示只显示已引用的文献，不显示未引用的文献；true 表示显示所有文献

#show: appendix

// 请根据文档类型，自行选择 if-else 中的内容

#if doctype == "bachelor" [
  = 符号与标记

  #table(
    columns: 2,
    align: (right, left),
    column-gutter: 1em,
    row-gutter: 0.5em,
    [$epsilon$], [介电常数],
    [$mu$], [磁导率],
  )

] else [
  = 实验环境

  == 硬件配置

  ......

  == 软件工具

  ......

]

#if doctype == "bachelor" [
  #achievement(
    papers: (
      "Chen H, Chan C T. Acoustic cloaking in three dimensions using acoustic metamaterials[J]. Applied Physics Letters, 2007, 91:183518.",
      "Chen H, Wu B I, Zhang B, et al. Electromagnetic Wave Interactions with a Metamaterial Cloak[J]. Physical Review Letters, 2007, 99(6):63903.",
    ),
    patents: ("第一发明人, 永动机[P], 专利申请号202510149890.0.",),
  )

  #acknowledgement[
    致谢主要感谢导师和对论文工作有直接贡献和帮助的人士和单位。致谢言语应谦虚诚恳，实事求是。
  ]
] else [
  #acknowledgement[
    致谢主要感谢导师和对论文工作有直接贡献和帮助的人士和单位。致谢言语应谦虚诚恳，实事求是。
  ]

  #achievement(
    papers: (
      "Chen H, Chan C T. Acoustic cloaking in three dimensions using acoustic metamaterials[J]. Applied Physics Letters, 2007, 91:183518.",
      "Chen H, Wu B I, Zhang B, et al. Electromagnetic Wave Interactions with a Metamaterial Cloak[J]. Physical Review Letters, 2007, 99(6):63903.",
    ),
    patents: ("第一发明人, 永动机[P], 专利申请号202510149890.0.",),
  )
]

#summary-en[
  HCCI (Homogenous Charge Compression Ignition)combustion has advantages in terms of efficiency and reduced emission. HCCI combustion can not only ensure both the high economic and dynamic quality of the engine, but also efficiently reduce the NOx and smoke emission. Moreover, one of the remarkable characteristics of HCCI combustion is that the ignition and combustion process are controlled by the chemical kinetics, so the HCCI ignition time can vary significantly with the changes of engine configuration parameters and operating conditions......
]
