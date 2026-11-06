#import "@preview/modern-shu-thesis:0.1.1": documentclass

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
  under-cover
) = documentclass(
  info: (
    title: "基于nana的nini",
    school: "某某学院",
    major: "某某专业",
    student_id: "21XXXXX",
    name: "塔尖",
    supervisor: "塔瘪教授",
    date: "1000-2000",
  ),
)

#show: doc
#cover()
#declare()

#abstract(
  keywords: ("学位论文", "论文格式", "规范化", "模板"),
  keywords-en: ("dissertation", "dissertation format", "standardization", "template")
)[
  摘要的内容需作者简要介绍本论文的主要内容主要为本人所完成的工作和创新点。

  ……

  (注：标题黑体小二号，正文宋体小四，行距20磅)

][
  The content of the abstract requires the author to briefly introduce the main content of this paper, mainly for my work and innovation.

  …….

  (Times New Roman，小四号，行距20磅)

]

#outline()

#show: mainmatter

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

#figure(
  image(
    "figures/energy-distribution.png",
    width: 70%,
  ),
  gap: 2em,
  kind: "image",
  supplement: [图],
  caption: [Energy distribution along radial], // 英文图例
)<image>

#v(1.5em)

// 图的引用请以 img 开头
如 @img:image 所示，......

// 表的引用请以 tbl 开头
我们来看 @tbl:table，

可以续表:
\
\
\

// 因为涉及续表，所以表的实现比较复杂且不易抽象成函数
#let xubiao = state("xubiao")
#figure(
  table(
    // 每列比例
    columns: (25%, 25%, 25%, 25%),
    table.header(
      table.cell(
        // 列数
        colspan: 4,
        {
          context if xubiao.get() {
            align(left)[*续@tbl:table*] // 请一定要在末尾给表添加标签(如<table>)，并在此处修改引用
          } else {
            v(-0.9em)
            xubiao.update(true)
          }
        },
      ),
      table.hline(),
      // 表头部分
      [感应频率 #linebreak() (kHz)],
      [感应发生器功率 #linebreak() (%×80kW)],
      [工件移动速度 #linebreak() (mm/min)],
      [感应圈与零件间隙 #linebreak() (mm)],
      table.hline(stroke: 0.5pt),
    ),
    // 表格内容
    ..for i in range(15) {
      ([250], [88], [5900], [1.65])
    },
    table.hline(),
  ),
  kind: "table",
  supplement: [表],
  caption: [高频感应加热的基本参数],
)<table>

== 公式格式

// 公式的引用请以 eqt 开头
我要引用 @eqt:equation。

$ 1 / mu nabla^2 Alpha - j omega sigma Alpha - nabla(1/mu) times (nabla times Alpha) + J_0 = 0 $<equation>

== 本章小结

本章介绍了……

#conclusion[
 结论是毕业论文的总结，是整篇论文的归宿。应精炼、准确、完整。着重阐述自己的创造性成果及其在本研究领域中的意义、作用，还可进一步提出需要讨论的问题和建议。 
]

// 参考文献
#bib(
  bibfunc: bibliography("ref.bib"),
) // full: false 表示只显示已引用的文献，不显示未引用的文献；true 表示显示所有文献

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

=== 测试1.1

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

#acknowledgement(location: "上海大学")[
表达真情实感即可。

（致谢部分切勿照搬，本部分内容也在论文查重范围之内）

（格式：宋体，Times New Roman小四号字，两边对齐，首行缩进2个字符，行距23磅，字符间距为“标准”）

]

#under-cover()