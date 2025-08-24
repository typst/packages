#import "@preview/theorion:0.3.2": *
#import cosmos.fancy: *
// #import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

#set page(height: auto)
#set heading(numbering: "1.1")
#set text(lang: "zh", region: "cn")

/// 1. 更改计数器和编号：
// #set-inherited-levels(1)
// #set-zero-fill(true)
// #set-leading-zero(true)
// #set-theorion-numbering("1.1")

/// 2. 其他选项：
// #set-result("noanswer")
// #set-qed-symbol[#math.qed]

/// 3. 自定义定理环境
// #let (theorem-counter, theorem-box, theorem, show-theorem) = make-frame(
//   "theorem",
//   theorion-i18n-map.at("theorem"),
//   counter: theorem-counter,  // 继承已有计数器，默认为 none
//   inherited-levels: 2,  // 需要新计数器时有用
//   inherited-from: heading,  // 从标题或其他计数器继承
//   render: (prefix: none, title: "", full-title: auto, body) => [#strong[#full-title.]#sym.space#emph(body)],
// )
// #show: show-theorem

/// 4. 开始使用
// #theorem(title: "欧几里得定理")[
//   素数有无穷多个。
// ] <thm:euclid>
// #theorem-box(title: "无编号定理", outlined: false)[
//   这个定理没有编号。
// ]

/// 5. 附录示例
// #counter(heading).update(0)
// #set heading(numbering: "A.1")
// #set-theorion-numbering("A.1")

/// 6. 目录
// #outline(title: none, target: figure.where(kind: "theorem"))


= Theorion 环境示例

== 目录

#outline(title: none, target: figure.where(kind: "theorem"))

== 开箱即用

```typst
#import "@preview/theorion:0.3.2": *
#import cosmos.fancy: *
// #import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

#theorem(title: "欧几里得定理")[
  素数有无穷多个。
] <thm:euclid>

#theorem-box(title: "无编号定理", outlined: false)[
  这个定理没有编号。
]
```

== 自定义

```typst
// 1. 更改计数器和编号：
#set-inherited-levels(1)
#set-zero-fill(true)
#set-leading-zero(true)
#set-theorion-numbering("1.1")

// 2. 其他选项：
#set-result("noanswer")
#set-qed-symbol[#math.qed]

// 3. 自定义定理环境
#let (theorem-counter, theorem-box, theorem, show-theorem) = make-frame(
  "theorem",
  theorion-i18n-map.at("theorem"),
  counter: theorem-counter,  // inherit the old counter, `none` by default
  inherited-levels: 2,  // useful when you need a new counter
  inherited-from: heading,  // heading or just another counter
  render: (prefix: none, title: "", full-title: auto, body) => [#strong[#full-title.]#sym.space#emph(body)],
)
#show: show-theorem

// 4. 开始使用
#theorem(title: "欧几里得定理")[
  素数有无穷多个。
] <thm:euclid>
#theorem-box(title: "无编号定理")[
  这个定理没有编号。
]

// 5. 附录示例
#counter(heading).update(0)
#set heading(numbering: "A.1")
#set-theorion-numbering("A.1")

// 6. 目录
#outline(title: none, target: figure.where(kind: "theorem"))
```

== 基础定理环境

让我们从最基本的定义开始。

#definition[
  若一个大于1的自然数不能写成两个更小自然数的乘积，则称其为#highlight[_素数_]（或_质数_）。
] <def:prime>

#example[
  数 $2$、$3$ 和 $17$ 都是素数。正如@cor:infinite-prime 所证，这个列表远未完整！详细证明见@thm:euclid。
]

#theorem(title: "欧几里得定理")[
  素数有无穷多个。
] <thm:euclid>

#proof[
  反证法：假设 $p_1, p_2, dots, p_n$ 是所有素数的有限列举。
  记 $P = p_1 p_2 dots p_n$。因为 $P + 1$ 不在我们的列表中，
  它不可能是素数。因此，一定存在某个素数 $p_j$ 整除 $P + 1$。
  又因为 $p_j$ 也整除 $P$，所以它必须整除差 $(P + 1) - P = 1$，矛盾。
]

#corollary[
  不存在最大的素数。
] <cor:infinite-prime>

#corollary[
  合数有无穷多个。
]

== 函数与连续性

#theorem(title: "连续性定理")[
  设函数 $f$ 在每一点都可导，则 $f$ 是连续函数。
] <thm:continuous>

#tip-box[
  @thm:continuous 告诉我们可导性蕴含连续性，但反之不成立。比如 $f(x) = |x|$ 在 $x = 0$ 处连续但不可导。
  更深入理解连续函数，请参见附录中的@thm:max-value。
]

== 几何定理

#theorem(title: "勾股定理")[
  直角三角形的两条直角边的平方和等于斜边的平方：
  $x^2 + y^2 = z^2$
] <thm:pythagoras>

#important-box[
  @thm:pythagoras 是平面几何中最基本也是最重要的定理之一，它连接了几何与代数。
]

#corollary[
  不存在边长为3厘米、4厘米和6厘米的直角三角形。这是@thm:pythagoras 的直接推论。
] <cor:pythagoras>

#lemma[
  给定两条线段，其长度分别为 $a$ 和 $b$，则存在实数 $r$ 使得 $b = r a$。
] <lem:proportion>

== 代数结构

#definition(title: "环")[
  设 $R$ 是一个非空集合，如果 $R$ 上定义了两个二元运算 $+$ 和 $dot$，满足：
  1. $(R, +)$ 是阿贝尔群
  2. $(R, dot)$ 是半群
  3. 分配律成立
  则称 $(R, +, dot)$ 为一个环。
] <def:ring>

#proposition[
  每个域都是环，但不是每个环都是域。这个概念基于@def:ring。
] <prop:ring-field>

#example[
  参考@def:ring，整数环 $ZZ$ 不是域，因为除了 $plus.minus 1$，其他元素都没有乘法逆元。
]

/// 附录示例
#counter(heading).update(0)
#set heading(numbering: "A.1")
#set-theorion-numbering("A.1")

= Theorion 附录

== 进阶分析

#theorem(title: "最大值定理")[
  闭区间上的连续函数必有最大值和最小值。
] <thm:max-value>

#warning-box[
  这个定理的两个条件缺一不可：
  - 函数必须是连续的
  - 定义域必须是闭区间
]

== 高等代数补充

#axiom(title: "群公理")[
  群 $(G, \cdot)$ 需满足：
  1. 封闭性
  2. 结合律
  3. 存在单位元
  4. 存在逆元
]

#postulate(title: "代数基本定理")[
  任意一个非零复系数多项式一定有复数根。
]

#remark[
  这个定理也被称为高斯基本定理，因为它是由高斯首次严格证明的。
]

== 常见问题与解答

#problem[
  证明：如果 $n$ 是大于1的整数，则存在长度为 $n$ 的连续合数序列。
]

#solution[
  考虑序列：$n! + 2, n! + 3, ..., n! + n$。

  对于任意 $2 <= k <= n$，$n! + k$ 能被 $k$ 整除，因为：
  $n! + k = k(n!/k + 1)$
  
  所以这是一个长度为 $n-1$ 的连续合数序列。
]

#exercise[
  1. 证明：存在无限多对孪生素数的猜想至今未被证明。
  2. 尝试说明为什么这个问题如此困难。
]

#conclusion[
  数论中还有许多未解决的问题，它们往往看似简单，实则深奥。
]

== 注意事项

#note-box[
  请记住数学证明既要严谨又要清晰。
  没有严谨性的清晰是不充分的，没有清晰性的严谨也是无效的。
]

#caution-box[
  在处理无穷级数时，一定要先检验其收敛性，再讨论其他性质。
]

#quote-box[
  数学是科学的女王，而数论是数学的女王。
  — 高斯
]

#emph-box[
  本章总结：
  - 我们介绍了基本的数论概念
  - 证明了几个重要定理
  - 展示了不同类型的数学环境
]

== 重述定理

// 1. 重述所有定理
#theorion-restate(filter: it => it.outlined and it.identifier == "theorem", render: it => it.render)
// 2. 重述所有定理（自定义格式）
// #theorion-restate(
//   filter: it => it.outlined and it.identifier == "theorem",
//   render: it => (prefix: none, title: "", full-title: auto, body) => block[#strong[#full-title.]#sym.space#emph(body)],
// )
// 3. 重述特定定理
// #theorion-restate(filter: it => it.label == <thm:euclid>)