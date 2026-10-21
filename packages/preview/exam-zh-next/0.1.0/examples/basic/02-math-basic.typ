// 数学期末考试：选择、填空、带评分点的解答题。
// 教师版：typst compile --input exam-mode=teacher 02-math-basic.typ 02-math-basic-teacher.pdf

#import "../../src/lib.typ": *

#show: exam.with(
    title: [2024年秋季期末考试],
    subject: [数学],
    page: (foot: "数学试题第;页（共;页）"),
)

#make-title()

#let blank(width) = box(width: width, stroke: (bottom: 0.5pt))
#information([姓名#blank(6em)], [班级#blank(6em)], [学号#blank(6em)], separator: h(2em))

#notice[本试卷共 3 大题，满分 100 分，考试时间 120 分钟。][请用黑色签字笔在答题卡上作答，在试卷上作答无效。][考试结束后，将试卷和答题卡一并交回。][可以使用计算器。]

= 选择题（本题共 8 小题，每小题 5 分，共 40 分）

#question[
    已知集合 $A = {x | x^2 - 3x + 2 = 0}$，$B = {1, 2, 3}$，则 $A union B = $ #paren[C]
    #choices(answer: "C")[${1}$][${1, 2}$][${1, 2, 3}$][${2, 3}$]
]

#question[
    函数 $f(x) = ln(x + 1)$ 的定义域是 #paren[B]
    #choices(answer: "B")[$RR$][$(-1, +infinity)$][$[0, +infinity)$][$(-infinity, -1)$]
]

#question[
    若复数 $z = 1 + iu$（$iu$ 为虚数单位），则 $|z| = $ #paren[D]
    #choices(answer: "D")[$1$][$iu$][$2$][$sqrt(2)$]
]

#question[
    已知向量 $vect(a) = (2, 1)$，$vect(b) = (-1, 3)$，则 $vect(a) dot vect(b) = $ #paren[A]
    #choices(answer: "A")[$1$][$-1$][$5$][$-5$]
]

#question[
    等比数列 ${a_n}$ 中，$a_1 = 2$，$a_3 = 8$，则 $a_5 = $ #paren[C]
    #choices(answer: "C")[$16$][$24$][$32$][$64$]
]

#question[
    已知 $cos alpha = 3 / 5$，且 $alpha in (0, uppi / 2)$，则 $sin alpha = $ #paren[B]
    #choices(answer: "B")[$3 / 5$][$4 / 5$][$5 / 4$][$5 / 3$]
]

#question[
    圆 $(x - 1)^2 + (y + 2)^2 = 9$ 的圆心坐标和半径分别是 #paren[A]
    #choices(answer: "A")[$(1, -2)$，$3$][$(-1, 2)$，$3$][$(1, -2)$，$9$][$(-1, 2)$，$9$]
]

#question[
    函数 $f(x) = eu^x - x$ 的零点所在的区间是 #paren[D]
    #choices(answer: "D")[$(-1, 0)$][$(1, 2)$][$(2, 3)$][$(0, 1)$]
]

= 填空题（本题共 4 小题，每小题 5 分，共 20 分）
#exam-setup(question: (index: 1))

#question[若 $f(x) = 2x^2 - 3x + 1$，则 $f(1) = $ #fillin[0]。]

#question[已知 $tan alpha = 2$，则 $display((sin alpha + cos alpha) / (sin alpha - cos alpha)) = $ #fillin[3]。]

#question[双曲线 $display(x^2 / 9 - y^2 / 16 = 1)$ 的渐近线方程为 #fillin[$y = plus.minus 4 / 3 x$]。]

#question[若 $(2x - 1)^5 = a_0 + a_1 x + a_2 x^2 + dots.c + a_5 x^5$，则 $a_0 + a_1 + a_2 + dots.c + a_5 = $ #fillin[1]。]

= 解答题（本题共 3 小题，共 40 分。解答应写出文字说明、证明过程或演算步骤）
#exam-setup(question: (index: 1))

#problem(points: 12)[
    已知函数 $f(x) = 2 sin x cos x + 2 sqrt(3) cos^2 x - sqrt(3)$。

    + 求 $f(x)$ 的最小正周期；
    + 求 $f(x)$ 在区间 $[0, uppi / 2]$ 上的最大值和最小值。

    #solution[
        + $f(x) = sin 2x + sqrt(3)(2 cos^2 x - 1)$ #score(2)
          $= sin 2x + sqrt(3) cos 2x$ #score(2)
          $= 2 sin(2x + uppi / 3)$。#score(2)
          所以最小正周期 $T = display((2 uppi) / 2) = uppi$。#score(2)
        + 当 $x in [0, uppi / 2]$ 时，$2x + uppi / 3 in [uppi / 3, (4 uppi) / 3]$，#score(2)
          当 $2x + uppi / 3 = uppi / 2$，即 $x = uppi / 12$ 时，$f(x)$ 取最大值 $2$；#score(1)
          当 $2x + uppi / 3 = (4 uppi) / 3$，即 $x = uppi / 2$ 时，$f(x)$ 取最小值 $-sqrt(3)$。#score(1)
    ]
]

#problem(points: 14)[
    在 $triangle A B C$ 中，角 $A$，$B$，$C$ 的对边分别为 $a$，$b$，$c$，已知 $a = 3$，$b = 2 sqrt(3)$，$cos C = 1 / 3$。

    + 求边 $c$ 的长；
    + 求 $triangle A B C$ 的面积；
    + 求 $sin A$ 的值。

    #solution[
        + 由余弦定理 $c^2 = a^2 + b^2 - 2 a b cos C$，#score(2)
          $c^2 = 9 + 12 - 2 times 3 times 2 sqrt(3) times 1 / 3 = 21 - 4 sqrt(3)$，#score(2)
          所以 $c = sqrt(21 - 4 sqrt(3))$。#score(1)
        + 由 $cos C = 1 / 3$ 得 $sin C = sqrt(1 - cos^2 C) = (2 sqrt(2)) / 3$，#score(2)
          $S_(triangle A B C) = 1 / 2 a b sin C = 1 / 2 times 3 times 2 sqrt(3) times (2 sqrt(2)) / 3 = 2 sqrt(6)$。#score(2)
        + 由正弦定理 $display(a / (sin A) = c / (sin C))$，#score(2)
          $sin A = display((a sin C) / c = (3 times (2 sqrt(2)) / 3) / sqrt(21 - 4 sqrt(3)) = (2 sqrt(2)) / sqrt(21 - 4 sqrt(3)))$。#score(3)
    ]
]

#problem(points: 14)[
    已知函数 $f(x) = x^3 - 3 a x + 2$（$a > 0$）。

    + 讨论 $f(x)$ 的单调性；
    + 若 $f(x)$ 有三个零点，求 $a$ 的取值范围；
    + 当 $a = 1$ 时，求 $f(x)$ 在区间 $[-2, 2]$ 上的最大值。

    #solution[
        + $f'(x) = 3x^2 - 3a = 3(x^2 - a)$。#score(2)
          当 $x < -sqrt(a)$ 或 $x > sqrt(a)$ 时，$f'(x) > 0$；当 $-sqrt(a) < x < sqrt(a)$ 时，$f'(x) < 0$。#score(2)
          所以 $f(x)$ 的递增区间为 $(-infinity, -sqrt(a))$ 和 $(sqrt(a), +infinity)$，递减区间为 $(-sqrt(a), sqrt(a))$。#score(2)
        + $f(x)$ 的极大值为 $f(-sqrt(a)) = 2 + 2 a sqrt(a)$，极小值为 $f(sqrt(a)) = 2 - 2 a sqrt(a)$。#score(2)
          $f(x)$ 有三个零点等价于 $f(-sqrt(a)) > 0$ 且 $f(sqrt(a)) < 0$，#score(2)
          即 $2 - 2 a sqrt(a) < 0$，解得 $a > 1$。#score(1)
        + 当 $a = 1$ 时，$f(x) = x^3 - 3x + 2$，$f'(x) = 3(x^2 - 1)$。#score(1)
          $f(-2) = 0$，$f(-1) = 4$，$f(1) = 0$，$f(2) = 4$。#score(1)
          所以最大值为 $4$。#score(1)
    ]
]
