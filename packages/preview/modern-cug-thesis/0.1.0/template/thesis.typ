// 在线包管理器模式
#import "@preview/modern-cug-thesis:0.1.0": documentclass, indent

// 本地模式
// #import "/lib.typ": documentclass, indent

#let (
  // 布局函数
  single-side, doc, mainmatter, mainmatter-end, appendix,
  // 页面函数
  fonts-display-page, title-page, decl-page, resume-page, 
  abstract, abstract-en, bilingual-bibliography,
  outline-page, list-of-figures-tables, notation, acknowledgement,
  // 其他
  info
) = documentclass(
  anonymous: false,  // 盲审模式
  // 论文页面顺序：
  // （封面，统一打印）、题名页（中文，英文）、声明页（原创性声明、导师承诺书、使用授权书）、简历页
  // 中文摘要、Abstract、目录、图和表清单、正文、致谢、参考文献（、附录）。
  // 单面打印范围，自中文摘要后双面
  single-side: ("title-page", "decl-page", "resume-page"),  
  // 可自定义字体，先英文字体后中文字体，应传入「宋体」、「黑体」、「楷体」、「仿宋」、「等宽」
  // fonts: (楷体: ("Times New Roman", "FZKai-Z03S")),
  info: (
    // 论文标题，将展示在题名页与页眉上
    // 多行标题请使用数组传入 `("thesis title", "with part next line")`，
    // 或使用换行符：`"thesis title\nwith part next line"`
    title: ("中国地质大学学位论文Typst模板", "参考研究生学位论文写作规范（2015-）"),
    title-en: ("The Specification of Writting and Printing", "for CUG thesis"),

    // 论文作者信息：学号、姓名、院系、专业、指导老师
    grade: "2025",
    student-id: "120222xxxx",
    school-code: "10491",
    school-name: "中国地质大学",
    school-name-en: "China University of Geosciences",
    author: "张三",
    author-en: "Ming Xing",
    department: "国家地理信息系统\n工程技术研究中心",
    department-en: "National Engineering Research Center of Geographic Information System",
    doctype: "master", // "bachelor" | "master" | "doctor" | "postdoc", 文档类型，默认为本科生 bachelor
    degreetype: "professional", // "academic" | "professional", 学位类型，默认为学术型 academic
    is-equivalent: false,   // 是否同等学力，默认为 false
    is-fulltime: true, // 是否全日制，默认为 true
    degree: "工程硕士",  // 学位名称，默认为工程硕士（专硕学位名称，学硕与专业名称类似）
    degree-en: "Master of Engineering",
    major: "测绘工程",  // 专业名称，默认为测绘工程
    major-en: "Surveying and Mapping Engineering",
    // 指导老师信息，以`("name", "title")` 数组方式传入
    supervisor: ("李四", "教授"),
    supervisor-en: ("Prof.", "Li Si"),
    supervisor-ii: ("王五", "副教授"),
    supervisor-ii-en: ("Prof.", "Wang Wu"),
    address-en: "Wuhan 430074 P.R. China",

    // 提交日期，默认为论文 PDF 生成日期
    submit-date: datetime.today(),
  ),
  // 参考文献源
  bibliography: bibliography.with("ref.bib"),
)

// 文稿设置
#show: doc
// 封面页
#title-page()
// 声明页
#decl-page()
// 作者简历
#resume-page(
  info: (
    // 1. 基本情况信息
    name:"张三", 
    gender: "男", 
    nation: "汉族", 
    birthday: "2000-01-29",
    native-place: "河南省鹤壁市",
    bachelor-time: "2018.09——2022.06",
    bachelor-school: "河南农业大学",
    master-time: "2022.09——2025.06",
    master-school: "中国地质大学（武汉）",
    doctor-time: "2020-09-01",
    doctor-school: "广东工业大学",
    // 2. 学术论文信息
    thesis-reference-1: "X. X研究[J]. X学报，2004（1）：53-55.",
    thesis-reference-2: "X. X分析[J]. X技术，2005（5）：6-7.",
    // 3. 获奖、专利情况信息
    award-1: "X. X. 江苏省科技进步奖三等奖.排名第2；",
    // 4. 研究项目信息
    project-1: "X项目, 国家自然基金,项目编号：X,参加人员；",
  )
)

// 中文摘要
#abstract(
  keywords: ("中国地质大学（武汉）", "学位论文", "Typst模板")
)[
  该项目是中国地质大学（武汉）学位论文Typst模板，主要依据#link("https://xgxy.cug.edu.cn/info/1073/3509.htm")[中国地质大学（武汉）研究生学位论文写作规范（2015-）]实现。该模板包含了 Typst 的简单介绍、特点，以及该模板使用方法以及注意事项等。如有疑问，欢迎各位前来#link("https://github.com/Rsweater/cug-thesis-typst/issues")[issue]交流 ~
]

// 英文摘要
#abstract-en(
  keywords: ("CUG", "Thesis Template", "Typst")
)[
  This project is the China University of Geosciences Dissertation Typst template, which is mainly realized based on #link("https://xgxy.cug.edu.cn/info/1073/3509.htm") [China University of Geosciences Postgraduate Dissertation Writing Standards (2015-)]. The template contains a brief introduction to Typst, its features, and how to use this template as well as precautions. If you have any questions, you are welcome to come to #link("https://github.com/Rsweater/cug-thesis-typst/issues")[issue] to exchange ~
]


// 目录
#outline-page()

// 图表目录
#list-of-figures-tables()

// 正文
#show: mainmatter

// 可以直接在该文件中编写，Typst 编译足够的快 ~
// 如果使用分章节存放，记得打开注释之后先预览（VS Code 右上角的预览按钮，快捷键 Ctrl+K V）一下，
// 确保成功导入相关文件。
// #include "chapters/intro.typ"
// #include "chapters/chapter1.typ"

= 导　论

欢迎使用该模板的用户~ 

该模板基于 Typst 设计，为方便 CUG 学子撰写毕业论文而生\~ 后面简单介绍下关于该模板的使用。使用该模板的好处：
#v(0.5em) // 正文格式20pt，段前段后0，这里先定义半个字符的间距，为了美观。
#set enum(indent: 2em) // 有序列表缩进2个字符长度
1. 不需要担心 Word 样式排版用的不熟练，模板样式按照 CUG 学位论文写作规范自动生成已经预先设定，仅需专注论文内容即可。
2. 拥有超快的渲染速度，不用担心后期一起渲染几十秒的问题（LaTex 老大哥不好意思哦\~）。
3. 预定义盲审、单双面混合打印模式，无需后续手动调整。
5. 支持 Typst Web APP 以及本地编辑模式，方便用户根据习惯自行挑选。

== 注意事项

各位是勇敢的尝鲜者，但是再次提醒哦~ 该模板是民间自制，有不被官网认可的风险，请自行斟酌使用。

最简单的确认方法，就是咨询各自的学长学姐，学院是否接受 PDF 格式的毕业论文，如果接受，可放心使用，样式排版与Word一致。

== 论文撰写引导

Typst 编辑模式有两种。一种是标记模式，一种是脚本模式。

怎么理解这个呢？Markdown 这样的标记语言的使用方式就是标记模式，我们可以成为 Markdown Like 模式。当然，这里是我们自己简称，别人怎么称呼还真不知道。脚本模式就类似于 LaTex 那样，直接一行一行的命令跟着内容在一块。

标记模式的好处是，我们可以使用简单的标记直接来划分内容：段落、列表、图表、引用还是公式或者代码。脚本模式的好处是，如果这个模板提供的样式不满足你个人的喜好，可以在遵循《写作规范》的前提下，调整样式。就类似上面导论那里。由于我们的论文要求段落行间距 20pt，段前段后 0 ，为了美观使用了`#v(0.5em)`以及`#set enum(indent: 2em)`。我们的脚本模式使用`#`表示脚本开始，如果有多条命令，后面可跟{}，例如`#{}`。

注意哦\~，我们这里的脚本模式是有作用域的。默认直接全局，在花括号内，仅作用于花括号。具体的可参考 README 中提供的文档说明以及本模板的代码。

后面小节简单的使用示例。

== 列表

=== 无序列表

- 无序列表项一
- 无序列表项二
  - 无序子列表项一
  - 无序子列表项二

=== 有序列表

+ 有序列表项一
+ 有序列表项二
  + 有序子列表项一
  + 有序子列表项二

=== 术语列表

/ 术语一: 术语解释
/ 术语二: 术语解释

== 图表

引用@tbl:timing，引用@tbl:timing-tlt，以及@fig:nju-logo。引用图表时，表格和图片分别需要加上 `tbl:`和`fig:` 前缀才能正常显示编号。

#align(center, (stack(dir: ltr)[
  #figure(
    table(
      align: center + horizon,
      columns: 4,
      [t], [1], [2], [3],
      [y], [0.3s], [0.4s], [0.8s],
    ),
    caption: [常规表],
  ) <timing>
][
  #h(50pt)
][
  #figure(
    table(
      columns: 4,
      stroke: none,
      table.hline(),
      [t], [1], [2], [3],
      table.hline(stroke: .5pt),
      [y], [0.3s], [0.4s], [0.8s],
      table.hline(),
    ),
    caption: [三线表],
  ) <timing-tlt>
]))

#figure(
  image("images/A-1.1.2校徽图案.jpg", width: 20%),
  caption: [图片测试],
) <nju-logo>


== 数学公式

可以像 Markdown 一样写行内公式 $x + y$，以及带编号的行间公式：

$ phi.alt := (1 + sqrt(5)) / 2 $ <ratio>

引用数学公式需要加上 `eqt:` 前缀，则由@eqt:ratio，我们有：

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

我们也可以通过 `<->` 标签来标识该行间公式不需要编号

$ y = integral_1^2 x^2 dif x $ <->

而后续数学公式仍然能正常编号。

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

== 参考文献

可以像这样引用参考文献：图书#[@蒋有绪1998]和会议#[@中国力学学会1990]。

== 代码块

代码块支持语法高亮。引用时需要加上 `lst:` @lst:code

#figure(
  ```py
  def add(x, y):
    return x + y
  ```,
  caption:[代码块],
) <code>

= 正　文

== 正文子标题

=== 正文子子标题

=== test

==== test2

== 2.2

=== 2.2.1

==== 2.2.1.1

=== 2.2.2

==== 2.2.2.1
@wang2022keypointbased @wang2022keypointbased @chen2023bsnet @xiao2023adnet
=== 2.2.3

==== 2.2.3.1
=== 2.2.4

==== 2.2.4.1

== 2.3
=== 2.3.1

==== 2.3.1.1

=== 2.3.2

==== 2.3.2.1

=== 2.3.3

==== 2.3.3.1

== 2.4

=== 2.4.1

==== 2.4.1.1

=== 2.4.2

==== 2.4.2.1

=== 2.4.3

==== 2.4.3.1

== 2.5

=== 2.5.1

==== 2.5.1.1

=== 2.5.2
正文内容

#figure(
  image("images/A-1.1.2校徽图案.jpg", width: 20%),
  caption: [图片测试],
) <nju-logo2>

#figure(
  image("images/A-1.1.2校徽图案.jpg", width: 20%),
  caption: [图片测试],
) <nju-log3>

// 中英双语参考文献
// 默认使用 gb-7714-2015-numeric 样式
#bilingual-bibliography(full: false, style: "gb-t-7714-2005-numeric-cug.csl")

// 致谢
#acknowledgement[
  感谢 Typst 非官方中文交流群的热心大佬的帮助 (797942860)，感谢 #link("https://github.com/nju-lug/modern-nju-thesis")[modern-nju-thesis]、#link("https://github.com/sysu/better-thesis")[better-thesis]、#link("https://github.com/hitszosa/universal-hit-thesis")[HIT-Thesis-Typst] 模板提供的代码思路，感谢 #link("https://gist.github.com/csimide")[csimide] 和 #link("https://github.com/OrangeX4")[OrangeX4] 提供的中英双语参考文献实现.
]

// 附录
// #show: appendix

// = 附录

// == 附录子标题

// === 附录子子标题

// 附录内容，这里也可以加入图片，例如@fig:appendix-img。

// #figure(
//   image("images/nju-emblem.svg", width: 20%),
//   caption: [图片测试],
// ) <appendix-img>


// // 正文结束标志，不可缺少
// // 这里放在附录后面，使得页码能正确计数
#mainmatter-end()