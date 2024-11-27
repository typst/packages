// 在线模式
// #import "@preview/cug-thesis-typst:0.1.0": documentclass, indent

// 本地模式
#import "/lib.typ": documentclass, indent

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

// 符号表
// #notation[
//   / DFT: 密度泛函理论 (Density functional theory)
//   / DMRG: 密度矩阵重正化群密度矩阵重正化群密度矩阵重正化群 (Density-Matrix Reformation-Group)
// ]

#include "chapters/intro.typ"

#include "chapters/chapter1.typ"

// // 手动分页
// #if twoside {
//   pagebreak() + " "
// }

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