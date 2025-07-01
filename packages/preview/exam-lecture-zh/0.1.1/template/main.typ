#import "@preview/exam-lecture-zh:0.1.1": *
#show: setup.with(
  // paper: a3,
  mode: EXAM,
  // show-answer: true,
  seal-line-student-info: (
    姓名: underline[~~~~~~~~~~~~~],
    准考证号: inline-square(14),
    考场号: inline-square(2),
    座位号: inline-square(2),
  ),
)

#outline()
#chapter[2025新高考I卷]
#title[2025新高考I卷]
#subject[数学]
#secret

#notice(
  [答题前，请务必将自已的姓名、准考证号用0.5毫米黑色墨水的签字笔填写在试卷及答题卡的规定位置.],
  [请认真核对监考员在答题卡上所粘贴的条形码上的姓名、准考证号与本人是否相符.],
  [作答选择题必须用2B铅笔将答题卡上对应选项的方框涂满、涂黑；如需改动，请用橡皮擦干净后，再选涂其他答案.作答非选择题，必须用0.5毫米黑色墨水的签字笔在答题卡上的指定位置作答，在其他位置作答一律无效.],
  [本试卷共4页，满分150分，考试时间为120分钟.考试结束后，请将本试卷和答题卡一并交回.],
)
= 单选题：本题共 8 小题，每小题 5 分，共 40 分.在每小题给出的四个选项中，只有一项是符合题目要求的.
#question[
  $(1 + 5i)i$ 的虚部为 #paren[]
  #choices([$-1$], [$0$], [$1$], [$6$])
]
#question[
  集合 $U = {x | x "为小于9的正整数" }$, $A = {1,3,5}$, 则 $C_U A$ 中的元素个数为 #paren[]
  #choices([$0$], [$3$], [$5$], [$8$])
]
#question[
  若双曲线 $C$ 的虚轴长为实轴长的 7 倍，则 $C$ 的离心率为 #paren[]
  #choices([$sqrt(2)$], [$2$], [$sqrt(7)$], [$2sqrt(2)$])
]
#question[
  若点 $(a,0) (a > 0)$ 是函数 $y = 2tan(x - pi / 3)$ 的图象的一个对称中心，则 $a$ 的最小值为 #paren[]
  #choices([$30°$], [$60°$], [$90°$], [$135°$])
]
#question[
  设 $f(x)$ 是定义在 $bb(R)$ 上且周期为 2 的偶函数，当 $2 <= x <= 3$ 时，$f(x) = 5 - 2x$，则 $f(-3 / 4 ) =$ #paren[]
  #choices([$-1 / 2$], [$-1 / 4$], [$1 / 4$], [$1 / 2$])
]
#question[
  已知视风速是真风速和船风速的和向量，船风速与船行驶速度大小相等，方向相反.则真风速等级是 #paren[]
  #text-figure(
    text: choices(
      column: 1,
      [轻风 (1.6$tilde$3.3 m/s)],
      [微风 (3.4$tilde$5.4 m/s)],
      [和风 (5.5$tilde$7.8 m/s)],
      [劲风 (8.0$tilde$10.7 m/s)],
    ),
    image("2025-1-6.png", width: 50%),
  )
]
#question[
  若圆 $x^2 + (y + 2)^2 = r^2 (r > 0)$ 上到直线 $y = sqrt(3)x + 2$ 的距离为 1 的点有且仅有 2 个，则 $r$ 的取值范围是 #paren[]
  #choices([(0, 1)], [(1, 3)], [(3, +∞)], [(0, +∞)])
]
#question[
  若实数 $x, y, z$ 满足 $2 + log_2 x = 3 + log_3y = 5 + log_5 z$，则 $x, y, z$ 的大小关系不可能是 #paren[]
  #choices([$x > y > z$], [$x > z > y$], [$y > x > z$], [$y > z > x$])
]
= 多选题：本题共 3 小题，每小题 6 分，共 18 分.在每小题给出的选项中，有多项符合题目要求.全部选对的得 6 分，部分选对的得部分分，有选错的得 0 分.

#question[
  在正三棱柱 $A B C-A_1B_1C_1$ 中，$D$ 为 $B C$ 中点，则 #paren[]
  #choices([$A D perp A_1C$], [$B_1C perp "平面" A A_1D$], [$C C_1 parallel "平面" A A_1D$], [$A D parallel A_1B_1$])
]
#question[
  设抛物线 $C: y^2 = 6x$ 的焦点为 $F$，过 $F$ 的直线交 $C$ 于$A、B$，过 $F$ 且垂直于 $A B$的直线交准线 $l$: $y = -3 / 2x$ 于 $E$，过点$A$作准线的垂线，垂足为$D$，则 #paren[]
  #choices([$|A D| = |A F|$], [$|A E| = |A B|$], [$|A B| >= 6$], [$|A E| dot |B E| >= 18$])
]
#question[
  已知 $triangle A B C$ 的面积为 $1 / 4$，若 $cos 2A + cos 2B + cos 2C = 2,cos A cos B sin C = 1 / 4$，则 #paren[]
  #choices([$sin C = sin^2 A + sin^2 B$], [$A B = sqrt(2)$], [$sin A + sin B = sqrt(6) / 2$], [$A C^2 + B C^2 = 3$])
]
= 填空题：本题共 3 小题，每小题 5 分，共 15 分.
#question[
  若直线 $y = 2x + 5$ 是曲线 $y = e^x + x + a$ 的切线，则 $a =$#fillin[].
]
#question[
  若一个正项等比数列的前 4 项和为 4，前 8 项和为 68，则该等比数列的公比为 #fillin[].
]
#question[
  一个箱子里有 5 个球，分别以 1$tilde$5 标号，若有放回取三次，记至少取出一次的球的个数 $X$，则 $E(X) =$#fillin[].
]
= 解答题：本题共 5 小题，共 77 分.解答应写出文字说明、证明过程或演算步骤.
#question(points: 13, bottom: 2in)[
  为研究某疾病与超声波检查结果的关系，从做过超声波检查的人群中随机调查了1000人，得到如下的列联表：
  #align(center)[
    #table(
      columns: 4,
      [], [正常], [不正常], [合计],
      [患该疾病], [20], [180], [200],
      [未患该疾病], [780], [20], [800],
      [合计], [800], [200], [1000],
    )
  ]
  + 记超声波检查结果不正常者患有该疾病的概率为$p$，求$p$的估计值；
  + 根据小概率值$alpha=0.001$的独立性检验，分析超声波检查结果是否与患该疾病有关.

  #text-figure(text: [ 附：$chi^2 = n(a d - b c)^2 / ((a + b)(c + d)(a + c)(b + d))$.], figure-x: 1in, table(
    columns: 4,
    [$P(chi^2 >= k)$], [0.005], [0.010], [0.001],
    [$k$], [3.841], [6.635], [10.828],
  ))
]
#question(points: 15, bottom: 1in)[
  设数列 ${a_n}$ 满足 $a_(n+1) / n = a_n / (n+1) + 1 / (n(n+1))$.
  + 证明：${n a_n}$ 为等差数列；
  + 设 $f(x) = a_1x + a_2x^2 + ... + a_m x^m，求 f'(2)$.
]
#question(points: 15, bottom: 2in)[
  如图所示的四棱锥 $P - A B C D$ 中，$P A perp "平面" A B C D, B C parallel A D, A B perp A D$.
  #image("2025-1-17.png", width: 30%)
  + 证明：平面 $P A B perp "平面" P A D$
  + 若 $P A = A B = sqrt(2), A D = sqrt(3) + 1, B C = 2$，$P, B, C, D$ 在同一个球面上，设该球面的球心为 $O$.
    + 证明：$O$ 在平面 $A B C D$上；
    + 求直线 $A C$ 与直线 $P O$ 所成角的余弦值.

]
#question(points: 17, bottom: 2in)[
  设椭圆 $C: x^2 / a^2 + y^2 / b^2 = 1 (a > b > 0)$，记 $A$为椭圆下端点，$B$ 为右端点，$|A B| = sqrt(10)$，且椭圆 $C$ 的离心率为 $(2sqrt(2)) / 3$.
  + 求椭圆的标准方程；
  + 设点 $P(m, n)$.
    + 若 $P$ 不在 $y$ 轴上，设 $R$ 是射线 $A P$ 上一点，$|A R| dot |A P| = 3$，用 $m, n$ 表示点 $R$ 的坐标；
    + 设直线$O Q$ 的斜率为 $k_1$，直线 $O P$ 的斜率为 $k_2$，若 $k_1 = 3k_2$，$M$为椭圆上一点，求 $|P M|$ 的最大值.
]
#question(points: 17, bottom: 2in)[
  设函数 $f(x) = 5cos x - cos 5x$.
  + 求 $f(x)$ 在 $[0, pi / 4]$ 的最大值；
  + 给定 $theta in (0, pi)，a$ 为给定实数，证明：存在 $y in [a - theta, a + theta]$，使得 $cos y <= cos theta$；
  + 若存在 $phi$，使得对任意 $x$，都有 $5cos x - cos(5x + phi) <= b$，求 $b$ 的最小值.
]



#chapter[2025新高考II卷]
#title[2025新高考II卷]
#subject[数学]
#secret
#notice(
  [答题前，请务必将自已的姓名、准考证号用0.5毫米黑色墨水的签字笔填写在试卷及答题卡的规定位置.
  ],
  [请认真核对监考员在答题卡上所粘贴的条形码上的姓名、准考证号与本人是否相符.
  ],
  [作答选择题必须用2B铅笔将答题卡上对应选项的方框涂满、涂黑；如需改动，请用橡皮擦干净后，再选涂其他答案.作答非选择题，必须用0.5毫米黑色墨水的签字笔在答题卡上的指定位置作答，在其他位置作答一律无效.
  ],
  [本试卷共4页，满分150分，考试时间为120分钟.考试结束后，请将本试卷和答题卡一并交回.],
)
= 单选题：本题共 8 小题，每小题 5 分，共 40 分.在每小题给出的四个选项中，只有一项是符合题目要求的.
#question[
  样本数据 $2$, $8$, $14$, $16$, $20$ 的平均数为#paren[]
  #choices([$8$], [$9$], [$12$], [$18$])
]
#question[
  已知 $z = 1 + i$，则 $1 / (z - 1) =$#paren[]
  #choices([$-i$], [$i$], [$-1$], [$1$])
]
#question[
  已知集合 $A = {-4, 0, 1, 2, 8}$，$B = {x | x^3 = x}$，则 $A inter B =$#paren[]
  #choices([${0, 1, 2}$], [${1, 2, 8}$], [${2, 8}$], [${0, 1}$])
]
#question[
  不等式 $(x-4) / (x-1) >= 2$ 的解集是#paren[]
  #choices([${x | -2 <= x <= 1}$], [${x | x <= -2}$], [${x | -2 <= x < 1}$], [${x | x > 1}$])
]
#question[
  在 $triangle A B C$ 中，$B C = 2$，$A C = 1 + sqrt(3)，A B = sqrt(6)$，则 $A =$#paren[]
  #choices([$45degree$], [$60degree$], [$120degree$], [$135degree$])
]
#question[
  设抛物线 $C: y^2 = 2p x (p > 0)$ 的焦点为 $F$，点 $A$ 在 $C$ 上，过 $A$ 作 $C$ 准线的垂线，垂足为 $B$.若直线 $B F$ 的方程为 $y = -2x + 2$，则 $|A F| =$#paren[]
  #choices([$3$], [$4$], [$5$], [$6$])
]
#question[
  记 $S_n$ 为等差数列 ${a_n}$ 的前 $n$ 项和，若 $S_3 = 6$, $S_5 = -5$，则 $S_6 =$ #paren[]
  #choices([$-20$], [$-15$], [$-10$], [$-5$])
]
#question[
  已知 $0 < alpha < pi$, $cos(alpha / 2) = sqrt(5) / 5$，则 $sin(alpha - pi / 4) =$ #paren[]
  #choices([$sqrt(2) / 10$], [$sqrt(2) / 5$], [$(3sqrt(2)) / 10$], [$(7sqrt(2)) / 10$])
]
= 多选题：本题共 3 小题，每小题 6 分，共 18 分.在每小题给出的选项中，有多项符合题目要求.全部选对的得 6 分，部分选对的得部分分，有选错的得 0 分.

#question[
  记 $S_n$ 为等比数列 ${a_n}$ 的前 $n$ 项和，$q$ 为 ${a_n}$ 的公比，$q > 0$.若 $S_3 = 7$, $a_3 = 1$，则 #paren[]
  #choices([$q = 1 / 2$], [$a_5 = 1 / 9$], [$S_8 = 8$], [$a_n + S_n = 8$])
]
#question[
  已知 $f(x)$ 是定义在 $RR$ 上的奇函数，且当 $x > 0$ 时，$f(x) = (x^2 - 3)e^x + 2$，则 #paren[]
  #choices(
    [$f(0) = 0$],
    [当 $x < 0$ 时，$f(x) = -(x^2 - 3)e^(-x) - 2$],
    [$f(x) >= 2$，当且仅当 $x >= sqrt(3)$],
    [$x = -1$ 是 $f(x)$ 的极大值点],
  )
]
#question[
  双曲线 $C: x^2 / a^2 - y^2 / b^2 = 1 (a > 0, b > 0)$ 的左、右焦点分别是 $F_1, F_2$，左、右顶点分别为 $A_1, A_2$，以 $F_1F_2$ 为直径的圆与曲线 $C$ 的一条渐近线交于 $M, N$ 两点，且 $angle N A_1M = (5pi) / 6$，则 #paren[]
  #choices(
    [$angle A_1M A_2 = pi / 6$],
    [$|M A_1| = 2|M A_2|$],
    [$C$ 的离心率为 $sqrt(13)$],
    [当 $a = sqrt(2)$ 时，四边形 $N A_1M A_2$ 的面积为 $8sqrt(3)$],
  )
]
= 填空题：本题共 3 小题，每小题 5 分，共 15 分.
#question[
  已知平面向量 $a = (x, 1)$, $b = (x - 1, 2x)$, 若 $a perp (a - b)$, 则 $|a| =$ #fillin[].
]
#question[
  若 $x = 2$ 是函数 $f(x) = (x - 1)(x - 2)(x - a)$ 的极值点，则 $f(0) =$ #fillin[].
]
#question[
  一个底面半径为$4$cm，高为$9$cm的封闭圆柱形容器（容器壁厚度忽略不计）内有两个半径相等的铁球，则铁球半径的最大值为 #fillin[]cm.
]
= 解答题：本题共 5 小题，共 77 分.解答应写出文字说明、证明过程或演算步骤.
#question(points: 13, bottom: 2in)[
  已知函数 $f(x) = cos(2x + phi)$ ($0 <= phi < pi$), $f(0) = 1 / 2$.
  + 求 $phi$;
  + 设函数 $g(x) = f(x) + f(x - pi / 6)$, 求 $g(x)$ 的值域和单调区间.
]
#question(points: 15, bottom: 2in)[
  已知椭圆 $C: x^2 / a^2 + y^2 / b^2 = 1 (a > b > 0)$ 的离心率为$sqrt(2) / 2$, 长轴长为 4,
  + 求 $C$ 的方程;
  + 过点 $(0,$-2$)$ 的直线 $l$ 与 $C$ 交于 $A$, $B$ 两点, $O$ 为坐标原点. 若 $triangle O A B$ 的面积为 $sqrt(2)$, 求 $|A B|$.
]
#question(points: 15, bottom: 2in)[
  如图，四边形 $A B C D$ 中，$A B || C D$, $angle D A B = 90^degree$, $F$ 为 $C D$ 中点, $E$ 在 $A B$ 上, $E F || A D$, $A B = 3A D$, $C D = 2A D$, 将四边形 $E F D A$ 沿 $E F$ 翻折至四边形 $E F D'A'$, 使得面 $E F D'A'$ 与面 $E F C B$ 所成的二面角为 $60^degree$.
  #text-figure(
    text: [
      + 证明: $A'B ||$ 平面 $C D'F$.
      + 求面 $B C D'$ 与面 $E F D'A'$ 所成二面角的正弦值.
    ],
    top: -30pt,
    figure-x: .35in,
  )[#image("2025-2-17.png")]

]
#question(points: 17, bottom: 2in)[
  已知函数 $f(x) = ln(1 + x) - x + 1 / 2x^2 - k x^3$, 其中 $0 < k < 1 / 3$.
  + 证明: $f(x)$ 在区间 $(0, +infinity)$ 存在唯一的极值点和唯一的零点;
  + 设 $x_1$, $x_2$ 分别为 $f(x)$ 在区间 $(0, +infinity)$ 的极值点和零点.
    + 设函数 $g(t) = f(x, t) - f(x, -t)$, 证明: $g(t)$ 在区间 $(0, x_1)$ 单调递减;
    + 比较 $2x_1$ 与 $x_2$ 的大小, 并证明你的结论.
]
#question(points: 17)[
  甲、乙两人进行乒乓球练习，每个球胜者得1分、负者得0分.设每个球甲胜的概率为 $p$ ($1 / 2 < p < 1$), 乙胜的概率为 $q$, $p + q = 1$, 且各球的胜负相互独立, 对正整数 $k >= 2$, 记 $p_k$ 为打完 $k$ 个球后甲比乙至少多得2分的概率, $q_k$ 为打完 $k$ 个球后乙比甲至少多得2分的概率.
  #block[
    + 求 $p_3$, $p_4$ (用 $p$ 表示)
    + 若 $(p_5 - p_3) / (q_4 - q_3) = 4$, 求 $p$;
    + 证明: 对任意正整数 $m$, $p_(2m+1) - q_(2m+1) < p_(2m) - q_(2m) < p_(2m+2) - q_(2m+2)$.
  ]
]

#explain[
  先求解 $(x-a)(x-2)>0$, $a$ 与 2 的大小不确定,需讨论。记 $(x-a)(x-2)>0$ 的解集为 $A$, $B=(-1,1)$, 题干的条件等价于 $B subset A$.

  当 $a=2$ 时, $(x-a)(x-2)>0$ 即为 $(x-2)^2 > 0$, 解得：$x != 2$, $therefore$ $A=(-infinity,2)(2, +infinity)$, 满足 $B subset A$;#score[3]

  当 $a>2$ 时, $(x-a)(x-2)>0 => x<2 "或" x>a$, $therefore$ $A=(-infinity,2)(a, +infinity)$,如图1满足 $B subset A$;#score[5]

  当 $a<2$ 时, $(x-a)(x-2)>0 => x<a$ 或 $x>2$, $therefore$ $A=(-infinity,a)(2, +infinity)$, 如图2,若要满足 $B subset A$ 应有 $1 < a<2$;#score[7]

  综上所述,实数 $a$ 的取值范围是 $[1,+infinity)$。#score[10]
]



