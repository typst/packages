#import "@preview/modern-npu-thesis:0.1.0": algorithm, algorithm-ref, nwpu-thesis

#let thesis-config = (
  doctype: "master", // "bachelor" | "master" | "doctor",
  degree: "professional", // "academic" | "professional",
  anonymous: false, // 是否开启盲审模式
  colored-cover: true, // 是否开启彩色封面封底
  info: (
    title: ("基于 Typst 的", "西北工业大学学位论文"),
    title-en: "First Line 
              Second Line",
    student-id: "2023123456",
    clc: "TP311.1", // 分类号
    author: "航小天",
    author-en: "Xiaotian Hang",
    department: "计算机学院",
    major: "计算机科学与技术",
    major-en: "Computer Science and Technology",
    supervisor: ("张三", "教授"),
    supervisor-en: "San Zhang",
    submit-date: (year: 2026, month: 3),
    // 评阅人名单
    reviewers: (
      (name: "xxx", title: "教授", unit: "西北工业大学（明评示例）"),
      (name: "全盲评阅", title: "无", unit: "无（盲评示例）"),
    ),
    // 答辩委员会信息
    defence-committee: (
      date: datetime(year: 2026, month: 3, day: 9),
      chairman: (name: "赵某某", title: "教授", unit: "西北工业大学"),
      members: (
        (name: "钱某某", title: "教授", unit: "西安交通大学"),
        (name: "孙某某", title: "教授", unit: "西安电子科技大学"),
        (name: "周某某", title: "教授", unit: "西北工业大学"),
        (name: "吴某某", title: "副教授", unit: "西北工业大学"),
      ),
      secretary: (name: "郑某某", title: "讲师", unit: "西北工业大学"),
    ),
  ),
  bibliography: bibliography.with("ref.bib"),
  abstract: [
    中文摘要内容。中文摘要一般应说明研究工作目的、实验方法、结果和最终结论等，而重点是结果和结论。摘要中不用图、表、化学结构式、非公知公用的符号和术语。
  ],
  keywords: ("关键词一", "关键词二", "关键词三", "关键词四"),
  funding: "本研究得到某某基金（编号：   ）资助。",
  abstract-en: [
    English abstract content. The abstract should generally explain the purpose, experimental methods, results, and final conclusions of the research, with emphasis on the results and conclusions.
  ],
  keywords-en: ("Keyword1", "Keyword2", "Keyword3", "Keyword4"),
  funding-en: "The present work is supported by the XXX（Project No.xxx）",
  appendix: [
    =
    附录是学位论文主体的补充，并不是必需的。
    
    附录编号依次编为附录A、附录B。附录标题各占一行，按一级标题编排。每一个附录一般应另起一页编排，如果有多个较短的附录，也可接排。
  ],
  acknowledgement: [
    致谢是作者对该文章的形成作过贡献的组织或个人予以感谢的文字记载，语言要诚恳、恰当、简短。致谢内容可以包括但不限于：国家科学基金、资助研究工作的奖学金基金、合同单位、资助或支持的企业、组织或个人；协助完成研究工作和提供便利条件的组织或个人；在研究工作中提出建议和提供帮助的人；给予转载和引用权的资料、图片、文献、研究和调查的所有者；其他应感谢的组织和个人。
  ],
  academic-achievements: [
    不同类型的成果列表书写格式与参考文献相同。对于学术论文，如已发表的被EI或SCI收录，应标明收录号；SCI论文一般应标注发表当年的影响因子；对已录用但尚未发表的学术论文，请注明是否EI或SCI刊源。
  ],
  scan-declaration: image("images/声明.pdf"),
)

#let thesis-body = [

  = 绪论

  == 研究背景

  XXX

  === 研究意义

  研究意义内容。

  === 研究现状

  研究现状内容。

  == 研究内容

  研究内容概述。

  == 图表测试

  引用@tbl:timing-tlt，以及@fig:test。引用图表时，表格和图片分别需要加上 `tbl:`和`fig:` 前缀才能正常显示编号。

  #figure(
    table(
      columns: (1fr, 1fr, 1fr, 1fr),
      stroke: none,
      inset: (x: 0.3em, y: 0.4em),
      align: center + horizon,

      table.hline(y: 0, stroke: 1.5pt),
      table.header([t], [1], [2], [3]),
      table.hline(y: 1, stroke: 0.5pt),
      [y], [0.3s], [0.4s], [0.8s],
      table.hline(y: 2, stroke: 1.5pt),
    ),
    caption: [三线表],
  ) <timing-tlt>
  
  #figure(
    table(
      columns: (1.25fr, 1fr, 1fr, 1fr, 1fr),
      stroke: none,
      inset: (x: 0.3em, y: 0.4em),
      align: center + horizon,

      table.hline(y: 0, stroke: 1.5pt),
      table.cell(rowspan: 2)[材料],
      table.cell(colspan: 2)[碳/环氧],
      table.cell(colspan: 2)[玻璃/环氧],
      table.hline(y: 1, start: 1, stroke: 0.5pt),
      [纵向], [横向], [纵向], [横向],
      table.hline(y: 2, stroke: 0.5pt),
      [模量，GPa], [181], [10.3], [38.6], [8.3],
      [压缩强度，MPa], [1500], [246], [610], [118],
      [拉伸强度，MPa], [1500], [40], [1062], [31],
      table.hline(y: 5, stroke: 1.5pt),
    ),
    caption: [复杂三线表示例：聚合物基复合材料的性能],
  ) <composite-performance>

  #figure(
    image("images/博士论文封面.jpg", width: 45%),
    caption: [图片测试],
  ) <test>

  图片之间的文字

  #figure(
    grid(
      columns: (1fr, 1fr),
      gutter: 1em,
      align(center)[
        #image("images/博士论文封面.jpg", width: 60%)
        (a) 第一个子图说明
      ],
      align(center)[
        #image("images/博士论文封底.jpg", width: 60%)
        (b) 第二个子图说明
      ],
    ),
    caption: [总图标题],
  ) <fig-main>

  #figure(
    grid(
      columns: (1fr, 1fr),
      rows: (200pt, 200pt),
      gutter: 1em,
      align(center)[
        #image("images/专硕论文封面.jpg", width: 50%)
        (a) 第一个子图说明
      ],
      align(center)[
        #image("images/专硕论文封底.jpg", width: 50%)
        (b) 第二个子图说明
      ],

      align(center)[
        #image("images/学硕论文封面.jpg", width: 50%)
        (c) 第三个子图说明
      ],
      align(center)[
        #image("images/学硕论文封底.jpg", width: 50%)
        (d) 第四个子图说明
      ],
    ),
    caption: [总图标题],
  ) <fig-main>

  == 数学公式

  可以像 Markdown 一样写行内公式 $x + y$，以及带编号的行间公式：

  $ phi.alt := (1 + sqrt(5)) / 2 $ <ratio>

  引用数学公式需要加上 `eqt:` 前缀，则由@eqt:ratio，我们有：

  $ F_n = floor(1 / sqrt(5) phi.alt^n) $

  我们也可以通过 `<->` 标签来标识该行间公式不需要编号

  $ y = integral_1^2 x^2 dif x $ <->

  而后续数学公式仍然能正常编号。

  $ F_n = floor(1 / sqrt(5) phi.alt^n) $

  == 算法示例

  下面给出采用单独算法编号的三线表风格算法示例，见#algorithm-ref(<alg:binary-search>)。

  #algorithm(
    title: [二分查找算法],
    input: [有序数组 $A$，目标值 target。],
    output: [目标值下标，不存在则返回 -1。],
    steps: (
      [left := 0],
      [right := len(A) - 1],
      [while left <= right do],
      [  mid := floor((left + right) / 2)],
      [  if A.at(mid) == target],
      [    return mid],
      [  else if A.at(mid) < target],
      [    left := mid + 1],
      [  else],
      [    right := mid - 1],
      [return -1],
    ),
  ) <alg:binary-search>

  == 参考文献

  可以像这样引用参考文献@蒋有绪1998，引用两个以上的文献时，文献之间用逗号分隔，如@WHO1970 @张志祥1998，引用三个以上的文献 @河北绿洲2001 @李炳穆2000 @丁文祥2000。

  = 研究方法

  == 方法概述

  方法概述内容。

  == 实验设计

  实验设计内容。
]

#show: nwpu-thesis.with(..thesis-config)
#thesis-body
