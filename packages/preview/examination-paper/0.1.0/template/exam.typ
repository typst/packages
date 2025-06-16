#import "@preview/examination-paper:0.1.0": documentclass

#let (
  mainmatter,
  title,
  questionHeader,
  score-table,
  choiceQuestion,
  fillQuestion,
  trueFalseQuestion,
  question,
) = documentclass(
  info: (
    school: "布鲁斯特大学",
    subject: "高等数学",
    major: "XX专业",
    // class: "勇往直前班",
    // time: [10:00--12:00],
    date: datetime(year: 2025, day: 20, month: 6),
    duration: [120分钟],
    // columns: 2,
  ),
  margin: (
    top: 3cm,
    bottom: 3cm,
    outside: 2cm,
    inside: 3.2cm,
  ),
  student-info: ("学院", "专业", "班级", "姓名", "学号"),
  font-size: 13pt,
  type: "A卷",
  method: "闭卷",
  random: true,
  frame: true,
  // choice-question-breakable: false,
  // frame-stroke: (thickness: 0.5pt, dash: "dashed", paint: black),
  // double-page: false,
  // show-answer: true,
  // seed: 1,
  // answer-color: maroon,
  // mono-font: ("Cascadia Code", "LXGW WenKai Mono GB"),
  // mono-font-size: 13pt,
  // title-font: ("Times New Roman", "SimHei"),
  // title-underline: false,
  // title-font-size: 1.8em,
)

#show: mainmatter

#title()

#score-table()

#questionHeader[选择题（每空2分，共30分）]

#choiceQuestion((
  ("以下内容哪个是真的？", ("地球是方的", ("地球是圆的", true), "月亮自己发光", "太阳比地球小")),
  (
    [以下内容中，哪一个是$e^x$的泰勒展开公式？提示：一个函数的泰勒展开是一个很重要的概念哦],
    (
      ([$display(e^x= sum_(i=0)^oo x^(2i + 1) / (2i + 1)!)$], true),
      ([$display(e^x= sum_(i=0)^oo x^(2i + 1) / (2i + 1)!)$], true),
      ([$display(e^x= sum_(i=0)^oo x^(2i + 1) / (2i + 1)!)$], true),
      ([$display(e^x= sum_(i=0)^oo x^(2i + 1) / (2i + 1)!)$], true),
    ),
    (inset: 0.8em),
  ),
  (
    [以下内容中，哪一个是$e^x$的泰勒展开公式？提示：一个函数的泰勒展开是一个很重要的概念哦],
    (
      [$display(e^x= sum_(i=0)^oo x^i / i!)$],
      [$display(e^x= sum_(i=-oo)^oo x^i / i!)$],
      [$display(e^x= sum_(i=0)^oo x^(2i) / (2i)!)$],
      ([$display(e^x= sum_(i=0)^oo x^(2i + 1) / (2i + 1)!)$], true),
    ),
    (inset: 0.8em),
  ),
  (
    [以下内容中，哪一个是$e^x$的泰勒展开公式？提示：一个函数的泰勒展开是一个很重要的概念哦],
    (
      [$display(e^x= sum_(i=0)^oo x^i / i!)$],
      [$display(e^x= sum_(i=-oo)^oo x^i / i!)$],
      [$display(e^x= sum_(i=0)^oo x^(2i) / (2i)!)$],
      ([$display(e^x= sum_(i=0)^oo x^(2i + 1) / (2i + 1)!)$], true),
    ),
    (inset: 0.8em),
  ),
  (
    [以下内容中，哪一个是$e^x$的泰勒展开公式？提示：一个函数的泰勒展开是一个很重要的概念哦],
    (
      [$display(e^x= sum_(i=0)^oo x^i / i!)$],
      [$display(e^x= sum_(i=-oo)^oo x^i / i!)$],
      [$display(e^x= sum_(i=0)^oo x^(2i) / (2i)!)$],
      ([$display(e^x= sum_(i=0)^oo x^(2i + 1) / (2i + 1)!)$], true),
    ),
    (inset: 0.8em),
  ),
  (
    [以下内容中，哪一个是$e^x$的泰勒展开公式？提示：一个函数的泰勒展开是一个很重要的概念哦],
    (
      [$display(e^x= sum_(i=0)^oo x^i / i!)$],
      [$display(e^x= sum_(i=-oo)^oo x^i / i!)$],
      [$display(e^x= sum_(i=0)^oo x^(2i) / (2i)!)$],
      ([$display(e^x= sum_(i=0)^oo x^(2i + 1) / (2i + 1)!)$], true),
    ),
    (inset: 0.8em),
  ),
  (
    [这是一个很短的题目。],
    (
      ([选这个], true),
      [别选],
      [别选],
      [别选],
    ),
  ),
  (
    [这是一个很短的题目。],
    (
      ([选这个], true),
      [别选],
      [别选],
      [别选],
    ),
  ),
  (
    [这是一个很短的题目。],
    (
      ([选这个], true),
      [别选],
      [别选],
      [别选],
    ),
  ),
  (
    [这是一个很短的题目。],
    (
      ([选这个], true),
      [别选],
      [别选],
      [别选],
    ),
  ),
  (
    [这是一个很短的题目。],
    (
      ([选这个], true),
      [别选],
      [别选],
      [别选],
    ),
  ),
  (
    [这是一个很短的题目。],
    (
      ([选这个], true),
      [别选],
      [别选],
      [别选],
    ),
  ),
  (
    [这是一个很短的题目。],
    (
      ([选这个], true),
      [别选],
      [别选],
      [别选],
    ),
  ),
  (
    [这是一个很短的题目。],
    (
      ([选这个], true),
      [别选],
      [别选],
      [别选],
    ),
  ),
  (
    [这是一个很短的题目。],
    (
      ([选这个], true),
      [别选],
      [别选],
      [别选],
    ),
  ),
))


#questionHeader[填空题（每空1分，共10分）]

#fillQuestion(
  (
    ([`Java`中，控制循环的关键字包括：], ([`break`], 3cm), [、], ([`continue`], 3cm), [和], ([`goto`], 3cm), [。]),
    ([`Java`中，控制循环的关键字包括：], ([`break`], 3cm), [、], ([`continue`], 3cm), [和], ([`goto`], 3cm), [。]),
    ("这是第一题", ("这是答案", 3cm), "这是后续内容。"),
    ("这是第一题", ("这是答案", 3cm), "这是后续内容。"),
    ("这是第一题", ("这是答案", 3cm), "这是后续内容。"),
    ([递归程序的含义是：], ([函数的自我调用], 4cm), [。]),
    ([递归程序的含义是：], ([函数的自我调用], 4cm), [。]),
    ([递归程序的含义是：], ([函数的自我调用], 4cm), [。]),
    ([`Java`中，控制循环的关键字包括：], ([`break`], 3cm), [、], ([`continue`], 3cm), [和], ([`goto`], 3cm), [。]),
    ([`Java`中，控制循环的关键字包括：], ([`break`], 3cm), [、], ([`continue`], 3cm), [和], ([`goto`], 3cm), [。]),
  ),
  spacing: 1.5em,
  leading: 1.5em,
)

#questionHeader[判断题（每题1分，共10分）]

#trueFalseQuestion(
  (
    ([`C++` 中，```cpp #include <iostream>``` 是用来引入输入输出流库的。#lorem(10)], true),
    ([在 `C++` 中，`int a = 5.5`; 会将 $5.5$ 转换为整数 $5$。#lorem(10)], true),
    ([`C++` 中，```cpp std::vector``` 是一种固定大小的数组。#lorem(10)], false),
    ([`C++` 中，```cpp #include <iostream>``` 是用来引入输入输出流库的。#lorem(10)], true),
    ([在 `C++` 中，`int a = 5.5`; 会将 $5.5$ 转换为整数 $5$。#lorem(10)], true),
    ([`C++` 中，```cpp std::vector``` 是一种固定大小的数组。#lorem(10)], false),
    ([`C++` 中，```cpp #include <iostream>``` 是用来引入输入输出流库的。#lorem(10)], true),
    ([在 `C++` 中，`int a = 5.5`; 会将 $5.5$ 转换为整数 $5$。#lorem(10)], true),
    ([`C++` 中，```cpp std::vector``` 是一种固定大小的数组。#lorem(10)], false),
    ([`C++` 中，```cpp std::vector``` 是一种固定大小的数组。#lorem(10)], false),
  ),
  spacing: 1.2em,
  leading: 1em,
)

#pagebreak()

#questionHeader[简答题（每题5分，共10分）]

#question(
  question: [请谈谈你对于函数式编程的理解。],
  answer: [
    *函数式编程（Functional Programming，简称 FP）*是一种编程范式，它将计算视为数学函数的求值，并避免使用可变状态和副作用。以下是函数式编程的核心定义和特点：
    输出仅依赖输入参数，没有副作用（不会修改外部状态）。不可变性（Immutability）高阶函数（Higher-Order Functions）函数组合（Function Composition）惰性求值、无状态（Statelessness） 避免共享状态，减少并发编程中的问题。
  ],
  spacing: 40%,
)

#question(question: [请谈谈你对于`C++`中移动语义的理解。])
#pagebreak()

#questionHeader[程序阅读题（每题10分，共20分）]
#question(
  question: [阅读以下程序，解释并说明其输出结果。],
  body: [
    ```
    #include <iostream>
    int main() {
      std::cout << "Hello, world!" << std::endl;
      return 0;
    }
    ```
  ],
  answer: [输出 `Hello, world!`

    #lorem(100)
  ],
)

#pagebreak()

#question(
  question: [已知在$triangle A B C$中，$A + B = 3C, 2 sin(A-C) = sin B$],
  body: [
    #set enum(numbering: "(1)")
    #grid(
      columns: (1fr, 1fr),
      align: (left, right),
      [
        + 求 $sin A$;
        + 设 $A B = 5$, 求 $A B$ 边上的高.
      ],
      [
        #import "@preview/cetz:0.4.0": canvas, draw
        #import "@preview/cetz-plot:0.1.2": plot

        #let style = (stroke: black, fill: rgb(0, 0, 200, 75))

        #let f1(x) = calc.sin(x)
        #let fn = (
          ($ x - x^3"/"3! $, x => x - calc.pow(x, 3) / 6),
          ($ x - x^3"/"3! - x^5"/"5! $, x => x - calc.pow(x, 3) / 6 + calc.pow(x, 5) / 120),
          (
            $ x - x^3"/"3! - x^5"/"5! - x^7"/"7! $,
            x => x - calc.pow(x, 3) / 6 + calc.pow(x, 5) / 120 - calc.pow(x, 7) / 5040,
          ),
        )

        #set text(size: 10pt)
        #canvas({
          import draw: *

          // Set-up a thin axis style
          set-style(
            axes: (stroke: .5pt, tick: (stroke: .5pt)),
            legend: none,
          )

          plot.plot(
            size: (5, 3),
            x-tick-step: calc.pi / 2,
            x-format: plot.formats.multiple-of,
            y-tick-step: 2,
            y-min: -2.5,
            y-max: 2.5,
            {
              let domain = (-1.1 * calc.pi, +1.1 * calc.pi)

              for (title, f) in fn {
                plot.add-fill-between(f, f1, domain: domain, style: (stroke: none), label: none)
              }
              plot.add(f1, domain: domain, style: (stroke: black))
            },
          )
        })
      ],
    )
  ],
)

#pagebreak()

#questionHeader[程序设计题（每题10分，共20分）]

#question(question: [设计一个自己的 `unique_ptr`.])

#pagebreak()

#question(question: [用自己的 `unique_ptr` 实现一个链表。])
