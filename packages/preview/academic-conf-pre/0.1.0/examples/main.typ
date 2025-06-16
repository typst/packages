#import "@preview/touying:0.4.2": *
#import "@preview/unify:0.6.0": num //标号
//#import "../themes/aus-beamer.typ" as theme-aus
#import "@preview/academic-conf-pre:0.1.0" as theme-aus

// 首先注册PPT的基本信息
#let s = theme-aus.register(aspect-ratio: "4-3") //4-3, 16-9
#let s = (s.methods.info)(
  self: s,
  title: [This is a template for academic research presentation in Typst],
  short-title: [My essay short title],
  subtitle: [This is the subtitle],
  author: [Jun Liu],
  date: datetime.today(),
  institution: [My Institution \
    University of Blablabla],
)

// 这些是一些常用的方法
// tblock是小方框
#let (init, slides, touying-outline, alert, speaker-note, tblock) = utils.methods(s)
#let (slide, empty-slide, title-slide, outline-slide, new-section-slide, ending-slide) = utils.slides(s)

// 封面
#show: init
#show: slides.with(title-slide: false)

#title-slide(authors: [Jun Liu, Jun Liu, Jun Liu, Jun Liu, \
  Jun Liu and Jun Liu\

  #set text(size: 0.9em)
  Jun Liu \@JunLiu.edu
])

// 目录
#outline-slide()

= Blocks
== Blocks
A *text block* is an elegant structure for presenting structured data. You can choose to display it using bullets or numbered lists.

#tblock(title: [Block With Bullets])[
  - You can choose to display it using bullets.
  - You can choose to display it using bullets.
  - You can choose to display it using bullets.
]
#tblock(title: [Block With Numbered Lists])[
  + You can choose to display it using number list.
  + You can choose to display it using number list.
  + You can choose to display it using number list.
]

= Figures
== Figures
The *images* will be automatically arranged in the most visually appealing way. Later, we will demonstrate some complex layout scenarios.
#figure(
  image("figures/image.png", width: 90%),
  caption: [This is the caption for figure.],
) <fig:SMSC>

= Tables
== Tables
There are many options for *table* layout. Please refer to the source code for details.

// 可以通过#align来控制排版细节
#align(center)[
  #table(
  columns: 2,
  inset: 10pt,
  align: (center, center, right),
  [*Site*], [*Messages*],
  [receivesmsonline.net], [81313],
  [receive-sms-online.info], [69389],
  [receive-sms-now.com], [63797],
  [hs3x.com], [55499],
  [receivesmsonline.com], [44640],
  [receivefreesms.com], [37485],
  [receive-sms-online.com], [27094],
  [e-receivesms.com], [7107],
)
]

= Formula
== Formula

This slide shows how we could display *math formulas*.
\
\

*Eq 1:*
$ f(x) = a x^2 + b x + c $

*Eq 2:*
$ "area" = pi dot "radius"^2 $

*Eq 3:*
$ cal(A) :=
    { x in RR | x "is natural" } $

*Eq 4:*
$ sum_(k=0)^n k
    &= 1 + ... + n \
    &= (n(n+1)) / 2 $

= Code
== Code
This is how we display the *code* in our presentation.

Adding `rbx` to `rcx` gives
the desired result.

What is ```rust fn main()``` in Rust
would be ```c int main()``` in C.
\
\
```rust
fn main() {
    println!("Hello World!");
}
```
\

This has ``` `backticks` ``` in it
(but the spaces are trimmed). And
``` here``` the leading space is
also trimmed.


= Complex Layouts
== Complex Layouts 1
#tblock(title: [Complex Layouts])[
  You can easily use composer or grid func from slide to implement *complex layouts*.
]

#grid(
  columns: (1fr, 1fr, 1fr),
  figure(
    image("figures/grid1.png"),
    caption: [This is the test figure],
  ),
  figure(
    image("figures/grid2.png"),
    caption: [This is the test figure],
  ),
  figure(
    image("figures/grid3.png"),
    caption: [This is the test figure],
  ),
)

== Complex Layouts 2

#slide(composer: (1.1fr, 1fr))[
  #set text(0.8em)

  As you can see, the composer function can be used to create *complex layouts*.

  And adjust the different layout parameters to achieve the desired result.
][
  #figure(
    table(
    columns: 3,
    align: (center, center, center),
    [Hello], [Hello], [Hello],
    [A], [B], [C],
  ),
    caption: [This is the table with caption],
  ) <tab:gateways>
\

  #figure(
    table(
      columns: 4,
      [], [Exam 1], [Exam 2], [Exam 3],
      [John], [85], [96], [86],
      [Mary], [53], [64], [75],
      [Robert], [32], [86], [85],
    ),
    caption: [This is the table with caption],
  ) <tab:gateways>
]


#ending-slide(title: [Thanks for Listening.])[
  \
  This is the *ending slide* to show some words
]
