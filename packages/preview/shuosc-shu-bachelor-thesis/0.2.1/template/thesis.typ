#import "@preview/shuosc-shu-bachelor-thesis:0.2.1": documentclass, algox, tablex, citex, imagex, subimagex

#let (
  info,
  doc,
  cover,
  declare,
  appendix,
  outline,
  mainmatter,
  conclusion,
  abstract,
  bib,
  acknowledgement,
  under-cover,
) = documentclass(
  info: (
    title: "基于Typst的上海大学毕业论文模板",
    school: "计算机工程与科学",
    major: "计算机科学与技术",
    student_id: "21123456",
    name: "张三",
    supervisor: "李四教授",
    date: "1000-2000",
  ),
)

#show: doc.with(
  fallback: false // 为true时字体缺失时使用系统默认，不显示豆腐块
)
#cover()
#declare()

#abstract(
  keywords: ("学位论文", "论文格式", "规范化", "模板"),
  keywords-en: ("dissertation", "dissertation format", "standardization", "template"),
)[
  摘要的内容需作者简要介绍本论文的主要内容主要为本人所完成的工作和创新点。

  ……

  (注：标题黑体小二号，正文宋体小四，行距20磅)
][
  The content of the abstract requires the author to briefly introduce the main content of this paper, mainly for my work and innovation.

  …….

  (Times New Roman，小四号，行距20磅)
]

#outline(
  compact: false // true目录是紧凑的形式；false按照学校的方式
) 

#show: mainmatter.with(
  math-level: 1 // 选择不同的公式编号层级（不同的老师有不同的要求）
)

= 章节一

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


正文各章节应拟标题，每章结束后应另起一页。标题要简明扼要，不应使用标点符号。各章、节、条的层次，可以按照“1……、1.1……、1.1.1……”标识，条以下具体款项的层次依次按照“1.1.1.1”或“（1）”、“①”等标识。各学院根据实际情况，可自行规定层次格式，但学院之内建议格式统一，以清晰无误为准@liu_survey_2024。

正文是毕业论文的主体和核心部分，不同学科专业和不同的选题可以有不同的写作方式。正文一般包括以下几个方面。

== 引言或背景
引言是论文正文的开端，引言应包括毕业论文选题的背景、目的和意义；对国内外研究现状和相关领域中已有的研究成果的简要评述；介绍本项研究工作研究设想、研究方法或实验设计、理论依据或实验基础；涉及范围和预期结果等。要求言简意赅，注意不要与摘要雷同或成为摘要的注解。

== 主体
论文主体是毕业论文的主要部分，必须言之成理，论据可靠，严格遵循本学科国际通行的学术规范。在写作上要注意结构合理、层次分明、重点突出，章节标题、公式图表符号必须规范统一。论文主体的内容根据不同学科有不同的特点，一般应包括以下几个方面：
+ 毕业设计（论文）总体方案或选题的论证；
+ 毕业设计（论文）各部分的设计实现，包括实验数据的获取、数据可行性及有效性的处理与分析、各部分的设计计算等；
+ 对研究内容及成果的客观阐述，包括理论依据、创新见解、创造性成果及其改进与实际应用价值等；
+ 论文主体的所有数据必须真实可靠，自然科学论文应推理正确、结论清晰；人文和社会学科的论文应把握论点正确、论证充分、论据可靠，恰当运用系统分析和比较研究的方法进行模型或方案设计，注重实证研究和案例分析，根据分析结果提出建议和改进措施等。

== 结论
结论是毕业论文的总结，是整篇论文的归宿。应精炼、准确、完整。着重阐述自己的创造性成果及其在本研究领域中的意义、作用，还可进一步提出需要讨论的问题和建议。

= 图表格式

== 图格式
=== 单张图片
#imagex(
  image("figures/energy-distribution.png", width: 70%),
  caption: [energy distribution along radial],
  label-name: "image",
)

=== 多个子图
#imagex(
  subimagex(
    image("figures/energy-distribution.png", width: 70%),
    caption: "子图a",
    label-name: "test"
  ),
  subimagex(image("figures/energy-distribution.png", width: 70%)),
  subimagex(image("figures/energy-distribution.png", width: 70%)),
  subimagex(image("figures/energy-distribution.png", width: 70%)),
  columns: 2,
  caption: [energy distribution along radial],
  label-name: "subfigures",
)

#pagebreak()
== 表格格式

可以续表:
#v(30em)

#tablex(
  ..for i in range(15) {
    ([250], [88], [5900], [1.65])
  },
  header: (
    [感应频率 #linebreak() (kHz)],
    [感应发生器功率 #linebreak() (%×80kW)],
    [工件移动速度 #linebreak() (mm/min)],
    [感应圈与零件间隙 #linebreak() (mm)],
  ),
  columns: (1fr, 1fr, 1fr, 1fr),
  caption: [66666666],
  label-name: "table",
)<what>

== 公式格式

$ 1 / mu nabla^2 Alpha - j omega sigma Alpha - nabla(1 / mu) times (nabla times Alpha) + J_0 = 0 $<equation>

#h(-2em)其中$mu$是材料的磁导率，$sigma$是材料的电导率，$omega$是电磁波的角频率，$Alpha$是电磁场的矢量位，$J_0$是电流密度。使用```typst #h(-2em)```取消这一行前面的缩进。

== 算法格式
算法也可以续：
#v(15em)
#[
  #import "@preview/lovelace:0.2.0": *
  #algox(
    label-name: "algorithm",
    caption: [欧几里得辗转相除],
    breakable: true,
    pseudocode(
      no-number,
      [#h(-1.25em) *input:* integers $a$ and $b$],
      no-number,
      [#h(-1.25em) *output:* greatest common divisor of $a$ and $b$],
      [*while* $a != b$ *do*],
      ind,
      [*if* $a > b$ *then*],
      ind,
      $a <- a - b$,
      ded,
      [*else*],
      ind,
      $b <- b - a$,
      ded,
      [*end*],
      ded,
      [*end*],
      [*return* $a$],
    ),
  )
]

也可以直接插入代码：
#algox(
  caption: [欧几里得辗转相除C++实现],
  [
    ```cpp
    嘿嘿
    #include <bits/stdc++.h>
    using namespace std;
    int gcd(int a, int b) {
      while (a != b) {
        if (a > b) a -= b;
        else b -= a;
      }
      return a;
    }
    ```
  ],
)

= 引用格式

== 常规引用

#tablex(
  header: (
    [引用对象],
    [效果],
    [原始代码],
  ),
  [表格],
  [我要引用@tbl:table],
  [```typst 我要引用@tbl:table```],
  table.cell(
    rowspan: 2,
    align: horizon,
  )[图片],
  [我要引用@img:image],
  [```typst 我要引用@img:image```],
  [我要引用@img:subfigures:test],
  [```typst 我要引用@img:subfigures:test```],
  [算法],
  [我要引用@algo:algorithm],
  [```typst 我要引用@algo:algorithm```],
  [公式],
  [我要引用@eqt:equation],
  [```typst 我要引用@eqt:equation```],
  columns: (1fr, 1fr, 1fr),
  caption: [常规引用示例表],
  label-name: "table1",
)

另一种函数引用方法: ```typst #ref(<img:image>)```

== 章节引用<main_test>

我要引用@main_test：```typst 我要引用@main_test ```

我要引用#ref(<appendix_test_1.1>)：```typst 我要引用@main_test```

== 页面引用
请注意#ref(<jump>, form: "page") 的```typst #bib```函数，它的`sup`参数在下一节会用到。

#pagebreak()

== 文献引用

#tablex(
  header: (
    [引用对象],
    [效果],
    [原始代码],
  ),
  [句子末尾引用],
  [Typst很厉害@liu_survey_2024],
  [```typst Typst很厉害@liu_survey_2024```],

  [句子末尾引用],
  [Typst很厉害#citex(<test>)],
  [```typst Typst很厉害#citex(<test>)```],

  [句子内部引用],
  [文献#citex(<liu_survey_2024>, sup: false)说Typst很厉害],
  text(0.7em)[```typst 文献#citex(<liu_survey_2024>,sup:false) 说Typst很厉害```],

  table.hline(stroke: 0.2pt),

  [用别的格式的引用(自行查阅参数)],
  [#citex(<liu_survey_2024>, style: "future-science", form: "prose")\ 这些人说的],
  text(0.8em)[```typst #citex(<liu_survey_2024>,style: "future-science", form:"prose")
    \ 这些人说的```],

  alignment: left + horizon,
  columns: (1fr, 1.5fr, 2fr),
  caption: [文献引用示例表],
  label-name: "table2",
)

当```typst #bib```中的`sup`为`true`的时候，所有的不标注`sup`的引用默认不为右上标；当```typst #bib```中的`sup`为`true`的时候，所有的不标注`sup`的引用默认为右上标。

使用别的格式时`sup`失效。

#conclusion[
  结论是毕业论文的总结，是整篇论文的归宿。应精炼、准确、完整。着重阐述自己的创造性成果及其在本研究领域中的意义、作用，还可进一步提出需要讨论的问题和建议。
]

// 参考文献
#bib(
  bibfunc: bibliography("ref.bib"),
  full: false, // false表示只显示已引用的文献，不显示未引用的文献；true表示显示所有文献
  sup: true, // true表示行内标注默认为上角标；false表示行内标注默认占据整行
)<jump>

#show: appendix

= 附录格式

论文附录依次用大写字母“附录A、附录B、附录C……”表示，附录内的分级序号可采用“附A1、附A1.1、附A1.1.1”等表示，图、表、公式均依此类推为“图A1、表A1、式（A1）”等。包含以下内容：

（1）代码、图表、标准、手册等数据；

（2）未发表过的一手文献；

（3）公式推导与证明、调查表等；

（4）辅助性教学工具或表格；

（5）其他需要展示或说明的内容

……

（标题黑体小二号，内容Times New Roman/宋体，小四号，行距20磅）

== 测试1

#figure(
  image(
    "figures/energy-distribution.png",
    width: 70%,
  ),
  kind: "image",
  supplement: [图],
  caption: [Energy distribution along radial], // 英文图例
)<image2>

......

=== 测试1.1 <appendix_test_1.1>

#figure(
  image(
    "figures/energy-distribution.png",
    width: 70%,
  ),
  kind: "image",
  supplement: [图],
  caption: [Energy distribution along radial], // 英文图例
)<image3>

= 测试2
#figure(
  image(
    "figures/energy-distribution.png",
    width: 70%,
  ),
  kind: "image",
  supplement: [图],
  caption: [Energy distribution along radial], // 英文图例
)<image4>

......

#acknowledgement(
  location: "上海大学",
  date: none, // 日期为空则默认为当天
)[
  表达真情实感即可。

  （致谢部分切勿照搬，本部分内容也在论文查重范围之内）

  （格式：宋体，Times New Roman小四号字，两边对齐，首行缩进2个字符，行距23磅，字符间距为“标准”）

]

#under-cover()
