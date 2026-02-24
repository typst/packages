#import "../lib.typ": *
#show: shuxuejuan.with(
  // font: ("SimSun",),
  // font-bold: ("LXGW WenKai Mono",),
  qst-number-level2: auto,
)

#set document(title: "数学卷")

#title()

#si()

#title-small[第一章 基本功能展示]

= 解答题（共$4$小题，$10$分）

== （$1$分）试说明当$n$为不小于$2$的正整数时，关于$x,y,z$的方程$x^n+y^n=z^n$没有正整数解。

=== $x+y=1$时，情况如何？

=== $x-y=1$时，$z>2$吗？

#v(3em)

== （$2$分）小明用$8$#un([km/h])的速度跑了$4$#un([km])，那么他跑了多久？#[
  === 小明不跑了，他跑了多久？
  === 小明倒着跑，他能跑吗？
]

#v(6em)

== （$3$分）试说明$integral_(0)^(+infinity)(sin x)/x mono(d)x$的敛散性。若收敛，求其值。

#v(6em)

#with-env(
  qst-align-number: "One-Lined-Compact",
  [
    == （$4$分）求$sum_(k=1)^(+infinity)(2k+1)/(3^k)$。
  ],
)

#v(6em)

= 填空题（本大题共$3$小题，每小题$3$分，共$9$分）

== 将无限循环小数$0 . accent(2,dot) dot(3)$化为分数是#bl([],scale: 2)。

== 利用@test，计算$1-0 . accent(9,dot)=$#bl([])。

#pgbk()

= 选择题（本大题共$3$小题，每小题$5$分，共$15$分）

== $(x-1)(x-2)>0$能推出#br([])。#op(
  [$x=-1$],[$x=0$],[$x=+1$],[$x=+2$],
  [$x=+3$],[$x=+3$],[$x=+3$],[$x=+3$]
)<test>

== 这题很长，选个不对的是#br([])。#op([我说的不对，选下一个],[我说的对，选上一个],[他们说的都不对，选第一个],[上一个说的对，选我])

== #grid(
  columns: (1fr, 1fr),
  align: (left, center),
  [这题选个对：#br([])，不对。不对？对。#op(
    col:1,
    [对],
    [不对]
    )],
  [#table(
      columns: 6,
      [*哈哈*], [A], [B], [C], [D], [E],
      [*嘻嘻*], [$1$], [$-1$], [$-2$], [$2$], [$-3$],
    )],
)

= 计算题（共$2$小题，共$49$分）

== 简单计算（本大题共$5$小题，每小题$5$分，共$25$分）

#qg(
  preprocessor: sxj-qg-pcs-std,
  level: 3,
  col: 3,
  gutter: 3em,
  [$1+1$],
  [$1+2$],
  [$1+(-1)$],
  [$(-1) times 1 + ( -(-1) )$],
  [$(-1) times 2 + ( -(-2) )$],
)

== 复杂计算（本大题共$4$小题，每小题$6$分，共$24$分）

#qg(
  gutter: 6em,
  [$sum_(i=1)^(+infinity)1 / (i(i+1))$],
  [$1 - 1 / 2 + 1 / 3 - 1 / 4 + dots.c$],
  [$integral sech x space mono(d)x$],
  [$ln mono(e)^pi$],
)

= 判断题（本大题共$8$小题，每小题$2$分，共$16$分）

#qg(
  preprocessor: sxj-qg-pcs-tf,
  [啊对的，对的],
  [啊不对，不对],
  [啊对，不对],
  [对的，对的],
)

== #br([])根据@test，这题是对的,然后我再凑点字数；

#qg(
  preprocessor: sxj-qg-pcs-tf,
  level: 2,
  col: 3,
  [这题是对的],
  [啊不对],
  [对对对的],
)

#title-small[第二章 语法糖]

#rn()

= 解答题（共$4$小题，$10$分）

== （$1$分）试说明当$n$为不小于$2$的正整数时，关于$x,y,z$的方程$x^n+y^n=z^n$没有正整数解。

=== $x+y=1$时，情况如何？

=== $x-y=1$时，$z>2$吗？

#v(3em)

== （$2$分）小明用$8$#un[km/h]的速度跑了$4$#un[km]，那么他跑了多久？#[
  === 小明不跑了，他跑了多久？
  === 小明倒着跑，他能跑吗？
]

#v(6em)

== （$3$分）试说明$integral_(0)^(+infinity)(sin x)/x mono(d)x$的敛散性。若收敛，求其值。

#v(6em)

#with-env(qst-align-number: "One-Lined-Compact")[
  == （$4$分）求$sum_(k=1)^(+infinity)(2k+1)/(3^k)$。
]

#v(6em)

= 填空题（本大题共$3$小题，每小题$3$分，共$9$分）

== 将无限循环小数$0 . accent(2,dot) dot(3)$化为分数是#bl(scale: 2)[]。

== 利用@test_，计算$1-0 . accent(9,dot)=$#bl[]。

#pgbk()

= 选择题（本大题共$3$小题，每小题$5$分，共$15$分）

== $(x-1)(x-2)>0$能推出#br[]。#op(
  $x=-1$,$x=0$,$x=+1$,$x=+2$,
  $x=+3$,$x=+3$,$x=+3$,$x=+3$
)

== 这题很长，选个不对的是#br[]。#op[我说的不对，选下一个][我说的对，选上一个][他们说的都不对，选第一个][上一个说的对，选我]

== #grid(
  columns: (1fr, 1fr),
  align: (auto, center),
  [这题选个对：#br[]，不对。#op(col:1)[对][不对]
  ],
  [#table(
      columns: 6,
      [*哈哈*], [A], [B], [C], [D], [E],
      [*嘻嘻*], $1$, $-1$, $-2$, $2$, $-3$,
    )],
)<test_>

= 计算题（共$2$小题，共$49$分）

== 简单计算（本大题共$5$小题，每小题$5$分，共$25$分）

#qg(
  preprocessor: sxj-qg-pcs-std,
  level: 3,
  col: 3,
  gutter: 3em,
)[
  $1+1$
][
  $1+2$
][
  $1+(-1)$
][
  $(-1) times 1 + ( -(-1) )$
][
  $(-1) times 2 + ( -(-2) )$
]


== 复杂计算（本大题共$4$小题，每小题$6$分，共$24$分）

#qg(
  gutter: 5.847em,
  $sum_(i=1)^(+infinity)1 / (i(i+1))$,
  $1 - 1 / 2 + 1 / 3 - 1 / 4 + dots.c$,
  $integral sech x space mono(d)x$,
  $ln mono(e)^pi$,
)

= 判断题（本大题共$8$小题，每小题$2$分，共$16$分）

#qg(preprocessor: sxj-qg-pcs-tf)[啊对的，对的][啊不对，不对][啊对，不对][对的，对的]

== #br[]根据@test_，这题是对的,然后我再凑点字数；

#qg(
  preprocessor: sxj-qg-pcs-tf,
  level: 2,
  col: 3,
)[这题是对的][啊不对][对对对的]
