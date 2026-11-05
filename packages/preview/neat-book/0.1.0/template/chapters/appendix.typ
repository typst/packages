#import "@preview/neat-book:0.1.0": *

= 记号与约定 <app-symbols>

#introduction[本附录汇总书中使用的记号，并展示独立的字母章号。]

== 常用记号

#table(
  columns: (1fr, 3fr),
  table.header([*记号*], [*含义*]),
  $NN$, [自然数集合],
  $ZZ$, [整数集合],
  $a divides b$, [$a$ 整除 $b$],
  $gcd(a,b)$, [$a$ 与 $b$ 的最大公因数],
)

=== 求和公式

$ sum_(k=1)^n k = (n(n+1))/2. $ <eq-appendix>

#theorem(title: "等差数列求和")[
  @eq-appendix 对任意正整数 $n$ 成立。
] <thm-appendix>

#proof[
  将 $1+2+dots+n$ 与 $n+(n-1)+dots+1$ 对齐相加，
  每一列都等于 $n+1$，共 $n$ 列，故原和为 $n(n+1)/2$。
]

正文的 @eq-gcd 与附录的 @eq-appendix 保留各自编号；@thm-appendix 也可以从正文引用。
