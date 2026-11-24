#import "@preview/scripst:1.1.3": braket, font, mycolor

#set page(
  width: 180mm,
  height: 240mm,
  margin: (x: 11mm, y: 9mm),
  fill: luma(248),
)
#set text(font: font.body, size: 9pt, fill: rgb("#252A29"))
#set par(leading: 0.55em)

#let ink = rgb("#252A29")
#let muted = rgb("#6D7471")
#let paper = white
#let border = luma(215)
#let teal = rgb("#187E78")
#let orange = rgb("#D67532")

#let tag(body, color: teal) = text(
  font: font.header,
  size: 7pt,
  weight: "bold",
  tracking: 0.08em,
  fill: color,
  body,
)

#let rounded(body, fill: paper, stroke: 0.65pt + border, inset: 8pt) = block(
  width: 100%,
  fill: fill,
  stroke: stroke,
  radius: 6pt,
  inset: inset,
  body,
)

#let advantage(number, title, body) = rounded(
  inset: (x: 8pt, y: 6pt),
  [
    #grid(
      columns: (10mm, 1fr),
      gutter: -10pt,
      [#text(font: "New Computer Modern", size: 12pt, fill: teal)[#number]],
      [
        #text(font: font.heading, size: 10.5pt, weight: "bold")[#title]
        #v(-3pt)
        #text(size: 9pt, fill: muted)[#body]
      ],
    )
  ],
)

#grid(
  columns: (1fr, auto),
  align: (left, top),
  [#tag([TYPST + SCRIPST])], [#text(size: 7pt, fill: orange)[github.com/An-314/scripst]],
)
#v(2pt)
#text(font: font.heading, size: 20pt, weight: "bold")[为什么推荐 Typst + Scripst？]
#v(2pt)
#text(size: 8.6pt, fill: muted)[轻便地写，专业地排，让工具跟上你的思考速度。]

#v(3mm)

#grid(
  columns: (1fr, 1fr),
  gutter: 2.5mm,
  row-gutter: 2.5mm,
  advantage([01], [像 Markdown 一样轻], [短标记完成标题、列表和强调，正文结构一眼可读。]),
  advantage([02], [像 LaTeX 一样能排], [公式、引用和分页直接面向正式文档。]),

  advantage([03], [比传统流程更即时], [增量编译让输入、预览、修改几乎连成一个动作。]),
  advantage([04], [更现代的包管理], [依赖与版本写进源码，按需获取并缓存；无需先维护庞大的 TeX 发行版。]),
)

#v(3mm)

#rounded(
  fill: ink,
  stroke: none,
  inset: 9pt,
  [
    #tag([SCRIPST ADDS THE SYSTEM], color: rgb("#EBA875"))
    #v(2pt)
    #text(font: font.heading, size: 13pt, weight: "bold", fill: white)[
      给年轻的 Typst，补上一套成熟的学术写作工具。
    ]
    #v(5pt)
    #grid(
      columns: (1fr, 1fr),
      gutter: 4pt,
      row-gutter: 4pt,
      rounded(fill: rgb("#FFFFFF12"), stroke: 0.5pt + rgb("#FFFFFF2F"), inset: 6pt, [#text(
          size: 12pt,
          weight: "bold",
          fill: white,
        )[排版预设]#v(-4pt)#text(size: 10pt, fill: luma(215))[文章 / 报告 / 书籍开箱即用。]]),
      rounded(fill: rgb("#FFFFFF12"), stroke: 0.5pt + rgb("#FFFFFF2F"), inset: 6pt, [#text(
          size: 12pt,
          weight: "bold",
          fill: white,
        )[参数接口]#v(-4pt)#text(size: 10pt, fill: luma(215))[字体、间距、目录、链接集中调整。]]),

      rounded(fill: rgb("#FFFFFF12"), stroke: 0.5pt + rgb("#FFFFFF2F"), inset: 6pt, [#text(
          size: 12pt,
          weight: "bold",
          fill: white,
        )[内容块]#v(-4pt)#text(size: 10pt, fill: luma(215))[定义、定理、习题、解答等预设。]]),
      rounded(fill: rgb("#FFFFFF12"), stroke: 0.5pt + rgb("#FFFFFF2F"), inset: 6pt, [#text(
          size: 11pt,
          weight: "bold",
          fill: white,
        )[Ratchet]#v(-3pt)#text(size: 10pt, fill: luma(215))[编号、重置与引用统一协作。]]),
    )
  ],
)

#v(3mm)

#rounded(
  inset: 8pt,
  [
    #tag([FORMULA LANGUAGE])
    #v(3pt)
    #text(size: 10pt, weight: "bold", fill: muted)[LaTeX]
    #v(1pt)
    #text(size: 9pt)[#raw("\\langle A\\rangle_\\psi=\\int \\psi^*(x)\\hat A\\psi(x)\\,\\mathrm{d}x")]
    #v(3pt)
    #text(size: 10pt, weight: "bold", fill: teal)[Typst]
    #v(1pt)
    #text(size: 9pt)[#raw("braket(Psi, hat(A), Psi) = integral Psi^*(x) hat(A) Psi(x) dif x")]
    #v(4pt)
    #align(center)[#text(
      font: "New Computer Modern Math",
      size: 10.5pt,
    )[$braket(Psi, hat(A), Psi) = integral Psi^*(x) hat(A) Psi(x) dif x$]]
  ],
)

#v(3mm)

#rounded(
  fill: mycolor.orange.transparentize(82%),
  stroke: 0.65pt + mycolor.orange,
  inset: 8pt,
  [
    #tag([CLASSROOM NOTE TEST], color: orange)
    #v(2pt)
    #text(
      font: font.countblock,
      size: 10pt,
      weight: "bold",
    )[“边听、边写、边预览，完全跟得上课堂进度。”\ “快速完成速记，拯救组会ddl。” \ “写作时不必被冗长命令和编译等待打断。”]
    #v(2pt)
    #text(size: 9pt, fill: muted)[复杂公式不必继续嵌入 TeX，写作也不必被冗长命令和编译等待打断。]
  ],
)

#place(bottom + right, dy: 6mm)[
  #text(size: 8pt, fill: muted)[少写样板代码，多写真正的内容。]
]
