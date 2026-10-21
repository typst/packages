// Visual check of page options not covered by the examples.
#import "../src/lib.typ": *
#show: exam.with(
    title: [页面选项测试],
    page: (size: "a3", show-columnline: true, foot-type: "common", show-head: true, head: n => align(right)[页眉 #n]),
    sealline: (enable: true, text-direction-vertical: true, even: (info: ([姓名#box(width: 6em, stroke: (bottom: .5pt))],))),
)
#make-title()
#for i in range(110) [#question[第 #(i + 1) 题题干 #paren()]]
