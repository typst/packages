// Visual check of fraction padding, footnote marks, circled numbers,
// textfigure ratio and multifigures column widths.
#import "../src/lib.typ": *
#show: exam.with(page: (size: (16cm, 24cm), margin: 1.5cm), style: (footnote-numbering: n => circled-number(n, filled: true)))

默认分式 $1/2 + (a + b)/(c + d)$，$ (x^2 + 1) / (x - 1) $
#exam-setup(symbols: (frac-add: 5em / 18))
加宽分式 $1/2 + (a + b)/(c + d)$，$ (x^2 + 1) / (x - 1) $
#exam-setup(symbols: (frac-add: none))

脚注一#footnote[第一条。] 脚注二#footnote[第二条。]

#circled-number(7) #circled-number(42) #circled-number(51) #circled-number(123) #circled-number(8, filled: true) #circled-number(66, filled: true)

#exam-setup(question: (index: 49, label: "①"))
#question[第 49 题]
#question[第 50 题]
#question[第 51 题，超过 50 后改为绘制]
#choices(label: "①", index: 50)[选项][选项][选项][选项]

#textfigure(fig-pos: "right", ratio: 50%)[文字只占一半宽度，图片放在右侧剩余的空间里。文字只占一半宽度，图片放在右侧剩余的空间里。][#image("../examples/assets/example-image.svg", width: 2cm)]

#multifigures(column-widths: (4cm,) * 3, ([题 9 图], image("../examples/assets/example-image.svg", width: 2cm)), ([题 10 图], image("../examples/assets/example-image.svg", width: 2cm)), ([题 11 图], image("../examples/assets/example-image.svg", width: 2cm)))
