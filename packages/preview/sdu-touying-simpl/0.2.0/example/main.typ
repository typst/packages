#set text(font: "Source Han Serif", lang: "CN",region: "CN")
#import "@preview/sdu-touying-simpl:0.2.0": *


#show: sdu-theme.with(
  aspect-ratio: "16-9",
   config-info(
    title: [Typst template for Shandong University],
    subtitle: [Continuously Improving...],
    author: [孙更欣],
    date: datetime.today(),
    institution: [Institution],
    logo:sdu-logo
  ),
  footer-line-color: sdu-red,
)
#set heading(numbering: "1.1")
#show heading.where(level: 1): set heading(numbering: "1.")
#title-slide()

= 第一章：基础功能

== 想分列显示？

#slide(composer: (1fr,1fr, auto))[
  展示
  `void fn`
][
  *Second column.第二列*
][
  #sdu-logo
]

== 表格
//表格内容设置在main.typ中

#[
  #set align(center+horizon)
  #let a = table.cell(
    fill: green.lighten(60%),
  )[A]
  #let b = table.cell(
    fill: aqua.lighten(60%),
  )[B]



  #table(
    columns: 4,
    [], [Exam 1], [Exam 2], [Exam 3],

    [John], [], a, [],
    [Mary], [], a, a,
    [Robert], b, a, b,
  )
]
== 数学公式
行内公式：$a^2 + b^2 = c^2$

块级公式：

$ E=m c^2\ angle.l a, b angle.r &= arrow(a) dot arrow(b) \
                       &= a_1 b_1 + a_2 b_2 + ... a_n b_n \
                       &= sum_(i=1)^n a_i b_i.  $

= 第二章：小组件

== 时间轴，很简单

//timeliney: https://typst.app/universe/package/timeliney
#timeliney.timeline(
  show-grid: true,
  {
    import timeliney: *
      
    headerline(group(([*2023*], 4)), group(([*2024*], 4)))
    headerline(
      group(..range(4).map(n => strong("Q" + str(n + 1)))),
      group(..range(4).map(n => strong("Q" + str(n + 1)))),
    )
  
    taskgroup(title: [*Research*], {
      task("Research the market", (0, 2), style: (stroke: 2pt + gray))
      task("Conduct user surveys", (1, 3), style: (stroke: 2pt + gray))
    })

    taskgroup(title: [*Development*], {
      task("Create mock-ups", (2, 3), style: (stroke: 2pt + gray))
      task("Develop application", (3, 5), style: (stroke: 2pt + gray))
      task("QA", (3.5, 6), style: (stroke: 2pt + gray))
    })

    taskgroup(title: [*Marketing*], {
      task("Press demos", (3.5, 7), style: (stroke: 2pt + gray))
      task("Social media advertising", (6, 7.5), style: (stroke: 2pt + gray))
    })

    milestone(
      at: 3.75,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *Conference demo*\
        Dec 2023
      ])
    )

    milestone(
      at: 6.5,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *App store launch*\
        Aug 2024
      ])
    )
  }
)

== 代码块，很优雅

#slide[
```typc
pub fn main() {
    println!("Hello, world!");
}
```
][
  //codly: https://typst.app/universe/package/codly
```rust
pub fn main() {
    println!("Hello, world!");
}
```
]

== 用节点和箭头绘制图表

#slide[
  #set text(size: .5em,)

```typc
#diagram(cell-size: 15mm, $
  G edge(f, ->) edge("d", pi, ->>) & im(f) \
  G slash ker(f) edge("ur", tilde(f), "hook-->")
$)
```
][
  #align(center,{
  diagram(cell-size: 15mm, $
    G edge(f, ->) edge("d", pi, ->>) & im(f) \
    G slash ker(f) edge("ur", tilde(f), "hook-->")
  $)
  })
]

#slide[
#set text(size: .5em,)

```typc
#import fletcher.shapes: diamond
#set text(font: "Comic Neue", weight: 600)

#diagram(
  node-stroke: 1pt,
  edge-stroke: 1pt,
  node((0,0), [Start], corner-radius: 2pt, extrude: (0, 3)),
  edge("-|>"),
  node((0,1), align(center)[
    Hey, wait,\ this flowchart\ is a trap!
  ], shape: diamond),
  edge("d,r,u,l", "-|>", [Yes], label-pos: 0.1)
)
```
][
  #align(center,{
import fletcher.shapes: diamond
set text(font: "Comic Neue", weight: 600)

diagram(
  node-stroke: 1pt,
  edge-stroke: 1pt,
  node((0,0), [Start], corner-radius: 2pt, extrude: (0, 3)),
  edge("-|>"),
  node((0,1), align(center)[
    Hey, wait,\ this flowchart\ is a trap!
  ], shape: diamond),
  edge("d,r,u,l", "-|>", [Yes], label-pos: 0.1)
)
  })
]

#slide[
  #set text(size: .5em,)

```typc
#set text(10pt)
#diagram(
  node-stroke: .1em,
  node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
  spacing: 4em,
  edge((-1,0), "r", "-|>", `open(path)`, label-pos: 0, label-side: center),
  node((0,0), `reading`, radius: 2em),
  edge(`read()`, "-|>"),
  node((1,0), `eof`, radius: 2em),
  edge(`close()`, "-|>"),
  node((2,0), `closed`, radius: 2em, extrude: (-2.5, 0)),
  edge((0,0), (0,0), `read()`, "--|>", bend: 130deg),
  edge((0,0), (2,0), `close()`, "-|>", bend: -40deg),
)
```
][
  
  #align(center,{
set text(10pt)
diagram(
  node-stroke: .1em,
  node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
  spacing: 4em,
  edge((-1,0), "r", "-|>", `open(path)`, label-pos: 0, label-side: center),
  node((0,0), `reading`, radius: 2em),
  edge(`read()`, "-|>"),
  node((1,0), `eof`, radius: 2em),
  edge(`close()`, "-|>"),
  node((2,0), `closed`, radius: 2em, extrude: (-2.5, 0)),
  edge((0,0), (0,0), `read()`, "--|>", bend: 130deg),
  edge((0,0), (2,0), `close()`, "-|>", bend: -40deg),
)
  })
]

#slide[
  #set text(size: .5em)

```typc
#diagram(cell-size: 15mm, $
  G edge(f, ->) edge("d", pi, ->>) & im(f) \
  G slash ker(f) edge("ur", tilde(f), "hook-->")
$)
```
][
  #align(center,{
  diagram(cell-size: 15mm, $
    G edge(f, ->) edge("d", pi, ->>) & im(f) \
    G slash ker(f) edge("ur", tilde(f), "hook-->")
  $)
  })
]

== 展示框，很有趣

#slide[
  #set text(size: .5em)

```typc
#showybox(
  [Hello world!]
)
```
```typc
showybox(
  frame: (
    dash: "dashed",
    border-color: red.darken(40%)
  ),
  body-style: (
    align: center
  ),
  sep: (
    dash: "dashed"
  ),
  shadow: (
	  offset: (x: 2pt, y: 3pt),
    color: yellow.lighten(70%)
  ),
  [This is an important message!],
  [Be careful outside. There are dangerous bananas!]
)
```

][
  #align(center,{

  showybox(
  [Hello world!]
  )

showybox(
  frame: (
    dash: "dashed",
    border-color: red.darken(40%)
  ),
  body-style: (
    align: center
  ),
  sep: (
    dash: "dashed"
  ),
  shadow: (
	  offset: (x: 2pt, y: 3pt),
    color: yellow.lighten(70%)
  ),
  [This is an important message!],
  [Be careful outside. There are dangerous bananas!]
)

  })
]

== 提示框

#slide[
  #set text(size: .5em)
```typc
#info[ This is the info clue ... ]
#tip(title: "Best tip ever")[Check out this cool package]
```
][
  #align(center,{
info[ This is the info clue ... ]
tip(title: "Best tip ever")[Check out this cool package]
  })
]

== 类obsidian

#info[This is information]

#success[I'm making a note here: huge success]

#check[This is checked!]

#warning[First warning...]

#note[My incredibly useful note]

#question[Question?]

#example[An example make things interesting]

#quote[To be or not to be]

#callout(
  title: "Callout",
  fill: blue,
  title-color: white,
  body-color: black,
  icon: none)[123]

#let mycallout = callout.with(title: "My callout")//TODO:放到config中去

// #mycallout[Hey this is my custom callout!]

= 第三章：页面

== focus-slide

#focus-slide[
  聚焦页
]

== matrix-slide

#matrix-slide[
  left
][
  middle
][
  right
]

#matrix-slide(columns: 1)[
  top
][
  bottom
]

#matrix-slide(columns: (1fr, 2fr, 1fr), ..(lorem(8),) * 9)


// #BlueBox(title: "你好")[bubu]

== 致谢

#ending-slide[
  #align(center + horizon)[
  #set text(size: 3em, weight: "bold", sdu-red)

  THANKS FOR ALL

  敬请指正！
]
]




