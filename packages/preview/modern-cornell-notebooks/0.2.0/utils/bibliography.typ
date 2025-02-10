// bibliography-content.typ
// 参考文献

#let bibliography-content(bibliography-style, bibliography-file) = {
    set text(font: ("Times New Roman", "KaiTi")) //设置参考文献字体
    pagebreak()
    show bibliography: set text(10.5pt)
    set bibliography(style: bibliography-style)
    bibliography-file
}