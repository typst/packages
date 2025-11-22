// 导入 preview 中的固定版本 modern-cqut-thesis:0.1.0 进行编译
#import "@preview/modern-cqut-thesis:0.1.0": *

// 从 lib.typ 导入并编译, 如果你要修改这个模板格式并编译请务必注释上方 @preview 
// 并导入下方 lib.typ 进行编译, 因默认优先级 @preview 更高, 直接从 typst 缓存目录（根目录进行编译）
// #import "../lib.typ": *

#let (
  // 布局函数
  twoside, doc, preface, mainmatter, mainmatter-end, appendix,
  // 页面函数
  fonts-display-page, cover, decl-page, abstract, abstract-en, bilingual-bibliography,
  outline-page, list-of-figures, list-of-tables, notation, acknowledgement,
) = documentclass(doctype: "bachelor",
  // doctype: "bachelor",  // "bachelor" | "master" | "doctor" | "postdoc", 文档类型，默认为本科生 bachelor
  // degree: "academic",  // "academic" | "professional", 学位类型，默认为学术型 academic
  // anonymous: true,  // 盲审模式
  twoside: true,  // 双面模式，会加入空白页，便于打印
  // 可自定义字体，先英文字体后中文字体，应传入「宋体」、「黑体」、「楷体」、「仿宋」、「等宽」
  // fonts: (楷体: ("Times New Roman", "FZKai-Z03S")),
  nl-cover: false,  // 国家图书馆封面
  de-cover: false,   // 设计封面
  info: (
    title: ("基于 Typst 的", "重庆理工大学学位论文"),
    title-en: "My Title in English",
    grade: "20XX",
    student-id: "1234567890",
    author: "张三",
    author-en: "Ming Xing",
    department: "某学院",
    department-en: "School of Chemistry and Chemical Engineering",
    major: "某专业",
    major-en: "Chemistry",
    supervisor: ("李四", "教授"),
    supervisor-en: "Professor My Supervisor",
    // supervisor-ii: ("王五", "副教授"),
    // supervisor-ii-en: "Professor My Supervisor",
    submit-date: datetime.today(),
  ),
  // 参考文献源
  bibliography: bibliography.with("thesis.bib"),
)

// 文稿设置
#show: doc


// 一个别的引用样式，打印时应该注释掉
#show cite: custom-cite


// 封面页
#cover()


// // 字体展示测试页
// #fonts-display-page()


// 声明页
#decl-page()


// 前言
#show: preface


// 中文摘要
#abstract(
  keywords: ("关键词1", "关键词2", "关键词3", "关键词4")
)[
  中文摘要
]


// 英文摘要
#abstract-en(
  keywords: ("Keyword1", "Keyword2", "Keyword3", "Keyword4")
)[
  English abstract
]


// 目录
#outline-page()


// 手动分页
#if twoside {
  pagebreak() + " "
}


// 插图目录
// #list-of-figures()


// 表格目录
// #list-of-tables()


// 正文
#show: mainmatter


// // 符号表
// #notation[
//   / DFT: 密度泛函理论 (Density functional theory)
//   / DMRG: 密度矩阵重正化群密度矩阵重正化群密度矩阵重正化群 (Density-Matrix Reformation-Group)
// ]



// ------------------------------------------- //



= 列　表

== 无序列表

- 无序列表项一
- 无序列表项二
  - 无序子列表项一
  - 无序子列表项二

== 有序列表

+ 有序列表项一
+ 有序列表项二
  + 有序子列表项一
  + 有序子列表项二

== 术语列表

/ 术语一: 术语解释
/ 术语二: 术语解释


// 手动分页
#if twoside {
  pagebreak() + " "
}



// ------------------------------------------- //



= 图　表

== 格式化的图标
引用@tbl:timing，引用@tbl:timing-tlt，以及@fig:cqut-logo。引用图表时，表格和图片分别需要加上 `tbl:`和`fig:` 前缀才能正常显示编号。

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

== 图片
#figure(
  image("logos/1.svg", width: 20%),
  caption: [图片测试],
) <cqut-logo>


// 手动分页
#if twoside {
  pagebreak() + " "
}




// ------------------------------------------- //



= 数　学

可以像 Markdown 一样写行内公式 $x + y$，以及带编号的行间公式：

$ phi.alt := (1 + sqrt(5)) / 2 $ <ratio>

引用数学公式需要加上 `eqt:` 前缀，则由@eqt:ratio，我们有：

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

我们也可以通过 `<->` 标签来标识该行间公式不需要编号

$ y = integral_1^2 x^2 dif x $ <->

而后续数学公式仍然能正常编号。

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

== 参考文献

可以像这样引用参考文献 @丁文祥2000：图书#[@蒋有绪1998]和会议#[@中国力学学会1990]。

== 代码块

代码块支持语法高亮。引用时需要加上 `lst:` @lst:code

#figure(
  ```py
  def add(x, y):
    return x + y
  ```,
  caption:[代码块],
) <code>


// 手动分页
#if twoside {
  pagebreak() + " "
}



// ------------------------------------------- //



= 化　学

#align(center, (stack(dir: ttb)[
  #figure(
    table(
      align: center + horizon,
      columns: 2,
      [化学式], [示例],
      [$ #ca("H2O") $], [水],
      [$ #ca("NH3") $], [氨],
      [$ #ca("CO2") $], [二氧化碳],
      [$ #ca("H+") $], [氢离子],
      [$ #ca("Ca(H2PO4)2") $], [磷酸氢钙],
      [$ #ca("NCl2") $], [二氯化氮],
      [$ #ca("H^1") $], [氢同位素H-1],
      [$ #ca("H^2") $], [氘H-2],
      [$ #ca("H^3") $], [氚H-3],
      [$ #ca("C^12") $], [碳-12],
      [$ #ca("C^14") $], [碳-14],
      [$ #ca("O^16") $], [氧-16],
      [$ #ca("O^18") $], [氧-18],
    ),
    caption: [化学式示例表],
  ) <chem>
][
  #v(100pt)
][
  #figure(
    table(
      columns: 2,
      stroke: none,
      table.hline(),
      [$ #cb("2KMnO4 = K2MnO4 + MnO2 + O2>", a: $Delta$) $], [氧化还原反应],
      [$ #cb("N2 + 3H2 <=> 2NH3", a: "高温加热", b: "催化剂") $], [合成氨反应],
      [$ #cb("2H2O <=> 2H2 + O2", a: "电解", b: "电流") $], [水的电解反应],
      [$ #cb("H2O + D2O -> 2HDO", a: "同位素交换反应") $], [氘水反应],
      [$ #cb("BaCl2 + Na2SO4 -> BaSO4(s)< + 2NaCl", a: "沉淀反应") $], [沉淀反应],
    ),
    caption: [化学方程式示例],
  ) <chem-equa>
]))



// 手动分页
#if twoside {
  pagebreak() + " "
}



// ------------------------------------------- //



= 定　理

== 定理环境
#show: thmrules.with(qed-symbol: $square$)

#theorem("Euclid")[
  There are infinitely many primes.
]

#definition[
  A natural number is called a #highlight[_prime number_] if it is greater
  than 1 and cannot be written as the product of two smaller natural numbers.
]

#example[
  The numbers $2$, $3$, and $17$ are prime.
  @cor_largest_prime shows that this list is not exhaustive!
]

#proof[
  Suppose to the contrary that $p_1, p_2, dots, p_n$ is a finite enumeration
  of all primes. Set $P = p_1 p_2 dots p_n$. Since $P + 1$ is not in our list,
  it cannot be prime. Thus, some prime factor $p_j$ divides $P + 1$.  Since
  $p_j$ also divides $P$, it must divide the difference $(P + 1) - P = 1$, a
  contradiction.
]

#corollary[
  There is no largest prime number.
] <cor_largest_prime>

#corollary[
  There are infinitely many composite numbers.
]

#theorem[
  There are arbitrarily long stretches of composite numbers.
]

#proof[
  For any $n > 2$, consider $
    n! + 2, quad n! + 3, quad ..., quad n! + n 
  $
]


// // 手动分页
// #if twoside {
//   pagebreak() + " "
// }



// ------------------------------------------- //



// 中英双语参考文献
// 默认使用 gb-7714-2015-numeric 样式
#bilingual-bibliography(full: true)


// 手动分页
#if twoside {
  pagebreak() + " "
}


// 一个别的引用样式
// #bibliography(
//   "./ref.bib",
//   title: "References",
//   style: "ieee"
// )



// ------------------------------------------- //



// 致谢
#acknowledgement[
  感谢 XXX，感谢 XXX 模板。
]


// 手动分页
#if twoside {
  pagebreak() + " "
}



// ------------------------------------------- //



// 附录
#show: appendix

= 附录

== 附录子标题

=== 附录子子标题

附录内容，这里也可以加入图片，例如@fig:appendix-img。

#figure(
  image("logos/1.svg", width: 20%),
  caption: [图片测试],
) <appendix-img>


// 手动分页
#if twoside {
  pagebreak() + " "
}


// 正文结束标志，不可缺少
// 这里放在附录后面，使得页码能正确计数
#mainmatter-end()