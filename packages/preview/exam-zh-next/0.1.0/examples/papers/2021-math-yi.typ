// 2021 年全国乙卷数学（理科）的题目，供单份试卷和试卷合集共用。
// The paper only holds content; the including file applies `exam`.

#import "../../src/lib.typ": *

本试卷共 4 页，22 题。全卷满分 150 分。考试用时 120 分钟。

#notice[
    答卷前，考生务必将自己的姓名、考生号、考场号和座位号填写答题卡上，用2B铅笔将试卷类型（B）填涂在答题卡相应位置上，将条形码横贴在答题卡右上角“条形码粘贴处”。
][
    作答选择题时，选出每小题答案后，用2B铅笔在答题卡上对应题目选项的答案信息点涂黑；如需改动，用橡皮擦干净后，再选涂其他答案。答案不能答在试卷上。写在试卷、草稿纸和答题卡上的非答题区域均无效。
][
    非选择题必须用黑色字迹的钢笔或签字笔作答，答案必须写在答题卡各题目指定区域内相应位置上；如需改动，先划掉原来的答案，然后再写上新答案；不准使用铅笔和涂改液。不按以上要求作答无效。
][
    考生必须保持答题卡的整洁。考试结束后，将试卷和答题卡一并交回。
]

= 选择题：本题共 8 小题，每小题 5 分，共 40 分。在每小题给出的四个选项中，只有一项是符合题目要求的。

#question(points: 2)[
    设集合 $A = {x | -2 < x < 4}$，$B = {2, 3, 4, 5}$，则 $A inter B = $ #paren[B]
    #choices(answer: "B")[${2}$][${2, 3}$][${3, 4}$][${2, 3, 4}$]
]

#question[
    已知 $z = 2 - iu$，则 $z (overline(z) + iu) = $ #paren[C]
    #choices[$6 - 2 iu$][$4 - 2 iu$][$6 + 2 iu$][$4 + 2 iu$]
]

#question[
    已知圆锥的底面半径为 $sqrt(2)$，其侧面展开图为一个半圆，则该圆锥的母线长为 #paren()
    #choices[$2$][$2 sqrt(2)$][$4$][$4 sqrt(2)$]
]

#question[
    下列区间中，函数 $f(x) = 7 sin(x - uppi / 6)$ 单调递增的区间是 #paren()
    #choices[$(0, uppi / 2)$][$(uppi / 2, uppi)$][$(uppi, (3 uppi) / 2)$][$((3 uppi) / 2, 2 uppi)$]
]

#question[
    已知 $F_1$，$F_2$ 是椭圆 $C: x^2 / 9 + y^2 / 4 = 1$ 的两个焦点，点 $M$ 在 $C$ 上，则 $|M F_1| dot |M F_2|$ 的最大值为 #paren()
    #choices[$13$][$12$][$9$][$6$]
]

#question[
    若 $tan theta = -2$，则 $(sin theta (1 + sin 2 theta)) / (sin theta + cos theta) = $ #paren()
    #choices[$-6 / 5$][$-2 / 5$][$2 / 5$][$6 / 5$]
]

#question[
    若过点 $(a, b)$ 可以作曲线 $y = eu^x$ 的两条切线，则 #paren()
    #choices[$eu^b < a$][$eu^a < b$][$0 < a < eu^b$][$0 < b < eu^a$]
]

#question[
    有 $6$ 个相同的球，分别标有数字 $1$，$2$，$3$，$4$，$5$，$6$，从中有放回地随机取两次，每次取 $1$ 个球，甲表示事件“第一次取出的球的数字是 $1$”，乙表示事件“第二次取出的球的数字是 $2$”，丙表示事件“两次取出的球的数字之和是 $8$”，丁表示事件“两次取出的球的数字之和是 $7$”，则 #paren()
    #choices[甲与丙相互独立][甲与丁相互独立][乙与丙相互独立][丙与丁相互独立]
]

= 选择题：本题共 4 小题，每小题 5 分，共 20 分。在每小题给出的选项中，有多项符合题目要求。全部选对的得 5 分，部分选对的得 2 分，有选错的得 0 分。

#question[
    有一组样本数据 $x_1, x_2, dots, x_n$，由这组数据得到新样本数据 $y_1, y_2, dots, y_n$，其中 $y_i = x_i + c$（$i = 1, 2, dots, n$），$c$ 为非零常数，则 #paren()
    #choices[两组样本数据的样本平均数相同][两组样本数据的样本中位数相同][两组样本数据的样本标准差相同][两组样本数据的样本极差相同]
]

#question[
    已知 $O$ 为坐标原点，点 $P_1 (cos alpha, sin alpha)$，$P_2 (cos beta, -sin beta)$，$P_3 (cos(alpha + beta), sin(alpha + beta))$，$A(1, 0)$，则 #paren()
    #choices[
        $|arrow(O P_1)| = |arrow(O P_2)|$
    ][
        $|arrow(A P_1)| = |arrow(A P_2)|$
    ][
        $arrow(O A) dot arrow(O P_3) = arrow(O P_1) dot arrow(O P_2)$
    ][
        $arrow(O A) dot arrow(O P_1) = arrow(O P_2) dot arrow(O P_3)$
    ]
]

#question[
    已知点 $P$ 在圆 $(x - 5)^2 + (y - 5)^2 = 16$ 上，点 $A(4, 0)$，$B(0, 2)$，则 #paren()
    #choices[
        点 $P$ 到直线 $A B$ 的距离小于 $10$
    ][
        点 $P$ 到直线 $A B$ 的距离大于 $2$
    ][
        当 $angle P B A$ 最小时，$|P B| = 3 sqrt(2)$
    ][
        当 $angle P B A$ 最大时，$|P B| = 3 sqrt(2)$
    ]
]

#question[
    在正三棱柱 $A B C$-$A_1 B_1 C_1$ 中，$A B = A A_1 = 1$，点 $P$ 满足 $arrow(B P) = lambda arrow(B C) + mu arrow(B B_1)$，其中 $lambda in [0, 1]$，$mu in [0, 1]$，则 #paren()
    #choices[
        当 $lambda = 1$ 时，$triangle A B_1 P$ 的周长为定值
    ][
        当 $mu = 1$ 时，三棱锥 $P$-$A_1 B C$ 的体积为定值
    ][
        当 $lambda = 1 / 2$ 时，有且仅有一个点 $P$，使得 $A_1 P perp B P$
    ][
        当 $mu = 1 / 2$ 时，有且仅有一个点 $P$，使得 $A_1 B perp "平面" A B_1 P$
    ]
]

= 填空题：本题共 4 小题，每小题 5 分，共 20 分。

#question[
    已知函数 $f(x) = x^3 (a dot 2^x - 2^(-x))$ 是偶函数，则 $a = $ #fillin[$1$]。
    #solution[由 $f(x) = f(-x)$，得 $a = 1$。]
]

#question[
    已知 $O$ 为坐标原点，抛物线 $C: y^2 = 2 p x$（$p > 0$）的焦点为 $F$，$P$ 为 $C$ 上一点，$P F$ 与 $x$ 轴垂直，$Q$ 为 $x$ 轴上一点，且 $P Q perp O P$，若 $|F Q| = 6$，则 $C$ 的准线方程为 #fillin[$x = -3$]。
]

#question[
    函数 $f(x) = |2 x - 1| - 2 ln x$ 的最小值为 #fillin[$1 - 2 ln 2$]。
]

#question[
    某校学生在研究民间剪纸艺术时，发现剪纸时经常会沿纸的某条对称轴把纸对折。规格为 $20 "dm" times 12 "dm"$ 的长方形纸，对折 $1$ 次共可以得到 $10 "dm" times 12 "dm"$，$20 "dm" times 6 "dm"$ 两种规格的图形，它们的面积之和 $S_1 = 240 "dm"^2$，对折 $2$ 次共可以得到 $5 "dm" times 12 "dm"$，$10 "dm" times 6 "dm"$，$20 "dm" times 3 "dm"$ 三种规格的图形，它们的面积之和 $S_2 = 180 "dm"^2$，以此类推。则对折 $4$ 次共可以得到不同规格图形的种数为 #fillin[5]；如果对折 $n$ 次，那么 $sum_(k=1)^n S_k = $ #fillin[$480(1 - 2^(-n))$] $"dm"^2$。
]

= 解答题：本题共 6 小题，共 70 分。解答应写出文字说明、证明过程或演算步骤。

#problem(points: 10)[
    已知数列 ${a_n}$ 满足 $a_1 = 1$，$a_(n+1) = cases(a_n + 1\, quad n "为奇数，", a_n + 2\, quad n "为偶数。")$

    + 记 $b_n = a_(2n)$，写出 $b_1$，$b_2$，并求数列 ${b_n}$ 的通项公式；
    + 求 ${a_n}$ 的前 $20$ 项和。
]

#problem(points: 12)[
    某学校组织“一带一路”知识竞赛，有 A，B 两类问题。每位参加比赛的同学先在两类问题中选择一类并从中随机抽取一个问题回答，若回答错误则该同学比赛结束；若回答正确则从另一类问题中再随机抽取一个问题回答，无论回答正确与否，该同学比赛结束。A 类问题中的每个问题回答正确得 $20$ 分，否则得 $0$ 分；B 类问题中的每个问题回答正确得 $80$ 分，否则得 $0$ 分。

    已知小明能正确回答 A 类问题的概率为 $0.8$，能正确回答 B 类问题的概率为 $0.6$，且能正确回答问题的概率与回答次序无关。

    + 若小明先回答 A 类问题，记 $X$ 为小明的累计得分，求 $X$ 的分布列；
    + 为使累计得分的期望最大，小明应选择先回答哪类问题？并说明理由。
]

#problem(points: 12)[
    记 $triangle A B C$ 的内角 $A$，$B$，$C$ 的对边分别为 $a$，$b$，$c$。已知 $b^2 = a c$，点 $D$ 在边 $A C$ 上，$B D sin angle A B C = a sin C$。

    + 证明：$B D = b$；
    + 若 $A D = 2 D C$，求 $cos angle A B C$。
]

#problem(points: 12)[
    #textfigure[
        如图，在三棱锥 $A$-$B C D$ 中，$"平面" A B D perp "平面" B C D$，$A B = A D$，$O$ 为 $B D$ 的中点。

        + 证明：$O A perp C D$；
        + 若 $triangle O C D$ 是边长为 $1$ 的等边三角形，点 $E$ 在棱 $A D$ 上，$D E = 2 E A$，且二面角 $E$-$B C$-$D$ 的大小为 $45 degree$，求三棱锥 $A$-$B C D$ 的体积。
    ][
        #image("../assets/example-image.svg", width: 3cm)
    ]
]

#problem(points: 12)[
    在平面直角坐标系 $x O y$ 中，已知点 $F_1 (-sqrt(17), 0)$，$F_2 (sqrt(17), 0)$，点 $M$ 满足 $|M F_1| - |M F_2| = 2$。记 $M$ 的轨迹为 $C$。

    + 求 $C$ 的方程；
    + 设点 $T$ 在直线 $x = 1 / 2$ 上，过 $T$ 的两条直线分别交 $C$ 于 $A$，$B$ 两点和 $P$，$Q$ 两点，且 $|T A| dot |T B| = |T P| dot |T Q|$，求直线 $A B$ 的斜率与直线 $P Q$ 的斜率之和。
]

#problem(points: 12)[
    已知函数 $f(x) = x (1 - ln x)$。

    + 讨论 $f(x)$ 的单调性；
    + 设 $a$，$b$ 为两个不相等的正数，且 $b ln a - a ln b = a - b$，证明：$2 < 1 / a + 1 / b < eu$。

    #solution[
        函数的定义域为 $(0, +infinity)$，又
        $ f'(x) = 1 - ln x - 1 = -ln x, #score(2) $
        当 $x in (0, 1)$ 时，$f'(x) > 0$，当 $x in (1, +infinity)$ 时，$f'(x) < 0$，故 $f(x)$ 的递增区间为 $(0, 1)$，#score(1) 递减区间为 $(1, +infinity)$。#score(1)
    ]
]
