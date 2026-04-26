// #import "./src/exports.typ": *
#import "@preview/touying:0.5.3": *
#import "@preview/mitex:0.2.4" : *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/cuti:0.2.1": show-cn-fakebold //显示粗体
#import "@preview/lovelace:0.3.0": * //伪代码
#import "@preview/codly:1.0.0":*
/*
three-line table, create it like this:

#llltable(
  titles:table.header(
    [*Random walk*],[*Markov chain*]
  ),
  columns:2,
  caption: [随机游走与马尔可夫链],
  [图 Graph], [随机过程 Stochastic process],[顶点 Vertex], [状态 State],[强连通 Strongly connected], [持续 Persistent],[非周期的 Aperiodic], [非周期的 Aperiodic],[强连通且非周期的 Strongly connected and aperiodic], [遍历的 Ergodic],[无向图 Undirected graph], [时间可逆的 Time reversible]
  
)
*/
#let llltable(titles:(),caption:[],align:left,kind:"table",supplement:[表],..items)={
  let items=items.pos()//在函数定义中，..bodies 表示接收任意数量的参数，这些参数被收集到一个特殊的 参数对象（arguments object） 中.bodies.pos() 方法从参数对象中提取所有的 位置参数，并返回一个 序列（sequence），即一个有序的参数列表。
  figure(
    kind:kind,
    supplement:supplement,
    caption: caption,
    table(
    stroke: none, 
    columns: titles.len(),
    align: align,
    table.hline(),
    table.header(
      for title in titles {
        [#strong(title)]
      }
    ),
    table.hline(),
    ..items,
    table.hline(),
    ),
  )
}

/*
cancelline, create it like this:

#cancelline(
  [deleted text]
)

or

#cancelline[deleted text]
*/
#let cancelline(..body)={
  let body=body.pos()
  underline(stroke: (thickness: 5pt, paint: black, cap: "round"),evade: false,background: false,offset: -7pt,..body)
}

/*
algorithm, create it like this:

#algo(
  caption: [Construction of sparse neighborhood graph (SNG)],
  content: [
#pseudocode-list(hooks: .0em, line-gap: .5em,)[
+ *for* $p in P$
  + *initialize* set $S=P\\{p}$
  + *while* $S !eq ∅$ 
    + *let* #mi(`p^* ← arg min_{p' ∈ 𝓥} d(p, p')`)
    + *add* a directed edge from p to $p^*$ 
    + *for* $p' in S\\{p^*}$
      + *if* #mi(`d(p^*, p') ≤ d(p, p')`) 
        + *remove* #mi(`p'`) from S
]  
  ]
)
*/
#let algo(caption:[],content:[])={
  figure(
    kind: "algorithm",
    caption: caption,
    supplement: [Algorithm],
    content
  )
}
