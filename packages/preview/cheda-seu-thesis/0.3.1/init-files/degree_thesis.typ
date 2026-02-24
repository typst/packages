#import "@preview/cheda-seu-thesis:0.3.1": degree-conf, degree-utils
#let (thanks, show-appendix) = degree-utils

/*
  使用模板前，请先安装 https://github.com/csimide/SEU-Typst-Template/tree/master/fonts 内的所有字体。
  如果使用 Web App，请将这些字体上传到 Web App 项目的根目录中。
*/

// 由于研究生院模板没有严格规定代码块的字体，为了美观，在此设定代码块字体
#show raw: set text(font: ("Fira Code", "SimHei"))
#import "@preview/codelst:2.0.2": sourcecode
#let code = sourcecode

#let terminology = [

  如果有必要可以设置此注释表。此部分内容可根据论文中采用的符号、变量、缩略词等专用术语加以定义和注释，以便于论文阅读和迅速查出某符号的明确含义。

  术语表建议使用 ```typ #let``` 语句另行定义，再通过参数传入模板。

  一般来说，请用 ```typ #table``` 绘制表格。如果想让术语表也有编号，可以使用 ```typ #figure```。

  `table` 的用法请见 Typst 文档。

  #figure(
    table(
      columns: (1fr, 1fr),
      align: center + horizon,
      rows: auto,
      inset: 8pt,
      stroke: none,
      //auto-vlines: false,
      table.hline(),
      table.header[*符号、变量、缩略词等*][*含义*],
      table.hline(stroke: 0.5pt),
      [SEU],table.vline(stroke: 0.5pt), [东南大学],
      table.hline(stroke: 0.5pt),
      [Typst],[Typst is a new markup-based typesetting system for the sciences.],
      table.hline(),
    ),
    kind: table,
    caption: [本论文专用术语（符号、变量、缩略词等）的注释表]
  )

  #h(2em)当 `terminology` 为 `none` 时，此注释表页面不会被渲染。 
]


#show: doc => degree-conf(
  author: (CN: "王东南", EN: "WANG Dong-nan", ID: "012345"),
  thesis-name: (
    CN: "摸鱼学硕士学位论文",
    EN: [
    A Thesis submitted to \
    Southeast University \
    For the Academic Degree of Master of Touching Fish
    ],
    heading: "东南大学硕士学位论文"
  ),
  title: (
    CN: "摸鱼背景下的Typst模板使用研究",
    EN: "A Study of the Use of the Typst Template During Touching Fish"
  ),
  advisors: (
    (CN: "湖牌桥", EN:"HU Pai-qiao", CN-title: "教授", EN-title: "Prof."),
    (CN: "苏锡浦", EN:"SU Xi-pu", CN-title: "副教授", EN-title: "Associate Prof.")
  ),
  school: (
    CN: "摸鱼学院",
    EN: "School of Touchingfish"
  ),
  major: (
    main: "摸鱼科学",
    submajor: "计算机摸鱼"
  ),
  degree: "摸鱼学硕士",
  category-number: "N94",
  secret-level: "公开",
  UDC: "303",
  school-number: "10286",
  committee-chair: "张三 教授",
  readers: (
    "李四 副教授",
    "王五 副教授"
  ),
  date: (
    CN: (
      defend-date: "2099年01月02日", 
      authorize-date: "2099年01月03日",
      finish-date: "2024年01月15日"
    ),
    EN: (
      finish-date: "Jan 15, 2024"
    )
  ),
  thanks: "本论文受到摸鱼基金委的基金赞助（123456）",
  degree-form: "应用研究",
  cn-abstract: [
    论文摘要包括题名、硕士（博士）研究生姓名、导师姓名、学校名称、正文、关键词中文约 500 字左右，英文约 200~300 词左右，二者应基本对应。它是论文内容的高度概括，应说明研究目的、研究方法、成果和结论，要突出本论文的创造性成果或新的见解，用语简洁、准确。论文摘要后还应注明本文的关键词 3 至 5 个。关键词应为公知公用的词和学术术语，不可采用自造字词和略写、符号等，词组不宜过长。
  ],
  cn-keywords: ("关键词1", "关键词2"),
  en-abstract: [
    英文摘要采用第三人称单数语气介绍该学位论文内容，目的是便于其他文摘摘录，因此在写作英文文摘时不宜用第一人称的语气陈述。叙述的基本时态为一般现在时，确实需要强调过去的事情或者已经完成的行为才使用过去时、完成时等其他时态。可以采用被动语态，但要避免出现用“This paper”作为主语代替作者完成某些研究行为。中国姓名译为英文时用汉语拼音，按照姓前名后的原则，姓、名均用全名，不宜用缩写。姓全用大写，名的第一个字母大写，名为双中文字时两个字的拼音之间可以不用短划线，但容易引起歧义时必须用短划线。例如“冯长根”译为“FENG Changgen”或“FENG Chang-gen”，而“冯长安”则必须译为“FENG Chang-an”。论文英文封面上的署名也遵守此规定。

    #lorem(100)
    ],
  en-keywords: ("Keywords1", "Keywords2"),
  always-start-odd: true,
  terminology: terminology,
  anonymous: false, // 选项暂时无用，未来用于渲染盲审版本
  first-level-title-page-disable-heading: false, // 一级标题页不显示页眉
  // 启用此选项后，“第X章 XXXXX” 一级标题所在页面将不显示页眉
  bilingual-bib: true,
  doc,
)


= 封面、扉页、摘要说明

模板的封面、扉页、摘要内容都是在参数中传入的。使用方法请参考本 Demo 文档。

封面的部分横线长度可能不合适，请在 https://github.com/csimide/SEU-Typst-Template/issues 提交反馈以便修改。

若摘要等过长，也可以先行定义摘要变量，再将其作为参数传入。


= 正文内容说明

正文是学位论文的主体。内容可因研究课题的性质不同而有所变化。一般可包括：文献综述、理论基础、计算方法、实验方法、经过整理加工的实验结果的分析讨论、见解和结论。正文一律用阿拉伯数字编排页码，页码在底部居中。正文之前的摘要、目录等内容单独编排罗马数字页码。

== 绪论（前言）

本研究课题国内外已有的重要文献的扼要概括，阐明研究此课题的目的、意义，研究的主要内容和所要解决的问题。本研究工作在国民经济建设和社会发展中的理论意义与实用价值。

== 文献综述

在查阅国内外文献和了解国内外有关科技情况的基础上，围绕课题涉及的问题，综述前人工作情况，达到承前启后的目的。要求：（1）总结课题方向至少 10 年以来的国内外动态；（2）明确前人的工作水平；（3）介绍目前尚存在的问题；（4）说明本课题的主攻方向。文献总结应达到可独立成为一篇综述文章的要求。


== 理论分析、数值计算或统计分析

利用研究生本人所掌握的理论知识对所选课题进行科学地、严密地理论分析、数值计算或统计分析，剖析课题，提出自己的见解。

== 实验原理、实验方法及实验装置

学位论文要求对实验原理、方法、装置、步骤和有关参数有较详细的阐述，以便评阅人及答辩委员会审核实验的可靠性，并能对实验进行重复以便验证结果的可靠性，也为以后的研究者提供一个较完整的研究方法。

== 实验结果及分析

列出数据的图或表，并对数据结果进行讨论，对比分析、结果推论要严格准确，避免采用模棱两可的评定语言。对反常的数据要保留并做解释或者说明，不可随意剔除数据做出有违科学公正的行为。引用别人的研究成果及数据应加注参考文献，较长的公式推导可列入附录。采纳文献及引用数据应为可以公开并能重复查到的文献资源，并需标明准确出处（如页码或图表序号等）。正文引用文献一律用右上角方括号内的次序号（阿拉伯数字）以“上标”格式标示。

== 图、表、公式、计量单位和数字用法的规定

=== 图

图包括曲线图、构造图、示意图、图解、框图、流程图、地图、照片等。图应具有“自明性”，即只看图、图题和图例，不阅读全文，就可理解图意。图应编排序号，可按章用阿拉伯数字顺序编排，例如图 3-1。插图较少时可按全文编排，如图 1、图 2……，若有分图用（a）（b）（c）表示，图注在图名下方，内容按序编号并用分号“；”隔开。

每一图应有简短确切的题名，连同图号置于图下。图题、图号字体与正文相同，字体也可改用仿宋以示与正文的区别。必要时，应将图上的符号、标记、代码以及实验条件等，用最简练的文字，横排于图题下方，作为图例说明。

本模板采用按章节编号的方式。如果需要插入带自动编号的图片，需要使用```typ #figure```。例如，使用下面的代码插入带编号的图片：

#code(
  ```typst
  #figure(
    image("./demo_image/24h_rain.png", width: 8.36cm),// 宽度/高度需要自行调整
    caption: [每小时降水量24小时均值分布图]
  )
  ```
)

#figure(
  image("./demo_image/24h_rain.png", width: 8.36cm),
  caption: [每小时降水量24小时均值分布图]
)

#h(2em) 通常情况下，插入图、表等组件后，后续的首个段落会丢失首行缩进，需要使用 `#h(2em)` 手动补充缩进。


如一个插图由两个及以上的分图组成，分图用(a)、(b)、(c)等标出，并标出分图名。目前，本模板尚未实现分图的字母自动编号。如需要分图，建议使用 `#grid` 来构建。例如：

#code(
  ```typst
  #figure(
    grid(
      columns: (3.83cm, 5.51cm),
      image("./demo_image/2-2a.png") + "(a) 速度障碍集合;", 
      image("./demo_image/2-2b.png") + "(b) 避免碰撞集合"
    ),
    caption: "速度障碍法速度选择"
  )
  ```
)

#figure(
  grid(
    columns: (3.83cm, 5.51cm),
    image("./demo_image/2-2a.png") + "(a) 速度障碍集合;", 
    image("./demo_image/2-2b.png") + "(b) 避免碰撞集合"
  ),
  caption: "速度障碍法速度选择"
)

#h(2em) 实际使用中，网格划分、网格大小调整需要自行操作。

=== 表

表的编排，一般是内容和测试项目由左至右横读，数据依序竖排。表应有自明性并采用阿拉伯数字编排序号，如表 1、表 2 等，表格较多时可按章排序，如表 1.1、@table1 等。

带编号、表名的表格需要使用 `#figure` 包裹，才能自动编号。方式与上方图片相仿，或者查看下面的代码说明。表格本身建议使用函数 `table` 、或第三方库 `tablem` 库绘制。使用 `tablem` 库时，`#figure` 可能会认为其包裹的内容不是 `table` 类型，而编号“图X-X”。可以通过添加 `kind: table` 声明这是一个表格。

#code(
```typst
#figure(
  {
    set table.cell(stroke: (top: 0.8pt, bottom: 0.8pt, left: 0pt, right: 0pt))
    show table.cell.where(y:0): set text(weight: "bold")
    table(
      columns: 13,
      rows: 1.8em,
      align: center + horizon,
      table.header(
        [], table.cell(colspan: 4)[Stage 1 (>7.1 μm)], table.cell(colspan: 4)[Stage 2 (4.8-7.1 μm)], table.cell(colspan: 4)[Stage 3 (3.2-4.7 μm)], 
      ),

      [], [Con], [Low], [Medium], [High], [Con], [Low], [Medium], [High], [Con], [Low], [Medium], [High],

      [H], [2.52], [2.58], [2.57], [2.24], [2.48], [2.21], [2.21], [2.36], [2.66], [2.65], [2.64], [2.53],

      [E], [0.87], [0.88], [0.93], [0.85], [0.9], [0.86], [0.86], [0.85], [0.9], [0.9], [0.85], [0.88]
    )
  },
  caption: "室外细菌气溶胶香农-维纳指数（H）和均匀性指数（E）",
)
```
) 

#figure(
  {
    set table.cell(stroke: (top: 0.8pt, bottom: 0.8pt, left: 0pt, right: 0pt))
    show table.cell.where(y:0): set text(weight: "bold")
    table(
      columns: 13,
      rows: 1.8em,
      align: center + horizon,
      table.header(
        [], table.cell(colspan: 4)[Stage 1 (>7.1 μm)], table.cell(colspan: 4)[Stage 2 (4.8-7.1 μm)], table.cell(colspan: 4)[Stage 3 (3.2-4.7 μm)], 
      ),

      [], [Con], [Low], [Medium], [High], [Con], [Low], [Medium], [High], [Con], [Low], [Medium], [High],

      [H], [2.52], [2.58], [2.57], [2.24], [2.48], [2.21], [2.21], [2.36], [2.66], [2.65], [2.64], [2.53],

      [E], [0.87], [0.88], [0.93], [0.85], [0.9], [0.86], [0.86], [0.85], [0.9], [0.9], [0.85], [0.88]
    )
  },
  caption: "室外细菌气溶胶香农-维纳指数（H）和均匀性指数（E）",
)<table1>

#h(2em)每一表应有简短确切的题名，连同表号置于表上。必要时，应将表中的符号、标记、代码以及需要说明事项，以最简练的文字，横排于表题下，作为表注，也可以附注于表下。表内附注的序号宜用小号阿拉伯数字并加右圆括号置于被标注对象的右上角，如：×××1），不宜用星号“\*”，以免与数学上共轭的符号相混。目前，本模板暂未实现表内“1）”格式的附注。

表的各栏均应标明“量（或测试项目）、标准规定符号、单位”。只有在无必要标注的情况下方可省略。表中的缩略词和符号，必须与正文中一致。

表内同一栏的数字必须上下对齐。表内不宜用“同上”、“同左”、“″”和类似词，应一律填入具体数字或文字。表内“空白”代表未测或无此项，“-”或“…”代表未发现（当“-”可能与代表阴性反应相混时用“…”代替），“0”表示实测结果确为零。

=== 数学、物理符号和化学式

正文中的公式、算式或方程式等应编排序号，序号标注于该式所在行的最右边；当有续行时，应标注于最后一行的最右边。

公式及文字中的一般变量（或一般函数）（如坐标$X$、$Y$，电压$V$，频率$f$）宜用斜体，矢量用粗斜体如$bold(S)$或白斜体上加单箭头$limits(S)^arrow$，常用函数（如三角函数$cos$、对数函数$ln$等）、数字运算符、化学元素符号及分子式、单位符号、产品代号、人名地名的外文字母等用正体。

Typst 的公式与 LaTeX 写法不同，参见 Typst 官方文档。

在 Typst 中，使用 ```typ $$``` 包裹公式以获得行内公式，在公式内容两侧增加空格以获得块公式。如 ```typ $alpha + beta = gamma$``` 会获得行内公式 $alpha + beta = gamma$，而加上两侧空格，写成 ```typ $ alpha + beta = gamma $``` ，就会变成带自动编号的块公式：

$ alpha + beta = gamma $ <eqexample>

#h(2em) 与图表相同，公式后的第一段通常也需要手动缩进。

多行公式可以使用 `\ ` 换行（反斜杠紧跟空格或者反斜杠紧跟换行）。与 LaTeX 类似，`&` 可以用于声明对齐关系。

#code(
  ```typst
  $ E_"ocv" &= 1.229 - 0.85 times 10^(-3) (T_"st" - T_0) \
    &+ 4.3085 times 10^(-5) T_"st" [ln(P_H_2/1.01325)+1/2 ln(P_O_2/1.01325)] 
  $
  ```
)

$
E_"ocv" &= 1.229 - 0.85 times 10^(-3) (T_"st" - T_0) \
  &+ 4.3085 times 10^(-5) T_"st" [ln(P_H_2/1.01325)+1/2 ln(P_O_2/1.01325)] 
$


#h(2em) 公式首行的起始位置位于行首算起第五个中文字符之处，即在段落起始行的首行缩进位置再退后两个中文字符。不要用居中、居左或居行首排列。公式编号按阿拉伯数字顺序编号，如（1）（2）……，公式较多时可按章顺序编号，如（1.1）（1.2）……。

*由于目前实现公式首行空四格的做法是修改对齐方式，故如遇多行公式，请手动为每行公式添加对齐，否则公式的位置将错位。*

公式引用使用式 1、式 1.1 等，英语文本中用 Eq.1、Eq.1.1 等。在 Typst 中，可以给公式添加 label 再引用。例如引用 @eqt:eqexample。

请注意，引用公式、图表需要添加相应的前缀，如  ```typ @tbl:``` ```typ @fig:``` ```typ @eqt:```。

#code(
```typst
$ alpha + beta = gamma $ <eqexample>

例如引用@eqt:eqexample。
```
)

// 上面这处代码请不要直接复制
// 因为为了规避渲染报错，加了一个零宽度空格

#h(2em) 较短的公式一般一式一行并按顺序编号，后面一式若为前面一式的注解（如下标范围 i=1，3，5，……）可用括号括起来与前面一式并排一行。较长的公式必须转行时，只能在=、≈、+、-、×、÷、<、>处转行。上下式尽可能在等号“=”处对齐。公式中符号尚未说明者应有说明，符号说明之间用分号隔开，一般一个符号占一行。

不需编号的公式也可以不用另起行。如：$I=V \/ R$ 。在上文的“行内公式”已经解说，此处不再赘述。由于 Typst 默认尝试使用数学方式表现，例如 ```typ $I=V / R$``` 会显示为 $I=V / R$，而研院的排版要求中说明“不宜采用竖式，以便使行距均匀，编排整齐。”故有时需要使用转义方式输入斜杠，如 ```typ $I=V \/ R$```。

=== 计量单位和数字用法

论文必须采用 1984 年 2 月 27 日国务院发布的《中华人民共和国法定计量单位》，并遵照《中华人民共和国法定计量单位使用方法》执行。各种量、单位和符号，必须遵循国家标准的规定执行。数字和单位用法应遵照 GB/T 15835，例如：

不宜在文字中间夹杂使用数学（物理）符号、计量单位符号，例如“钢轨每 m 重量＜50kg”应写成“钢轨每米重量小于 50kg”；

纯小数在小数点前面的 0 不能省略；

百分数及幂次数量范围应完整表达，如“20%\~40%”不应写作“20\~40%”，“3×102
\~5×102”不能写成“3\~5×102”；避免让单位误为词头，如力矩单位 N·m 或 Nm 不能写成 mN；组合单位中的斜线不能多于一条，如 w/（m2·℃）不能写成 w/m2/℃。

注意：`~` 在 Typst 的书写环境中是不断行空格。如果需要输入 `~` 本身，可能需要转义为 `\~` 输入。

== 结论

结论应该观点明确、严谨、完整、准确，文字必须简明扼要，要阐明本人在科研工作中的创造性成果、新见解及其意义，本文成果在本领域中的地位和作用，对存在的问题和不足应做出客观的叙述和提出建议。

应严格区分自己的成果与导师科研成果和前人已有研究的界限。

== 为引用文献而添加的章节


#h(2em)参考文献需要使用 bib 格式的引用文献表，再在正文中通过 ```typ @labelname``` 方式引用。如


#code(
```typst
这里有一段话 @kopka2004guide.

引用多个会自动合并 @kopka2004guide @wang2010guide 。
```
) 

#h(2em)这里有一段话 @kopka2004guide，引用多个会自动合并 @kopka2004guide @wang2010guide 。


目前参考文献格式不符合研究生院要求，会在今后重制/寻找合适的 csl 文件。

完成上述操作后，*在致谢章节之后！致谢章节之后！致谢章节之后！*，添加

#code(
```typst
#bibliography(
  "ref.bib", // 替换为自己的bib路径
  style: "gb-t-7714-2015-numeric-seu-degree.csl"
)
```
) 

#h(2em)就会自动生成参考文献表。demo 使用的 `ref.bib` 来自 https://github.com/lucifer1004/pkuthss-typst 。

当前（Typst 0.12.x）的 GB/T 7714-2015 参考文献功能仍有较多问题；东大使用的参考文献也不是标准的 GB/T 7714-2015 格式。目前，我们尝试使用曲线方法解决：

为了生成中英文双语的参考文献表，本模板实验性地引入了 `bilingual-bibliography` 。有关该功能的详细信息，请访问 https://github.com/nju-lug/modern-nju-thesis/issues/3 。如果出现参考文献显示不正常的情况，请前往 https://github.com/csimide/SEU-Typst-Template/issues/1 反馈。

模板提供了 `bilingual-bib` 参数，用于控制是否使用 `bilingual-bibliography`。当 `bilingual-bib` 参数设置为 `true` 时，模板会使用 `bilingual-bibliography` 渲染。

本模板附带的 `gb-t-7714-2015-numeric-seu-degree.csl` 是“修复”部分 bug 的学位论文用 CSL 文件。该格式和东大格式不完全吻合，但比自带的 `gb7714-2015` 稍微符合一些。



#thanks[

致谢应当作为正文部分的最后一个章节出现。

可以在正文后对本论文学术研究有特别贡献的组织或个人表达谢意：

1、对提供资助或者支持的基金（基金项目应该包括基金名称、项目名称、项目编号、项目负责人、研究起止年月等）、合同单位、企业、组织或者个人；

2、协助完成研究工作或提供便利的组织或个人；

3、给予转载或者引用权的资料、图片、文献、研究设想的所有者。

致谢章节应当使用 ```typ #thanks[内容]``` 显示。

在致谢章节后，请添加  ```typ #bibliography``` 引用文献表。

参考文献过后，需要使用```typ #show: show-appendix```进入附录部分。

]

#bibliography(
  "ref.bib", // 替换为自己的bib路径
  style: "gb-t-7714-2015-numeric-seu-degree.csl"
)

#show: show-appendix // 进入附录部分


= 附录说明 <appendix-1>

如果有必要可以设置附录。该部分包括与论文有关的原始数据明细表，较多的图表，计算程序及说明，过长的公式推导，或取材于复制品而不便于编入正文的材料等。附录一般与论文全文装订在一起，与正文一起编页码。如果附录内容很多，可独立成册。若有多个附录，则按大写英文字母编号排序，如附录 A、附录 B 等，每一个附录均另起一页。附录中的公式及图表编号应冠以附录序号字母加一短划线，如公式（A-2）、图 A-2，表 B-2 等。

$ 
&1+2+ \
&3+4+\ 
&66666666
$ <ss1>

#figure(
  {
    set table.cell(stroke: (top: 0.8pt, bottom: 0.8pt, left: 0pt, right: 0pt))
    show table.cell.where(y:0): set text(weight: "bold")
    table(
      columns: 13,
      rows: 1.8em,
      align: center + horizon,
      table.header(
        [], table.cell(colspan: 4)[Stage 1 (>7.1 μm)], table.cell(colspan: 4)[Stage 2 (4.8-7.1 μm)], table.cell(colspan: 4)[Stage 3 (3.2-4.7 μm)], 
      ),

      [], [Con], [Low], [Medium], [High], [Con], [Low], [Medium], [High], [Con], [Low], [Medium], [High],

      [H], [2.52], [2.58], [2.57], [2.24], [2.48], [2.21], [2.21], [2.36], [2.66], [2.65], [2.64], [2.53],

      [E], [0.87], [0.88], [0.93], [0.85], [0.9], [0.86], [0.86], [0.85], [0.9], [0.9], [0.85], [0.88]
    )
  },
  caption: "室外细菌气溶胶香农-维纳指数（H）和均匀性指数（E）",
)

= 余下部分说明

在研院的格式要求中，余下部分还有索引、作者简介、后记（或鸣谢）、封底。目前本模板尚未支持这四个部分。