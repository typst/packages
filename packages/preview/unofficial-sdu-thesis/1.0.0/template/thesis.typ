// 使用typst packages库
#import "@preview/unofficial-sdu-thesis:1.0.0": * //上一版本为0.2.2
// 如果是本地安装，则使用
// #import "@local/unofficial-sdu-thesis:1.0.0": *
// 如果是源码调试，则使用
// #import "../lib.typ": *

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
    title: "XXXX毕业论文",
    name: "渐入佳境Groove",
    id: "20XXXXXXXXXX",
    school: "XXXX学院",
    major: "XXXX",
    grade: "20XX级",
    mentor: "MENTORNAME",
    time: "20XX年X月XX日",
  ),
  // 此项控制是否开启匿名模式，开启后自动匹配全文范围的导师名MENTORNAME，替换为****
  ifMentorAnonymous: false
)

#show: doc
#cover()
#abstract(
  body: [
    中文摘要应将学位论文的内容要点简短明了地表达出来，一般约300\~800个汉字，字体为宋体小四号。内容应包括目的与意义、研究内容与方法以及研究结论等。

    同时需要突出论文的新论点、新见解或创造性成果，语言力求精炼。注意：中英文摘要和中英文关键词，要一一对应。
  ],
  keywords: ("关键词1", "关键词2", "关键词3", "关键词4", "关键词5"),
  body-en: [
    This dissertation explores innovative approaches in artificial intelligence applications. The research methodology combines theoretical analysis with practical experiments, resulting in novel insights and frameworks. The findings contribute significantly to the field, offering potential solutions for real-world implementation.

    The study highlights original perspectives and creative outcomes, demonstrating both academic rigor and practical relevance.
  ],
  keywords-en: ("dissertation", "dissertation format", "standardization", "template"),
)
#outline()


#show: mainmatter

//===========开始正文============
= 绪#h(2em)论

== 二级标题
山東大學本科畢業論文（設計）Typst模板。

=== 三级标题
本文...

=== 三级标题
许多年后 @toshev_deeppose_2014，奥雷里亚诺·布恩迪亚上校站在行刑队面前，准会想起父亲带他去见识冰块的那个遥远的下午。

Many years later, as he faced the firing squad @stumberg_dmvio_2022 , Colonel Aureliano Buendía was to remember that distant afternoon when his father took him to discover ice.

当时的马孔多是一个二十户人家的村落，泥巴和芦苇盖成的房屋沿河岸排开，河水清澈，沿着遍布光滑的石头的河床流淌，那些石头洁白而巨大，像是史前的蛋。

At that time Macondo was a village of twenty adobe houses, built on the bank of a river of clear water that ran along a bed of polished stones, which were white and enormous, like prehistoric eggs.

这片土地如此年轻 @lee_groundmovingplatformbased_2016 @choi_pose2mesh_2021 @kim_realtime_2015，许多事物都还没有名字 ，提到的时候需要用手指指点点。

The world was so recent that many things lacked names, and in order @bay_surf_2006 to indicate them it was necessary to point.

你可以看到 @img:image2

= 本科毕业论文写作规范

- *养成良好的写作习惯*：
  - 写作过程中，及时保存并备份文档，特别是当版本有较大更新时。
  - 为突出显示、方便修改，成文时，全文中所有与序号有关的章节号、图号、表号、式号、文献号、附录号等，均用#text(fill: rgb("c00000"))[深红色]标注。#text(fill:gray,font: "Courier New")[rgb:C00000]

== 正文写作规范

=== 正文字体规范

+ *正文字体字号*：
  - 中文使用小四号宋体
  - 外文字母（英文字母、希腊字母等）和数字使用小四号 Times New Roman 字体

+ *图表名称字体字号*：
  - 中文使用五号宋体
  - 外文字母和数字使用五号 Times New Roman 字体
  - 图表名称需加粗并居中对齐

+ *标点符号使用规则*：
  - 中文句子使用中文标点符号
  - 英文句子使用英文标点符号
  - 全文括号、引号、波浪号等统一使用 Times New Roman 字体：
  - 英文摘要和参考文献中，英文标点符号后需空一格（段落最后一个标点符号除外）

== 二级标题
本组织...

=== 三级标题
本文将...

= 图表格式
== 图格式
#figure(
  rect(image(
    "img/AlbertEinstein.png",
    width: 50%,
  )),
  // kind: "image", 被弃用的特性
  supplement: [图],
  caption: [Albert Einstein], // 英文图例
)<Einstein>

// 图片引用采用@img:<image>，具体细节在figures.typ内。
如@img:Einstein 所示，这是爱因斯坦。

== 表格格式
// 表的引用请以 tbl 开头
这里展示了一张数据表格，见@tbl:这张表格的label

// tablex不需要嵌套在figure内完成 lable设置
#tablex(
  header: (
    [感应频率 #linebreak() (kHz)],
    [感应发生器功率 #linebreak() (%×80kW)],
    [工件移动速度 #linebreak() (mm/min)],
    [感应圈与零件间隙 #linebreak() (mm)],
  ),
  columns: (1fr, 1fr, 1fr, 1fr),
  // colnum: 4,被弃用的特性
  caption: [这是一个表格示例],
  label-name: "这张表格的label",
  ..for i in range(10) {
    ([250], [88], [5900], [1.65])
  },
)

同时，见@tbl:包含两位科学家的表 所示，这是另外两位科学家的照片，他们分别是香农和冯诺伊曼。这一部分的内容主要用于帮助认识`tablex`的用法。

#tablex(
  columns: (1fr, 1fr),
  caption: [两位科学家],
  label-name: "包含两位科学家的表",
  header: (
    [Claude Elwood Shannon \ 克勞德·夏農], // "\" is same with #linebreak()
    [John von Neumann #linebreak() 約翰·馮·諾伊曼],
  ),
  figure(
    image(
      "img/ClaudeElwoodShannon.png",
      width: 50%,
    ),
    supplement: [图],
  ),
  figure(
    image(
      "img/John von Neumann.png",
      width: 50%,
    ),
    supplement: [图],
  ),
)

== 公式格式
// 公式的引用请以 eqt 开头
我要引用 @eqt:equation。

$ 1 / mu nabla^2 Alpha - j omega sigma Alpha - nabla(1/mu) times (nabla times Alpha) + J_0 = 0 $<equation> //添加公式引用键使用<>符号

== 算法格式
我要引用 @algo:algorithm
#rect(width: 50%, height: 5em, fill: black)[
  #align(center + alignment.horizon)[
    #text(fill: white)[填充: width:50%, height:5em]
  ]
]
#[
  #import "@preview/lovelace:0.2.0": *
  #algox(
    label-name: "algorithm",
    caption: [欧几里得辗转相除],
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

= 总结与展望
总结全文并展望。主要撰写论文工作的结论、创新点、不足之处、进一步研究展望等内容，不宜插入图表。

== 工作总结
#lorem(20)
== 不足之处与进一步研究展望
#lorem(20)

=== 不足之处与进一步研究展望
#lorem(20)

==== 不足之处与进一步研究展望
test here
#lorem(20)

===== 不足之处与进一步研究展望
#lorem(20)

// 文献引用 使用前请确保存在ref.bib文件，相关内容请查阅BibTeX
#bib(bibfunc: bibliography("ref.bib"))

// 致谢
#acknowledgement()[
  表达真情实感即可。
  （致谢部分切勿照搬，本部分内容也在论文查重范围之内）
  （格式：宋体，Times New Roman小四号字，两边对齐，首行缩进2个字符，行距23磅，字符间距为“标准”）

]



// 附录
#show: appendix

= 附#h(2em)录
“附录”二字黑体小二号加粗居中，中间空4个空格；内容为宋体小四号、首行缩进两字符、1.5倍行距。对于不宜放在正文中，但有参考价值的内容，可放附录中。例如，重复测试的实验结果图表，篇幅较大的图、表、数学式的推演、编写的算法、程序代码段等。注意：正文文字统领图表式、文献、附录。所有的附录均应在正文文字中提及。
== 附图示例
#figure(
  image(
    "./img/appendix/Lenna.png",
    width: 70%,
  ),
  kind: "appendix",
  supplement: [附图],
  caption: [Lenna], // 英文图例
)<image2>
这里可以记录文字描述。

#figure(
  image(
    "./img/appendix/Sierpinski_pyramid.jpg",
    width: 70%,
  ),
  kind: "appendix",
  supplement: [附图],
  caption: [Sierpinski pyramid], // 英文图例
)<image4>

......

#figure(
  image(
    "./img/appendix/Sigmoid.svg",
    width: 100%,
  ),
  kind: "appendix",
  supplement: [附图],
  caption: [Sigmoid function], // 英文图例
)<image3>

#pagebreak()
== 附表示例

这是一个示例附表 @tbl:续表示例

#tablex(
  columns: (1fr, 1fr, 1fr),
  caption: [用于构成十进倍数和分数单位的词头],
  supplement: "附表",
  label-name: "续表示例",
  header: (
    [所表示的因数], // "\" is same with #linebreak()
    [词头名称],
    [词头符号],
  ),
  [$10^18$],
  [艾\[可萨\]],
  [E],
  [$10^15$],
  [拍\[它\]],
  [P],
  [$10^12$],
  [太\[拉\]],
  [T],
  [$10^9$],
  [吉\[咖\]],
  [G],
  [$10^6$],
  [兆],
  [M],
  [$10^3$],
  [千],
  [k],
  [$10^2$],
  [百],
  [H],
  [$10^1$],
  [十],
  [da],
  [$10^-1$],
  [分],
  [d],
  [$10^-2$],
  [厘],
  [c],
  [$10^-3$],
  [毫],
  [m],
  [$10^-6$],
  [微],
  [H],
  [$10^-9$],
  [纳\[诺\]],
  [n],
  [$10^-12$],
  [皮\[可\]],
  [P],
  [$10^-15$],
  [飞\[母托\]],
  [f],
  [$10^-18$],
  [阿\[托\]],
  [a],
  [$10^-6$],
  [微],
  [H],
  [$10^-9$],
  [纳\[诺\]],
  [n],
  [$10^-12$],
  [皮\[可\]],
  [P],
  [$10^-15$],
  [飞\[母托\]],
  [f],
  [$10^-18$],
  [阿\[托\]],
  [a],
  [$10^-6$],
  [微],
  [H],
  [$10^-9$],
  [纳\[诺\]],
  [n],
  [$10^-12$],
  [皮\[可\]],
  [P],
  [$10^-15$],
  [飞\[母托\]],
  [f],
  [$10^-18$],
  [阿\[托\]],
  [a],
)

