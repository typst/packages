#import "@preview/sang-math:1.1.0": *

#set page(margin: 18mm)
#show: sang-setup

#let (tn, ds, tln, tl) = bank-mode()
#let bank = question-bank(
  tn(
    [Đạo hàm của $x^2$ là gì?],
    ([$x$], True([$2x$]), [$x^2$], [$2$]),
    id: "1D7N2-1",
    loigiai: [Đạo hàm của $x^n$ là $n x^(n-1)$.],
  ),
  tln(
    [Tính $f'(2)$ với $f(x)=x^2$.], 4,
    id: "1D7H2-1",
    loigiai: [$f'(x)=2x$ nên $f'(2)=4$.],
  ),
)

#let selected = bank-select(bank-filter(bank, grade: 11, id-prefix: "1D7"), seed: 101)
= Đề học sinh
#for q in selected { render-question(q, mode: "student") }

#pagebreak()
= Đáp án và lời giải
#for q in selected { render-question(q, mode: "solution") }
