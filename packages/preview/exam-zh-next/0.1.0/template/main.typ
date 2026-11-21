#import "@preview/exam-zh-next:0.1.0": *

// 学生版：typst compile main.typ
// 教师版：typst compile --input exam-mode=teacher main.typ main-teacher.pdf
#show: exam.with(
    title: [2026 年春季期中考试],
    subject: [数学],
    page: (foot: "数学试题第;页（共;页）"),
    // 常用设置：
    // font: (preset: "windows"),        // noto、source-han、fandol、windows、mac、founder
    // page: (size: "a3"),               // A3 横向双栏
    // sealline: (enable: true),         // 密封线
)

#secret()
#make-title()

#notice[答卷前，考生务必将自己的姓名、考生号填写在答题卡上。][考试结束后，将本试卷和答题卡一并交回。]

= 选择题：本题共 2 小题，每小题 5 分，共 10 分。

#question[
    设集合 $A = {x | -1 < x < 4}$，$B = {2, 3, 4, 5}$，则 $A inter B = $ #paren[B]
    #choices(answer: "B")[${2}$][${2, 3}$][${3, 4}$][${2, 3, 4}$]
]

#question[
    已知 $z = 2 - iu$，则 $z (overline(z) + iu) = $ #paren[C]
    #choices(answer: "C")[$6 - 2 iu$][$4 - 2 iu$][$6 + 2 iu$][$4 + 2 iu$]
]

= 填空题：本题共 1 小题，每小题 5 分，共 5 分。

#question[
    已知函数 $f(x) = x^3 (a dot 2^x - 2^(-x))$ 是偶函数，则 $a = $ #fillin[$1$]。
]

= 解答题：本题共 1 小题，共 12 分。

#problem(points: 12)[
    已知函数 $f(x) = x (1 - ln x)$。

    + 讨论 $f(x)$ 的单调性；
    + 设 $a$，$b$ 为两个不相等的正数，且 $b ln a - a ln b = a - b$，证明：$2 < 1 / a + 1 / b < eu$。

    #solution[
        函数的定义域为 $(0, +infinity)$，又
        $ f'(x) = 1 - ln x - 1 = -ln x, #score(2) $
        故 $f(x)$ 的递增区间为 $(0, 1)$，递减区间为 $(1, +infinity)$。#score(2)
    ]
]
