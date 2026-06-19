// Note: 为方便调试，此处使用相对路径。
#import "/src/lib.typ": *

// Note: 使用`show: shuxuejuan`，将常用函数绑定到内置的`heading`，`ref`等上。
#show: shuxuejuan

// Note: 以下内容可选择性开启或设置，去掉注释看看有何变化？
// DNF: 此处多次调用`env-upd`会引发`convergence`问题与bug，故单次请勿取消过多行注释。
// #context env-upd(font-size: env-get("font-size") + (medium: 11pt))
// #context env-upd(qst-style: COMPOSER.GRID)
// #context env-upd(fn-number: sxj-counter-with-acc-to-nums-normal)  // Note: 常用
// #context env-upd(qst-tag-w: (auto, 1em, 1em))
// #context env-upd(ans-shown: false)  // Note: 常用
// #context env-upd(ans-color: color.rgb(238, 0, 0))
// #context env-upd(ref-style: 1)

// Note: 为了字体，页面更好看的设置。
#set page(margin: (top: 19pt))
#set text(font: "Noto Serif CJK SC")
#show text.where(weight: "bold").or(text.where(weight: "extrabold")): set text(font: "LXGW WenKai Mono")
#show math.equation: set text(font: "STIX Two Math")

// Note: 为了使用更方便的函数绑定。
#let ans_ = sxj-answer
#let cu = sxj-counter-question-update.with(level: 3)
#let num(n) = numbering("①", n)

#set document(title: "不知名的小测")

#title()

#si()

= 选择题

== 下列各说法中正确的是#br[BCD]。#op(
  $emptyset in emptyset$,
  $emptyset subset.eq emptyset$,
  $emptyset in {emptyset}$,
  $emptyset subset.eq {emptyset}$,
)

== 下列二元一次方程组中#br[AD]可直接用两式相加消去其中一个未知数。#op(
  $cases(-&2x+3y=2, &2x+2y=3)$,
  $cases(y+2x=0, x=2y)$,
  $cases(&2x+3y=2, &3x-2y=3)$,
  $cases(-&y=3x, &y=5x-2)$,
)

== 下列各说法中正确的是#br[B]。#op(
  [若$a c = b c$，则$a=b$。],
  [若$a/c = b/c$，则$a=b$。],
  [若$abs(a) = abs(b)$，则$a=b$。],
  [若$a^2 = b^2$，则$a=b$。],
)

= 填空题

== #grid(
  columns: (1fr, auto),
  column-gutter: .5em,
  [
    称平面直角坐标系中横、纵坐标均为正整数的点为“正点”，正点$(x,y)$可按右表规则移动。若正点$P$按此规则连续移动$10$次至$P_10 (38,16)$，则$P$坐标为#bl[$(3,1)$或$(7,2)$]。
  ],
  table(
    columns: 5,
    align: center + horizon,
    [$x+3y$除以\ $4$得到余数], $0$, $1$, $2$, $3$,
    [移动方式], [上移$2$], [右移$3$], [上移$3$], [右移$7$],
  ),
)

= 解答题

#let fsum = math.op(math.plus.o)
== 若$p,q in NN^+,gcd(p, q)=1$，则称$p/q$为“既约分数”。定义$QQ^+$上的Farey和：$p_1/q_1 fsum p_2/q_2 := (p_1+p_2)/(q_1+q_2)$，其中$p_1/q_1,p_2/q_2$均为既约分数。对平面上一条数轴与既约分数$p/q$，定义Ford圆$F(p/q)$：与数轴上表示$p/q$的点相切，在数轴“上方”以$1/q^2$为直径的一个圆。证明以下命题。#[
  #context v(-par.leading)
  === 对满足$abs(p_1q_2-p_2q_1)=1$的既约分数$p_1/q_1$与$p_2/q_2$，有$F(p_1/q_1)$与$F(p_2/q_2)$相外切。<qst-ford-2-circle>
  #context v(-par.leading)
  === 对任意既约分数$a,b,c(a!=b,c=a fsum b)$，若$F(a)$与$F(b)$相切，则$F(c)$与$F(a),F(b)$均相切。
]<qst-ford>

#cu()
#context v(par.leading)

#ans(ans-type: SXJ-BODY-TYPE.ANS.PF, composer: COMPOSER.GRID)[
  === #grid(
    columns: (1fr, 1fr),
    [
      两圆圆心：

      垂直距离$d_y=1/2 abs(1/q_1^2-1/q_2^2)=(abs(q_1^2-q_2^2))/(2 q_1^2 q_2^2)$，

      水平距离$d_x=abs(p_1/q_1-p_2/q_2)=abs(p_1q_2-p_2q_1)/(q_1 q_2)$。

      两圆相外切时圆心距$d=1/2(1/q_1^2+1/q_2^2)$。],
    [
      $because&d^2-d_y^2=d_x^2\
      <=>&(1/q_1^2+1/q_2^2)^2-(1/q_1^2-1/q_2^2)^2=4(p_1q_2-p_2q_1)^2/(q_1^2q_2^2)\
      <=>&1=(p_1q_2-p_2q_1)^2$

      $therefore$两圆相外切。
    ],
  )

  === #[
    设$a,b$的既约分数表达分别为$p_1/q_1,p_2/q_2$，注意到$abs(p_1(q_1+q_2) - (p_1+p_2)q_1)=abs(p_1q_2-p_2q_1)=1$，\
    故$gcd(p_1+p_2, q_1+q_2)=1$，$c$的既约分数表达即为$(p_1+p_2)/(q_1+q_2)$，且$a,c$满足 @qst-ford-2-circle 中条件。\
    故$F(c)$与$F(a)$相切，同理$F(c)$与$F(b)$相切。
  ]
]

= 附加题

#context v(par.leading)

#qg(
  gutter: auto,
  $-2sqrt(3)-2-sqrt(3)$,
  ans(composer: COMPOSER.GRID)[
    $"原式" & = (-2-1)sqrt(3)-2\
    & = -3sqrt(3)-2$
  ],
  $cases(x+1<2 &#ans_(num(1)), 3x>6 &#ans_(num(2)))$,
  {
    context v(par.leading)
    ans[#grid(
      columns: (auto, auto),
      column-gutter: 1em,
      [
        解#num(1)得：$x<1$\
        解#num(2)得：$x>2$
      ],
      [
        $therefore$原不等式组解集为空。
      ],
    )]
  },
)

#context v(par.leading)

#qg(
  level: 2,
  batcher: sxj-qg-bchr-tf,
  [同一平面上$4$条直线可恰有$2$个交点],
  sym.crossmark,
  [$pi + 1/2$是无理数],
  sym.checkmark,
)

== 对 @qst-ford 的补充：自备纸张，证明对$a,b in NN^+$，$gcd(a, b)=1<=>exists u,v in ZZ, u a + v b = 1$。
