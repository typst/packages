#import "@preview/shuosc-shu-bachelor-thesis:0.3.0": documentclass, algox, tablex, citex, imagex, subimagex
    
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
  fonts,
) = documentclass(
  info: (
    title: "基于Typst的上海大学毕业论文模板",
    school: "计算机工程与科学",
    major: "计算机科学与技术",
    student_id: "21123456",
    name: "张三",
    supervisor: "李四教授",
    date: "2048年2月31日起5月32日止",
  ),
  fonts: (
    fallback: false, // 为true时字体缺失时使用系统默认，不显示豆腐块
    // 模版内置了一定的字体调用顺序，但可能与系统的不一致，出现这种情况是先在Tinyminst->Tool->Fonts的字体库中找到字体名称，然后在下面填入即可
    // 可以配置的字体有：songti, heiti, kaiti, fangsong, dengkuan
    // 正文为songti，标题为heiti，代码为dengkuan
    // 下面是使用示例：
    songti: (
      (name: "Times New Roman", covers: "latin-in-cjk"), // 先指定英文字体
      "簡宋", // 中文字体
    ),
  ),
  title-line-length: 260pt, // 如果题目换行不好看，可以在这里适当修改换行的长度
  math-level: 2, // 选择公式编号层级
  outline-compact: false, // true目录是紧凑的形式；false按照学校的方式
  citation: (
    func: bibliography("ref.bib"), // 参考文献源文件，主流的论文网站（谷歌学术，知网等）都会提供bibtex格式的参考文献
    full: false, // false表示只显示已引用的文献，不显示未引用的文献；true表示显示所有文献
    sup: true, // true表示行内标注默认为上角标；false表示行内标注默认占据整行
  ),
)

// 设置文档格式
#fonts
#show: doc

// 显示封面
#cover()

// 显示声明
#declare(
  author_sign: image("figures/sign.png"), // 学生签名
  supervisor_sign: image("figures/sign.png"), // 教师签名
  date: none, // 日期为空则默认为当天
)

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

// 显示目录
#outline()

// 设置文档主体的格式
#show: mainmatter

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


正文各章节应拟标题，每章结束后应另起一页。标题要简明扼要，不应使用标点符号。各章、节、条的层次，可以按照“1……、1.1……、1.1.1……”标识，条以下具体款项的层次依次按照“1.1.1.1”或“（1）”、“①”等标识。各学院根据实际情况，可自行规定层次格式，但学院之内建议格式统一，以清晰无误为准。

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
  caption: [示例图片],
  label-name: "image1",
  placement: none, // 默认 none, 即图片会强制显示在当前位置; 还可以设置为 auto, top, bottom, 分别表示自动、顶部、底部 (推荐使用 auto)
)

=== 多个子图
#imagex(
  subimagex(
    image("figures/energy-distribution.png", width: 70%),
    caption: "子图a",
    label-name: "sub1",
  ),
  subimagex(image("figures/energy-distribution.png", width: 70%)),
  subimagex(image("figures/energy-distribution.png", width: 70%)),
  subimagex(image("figures/energy-distribution.png", width: 70%)),
  columns: 2,
  caption: [示例子图],
  label-name: "image2",
  placement: none, // 默认 none, 即图片会强制显示在当前位置; 还可以设置为 auto, top, bottom, 分别表示自动、顶部、底部 (推荐使用 auto)
)

#pagebreak()

== 表格格式

表格可以在换页的时候自然断开并显示“续表xxxx”，如果需要令表显示在整页中，请将表中的`breakable`设置为`false`。

#tablex(
  ..for i in range(5) {
    ([250], [88], [5900], [1.65])
  },
  header: (
    [感应频率 #linebreak() (kHz)],
    [感应发生器功率 #linebreak() (%×80kW)],
    [工件移动速度 #linebreak() (mm/min)],
    [感应圈与零件间隙 #linebreak() (mm)],
  ),
  columns: (1fr, 1fr, 1fr, 1fr),
  caption: [示例表格],
  label-name: "table1",
  breakable: true,
)

== 公式格式

$ 1 / mu nabla^2 Alpha - j omega sigma Alpha - nabla(1 / mu) times (nabla times Alpha) + J_0 = 0 $<equation>

#h(-2em)其中$mu$是材料的磁导率，$sigma$是材料的电导率，$omega$是电磁波的角频率，$Alpha$是电磁场的矢量位，$J_0$是电流密度。使用```typst #h(-2em)```取消这一行前面的缩进。

#pagebreak()

== 算法格式
算法和表格一样也是换页的时候自然断开并显示“续算法xxxx”。
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
  [我要引用@tbl:table1],
  [```typst 我要引用@tbl:table```],
  table.cell(
    rowspan: 2,
    align: horizon,
  )[图片],
  [我要引用@img:image1],
  [```typst 我要引用@img:image1```],
  [我要引用@img:image2:sub1],
  [```typst 我要引用@img:subfigures1:test```],
  [算法],
  [我要引用@algo:algorithm],
  [```typst 我要引用@algo:algorithm```],
  [公式],
  [我要引用@eqt:equation],
  [```typst 我要引用@eqt:equation```],
  columns: (1fr, 1fr, 1fr),
  caption: [常规引用示例表],
)

另一种函数引用方法: ```typst #ref(<img:image1>)```

== 章节引用<main_test>

我要引用@main_test：```typst 我要引用@main_test ```

我要引用#ref(<appendix1>)：```typst 我要引用#ref(<appendix1>)```

== 页面引用
请注意#ref(<jump>, form: "page") 的```typst #bib```函数，它会因为`citation.full`参数变化而发生变化。

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

当`citation`中的`sup`为`true`的时候，所有的不标注`sup`的引用默认不为右上标；当`citation`中的`sup`为`true`的时候，所有的不标注`sup`的引用默认为右上标。

使用别的格式时`sup`失效。

= 高级格式

== 数据表格

无论是LaTex还是Word，将大量的数据制作成表格往往是一个非常复杂的过程。更何况这些实验数据日后可能还会变更，那么又要对表格的部分内容进行调整（比如加粗数据最大的那一项），这里给出一个制作数据表格的快捷方法，大致的流程是：
+ 将数据保存为CSV格式（Excel等均支持该格式）；
+ 使用Typst读取；
+ 排版并处理数据。
#ref(<tbl:data1>)是一个简单的例子：

#{
  // 读取文件，分隔符可以为分号
  let result = csv("data/heros.csv", delimiter: ",")

  // 获取列数
  let m = result.at(0).len()

  // 获取表头
  let head = result.at(0)

  // 获取数据部分
  let data = result.slice(1)

  tablex(
    ..data.flatten(), // 将数据展平
    header: head, // 显示表头
    columns: m, // 设置列数
    caption: [超级英雄能力表],
    label-name: "data1",
  )
}

#ref(<tbl:data2>)是一个更复杂的例子：

#let colors = (
  rgb(214, 38, 40, 255),
  rgb(43, 160, 43, 255),
  rgb(158, 216, 229, 255),
  rgb(114, 158, 206, 255),
  rgb(204, 204, 91, 255),
  rgb(255, 186, 119, 255),
  rgb(147, 102, 188, 255),
  rgb(30, 119, 181, 255),
  rgb(188, 188, 33, 255),
  rgb(255, 127, 12, 255),
  rgb(196, 175, 214, 255),
)

#{
  let results = csv("data/nyuv2.csv", delimiter: ",")
  let m = results.at(0).len()
  let head = results.at(0)

  // 将中间的标签旋转90度
  for y in range(m - 3) {
    head.at(y + 2) = rotate(
      90deg,
      stack(dir: ltr, box(fill: colors.at(y), inset: 4pt), head.at(y + 2)),
      reflow: true,
    )
  }
  let data = results.slice(1)

  // 将数据中的最大项找出并加粗
  for y in range(1, m) {
    // 去除非数据元素
    let col_num = data.map(row => row.at(y)).filter(it => it.contains(regex("\d")))

    // 找出最大值
    let max_val = col_num.map(float).reduce(calc.max)

    // 加粗最大值
    data = data.map(row => {
      let item = row.at(y)
      if item.contains(regex("\d")) and float(item) == max_val {
        row.at(y) = [#strong(item)]
      }
      row
    })
  }
  tablex(
    table.vline(x: 2, stroke: 0.2pt),
    table.vline(x: m - 1, stroke: 0.2pt),
    ..data.flatten(),
    header: head,
    columns: (15%, 7%, ..(auto,) * 11, 8%),
    caption: [主流模型在NYUv2数据集下的性能表现],
    label-name: "data2",
  )
}
#pagebreak()

== 流程图绘制

使用#link("https://typst.app/universe/package/fletcher", underline([Fletcher]))可以绘制流程图，点击横线处链接查看使用文档。



== 复杂图形绘制

Fletcher是基于#link("https://typst.app/universe/package/cetz", underline([CeTZ]))的，CeTZ可以绘制更复杂的图形，点击横线处链接查看使用文档。

#import "figures/cetz_graph.typ"
#imagex(
  cetz_graph.camera_model(70%),
  caption: [相机针孔成像模型],
  label-name: "camera_model",
)
#pagebreak()

== LaTex公式
如果你不习惯Typst的公式，可以使用#link("https://typst.app/universe/package/mitex", underline([MiTex]))，点击横线处链接查看使用文档。

#import "@preview/mitex:0.2.5": *

行内公式如下：#mi("x") 或 #mi[y]。

块级公式如#ref(<eqt:equation1>)：
#mitex(`
  \newcommand{\f}[2]{#1f(#2)}
  \f\relax{x} = \int_{-\infty}^\infty
    \f\hat\xi\,e^{2 \pi i \xi x}
    \,d\xi
`)<equation1>

// 显示结论
#conclusion[
  结论是毕业论文的总结，是整篇论文的归宿。应精炼、准确、完整。着重阐述自己的创造性成果及其在本研究领域中的意义、作用，还可进一步提出需要讨论的问题和建议。
]

// 显示参考文献
#bib()

<jump>

// 设置附录文档格式
#show: appendix

= 附录格式
<appendix1>

论文附录依次用大写字母“附录A、附录B、附录C……”表示，附录内的分级序号可采用“附A1、附A1.1、附A1.1.1”等表示，图、表、公式均依此类推为“图A1、表A1、式（A1）”等。包含以下内容：

（1）代码、图表、标准、手册等数据；

（2）未发表过的一手文献；

（3）公式推导与证明、调查表等；

（4）辅助性教学工具或表格；

（5）其他需要展示或说明的内容

……

（标题黑体小二号，内容Times New Roman/宋体，小四号，行距20磅）

// 显示感谢
#acknowledgement(
  location: "上海大学",
  date: none, // 日期为空则默认为当天
)[
  表达真情实感即可。

  （致谢部分切勿照搬，本部分内容也在论文查重范围之内）

  （格式：宋体，Times New Roman小四号字，两边对齐，首行缩进2个字符，行距23磅，字符间距为“标准”）

]

// 显示封底
#under-cover()
