// 最小示例：一份试卷只需要导入、套用模板和题目。

#import "../../src/lib.typ": *

#show: exam.with(title: [我的第一份试卷])

#make-title()

#question[
    $1 + 1 = $ ?
]

#question[
    已知圆的半径为 $r$，则圆的面积为 #paren[B]
    #choices[$uppi r$][$uppi r^2$][$2 uppi r$][$uppi r^3$]
]
