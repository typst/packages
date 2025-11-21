#import "@preview/unofficial-tyut-thesis:0.1.1": documentclass

#let (
  doc,
  cover,
  decl,
  abstract,
  abstract-en,
  preface,
  outline-page,
  mainmatter,
  gloss,
  set-glossary-table,
  bilingual-bibliography,
  acknowledgement,
  twoside,
  appendix,
) = documentclass(
  // anonymous: true, // 需要匿名可以打开此选项
  // twoside: true, // 打印纸质版时可以打开此选项
  info: (
    title: ("基于 Typst 的太原理工大学论文模板", "——非官方版本"),
    title-en: " A Typst Template for TYUT Thesis - Unofficial Edition",
    author: "爱因斯坦",
    student-id: "11001101010086",
    department: "XX学院",
    session: "20XX",
    major: "XX专业",
    class: "XX班",
    supervisor: ("张三", "教授"),
    submit-date: datetime.today(),
    // submit-date: datetime(year: 2025, month: 1, day: 28)
    // author-sign-date: datetime.today(), // 承诺书作者签名日期
    // supervisor-sign-date: datetime(year: 1997, month: 1, day:1), // 承诺书导师签名日期
  ),
  bibliography: bibliography.with("references.bib"),
  // font: "KaiTi", // Main Font
  // reference-font: ("Times New Roman", "SimSun"),
)

#show: doc

#cover()

// #decl(
//   author-signature: place(
//     dy: -1em,
//     dx: 1em,
//     image("imgs/author-signature.jpg", height: 2em)),
//   supervisor-signature: place(
//     dy: -1em,
//     dx: 1em,
//     image("imgs/author-signature.jpg", height: 2em)),
//     )
#decl()

#show: preface

#abstract(keywords: ("Typst", "TYUT", "Template", "Thesis", "毕业论文"))[
  本项目是基于 Typst 制作的一款适用于太原理工大学本科毕设论文的模板，注意是非官方模板，因此不被承认的风险，请谨慎使用。

  使用本项目需要具备基本的 Typst 使用知识，学习大概需要1小时，需要阅读#link("https://typst.app/docs/tutorial")[#text(fill: blue)[#underline[官方入门教程]]]。
]

#abstract-en(keywords: ("Typst", "TYUT", "Template", "Thesis"))[
  This project is based on Typst to produce a template for undergraduate BSc thesis of Taiyuan University of Technology, note that it is an unofficial template, so the risk of not being recognized, please use with caution.

  Using this project requires basic knowledge of using Typst, which takes about 1 hour to learn and requires reading #link("https://typst.app/docs/tutorial")[#text(fill: blue)[#underline[Official Getting Started Tutorial]]].
]

#outline-page()


#pagebreak()

#show: mainmatter

= 绪论
== 基本书写

直接输入文字即可。需要注意，如果两行之间没有空行，
像现在这样，会自动合并为一行。如果需要换行，
则需要多打一个空行。

像现在这样。

== 无序列表
可以通过以下方式添加无续列表：

- 表项1
- 表项2
  - 表项3
  - 表项4

== 有序列表

通过以下方式添加有续列表：

+ 表项1
+ 表项2
  + 表项3
  + 表项4
+ 表项5

== 术语

#set-glossary-table((
  (
    key: "urllc",
    short: "URLLC",
    long: "Ultra-Reliable and Low Latency Communications",
    description: "超可靠低延迟通信",
  ),
  (
    key: "api",
    short: "API",
    long: "Application Program Interface",
    description: "应用程序接口",
  ),
));

如果论文中出现缩写，推荐使用 `gloss` 进行管理，先将相关内容放入到 `set-glossary-table` 中，之后再使用，例如，第一次出现#gloss("urllc")时，会写出对应的中文内容、英文全称和缩写，之后再出现
#gloss("urllc")时，则只出现缩写。再举一个例子：#gloss("api")应当是全称，#gloss("api")和#gloss("api")应当只显示缩写。

如果引用了列表中没有出现的术语，则会出现红色警告，例如：#gloss("vanet")

== 图片和表格

引用@tbl:timing，引用@tbl:timing-tlt，以及@fig:some-figure。引用图表时，表格和图片分别需要加上 `tbl:`和`fig:` 前缀才能正常显示编号。

#align(
  center,
  (
    stack(dir: ltr)[
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
    ]
  ),
)

#figure(
  image("imgs/author-signature.jpg", width: 50%),
  numbering: none,
  caption: [图片测试],
) <some-figure>

#figure(
  [
    #set text(font: ("Times New Roman", "SimHei"), size: 10pt)
    #set stack(dir: ttb, spacing: 0.5em)
    #set image(height: 2cm)
    #grid(
      columns: 2,
      gutter: 1em,
      stack(image("imgs/author-signature.jpg"), [(a) 子图1]), stack(image("imgs/author-signature.jpg"), [(b) 子图2]),
      stack(image("imgs/author-signature.jpg"), [(c) 子图3]), stack(image("imgs/author-signature.jpg"), [(d) 子图4]),
    )],
  caption: [多图示例],
) <multiple-figures>

@fig:multiple-figures 是一个多图示范的例子。

== 引用

直接引用相关 `bib` 文件中的条目即可，如这里引用了@deepLearn。中文引用@蒋有绪1998 @中国力学学会1990 也可以正常显示。


= 数学公式与代码

== 数学公式示例

我们可以利用求根公式来得到一般形式的一元二次方程：$a x^2 + b x + c = 0$ 的解，其具体内容为（如果不希望公式后边段落有缩进，可以加入 `box`）：
#box[$ x_(1,2) = (-b plus.minus sqrt(b^2 - 4 a c)) / (2 a), $ <root-finder>]
其中， $a, b$ 和 $c$ 为原始方程的系数。根据@eqt:root-finder, 可以看到，每个一元二次方程，都有两个解，不过有时候两个根可能相等，有时候可能会出现复数根。

根据相关公式，我们可以得到 $e^x$ 的泰勒展示：

$
  e^x= sum_(i=0)^oo x^i / i!.
$

如果某个公式不需要编号，可以加入 `<->` 标签。如：

$
  integral.cont sqrt(x^2+y^2) dif x dif y.
$ <->

但是后续公式会自动继续编号：

$
  e^(i pi) + 1 = 0.
$

更多数学公式内容，参考#text(fill: blue)[#underline[#link("https://typst.app/docs/reference/math/")[*官方文档*]]]。也可使用#text(fill: blue)[#underline[#link("https://typerino.com/")[*在线公式编辑器*]]]进行公式编辑。

== 代码

=== 原始效果

行内代码块需要包裹在反引号内，如 `http`，块级代码则需要以三个反引号包裹，后面加上语言名称（可选），如：

#figure(
  ```cpp
  #include <vector>
  #include <iostream>

  using std::cout;
  using std::endl;
  using std::vector;

  int main() {
    vector<int> v{10, 3};
    for (auto i : v) {
      cout << i << endl;
    }
    return 0;
  }
  ```,
  caption: [代码块展示],
) <cpp-code>

如果需要引用代码，需要加上`lst`，如这里引用了@lst:cpp-code。

=== 添加行号

如果需要添加行号，推荐使用 `@preview/zebraw` 包

#import "@preview/zebraw:0.5.5": zebraw
#show: zebraw

#figure(
  ```haskell
  import Data.List (partition)

  qsort :: Ord a => [a] -> [a] -> [a]
  qsort [] = []
  qsort (x:xs) = qsort ls ++ [x] ++ qsort rs
   where
    (ls, rs) = partition (<x) xs
  ```,
  caption: [Haskell 代码中的快速排序],
)

==== 四级标题不会出现在目录中

这是四级标题下的内容。


=== 伪代码

伪代码可以用 `algo` 库：

#import "@preview/algo:0.3.6": algo, i, d, comment, code

#figure(
  algo(
    title: "Fib",
    parameters: ("n",),
  )[
    if $n < 0$:#i\ // use #i to indent the following lines
    return null#d\ // use #d to dedent the following lines
    if $n = 0$ or $n = 1$:#i #comment[you can also]\
    return $n$#d #comment[add comments!]\
    return #smallcaps("Fib")$(n-1) +$ #smallcaps("Fib")$(n-2)$
  ],
  caption: [斐波那契数列],
  kind: "algo",
  supplement: "算法",
) <fib>

从@alg:fib 中可以看到，斐波那契数列可以用递归的方式进行计算。


// 参考文献
#bilingual-bibliography(full: false)


#acknowledgement[
  作者在设计（论文）期间都是在×××教授全面、具体指导下完成进行的。×老师渊博的学识、敏锐的思维、民主而严谨的作风使学生受益非浅，并终生难忘。

  感谢×××副教授等在毕业设计工作中给予的帮助。

  感谢我的学友和朋友对我的关心和帮助。

]

#show: appendix

// 手动分页
#if twoside {
  pagebreak() + " "
}

= 关于网络演算的基本说明

== 到达曲线的说明

$
  lr(angle.l f, alpha angle.r) = sup_(0 <= t <= s) [f(x-t) + f(t) <= alpha]
$ <appendix-equation>

#figure(
  image("imgs/author-signature.jpg"),
  caption: [附录图片],
) <appendix-figure>

再试试表格。

#figure(
  table(
    align: center,
    columns: 3,
    [a], [b], [c],
    [d], [e], [f],
  ),
  caption: [附录表格],
) <appendix-table>

附录中的公式引用：@eqt:appendix-equation，附录中的图片引用：@fig:appendix-figure，附录中的表格引用：@tbl:appendix-table。

= 一些证明细节

== 另外的数学公式

$
  integral_(-oo)^oo x dif x = 0
$ <appendix-equation2>

#figure(
  image("imgs/author-signature.jpg"),
  caption: [附录图片],
) <appendix-figure2>

附录中的公式引用：@eqt:appendix-equation2，附录中的图片引用：@fig:appendix-figure2.
