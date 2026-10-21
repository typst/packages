// 第一份完整试卷：抬头、注意事项、三类题型。
// 学生版：typst compile 01-first-exam.typ
// 教师版：typst compile --input exam-mode=teacher 01-first-exam.typ 01-first-exam-teacher.pdf

#import "../../src/lib.typ": *

#show: exam.with(
    title: [2024年春季期中考试],
    subject: [数学],
    page: (foot: "数学试题第;页（共;页）"),
)

#make-title()

#information(
    [姓名#box(width: 6em, stroke: (bottom: 0.5pt))],
    [班级#box(width: 6em, stroke: (bottom: 0.5pt))],
    [座号#box(width: 4em, stroke: (bottom: 0.5pt))],
    separator: h(2em),
)

#notice[
    本试卷共 3 大题，满分 100 分，考试时间 90 分钟。
][
    请用黑色签字笔在答题卡上作答。
][
    考试结束后，将试卷和答题卡一并交回。
]

= 选择题（每题 5 分，共 20 分）

#question[
    已知集合 $A = {1, 2, 3}$，$B = {2, 3, 4}$，则 $A inter B = $ #paren[B]
    #choices(answer: "B")[${1}$][${2, 3}$][${1, 2, 3, 4}$][$emptyset$]
]

#question[
    函数 $f(x) = x^2 - 4x + 3$ 的对称轴是 #paren[C]
    #choices(answer: "C")[$x = 1$][$x = 3$][$x = 2$][$x = -2$]
]

#question[
    若 $sin alpha = 1 / 2$，且 $alpha$ 为锐角，则 $alpha = $ #paren[A]
    #choices(answer: "A")[$30 degree$][$45 degree$][$60 degree$][$90 degree$]
]

#question[
    下列函数中，在 $RR$ 上单调递增的是 #paren[D]
    #choices(answer: "D")[$y = -x$][$y = x^2$][$y = 1 / x$][$y = 2x + 1$]
]

= 填空题（每题 5 分，共 20 分）
#exam-setup(question: (index: 1))

#question[
    若 $f(x) = 3x - 2$，则 $f(2) = $ #fillin[4]。
]

#question[
    圆周率 $uppi$ 的近似值为 #fillin[3.14159]（保留五位小数）。
]

#question[
    方程 $x^2 - 5x + 6 = 0$ 的两个根为 $x_1 = $ #fillin[2]，$x_2 = $ #fillin[3]。
]

#question[
    不等式 $|x - 2| < 3$ 的解集是 #fillin[$(-1, 5)$]。
]

= 解答题（共 60 分）
#exam-setup(question: (index: 1))

#problem(points: 15)[
    已知函数 $f(x) = x^2 - 4x + 3$。

    + 求 $f(x)$ 的对称轴；
    + 求 $f(x)$ 的最小值；
    + 求 $f(x)$ 的零点。

    #solution[
        + 对称轴为 $x = -b / (2a) = -(-4) / (2 times 1) = 2$。#score(5)
        + 配方得：$f(x) = (x - 2)^2 - 1$，#score(3)
          所以最小值为 $-1$。#score(2)
        + 令 $f(x) = 0$，即 $x^2 - 4x + 3 = 0$，#score(2)
          因式分解得：$(x - 1)(x - 3) = 0$，#score(2)
          所以 $x_1 = 1$，$x_2 = 3$。#score(1)
    ]
]

#problem(points: 20)[
    已知等差数列 ${a_n}$ 满足 $a_1 = 3$，$a_3 = 9$。

    + 求数列 ${a_n}$ 的通项公式；
    + 求前 $n$ 项和 $S_n$；
    + 求满足 $S_n > 100$ 的最小正整数 $n$。

    #solution[
        + 设公差为 $d$，则 $a_3 = a_1 + 2d$，#score(2)
          即 $9 = 3 + 2d$，解得 $d = 3$。#score(2)
          所以 $a_n = a_1 + (n - 1)d = 3 + 3(n - 1) = 3n$。#score(2)
        + $S_n = (n(a_1 + a_n)) / 2 = (n(3 + 3n)) / 2 = (3n(n + 1)) / 2$。#score(6)
        + 由 $S_n > 100$ 得 $(3n(n + 1)) / 2 > 100$，#score(2)
          即 $3n^2 + 3n - 200 > 0$。#score(2)
          解得 $n > (-3 + sqrt(2409)) / 6 approx 7.67$，#score(3)
          所以最小正整数 $n = 8$。#score(1)
    ]
]

#problem(points: 25)[
    已知函数 $f(x) = x^3 - 3x$。

    + 求 $f(x)$ 的单调区间；
    + 求 $f(x)$ 在区间 $[-2, 2]$ 上的最大值和最小值；
    + 若方程 $f(x) = a$ 有三个不同的实根，求实数 $a$ 的取值范围。

    #solution[
        + $f'(x) = 3x^2 - 3 = 3(x^2 - 1) = 3(x + 1)(x - 1)$。#score(3)
          令 $f'(x) = 0$，得 $x = -1$ 或 $x = 1$。#score(2)
          当 $x < -1$ 时，$f'(x) > 0$；当 $-1 < x < 1$ 时，$f'(x) < 0$；当 $x > 1$ 时，$f'(x) > 0$。#score(3)
          所以 $f(x)$ 的递增区间为 $(-infinity, -1)$ 和 $(1, +infinity)$，递减区间为 $(-1, 1)$。#score(2)
        + 由（1）知，$f(x)$ 在 $x = -1$ 处取极大值，在 $x = 1$ 处取极小值。#score(2)
          $f(-2) = -2$，$f(-1) = 2$，$f(1) = -2$，$f(2) = 2$。#score(4)
          所以最大值为 $2$，最小值为 $-2$。#score(2)
        + 由（2）知，$f(x)$ 的极大值为 $f(-1) = 2$，极小值为 $f(1) = -2$。#score(2)
          方程 $f(x) = a$ 有三个不同的实根，等价于直线 $y = a$ 与曲线 $y = f(x)$ 有三个交点，#score(3)
          所以 $-2 < a < 2$。#score(2)
    ]
]
