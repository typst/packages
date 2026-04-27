#import "@preview/shuimu-touying:0.3.0": *
//#import "../lib.typ": *

#show: shuimu-touying-theme.with(
  config-info(
    title: [报告主标题],
    subtitle: [报告副标题],
    reporter: [*陈海翔*],
    author: [*CHEN MASON*],
    supervisor: [*蔡继明*],
    date: datetime.today(),
    institution: [清华大学社科学院经济学研究所],
  ),
)

#title-slide()

#outline-slide()

= 研究背景

- #lorem(50)

= 研究内容
== 研究计划

- #lorem(150)

#tblock(
  title: [无编号公式],
  [$ e^(pi i)+1=0 $]
)

== 工作进度

// 设置*全局*公式编号格式为 (1)，(2)，...
// 也就是说在这个命令之后的公式都会带上编号，可以随意调整这个命令的位置
#set math.equation(numbering: "(1)") 

#tblock(
  title: [有编号公式],
  [$ 0+0=0 $]
)

#tblock(
  title: [部分无编号公式],
  [#math.equation(block: true, numbering: none)[
  $ 1 + 1 = 2 $
]]
)

#tblock(
  title:[继续编号],
  [$ 2+2=4 $]
)

#focus-slide([Wake Up!])

= 后期安排

== 问题与解决方案

- #lorem(50)@cai1985
- #lorem(50)

#set align(top) // 参考文献部分应该顶部对齐
#bibliography(
  "refs.bib", 
  title: "参考文献", // 参考文献部分的标题
  full: true, // 是否包括给定参考文献文件中的所有作品，即使它们在文档中没有被引用
  style: "gb-7714-2015-numeric" // 引文样式
)

#focus-slide([
  向大家致敬！

  Q&A])