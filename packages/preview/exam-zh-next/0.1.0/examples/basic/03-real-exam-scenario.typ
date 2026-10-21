// 真实考试场景：密封线、评分框、草稿纸，一份源码出学生版和教师版。
// 学生版：typst compile 03-real-exam-scenario.typ
// 教师版：typst compile --input exam-mode=teacher 03-real-exam-scenario.typ 03-real-exam-scenario-teacher.pdf
// 教师版把解答集中放在文末的“参考答案”中，并换用独立的卷头。

#import "../../src/lib.typ": *

#show: exam.with(
    title: [高一数学月考试卷],
    subject: [数学],
    page: (foot: "数学试题第;页（共;页）"),
    sealline: (enable: true),
    scoringbox: (type: "twocolumn"),
    teacher: teacher-defaults + (
        title: [高一数学月考试卷参考答案],
        solution: (show-solution: "show-move"),
    ),
)

#student-only(secret())
#make-title()

#let blank(width) = box(width: width, stroke: (bottom: 0.5pt))
#student-only[
    #information([姓名#blank(6em)], [班级#blank(6em)], [学号#blank(6em)], [考场#blank(4em)], [座号#blank(3em)], separator: h(1.2em))

    #notice[
        本试卷共 4 页，22 小题，满分 150 分。考试用时 120 分钟。
    ][
        答卷前，考生务必将自己的姓名、学号、班级填写在答题卡上。
    ][
        作答选择题时，选出每小题答案后，用 2B 铅笔在答题卡上对应题目选项的答案信息点涂黑；如需改动，用橡皮擦干净后，再选涂其他答案。
    ][
        非选择题必须用黑色字迹的钢笔或签字笔作答，答案必须写在答题卡各题目指定区域内相应位置上；如需改动，先划掉原来的答案，然后再写上新答案。
    ][
        考生必须保持答题卡的整洁。考试结束后，将试卷和答题卡一并交回。
    ]
]

= 选择题（本题共 5 小题，每小题 5 分，共 25 分。在每小题给出的四个选项中，只有一项是符合题目要求的）

#question[
    已知集合 $A = {x | x^2 - 3x + 2 = 0}$，$B = {1, 2, 3}$，则 $A inter B = $ #paren[D]
    #choices(answer: "D")[${1}$][${2}$][${3}$][${1, 2}$]
]

#question[
    函数 $f(x) = ln(2x - 1)$ 的定义域为 #paren[C]
    #choices(answer: "C")[$(-infinity, 1 / 2)$][$[1 / 2, +infinity)$][$(1 / 2, +infinity)$][$RR$]
]

#question[
    若复数 $z$ 满足 $(1 + iu) z = 2$，则 $|z| = $ #paren[B]
    #choices(answer: "B")[$1$][$sqrt(2)$][$2$][$2 sqrt(2)$]
]

#question[
    已知向量 $vect(a) = (1, 2)$，$vect(b) = (2, -1)$，则 $vect(a) dot vect(b) = $ #paren[A]
    #choices(answer: "A")[$0$][$1$][$-1$][$3$]
]

#question[
    在等差数列 ${a_n}$ 中，$a_1 = 2$，$d = 3$，则 $a_5 = $ #paren[D]
    #choices(answer: "D")[$11$][$12$][$13$][$14$]
]

= 填空题（本题共 4 小题，每小题 5 分，共 20 分）
#exam-setup(question: (index: 1))

#question[已知 $f(x) = 2x^2 - 3x + 1$，则 $f(2) = $ #fillin[3]。]

#question[若 $tan alpha = 2$，则 $display((sin alpha + cos alpha) / (sin alpha - cos alpha)) = $ #fillin[3]。]

#question[已知等比数列 ${a_n}$ 满足 $a_1 = 1$，$a_3 = 4$，则公比 $q = $ #fillin[$plus.minus 2$]。]

#question[若不等式 $|x - 1| + |x + 2| >= a$ 对所有实数 $x$ 恒成立，则实数 $a$ 的取值范围是 #fillin[$(-infinity, 3]$]。]

= 解答题（本题共 3 小题，共 34 分。解答应写出文字说明、证明过程或演算步骤）
#exam-setup(question: (index: 1))

#problem(points: 10)[
    已知函数 $f(x) = 2 sin x cos x + 2 sqrt(3) cos^2 x - sqrt(3)$。

    + 求 $f(x)$ 的最小正周期；
    + 求 $f(x)$ 的单调递增区间。

    #solution[
        + $f(x) = sin 2x + sqrt(3)(2 cos^2 x - 1)$ #score(2)
          $= sin 2x + sqrt(3) cos 2x$ #score(1)
          $= 2 sin(2x + uppi / 3)$。#score(1)
          所以最小正周期 $T = display((2 uppi) / 2) = uppi$。#score(1)
        + 由 $-uppi / 2 + 2 k uppi <= 2x + uppi / 3 <= uppi / 2 + 2 k uppi$，$k in ZZ$，#score(2)
          得 $-(5 uppi) / 12 + k uppi <= x <= uppi / 12 + k uppi$，$k in ZZ$。#score(2)
          所以 $f(x)$ 的单调递增区间为 $[-(5 uppi) / 12 + k uppi, uppi / 12 + k uppi]$，$k in ZZ$。#score(1)
    ]
]

#problem(points: 12)[
    已知等差数列 ${a_n}$ 的前 $n$ 项和为 $S_n$，$a_2 = 4$，$S_5 = 30$。

    + 求数列 ${a_n}$ 的通项公式；
    + 求满足 $S_n > 100$ 的最小正整数 $n$。

    #solution[
        + 设首项为 $a_1$，公差为 $d$，由题意得 #score(1)
          $cases(a_1 + d = 4, 5 a_1 + 10 d = 30)$，#score(2)
          解得 $a_1 = 2$，$d = 2$。#score(2)
          所以 $a_n = 2 + 2(n - 1) = 2n$。#score(1)
        + $S_n = display((n(a_1 + a_n)) / 2 = (n(2 + 2n)) / 2) = n(n + 1)$。#score(2)
          由 $S_n > 100$ 得 $n(n + 1) > 100$，#score(1)
          解得 $n > display((-1 + sqrt(401)) / 2) approx 9.51$。#score(2)
          所以最小正整数 $n = 10$。#score(1)
    ]
]

#problem(points: 12)[
    已知圆 $C: x^2 + y^2 - 2x - 4y + 1 = 0$。

    + 求圆 $C$ 的圆心坐标和半径；
    + 若直线 $l: x + y + m = 0$ 与圆 $C$ 相切，求 $m$ 的值。

    #solution[
        + 圆的方程可化为 $(x - 1)^2 + (y - 2)^2 = 4$。#score(3)
          所以圆心为 $(1, 2)$，半径 $r = 2$。#score(2)
        + 圆心到直线的距离 $d = display((|1 + 2 + m|) / sqrt(2) = (|3 + m|) / sqrt(2))$。#score(3)
          由相切条件 $d = r$，得 $display((|3 + m|) / sqrt(2)) = 2$，#score(2)
          解得 $m = 2 sqrt(2) - 3$ 或 $m = -2 sqrt(2) - 3$。#score(2)
    ]
]

#student-only(draftpaper())
