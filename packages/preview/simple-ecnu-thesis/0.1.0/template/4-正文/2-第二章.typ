#import "mod.typ": *
#show: style

= 预备知识

在论文中我们经常使用图片或者表格，
在 `Typst` 中我们使用 `figure` 来包裹他们，



== 图形 `figure` 示例

=== 图形中放表格

七神（The Seven Gods），
又名尘世七执政，
是米哈游出品游戏《原神》及其衍生作品中的角色合称，
指的是分别掌控七种元素（即火、水、风、雷、草、冰、岩），
并以不同的理念统御提瓦特大陆七国的七位神灵。
如@table-normal 所示：

#figure(
  caption: [尘世七执政],
  kind: table, // 可以注释
  table(
    columns: 3,
    table.header([], [神之眼], [尘世七执政]),
    [蒙德], [风], [巴巴托斯],
    [璃月], [🪨], [摩拉克斯],
    [稻妻], [⚡], [巴尔泽布],
    [须弥], [草], [小吉祥草王],
    [枫丹], [💦], [芙卡洛斯],
    [穆纳塔], [🔥], [玛薇卡],
    [至冬], [❄️], [冰之女皇],
  ),
) <table-normal>

引用*普通表格*@table-normal，
或者这样写#ref(<table-normal>)

=== 图形：三线表 + 合并单元格

愚人众的代号以及称呼

#figure(
  caption: [愚人众],
  table(
    columns: 3,
    stroke: none,
    align: center,
    table.hline(),
    table.header(table.cell(colspan: 2)[代号], [称呼]),
    table.hline(stroke: 0.5pt),
    [统括官], [「丑角」], [皮耶罗],
    [No.1], [「队长」], [卡皮塔诺],
    [No.2], [「博士」], [多托雷],
    [No.3], [「少女」], [哥伦比娅],
    table.cell(colspan: 2)[████████], [███],

    table.hline(),
  ),
)<table-demo>


== 图形中放入图片

星穹铁道，启动！

#figure(
  caption: [崩坏星穹铁道],
  kind: image,
  image("../image/崩坏星穹铁道.jpg", width: 80%),
)

== 子图的不同排列方式

排列方式1

#subpar-grid(
  caption: [我是一张超图，子图纵向排列],
  figure(
    caption: [我是第一个子图a],
    rect(stroke: 1pt, height: 4em, width: 60%, fill: rgb("eeeeaa")),
  ),
  figure(
    caption: [我是第二个子图b],
    rect(stroke: 1pt, height: 6em, width: 80%, fill: rgb("eeaaee")),
  ),
)

排列方式2

#subpar-grid(
  caption: [我是另一张超图，子图横向排列],
  kind: image,
  columns: (1fr, 1fr),
  figure(
    caption: [我是第一个子图a],
    rect(stroke: 1pt, height: 3em, width: 40%, fill: rgb("9bea1e")),
  ),
  figure(
    caption: [我是第二个子图b],
    rect(stroke: 1pt, height: 4em, width: 40%, fill: rgb("aebaea")),
  ),
)

如何引用子图和超图

#subpar-grid(
  caption: [这是一张超图，子图网格排列],
  columns: (1fr, 1fr),
  kind: image,
  figure(
    caption: [我是子图a],
    rect(stroke: 1pt, height: 4em, width: 40%, fill: rgb("aeaeee")),
  ),
  <sub-figure-1>,
  figure(
    caption: [我是图b],
    rect(stroke: 1pt, height: 4em, width: 40%, fill: rgb("aeeeee")),
  ),
  <sub-figure-2>,
  figure(
    caption: [我是子图c],
    rect(stroke: 1pt, height: 4em, width: 40%, fill: rgb("aeae1e")),
  ),
  figure(
    caption: [我是子图d],
    rect(stroke: 1pt, height: 4em, width: 40%, fill: rgb("a10ee1")),
  ),
  label: <super-figure>,
)

引用超图 @super-figure 的写法，
引用子图 @sub-figure-1 和 @sub-figure-2 的写法。


== 伪算法样式

见 @chapter-3[] 的 @chapter-3-ai，
或者这样写#ref(<chapter-3>, supplement: [])也可以，
本质上 `@chapter-3` 是语法糖。

比较两种用法

- @chapter-3
- @chapter-3[]

== 数学公式

欧拉公式 $e ^ (i pi)  + 1 = 0$ 由数学中最重要的五个数组成 ... ...

常见的激活函数如@eqt-activation 所示

$
  & "ReLU" (x) &= &max lr((0 , x))\
  & "Sigmoid" (x) & = &frac(e^x, 1 plus e^x)\
  & "Tanh" (x) & = &frac(e^x - e^(minus x), e^x plus e^(minus x))\
$ <eqt-activation>

常见的损失函数有

$
  & "MSE平方损失函数" L(Y | f(X)) &= &sum_N (Y-f(X))^2 \
  & "对数损失函数" L(Y, "Pr"(Y|X)) &= &- log "Pr"(Y|X) \
  & "01损失函数" L(Y, f(X)) &= &cases(1 "if " Y != f (X), 0 "if " Y = f (X)) \
  & "Hinge 损失函数" L(y, f(X)) &=& max(0, 1 - y f(x))
$

