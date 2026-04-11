#import "@preview/modern-sjtu-report:0.2.0": *
#import "@preview/cuti:0.4.0": fakeitalic, show-cn-fakebold
#import "@preview/lilaq:0.5.0" as lq

#let course-name = "某交大金课"
#let course-name-en = "Some Random Course"
#let experiment-name = "实验名称"

// 可选预设：blue, red, shsmu，custom
#let ident-color = "blue"
// 若ident-color为三预设之一则以下无效
#let logo-path = "path/to/logo"
#let name-path = "path/to/name"
#let header-path = "path/to/header"
#let org-name = "name"

#let info-items = (
  ([专#h(2em)业], [某专业]),
  ([学生姓名], [某学生]),
  ([学生学号], [1234567890]),
  ([教#h(2em)师], [某教师]),
  ([自定义键], [自定义值]),
)

// 如果出现了字体问题可以修改此处的字体列表
#let cover-fonts = ("Times New Roman", "Kaiti SC", "KaiTi", "Noto Serif SC", "SimSun")
#let article-fonts = ("Times New Roman", "Noto Serif SC", "Songti SC", "SimSun")
#let code-fonts = ("Consolas", "Ubuntu Mono", "Menlo", "Courier New", "Courier", "Noto Serif SC")

// show-cn-fakebold可以在字体自身仅单字重时通过描边的方式实现伪粗体效果
// Songti SC, Noto Serif SC等都是有原生粗体支持的，不需要额外操作
// 如果使用的是SimSun，KaiTi等没有原生粗体支持的字体，可以将下行取消注释
// #show: show-cn-fakebold


#make-cover(
  course-name: course-name,
  course-name-en: course-name-en,
  info-items: info-items,
  ident-color: ident-color,
  cover-fonts: cover-fonts,
  logo-path: logo-path,
  name-path: name-path,
  org-name: org-name,
)

#show: general-layout.with(
  ident-color: ident-color,
  header-logo: true,
  experiment-name: experiment-name,
  article-fonts: article-fonts,
  code-fonts: code-fonts,
  header-path: header-path,
)

#make-title(name: experiment-name)

= 中文示例

相聚在东海之滨，吸取知识的甘泉。交大，交大，学府庄严，师生切磋共涉艰险。为飞跃而求实，为创业而攻坚。同学们，同学们！振兴中华，振兴中华。宏图在胸，重任在肩。

迎向那真理之光，扬起青春的风帆。交大，交大，群英汇聚，同舟共济远航彼岸。为自强而奋发，为人类多贡献。同学们，同学们！饮水思源，饮水思源。母校的光荣，长存心田。

= English Example

#lorem(25)

#lorem(40)

= Typst 常见语法与样式实例

== 基础语法

落霞与孤#h(2em)鹜齐飞，*秋水共* #fakeitalic("长天一色")。 // 中文的斜体同样是cuti提供的伪斜体实现，并不推荐大规模使用

#underline[The quick brown] #strike[fox] jumps over _the lazy_ d#super[o]#sub[g].

=== 三级标题
==== 四级标题
===== 五级标题
====== 六级标题

== 列表

#lorem(20)

+ 有序列表
  - 的无序子列表
    + 的有序子子列表

#lorem(30)

== 数学

#lorem(30)

$
  x_"1,2" = (- b plus.minus sqrt(b^2 - 4 a c)) / (2 a)
$

而这是一个行内数学公式 $e^(i pi) + 1 = 0.$

== 图表

#lorem(45)

#figure(
  table(
    columns: (auto, auto, auto),
    table.header([Column1], [Column2], [Columns3]),
    [第一行], [100], [$x + y$],
    [row2], [200], [$1/2$],
    [_The third row_], [30000000000000], [$integral e^x d x$],
  ),
  caption: "一个三线表",
)

#lorem(50)

#figure(
  lq.diagram(
    title: [Example Plot],
    lq.plot((0, 1, 2, 3, 4), (3, 5, 4, 2, 3), mark: "s", label: [A], stroke: none),
    lq.plot(
      (0, 1, 2, 3, 4),
      x => 2 * calc.cos(x) + 3,
      mark: "o",
      label: [B],
    ),
  ),
  caption: [A matplotlib style plot created by lilaq],
)

#lorem(25)

== 代码

#lorem(30) 这是一个行内代码块 ```python print("Hello, World!")``` (有高亮) `print("Hello World!")` (无高亮)。

```cpp
#include <iostream>
using namespace std;
int main() {
    cout << "Hello, World!" << endl;
    return 0; // 代码中的中文
}
```

#lorem(20)

#figure(
  kind: "pseudocode-list",
  supplement: pseudocode-list,
  pseudocode-list[
    + do something
    + do something else
    + *while* still something to do
      + do even more
      + *if* not done yet *then*
        + wait a bit
        + resume working
      + *else*
        + go home
      + *end*
    + *end*
  ],
  caption: "伪代码示例",
)

#lorem(20) @vaswani2023attentionneed @reference


#bibliography("ref.bib", title: "参考文献")
