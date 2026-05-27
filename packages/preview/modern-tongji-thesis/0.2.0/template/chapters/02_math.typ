#import "@preview/modern-tongji-thesis:0.2.0": *

= 数学环境 <math>

在本章（@math）中，我们展示各种数学符号和定理环境的使用。数学排版是学术论文中的重要组成部分，
同济大学论文模板遵循 GB/T 3102.11-1993 的数学符号排版规范。

== 数学符号

微分符号 $"d"$ 应使用正体（而非斜体 $d$）。圆周率 $pi$、
自然对数的底 $e$ 同样应为正体。

虚数单位应使用正体：#ii 和 #jj 分别对应电工学和数学中的虚数单位，
通过模板预置的 #raw("#ii", lang: "typ") 和 #raw("#jj", lang: "typ") 命令调用。

== 方程环境

Typst 使用 `$ ... $` 表示行内公式，使用 `$ ... $`（单独段落）表示行间公式。
行间公式可以自动编号，并支持交叉引用。

=== 基本方程

简谐振子的运动方程为：

$
  ("d"^2)/("d" t^2) x(t) + omega^2 x(t) = sin(t).
$ <eq:harmonic-oscillator>

偏微分方程也是常见的数学对象，波动方程可以写为：

$
  (partial^2 u)/(partial t^2) = (partial^2 u)/(partial x^2) + (partial^2 u)/(partial y^2).
$

傅里叶级数也是基本的数学工具：

$
  sum_(n=1)^oo (cos(n x))/n^2 = pi^2/6 - x^2/4.
$

=== 多行对齐方程

Typst 使用 `\` 在公式块中进行换行，并可以通过对齐点实现多行对齐。
以下是一个信息论恒等式的推导过程：

$
  &I(X_1;X_2) - I(X_1;X_2|X_3) \
  = &H(X_2) - H(X_2|X_3) \
  = &H(X_2,X_3) - H(X_3) - H(X_2|X_3) \
  = &I(X_2;X_3) - I(X_2;X_3|X_1) \
  = &I(X_2;X_3,X_1) \
  >= &0.
$

=== 超长公式

对于较长的公式，可以通过多行拆分来提高可读性：

$
  1/2 Delta (f_(i j) f^(i j)) = 2 (sum_(i < j) chi_(i j) (sigma_i - sigma_j)^2
  + f^(i j) nabla_j nabla_i (Delta f) + nabla_k f_(i j) nabla^k f^(i j)
  + f^(i j) f^k [2 nabla_i R_(j k) - nabla_k R_(i j)]) \
  -  3 H^2 [1 + dot(phi)/(2 H^2)] - dot(phi)^2/2 - k/a^2 phi^2
  -  1/2 ((partial phi)/(partial t))^2 + a^2/2 ((partial phi)/(partial x))^2
  +  1/4 lambda phi^4 + beta/3 phi^3 \
  -  1/2 mu^2 phi^2 (ln(phi^2) - c)
  +  e^2/2 ((partial A_mu)/(partial t))^2 - e^2/2 ((partial A_mu)/(partial x))^2
  -  e^2 phi^2 A_mu A^mu + 1/4 F_(mu nu) F^(mu nu).
$

== 矩阵与行列式

矩阵与行列式也是常见的数学对象。Typst 使用 `mat(...; ...)` 排版矩阵，
用 `det mat(...)` 排版行列式。例如一个 $m times n$ 的矩阵 $bold(A)$ 及其 $2 times 2$ 的行列式：

$
  bold(A) = mat(
    a_11, a_12, dots, a_(1n);
    a_21, a_22, dots, a_(2n);
    dots, dots, dots, dots;
    a_(m 1), a_(m 2), dots, a_(m n)
  ), quad
  det(bold(A)) = det mat(a_11, a_12; a_21, a_22) = a_11 a_22 - a_12 a_21.
$

== 分段函数

分段函数用 `cases` 语法表示，使用 `&` 在分支内对齐，各分支间用 `,` 分隔：

$
  f(x) = cases(
    x^2   & quad x >= 0,
    -x^2  & quad x  <  0,
  )
$ <eq:piecewise>

== 定理环境

定理环境是数学论文的重要工具。同济大学论文模板的 LaTeX 版本定义了定理、推论、引理、
命题、猜想、假设、定义、例、注和证明共十种定理环境，按章编号。
本 Typst 模板通过 `theorion` 宏包实现了完全对应的环境。

#thm[素数有无穷多个。] <thm:infinite-primes>

#pf[
  假设素数只有有限个，记为 $p_1, p_2, dots, p_n$。令 $N = p_1 p_2 dots p_n + 1$，
  则 $N > 1$，且 $N$ 除以任何 $p_i$ 都余 $1$，因此 $N$ 不能被任何 $p_i$ 整除。
  但 $N$ 必有素因子，该素因子不在 $p_1, dots, p_n$ 中，与假设矛盾。
  故素数有无穷多个。
]

#cor[
  如果 $a$ 和 $b$ 是正实数，则 $a + b >= 2 sqrt(a b)$。
] <cor:am-gm>

#pf[
  具体地，我们有：
  $
    sqrt(a b) &<= (a + b)/2 \
    => 2 sqrt(a b) &<= a + b
  $
  因此，$a + b >= 2 sqrt(a b)$，定理成立。
]

#lem[
  设 $f$ 是一个在 $[a, b]$ 上的可微函数，则 $f$ 在 $[a, b]$ 上一定有一点使得
  $f'(c) = (f(b) - f(a))/(b - a)$。
] <lem:mvt>

#pf[
  定义辅助函数 $g(x) = f(x) - (f(b) - f(a))/(b - a) (x - a)$。
  易验证 $g(a) = f(a)$，$g(b) = f(b) - (f(b) - f(a)) = f(a)$，故 $g(a) = g(b)$。
  由罗尔定理，存在 $c in (a, b)$ 使得 $g'(c) = 0$，即
  $
    f'(c) - (f(b) - f(a))/(b - a) = 0,
  $
  因此 $f'(c) = (f(b) - f(a))/(b - a)$，定理得证。
]

#prop[
  设 $f$ 和 $g$ 是两个单调递增的函数，则 $f + g$ 也是一个单调递增函数。
] <prop:monotonic>

#pf[
  我们需要证明对于任意的 $x, y in RR$，如果 $x < y$，
  则 $f(x) + g(x) < f(y) + g(y)$。
  由于 $f$ 和 $g$ 都是单调递增的，所以有 $f(x) < f(y)$ 和 $g(x) < g(y)$，
  于是 $f(x) + g(x) < f(y) + g(x) < f(y) + g(y)$。
  因此，$f + g$ 是单调递增的，定理得证。
]

#conj[孪生素数猜想][
  存在无穷多对素数 $(p, p + 2)$，使得 $p$ 和 $p + 2$ 均为素数。
  例如 $(3, 5)$、$(5, 7)$、$(11, 13)$、$(17, 19)$ 等。
  该猜想至今尚未被证明。
] <conj:twin-primes>

#assume[
  假设 $A$ 和 $B$ 是两个集合，则它们的笛卡尔积 $A times B$ 的基数为 $|A| dot |B|$。
] <assume:cartesian>

#pf[
  我们可以使用等势关系来证明，即构造一个双射
  $f: A times B -> {1, 2, dots, |A| dot |B|}$。
  具体地，我们可以按照以下方式定义 $f$：
  $
    f(a, b) = (a - 1) dot |B| + b.
  $
  因此，$A times B$ 和 ${1, 2, dots, |A| dot |B|}$ 等势，即它们有相同的基数，
  定理得证。
]

#dfn[
  一个有向无环图是拓扑排序的，当且仅当它的所有顶点都可以按照某个顺序进行编号，
  使得对于任意一条有向边 $(u, v)$，$u$ 的编号都小于 $v$ 的编号。
] <dfn:topological-sort>

#exmp[
  考虑一个任务调度问题，其中有 $n$ 个任务需要按照一定的顺序执行。
  如果任务之间存在依赖关系，即某些任务必须在其他任务执行完毕之后才能开始执行，
  那么我们可以将这些任务和它们之间的依赖关系表示成一个有向无环图，
  并通过拓扑排序来确定任务的执行顺序。
] <exmp:task-scheduling>

#rem[
  在数学中，定义和定理是数学推理的基础，而引理和命题则通常作为定理证明的中间步骤。
  而且在数学研究中，猜想和猜测往往需要大量的证明和反证，才能得到确定的结论。
] <rem:note>

#thm[
  对于任意正整数 $n$，有 $sum_(i=1)^n i = (n (n + 1))/2$。
] <thm:arithmetic-series>

#pf[
  设 $n$ 是任意正整数，则存在一个双射
  $f: {1, 2, dots, n} -> {n, n - 1, dots, 1}$，
  即将 ${1, 2, dots, n}$ 中的元素按照相反的顺序重新编号，使得 $f(i) = n - i + 1$。
  因此，我们有：
  $
    sum_(i=1)^n i &= 1 + 2 + dots + (n - 1) + n \
                  &= f(1) + f(2) + dots + f(n - 1) + f(n) \
                  &= (n + 1) dot n/2 \
                  &= (n (n + 1))/2.
  $
  因此，定理成立。
]
