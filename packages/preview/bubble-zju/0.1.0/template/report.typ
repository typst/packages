#import "@preview/bubble-zju:0.1.0": *

// and you can import any Typst package you want!
#import "@preview/note-me:0.5.0": *
// #import "@preview/cetz:0.4.1": canvas, draw, matrix, vector
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import fletcher.shapes: circle as fletcher_circle, hexagon, house

#show: bubble.with(
  title: "实验二：Typst模板实现",
  subtitle: "Typst短学期 (Typst101) 实验报告",
  author: "324010XXXX 犬戎",
  affiliation: "浙江大学 计算机科学与技术",
  date: datetime.today().display("[year] 年 [month padding:none] 月 [day padding:none] 日"),
  year: "课程综合实践I (CS1145M), 2025",
  // class: "Class",
  // other: ("Made with Typst", "https://typst.com")
)

#outline(title: "目录")
#pagebreak()

= 简介

这是一个简单的浙江大学报告模板，你可以用它来写报告。

= 样式

下面是一些样式的样例。

== 列表

以下是一个无序列表。

- AVL Tree
- Splay Tree
- Red-Black Tree
- B+ Tree

以下是一个有序列表。

1. Alice
2. Bob
3. Charlie
5. Eve

== 代码块

这是一个代码块：

```rust
fn main() {
    println!("Hello, world!");
}
```

在 bubble-zju 的配置中，西文字体使用「JetBrainsMonoNL NF」，中文字体使用「霞鹜文楷屏幕阅读版」。

```py
text = "未甚拔行间，犬戎大充斥"
print(text.encode())
```

这里是一个行内代码块：`text.encode()`。

== 图表

见 @figure1。

#figure(
  [
    #let blob(pos, label, tint: white, ..args) = node(
      pos,
      align(center, label),
      width: 28mm,
      fill: tint.lighten(60%),
      stroke: 1pt + tint.darken(20%),
      ..args,
    )

    // #let c(..args) = circle(..args)
    #let circ(pos, tint: white, ..args) = node(
      pos,
      align(center, box(baseline: -2pt)[$+$]),
      fill: tint,
      stroke: 1pt + black,
      shape: fletcher_circle,
      radius: 2.5mm,
      ..args,
    )

    #diagram(
      spacing: 8pt,
      cell-size: (8mm, 10mm),
      edge-stroke: 1pt,
      edge-corner-radius: 5pt,
      mark-scale: 70%,

      circ((0, 1)),
      edge(),
      blob((0, 2), [Grouped Query\ Attention], tint: orange),
      blob((0, 3.3), [RMS Norm], tint: yellow, shape: hexagon),
      edge(),
      blob((0, 5), [Input], shape: house.with(angle: 30deg), width: auto, tint: red),

      for x in (-.3, -.1, +.1, +.3) {
        edge((0, 2.8), (x, 2.8), (x, 2), "-|>")
      },
      edge((0, 2.8), (0, 4)),
      edge((0, 4), "r,uuu,l", "--|>"),
      edge((0, 1), (0, 0.35), "rr", (2, 4), "r", (3, 3.3), "-|>"),
      edge((3, 4), "r,uuu,l", "--|>"),

      blob((3, 0), [Output], tint: green),
      edge("<|-"),
      circ((3, 1)),
      edge(),
      blob((3, 2), [Feed\ Forward], tint: blue),
      edge(),
      blob((3, 3.3), [RMS Norm], tint: yellow, shape: hexagon),
    )
  ],
  caption: [Overview of Qwen3 Decoder Layer.],
)<figure1>

该图表使用 fletcher 进行绘制。

== 公式

你可以使用数学公式。

=== Riemann 重排定理

假设 $sum_(n=1)^(infinity) a_n$ 是一个条件收敛的无穷级数。对任意的一个实数 $C$，都存在一种从自然数集合到自然数集合的排列 $sigma: n arrow.bar sigma(n)$，使得
$
  sum_(n=1)^(infinity) a_sigma(n) = C.
$

此外，也存在另一种排列 $sigma': n arrow.bar sigma'(n)$，使得
$
  sum_(n=1)^(infinity) a_(sigma'(n)) = infinity.
$

类似地，也可以有办法使它的部分和趋于 $-infinity$，或没有任何极限。

反之，如果级数是绝对收敛的，那么无论怎样重排，它仍然会收敛到同一个值，也就是级数的和。
