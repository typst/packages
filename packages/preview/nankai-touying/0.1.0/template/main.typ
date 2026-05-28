#import "@preview/nankai-touying:0.1.0": *

#show: nankai-touying-theme.with(
  config-info(
    title: [基于某物关于一些东西的某种研究],
    // subtitle: [本科毕业答辩],
    reporter: [答辩人],
    // author: [可以填入原作者],
    supervisor: [一位 副教授],
    date: datetime.today(),
    institution: [南开大学统计与数据科学学院],
  ),
  config-common(
    datetime-format: "[year] 年 [month] 月",
    // breakable: false  // 是否允许截断
  )
)

#title-slide()

#outline-slide()

= 研究背景

== 问题背景

#lorem(50)

= 总结与展望

#v(-2em)
#grid(
  columns: (1.08fr, 0.92fr),
  column-gutter: 1em,
  align: top + left,
  [
    === 总结
    - #lorem(10)
    - #lorem(10)
    - #lorem(10)
    - #lorem(10)
  ],
  [
    === 展望
    - #lorem(10)
    - #lorem(10)
    - #lorem(10)
  ],
)


#show: appendix

= 参考文献

#set align(top) // 参考文献部分应该顶部对齐
#v(-4em)
// #set text(size: 0.5em) // 调整字体大小
#bibliography(
  "refs.bib", 
  title: none, // 参考文献部分的标题
  full: true, // 是否包括给定参考文献文件中的所有作品，即使它们在文档中没有被引用
  style: "ieee" // 引文样式
)
