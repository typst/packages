#import "@preview/easy-paper:0.2.0": *

#show: project.with(
  title: "EasyPaper 模板使用示例",
  author: "张三",
  date: auto,
  abstract: [
    本文档展示了 EasyPaper 模板的主要功能，包括题目框、解答框、三线表格、数学公式等学术组件。
  ],
  keywords: ("Typst", "模板", "学术写作"),
)


= 基本功能

EasyPaper@EasyPaper 是基于 SimplePaper@SimplePaper 改进的模板，具有单文件设计、系统字体兼容、学术组件丰富等特点。

== 文本格式

支持 *粗体*、_斜体_ 和 `inline code`。列表功能：
- 无序列表项
  - 嵌套项目
    - 嵌套列表采用不同符号
+ 第二步
  + 当然你也可以继续嵌套
    + 再嵌套
  - 也可以混合嵌套
+ 第三步

/ 定义: 你还可以定义一个术语，并给出解释。

== 代码块

```python
def factorial(n):
    return 1 if n <= 1 else n * factorial(n-1)
print(factorial(5))  # 输出: 120
```

= 学术组件

== 题目与解答

#problem[
  求 $f(x) = x^2 - 4x + 3$ 的最小值。
]

#solution[
  配方得：
  $
    f(x) = (x-2)^2 - 1
  $

  当 $x = 2$ 时，函数取最小值 $-1$。
]

#summary[
  本题通过配方求解二次函数的最小值，体现了配方在数学问题中的应用。
]

== 数学公式

重要公式会自动编号：
$
  pardiff(f(x,y), x) = pardiff("", x)((x^2+y^2) / 2) = x
$ <eq:partial>

辅助公式不编号：
$
  sin^2(x) + cos^2(x) = 1
$

== 图表功能

#figure(
  image("./assets/example.png", width: 80%),
  caption: [明代永宁宣抚司及永宁卫疆域图],
) <fig:example>

表格会自动使用三线表格式：
#figure(
  table(
    columns: 4,
    [*项目*], [*数值*], [*单位*], [*备注*],
    [长度], [10.5], [cm], [注释],
    [质量], [2.3], [kg], [注释],
    [温度], [25.0], [°C], [注释],
  ),
  caption: [实验数据表],
) <tab:data>

下面的文字是引用功能，可以引用@fig:example，@eq:partial 和@tab:data。支持外部#link("https://typst.app")[链接]和脚注#footnote[这是脚注内容]。

#bibliography("ref.bib")
