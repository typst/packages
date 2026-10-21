// The exam-zh example-multiple.tex, ported to Typst: an A3 collection of
// papers with a seal line, a table of contents and one chapter per paper.

#import "../src/lib.typ": *

#let blank(width) = box(width: width, stroke: (bottom: 0.5pt))
#let field(label) = heiti(text(size: zihao(4), label))

#show: exam.with(
    title: [2021 年普通高等学校招生全国统一考试],
    subject: [数学（理科）],
    page: (size: "a3", show-columnline: false, foot: "数学试题第;页（共;页）"),
    style: (fullwidth-stop: true, display-math: true),
    paren: (show-paren: true),
    sealline: (
        enable: true,
        scope: "mod-2",
        circle-show: false,
        line-type: "solid",
        info: (
            [#field[姓名] #blank(8em)],
            [#field[准考证号] #examsquare(9)],
            [#field[考场号] #examsquare(2)],
            [#field[座位号] #examsquare(2)],
        ),
        info-format: none,
        info-xshift: 12mm,
        text: "此卷只装订不密封",
        text-width: 98%,
        text-format: (family: "sans", size: zihao(-3)),
        text-xshift: 20mm,
    ),
    square: (x-length: 1.8em, y-length: 1.6em),
)

#exam-outline()

#for paper in ("papers/2021-math-yi.typ", "papers/2021-math-yi.typ") {
    chapter[2021 年普通高等学校招生全国统一考试]
    secret()
    make-title()
    include paper
}
