#import "../lib.typ": *

#set page(margin: 18mm)
#show: sang-setup

#let bank = question-bank(
  question(
    id: "D12-001",
    kind: QUESTION_MC,
    prompt: [Đạo hàm của $x^2$ là gì?],
    choices: (choice([$x$]), choice([$2x$], correct: true), choice([$x^2$]), choice([$2$])),
    answer: answer("choice", 2),
    solution: [Đạo hàm của $x^n$ là $n x^(n-1)$.],
    grade: 12,
    topic: "dao-ham",
    difficulty: 1,
  ),
  question(
    id: "D12-002",
    kind: QUESTION_SA,
    prompt: [Tính $f'(2)$ với $f(x)=x^2$.],
    answer: 4,
    solution: [$f'(x)=2x$ nên $f'(2)=4$.],
    grade: 12,
    topic: "dao-ham",
    difficulty: 2,
  ),
)

#let selected = bank-select(bank-filter(bank, grade: 12, topic: "dao-ham"), seed: 101)
= Đề học sinh
#for q in selected { render-question(q, mode: "student") }

#pagebreak()
= Đáp án và lời giải
#for q in selected { render-question(q, mode: "solution") }
