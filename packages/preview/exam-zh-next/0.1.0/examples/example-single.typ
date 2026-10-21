// The exam-zh example-single.tex, ported to Typst.
// Compile the teacher version with: typst compile --input exam-mode=teacher example-single.typ

#import "../src/lib.typ": *

#show: exam.with(
    title: [2021 年普通高等学校招生全国统一考试（乙卷）],
    subject: [数学（理科）],
    page: (foot: "数学试题第;页（共;页）"),
    style: (display-math: true),
    paren: (show-paren: true, show-answer: true),
    solution: (show-solution: "show-stay", label-indentation: false),
)

#secret()
#make-title()

#include "papers/2021-math-yi.typ"
