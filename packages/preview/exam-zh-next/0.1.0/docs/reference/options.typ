// 3.5 参数设置：exam-zh-doc 中每个 \examsetup 键值的 Typst 对照。

#import "../doc-style.typ": *

== 参数设置

#entry("\\examsetup", ("exam-setup", "exam.with"), latex-syntax: ```latex \examsetup{⟨键值列表⟩}```, typst-syntax: ```typ #exam-setup(⟨模块⟩: (⟨键⟩: ⟨值⟩))```)[
    全部选项都可以由 `exam-setup` 设置，从调用处往后生效；写在 `#show: exam.with(...)` 中则作用于整份试卷。LaTeX 版的两种等价写法 `page = { size = a3paper }` 与 `page/size = a3paper` 在 Typst 中都写成 `page: (size: "a3")`。

    与 LaTeX 版的区别：
    - 键值列表中可以有空行和注释；
    - 布尔值必须写出 `true` 或 `false`；
    - 文字是内容 `[...]`，取值是字符串 `"..."`，长度带单位；
    - 写错键名时编译报错，并给出完整键名。
]

#compare(```latex
\examsetup{
  page = {
    size = a3paper
  },
  choices = {
    column-sep  = 1em,
    label-pos   = auto,
    label-sep   = 0.5em,
    max-columns = 4
  }
}
% 或者
\examsetup{
  page/size            = a3paper,
  choices/column-sep   = 1em,
  choices/label-pos    = auto,
  choices/label-sep    = 0.5em,
  choices/max-columns  = 4
}
```, ```typ
#show: exam.with(
  page: (size: "a3"),
  choices: (
    column-sep: 1em,
    label-pos: auto,
    label-sep: 0.5em,
    max-columns: 4,
  ),
)
```, show-result: false)

=== 风格设置

#entry("style", "style", latex-syntax: ```latex style = {⟨键值列表⟩}```, typst-syntax: ```typ style: (⟨键⟩: ⟨值⟩)```)[
    该选项包含许多子项目。Typst 版还在这里设置行距（`par-leading`）、段落间距（`par-spacing`）、首行缩进（`first-line-indent`）以及行内公式的行间样式（`display-math`，对应 `\everymath{\displaystyle}`）。
]

#entry("style/fullwidth-stop", "style: (fullwidth-stop: ..)", latex-syntax: ```latex fullwidth-stop = catcode | false```, typst-syntax: ```typ fullwidth-stop: true | false```)[
    是否将“。”映射为“．”。LaTeX 版的 `catcode` 对应 `true`。只能在 `exam` 中设置。
]

#compare(setup: (style: (fullwidth-stop: true)), ```latex
\examsetup{style/fullwidth-stop = catcode}
句号会变成全角点。
```, ```typ
// #show: exam.with(style: (fullwidth-stop: true))
句号会变成全角点。
```)

#entry("style/footnote-style", "style: (footnote-numbering: ..)", latex-syntax: ```latex footnote-style = plain | libertinus | libertinus* | pifont | ...```, typst-syntax: ```typ footnote-numbering: "1" | "①" | n => circled-number(n, filled: true)```, status: [写法不同])[
    脚注编号样式。LaTeX 版按字体选择带圈数字样式，带 `*` 的为阴文（黑底白字）。Typst 版直接给出编号格式或函数：`"①"` 为字体中的带圈数字，`circled-number(n, filled: true)` 为阴文样式。只能在 `exam` 中设置。
]

=== 师生两版

#entry("style/student-version-suffix", "—", latex-syntax: ```latex student-version-suffix = _student_version```, typst-syntax: ```typ typst compile --input exam-mode=teacher exam.typ ⟨文件名⟩.pdf```, status: [Typst 中不需要])[
    LaTeX 版第二个 PDF 的文件名后缀。Typst 版在命令行中直接指定输出文件名。
]

#entry("style/student-version-cleanaux", "—", status: [Typst 中不需要])[
    LaTeX 版是否清除第二次编译的辅助文件。Typst 不生成辅助文件。
]

=== 中国化数学符号

#entry("symbols", "symbols", latex-syntax: ```latex symbols = {⟨键值列表⟩}```, typst-syntax: ```typ symbols: (⟨键⟩: ⟨值⟩)```)[
    用于设置中国化符号。符号本身见 3.4.3 节。
]

#entry("symbols/paralleleq-type", "symbols: (paralleleq-type: ..)", latex-syntax: ```latex paralleleq-type = slant | perpendicular```, typst-syntax: ```typ paralleleq-type: "slant" | "perpendicular"```)[
    `paralleleq` 的效果：`"slant"` 上方的线是倾斜的，`"perpendicular"` 上方的线是垂直的。
]

#compare(```latex
$\paralleleq$ \examsetup{symbols/paralleleq-type = perpendicular} $\paralleleq$
```, ```typ
#import symbols: *
$paralleleq$ #exam-setup(symbols: (paralleleq-type: "perpendicular")) $paralleleq$
```)

#entry(("symbols/change-frac-style", "symbols/change-dfrac-style", "symbols/frac-add", "symbols/dfrac-add"), "symbols: (frac-add: ..)", latex-syntax: ```latex change-frac-style = true, frac-add = 5mu```, typst-syntax: ```typ frac-add: 5em / 18```, status: [写法不同])[
    在分式的分子分母两侧增加间距。LaTeX 版用 `change-frac-style` 开启、`frac-add` 给出间距；Typst 版设置 `frac-add` 即开启，`none`（默认）为关闭。Typst 不区分 `\frac` 与 `\dfrac`，`frac-add` 作用于所有分式；`5mu` 等于 `5em / 18`。
]

#compare(```latex
$\frac{1}{2} + \frac{a+b}{c+d}$
\examsetup{symbols/change-frac-style = true, symbols/frac-add = 5mu}
$\frac{1}{2} + \frac{a+b}{c+d}$
```, ```typ
$1/2 + (a + b)/(c + d)$
#exam-setup(symbols: (frac-add: 5em / 18))
$1/2 + (a + b)/(c + d)$
```)

=== 页面设置

#entry("page", "page", latex-syntax: ```latex page = {⟨键值列表⟩}```, typst-syntax: ```typ page: (⟨键⟩: ⟨值⟩)```)[
    页面设置。页面相关的选项只能在 `exam` 中设置。
]

#entry("page/size", "page: (size: ..)", latex-syntax: ```latex size = a3paper | a4paper | custom```, typst-syntax: ```typ size: "a4" | "a3" | (⟨宽⟩, ⟨高⟩)```)[
    试卷尺寸。`"a4"` 表示一页为 A4 纸大小；`"a3"` 表示一页为横向 A3 纸，内容为连续两页 A4 拼接；自定义纸张直接给出 `(宽, 高)`，采用普通单页页码和居中页脚。
]

#entry(("page/paper-width", "page/paper-height", "page/margin", "page/headheight"), ("page: (size: (宽, 高))", "page: (margin: ..)", "—"), latex-syntax: ```latex paper-width, paper-height, margin, headheight```, typst-syntax: ```typ size: (195mm, 270mm), margin: 15mm```)[
    自定义纸张的宽、高和页边距。`margin` 可以是一个长度，也可以是字典 `(top:, bottom:, left:, right:, inside:, outside:, x:, y:)`；默认值随纸张和是否有密封线而定（与 LaTeX 版相同）。`headheight` 在 Typst 中不需要：页眉与正文的距离由 `page.header-ascent` 控制。
]

16K 油印的单页尺寸可按如下方式设置：

#compare(```latex
\examsetup{
  page = {
    size = custom,
    paper-width = 195mm,
    paper-height = 270mm,
    margin = 15mm,
    headheight = 19.72mm,
  },
}
```, ```typ
#show: exam.with(
  page: (
    size: (195mm, 270mm),
    margin: 15mm,
  ),
)
```, show-result: false)

#entry("page/show-head", "page: (show-head: ..)", latex-syntax: ```latex show-head = true | false```, typst-syntax: ```typ show-head: true | false```)[
    是否显示页眉，默认不显示。
]

#entry("page/show-foot", "page: (show-foot: ..)", latex-syntax: ```latex show-foot = true | false```, typst-syntax: ```typ show-foot: true | false```)[
    是否显示页脚，默认显示。
]

#entry("page/head-content", "page: (head: ..)", latex-syntax: ```latex head-content = {\fancyhead[...]{...}}```, typst-syntax: ```typ head: [⟨内容⟩] | n => [⟨第 n 页的页眉⟩]```, status: [写法不同])[
    页眉内容。LaTeX 版写 fancyhdr 命令；Typst 版给出内容，或接收页码的函数（可以按奇偶页返回不同内容）。
]

#compare(```latex
head-content = {
  \fancyhead[ER, OL]{测试文本}
  \fancyhead[C]{\includegraphics[height=1cm]{example-image.png}}
}
```, ```typ
#show: exam.with(
  page: (
    show-head: true,
    head: n => grid(columns: (1fr, auto, 1fr),
      if calc.odd(n) [测试文本],
      image("example-image.png", height: 1cm),
      if calc.even(n) { align(right)[测试文本] }),
  ),
)
```, show-result: false)

#entry("page/foot-type", "page: (foot-type: ..)", latex-syntax: ```latex foot-type = common | separate```, typst-syntax: ```typ foot-type: "common" | "separate"```)[
    A3 纸时页脚的类型。`"common"` 表示两页 A4（即一页 A3）共用一个页脚；`"separate"`（默认）表示两页 A4 各自有一个页脚，页码按 A4 计算。
]

#entry("page/foot-content", "page: (foot: ..)", latex-syntax: ```latex foot-content = {数学试题第;页（共;页）}```, typst-syntax: ```typ foot: "数学试题第;页（共;页）" | (page, total) => [...]```)[
    页脚内容。与 LaTeX 版相同，可以写含西文分号的字符串：不含分号时直接输出；一个分号代替页码；两个分号分别代替页码和总页数。也可以给出函数 `(page, total) => [...]`。默认为 `第 page 页（共 total 页）`。
]

#entry(("page/show-columnline", "page/columnline-width"), ("page: (show-columnline: ..)", "page: (columnline-stroke: ..)"), latex-syntax: ```latex show-columnline = true, columnline-width = 0.4pt```, typst-syntax: ```typ show-columnline: true, columnline-stroke: 0.4pt```)[
    A3 纸时是否显示两页 A4 之间的竖线，及竖线的线宽（Typst 中可以是任意描边，如 `0.4pt + gray`）。
]

#entry("page/show-chapter", "page: (show-chapter: ..)", latex-syntax: ```latex show-chapter = true | false```, typst-syntax: ```typ show-chapter: true | false```)[
    是否显示 `chapter` 的内容。`false` 时标题不出现，但仍录入目录并可以通过链接跳转。
]

#shot("page-options", width: 80%, caption: [A3 纸、共用页脚、中间竖线、页眉与竖排密封线文字（`tests/page-options.typ`）])

=== 密封线

#entry("sealline", "sealline", latex-syntax: ```latex sealline = {⟨键值列表⟩}```, typst-syntax: ```typ sealline: (⟨键⟩: ⟨值⟩)```)[
    密封线设置，只能在 `exam` 中设置。LaTeX 版中 `foo`、`odd-foo`、`even-foo` 三种写法分别统一控制、控制奇数页、控制偶数页；Typst 版中 `foo` 统一控制，`odd: (foo: ..)`、`even: (foo: ..)` 分别覆盖奇偶页。例如 `odd-text-xshift = 20mm` 写成 `odd: (text-xshift: 20mm)`。

    下面所说的“水平”“垂直”都以正常的页面为参考系。
]

#entry("sealline/show", "sealline: (enable: ..)", latex-syntax: ```latex show = true | false```, typst-syntax: ```typ enable: true | false```, status: [写法不同])[
    是否显示密封线，默认不显示。`show` 是 Typst 的关键字，所以 Typst 版的键名为 `enable`。开启后页边距改为装订边较宽的双面版式。
]

#entry(("sealline/scope", "sealline/type"), "sealline: (scope: ..)", latex-syntax: ```latex scope = firstpage | oddpage | everypage | first-and-last | mod-2 | mod-3 | mod-4 | mod-6```, typst-syntax: ```typ scope: "everypage"```)[
    密封线的作用范围。`"firstpage"` 仅第一页有密封线；`"oddpage"` 仅奇数页有，在页面左侧；`"everypage"`（默认）每页都有，奇数页在左侧，偶数页在右侧；`"first-and-last"` 只有第一页和最后一页有；`"mod-x"` 表示满足 $y mod x = 1$ 的页 $y$ 有密封线。页数按页码计算，目录页不计入。LaTeX 版的同义键 `type` 在 Typst 版中不再提供。
]

#entry(("sealline/line-thickness", "sealline/odd-line-thickness", "sealline/even-line-thickness"), ("sealline: (line-thickness: ..)", "odd: (line-thickness: ..)", "even: (line-thickness: ..)"), latex-syntax: ```latex line-thickness = 1pt```, typst-syntax: ```typ line-thickness: 1pt```)[
    密封线的线厚度。
]

#entry(("sealline/line-xshift", "sealline/odd-line-xshift", "sealline/even-line-xshift"), ("sealline: (line-xshift: ..)", "odd: (line-xshift: ..)", "even: (line-xshift: ..)"), latex-syntax: ```latex line-xshift = 8mm```, typst-syntax: ```typ line-xshift: 8mm```)[
    密封线的水平偏移量，默认 8mm。正值时奇数页密封线往左偏移，偶数页往右偏移（都是离开版心）。
]

#entry(("sealline/line-yshift", "sealline/odd-line-yshift", "sealline/even-line-yshift"), ("sealline: (line-yshift: ..)", "odd: (line-yshift: ..)", "even: (line-yshift: ..)"), latex-syntax: ```latex line-yshift = 0mm```, typst-syntax: ```typ line-yshift: 0mm```)[
    密封线的垂直伸缩量。正值时密封线上下同时往内缩；0mm 时密封线长度为版心高度。
]

#entry(("sealline/line-type", "sealline/odd-line-type", "sealline/even-line-type"), ("sealline: (line-type: ..)", "odd: (line-type: ..)", "even: (line-type: ..)"), latex-syntax: ```latex line-type = loosely-dashed```, typst-syntax: ```typ line-type: "loosely-dashed"```)[
    密封线的线型，名称与 TikZ 相同：`solid`、`dotted`、`densely-dotted`、`loosely-dotted`、`dashed`、`densely-dashed`、`loosely-dashed`、`dash-dot`、`densely-dash-dot`、`loosely-dash-dot`、`dash-dot-dot`、`densely-dash-dot-dot`、`loosely-dash-dot-dot`。也可以直接给出 Typst 的 `dash` 值，例如 `(4pt, 2pt)`。
]

#demo(```typ
#for t in ("solid", "dotted", "densely-dotted", "loosely-dotted", "dashed", "densely-dashed", "loosely-dashed", "dash-dot", "densely-dash-dot", "loosely-dash-dot") {
  let dash = (
    "solid": none, "dash-dot": "dash-dotted", "densely-dash-dot": "densely-dash-dotted", "loosely-dash-dot": "loosely-dash-dotted",
  ).at(t, default: t)
  box(width: 48%, [#box(width: 9em, raw(t)) #box(line(length: 4cm, stroke: (thickness: 1pt, dash: dash)))])
}
```)

#entry(("sealline/text", "sealline/odd-text", "sealline/even-text"), ("sealline: (text: ..)", "odd: (text: ..)", "even: (text: ..)"), latex-syntax: ```latex text = 密封线内不得答题```, typst-syntax: ```typ text: "密封线内不得答题"```)[
    沿着密封线的文字，字符均匀分散。与 LaTeX 版相同，文字中不能有命令，字体通过 `text-format` 设置。
]

#entry(("sealline/text-width", "sealline/odd-text-width", "sealline/even-text-width"), ("sealline: (text-width: ..)", "odd: (text-width: ..)", "even: (text-width: ..)"), latex-syntax: ```latex text-width = 0.8\textheight```, typst-syntax: ```typ text-width: 80%```)[
    文字分散的长度。可以是长度，或版心高度的比例（`80%` 对应 `0.8\textheight`）。
]

#entry(("sealline/text-format", "sealline/odd-text-format", "sealline/even-text-format"), ("sealline: (text-format: ..)", "odd: (text-format: ..)", "even: (text-format: ..)"), latex-syntax: ```latex text-format = \zihao{4}\sffamily```, typst-syntax: ```typ text-format: (family: "sans", size: zihao(4))```)[
    文字的字体设置。
]

#entry(("sealline/text-xshift", "sealline/odd-text-xshift", "sealline/even-text-xshift"), ("sealline: (text-xshift: ..)", "odd: (text-xshift: ..)", "even: (text-xshift: ..)"), latex-syntax: ```latex text-xshift = 11mm```, typst-syntax: ```typ text-xshift: 11mm```)[
    文字的水平偏移量，默认 11mm。正值时奇数页文字往左，偶数页往右。
]

#entry(("sealline/text-yshift", "sealline/odd-text-yshift", "sealline/even-text-yshift"), ("sealline: (text-yshift: ..)", "odd: (text-yshift: ..)", "even: (text-yshift: ..)"), latex-syntax: ```latex text-yshift = 0pt```, typst-syntax: ```typ text-yshift: 0pt```)[
    文字的垂直偏移量。正值时奇数页文字往上；偶数页在竖排时往上、旋转时往下（与 LaTeX 版相同）。
]

#entry(("sealline/text-xscale", "sealline/text-yscale", "sealline/odd-text-xscale", "sealline/even-text-xscale", "sealline/odd-text-yscale", "sealline/even-text-yscale"), ("sealline: (text-xscale: ..)", "sealline: (text-yscale: ..)"), latex-syntax: ```latex text-xscale = 1.0, text-yscale = 0.8```, typst-syntax: ```typ text-xscale: 100%, text-yscale: 80%```)[
    文字的水平与垂直放缩（以旋转后的试卷为参考系），写成百分比。
]

#entry(("sealline/text-direction-vertical", "sealline/odd-text-direction-vertical", "sealline/even-text-direction-vertical"), ("sealline: (text-direction-vertical: ..)", "odd: (text-direction-vertical: ..)", "even: (text-direction-vertical: ..)"), latex-syntax: ```latex text-direction-vertical = true | false```, typst-syntax: ```typ text-direction-vertical: true | false```)[
    `true` 表示奇偶页文字都从上往下竖排、不旋转；`false`（默认）表示奇数页逆时针旋转 90 度从下往上排，偶数页顺时针旋转从上往下排。
]

#entry(("sealline/circle-show", "sealline/odd-circle-show", "sealline/even-circle-show"), ("sealline: (circle-show: ..)", "odd: (circle-show: ..)", "even: (circle-show: ..)"), latex-syntax: ```latex circle-show = true | false```, typst-syntax: ```typ circle-show: true | false```)[
    密封线上装订孔圆圈的显示与否，默认显示。
]

#entry(("sealline/circle-start", "sealline/circle-end", "sealline/odd-circle-start", "sealline/even-circle-start", "sealline/odd-circle-end", "sealline/even-circle-end"), ("sealline: (circle-start: ..)", "sealline: (circle-end: ..)"), latex-syntax: ```latex circle-start = 0.07, circle-end = 0.92```, typst-syntax: ```typ circle-start: 0.07, circle-end: 0.92```)[
    圆圈的起点和终点占线总长的比例（从上往下），取值 0–1。
]

#entry(("sealline/circle-step", "sealline/odd-circle-step", "sealline/even-circle-step"), ("sealline: (circle-step: ..)", "odd: (circle-step: ..)", "even: (circle-step: ..)"), latex-syntax: ```latex circle-step = 3.5em```, typst-syntax: ```typ circle-step: 3.5em```)[
    相邻两个圆圈之间的距离。最后一个圆圈超出 `circle-end` 时不显示。
]

#entry(("sealline/circle-diameter", "sealline/odd-circle-diameter", "sealline/even-circle-diameter"), ("sealline: (circle-diameter: ..)", "odd: (circle-diameter: ..)", "even: (circle-diameter: ..)"), latex-syntax: ```latex circle-diameter = 3mm```, typst-syntax: ```typ circle-diameter: 3mm```)[
    圆圈的直径。
]

#entry(("sealline/circle-xshift", "sealline/odd-circle-xshift", "sealline/even-circle-xshift"), ("sealline: (circle-xshift: ..)", "odd: (circle-xshift: ..)", "even: (circle-xshift: ..)"), latex-syntax: ```latex circle-xshift = 8mm```, typst-syntax: ```typ circle-xshift: 8mm```)[
    圆圈的水平偏移量。
]

#entry("sealline/odd-info-content", "sealline: (info: ..)", latex-syntax: ```latex
odd-info-content = {
  {\kaishu 姓名}：{\underline{\hspace*{8em}}},
  {\kaishu 准考证号}：{\underline{\hspace*{8em}}},
  ...
}
```, typst-syntax: ```typ
info: (
  ("姓名", 8em),
  ("准考证号", 8em),
  [座位号 #examsquare(2)],
)
```, status: [写法不同])[
    奇数页密封线旁的学生信息。每一项可以是 `(标签, 下划线宽度)`，也可以是任意内容（如方格）；字体由 `info-format`（默认楷体）设置。LaTeX 版受 TikZ 的 `text along path` 限制，命令要用花括号包起来；Typst 版没有这个限制。默认只在奇数页显示；偶数页也需要时设置 `even: (info: (..))`。
]

#entry("sealline/odd-info-separator", "sealline: (info-separator: ..)", latex-syntax: ```latex odd-info-separator = \hspace*{3em}```, typst-syntax: ```typ info-separator: h(3em)```)[
    学生信息各项之间的分隔，默认 `h(3em)`。
]

#entry("sealline/odd-info-align", "sealline: (info-align: ..)", latex-syntax: ```latex odd-info-align = left | center | right```, typst-syntax: ```typ info-align: left | center | right```)[
    学生信息的对齐方式，以试卷顺时针旋转 90 度后的视角为参考（此时密封线为水平线）。
]

#entry(("sealline/odd-info-xshift", "sealline/odd-info-yshift"), ("sealline: (info-xshift: ..)", "sealline: (info-yshift: ..)"), latex-syntax: ```latex odd-info-xshift = 20mm, odd-info-yshift = 0mm```, typst-syntax: ```typ info-xshift: 20mm, info-yshift: 0mm```)[
    学生信息的水平与垂直偏移量。
]

#compare(title: [`example-multiple` 中的密封线设置], ```latex
\examsetup{
  sealline = {
    show        = true,
    scope       = mod-2,
    circle-show = false,
    line-type   = solid,
    odd-info-content = {
      {\heiti \zihao{4}姓名} {\underline{\hspace*{8em}}},
      {\heiti \zihao{4}准考证号} {\examsquare{9}},
      {\heiti \zihao{4}考场号} {\examsquare{2}},
      {\heiti \zihao{4}座位号} {\examsquare{2}},
    },
    odd-info-xshift = 12mm,
    text = {此卷只装订不密封},
    text-width = 0.98\textheight,
    text-format  = \zihao{-3}\sffamily,
    text-xshift = 20mm
  },
  square = {
    x-length = 1.8em,
    y-length = 1.6em
  }
}
```, ```typ
#let field(label) = heiti(text(size: zihao(4), label))
#show: exam.with(
  sealline: (
    enable: true,
    scope: "mod-2",
    circle-show: false,
    line-type: "solid",
    info: (
      [#field[姓名] #box(width: 8em, stroke: (bottom: .5pt))],
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
```, show-result: false)

#grid(columns: (1.4fr, 1fr), column-gutter: 1em,
    shot("sealline-a3", caption: [上例的效果（`examples/example-multiple.typ`）]),
    shot("sealline-a4", caption: [默认密封线（`examples/basic/03-real-exam-scenario.typ`）]))

=== 方格

#entry("square", "square", latex-syntax: ```latex square = {⟨键值列表⟩}```, typst-syntax: ```typ square: (⟨键⟩: ⟨值⟩)```)[
    `examsquare` 的设置，也可以写在 `examsquare` 的参数中。
]

#entry(("square/x-length", "square/y-length"), ("square: (x-length: ..)", "square: (y-length: ..)"), latex-syntax: ```latex x-length = 1.4em, y-length = 1.2em```, typst-syntax: ```typ x-length: 1.4em, y-length: 1.2em```)[
    单位方格的长与宽。
]

#entry("square/baseline", "square: (baseline: ..)", latex-syntax: ```latex baseline = 3pt```, typst-syntax: ```typ baseline: 3pt```)[
    方格的基线偏移（方格底边在文字基线下方的距离）。一般长宽有较大改动时才需要调整。
]

#entry("square/linewidth", "square: (linewidth: ..)", latex-syntax: ```latex linewidth = 0.4pt```, typst-syntax: ```typ linewidth: 0.4pt```)[
    方格的线宽。
]

#entry("square/xshift", "—", status: [Typst 中不需要])[
    LaTeX 版中相邻方格互相重叠的距离，用来合并公共边。Typst 版的方格画在同一个网格中，公共边自动只画一次。
]

#compare(```latex
\examsquare{4} \examsquare[x-length = 1.8em, y-length = 1.6em]{2}
```, ```typ
#examsquare(4) #examsquare(2, x-length: 1.8em, y-length: 1.6em)
```)

=== 字体

#entry("font", "font: (latin: ..)", latex-syntax: ```latex font = newcm | lm | times | termes | stix | xits | libertinus | none```, typst-syntax: ```typ font: (latin: "New Computer Modern")```, status: [写法不同])[
    设置西文字体。LaTeX 版用预设名称；Typst 版直接写字体名称。对应关系：

    #table(columns: (auto, 1fr),
        [*LaTeX 版*], [*Typst 版的 `latin`*],
        [`newcm`（默认）], [`"New Computer Modern"`（默认，Typst 自带）],
        [`lm`], [`"Latin Modern Roman"`],
        [`times`], [`"Times New Roman"`],
        [`termes`], [`"TeX Gyre Termes"`],
        [`stix`], [`"STIX Two Text"`],
        [`xits`], [`"XITS"`],
        [`libertinus`], [`"Libertinus Serif"`（Typst 自带）],
        [`none`], [`none`（西文也使用中文字体）],
    )

    中文字体用 `font: (preset: ..)` 选择，见入门指南第 6 章 Q3；无衬线（黑体）文字的西文使用中文黑体字体中的西文字形。
]

#entry("math-font", "font: (math: ..)", latex-syntax: ```latex math-font = newcm | lm | stix | xits | libertinus | cambria | garamond | pala | asana | none```, typst-syntax: ```typ font: (math: "New Computer Modern Math")```, status: [写法不同])[
    设置数学字体：

    #table(columns: (auto, 1fr),
        [*LaTeX 版*], [*Typst 版的 `math`*],
        [`newcm`（默认）], [`"New Computer Modern Math"`（默认，Typst 自带）],
        [`lm`], [`"Latin Modern Math"`],
        [`stix`], [`"STIX Two Math"`],
        [`xits`], [`"XITS Math"`],
        [`libertinus`], [`"Libertinus Math"`],
        [`cambria`], [`"Cambria Math"`],
        [`pala`], [`"TeX Gyre Pagella Math"`],
        [`garamond`], [`"Garamond-Math"`],
        [`asana`], [`"Asana Math"`],
    )
]

=== 抬头

#entry("title", "make-title", latex-syntax: ```latex title = {⟨键值列表⟩}```, typst-syntax: ```typ make-title: (⟨键⟩: ⟨值⟩)```, status: [写法不同])[
    抬头的设置。因为 `exam(title: ..)` 已经用来写标题本身，这一组选项在 Typst 版中叫 `make-title`。
]

#entry("title/title-format", "make-title: (title-format: ..)", latex-syntax: ```latex title-format = \Large```, typst-syntax: ```typ title-format: (size: 16pt)```)[
    标题的格式。
]

#entry("title/subject-format", "make-title: (subject-format: ..)", latex-syntax: ```latex subject-format = \sffamily \bfseries \huge```, typst-syntax: ```typ subject-format: (family: "sans", weight: "bold", size: 22pt)```)[
    科目的格式。
]

#entry(("title/subject-sep", "title/top-sep", "title/bottom-sep"), ("make-title: (subject-sep: ..)", "(top-sep: ..)", "(bottom-sep: ..)"), latex-syntax: ```latex subject-sep = -.35em, top-sep = -.5em, bottom-sep = .33em```, typst-syntax: ```typ subject-sep: -0.2em, top-sep: 0em, bottom-sep: 0.6em```)[
    标题与科目之间、标题上方、标题与科目整体下方的间距。
]

#compare(```latex
\examsetup{title/title-format = \zihao{3}, title/subject-format = \kaishu\zihao{1}}
\title{期中考试} \subject{语文} \maketitle
```, ```typ
#exam-setup(make-title: (title-format: (size: zihao(3)), subject-format: (family: "kai", size: zihao(1))))
#make-title(title: [期中考试], subject: [语文])
```)

=== 题干

#entry("question", "question", latex-syntax: ```latex question = {⟨键值列表⟩}```, typst-syntax: ```typ question: (⟨键⟩: ⟨值⟩)```)[
    `question` 的设置，可以写在 `exam-setup` 中，也可以写在 `question(...)` 中只作用于这一题。
]

#entry("problem", "problem", latex-syntax: ```latex problem = {⟨键值列表⟩}```, typst-syntax: ```typ problem: (⟨键⟩: ⟨值⟩)```)[
    `problem` 的设置，键与 `question` 基本相同，但没有 `combine-fillin`。
]

#entry("question/show-answer", "question: (show-answer: ..)", latex-syntax: ```latex show-answer = true | false```, typst-syntax: ```typ show-answer: true | false```)[
    统一控制 `paren` 和 `fillin` 中答案的显示与否。写在 `question(show-answer: true)[...]` 中时只作用于这一题。
]

#entry("question/points", "question(points: ..)", latex-syntax: ```latex \begin{question}[points = 5]```, typst-syntax: ```typ #question(points: 5)[...]```)[
    题目的分值，出现在题号后。
]

#entry("question/show-points", "question: (show-points: ..)", latex-syntax: ```latex show-points = true | auto | false```, typst-syntax: ```typ show-points: true | auto | false```)[
    `auto`（默认）表示 `question` 的分值不显示、`problem` 的分值显示；`true`、`false` 分别表示全都显示和全都不显示。
]

#entry("question/points-separate-par", "question: (points-separate-par: ..)", latex-syntax: ```latex points-separate-par = true | false```, typst-syntax: ```typ points-separate-par: true | false```)[
    分值是否单独成段。`question` 默认为 `false`，`problem` 默认为 `true`。
]

#entry(("question/top-sep", "question/bottom-sep"), ("question: (top-sep: ..)", "(bottom-sep: ..)"), latex-syntax: ```latex top-sep = .25em plus .25em minus .1em```, typst-syntax: ```typ top-sep: 0.5em, bottom-sep: 0.5em```)[
    题目上下方的间距。
]

#entry("question/index", ("question: (index: ..)", "question(index: ..)"), latex-syntax: ```latex index = ⟨integer⟩```, typst-syntax: ```typ #exam-setup(question: (index: 1))```)[
    下一题的题号（与 exam-zh 的实际效果相同）。在 `exam-setup` 中设置时影响之后的题目；`#question(index: 5)[...]` 只把这一题编为第 5 题，之后的题目从 6 继续。
]

#entry("question/label", "question: (label: ..)", latex-syntax: ```latex label = \arabic*.```, typst-syntax: ```typ label: "1."```)[
    题号格式。LaTeX 版的 `\arabic*`、`\alph*`、`\Alph*`、`\roman*`、`\Roman*`、`\circlednumber*` 分别对应编号格式 `"1"`、`"a"`、`"A"`、`"i"`、`"I"`、`"①"`，前后的文字照写，例如 `\arabic*.` 写成 `"1."`、`（\arabic*）` 写成 `"（1）"`。也可以是函数 `n => ...`，以及固定内容。
]

#compare(```latex
\examsetup{question/label = \Roman*.}
\begin{question} 罗马数字题号 \end{question}
\examsetup{question/label = \circlednumber*}
\begin{question} 带圈数字题号 \end{question}
```, ```typ
#exam-setup(question: (label: "I."))
#question[罗马数字题号]
#exam-setup(question: (label: "①"))
#question[带圈数字题号]
```)

#entry(("question/combine-fillin", "question/combine-fillin-args"), "question: (combine-fillin: ..)", latex-syntax: ```latex combine-fillin = true, combine-fillin-args = {[type = paren][A]}```, typst-syntax: ```typ combine-fillin: (type: "paren", answer: [A])```)[
    把 `fillin` 放在题号左侧。`true` 使用默认的 `fillin`；字典中可以写 `fillin` 的任意参数，答案写在 `answer` 中。
]

#compare(title: [`combine-fillin` 和 `combine-fillin-args` 的使用示例], ```latex
\examsetup{
  fillin/show-answer = true,
  question/combine-fillin = true,
}
\begin{question}[combine-fillin-args = {[type = paren][A]}]
  设集合 $A = \{x \mid -1 < x < 4\}$，$B = \{2, 3, 4, 5\}$，则 $A \cap B = $
\end{question}
```, ```typ
#exam-setup(fillin: (show-answer: true))
#question(combine-fillin: (type: "paren", answer: [A]))[
  设集合 $A = {x | -1 < x < 4}$，$B = {2, 3, 4, 5}$，则 $A inter B = $
]
```)

#entry("question/hang", "question: (hang: ..)", latex-syntax: ```latex hang = true | false```, typst-syntax: ```typ hang: true | false```)[
    `question` 是否为悬挂效果，默认 `true`。
]

#compare(title: [`question/hang` 的效果], ```latex
\begin{question}
  劳仑衣普桑，认至将指点效则机，最你更枝。想极整月正进好志次回总般，段然取向使张规军证回，世市总李率英茄持伴。用阶千样响领交出，器程办管据家元写
\end{question}

\begin{question}[hang = false]
  劳仑衣普桑，认至将指点效则机，最你更枝。想极整月正进好志次回总般，段然取向使张规军证回，世市总李率英茄持伴。用阶千样响领交出，器程办管据家元写
\end{question}
```, ```typ
#question[
  劳仑衣普桑，认至将指点效则机，最你更枝。想极整月正进好志次回总般，段然取向使张规军证回，世市总李率英茄持伴。用阶千样响领交出，器程办管据家元写
]

#question(hang: false)[
  劳仑衣普桑，认至将指点效则机，最你更枝。想极整月正进好志次回总般，段然取向使张规军证回，世市总李率英茄持伴。用阶千样响领交出，器程办管据家元写
]
```)

#entry("problem/hang", "problem: (hang: ..)", latex-syntax: ```latex hang = true | false```, typst-syntax: ```typ hang: true | false```)[
    `problem` 题干是否悬挂缩进。默认 `false`，保持解答题题干首行缩进；`true` 时题干的续行与题号后的首行对齐。
]

#compare(title: [`problem/hang` 的效果], setup: (problem: (show-points: false)), ```latex
\begin{problem}
  默认解答题题干保持首行缩进。题干较长并换行时，后续文字从页面左侧开始。
\end{problem}

\begin{problem}[hang = true]
  悬挂模式下，题干换行后的文字与题号后的首行对齐。
\end{problem}
```, ```typ
#problem[
  默认解答题题干保持首行缩进。题干较长并换行时，后续文字从页面左侧开始。题干较长并换行时，后续文字从页面左侧开始。
]

#problem(hang: true)[
  悬挂模式下，题干换行后的文字与题号后的首行对齐。悬挂模式下，题干换行后的文字与题号后的首行对齐。
]
```)

#entry(("question/points-prelabel", "question/points-postlabel"), ("question: (points-prelabel: ..)", "(points-postlabel: ..)"), latex-syntax: ```latex points-prelabel = {（}, points-postlabel = {分）}```, typst-syntax: ```typ points-prelabel: [（], points-postlabel: [分）]```)[
    分值前后的内容，默认为“（2 分）”的效果。
]

=== 选择题

#entry("choices", "choices", latex-syntax: ```latex choices = {⟨键值列表⟩}```, typst-syntax: ```typ choices: (⟨键⟩: ⟨值⟩)```)[
    `choices` 的设置，可以写在 `exam-setup` 中，也可以写在 `choices(...)` 中只作用于这一次。
]

#entry("choices/index", "choices: (index: ..)", latex-syntax: ```latex index = ⟨integer⟩```, typst-syntax: ```typ index: 1```)[
    第一个选项标签的编号。
]

#compare(title: [`choices/index` 示例], ```latex
\begin{choices}
  \item 1
  \item 2
  \item 3
\end{choices}

\begin{choices}[index = 2]
  \item 1
  \item 2
  \item 3
\end{choices}
```, ```typ
#choices[1][2][3]

#choices(index: 2)[1][2][3]
```)

#entry(("choices/show-answer", "choices/answer-color"), ("choices: (show-answer: ..)", "(answer-color: ..)"), latex-syntax: ```latex \item* ⟨正确选项⟩, show-answer = true, answer-color = red```, typst-syntax: ```typ #choices(answer: "BD", show-answer: true, answer-color: red)```)[
    LaTeX 版在 `\item` 后加星号标记正确选项；Typst 版用 `answer` 给出正确选项，字母按选项标签计算，整数按选项序号计算。`show-answer: true` 时正确选项的标签和内容用 `answer-color` 着色。该设置不与 `question/show-answer` 联动；教师版会同时打开二者。
]

#compare(title: [使用 `\item*` 标记并显示正确选项], ```latex
\begin{choices}[show-answer = true, answer-color = blue]
  \item 错误选项
  \item* 正确选项
  \item 错误选项
  \item* 另一个正确选项
\end{choices}
```, ```typ
#choices(show-answer: true, answer-color: blue, answer: "BD")[错误选项][正确选项][错误选项][另一个正确选项]
```)

#entry("choices/column-sep", "choices: (column-sep: ..)", latex-syntax: ```latex column-sep = 1em```, typst-syntax: ```typ column-sep: 1em```)[
    选项列之间的最小间隔。
]

#entry(("choices/left-indent", "choices/right-indent", "choices/margin"), ("choices: (left-indent: ..)", "(right-indent: ..)", "(margin: ..)"), latex-syntax: ```latex left-indent = 1em, right-indent = 1em, margin = 1em```, typst-syntax: ```typ left-indent: 1em, right-indent: 1em, margin: 1em```)[
    整组选项的左右缩进，`margin` 同时设置两者。缩进先从可用宽度中扣除，再计算列数和每列宽度。
]

#compare(title: [`choices/left-indent` 和 `choices/right-indent` 的效果], ```latex
\begin{enumerate}
  \item 题干
    \begin{choices}[left-indent = 1em, right-indent = 1em]
      \item 选项一
      \item 选项二
      \item 选项三
      \item 选项四
    \end{choices}
\end{enumerate}
```, ```typ
+ 题干
  #choices(left-indent: 1em, right-indent: 1em)[选项一][选项二][选项三][选项四]
```)

#entry("choices/columns", "choices: (columns: ..)", latex-syntax: ```latex columns = ⟨integer⟩（0 为自动）```, typst-syntax: ```typ columns: auto | ⟨integer⟩```)[
    强制按该列数排版选项。LaTeX 版的 `0`（自动选择列数）在 Typst 版中写成 `auto`。
]

#entry("choices/label", "choices: (label: ..)", latex-syntax: ```latex label = \Alph*.```, typst-syntax: ```typ label: "A."```)[
    标签格式，规则与 `question/label` 相同。`label: none` 去掉标签；问卷中的方框、圆圈标签直接写成内容。
]

#compare(title: [`choices` 环境 label 的使用示例], ```latex
\begin{choices}
  \item 第一项
  \item 第二项
  \item 第三项
  \item 第四项
\end{choices}

\begin{choices}[label = \arabic*)]
  \item 第一项
  \item 第二项
  \item 第三项
  \item 第四项
\end{choices}
```, ```typ
#choices[第一项][第二项][第三项][第四项]

#choices(label: "1)")[第一项][第二项][第三项][第四项]
```)

#compare(title: [label 为正方形], ```latex
\begin{choices}[label = $\square$]
  \item 第一项
  \item 第二项
  \item 第三项
  \item 第四项
\end{choices}
```, ```typ
#choices(label: $square$)[第一项][第二项][第三项][第四项]
```)

#compare(title: [label 为圆形], ```latex
\begin{choices}[label = \textbigcircle]
  \item 第一项
  \item 第二项
  \item 第三项
  \item 第四项
\end{choices}
```, ```typ
#choices(label: $circle.stroked.big$)[第一项][第二项][第三项][第四项]
```)

#entry("choices/label-pos", "choices: (label-pos: ..)", latex-syntax: ```latex label-pos = auto | top-left | left | bottom```, typst-syntax: ```typ label-pos: auto | "top-left" | "left" | "bottom"```)[
    标签相对于选项内容的位置。`auto` 根据内容高度判断：高度超过两行时视为图片，标签垂直居中；`"top-left"` 在内容左侧顶部；`"left"` 在内容左侧中间；`"bottom"` 在内容下方。
]

#compare(```latex
\begin{choices}[label-pos = bottom]
  \item \includegraphics[width=2cm]{example-image.png}
  \item \includegraphics[width=2cm]{example-image.png}
  \item \includegraphics[width=2cm]{example-image.png}
  \item \includegraphics[width=2cm]{example-image.png}
\end{choices}
```, ```typ
#let fig = image("../examples/assets/example-image.svg", width: 2cm)
#choices[#fig][#fig][#fig][#fig]
#choices(label-pos: "bottom")[#fig][#fig][#fig][#fig]
```)

#entry("choices/label-align", "choices: (label-align: ..)", latex-syntax: ```latex label-align = left | center | right```, typst-syntax: ```typ label-align: left | center | right```)[
    标签内部的对齐方式，默认左对齐。
]

#compare(title: [`label-align` 的效果示例], ```latex
\begin{choices}[index = 8, label = \arabic*.]
  \item 1
  \item 2
  \item 3
  \item 4
\end{choices}
\begin{choices}[index = 8, label = \arabic*., label-align = left]
  \item 1
  \item 2
  \item 3
  \item 4
\end{choices}
\begin{choices}[index = 8, label = \arabic*., label-align = center]
  \item 1
  \item 2
  \item 3
  \item 4
\end{choices}
```, ```typ
#choices(index: 8, label: "1.", label-align: right)[1][2][3][4]
#choices(index: 8, label: "1.", label-align: left)[1][2][3][4]
#choices(index: 8, label: "1.", label-align: center)[1][2][3][4]
```)

#entry("choices/label-sep", "choices: (label-sep: ..)", latex-syntax: ```latex label-sep = 0.5em```, typst-syntax: ```typ label-sep: 0.5em```)[
    标签与选项之间的距离。
]

#entry("choices/label-width", "choices: (label-width: ..)", latex-syntax: ```latex label-width = 0pt```, typst-syntax: ```typ label-width: 0pt```)[
    标签的宽度。宽度不足时自动调整为最长标签的宽度。
]

#entry("choices/max-columns", "choices: (max-columns: ..)", latex-syntax: ```latex max-columns = 4```, typst-syntax: ```typ max-columns: 4```)[
    选项的最大列数。排版时先尝试该列数，放不下时把列数除以 2 并取整再尝试，直到可以放下全部选项。
]

#entry(("choices/top-sep", "choices/bottom-sep"), ("choices: (top-sep: ..)", "(bottom-sep: ..)"), latex-syntax: ```latex top-sep = 0pt, bottom-sep = 0pt```, typst-syntax: ```typ top-sep: 0.3em, bottom-sep: 0.3em```)[
    选项上方与下方的间距。
]

#entry("choices/linesep", "choices: (linesep: ..)", latex-syntax: ```latex linesep = 0pt plus .5ex```, typst-syntax: ```typ linesep: 0pt```)[
    选项多于一行时，行与行之间的额外间距（在正常行距之外）。
]

#entry("choices/item-linesep", "choices: (item-linesep: ..)", latex-syntax: ```latex item-linesep = 0pt```, typst-syntax: ```typ item-linesep: 0pt```)[
    多行选项内部相邻文字行的额外间距，与控制不同选项行之间距离的 `linesep` 相互独立。
]

#compare(title: [`choices/item-linesep` 的效果], ```latex
\begin{choices}[columns = 2, item-linesep = 3pt]
  \item 这是一个会自动换行的较长选项，用于展示选项内部的额外行距。
  \item 含有公式 $\displaystyle \frac{a_1+a_2}{b_1+b_2}$ 的多行选项。
\end{choices}
```, ```typ
#choices(columns: 2, item-linesep: 3pt)[这是一个会自动换行的较长选项，用于展示选项内部的额外行距。][含有公式 $display((a_1 + a_2)/(b_1 + b_2))$ 的多行选项。]
```)

#entry("paren", "paren", latex-syntax: ```latex paren = {⟨键值列表⟩}```, typst-syntax: ```typ paren: (⟨键⟩: ⟨值⟩)```)[
    `paren` 的设置。
]

#entry("paren/show-answer", "paren: (show-answer: ..)", latex-syntax: ```latex show-answer = true | false```, typst-syntax: ```typ show-answer: true | false```)[
    控制 `paren` 答案的显示与否。与 `question/show-answer` 同时出现时，`paren` 自己的设置优先。
]

#entry("paren/show-paren", "paren: (show-paren: ..)", latex-syntax: ```latex show-paren = true | false```, typst-syntax: ```typ show-paren: true | false```)[
    是否显示括号，默认显示。
]

#entry("paren/text-color", "paren: (text-color: ..)", latex-syntax: ```latex text-color = ⟨color⟩```, typst-syntax: ```typ text-color: red```)[
    括号中答案的颜色。
]

#entry("paren/type", "paren: (type: ..)", latex-syntax: ```latex type = hfill | dotfill | none```, typst-syntax: ```typ type: "hfill" | "dotfill" | "none"```)[
    `"hfill"` 用空白把括号排到行末；`"dotfill"` 用点线填充后再放置括号；`"none"` 表示括号紧跟前面的内容。
]

#compare(title: [`paren/type` 效果展示], ```latex
\examsetup{
  paren = {
    show-paren = true
  }
}
\begin{question}
  一共有 \paren[A] 个苹果？
  \begin{choices}
    \item 1
    \item 2
    \item 3
    \item 4
  \end{choices}
\end{question}

\examsetup{
  paren = {
    type = none
  }
}

\begin{question}
  一共有 \paren[B] 个苹果？
  \begin{choices}
    \item 1
    \item 2
    \item 3
    \item 4
  \end{choices}
\end{question}
```, ```typ
#exam-setup(paren: (show-paren: true))
#question[
  一共有 #paren[A] 个苹果？
  #choices[1][2][3][4]
]

#exam-setup(paren: (type: "none"))

#question[
  一共有 #paren[B] 个苹果？
  #choices[1][2][3][4]
]
```)

#entry("question/label-align", "question: (label-align: ..)", latex-syntax: ```latex label-align = left | center | right```, typst-syntax: ```typ label-align: left | center | right```)[
    题号的对齐方式，默认右对齐。题号位的宽度为 `label-width`（默认 1.3em），题号更宽时自动加宽。
]

=== 填空题

#entry("fillin", "fillin", latex-syntax: ```latex fillin = {⟨键值列表⟩}```, typst-syntax: ```typ fillin: (⟨键⟩: ⟨值⟩)```)[
    `fillin` 的设置，可以写在 `exam-setup` 中，也可以写在 `fillin(...)` 中只作用于这一个。
]

#entry("fillin/type", "fillin: (type: ..)", latex-syntax: ```latex type = line | paren | circle | rectangle | blank```, typst-syntax: ```typ type: "line" | "paren" | "circle" | "rectangle" | "blank"```)[
    填空的类型：`"line"` 下划线；`"paren"` 括号；`"rectangle"` 外包一个矩形；`"circle"` 外包一个圆，内容变多时拉伸；`"blank"` 没有任何装饰。
]

#compare(title: [`\fillin` 的类型以及参数使用方式], ```latex
答案是 \fillin \fillin[]
\fillin[type = paren][]
\fillin[type = circle][]
\fillin[type = blank][]
```, ```typ
答案是 #fillin() #fillin()
#fillin(type: "paren")
#fillin(type: "circle")
#fillin(type: "blank")
```)

#entry("fillin/no-answer-type", "fillin: (no-answer-type: ..)", latex-syntax: ```latex no-answer-type = blacktriangle | counter | none```, typst-syntax: ```typ no-answer-type: "blacktriangle" | "counter" | "none"```)[
    不显示答案时空里的内容：`"blacktriangle"`（默认）显示黑色三角形；`"counter"` 显示编号，每用一次加一，用于英语完形填空；`"none"` 只留出 `width` 宽的空白。
]

#compare(```latex
\examsetup{fillin/no-answer-type = counter}
I \fillin[am] a student. She \fillin[is] a teacher. They \fillin[are] friends.
```, ```typ
#exam-setup(fillin: (no-answer-type: "counter"))
I #fillin[am] a student. She #fillin[is] a teacher. They #fillin[are] friends.
```)

#entry("fillin/no-answer-counter-index", "fillin: (no-answer-counter-index: ..)", latex-syntax: ```latex no-answer-counter-index = 1```, typst-syntax: ```typ #exam-setup(fillin: (no-answer-counter-index: 21))```)[
    下一个编号空的编号，例如完形填空从第 21 空开始。
]

#entry("fillin/no-answer-counter-label", "fillin: (no-answer-counter-label: ..)", latex-syntax: ```latex no-answer-counter-label = \arabic*```, typst-syntax: ```typ no-answer-counter-label: "1"```)[
    编号空的编号格式，规则与 `question/label` 相同。
]

#compare(```latex
\examsetup{fillin/no-answer-type = counter, fillin/no-answer-counter-index = 21, fillin/no-answer-counter-label = \circlednumber*}
I \fillin[am] a student. She \fillin[is] a teacher.
```, ```typ
#exam-setup(fillin: (no-answer-type: "counter", no-answer-counter-index: 21, no-answer-counter-label: "①"))
I #fillin[am] a student. She #fillin[is] a teacher.
```)

#entry("fillin/show-answer", "fillin: (show-answer: ..)", latex-syntax: ```latex show-answer = true | false```, typst-syntax: ```typ show-answer: true | false```)[
    控制 `fillin` 答案的显示与否。与 `question/show-answer` 同时出现时，`fillin` 自己的设置优先。
]

#entry(("fillin/width", "fillin/width-extra"), ("fillin: (width: ..)", "(width-extra: ..)"), latex-syntax: ```latex width = 3em | auto, width-extra = 0pt```, typst-syntax: ```typ width: 3em | auto | 50%, width-extra: 0pt```)[
    `no-answer-type: "none"` 时空白的宽度，默认 3em。`auto` 按已输入答案的自然宽度留空，再加上 `width-extra`；没有答案时仍用 3em。Typst 版的宽度还可以是行宽的比例，如 `120%`（对应 `1.2\linewidth`）。
]

#compare(title: [按答案自然宽度留空], ```latex
\examsetup{fillin = { show-answer = false, no-answer-type = none }}

默认固定宽度：春眠不觉晓，\fillin[处处闻啼鸟]。

按答案留空：春眠不觉晓，
\fillin[width = auto][处处闻啼鸟]。

全局设置：\examsetup{fillin/width = auto}
夜来风雨声，\fillin[花落知多少]。
```, ```typ
#exam-setup(fillin: (show-answer: false, no-answer-type: "none"))

默认固定宽度：春眠不觉晓，#fillin[处处闻啼鸟]。

按答案留空：春眠不觉晓，
#fillin(width: auto)[处处闻啼鸟]。

全局设置：#exam-setup(fillin: (width: auto))
夜来风雨声，#fillin[花落知多少]。
```)

#entry("fillin/width-type", "fillin: (width-type: ..)", latex-syntax: ```latex width-type = fill | normal```, typst-syntax: ```typ width-type: "fill" | "normal"```)[
    空白比当前行剩余长度还宽时，多出部分在下一行的表现：`"normal"`（默认）严格按 `width` 排版；`"fill"` 让最后一行延伸到行末。LaTeX 版依赖 linegoal，需要编译两次；Typst 版一次即可。
]

#compare(title: [`width-type` 示例], ```latex
\examsetup{fillin/no-answer-type=none}
测试 测试测试，测试 \fillin[width = 3em][答案]

测试 测试测试，测试 \fillin[width = 0.5\linewidth][答案]

测试
\fillin[width = 1.1\linewidth][答案] 测试

测试
\fillin[width-type = fill, width = 1.1\linewidth][答案] 测试

测试
\fillin[width-type = normal, width = 1.1\linewidth][答案] 测试
```, ```typ
#exam-setup(fillin: (no-answer-type: "none"))
测试 测试测试，测试 #fillin(width: 3em)[答案]

测试 测试测试，测试 #fillin(width: 50%)[答案]

测试
#fillin(width: 110%)[答案] 测试

测试
#fillin(width-type: "fill", width: 110%)[答案] 测试

测试
#fillin(width-type: "normal", width: 110%)[答案] 测试
```)

#entry(("fillin/box-color", "fillin/text-color"), ("fillin: (box-color: ..)", "(text-color: ..)"), latex-syntax: ```latex box-color = black, text-color = black```, typst-syntax: ```typ box-color: black, text-color: black```)[
    线、括号、圆圈或方框的颜色，及答案的颜色。
]

#compare(```latex
\examsetup{fillin/show-answer = true, fillin/text-color = red, fillin/box-color = blue}
\fillin[答案] \fillin[type = circle][B] \fillin[type = rectangle][C]
```, ```typ
#exam-setup(fillin: (show-answer: true, text-color: red, box-color: blue))
#fillin[答案] #fillin(type: "circle")[B] #fillin(type: "rectangle")[C]
```)

#entry("fillin/paren-type", "fillin: (paren-type: ..)", latex-syntax: ```latex paren-type = banjiao | quanjiao```, typst-syntax: ```typ paren-type: "banjiao" | "quanjiao"```)[
    `type: "paren"` 时的括号类型：`"banjiao"`（默认）半角括号，`"quanjiao"` 全角括号。
]

#entry(("fillin/depth", "—"), ("fillin: (depth: ..)", "fillin: (stroke: ..)"), latex-syntax: ```latex depth = 0.4em```, typst-syntax: ```typ depth: 0.3em, stroke: 0.5pt```)[
    下划线在基线下方的距离；答案有分式等较深的内容时，下划线自动下移。Typst 版还可以用 `stroke` 设置线宽。
]

=== 解答题

#entry("solution", "solution", latex-syntax: ```latex solution = {⟨键值列表⟩}```, typst-syntax: ```typ solution: (⟨键⟩: ⟨值⟩)```)[
    `solution` 的设置。LaTeX 版只能通过 `\examsetup` 设置；Typst 版也可以写在 `solution(...)` 中只作用于这一个。下面的示例都设置了 `show-solution: "show-stay"`。
]

#entry("solution/show-solution", "solution: (show-solution: ..)", latex-syntax: ```latex show-solution = hide | show-stay | show-move```, typst-syntax: ```typ show-solution: "hide" | "show-stay" | "show-move"```)[
    `"hide"`（默认）隐藏，`"show-stay"` 显示在原处，`"show-move"` 显示在最后的“参考答案”中。在文中某处调用 `print-moved-solutions()` 可以把它们排在那里。
]

#shot("teacher-moved", width: 60%, caption: [`show-move` 的效果])

#entry("solution/pre-analysis", "solution: (pre-analysis: ..)", latex-syntax: ```latex pre-analysis = 【解析】```, typst-syntax: ```typ pre-analysis: [【解析】]```)[
    移到最后时，每条解答前的内容。
]

#entry("solution/parbreak", "solution: (parbreak: ..)", latex-syntax: ```latex parbreak = true | false```, typst-syntax: ```typ parbreak: true | false```)[
    解答内容是否在标签（默认“解答”）后新起一段开始。
]

#entry(("solution/show-qed", "solution/qedsymbol"), ("solution: (show-qed: ..)", "(qedsymbol: ..)"), latex-syntax: ```latex show-qed = true, qedsymbol = $\square$```, typst-syntax: ```typ show-qed: true, qedsymbol: $square$```)[
    是否显示解答结束的符号，及结束符号（可以是文字）。
]

#compare(title: [`qedsymbol` 示例], setup: (solution: (show-solution: "show-stay")), ```latex
\begin{solution}
  测试
\end{solution}
\examsetup{
  solution = {
    qedsymbol = \#
  }
}
\begin{solution}
  测试
\end{solution}
```, ```typ
#solution[测试]
#exam-setup(solution: (qedsymbol: [\#]))
#solution[测试]
```)

#entry("solution/label-content", "solution: (label-content: ..)", latex-syntax: ```latex label-content = 解答```, typst-syntax: ```typ label-content: [解答]```)[
    解答开头的标签，默认“解答”。想写成“证明”时，可以定义自己的函数（LaTeX 版重定义 `proof` 环境）：
]

#compare(setup: (solution: (show-solution: "show-stay")), ```latex
\RenewDocumentEnvironment{proof}{O{}}{%
  \begin{solution}[label-content = 证明, pre-analysis = 【证明】, #1]
}{\end{solution}}
```, ```typ
#let proof = solution.with(label-content: [证明], pre-analysis: [【证明】])
#proof[由题设可知……]
```)

#entry("solution/label-indentation", "solution: (label-indentation: ..)", latex-syntax: ```latex label-indentation = true | false```, typst-syntax: ```typ label-indentation: true | false```)[
    标签是否缩进，默认缩进。
]

#entry("solution/label-punct", "solution: (label-punct: ..)", latex-syntax: ```latex label-punct = {}```, typst-syntax: ```typ label-punct: [：]```)[
    标签后的标点，默认为空。Typst 版还可以用 `label-format` 设置标签格式（默认加粗）。
]

#entry(("solution/score-pre-content", "solution/score-post-content"), ("solution: (score-pre-content: ..)", "(score-post-content: ..)"), latex-syntax: ```latex score-pre-content = {}, score-post-content = 分```, typst-syntax: ```typ score-pre-content: none, score-post-content: [分]```)[
    `score` 前后的内容。
]

#compare(title: [`score-pre-content` 和 `score-post-content` 示例], setup: (solution: (show-solution: "show-stay")), ```latex
\examsetup{
  solution = {
    score-pre-content = 这个点可以有,
    score-post-content = 分的分数
  }
}
\begin{solution}
  函数的定义域为 $(0, +\infty)$,
  又 \[f^{\prime}(x) = 1 - \ln x-1 = -\ln x, \score{2}\]
  当 $x \in(0, 1)$ 时, $f^{\prime}(x) > 0$, 当 $x \in(1, +\infty)$ 时, $f^{\prime}(x) < 0$,
  故 $f(x)$ 的递增区间为 $(0,1)$, 递减区间为 $(1, +\infty)$.
\end{solution}
```, ```typ
#exam-setup(solution: (score-pre-content: [这个点可以有], score-post-content: [分的分数]))
#solution[
  函数的定义域为 $(0, +infinity)$，
  又 $ f'(x) = 1 - ln x - 1 = -ln x, #score(2) $
  当 $x in (0, 1)$ 时，$f'(x) > 0$，当 $x in (1, +infinity)$ 时，$f'(x) < 0$，故 $f(x)$ 的递增区间为 $(0, 1)$，递减区间为 $(1, +infinity)$。
]
```)

将 `score-pre-content` 和 `score-post-content` 设置为空就可以产生批注效果：

#compare(title: [`score-pre-content` 和 `score-post-content` 为空产生批注效果], setup: (solution: (show-solution: "show-stay")), ```latex
\examsetup{
  solution = {score-pre-content = {}, score-post-content = {}}
}
\begin{solution}
  函数的定义域为 $(0, +\infty)$,
  又 \[f^{\prime}(x) = 1 - \ln x-1 = -\ln x, \score{这是关键点}\]
  当 $x \in(0, 1)$ 时, $f^{\prime}(x) > 0$, 当 $x \in(1, +\infty)$ 时, $f^{\prime}(x) < 0$,
  故 $f(x)$ 的递增区间为 $(0,1)$, 递减区间为 $(1, +\infty)$.
\end{solution}
```, ```typ
#exam-setup(solution: (score-pre-content: none, score-post-content: none))
#solution[
  函数的定义域为 $(0, +infinity)$，
  又 $ f'(x) = 1 - ln x - 1 = -ln x, #score[这是关键点] $
  当 $x in (0, 1)$ 时，$f'(x) > 0$，当 $x in (1, +infinity)$ 时，$f'(x) < 0$，故 $f(x)$ 的递增区间为 $(0, 1)$，递减区间为 $(1, +infinity)$。
]
```)

#entry("solution/score-format", "solution: (score-format: ..)", latex-syntax: ```latex score-format = \color{red}```, typst-syntax: ```typ score-format: (fill: red)```)[
    `score` 内容的格式。
]

#compare(title: [`score-format` 示例], setup: (solution: (show-solution: "show-stay")), ```latex
\examsetup{
  solution = {
    score-format = {\sffamily \huge \color{blue}}
  }
}
\begin{solution}
  测试 \score{2}
\end{solution}
```, ```typ
#exam-setup(solution: (score-format: (family: "sans", size: 20pt, fill: blue)))
#solution[测试 #score(2)]
```)

#entry("solution/score-showleader", "solution: (score-showleader: ..)", latex-syntax: ```latex score-showleader = true | false```, typst-syntax: ```typ score-showleader: true | false```)[
    `score` 的引导线显示与否。
]

#entry("solution/text-color", "solution: (text-color: ..)", latex-syntax: ```latex text-color = black```, typst-syntax: ```typ text-color: black```)[
    解答内容的颜色。
]

#entry(("solution/blank-type", "solution/blank-vsep"), ("solution: (blank-type: ..)", "(blank-vsep: ..)"), latex-syntax: ```latex blank-type = none | manual | hide, blank-vsep = 12ex plus 1ex minus 1ex```, typst-syntax: ```typ blank-type: "none" | "manual" | "hide", blank-vsep: 12em```)[
    隐藏解答时是否留出空白给学生答题：`"none"` 不留；`"manual"` 留 `blank-vsep` 的高度；`"hide"` 留与解答等高的空白。
]

#compare(```latex
\examsetup{solution/show-solution = hide, solution/blank-type = manual, solution/blank-vsep = 4em}
\begin{problem}[points = 4]
  求 $f(x) = x^2$ 的最小值。
  \begin{solution} 最小值为 $0$。 \end{solution}
\end{problem}
```, ```typ
#exam-setup(solution: (show-solution: "hide", blank-type: "manual", blank-vsep: 4em))
#problem(points: 4)[
  求 $f(x) = x^2$ 的最小值。
  #solution[最小值为 $0$。]
]
#line(length: 100%, stroke: (dash: "dashed", paint: gray))
```)

=== 几个列表环境

#entry("list", "list", latex-syntax: ```latex list = {⟨键值列表⟩}```, typst-syntax: ```typ list: (⟨键⟩: ⟨值⟩)```)[
    `step`、`method`、`case` 的设置。
]

#entry(("list/step-name", "list/method-name", "list/case-name"), ("list: (step-name: ..)", "(method-name: ..)", "(case-name: ..)"), latex-syntax: ```latex step-name = 步骤, method-name = 方法, case-name = 情形```, typst-syntax: ```typ step-name: [步骤], method-name: [方法], case-name: [情形]```)[
    三个列表的标签名。
]

#entry(("list/step-punct", "list/method-punct", "list/case-punct"), ("list: (step-punct: ..)", "(method-punct: ..)", "(case-punct: ..)"), latex-syntax: ```latex step-punct = ., method-punct = {}, case-punct = .```, typst-syntax: ```typ step-punct: [.], method-punct: none, case-punct: [.]```)[
    标签后的标点。
]

#compare(```latex
\examsetup{list/step-name = 第, list/step-punct = 步：}
\begin{step} \item 审题 \item 列式 \end{step}
```, ```typ
#exam-setup(list: (step-name: [第], step-punct: [步：]))
#step[审题][列式]
```)

=== 草稿纸

#entry("draft", "draft", latex-syntax: ```latex draft = {⟨键值列表⟩}```, typst-syntax: ```typ draft: (⟨键⟩: ⟨值⟩)```)[
    `draftpaper` 的设置，也可以写在 `draftpaper(...)` 中只作用于这一页。
]

#entry("draft/watermark-size", "draft: (watermark-size: ..)", latex-syntax: ```latex watermark-size = 100pt```, typst-syntax: ```typ watermark-size: auto | 100pt```)[
    “草稿纸”水印的大小。`auto` 时 A4 为 100pt，A3 为 180pt。
]

#entry("draft/show-watermark", "draft: (show-watermark: ..)", latex-syntax: ```latex show-watermark = true | false```, typst-syntax: ```typ show-watermark: true | false```)[
    是否显示水印。LaTeX 版需要编译两次才出现水印；Typst 版一次即可。水印的文字与颜色由 `watermark-text`、`watermark-color` 设置。
]

#entry("draft/show-draft", "draft: (show-draft: ..)", latex-syntax: ```latex show-draft = auto | manual```, typst-syntax: ```typ show-draft: "auto" | "manual"```)[
    是否在文档最后自动添加两页草稿纸。`"auto"` 自动添加；`"manual"`（默认）不添加，需要时手动写 `draftpaper()`。密封线的作用范围包括草稿纸。
]

=== 评分框

#entry("scoringbox", "scoringbox", latex-syntax: ```latex scoringbox = {⟨键值列表⟩}```, typst-syntax: ```typ scoringbox: (⟨键⟩: ⟨值⟩)```)[
    评分框的设置。Typst 版还可以设置格子的 `cell-width` 与 `cell-height`。
]

#entry("scoringbox/type", "scoringbox: (type: ..)", latex-syntax: ```latex type = onecolumn | twocolumn | none```, typst-syntax: ```typ type: "onecolumn" | "twocolumn" | none```)[
    把评分框和大题标题结合：`"onecolumn"` 为只有“得分”的评分框，`"twocolumn"` 为有“得分”和“阅卷人”的评分框，`none`（默认）不显示。
]

#entry("scoringbox/position", "scoringbox: (position: ..)", latex-syntax: ```latex position = left | right```, typst-syntax: ```typ position: left | right```)[
    评分框在大题标题的左边或右边。
]

#compare(```latex
\examsetup{scoringbox/type = twocolumn, scoringbox/position = right}
\section{选择题：本题共 8 小题，每小题 5 分，共 40 分。}
```, ```typ
#exam-setup(scoringbox: (type: "twocolumn", position: right))
= 选择题：本题共 8 小题，每小题 5 分，共 40 分。
```)

=== 选择标记题型

#entry("select", "select", latex-syntax: ```latex select = {⟨键值列表⟩}```, typst-syntax: ```typ select: (⟨键⟩: ⟨值⟩)```)[
    `select` 的设置，也可以写在 `select(...)` 中。
]

#entry(("select/mark-symbol", "chinese/mark-symbol"), "select: (mark-symbol: ..)", latex-syntax: ```latex mark-symbol = $\checkmark$```, typst-syntax: ```typ mark-symbol: sym.checkmark```)[
    标记符号。
]

#compare(title: [`mark-symbol` 使用示例], ```latex
\begin{select}[mark-symbol = {\textcolor{red}{$\times$}},show-mark = true]
  \sitem 正确
  \sitem* 错误
  \sitem* 错误
\end{select}
```, ```typ
#select(mark-symbol: text(fill: red, $times$), show-mark: true, answer: (2, 3))[正确][错误][错误]
```)

#entry(("select/show-mark", "chinese/show-mark"), "select: (show-mark: ..)", latex-syntax: ```latex show-mark = true | false```, typst-syntax: ```typ show-mark: true | false```)[
    是否显示标记符号，默认不显示；教师版显示。
]

#entry(("select/mark-position", "chinese/mark-position"), "select: (mark-position: ..)", latex-syntax: ```latex mark-position = top | above | below | bottom | left | right```, typst-syntax: ```typ mark-position: top | bottom | left | right```)[
    标记符号相对于内容的位置，默认 `right`。LaTeX 版中 `above` 与 `top`、`below` 与 `bottom` 同义；Typst 版写 `top`、`bottom`。
]

#entry(("select/mark-xshift", "select/mark-yshift", "chinese/mark-xshift", "chinese/mark-yshift"), ("select: (mark-xshift: ..)", "(mark-yshift: ..)"), latex-syntax: ```latex mark-xshift = 0pt, mark-yshift = 0pt```, typst-syntax: ```typ mark-xshift: 0pt, mark-yshift: 0pt```)[
    标记符号的水平和垂直偏移量。
]

#entry(("select/separator", "chinese/separator"), "select: (separator: ..)", latex-syntax: ```latex separator = \hspace{1em}```, typst-syntax: ```typ separator: h(1em)```)[
    选项之间的分隔。
]

#entry(("select/pre-content", "select/post-content", "chinese/pre-content", "chinese/post-content"), ("select: (pre-content: ..)", "(post-content: ..)"), latex-syntax: ```latex pre-content = (, post-content = )```, typst-syntax: ```typ pre-content: [(], post-content: [)]```)[
    选项前后的内容。
]

#compare(title: [`select` 相关键值的综合使用], ```latex
折
\begin{select}[pre-content = {[}, post-content = {\}}, mark-symbol = {\tiny $\triangle$}, separator = {, },mark-position = bottom, show-mark=true]
  \sitem \pinyin{zhe1}
  \sitem \pinyin{zhe2}
  \sitem \pinyin{zhe3}
  \sitem \pinyin{zhe4}
  \sitem \pinyin{she1}
  \sitem* \pinyin{she2}
  \sitem \pinyin{she3}
  \sitem \pinyin{she4}
\end{select}
本
```, ```typ
折#select(pre-content: [\[], post-content: [\}], mark-symbol: text(size: 0.5em, $triangle$), separator: [, ], mark-position: bottom, show-mark: true, answer: 6)[zhē][zhé][zhě][zhè][shē][shé][shě][shè]本
```)

=== 作文格

#entry("composition-grid", "composition-grid", latex-syntax: ```latex composition-grid = {⟨键值列表⟩}```, typst-syntax: ```typ composition-grid: (⟨键⟩: ⟨值⟩)```)[
    `composition-grid` 的设置，也可以写在 `composition-grid(...)` 中。
]

#entry("composition-grid/columns", "composition-grid: (columns: ..)", latex-syntax: ```latex columns = 20```, typst-syntax: ```typ columns: 20```)[
    每行的格子数。
]

#entry("composition-grid/row-sep-ratio", "composition-grid: (row-sep-ratio: ..)", latex-syntax: ```latex row-sep-ratio = 2```, typst-syntax: ```typ row-sep-ratio: 2```)[
    行间距比例，数值越大行间距越小。行间距为格子边长除以（比例 + 1）。
]

#entry(("composition-grid/cell-size", "composition-grid/cell-scale", "composition-grid/cell-format"), ("composition-grid: (cell-size: ..)", "(cell-scale: ..)", "—"), latex-syntax: ```latex cell-size = auto, cell-scale = 1.75, cell-format = ⟨字号⟩```, typst-syntax: ```typ cell-size: auto | 18pt, cell-scale: 1.75```)[
    格子的边长。`cell-size: auto`（默认）时为当前字号乘以 `cell-scale`；也可以直接指定长度。LaTeX 版的 `cell-format`（给 hanzibox 的原始字号命令）在 Typst 版中不需要：用 `cell-size` 指定即可。
]

#entry("composition-grid/frame-type", "composition-grid: (frame-type: ..)", latex-syntax: ```latex frame-type = 口 | 十 | 米 | ...```, typst-syntax: ```typ frame-type: "口" | "田" | "米"```)[
    格子类型：`"口"`（默认）方格，`"田"` 带十字虚线，`"米"` 带十字和对角虚线。hanzibox 的其他格子类型留给独立的汉字格包。
]

#entry(("composition-grid/frame-color", "composition-grid/fill-color", "composition-grid/frame-linewidth"), ("composition-grid: (frame-color: ..)", "(fill-color: ..)", "(frame-linewidth: ..)"), latex-syntax: ```latex frame-color = black, fill-color = , frame-linewidth = 0.4pt```, typst-syntax: ```typ frame-color: black, fill-color: none, frame-linewidth: 0.4pt```)[
    格线颜色、格子填充颜色和格线宽度。
]

#entry("composition-grid/auto-break", "composition-grid: (auto-break: ..)", latex-syntax: ```latex auto-break = true | false```, typst-syntax: ```typ auto-break: true | false```)[
    是否在当前页放不下时自动分页续排，默认是。`false` 时整个网格作为不可分页的一块。
]

#entry("composition-grid/count-marks", "composition-grid: (count-marks: ..)", latex-syntax: ```latex count-marks = {600, 800}```, typst-syntax: ```typ count-marks: (600, 800)```)[
    在指定累计字数所在的行末显示小字提示。每个数值应为 `columns` 的整数倍，且不超过总格数。
]

#entry(("composition-grid/count-format", "composition-grid/count-sep"), ("composition-grid: (count-format: ..)", "(count-sep: ..)"), latex-syntax: ```latex count-format = \scriptsize, count-sep = 2pt```, typst-syntax: ```typ count-format: (size: 6pt), count-sep: 2pt```)[
    字数提示的格式，及它与网格右边框的距离。
]

#entry("composition-grid/hanzibox-options", "—", status: [Typst 中不需要])[
    LaTeX 版向 hanzibox 直接传递的额外选项。Typst 版的作文格由模板绘制，使用上面的选项。
]

#compare(```latex
\compositiongrid[columns = 10, frame-type = 米, frame-color = red!70, cell-size = 2em, count-marks = {20}]{30}
```, ```typ
#composition-grid(30, columns: 10, frame-type: "米", frame-color: red.lighten(30%), cell-size: 2em, count-marks: (20,))
```)

=== 连线题型

#entry("lineto", "lineto", latex-syntax: ```latex lineto = {⟨键值列表⟩}```, typst-syntax: ```typ lineto: (⟨键⟩: ⟨值⟩)```)[
    `lineto` 的设置。
]

#entry("lineto/xsep", "lineto: (xsep: ..)", latex-syntax: ```latex xsep = .25\linewidth```, typst-syntax: ```typ xsep: 25%```)[
    两列之间的距离（列中心之间），可以是长度或行宽的比例。LaTeX 版只能在 `\examsetup` 中设置；Typst 版也可以写在 `lineto(...)` 中。
]

#entry("lineto/ysep", "lineto: (ysep: ..)", latex-syntax: ```latex ysep = 1cm```, typst-syntax: ```typ ysep: 1cm```)[
    两行之间的距离。
]

#entry("lineto/name", "—", status: [写法不同])[
    LaTeX 版中 `\linelistset` 设置的一组的名称，默认为小写罗马数字，连线时写成 `i-1`、`ii-3`。Typst 版按列的顺序和项的序号连线，不需要名称：`connect: ((1, 3),)` 连接第一列第 1 项与第二列第 3 项。Typst 版还提供 `show-lines`（是否画线）、`stroke`（线型）和 `item-inset`（线与文字的间距）。
]

#compare(title: [`lineto/name` 的效果及 `lineto` 环境使用示例], ```latex
\begin{lineto}
  \linelistset{apple, banana, key}
  \linelistset{香蕉, 钥匙, 苹果}
  \lineconnect{i-1,ii-3}
  \lineconnect{i-2,ii-1}
  \lineconnect{i-3,ii-2}
\end{lineto}

\begin{lineto}
  \linelistset[name = a]{apple, banana, key}
  \linelistset[name = b]{香蕉, 钥匙, 苹果}
  \linelistset[name = c]{黄色, 红色,银色}
  \lineconnect{a-1,b-3,c-2}
  \lineconnect{a-2,b-1,c-1}
  \lineconnect{a-3,b-2,c-3}
\end{lineto}
```, ```typ
#exam-setup(lineto: (show-lines: true))
#lineto(
  ([apple], [banana], [key]),
  ([香蕉], [钥匙], [苹果]),
  connect: ((1, 3), (2, 1), (3, 2)),
)

#lineto(
  ([apple], [banana], [key]),
  ([香蕉], [钥匙], [苹果]),
  ([黄色], [红色], [银色]),
  connect: ((1, 3, 2), (2, 1, 1), (3, 2, 3)),
)
```)

=== 语文相关

#entry("material", "material", latex-syntax: ```latex material = {⟨键值列表⟩}```, typst-syntax: ```typ material: (⟨键⟩: ⟨值⟩)```)[
    `material` 的设置，也可以写在 `material(...)` 中。
]

#entry(("material/title", "material/author", "material/source"), ("material(title: ..)", "(author: ..)", "(source: ..)"), latex-syntax: ```latex title = ⟨标题⟩, author = ⟨作者⟩, source = ⟨来源⟩```, typst-syntax: ```typ #material(title: [..], author: [..], source: [..])[..]```)[
    材料上方的标题和作者，及下方右对齐的来源出处；都可以不写。这三项只写在 `material(...)` 中。
]

#entry(("material/title-format", "material/author-format", "material/format", "material/source-format"), ("material: (title-format: ..)", "(author-format: ..)", "(format: ..)", "(source-format: ..)"), latex-syntax: ```latex title-format = \zihao{4}, author-format = \small, format = \kaishu```, typst-syntax: ```typ title-format: (size: 14pt), author-format: (size: 9pt), format: (family: "kai")```)[
    标题、作者、内容和来源的格式。
]

#entry(("material/title-author-sep", "material/top-sep", "material/bottom-sep", "material/title-material-sep"), ("material: (title-author-sep: ..)", "(top-sep: ..)", "(bottom-sep: ..)", "(title-material-sep: ..)"), latex-syntax: ```latex title-author-sep = 2em, top-sep = 0pt, bottom-sep = 0pt, title-material-sep = 0pt```, typst-syntax: ```typ title-author-sep: 2em, top-sep: 0.5em, bottom-sep: 0.5em, title-material-sep: 0.3em```)[
    标题与作者之间、整体上方、整体下方、标题与内容之间的间距。
]

#entry(("poem", "poem/title", "poem/title-format", "poem/author", "poem/author-format", "poem/title-author-sep", "poem/format", "poem/top-sep", "poem/bottom-sep", "poem/title-poem-sep"), "poem", latex-syntax: ```latex poem = {⟨键值列表⟩}```, typst-syntax: ```typ poem: (⟨键⟩: ⟨值⟩)```)[
    `poem` 的设置，也可以写在 `poem(...)` 中。`title`、`author`、`title-format`、`author-format`、`title-author-sep`、`format`、`top-sep`、`bottom-sep` 与 `material` 相同；`title-poem-sep` 为标题与诗之间的间距。
]

#entry("poem/align", "poem: (align: ..)", latex-syntax: ```latex align = l | c | r```, typst-syntax: ```typ align: left | center | right```)[
    诗句在居中的整体内部的对齐方式，默认左对齐。
]

#compare(```latex
\begin{poem}[title = 登鹳雀楼, author = 王之涣, align = c]
  白日依山尽，黄河入海流。\\
  欲穷千里目，更上一层楼。
\end{poem}
```, ```typ
#poem(title: [登鹳雀楼], author: [王之涣], align: center)[
  白日依山尽，黄河入海流。\
  欲穷千里目，更上一层楼。
]
```)

#entry("poem/type", "poem: (type: ..)", latex-syntax: ```latex type = minipage | chinese```, typst-syntax: ```typ type: "minipage" | "chinese"```)[
    注释的排法：`"chinese"`（默认）注释不分行、连着显示，最前面有“［注］”（来源于 2021 年高考语文真题卷）；`"minipage"` 注释上方有横线，每条注释单独一行。
]

#compare(```latex
\begin{poem}[type = minipage, title = 登鹳雀楼\zhu{鹳雀楼：在今山西永济。}, author = 王之涣]
  白日依山尽，黄河入海流\zhu{黄河：一作“黄流”。}。\\
  欲穷千里目，更上一层楼。
\end{poem}
```, ```typ
#poem(type: "minipage", title: [登鹳雀楼#zhu[鹳雀楼：在今山西永济。]], author: [王之涣])[
  白日依山尽，黄河入海流#zhu[黄河：一作“黄流”。]。\
  欲穷千里目，更上一层楼。
]
```)

#entry("poem/zhu-circlednumber-base", "poem: (zhu-circlednumber-base: ..)", latex-syntax: ```latex zhu-circlednumber-base = tikz | font```, typst-syntax: ```typ zhu-circlednumber-base: "tikz" | "font"```)[
    注释的带圈数字：`"font"`（默认）使用字体中的字形，`"tikz"` 绘制圆圈（同 `circled-number`）。
]

=== 图文排版

#entry("multifigures", "multifigures", latex-syntax: ```latex multifigures = {⟨键值列表⟩}```, typst-syntax: ```typ multifigures: (⟨键⟩: ⟨值⟩)```)[
    `multifigures` 的设置，也可以写在 `multifigures(...)` 中。
]

#entry("multifigures/columns", "multifigures: (columns: ..)", latex-syntax: ```latex columns = 3```, typst-syntax: ```typ columns: 3```)[
    每行多少项。
]

#entry("multifigures/fig-pos", "multifigures: (fig-pos: ..)", latex-syntax: ```latex fig-pos = top | above | bottom | below | left | right```, typst-syntax: ```typ fig-pos: top | bottom | left | right```)[
    图片相对于标签的位置，默认 `top`（图片在标签上方）。
]

#entry(("multifigures/top-sep", "multifigures/bottom-sep"), ("multifigures: (top-sep: ..)", "(bottom-sep: ..)"), latex-syntax: ```latex top-sep = 1ex plus .5ex minus .5ex, bottom-sep = 0pt```, typst-syntax: ```typ top-sep: 0.6em, bottom-sep: 0.3em```)[
    整体上方与下方的间距。
]

#entry(("multifigures/column-gap", "—"), ("multifigures: (column-gap: ..)", "(row-gap: ..)"), latex-syntax: ```latex column-gap = 6pt```, typst-syntax: ```typ column-gap: 6pt, row-gap: 1em```)[
    同一行图片之间的列间距；Typst 版还有行间距 `row-gap`。
]

多行图片需要固定列宽时，LaTeX 版用第二个可选参数传给 tabularray（如 `colspec={*{3}{X[4.5cm,c]}}`）；Typst 版写 `column-widths`：

#compare(```latex
\begin{multifigures}[columns=3][colspec={*{3}{X[4.5cm,c]}}]
  \item[题 9 图] \includegraphics[width=3cm]{example-image.png}
  \item[题 10 图] \includegraphics[width=3cm]{example-image.png}
  \item[题 11 图] \includegraphics[width=3cm]{example-image.png}
\end{multifigures}
```, ```typ
#let fig = image("../examples/assets/example-image.svg", width: 3cm)
#multifigures(columns: 3, column-widths: (4.5cm,) * 3,
  ([题 9 图], fig), ([题 10 图], fig), ([题 11 图], fig))
```)

#entry("multifigures/align", "multifigures: (align: ..)", latex-syntax: ```latex align = t | m | b```, typst-syntax: ```typ align: top | horizon | bottom```)[
    图片和标签整体的对齐方式，默认底部对齐。
]

#entry(("multifigures/xshift", "multifigures/yshift", "multifigures/label-xshift", "multifigures/label-yshift", "multifigures/hshift", "multifigures/vshift", "multifigures/label-hshift", "multifigures/label-vshift"), ("multifigures: (xshift: ..)", "(yshift: ..)", "(label-xshift: ..)", "(label-yshift: ..)"), latex-syntax: ```latex xshift, hshift, yshift, vshift, label-xshift, ...```, typst-syntax: ```typ xshift: 0pt, yshift: 0pt, label-xshift: 0pt, label-yshift: 0pt```)[
    图片和标签整体的偏移，及标签相对图片的偏移。LaTeX 版的同义键 `hshift`、`vshift`、`label-hshift`、`label-vshift` 在 Typst 版中统一写成 `xshift`、`yshift`。
]

#entry("textfigure", "textfigure", latex-syntax: ```latex textfigure = {⟨键值列表⟩}```, typst-syntax: ```typ textfigure: (⟨键⟩: ⟨值⟩)```)[
    `textfigure` 的设置，也可以写在 `textfigure(...)` 中。
]

#entry("textfigure/fig-pos", "textfigure: (fig-pos: ..)", latex-syntax: ```latex fig-pos = bottom-right```, typst-syntax: ```typ fig-pos: "bottom-right"```)[
    图片相对于文本的方位，默认 `"bottom-right"`：

    / `top`、`bottom`: 图片在文本上方、下方；
    / `left`、`right`（同 `left-center`、`right-center`）: 图片在文本左边、右边，垂直居中；
    / `top-left`、`top-center`、`top-right`、`top-flushright`: 图片在文本上方，分别靠左、位于整行中间、与文本右端对齐、位于行末；
    / `bottom-left`、`bottom-center`、`bottom-right`、`bottom-flushright`: 同上，图片在文本下方；
    / `left-top`、`left-bottom`、`right-top`、`right-bottom`: 图片在文本左边或右边，顶部或底部对齐。
]

#compare(```latex
\textfigure[fig-pos = left-top]{文字在图片右侧，图片顶部对齐。……}{\includegraphics[width=2cm]{example-image.png}}
\textfigure[fig-pos = top-center]{图片在文字上方居中。}{\includegraphics[width=2cm]{example-image.png}}
```, ```typ
#let fig = image("../examples/assets/example-image.svg", width: 2cm)
#textfigure(fig-pos: "left-top")[文字在图片右侧，图片顶部对齐。文字在图片右侧，图片顶部对齐。][#fig]
#textfigure(fig-pos: "top-center")[图片在文字上方居中。][#fig]
```)

#entry(("textfigure/xshift", "textfigure/yshift", "textfigure/figure-xshift", "textfigure/figure-yshift", "textfigure/hshift", "textfigure/vshift", "textfigure/figure-hshift", "textfigure/figure-vshift"), ("textfigure: (xshift: ..)", "(yshift: ..)", "(figure-xshift: ..)", "(figure-yshift: ..)"), latex-syntax: ```latex xshift, hshift, yshift, vshift, figure-xshift, ...```, typst-syntax: ```typ xshift: 0pt, yshift: 0pt, figure-xshift: 0pt, figure-yshift: 0pt```)[
    图片和文本整体的偏移，及图片相对文本的偏移。同义键 `hshift`、`vshift` 统一写成 `xshift`、`yshift`。
]

#entry(("textfigure/top-sep", "textfigure/bottom-sep"), ("textfigure: (top-sep: ..)", "(bottom-sep: ..)"), latex-syntax: ```latex top-sep = 0pt, bottom-sep = 1.5ex plus .5ex minus 0.5ex```, typst-syntax: ```typ top-sep: 0.3em, bottom-sep: 0.6em```)[
    上方与下方的间距。
]

#entry(("textfigure/text-width", "textfigure/auto-text-width", "textfigure/min-text-width", "textfigure/column-gap"), ("textfigure: (text-width: ..)", "—", "(min-text-width: ..)", "(column-gap: ..)"), latex-syntax: ```latex text-width = \textwidth, auto-text-width = true, min-text-width = .35\linewidth, column-gap = 1em```, typst-syntax: ```typ text-width: auto, min-text-width: 35%, column-gap: 1em```)[
    文本部分的宽度。Typst 版的 `text-width: auto`（默认）就是 LaTeX 版的 `auto-text-width = true`：左右排版时文字宽度等于行宽减去图片宽度和 `column-gap`，但不小于 `min-text-width`；上下排版时为文字的自然宽度。给出长度时使用该宽度。
]

#entry("textfigure/figure-width", "textfigure: (figure-width: ..)", latex-syntax: ```latex figure-width = \columnwidth```, typst-syntax: ```typ figure-width: auto | 4cm```)[
    图片部分的宽度，`auto`（默认）为图片本身的宽度；给出长度时图片在该宽度内居中。
]

#entry(("textfigure/ratio", "textfigure/text-ratio"), "textfigure: (ratio: ..)", latex-syntax: ```latex ratio = 0.95```, typst-syntax: ```typ ratio: 60%```)[
    文字所占行宽的比例，优先于 `text-width`。
]

#compare(```latex
\textfigure[fig-pos = right, ratio = 0.5]{文字只占一半宽度。……}{\includegraphics[width=2cm]{example-image.png}}
```, ```typ
#textfigure(fig-pos: "right", ratio: 50%)[文字只占一半宽度。文字只占一半宽度。文字只占一半宽度。][#image("../examples/assets/example-image.svg", width: 2cm)]
```)

#entry("textfigure/top", "—", status: [留给独立包])[
    `fig-pos = left-top` 时图片从文本的第几行开始，效果与 wrapstuff 的 `top` 相同，属于文字绕排，见 3.4.22 节最后。
]

#entry("textfigure/parindent", "textfigure: (parindent: ..)", latex-syntax: ```latex parindent = 2em```, typst-syntax: ```typ parindent: 2em```)[
    文本部分的段首缩进。
]

=== 数学-计算题排版

#entry("calculations", "calculations", latex-syntax: ```latex calculations = {⟨键值列表⟩}```, typst-syntax: ```typ calculations: (⟨键⟩: ⟨值⟩)```)[
    `calculations` 的设置，也可以写在 `calculations(...)` 中。
]

#entry("calculations/index", "calculations: (index: ..)", latex-syntax: ```latex index = 1```, typst-syntax: ```typ index: 1```)[
    第一个题目的编号。
]

#entry("calculations/columns", "calculations: (columns: ..)", latex-syntax: ```latex columns = 2```, typst-syntax: ```typ columns: 2```)[
    每行多少项。
]

#entry("calculations/fig-pos", "calculations: (fig-pos: ..)", latex-syntax: ```latex fig-pos = top | above | bottom | below | left | right | left-top```, typst-syntax: ```typ fig-pos: "left-top" | "left" | "right" | "top" | "bottom"```)[
    题目相对于编号的位置，默认 `"left-top"`（编号在题目左侧、首行对齐）。同义键 `above`、`below` 写成 `"top"`、`"bottom"`。
]

#compare(```latex
\begin{calculations}[fig-pos = top, columns = 3]
  \item $1 + 1$
  \item $2 + 2$
  \item $3 + 3$
\end{calculations}
```, ```typ
#calculations(fig-pos: "top", columns: 3)[$1 + 1$][$2 + 2$][$3 + 3$]
```)

#entry(("calculations/top-sep", "calculations/bottom-sep"), ("calculations: (top-sep: ..)", "(bottom-sep: ..)"), latex-syntax: ```latex top-sep = 1ex plus .5ex minus .5ex, bottom-sep = 0pt```, typst-syntax: ```typ top-sep: 0.6em, bottom-sep: 0.3em```)[
    上方与下方的间距。
]

#entry(("calculations/hsep", "calculations/vsep"), ("calculations: (hsep: ..)", "(vsep: ..)"), latex-syntax: ```latex hsep = 2em, vsep = 0em```, typst-syntax: ```typ hsep: 2em, vsep: 0pt```)[
    题目之间的水平与垂直间距。
]

#entry("calculations/align", "calculations: (align: ..)", latex-syntax: ```latex align = t | m | b```, typst-syntax: ```typ align: top | horizon | bottom```)[
    同一行各题的对齐方式，默认顶部对齐。
]

#entry(("calculations/xshift", "calculations/hshift", "calculations/yshift", "calculations/vshift", "calculations/label-xshift", "calculations/label-hshift", "calculations/label-yshift", "calculations/label-vshift"), ("calculations: (xshift: ..)", "(label-xshift: ..)", "(label-yshift: ..)"), latex-syntax: ```latex xshift = 2em, label-xshift = 0pt, ...```, typst-syntax: ```typ xshift: 2em, label-xshift: 0pt, label-yshift: 0pt```)[
    整体左侧的缩进，及编号相对题目的偏移。同义键 `hshift`、`vshift`、`label-hshift`、`label-vshift` 统一写成 `xshift`、`yshift`；整体的垂直偏移在 Typst 版中用 `top-sep` 调整。
]
