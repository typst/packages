#import "@preview/codly:1.0.0":*
#import "@preview/i-figured:0.2.4"
#import "@preview/pintorita:0.1.1"
#import "@preview/gentle-clues:0.8.0": *
#import "@preview/cheq:0.1.0": checklist
#import "@preview/unify:0.6.0": num, qty, numrange, qtyrange
#import "@preview/mitex:0.2.4" : *
#import "@preview/showybox:2.0.1": *
#import "@preview/cuti:0.2.1": show-cn-fakebold
#import "@preview/commute:0.2.0":*

  // #llltable(
  //   titles:table.header(
  //     [*Random walk*],[*Markov chain*]
  //   ),
  //   columns:2,
  //   caption: [随机游走与马尔可夫链],
  //   [图 Graph], [随机过程 Stochastic process],[顶点 Vertex], [状态 State],[强连通 Strongly connected], [持续 Persistent],[非周期的 Aperiodic], [非周期的 Aperiodic],[强连通且非周期的 Strongly connected and aperiodic], [遍历的 Ergodic],[无向图 Undirected graph], [时间可逆的 Time reversible]
    
  // )
#let llltable(titles:[],columns:1,caption:[],align:left,kind:"table",supplement:[表],..items)={
  let items=items.pos()//在函数定义中，..bodies 表示接收任意数量的参数，这些参数被收集到一个特殊的 参数对象（arguments object） 中.bodies.pos() 方法从参数对象中提取所有的 位置参数，并返回一个 序列（sequence），即一个有序的参数列表。
  figure(
    kind:kind,
    supplement:supplement,
    caption: caption,
    table(
    stroke: none, 
    columns: columns,
    align: align,
    table.hline(),
    // table.header(
    //   for title in titles {
    //     strong(title)
    //   }
    // ),
    titles,
    table.hline(),
    ..items,
    table.hline(),
    ),
  )
}