#import "@preview/twilight-book:0.1.6" : *

#show: book.with(
  title: [晨昏之书],
  theme: "abyss",
  depth: 1,
  wrapper: (heading, content) => {
    heading
    nest-block(depth: 2, content)
  },
  inset: 1em,
  preface: "一个多主题模板",
  date: datetime(year: 2025, month: 11, day: 25),
)

// 在这里编写正文 / Write the main content here

= 第一章

这是第一章的内容

== 第一节

这是第一节的内容

=== 第一小节

这是第一小节的内容

==== 第一子小节

这是第一子小节的内容

=== 第二小节

这是第二小节的内容

== 第二节

这是第二节的内容

= 第二章

这是第二章的内容

#table(
  columns: 5,
  [1], [2], [3], [4], [5],
  [a], [b], [c], [d], [e],
  [α], [β], [γ], [δ], [ε],
)
