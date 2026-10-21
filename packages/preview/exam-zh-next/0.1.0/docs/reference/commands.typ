// 3.4 命令和环境介绍：exam-zh-doc 中每个命令与环境的 Typst 对照。

#import "../doc-style.typ": *

== 命令和环境介绍

=== 正体的数学常数

#entry(("\\eu", "\\upe"), ("eu", "upe"),
    latex-syntax: ```latex $\eu$```, typst-syntax: ```typ $eu$```)[
    正体的自然对数的底“e”。`eu` 可以理解为 “e upright” 的缩写或者 “Euler's number” 的首字母。在 Typst 数学公式中直接写变量名即可，不需要反斜杠。
]

#entry(("\\iu", "\\upi"), ("iu", "upi"),
    latex-syntax: ```latex $\iu$```, typst-syntax: ```typ $iu$```)[
    正体的虚数单位“i”。
]

#entry("\\uppi", "uppi", latex-syntax: ```latex $\uppi$```, typst-syntax: ```typ $uppi$```)[
    正体的圆周率“π”。
]

#compare(title: [`\eu`、`\iu` 和 `\uppi` 的效果], ```latex
$\eu \quad \iu \quad \uppi$
```, ```typ
$eu quad iu quad uppi$
```)

=== 优化的命令环境

#entry("\\vec", "vect", latex-syntax: ```latex \vec{⟨content⟩}```, typst-syntax: ```typ $vect(⟨content⟩)$```, status: [写法不同])[
    向量命令。当只有一个字符的时候默认加粗斜体，两个及两个以上字符则加箭头。Typst 的 `vec` 是列向量，所以本模板的向量命令叫 `vect`；只要箭头时也可以直接用 Typst 的 `arrow`。
]

#compare(title: [`\vec` 示例], ```latex
$\vec{a} \quad \vec{AB}$
```, ```typ
$vect(a) quad vect(A B)$
```)

=== 中国化数学符号

LaTeX 版用 TikZ 重新绘制了部分符号，并重定义了同名命令（加 `*` 表示不重定义）。Typst 版把这些符号放在模块 `symbols` 中：`#import symbols: *` 之后，数学公式中的同名符号变成教材写法；不导入时就是 Typst 的标准符号，相当于 LaTeX 版的 `*` 形式。也可以不导入，直接写 `symbols.parallel`。

#entry("\\varnothing", "varnothing", latex-syntax: ```latex $\varnothing$```, typst-syntax: ```typ $varnothing$  // 导入 symbols 后```)[
    空集符号。LaTeX 版从 Asana Math 单独取用这个字形；Typst 版使用数学字体中的 ∅（U+2205）。标准符号为 `emptyset`。
]

#entry("\\parallelogram", "parallelogram", latex-syntax: ```latex $\parallelogram$```, typst-syntax: ```typ $parallelogram$```)[
    平行四边形 ▱。
]

#entry(("\\parallel", "\\nparallel"), ("parallel", "nparallel"), latex-syntax: ```latex $\parallel \, \nparallel$```, typst-syntax: ```typ $parallel thin nparallel$```)[
    平行（⫽）和不平行。标准的竖直平行符号是 `sym.parallel`（∥）。
]

#entry("\\paralleleq", "paralleleq", latex-syntax: ```latex $\paralleleq$```, typst-syntax: ```typ $paralleleq$```)[
    平行且相等。由 3.5.3 节的 `symbols/paralleleq-type` 控制倾斜和垂直两个不同类型。
]

#entry(("\\subset", "\\nsubset", "\\subseteq", "\\nsubseteq", "\\subset*", "\\nsubset*", "\\subseteq*", "\\nsubseteq*"), ("subset", "subset.not", "subset.eq", "subset.eq.not"),
    latex-syntax: ```latex $\subset \nsubset \subseteq \nsubseteq$```, typst-syntax: ```typ $subset subset.not subset.eq subset.eq.not$```, status: [写法不同])[
    包含于（无横线、有横线）及其否定。LaTeX 版用 TikZ 重画了这些符号；Typst 版使用数学字体中的标准字形，已经是教材的写法。
]

#entry(("\\subsetneqq", "\\nsubsetneqq", "\\supsetneqq", "\\nsupsetneqq", "\\subsetneqq*", "\\supsetneqq*"), ("subsetneqq", "nsubsetneqq", "supsetneqq", "nsupsetneqq"),
    latex-syntax: ```latex $\subsetneqq \nsubsetneqq$```, typst-syntax: ```typ $subsetneqq nsubsetneqq$```)[
    真子集（⫋）、反向真子集（⫌）及其否定，在 `symbols` 模块中。
]

#entry(("\\supset", "\\nsupset", "\\supseteq", "\\nsupseteq", "\\supset*", "\\nsupset*", "\\supseteq*", "\\nsupseteq*"), ("supset", "supset.not", "supset.eq", "supset.eq.not"),
    latex-syntax: ```latex $\supset \supseteq$```, typst-syntax: ```typ $supset supset.eq$```, status: [写法不同])[
    反向包含于及其否定，使用 Typst 的标准符号。
]

#entry(("\\cap", "\\cup", "\\cap*", "\\cup*"), ("inter", "union"), latex-syntax: ```latex $A \cap B$, $A \cup B$```, typst-syntax: ```typ $A inter B$, $A union B$```, status: [写法不同])[
    交集与并集。Typst 中的名称是 `inter` 和 `union`。
]

#entry(("\\sim", "\\nsim", "\\sim*"), ("sim", "nsim"), latex-syntax: ```latex $\sim \nsim$```, typst-syntax: ```typ $sim nsim$  // 导入 symbols 后```)[
    相似（∽）与不相似。导入 `symbols` 后 `sim` 为教材中的相似符号；概率中的“服从”用 `~` 或 `tilde.op`。
]

#entry(("\\cong", "\\ncong", "\\cong*"), ("cong", "ncong"), latex-syntax: ```latex $\cong \ncong$```, typst-syntax: ```typ $cong ncong$  // 导入 symbols 后```)[
    全等（≌）与不全等。
]

#compare(title: [中国化数学符号], ```latex
$\varnothing \quad \parallelogram ABCD \quad AB \parallel CD \quad AB \nparallel CD \quad AB \paralleleq CD$

$\triangle ABC \sim \triangle DEF \quad \triangle ABC \cong \triangle DEF \quad A \subsetneqq B$
```, ```typ
#import symbols: *
$varnothing quad parallelogram A B C D quad A B parallel C D quad A B nparallel C D quad A B paralleleq C D$

$triangle A B C sim triangle D E F quad triangle A B C cong triangle D E F quad A subsetneqq B$
```)

=== 抬头

#entry("\\information", "information", latex-syntax: ```latex \information[⟨分隔符⟩]{⟨项1⟩, ⟨项2⟩}```, typst-syntax: ```typ #information(⟨项1⟩, ⟨项2⟩, separator: h(1em))```)[
    水平的学生信息输入命令。LaTeX 版用逗号分隔各项，Typst 版每项是一个参数；分隔符默认为 `h(1em)`（LaTeX 版为 `\quad`）。
]

#compare(```latex
\information{
  姓名\underline{\hspace{6em}},
  座位号\underline{\hspace{15em}}
}
```, ```typ
#information(
  [姓名#box(width: 6em, stroke: (bottom: .5pt))],
  [座位号#box(width: 15em, stroke: (bottom: .5pt))],
)
```)

#entry("\\warning", "warning", latex-syntax: ```latex \warning[⟨格式⟩]{⟨警告⟩}```, typst-syntax: ```typ #warning(format: ⟨格式⟩)[⟨警告⟩]```)[
    警告命令。居中、黑体。格式默认为 `(family: "sans", weight: "bold", size: 12pt)`。
]

#compare(```latex
\warning{（在此卷上答题无效）}
```, ```typ
#warning[（在此卷上答题无效）]
```)

#entry("\\secret", "secret", latex-syntax: ```latex \secret[⟨格式⟩]```, typst-syntax: ```typ #secret(format: ⟨格式⟩, body: ⟨文字⟩)```)[
    “绝密 ★ 启用前”。格式默认为加粗；`body` 可以换成其他文字。
]

#compare(```latex
\secret
```, ```typ
#secret()
```)

#entry("notice 环境", "notice", latex-syntax: ```latex
\begin{notice}[⟨键值⟩][⟨enumerate 选项⟩]
  \item ...
  \item ...
\end{notice}
```, typst-syntax: ```typ
#notice(⟨键值⟩)[...][...]
```)[
    注意事项。LaTeX 版是 `enumerate` 的包装，每个 `\item` 一项；Typst 版每个方括号一项。键值见下。
]

#entry("notice/label", "notice: (label: ..)", latex-syntax: ```latex label = ⟨label⟩```, typst-syntax: ```typ label: [注意事项：]```)[
    标签内容。默认为 `注意事项：`。
]

#entry("notice/label-format", "notice: (label-format: ..)", latex-syntax: ```latex label-format = \sffamily\bfseries```, typst-syntax: ```typ label-format: (family: "sans", weight: "bold")```, status: [写法不同])[
    标签格式。LaTeX 版的格式是一串字体命令；Typst 版的格式是 `text` 参数组成的字典，`family` 取 `"serif"`、`"sans"`、`"kai"`、`"fangsong"`，也可以是函数 `body => ...`。本手册中所有 `*-format` 键都是这样。
]

#entry(("notice/top-sep", "notice/bottom-sep"), ("notice: (top-sep: ..)", "notice: (bottom-sep: ..)"), latex-syntax: ```latex top-sep = .25em plus .25em minus .1em```, typst-syntax: ```typ top-sep: 0.4em```)[
    上下方的间距。Typst 的长度没有 `plus`/`minus` 弹性部分。
]

#entry("\\title", "exam(title: ..)", latex-syntax: ```latex \title{⟨标题⟩}```, typst-syntax: ```typ #show: exam.with(title: [⟨标题⟩])```)[
    标题，由 `make-title` 输出。也可以 `#make-title(title: [...])` 直接给出。格式见 3.5.8 节。
]

#entry("\\subject", "exam(subject: .., subject-width: ..)", latex-syntax: ```latex \subject[⟨宽度⟩]{⟨科目⟩}```, typst-syntax: ```typ #show: exam.with(subject: [⟨科目⟩], subject-width: ⟨宽度⟩)```)[
    科目，可以为空或不写。科目内容在 `subject-width` 宽度内均匀分散，默认为科目在正文字号下宽度的 2 倍（与 exam-zh 的实际效果相同）。
]

#entry("\\maketitle", "make-title", latex-syntax: ```latex \maketitle```, typst-syntax: ```typ #make-title()```)[
    生成标题和科目。
]

#compare(title: [抬头], ```latex
\title{2021 年普通高等学校招生全国统一考试（乙卷）}
\subject{数学（理科）}
\maketitle
```, ```typ
#make-title(title: [2021 年普通高等学校招生全国统一考试（乙卷）], subject: [数学（理科）])
```)

=== 题干

#entry("question 环境", "question", latex-syntax: ```latex
\begin{question}[⟨键值列表⟩]
  ⟨题干⟩
\end{question}
```, typst-syntax: ```typ
#question(⟨键值⟩)[
  ⟨题干⟩
]
```)[
    选择题和填空题题干。键值见 3.5.9 节；常用的 `points`、`index`、`show-answer` 直接写在括号里。
]

#entry("problem 环境", "problem", latex-syntax: ```latex
\begin{problem}[⟨键值列表⟩]
  ⟨题干⟩
\end{problem}
```, typst-syntax: ```typ
#problem(⟨键值⟩)[
  ⟨题干⟩
]
```)[
    解答题题干。`question` 和 `problem` 的区别：显示分值时，`question` 的题干紧接在分数后，`problem` 的题干在分数后新起一段。
]

#compare(title: [`question` 和 `problem` 环境的区别], setup: (question: (show-points: true)), ```latex
% \examsetup{question/show-points = true}
\begin{question}[points = 1]
  题干测试
\end{question}
\begin{problem}[points = 2]
  题干测试
\end{problem}
```, ```typ
#exam-setup(question: (show-points: true))
#question(points: 1)[题干测试]
#problem(points: 2)[题干测试]
```)

#entry("\\paren", "paren", latex-syntax: ```latex \paren[⟨答案⟩]   \paren*```, typst-syntax: ```typ #paren[⟨答案⟩]   #paren(wide: true)```)[
    括号。答案受 `show-answer` 控制显示。括号自动到行末尾；若单行内容较长，会自动到下一行末尾。`\paren*` 的较宽括号写成 `wide: true`。
]

#compare(title: [`\paren` 的换行效果], setup: (paren: (show-paren: true)), ```latex
\begin{question}
  短题干选项 \paren
\end{question}
\begin{question}
  长长长长长长长长长长长长长长长长长长长长长长长长长长长题干选项 \paren
\end{question}
```, ```typ
#question[短题干选项 #paren()]
#question[长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长题干选项 #paren()]
```)

#entry("\\AddQuestionCounter", "question: (label: n => ..)", latex-syntax: ```latex \AddQuestionCounter{⟨LaTeX command⟩}{⟨internal command⟩}```, typst-syntax: ```typ label: n => [第 #n 题]```, status: [Typst 中不需要])[
    LaTeX 版要先注册计数器样式，才能在 `label` 中使用。Typst 版的 `label` 直接接受编号格式（`"1."`、`"(1)"`、`"①"`、`"一、"`）或函数，不需要注册。
]

#compare(```latex
\AddQuestionCounter{\circlednumber}{\__examzh_font_circled_number:n}
\examsetup{question/label = \circlednumber*}
\begin{question} 带圈数字题号 \end{question}
```, ```typ
#exam-setup(question: (label: "①"))
#question[带圈数字题号]
#exam-setup(question: (label: n => [第 #n 题]))
#question[用函数定义的题号]
```)

=== 选择题

#entry("choices 环境", "choices", latex-syntax: ```latex
\begin{choices}[⟨键值列表⟩]
  \item ⟨选项1⟩
  \item ⟨选项2⟩
\end{choices}
```, typst-syntax: ```typ
#choices(⟨键值⟩)[⟨选项1⟩][⟨选项2⟩]
```)[
    选择题选项排版。每个方括号是一个选项。键值见 3.5.10 节。
]

#entry("\\setchoices", ("set-choices", "exam-setup(choices: ..)"), latex-syntax: ```latex \setchoices{⟨键值列表⟩}```, typst-syntax: ```typ #set-choices(⟨键值⟩)```)[
    `choices` 的参数设置，与 `exam-setup(choices: (...))` 效果相同。
]

#entry("\\AddChoicesCounter", "choices: (label: n => ..)", latex-syntax: ```latex \AddChoicesCounter{⟨LaTeX command⟩}{⟨internal command⟩}```, typst-syntax: ```typ label: n => ...```, status: [Typst 中不需要])[
    自定义选项标签的计数器样式。Typst 版的 `label` 直接接受函数。
]

#compare(title: [`\AddChoicesCounter` 使用示例], ```latex
\ExplSyntaxOn
\cs_new:Npn \examzhtest_counter:n #1
  {
    \int_set:Nn \l_tmpa_int { \int_eval:n { #1 + 1 } }
    \int_use:N \l_tmpa_int
  }
\AddChoicesCounter \test \examzhtest_counter:n
\ExplSyntaxOff
\begin{choices}[label = \test*]
  \item 1
  \item 2
\end{choices}
```, ```typ
#choices(label: n => str(n + 1))[1][2]
```)

#entry(("\\circlednumber", "\\tikzcirclednumber"), ("numbering(\"①\", n)", "circled-number"), latex-syntax: ```latex \circlednumber{⟨数字⟩}  \tikzcirclednumber{⟨数字⟩}```, typst-syntax: ```typ #numbering("①", ⟨数字⟩)  #circled-number(⟨数字⟩)```)[
    带圈数字。`"①"` 编号格式使用字体中的字形，只支持 1–50；`circled-number` 绘制圆圈，没有范围限制，`filled: true` 为黑底白字。在 `label` 中写 `"①"` 时，超过 50 自动改用 `circled-number`。LaTeX 版中的计数器名（如 `page`）在 Typst 中写成 `counter(page).get().first()`。
]

#compare(title: [`\circlednumber` 的使用示例], ```latex
\circlednumber{1} \circlednumber{2}
\tikzcirclednumber{1} \tikzcirclednumber{2}
\circlednumber{page} \circlednumber{section}
```, ```typ
#numbering("①", 1) #numbering("①", 2)
#circled-number(1) #circled-number(2)
#context numbering("①", counter(page).get().first())
#circled-number(51) #circled-number(8, filled: true)
```)

=== 填空题

#entry(("\\fillin", "\\fillin*"), ("fillin", "fillin(breakable: true)"), latex-syntax: ```latex \fillin[⟨键值⟩][⟨答案⟩]   \fillin*[⟨键值⟩][⟨答案⟩]```, typst-syntax: ```typ #fillin(⟨键值⟩)[⟨答案⟩]   #fillin(breakable: true)[⟨答案⟩]```)[
    填空命令，可生成下划线或括号等形式。答案受 `question/show-answer` 控制显示或隐藏；键值见 3.5.11 节。

    *换行行为：*显示答案时，答案宽度超过一行（或答案是纯文字）时按文字换行；`breakable: true` 无论长短都可换行。不显示答案时生成固定宽度的占位；`no-answer-type: "none"` 且宽度超过行宽时自动换行。

    LaTeX 版中 `\fillin[⟨1⟩]` 表示答案，只改类型要写 `\fillin[type=paren][]`；答案含不配对的方括号时要写成 `\fillin[{$(-\infty, 1]$}]`。Typst 版的键值写在圆括号里、答案写在方括号里，没有这些限制：`#fillin(type: "paren")`、`#fillin[$(-infinity, 1]$]`。
]

#compare(title: [`\fillin` 和 `\fillin*` 的换行行为对比], ```latex
\examsetup{fillin/no-answer-type=none}
% 情况 1：显示答案时
\examsetup{question/show-answer = true}

短答案：\fillin[42]

长答案（自动换行）：\fillin[$\frac{1}{2}$ 这是一个很长的答案内容，这是一个很长的答案内容，这是一个很长的答案内容，这是一个很长的答案内容。]

强制可换行：\fillin*[短答案]

\vspace{1em}

% 情况 2：不显示答案时
\examsetup{question/show-answer = false}

默认固定长度：\fillin[width=5em][答案]

超宽自动换行（v0.2.6+）：
测试 \fillin[width=1.2\linewidth][长答案]

使用 \verb|\fillin*| 换行：
测试 \fillin*[width=1.2\linewidth][长答案内容]
```, ```typ
#exam-setup(fillin: (no-answer-type: "none"))
// 情况 1：显示答案时
#exam-setup(question: (show-answer: true))

短答案：#fillin[42]

长答案（自动换行）：#fillin(breakable: true)[$1/2$ 这是一个很长的答案内容，这是一个很长的答案内容，这是一个很长的答案内容，这是一个很长的答案内容。]

强制可换行：#fillin(breakable: true)[短答案]

#v(1em)

// 情况 2：不显示答案时
#exam-setup(question: (show-answer: false))

默认固定长度：#fillin(width: 5em)[答案]

超宽自动换行：
测试 #fillin(width: 120%)[长答案]

使用 `breakable` 换行：
测试 #fillin(breakable: true, width: 120%)[长答案内容]
```)

#entry("\\AddFillinCounter", "fillin: (no-answer-counter-label: n => ..)", latex-syntax: ```latex \AddFillinCounter{⟨LaTeX command⟩}{⟨internal command⟩}```, typst-syntax: ```typ no-answer-counter-label: "①"```, status: [Typst 中不需要])[
    `no-answer-type = counter` 时计数器的样式。Typst 版直接写编号格式或函数。
]

=== 判断题

作为 `paren` 和 `fillin` 的应用可以实现判断题效果。

#compare(title: [`\paren` 和 `\fillin` 命令的应用：判断题], ```latex
\examsetup{
  question/show-answer = true,
  fillin/type = paren,
  paren/show-paren = true
}
\newcommand{\true}{$\checkmark$}
\newcommand{\false}{$\times$}

\begin{question}
  $1 + 1 = 2$ \paren[对]
\end{question}

\begin{question}
  $1 + 1 = 3$ \fillin[错]
\end{question}

\begin{question}
  $1 + 1 = 2$ \paren[\true]
\end{question}

\begin{question}
  $1 + 1 = 3$ \fillin[\false]
\end{question}
```, ```typ
#exam-setup(
  question: (show-answer: true),
  fillin: (type: "paren"),
  paren: (show-paren: true),
)
#let true-mark = $checkmark$
#let false-mark = $times$

#question[$1 + 1 = 2$ #paren[对]]

#question[$1 + 1 = 3$ #fillin[错]]

#question[$1 + 1 = 2$ #paren[#true-mark]]

#question[$1 + 1 = 3$ #fillin[#false-mark]]
```)

由于使用“对错”还是“叉勾”因人而异，模板没有固定写法，但可以自定义（以 `fillin` 为例）：

#compare(title: [填空题的自定义示例], ```latex
\examsetup{
  question/show-answer = true,
  fillin/type = paren,
  paren/show-paren = true
}

\newcommand{\true}{\fillin[$\surd$]}
\newcommand{\false}{\fillin[$\times$]}

\begin{question}
  $1 + 1 = 2$ \true
\end{question}

\begin{question}
  $1 + 1 = 3$ \false
\end{question}
```, ```typ
#exam-setup(
  question: (show-answer: true),
  fillin: (type: "paren"),
  paren: (show-paren: true),
)

#let right = fillin[$sqrt("")$]
#let wrong = fillin[$times$]

#question[$1 + 1 = 2$ #right]

#question[$1 + 1 = 3$ #wrong]
```)

=== 解答题

#entry("solution 环境", "solution", latex-syntax: ```latex
\begin{solution}[⟨键值列表⟩]
  ...
\end{solution}
```, typst-syntax: ```typ
#solution(⟨键值⟩)[
  ...
]
```)[
    解答题解答。键值见 3.5.12 节。下面和 `solution` 有关的示例都默认设置了 `solution: (show-solution: "show-stay")`。
]

#compare(title: [`solution` 环境示例], setup: (solution: (show-solution: "show-stay")), ```latex
\begin{solution}
  测试
\end{solution}
```, ```typ
#solution[测试]
```)

#entry("\\score", "score", latex-syntax: ```latex \score{⟨分数⟩}```, typst-syntax: ```typ #score(⟨分数⟩)```)[
    解答中得分点的得分命令。LaTeX 版在行间公式中使用时需要编译两次才能产生虚线；Typst 版一次即可，公式保持居中。
]

#compare(title: [`\score` 命令示例], setup: (solution: (show-solution: "show-stay")), ```latex
\begin{solution}
  函数的定义域为 $(0, +\infty)$,
  又 \[f^{\prime}(x) = 1 - \ln x-1 = -\ln x, \score{2}\]
  当 $x \in(0, 1)$ 时, $f^{\prime}(x) > 0$, 当 $x \in(1, +\infty)$ 时, $f^{\prime}(x) < 0$.

  故 $f(x)$ 的递增区间为 $(0,1)$, \score{1} 递减区间为 $(1, +\infty)$. \score{1}
\end{solution}
```, ```typ
#solution[
  函数的定义域为 $(0, +infinity)$，
  又 $ f'(x) = 1 - ln x - 1 = -ln x, #score(2) $
  当 $x in (0, 1)$ 时，$f'(x) > 0$，当 $x in (1, +infinity)$ 时，$f'(x) < 0$。

  故 $f(x)$ 的递增区间为 $(0, 1)$，#score(1) 递减区间为 $(1, +infinity)$。#score(1)
]
```)

=== 几个列表环境

#entry("step 环境", "step", latex-syntax: ```latex
\begin{step}
  \item ...
\end{step}
```, typst-syntax: ```typ #step[...][...]```)[
    “步骤”列表。可以嵌套一层，编号为“步骤1.1”。
]

#entry("method 环境", "method", latex-syntax: ```latex
\begin{method}
  \item ...
\end{method}
```, typst-syntax: ```typ #method[...][...]```)[
    “方法”列表，编号为“方法一”“方法二”。
]

#entry("case 环境", "case", latex-syntax: ```latex
\begin{case}
  \item ...
\end{case}
```, typst-syntax: ```typ #case[...][...]```)[
    “情形”列表。可以嵌套一层。参数见 3.5.13 节。
]

#compare(```latex
\begin{step}
  \item 第一步
  \item 第二步
    \begin{step}
      \item 嵌套
    \end{step}
\end{step}
\begin{method}
  \item 配方法
  \item 公式法
\end{method}
\begin{case}
  \item $a > 0$ 时
  \item $a \leq 0$ 时
\end{case}
```, ```typ
#step[第一步][第二步 #step[嵌套]]
#method[配方法][公式法]
#case[$a > 0$ 时][$a <= 0$ 时]
```)

=== 草稿纸

#entry("\\draftpaper", "draftpaper", latex-syntax: ```latex \draftpaper[⟨参数列表⟩]```, typst-syntax: ```typ #draftpaper(⟨参数⟩)```)[
    草稿纸命令，使用一次产生一页草稿纸，不计入页码。参数见 3.5.14 节。
]

#shot("draftpaper", width: 45%, caption: [`draftpaper()` 产生的草稿纸（带密封线）])

=== 方格

在密封线或 `information` 输出的个人信息中，可能需要输出方格（如 2021 年数学高考原卷）。

#entry("\\examsquare", "examsquare", latex-syntax: ```latex \examsquare[⟨参数列表⟩]{⟨方格个数⟩}```, typst-syntax: ```typ #examsquare(⟨方格个数⟩, ⟨参数⟩)```)[
    方格命令。参数见 3.5.6 节。
]

#compare(```latex
准考证号 \examsquare{9}
```, ```typ
准考证号 #examsquare(9)
```)

=== 评分框

#entry(("\\scoringbox", "\\scoringbox*"), ("scoringbox()", "scoringbox(simple: true)"), latex-syntax: ```latex \scoringbox   \scoringbox*```, typst-syntax: ```typ #scoringbox()   #scoringbox(simple: true)```)[
    评分框。可单独使用；与大题标题结合见 3.5.15 节。
]

#compare(title: [评分框示例], ```latex
\scoringbox \quad \scoringbox*
```, ```typ
#scoringbox() #h(1em) #scoringbox(simple: true)
```)

=== 试卷合集

`exam-zh` 不仅可以排版单份试卷，也可以排版多份试卷构成的合集。

#entry("\\tableofcontents", "exam-outline", latex-syntax: ```latex \tableofcontents```, typst-syntax: ```typ #exam-outline()```)[
    目录。目录单独成页、不编页码，之后的试卷从第 1 页开始；A3 拼版时目录中的页码按 A4 计算。
]

#entry("\\chapter", "chapter", latex-syntax: ```latex \chapter{⟨标题⟩}```, typst-syntax: ```typ #chapter[⟨标题⟩]```)[
    一份试卷的标题，横跨所有栏，录入目录。新的 `chapter` 下题号和大题编号会重置。用 `page/show-chapter` 控制显示与否（3.5.4 节）。其余命令见 3.4.4 节。
]

#code-only(```typ
#exam-outline()

#for paper in ("papers/2021-a.typ", "papers/2021-b.typ") {
  chapter[2021 年普通高等学校招生全国统一考试]
  make-title()
  include paper
}
```)

#grid(columns: (1fr, 1fr), column-gutter: 1em,
    shot("outline", caption: [`exam-outline()`]),
    shot("sealline-a3", caption: [`chapter` 的标题横跨两栏]))

=== 选择标记题型

#entry("select 环境", "select", latex-syntax: ```latex
\begin{select}[⟨键值列表⟩]
  \sitem ⟨未标记的选项⟩
  \sitem* ⟨标记的选项⟩
\end{select}
```, typst-syntax: ```typ #select(answer: 2, ⟨键值⟩)[⟨选项⟩][⟨选项⟩]```)[
    选择标记。`\sitem*` 标记的选项写成 `answer: 序号`（多个时写数组 `(1, 3)`）。键值见 3.5.16 节。拼音直接写带声调的字母即可（LaTeX 版用 xpinyin 的 `\pinyin{zhe2}`）。
]

#compare(title: [`select` 环境的基本使用], ```latex
折
\begin{select}
  \sitem \pinyin{zhe2}
  \sitem* \pinyin{she2}
\end{select}
本

\begin{select}
  \sitem* 疏
  \sitem 蔬
  \sitem 输
\end{select}
远
```, ```typ
折#select(answer: 2)[zhé][shé]本

#select(answer: 1)[疏][蔬][输]远
```)

=== 连线题型

#entry(("lineto 环境", "\\linelistset", "\\lineconnect"), ("lineto", "lineto 的位置参数", "connect"), latex-syntax: ```latex
\begin{lineto}[⟨TikZ 选项⟩]
  \linelistset[⟨键值⟩]{⟨list⟩}
  \lineconnect[⟨TikZ 选项⟩]{i-1, ii-3}
\end{lineto}
```, typst-syntax: ```typ
#lineto(
  (⟨项⟩, ⟨项⟩),          // 每个位置参数一列
  (⟨项⟩, ⟨项⟩),
  connect: ((1, 3),),   // 每条线依次经过的各列序号
)
```, status: [写法不同])[
    连线题。LaTeX 版用 `\linelistset` 逐列设置、按名称 `i-1`、`ii-3` 连线；Typst 版每列是一个数组，`connect` 中每一项给出一条线在各列的序号，`(1, 3, 2)` 依次连接第一列第 1 项、第二列第 3 项、第三列第 2 项。连线是答案：学生版默认不画，教师版或 `show-lines: true` 时显示。示例见 3.5.18 节。
]

=== 语文-材料文章

#entry("material 环境", "material", latex-syntax: ```latex
\begin{material}[⟨键值列表⟩]
  ⟨content⟩
\end{material}
```, typst-syntax: ```typ #material(⟨键值⟩)[⟨content⟩]```)[
    语文的材料/文章。键值见 3.5.19 节。
]

#compare(title: [`material` 环境示例], ```latex
\begin{material}[title = \LaTeX{} 入门, author = 夏大鱼羊, format = {\sffamily \zihao{-4}},source={（摘自《夏大鱼羊自传》） \\ 2022年}]
  劳仑衣普桑，认至将指点效则机，最你更枝。想板整月正进好志次回总般，段然取向使张规军证回，世市总李率英茄持伴。用阶千样响领交出，器程办管据家元写，名其直金团。
\end{material}
```, ```typ
#material(title: [Typst 入门], author: [夏大鱼羊], format: (family: "sans", size: zihao(-4)), source: [（摘自《夏大鱼羊自传》） \ 2022年])[
  劳仑衣普桑，认至将指点效则机，最你更枝。想板整月正进好志次回总般，段然取向使张规军证回，世市总李率英茄持伴。用阶千样响领交出，器程办管据家元写，名其直金团。
]
```)

=== 语文-古诗

#entry("poem 环境", "poem", latex-syntax: ```latex
\begin{poem}[⟨键值列表⟩]
  ⟨content⟩
\end{poem}
```, typst-syntax: ```typ #poem(⟨键值⟩)[⟨content⟩]```)[
    古诗。整体居中，每行用 `\` 换行（LaTeX 版用 `\\`）。键值见 3.5.19 节。
]

#entry("\\zhu", "zhu", latex-syntax: ```latex \zhu{⟨注释⟩}```, typst-syntax: ```typ #zhu[⟨注释⟩]```)[
    古诗的注释，只能在 `poem` 中使用。注释用带圈数字标在原文中，排在诗后。
]

#compare(title: [`poem` 环境示例], setup: (poem: (format: (family: "kai"))), ```latex
\examsetup{
  poem/format = \itshape
}
\begin{poem}[author = 杨巨源, title = {寄江州白司马\zhu{江州白司马：即白居易。}}]
  江州司马平安否？ 惠远东林住得无 \zhu{惠远：东晋高僧，居庐山东林寺。}？ \\
  湓浦曾闻似衣带，庐峰见说胜香炉。\\
  题诗岁晏离鸿断，望阙天遥病鹤孤。\\
  莫谩拘牵雨花社\zhu{莫谩：不要。雨花社：指佛教讲经的集会。}，青云依旧是前途。
\end{poem}
```, ```typ
#exam-setup(poem: (format: (family: "kai")))
#poem(author: [杨巨源], title: [寄江州白司马#zhu[江州白司马：即白居易。]])[
  江州司马平安否？惠远东林住得无#zhu[惠远：东晋高僧，居庐山东林寺。]？\
  湓浦曾闻似衣带，庐峰见说胜香炉。\
  题诗岁晏离鸿断，望阙天遥病鹤孤。\
  莫谩拘牵雨花社#zhu[莫谩：不要。雨花社：指佛教讲经的集会。]，青云依旧是前途。
]
```)

=== 语文-作文格

#entry("\\compositiongrid", "composition-grid", latex-syntax: ```latex \compositiongrid[⟨键值列表⟩]{⟨目标字数⟩}```, typst-syntax: ```typ #composition-grid(⟨目标字数⟩, ⟨键值⟩)```)[
    中文作文答题格。必选参数表示希望提供的最少作文格数，实际格数会按每行格数向上补齐成完整行。LaTeX 版底层使用 hanzibox 的 `\writegrid`；Typst 版直接绘制。网格默认先利用当前页的剩余空间，再自动分页续排。键值见 3.5.17 节。
]

#compare(title: [`\compositiongrid` 命令示例], ```latex
\compositiongrid
  [columns = 12, row-sep-ratio = 2, count-marks = {24}]
  {36}
```, ```typ
#composition-grid(36, columns: 12, row-sep-ratio: 2, count-marks: (24,))
```)

=== 英语-作文框

#entry("writingbox 环境", "writingbox", latex-syntax: ```latex
\begin{writingbox}[⟨tcolorbox 选项⟩]
  ⟨content⟩
\end{writingbox}
```, typst-syntax: ```typ #writingbox(title: .., ⟨键值⟩)[⟨content⟩]```, status: [写法不同])[
    英语作文框。LaTeX 版的选项直接传给 tcolorbox；Typst 版支持 `title` 和 `writing` 模块中的 `box-stroke`、`inset`、`title-format`。
]

#compare(title: [`writingbox` 环境示例], ```latex
\begin{writingbox}[title = {Youth and me}]
  \vspace*{4em}
\end{writingbox}
```, ```typ
#writingbox(title: [Youth and me])[
  #v(4em)
]
```)

#compare(title: [`writingbox` 环境示例], ```latex
\begin{writingbox}
  As the twins looked around them in disappointment, their father appeared.

  \vspace*{4em}

  The twins carried the breakfast upstairs and woke their mother up.

  \vspace*{4em}
\end{writingbox}
```, ```typ
#writingbox[
  #align(center)[As the twins looked around them in disappointment, their father appeared.]

  #v(4em)

  #align(center)[The twins carried the breakfast upstairs and woke their mother up.]

  #v(4em)
]
```)

#entry("\\writinglines", "writinglines", latex-syntax: ```latex \writinglines[⟨键值⟩]{⟨行数⟩}```, typst-syntax: ```typ #writinglines(⟨行数⟩, ⟨键值⟩)```)[
    英语作文答题横线框，横线两端与边框对齐。键值有 `line-width`、`line-height`、`line-thickness`、`line-color`；边框粗细为 `lines-stroke`（LaTeX 版的 `box-options` 传给 tcolorbox）。
]

#compare(title: [`\writinglines` 命令示例], ```latex
\writinglines
  [line-height = 0.75cm, line-thickness = 0.4pt]
  {8}
```, ```typ
#writinglines(8, line-height: 0.75cm, line-thickness: 0.4pt)
```)

#entry("\\writingline", "writingline", latex-syntax: ```latex \writingline```, typst-syntax: ```typ #writingline()```)[
    单行横线，可插入已有的作文框中。
]

#compare(```latex
\begin{writingbox}[left = 0pt, right = 0pt, boxsep = 0pt]
  \writingline
  \writingline
  \writingline
\end{writingbox}
```, ```typ
#writingbox(inset: 0pt)[
  #writingline()
  #writingline()
  #writingline()
]
```)

=== 师生两版

#entry("\\ExamPrintAnswerSet", "exam(teacher: ..)", latex-syntax: ```latex \ExamPrintAnswerSet[⟨cmd list⟩]{⟨key-val list⟩}```, typst-syntax: ```typ #show: exam.with(teacher: teacher-defaults + (..))```, status: [写法不同])[
    设置第二个版本（教师版）的设置。`⟨key-val list⟩` 对应 `teacher` 字典中的选项，在教师版中合并到其他设置之后；`⟨cmd list⟩` 中重定义 `\title`、`\subject` 的命令对应 `teacher` 中的 `title`、`subject`；隐藏 `\warning`、`notice` 等只面向考生的内容，用 `student-only[...]` 包裹即可。

    `teacher` 的默认值 `teacher-defaults` 打开括号与填空答案、标出正确选项、原位显示解答、显示选择标记和连线。
]

#compare(```latex
\ExamPrintAnswerSet[
  \geometry{showframe}
]{
  page/size=a3paper,
  solution/show-solution=show-stay,
  question/show-answer=true
}
```, ```typ
#show: exam.with(
  teacher: (
    solution: (show-solution: "show-stay"),
    question: (show-answer: true),
  ),
)
```, show-result: false)

教师版的纸张与学生版相同（Typst 中纸张在编译开始时确定）；需要不同纸张时，用 `page: (size: if sys.inputs.at("exam-mode", default: "") == "teacher" { "a3" } else { "a4" })` 之类的写法。

#compare(```latex
\title{2026 年春季期中考试}
\subject{数学}

\ExamPrintAnswerSet[
  \title{2026 年春季期中考试参考答案},
  \subject{},
  \RenewDocumentCommand \warning { O{} m } {},
  \RenewDocumentEnvironment { notice } { O{} O{} +b } {} {}
]{
  solution/show-solution=show-stay,
  question/show-answer=true
}
```, ```typ
#show: exam.with(
  title: [2026 年春季期中考试],
  subject: [数学],
  teacher: teacher-defaults + (
    title: [2026 年春季期中考试参考答案],
    subject: none,
  ),
)

#student-only[
  #warning[（在此卷上答题无效）]
  #notice[...][...]
]
```, show-result: false)

#entry("\\ExamPrintAnswer", "—", status: [Typst 中不需要])[
    LaTeX 版用它让 `\ExamPrintAnswerSet` 的设置生效；Typst 版在教师版中自动合并 `teacher` 的设置。
]

*如何生成师生两版：*LaTeX 版用 `xelatex -shell-escape` 编译，在一次编译中再调用 latexmk 生成第二个 PDF；Typst 版编译两次，分别得到两个版本：

#code-only(```sh
typst compile exam.typ                                            # 学生版
typst compile --input exam-mode=teacher exam.typ exam-teacher.pdf # 教师版
```)

#grid(columns: (1fr, 1fr), column-gutter: 1em,
    shot("first-student", caption: [学生版]), shot("first-teacher", caption: [教师版]))

=== 图文排版

试卷中的图文排版主要有三种：多张图片并排；文字和图片左右或上下排版；文字绕排。前两种对应 `multifigures` 和 `textfigure`；文字绕排见本节最后。

#entry("multifigures 环境", "multifigures", latex-syntax: ```latex
\begin{multifigures}[⟨键值⟩]
  \item[⟨标签⟩] ⟨内容⟩
\end{multifigures}
```, typst-syntax: ```typ #multifigures(([⟨标签⟩], ⟨内容⟩), .., ⟨键值⟩)```)[
    多张图片排版。每张图片写成 `(标签, 内容)`，没有标签时直接写内容。键值见 3.5.20 节。
]

#compare(title: [`multifigures` 环境示例1], ```latex
\begin{multifigures}
  \item[题 9 图：勾股数] \includegraphics[width=3cm]{example-image.png}
  \item[题 11 图：圆锥曲线] \includegraphics[width=3cm]{example-image.png}
\end{multifigures}
```, ```typ
#multifigures(
  ([题 9 图：勾股数], image("../examples/assets/example-image.svg", width: 3cm)),
  ([题 11 图：圆锥曲线], image("../examples/assets/example-image.svg", width: 3cm)),
)
```)

#compare(title: [`multifigures` 环境示例2], ```latex
\begin{multifigures}[columns=2]
  \item[题 9 图] \includegraphics[width=3cm]{example-image.png}
  \item[题 10 图] \includegraphics[width=3cm]{example-image.png}
  \item[题 11 图] \includegraphics[width=3cm]{example-image.png}
  \item[题 12 图] \includegraphics[width=3cm]{example-image.png}
\end{multifigures}
```, ```typ
#let fig = image("../examples/assets/example-image.svg", width: 3cm)
#multifigures(columns: 2,
  ([题 9 图], fig), ([题 10 图], fig), ([题 11 图], fig), ([题 12 图], fig))
```)

#entry("\\textfigure", "textfigure", latex-syntax: ```latex \textfigure[⟨键值⟩]{⟨文本⟩}{⟨图片⟩}```, typst-syntax: ```typ #textfigure(⟨键值⟩)[⟨文本⟩][⟨图片⟩]```)[
    图文排版。键值见 3.5.20 节。
]

#compare(title: [`\textfigure` 命令示例1], ```latex
\textfigure{
  江州司马平安否？ 惠远东林住得无？ \par
  湓浦曾闻似衣带，庐峰见说胜香炉。\par
  题诗岁晏离鸿断，望阙天遥病鹤孤。\par
  莫谩拘牵雨花社，青云依旧是前途。
}{
  \includegraphics[width=3cm]{example-image.png}
}
```, ```typ
#textfigure[
  江州司马平安否？惠远东林住得无？\
  湓浦曾闻似衣带，庐峰见说胜香炉。\
  题诗岁晏离鸿断，望阙天遥病鹤孤。\
  莫谩拘牵雨花社，青云依旧是前途。
][#image("../examples/assets/example-image.svg", width: 3cm)]
```)

#compare(title: [`\textfigure` 命令示例2], ```latex
\textfigure[text-width=\columnwidth,fig-pos=bottom-flushright]{
  如图，在三棱锥 $A$-$BCD$ 中，$\text{平面} ABD \perp \text{平面} BCD$，
  $AB = AD$，$O$ 为 $BD$ 的重点。
  \begin{enumerate}
    \item 证明：$OA \perp CD$；
    \item 若 $\triangle OCD$ 是变长为 $1$ 的等边三角形，点 $E$ 在棱 $AD$ 上，
      $DE = 2 EA$，且二面角 $E$-$BC$-$D$ 的大小为 $45^{\circ}$，
      求三棱锥 $A$-$BCD$ 的体积。
  \end{enumerate}
}{
  \includegraphics[width=3cm]{example-image.png}
}
```, ```typ
#textfigure(fig-pos: "bottom-flushright")[
  如图，在三棱锥 $A$-$B C D$ 中，$"平面" A B D perp "平面" B C D$，$A B = A D$，$O$ 为 $B D$ 的中点。
  + 证明：$O A perp C D$；
  + 若 $triangle O C D$ 是边长为 $1$ 的等边三角形，点 $E$ 在棱 $A D$ 上，$D E = 2 E A$，且二面角 $E$-$B C$-$D$ 的大小为 $45 degree$，求三棱锥 $A$-$B C D$ 的体积。
][#image("../examples/assets/example-image.svg", width: 3cm)]
```)

#compare(title: [`\textfigure` 命令示例3], ```latex
\textfigure{
  \begin{question}
    双曲线 $C: \frac{x^{2}}{4}-\frac{y^{2}}{2}=1$ 的右焦点为 $F$, 为点 $P$ 在 $C$ 的一条渐近线上, $O$ 为坐标原点, 若 $|P O|=|P F|$, 则 $\triangle P F O$ 的面积为 \paren
    \begin{choices}
      \item $\frac{3 \sqrt{2}}{4}$
      \item $\frac{3 \sqrt{2}}{2}$
      \item $2 \sqrt{2}$
      \item $3 \sqrt{2}$
    \end{choices}
  \end{question}

  \begin{question}
    设 $f(x)$ 是定义域为 $\mathbf{R}$ 的偶函数, 且在 $(0,+\infty)$ 单调递减, 则
    \begin{choices}
      \item $f\left(\log _{3} \frac{1}{4}\right)>f\left(2^{-\frac{3}{2}}\right)>f\left(2^{-\frac{2}{3}}\right)$
      \item $f\left(\log _{3} \frac{1}{4}\right)>f\left(2^{-\frac{2}{3}}\right)>f\left(2^{-\frac{3}{2}}\right)$
      \item $f\left(2^{-\frac{3}{2}}\right)>f\left(2^{-\frac{2}{3}}\right)>f\left(\log _{3} \frac{1}{4}\right)$
      \item $f\left(2^{-\frac{2}{3}}\right)>f\left(2^{-\frac{3}{2}}\right)>f\left(\log _{3} \frac{1}{4}\right)$
    \end{choices}
  \end{question}
}{
  \includegraphics[width = 2cm, height = 5cm]{example-image.png} \\ （第 9 题）
}
```, ```typ
#textfigure(fig-pos: "right")[
  #question[
    双曲线 $C: x^2/4 - y^2/2 = 1$ 的右焦点为 $F$，点 $P$ 在 $C$ 的一条渐近线上，$O$ 为坐标原点，若 $|P O| = |P F|$，则 $triangle P F O$ 的面积为 #paren()
    #choices[$(3 sqrt(2))/4$][$(3 sqrt(2))/2$][$2 sqrt(2)$][$3 sqrt(2)$]
  ]

  #question[
    设 $f(x)$ 是定义域为 $bold(R)$ 的偶函数，且在 $(0, +infinity)$ 单调递减，则
    #choices[
      $f(log_3 1/4) > f(2^(-3/2)) > f(2^(-2/3))$
    ][
      $f(log_3 1/4) > f(2^(-2/3)) > f(2^(-3/2))$
    ][
      $f(2^(-3/2)) > f(2^(-2/3)) > f(log_3 1/4)$
    ][
      $f(2^(-2/3)) > f(2^(-3/2)) > f(log_3 1/4)$
    ]
  ]
][#align(center)[#image("../examples/assets/example-image.svg", width: 2cm, height: 5cm) \ （第 9 题）]]
```)

#entry("wrapstuff 环境", "—", status: [留给独立包])[
    LaTeX 版加载李清的 wrapstuff 宏包实现文字绕排。Typst 目前不支持文字绕排浮动内容，本模板也不提供绕排命令；可以使用 #link("https://typst.app/universe/package/meander")[meander]（任意形状）或 #link("https://typst.app/universe/package/wrap-it")[wrap-it]（矩形）。
]

=== 页面设置

LaTeX 版根据 A3 或 A4 有不同的页面设置，并在 `\AtEndPreamble` 中执行；用户修改页面设置时也要写在 `\AtEndPreamble` 中。Typst 版直接设置 `page`：

#compare(```latex
\AtEndPreamble{%
  \geometry{
    top = 2.5cm, bottom = 2cm, left = 2cm, right = 2cm
  }
}
```, ```typ
#show: exam.with(
  page: (margin: (top: 2.5cm, bottom: 2cm, left: 2cm, right: 2cm)),
)
```, show-result: false)

=== 数学-计算题排版

#entry("calculations 环境", "calculations", latex-syntax: ```latex
\begin{calculations}[⟨键值列表⟩]
  \item ⟨内容1⟩
  \item ⟨内容2⟩
\end{calculations}
```, typst-syntax: ```typ #calculations(⟨键值⟩)[⟨内容1⟩][⟨内容2⟩]```)[
    计算题排版。键值见 3.5.21 节。
]

#compare(title: [`calculations` 环境示例], ```latex
\begin{calculations}[
  % index = 3,             % 从 3 开始编号
  label   = \arabic*.,   % 样式，和 question 环境的一样
  columns = 2,           % 每行多少项
  hsep    = 0pt,         % 两列之间的间距
  vsep    = 4cm          % 两行之间的间距
]
  \item
    $(-10) + \dfrac{1}{3} - (-3)$
  \item（5分）
    $(-10) + 5 - (-3)$
  \item
    $(-10) + 5 - (-3)$
  \item（5分）
    $(-10) + 5 - (-3)$
\end{calculations}
```, ```typ
#calculations(
  // index: 3,         // 从 3 开始编号
  label: "1.",         // 样式，和 question 的一样
  columns: 2,          // 每行多少项
  hsep: 0pt,           // 两列之间的间距
  vsep: 4cm,           // 两行之间的间距
)[$(-10) + display(1/3) - (-3)$][（5分）$(-10) + 5 - (-3)$][$(-10) + 5 - (-3)$][（5分）$(-10) + 5 - (-3)$]
```)
