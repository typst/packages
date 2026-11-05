#import "@preview/chengsi:0.1.0": notes, environments
#import "config.typ": config

#let demo = config + (
  title: "分析与代数",
  subtitle: "Notes on Analysis & Algebra",
  author: "数学学习札记",
  description: [从局部估计到整体结构 / From estimates to structure],
)
#let env = environments(config: demo)
#let epigraph = env.epigraph
#let ip(x, y) = $lr(chevron.l #x, #y chevron.r)$
#show: notes.with(config: demo)

= 极限与连续

#epigraph(author: [孔子], source: [《论语·为政》])[
  学而不思则罔，思而不学则殆。
]
#cite(<analects>, form: none)


数学分析的起点，是把“无限接近”转化为可以检验的语言。
本章从数列极限出发，记录定义、直觉与证明之间的联系。

_The art of analysis begins with making approximation precise._

== 数列的收敛

#(env.definition)(title: [数列极限 / Limit of a sequence])[
  设 $(a_n)$ 为实数列。若存在 $L in RR$，使得对任意 $epsilon > 0$，
  都存在 $N in NN$，当 $n >= N$ 时有 $abs(a_n - L) < epsilon$，
  则称 $(a_n)$ 收敛于 $L$，记作 $a_n -> L$。
] <def-limit>

量词的先后顺序是定义的核心：$N$ 可以依赖 $epsilon$，但不应依赖后续选取的 $n$。

#(env.theorem)(title: [极限的唯一性 / Uniqueness])[
  若实数列 $(a_n)$ 收敛，则它的极限唯一。
] <thm-unique>

#(env.proof)[
  假设 $a_n -> L$ 且 $a_n -> M$，但 $L != M$。
  取 $epsilon = abs(L-M)/3$，由 @def-limit，对充分大的 $n$ 有
  $ abs(L-M) <= abs(L-a_n) + abs(a_n-M) < 2/3 abs(L-M). $ <eq-unique>
  这与 $abs(L-M) > 0$ 矛盾，故 $L=M$。
]

== 从定义到估计

#(env.example)(title: [$1/n -> 0$])[
  给定 $epsilon > 0$，取整数 $N > 1/epsilon$。对任意 $n >= N$，
  有 $abs(1/n - 0) <= 1/N < epsilon$，因此极限为 $0$。
]

#(env.remark)[
  证明中的关键是先写出目标不等式，再反推 $N$ 的选择。
  式 @eq-unique 则展示了三角不等式如何把两个局部估计连接起来。
]

= 内积与正交

#epigraph(
  author: [Isaac Newton], source: [Letter to Robert Hooke, 1676],
  italic: true,
  translation: [如果我看得更远，那是因为我站在巨人的肩上。（译文）],
)[If I have seen further it is by standing on the sholders of Giants.]

内积使向量空间具有长度与角度。投影把抽象的几何直觉转化为可计算的表达式。
进一步阅读可参见 Axler 的教材 @axler2024 和 Strang 的课程 @strang2010。

== 内积空间

#(env.definition)(title: [实内积 / Real inner product])[
  实向量空间 $V$ 上的内积 $ip(x,y)$ 是一个对称双线性型，
  且满足 $ip(x,x) >= 0$，等号当且仅当 $x=0$。
  由此定义范数 $norm(x) = sqrt(ip(x,x))$。
]

#(env.theorem)(title: [Cauchy–Schwarz 不等式])[
  对任意 $x,y in V$，有
  $ abs(ip(x,y)) <= norm(x) norm(y). $ <eq-cs>
  等号成立当且仅当 $x,y$ 线性相关。
] <thm-cs>

#(env.proof)[
  当 $y=0$ 时显然成立。若 $y != 0$，对任意 $t in RR$，
  $ 0 <= norm(x-t y)^2
      = norm(x)^2 - 2t ip(x,y) + t^2 norm(y)^2. $
  取 $t = ip(x,y) / norm(y)^2$，整理即得 @eq-cs。
  等号成立恰好对应 $x=t y$。
]

== 正交投影

若 $u_1, dots, u_k$ 是子空间 $W$ 的一组标准正交基，则
$ op("proj")_W(x) = sum_(i=1)^k ip(x,u_i) u_i. $ <eq-proj>

#(env.corollary)(title: [最佳逼近 / Best approximation])[
  令 $p = op("proj")_W(x)$，则对任意 $w in W$，
  $ norm(x-w)^2 = norm(x-p)^2 + norm(p-w)^2 >= norm(x-p)^2. $
]

#(env.remark)[
  @thm-cs 控制内积的大小；@thm-unique 则控制极限的歧义。
  自动引用会保留对象名称与编号，点击即可跳转。
]

= 计算、练习与回顾

#epigraph(author: [荀子], source: [《荀子·劝学》])[
  不积跬步，无以致千里；不积小流，无以成江海。
]

== 二项式与上升阶乘

对于正整数 $j,k$，二项式系数可以写成
$ binom(k+j-1, k) = frac(j(j+1)(j+2) dots.h.c (j+k-1), k!). $

固定 $k$ 后，它是关于 $j$ 的 $k$ 次多项式。例如
$ binom(j+2, 3) &= (j(j+1)(j+2))/6 \
                  &= j^3/6 + j^2/2 + j/3. $

#(env.lemma)(title: [首项系数])[
  多项式 $j(j+1) dots.h.c (j+k-1)$ 是首一多项式，
  因此 $binom(k+j-1,k)$ 关于 $j$ 的首项系数为 $1/k!$。
]

== 矩阵与分段函数

公式使用独立的数学字体，矩阵、黑板粗体与积分符号保持一致。
$ A = mat(2, 1; 1, 2), quad
  f(x) = cases(x^2 & "if " x >= 0, -x & "if " x < 0). $

#(env.exercise)(title: [从计算到解释])[
  + 求矩阵 $A$ 的特征值与一组标准正交特征向量。
  + 用 @eq-proj 将 $(1,0)$ 投影到 $W = op("span")((1,1))$。
  + 直接从定义证明：若 $a_n -> a$、$b_n -> b$，则 $a_n+b_n -> a+b$。
]

== 一页回顾

#table(
  columns: (1.05fr, 1.7fr, 1.25fr),
  table.header([概念 / Concept], [关键表达 / Key idea], [方法 / Method]),
  [极限], [$forall epsilon > 0, exists N$], [控制误差],
  [内积], [$abs(ip(x,y)) <= norm(x) norm(y)$], [二次型非负],
  [投影], [$x-p perp W$], [正交分解],
)

#(env.remark)(title: [下一步 / Next steps])[
  每次记录一个定义、一条核心结论，以及一个能暴露误解的反例。
  留下问题，往往比抄下答案更有价值。
  也可从 #link("https://linear.axler.net/")[作者提供的教材主页]继续阅读。
]

= 数值实验

用三种语言计算同一个正交投影：令 $x=(1,0)$、$u=(1,1)$，
则 $p = (x dot u)/(u dot u) u = (1/2,1/2)$。计算是检验直觉的一种方式。

== Python

```python
import numpy as np

# Project x onto the span of u
x = np.array([1.0, 0.0])
u = np.array([1.0, 1.0])
p = (x @ u) / (u @ u) * u
assert np.allclose(p, [0.5, 0.5])
print("projection:", p)
```

== Julia

#(env.code)(title: [projection.jl], numbers: true)[
```julia
using LinearAlgebra

# 向量在一维子空间上的投影
x = [1.0, 0.0]
u = [1.0, 1.0]
p = dot(x, u) / dot(u, u) * u
@assert p ≈ [0.5, 0.5]
println("projection: ", p)
```
]

== MATLAB

```matlab
% Project a column vector
x = [1; 0];
u = [1; 1];
p = (u' * x) / (u' * u) * u;
assert(norm(p - [0.5; 0.5]) < 1e-12);
disp('projection:');
disp(p);
```

三种写法都对应 @eq-proj；用 `assert` 检查结果，用 `p` 保存投影向量。

#bibliography("references.bib")

