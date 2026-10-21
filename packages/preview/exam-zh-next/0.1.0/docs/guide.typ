// exam-zh-next 入门指南（Typst 版）。章节与示例对应 exam-zh 的 exam-zh-doc-basic。
// 编译：typst compile --root .. guide.typ

#import "doc-style.typ": *

#show: doc.with(title: [exam-zh-next 入门指南], subject: [Typst 版])

#make-title()

#tip(none, kind: "info")[
    本文档是 exam-zh Typst 版的*入门指南*，章节与示例和 LaTeX 版的入门文档（`exam-zh-doc-basic.pdf`）一一对应，专为第一次使用 Typst 或 exam-zh 的老师编写。

    *阅读本文档，你将学会：*
    + 在 10 分钟内创建第一份中文试卷；
    + 掌握选择题、填空题、解答题等基础题型；
    + 了解答案显示控制、页面设置等常用功能；
    + 获取完整的试卷示例代码，直接复制使用；
    + 快速解决常见问题。

    需要查询某个 LaTeX 命令或键值在 Typst 版中的写法时，请阅读《exam-zh-next API 对照手册》（`reference.typ`）：它按 LaTeX 版完整文档（`exam-zh-doc.pdf`）的顺序，逐条给出 LaTeX 写法、Typst 写法和效果。

    *推荐学习路径：*第 1 章创建第一份试卷 → 第 2 章理解基础概念 → 按需阅读第 3、4 章 → 参考第 5 章的完整示例 → 遇到问题查第 6 章 FAQ。
]

#outline(title: [目录], depth: 2)

#heading(numbering: none)[快速参考卡片]

本页提供最常用的命令速查。

==== 试卷基本结构

#code-only(```typ
#import "@preview/exam-zh-next:0.1.0": *

// 配置（可选）
#show: exam.with(
  title: [试卷标题],
  subject: [科目],
  question: (show-answer: true),            // 显示答案
  solution: (show-solution: "show-stay"),
)

#make-title()

#information([姓名#box(width: 6em, stroke: (bottom: .5pt))], [班级#box(width: 6em, stroke: (bottom: .5pt))])

#notice[注意事项1][注意事项2]

// ... 题目内容 ...
```)

==== 常用命令速查表

#table(
    columns: (auto, 1fr),
    [*命令*], [*说明*],
    table.cell(colspan: 2)[*选择题*],
    [`#question[...]`], [创建题目],
    [`#paren[A]`], [添加答案括号（A 是答案）],
    [`#choices[..][..]`], [创建选项列表，每个 `[...]` 是一个选项（自动标号 A, B, C, D…）],
    table.cell(colspan: 2)[*填空题*],
    [`#fillin[答案]`], [创建填空（答案默认隐藏）],
    [`#fillin(width: 4em)[答案]`], [指定填空宽度],
    [`#fillin[$[2, 3)$]`], [答案写在内容块里，方括号不需要额外保护],
    table.cell(colspan: 2)[*解答题*],
    [`#problem(points: 10)[...]`], [创建解答题（10 分）],
    [`#solution[...]`], [解答过程],
    [`#score(5)`], [标记给分点（5 分）],
    table.cell(colspan: 2)[*题号控制*],
    [`#exam-setup(question: (index: 1))`], [下一题的题号为 1],
    [`#exam-setup(question: (index: 11))`], [下一题的题号为 11],
    table.cell(colspan: 2)[*答案控制*],
    [`question: (show-answer: true)`], [显示选择题和填空题答案],
    [`solution: (show-solution: "show-stay")`], [原位显示解答],
    [`solution: (show-solution: "hide")`], [隐藏解答],
    [`--input exam-mode=teacher`], [编译教师版（显示以上全部答案）],
    table.cell(colspan: 2)[*选项排版*],
    [`choices: (columns: 2)`], [强制选项排成 2 列],
    [`choices: (columns: auto)`], [自动选择列数（默认）],
    [`#choices(columns: 4)[..]`], [单独设置此题排 4 列],
    table.cell(colspan: 2)[*数学符号*],
    [`uppi`], [正体圆周率 #sym.pi],
    [`eu`], [正体自然对数底 e],
    [`iu`], [正体虚数单位 i],
)

==== 快速切换学生版/教师版

*方法一：命令行参数（推荐）*

同一份源码，换一个参数就得到另一个版本，不需要改文件：

#code-only(spec: doc-config.typst, ```sh
typst compile exam.typ                                            # 学生版
typst compile --input exam-mode=teacher exam.typ exam-teacher.pdf # 教师版
```)

*方法二：在文件中切换*

#code-only(```typ
#show: exam.with(
  mode: "teacher",   // 教师版；删去这一行即为学生版
)
```)

==== 常见错误速查

#table(
    columns: (auto, 1fr),
    [*错误信息*], [*原因与解决*],
    [`unknown variable: ab`], [数学公式里连写的字母被当成变量名：`$ab$` 改为 `$a b$`],
    [`unknown variable` / `unknown function`], [函数名拼写错误，或忘了 `#import`],
    [`unclosed delimiter`], [`[`、`(`、`$` 没有闭合],
    [`exam-zh: unknown option ...`], [选项名写错，报错信息会给出完整的键名],
    [`unknown font family`], [没有安装对应字体，见第 6 章 Q3],
    [中文显示为方框], [系统中没有中文字体，或字体名写错],
)

==== 进阶技巧

*1. 批量生成不同版本*

#code-only(```sh
typst compile exam.typ exam-student.pdf
typst compile --input exam-mode=teacher exam.typ exam-teacher.pdf
```)

*2. 特殊符号处理*

#table(
    columns: (auto, auto),
    [*符号*], [*写法*],
    [方括号 \[2,3)], [`#fillin[$[2, 3)$]`（数学公式里直接写）或 `#fillin[\[2,3)]`],
    [百分号 50%], [`#fillin[50%]`（直接写）],
    [美元符号 \$100], [`#fillin[\$100]`],
    [和号 A&B], [`#fillin[A&B]`（直接写）],
    [下划线 a_1], [`#fillin[$a_1$]` 或 `#fillin[a\_1]`],
    [井号 \#、星号 \*], [`\#`、`\*`],
)

*3. 题目分值显示*

#code-only(```typ
// 全局显示分值
#exam-setup(question: (show-points: true))

// 单题设置分值
#question(points: 5)[题目内容...]
```)

= 快速开始

欢迎使用 exam-zh！本章将帮助你在 10 分钟内创建第一份中文试卷。

== 什么是 exam-zh

exam-zh 是一个专为中国试卷设计的 Typst 模板，让你能用代码的方式高效地制作试卷。它最初是 LaTeX 模板，本模板用 Typst 重新实现了它的功能和接口。

*一句话介绍：*用简洁的代码，排版专业的中文试卷。

*三大核心特性：*
+ *选项自动排版*：选择题的选项会自动排列成合适的列数，无需手动调整；
+ *答案智能控制*：一条命令生成教师版和学生版；
+ *密封线自定义*：支持多种密封线样式，符合中国试卷规范。

*适合谁用：*中小学教师、培训机构老师、想制作练习题或模拟试卷的学生，以及任何需要规范排版试卷的用户。

== 安装与验证

=== 快速安装

Typst 有两种用法：

- *在线使用*：在 #link("https://typst.app")[typst.app] 新建项目即可，不需要安装任何软件；
- *本地使用*：安装 Typst 命令行（例如 `winget install --id Typst.Typst`、`brew install typst`），或在 VS Code 中安装 Tinymist 插件。

模板通过第一行的 `#import` 自动下载，不需要单独安装：

#code-only(```typ
#import "@preview/exam-zh-next:0.1.0": *
```)

=== 检查安装

创建一个测试文件 `test.typ`：

#code-only(```typ
#import "@preview/exam-zh-next:0.1.0": *
#show: exam

安装成功！
```)

在命令行编译：

#code-only(```sh
typst compile test.typ
```)

如果生成了 `test.pdf` 并显示“安装成功！”，恭喜你，可以开始使用了！模板的全部功能（选择题、语文、英语、图文排版等）都由这一行 `#import` 引入，不需要再加载其他模块。

==== 注意事项

- 需要 Typst 0.15 或更新版本；
- 需要电脑上有中文字体（typst.app 自带思源/Noto 字体），字体设置见第 6 章 Q3；
- 每次编译只需运行一次，不需要像 LaTeX 那样编译两遍。

#tip([常见编译错误速查], kind: "bad")[
    *1. 错误：*`package not found` \
    *原因：*网络无法下载模板。\
    *解决：*检查网络，或按 README 的说明把模板放到本地 `@local` 包目录。

    *2. 错误：*中文显示为方框 \
    *原因：*没有找到中文字体。\
    *解决：*安装 Noto CJK 字体，或用 `font: (preset: "windows")` 等预设换成系统字体。

    *3. 错误：*`unknown variable: ab` \
    *原因：*数学公式中多个字母连写会被当成一个变量名。\
    *解决：*字母之间加空格：`$a b$`。
]

== 5 分钟创建第一份试卷

让我们从最简单的例子开始。创建一个新文件 `my-first-exam.typ`，输入以下内容：

#demo(setup: (meta: (title: [数学测试], subject: [数学])), ```typ
#import "@preview/exam-zh-next:0.1.0": *

// 设置试卷标题和科目
#show: exam.with(title: [数学测试], subject: [数学])

#make-title()

// 第一道选择题
#question[
  $1 + 1 = $ #paren[C]
  #choices[$0$][$1$][$2$][$3$]
]

// 第二道选择题
#question[
  下列哪个数是质数？#paren[B]
  #choices[$4$][$5$][$6$][$8$]
]
```)

编译：

#code-only(```sh
typst compile my-first-exam.typ
```)

*恭喜你！*你已经创建了第一份试卷。现在让我们理解这段代码：

+ `#import "@preview/exam-zh-next:0.1.0": *`：引入 exam-zh 模板；
+ `#show: exam.with(title: ..., subject: ...)`：把整份文档交给 `exam` 模板排版，同时设置标题和科目；
+ `#make-title()`：生成标题和科目；
+ `#question[...]`：创建一道题目，方括号里是题干；
+ `#paren[C]`：在题目后添加括号，`[C]` 表示答案是选项 C（默认隐藏）；
+ `#choices[..][..]`：创建选择题的选项列表，每个方括号是一个选项。

== 显示或隐藏答案

默认情况下答案是隐藏的（学生版）。要得到教师版，用命令行参数编译即可，源码不用改：

#code-only(```sh
typst compile --input exam-mode=teacher my-first-exam.typ my-first-exam-teacher.pdf
```)

也可以在源码中直接打开答案：

#demo(```typ
#show: exam.with(
  question: (show-answer: true),  // 显示答案
)

#question[
  $1 + 1 = $ #paren[C]
  #choices[$0$][$1$][$2$][$3$]
]
```, setup: (question: (show-answer: true)))

*小技巧：*教师版还会原位显示解答、标出正确选项；只要用命令行参数切换，就不需要反复注释代码。

== 添加填空题和解答题

让我们创建一份更完整的试卷：

#demo(versions: true, setup: (meta: (title: [数学测试], subject: [数学])), ```typ
#import "@preview/exam-zh-next:0.1.0": *
#show: exam.with(title: [数学测试], subject: [数学])

#make-title()

// 选择题
#question[
  $1 + 1 = $ #paren[C]
  #choices[$0$][$1$][$2$][$3$]
]

// 填空题
#question[
  圆周率 $uppi approx$ #fillin[3.14]（保留两位小数）。
]

// 解答题
#problem(points: 10)[
  计算：$(x + 1)^2$
  #solution[
    解：$(x + 1)^2 = x^2 + 2x + 1$
  ]
]
```)

*新增知识点：*
- `#fillin[答案]`：创建填空题，答案默认隐藏；
- `#problem[...]`：创建解答题（与 `question` 类似，但用于大题）；
- `points: 10`：设置题目分值为 10 分；
- `#solution[...]`：解答题的答案部分（学生版隐藏，教师版显示）。

== 下一步学习路线

+ *第 2 章*：了解 Typst 和 exam-zh 的基础概念；
+ *第 3 章*：学习更多题型和功能（分值显示、题号定制等）；
+ *第 4 章*：掌握常见场景（页面设置、草稿纸、密封线等）；
+ *第 5 章*：参考完整示例，复制使用；
+ *第 6 章*：遇到问题时查阅 FAQ。

*提示：*你可以跳过第 2 章，直接查阅后面需要的功能。第 2 章适合完全不了解 Typst 的新手。

== 常用资源

- *API 对照手册*：`reference.typ`（逐条查询 LaTeX 版命令与键值的 Typst 写法）；
- *示例代码*：`examples/basic/` 目录（可直接复制）；
- *Typst 官方文档*：#link("https://typst.app/docs")[typst.app/docs]，中文文档：#link("https://typst-doc-cn.github.io/docs/")[typst-doc-cn.github.io/docs]；
- *LaTeX 版 exam-zh*：#link("https://github.com/xkwxdyy/exam-zh")[GitHub]、#link("https://gitee.com/xkwxdyy/exam-zh")[Gitee]。

= 基础概念

本章为完全不了解 Typst 的新手准备。如果你已经会用 Typst，可以跳过本章，直接阅读第 3 章。

== Typst 基础知识

=== 什么是函数

Typst 中的命令叫做函数，以 `#` 开头，参数写在圆括号里，内容写在方括号里：

#code-only(```typ
#函数名(参数)
#函数名(参数)[内容]
#函数名[内容]
```)

*示例：*

#code-only(```typ
#make-title()                  // 无参数的函数
#fillin[答案]                  // 内容参数写在方括号里
#fillin(width: 5em)[答案]      // 有命名参数的函数
```)

=== 内容块：代替 LaTeX 的环境

LaTeX 用 `\begin{...}` 和 `\end{...}` 包裹的环境，在 Typst 中就是函数后面的方括号。方括号可以换行，里面可以放任意内容：

#code-only(```typ
#question[
  题目内容...
]

#choices[选项A][选项B]
```)

=== 注释

以 `//` 开头的内容是注释，不会被编译；`/* ... */` 可以注释多行。

#code-only(```typ
// 这是注释，不会显示在 PDF 中
#make-title()  // 行尾的注释
```)

*用途：*解释代码的作用、临时禁用某些代码。

=== 特殊字符

以下字符在 Typst 中有特殊含义，需要显示它们时在前面加反斜杠 `\`：

#table(
    columns: (auto, 1fr, auto),
    [*字符*], [*用途*], [*如何输入该字符*],
    [`#`], [函数调用], [`\#`],
    [`$`], [数学公式标记], [`\$`],
    [`*`、`_`], [加粗、强调（行内成对出现时）], [`\*`、`\_`],
    [`[`、`]`], [内容块], [`\[`、`\]`],
    [`=`、`+`、`-`（行首）], [标题、编号列表、无序列表], [`\=`、`\+`、`\-`],
    [`\`], [转义；单独使用表示换行], [`\\`],
    [`//`], [注释], [`\/\/`],
)

#tip([易错点提示], kind: "warn")[
    LaTeX 版中 `\fillin[[2,3)]` 会解析失败，需要写成 `\fillin[{$[2,3)$}]`。Typst 中答案写在内容块里，数学公式中的方括号不需要任何保护：`#fillin[$[2, 3)$]`。只有在普通文字里写不配对的方括号时才需要转义：`#fillin[\[2,3)]`。
]

== exam-zh 核心概念

=== 模板

每份试卷都以两行开头：引入模板，再把整份文档交给 `exam` 排版。

#code-only(```typ
#import "@preview/exam-zh-next:0.1.0": *
#show: exam
```)

=== 文档结构

一份完整试卷的结构：

#code-only(```typ
#import "@preview/exam-zh-next:0.1.0": *   // 引入模板

// === 配置（对应 LaTeX 的导言区）===
#show: exam.with(
  title: [标题],
  // 各种配置...
)

// === 试卷内容（对应 LaTeX 的正文）===
#make-title()

题目内容...
```)

`#show: exam.with(...)` 之后的全部内容都是试卷正文，不需要 `\begin{document}` 和 `\end{document}`。

=== 选项设置

LaTeX 版用 `\examsetup{键 = 值}` 配置，Typst 版的选项按模块写成字典 `模块: (键: 值)`：

#code-only(```typ
#show: exam.with(
  question: (show-answer: true, show-points: true),   // 显示答案和分值
  choices: (columns: 2),                              // 选项排 2 列
)
```)

LaTeX 的 `question/show-answer = true` 在 Typst 中写成 `question: (show-answer: true)`。选项可以写在三个地方，键名完全相同：

- `#show: exam.with(...)`：整份试卷的初始设置；
- `#exam-setup(...)`：从这里往后生效，相当于在正文中使用 `\examsetup`；
- 题目函数本身：`#choices(columns: 2)[...]`，只作用于这一次。

*注意：*
- 字典的每一项之间用逗号分隔，最后一项后面可以有逗号；
- 文字写成内容 `[...]`（如 `label: [考生须知：]`），选项值写成字符串 `"..."`（如 `type: "paren"`）；
- 键名写错时编译会直接报错并给出完整键名，例如 ``exam-zh: unknown option `choices.colums` ``。

=== 题目函数

exam-zh 提供三种题目函数：

+ *question*：用于选择题和填空题；
+ *problem*：用于解答题；
+ *solution*：用于解答过程（放在 `question` 或 `problem` 内部）。

#code-only(```typ
// 选择题/填空题
#question(points: 5)[
  题目内容...
]

// 解答题
#problem(points: 10)[
  题目内容...
  #solution[
    解答过程...
  ]
]
```)

=== 答案控制机制

*相关选项：*
- `question: (show-answer: ..)`：同时控制选择题括号和填空题的答案；
- `paren: (show-answer: ..)`：只控制括号内的答案；
- `paren: (show-paren: ..)`：控制括号是否出现；
- `fillin: (show-answer: ..)`：只控制填空题答案；
- `choices: (show-answer: ..)`：控制是否标出正确选项；
- `solution: (show-solution: ..)`：控制解答题答案；
- `mode: "teacher"` 或 `--input exam-mode=teacher`：一次打开以上全部答案。

*典型用法：*

#code-only(```typ
// 学生版（隐藏所有答案）—— 默认行为，不需要任何设置

// 教师版（显示所有答案）
#show: exam.with(mode: "teacher")
```)

== 编译与调试

=== 如何编译

*方法一：命令行*

#code-only(```sh
typst compile 文件名.typ    # 编译一次
typst watch 文件名.typ      # 保存文件时自动重新编译
```)

*方法二：编辑器（推荐）*

- *typst.app*：在线编辑，右侧实时预览；
- *VS Code + Tinymist 插件*：本地编辑，实时预览，点击预览可跳转到源码。

*注意：*Typst 没有“编译两次”的概念：目录、页码、答案后置等都在一次编译中完成。

=== 常见错误类型

==== 名称错误

*错误提示：*`unknown variable: titel`

*原因：*使用了不存在的函数或变量，或拼写错误。

#code-only(```typ
#show: exam.with(titel: [标题])  // 错误：应该是 title
```)

==== 数学公式中的字母连写

*错误提示：*`unknown variable: xy`

*原因：*Typst 数学公式中，连写的多个字母会被当成一个变量名（这样 `sin`、`pi` 才能直接写）。

#code-only(```typ
$xy + 1 = 0$     // 错误
$x y + 1 = 0$    // 正确：字母之间加空格
```)

==== 括号不匹配

*错误提示：*`unclosed delimiter`

*原因：*方括号、圆括号或 `$` 没有正确闭合。

#code-only(```typ
#question[
  题目内容...
// 错误：少了右方括号 ]
```)

==== 选项写错

*错误提示：*``exam-zh: unknown option `fillin.typ` ``

*原因：*选项名拼写错误。报错信息给出了完整的键名，按第 3 章或 API 对照手册改正即可。

=== 调试技巧

+ *查看错误位置*：错误信息会标出出错的文件、行号，并在源码下画出出错的位置；
+ *二分法查找*：注释掉一半代码，如果能编译，错误在注释部分，继续二分直到找到出错位置；
+ *最小可复现示例*：删除不相关代码，保留最少的能重现问题的代码，方便提问和排查；
+ *编辑器提示*：Tinymist 会在出错处画波浪线，并在鼠标悬停时显示说明。

== 下一步

+ 阅读第 3 章，学习如何创建各种题型；
+ 尝试修改 `examples/basic/` 中的示例；
+ 遇到问题时查阅第 6 章 FAQ；
+ 需要详细参数时查阅《exam-zh-next API 对照手册》。

不要试图一次性学完所有内容，而是*边用边学、遇到问题再查*。

= 创建题目

本章详细介绍如何创建各种题型。掌握这些内容后，你就能制作大部分常见的试卷了。

== 试卷抬头

试卷抬头包括标题、科目、学生信息栏和注意事项等内容。

=== 标题和科目

标题和科目写在 `exam` 中，`#make-title()` 把它们排出来：

#demo(setup: (meta: (title: [2024年春季期中考试], subject: [数学])), ```typ
#import "@preview/exam-zh-next:0.1.0": *
#show: exam.with(title: [2024年春季期中考试], subject: [数学])

#make-title()
```)

*说明：*
- `title` 设置主标题；
- `subject` 设置科目，`subject-width` 控制科目文字分散对齐的宽度；
- `#make-title()` 也可以直接给出标题：`#make-title(title: [...], subject: [...])`，试卷合集中常用。

=== 学生信息栏

#demo(```typ
#information(
  [姓名#box(width: 6em, stroke: (bottom: .5pt))],
  [班级#box(width: 6em, stroke: (bottom: .5pt))],
  [座号#box(width: 4em, stroke: (bottom: .5pt))],
)
```)

*提示：*
- 用 `#box(width: 长度, stroke: (bottom: .5pt))` 画填写下划线；
- 常用长度单位：`em`（字符宽度）、`cm`（厘米）、`mm`（毫米）；
- `separator: h(2em)` 改变各项之间的距离（默认 `h(1em)`）。

=== 注意事项

#demo(```typ
#notice[本试卷共 3 大题，满分 100 分。][考试时间 90 分钟。][请用黑色签字笔在答题卡上作答。]
```)

每个方括号是一条注意事项。*自定义标题：*

#demo(```typ
#notice(label: [考生须知：])[...][...]
```)

== 选择题

选择题由 `question` 和 `choices` 组合使用。

=== 基本用法

#demo(```typ
#question[
  下列哪个数是质数？#paren[B]
  #choices(answer: "B")[$4$][$5$][$6$][$8$]
]
```)

*关键点：*
+ `#question[...]` 创建题目；
+ `#paren[B]` 添加答案括号，`[B]` 表示正确答案是选项 B（默认隐藏）；
+ `#choices[..][..]` 创建选项列表，每个方括号是一个选项，自动标号为 A、B、C、D…；
+ `answer: "B"` 记录正确选项，对应 LaTeX 版的 `\item*`。

=== 标记和显示正确选项

`answer` 只记录正确选项，默认不改变学生版外观。需要显示答案时，可以统一着色正确选项：

#demo(```typ
#exam-setup(choices: (show-answer: true, answer-color: red))

#choices(answer: "BD")[错误选项][正确选项][错误选项][另一个正确选项]
```)

`choices: (show-answer: ..)` 独立于 `question: (show-answer: ..)`；教师版会同时打开两者。

=== 显示分值

默认情况下，`question` 的分值是隐藏的（`problem` 的分值默认显示）。

#demo(```typ
// 全局显示所有题目的分值
#exam-setup(question: (show-points: true))

#question(points: 5)[
  题目内容……（本题 5 分）
]
```)

=== 控制选项排列

选项默认会自动排列成合适的列数。

*手动指定列数：*

#demo(```typ
// 全局设置：所有选择题排成 2 列
#exam-setup(choices: (columns: 2))
#choices[选项一][选项二][选项三][选项四]

// 单独设置某题：这题排成 4 列
#choices(columns: 4)[选项一][选项二][选项三][选项四]
```)

*强制单列（选项内容很长时）：*

#demo(```typ
#choices(columns: 1)[这是一个很长的选项内容……][另一个很长的选项……]
```)

=== 选项标签样式

默认选项标签是 A、B、C、D…，可以自定义：

#demo(```typ
// 使用数字标签
#choices(label: "1.")[选项1][选项2]

// 使用带圈数字
#choices(label: "①")[第一个选项][第二个选项]
```)

=== 多选题

多选题使用同样的方式，只是答案可以有多个：

#demo(versions: true, ```typ
#question[
  下列哪些数是质数？（多选）#paren[BD]
  #choices(answer: "BD")[$4$][$5$][$6$][$7$]
]
```)

=== 嵌套使用

LaTeX 版的 `choices` 在深层列表、绕排图片和 `minipage` 中容易错位。Typst 版的 `choices` 按所在位置的实际宽度计算列数，这些情况都可以直接使用。

*在列表中使用：*

#demo(```typ
#problem[
  已知函数 $f(x) = x^2 - 2x + 1$。
  + 求 $f(x)$ 的对称轴；
  + $f(x)$ 的图像与 $x$ 轴的交点个数是 #paren[B]
    #choices[0 个][1 个][2 个][3 个]
]
```)

*在较窄的区域中使用：*列数按区域宽度自动减少，不需要手动指定。

#demo(```typ
#block(width: 50%, stroke: .5pt + gray, inset: 6pt)[
  #question[
    题目……#paren[A]
    #choices[选项一][选项二][选项三][选项四]
  ]
]
```)

*与图片并排：*用 `textfigure`（见第 4 章）。

== 填空题

填空题使用 `fillin` 创建填空位置。

=== 基本用法

#demo(versions: true, ```typ
#question[
  圆周率 $uppi approx$ #fillin[3.14]（保留两位小数）。
]

#question[
  $1 + 1 = $ #fillin[2]。
]
```)

*说明：*
- `#fillin[答案]` 创建填空，答案默认隐藏；
- 答案在 `question: (show-answer: true)` 或教师版中显示；
- 学生版的空里默认显示黑色三角形 ▲，也可以改为编号或空白（见下）。

=== 调整填空宽度

填空宽度在 `no-answer-type: "none"`（只留空白）时生效：

#demo(```typ
// 全局设置
#exam-setup(fillin: (no-answer-type: "none", width: 4em))
默认宽度：#fillin[答案]

// 单独设置
计算结果：#fillin(width: 8em)[很长的答案内容]
答：#fillin(width: 2em)[是]

// 按答案长度留空
春眠不觉晓，#fillin(width: auto)[处处闻啼鸟]。
```)

=== 特殊符号使用注意事项

Typst 中答案写在内容块 `[...]` 里，大部分符号都可以直接写：

#demo(```typ
区间为 #fillin(show-answer: true)[$[2, 3)$]，
不配对的括号 #fillin(show-answer: true)[$(-infinity, 1]$]，
百分号 #fillin(show-answer: true)[50%]，
美元 #fillin(show-answer: true)[\$100]，
下标 #fillin(show-answer: true)[$a_1$]，
集合 #fillin(show-answer: true)[${1, 2}$]
```)

#table(
    columns: (auto, auto, auto),
    [*符号*], [*LaTeX 版写法*], [*Typst 版写法*],
    [方括号区间], [`\fillin[{$[2,3)$}]`], [`#fillin[$[2, 3)$]`],
    [百分号 %], [`\fillin[50\%]`], [`#fillin[50%]`],
    [美元符号 \$], [`\fillin[\$100]`], [`#fillin[\$100]`],
    [和号 &], [`\fillin[A\&B]`], [`#fillin[A&B]`],
    [下划线 \_], [`\fillin[$a_1$]`], [`#fillin[$a_1$]` 或 `#fillin[a\_1]`],
    [花括号], [`\fillin[{$\{1,2\}$}]`], [`#fillin[${1, 2}$]`],
)

#tip([易错点提示], kind: "warn")[
    + 数学内容要写在 `$...$` 中，例如 `#fillin[$x^2 + 1$]`；
    + 普通文字中的 `#`、`$`、`*`、`_`、`[`、`]` 需要加反斜杠；
    + 不确定时，把答案写成数学公式 `$...$` 通常最安全。
]

*长答案换行：*显示答案时，答案宽度超过一行会自动换行；`breakable: true` 无论长短都使用可换行排版：

#demo(```typ
#exam-setup(fillin: (show-answer: true))
短答案：#fillin[3.14]

长答案：#fillin[这是一个比较长的答案内容，需要在题目中换行显示，这是一个比较长的答案内容]

强制可换行：#fillin(breakable: true)[短答案]
```)

=== 填空样式

默认是下划线样式，也可以改成括号、圆圈、方框或纯留白：

#demo(```typ
#exam-setup(fillin: (show-answer: true))
下划线 #fillin[答案]，括号 #fillin(type: "paren")[答案]，圆圈 #fillin(type: "circle")[答案]，方框 #fillin(type: "rectangle")[答案]，留白 #fillin(type: "blank")[答案]。
```)

全局改为括号样式：`#exam-setup(fillin: (type: "paren"))`。

=== 数学公式中的填空

#demo(versions: true, ```typ
#question[
  解方程：$x^2 - 5x + 6 = 0$，得 $x_1 = $ #fillin[2]，$x_2 = $ #fillin[3]。
]

#question[
  化简：$(x + 1)^2 = $ #fillin[$x^2 + 2x + 1$]。
]
```)

== 解答题

解答题使用 `problem` 和 `solution`。

=== 基本结构

#demo(versions: true, ```typ
#problem(points: 10)[
  计算：$(x + 1)^2$

  #solution[
    解：

    $(x + 1)^2 = (x + 1)(x + 1)$

    $= x^2 + 2x + 1$

    答：$(x + 1)^2 = x^2 + 2x + 1$
  ]
]
```)

*说明：*
- `problem` 创建解答题（类似 `question`，但分值单独成行、题干首行缩进）；
- `points: 10` 设置分值；
- `solution` 包含解答过程（默认隐藏）。

*推荐结构：*把 `solution` 放在它所对应的 `question` 或 `problem` 内部，并置于题干之后，题目与解答的对应关系最清楚：

#demo(setup: (solution: (show-solution: "show-stay")), ```typ
#import "@preview/exam-zh-next:0.1.0": *
#show: exam.with(solution: (show-solution: "show-stay"))

#question[
  $uppi approx$ #fillin[3.14]（保留两位小数）。
  #solution[$uppi approx 3.14$。]
]
```)

=== 显示解答

#code-only(```typ
#show: exam.with(
  solution: (show-solution: "show-stay"),   // 原位显示
  // solution: (show-solution: "show-move"), // 移到试卷最后
  // solution: (show-solution: "hide"),      // 隐藏（默认）
)
```)

*三种模式：*
+ `"hide"`（默认）：完全隐藏，生成学生版；
+ `"show-stay"`：在原位显示，适合教师版；
+ `"show-move"`：移到试卷最后的“参考答案”中统一显示。

=== 给分点标记

#demo(setup: (solution: (show-solution: "show-stay")), ```typ
#solution[
  解：设方程两根为 $x_1$、$x_2$。#score(2)
  由韦达定理得：$x_1 + x_2 = 5$ #score(3)
  $x_1 dot x_2 = 6$ #score(3)
  解得 $x_1 = 2$，$x_2 = 3$。#score(2)
]
```)

*说明：*`#score(分数)` 标记该步骤的分值，引导线自动画到行末。写在行间公式里时，公式保持居中，引导线从公式末尾画到页边。

=== 小问题

解答题中可以包含多个小问，用 `+` 开头的行写编号列表：

#demo(versions: true, ```typ
#problem(points: 12)[
  已知函数 $f(x) = x^2 - 2x + 1$。
  + 求 $f(x)$ 的最小值；
  + 求 $f(x)$ 的对称轴；
  + 画出 $f(x)$ 的图像。

  #solution[
    + 配方得 $f(x) = (x - 1)^2$，最小值为 $0$。#score(5)
    + 对称轴为 $x = 1$。#score(4)
    + （图像略）#score(3)
  ]
]
```)

== 其他题型

=== 判断题

模板没有单独的“判断题命令”，直接用 `paren` 或 `fillin` 写“对/错”即可：

#demo(versions: true, ```typ
#question[
  $1 + 1 = 3$。#paren[错]
]

#question[
  圆的面积公式是 $S = uppi r^2$。#fillin[对]
]
```)

*说明：*
- `#paren[对]`、`#paren[错]` 适合直接在题干后给出判断位；
- `#fillin[对]`、`#fillin[错]` 适合需要横线或括号样式的场景；
- 答案仍由 `question: (show-answer: true)` 或教师版控制显示。

=== 列表题

一个大题下有多个并列的小问题：

#demo(versions: true, ```typ
#question[
  计算下列各题：
  + $1 + 1 = $ #fillin[2]
  + $2 + 2 = $ #fillin[4]
  + $3 + 3 = $ #fillin[6]
]
```)

== 题号控制

=== 自动编号

题号默认从 1 开始自动递增，跨大题不重置，无需手动管理。

=== 重置题号

`question: (index: n)` 表示*下一题的题号为 n*。在新的题型部分重新从 1 开始：

#demo(```typ
= 选择题
#question[题号自动从 1 开始]
#question[第 2 题]

= 填空题
#exam-setup(question: (index: 1))
#question[题号重新从 1 开始]
```)

#tip([与 LaTeX 版入门文档的差别], kind: "warn")[
    LaTeX 版入门文档写的是“`question/index = 0` 重置题号”，但 exam-zh 的实际效果是下一题编号为 0（它的示例 `01-first-exam` 中填空题就从“0.”开始）。Typst 版的 `index` 与 exam-zh 的实现一致，表示下一题的题号，所以重新从 1 开始要写 `index: 1`。
]

=== 手动设置题号

#demo(```typ
#exam-setup(question: (index: 11))  // 下一题为第 11 题

#question[这是第 11 题……]
```)

只改某一题的题号：`#question(index: 11)[...]`。

=== 题号样式

#demo(```typ
#exam-setup(question: (label: "1."))    // 1. 2. 3. …
#question[默认样式]
#exam-setup(question: (label: "(1)"))   // (1) (2) (3) …
#question[带括号]
#exam-setup(question: (label: "A."))    // A. B. C. …
#question[字母]
```)

== 完整示例

#tip([完整示例说明], kind: "good")[
    此示例展示了一份标准试卷的完整结构：试卷抬头（标题、科目、学生信息、注意事项），三种题型（选择题、填空题、解答题），题号重置和分值设置，以及学生版/教师版的切换方式。

    *提示：*可复制此代码作为模板，也可参考 `examples/basic/01-first-exam.typ` 获取更实用的示例。
]

#demo(versions: true, setup: (meta: (title: [2024年春季期中考试], subject: [数学])), ```typ
#import "@preview/exam-zh-next:0.1.0": *
#show: exam.with(title: [2024年春季期中考试], subject: [数学])

#make-title()

#information(
  [姓名#box(width: 6em, stroke: (bottom: .5pt))],
  [班级#box(width: 6em, stroke: (bottom: .5pt))],
)

#notice[本试卷共 3 大题，满分 100 分。][考试时间 90 分钟。]

= 选择题（每题5分，共10分）

#question[
  $1 + 1 = $ #paren[C]
  #choices(answer: "C")[$0$][$1$][$2$][$3$]
]

#question[
  下列哪个是质数？#paren[B]
  #choices(answer: "B")[$4$][$5$][$6$][$8$]
]

= 填空题（每题5分，共10分）
#exam-setup(question: (index: 1))

#question[$uppi approx$ #fillin[3.14]（保留两位小数）。]

#question[正方形边长5cm，面积是 #fillin[25] $"cm"^2$。]

= 解答题（共10分）
#exam-setup(question: (index: 1))

#problem(points: 10)[
  计算：$(x + 1)^2$
  #solution[解：$(x + 1)^2 = x^2 + 2x + 1$]
]
```)

*使用提示：*复制此代码作为模板，修改标题、科目和题目内容；用 `--input exam-mode=teacher` 编译教师版。

= 常见场景

本章介绍实际使用中的常见需求和解决方案。

== 答案控制方案

=== 生成学生版和教师版

*学生版（默认）：*什么都不设置，所有答案都隐藏。

*教师版：*显示括号和填空答案、标出正确选项、原位显示解答。

#tip([最佳实践：版本切换方法对比], kind: "good")[
    *方法一：命令行参数（推荐）*

    适合场景：所有情况。一份源码，两条命令：

    #code-only(```sh
    typst compile exam.typ                                         # 学生版
    typst compile --input exam-mode=teacher exam.typ exam-ans.pdf  # 教师版
    ```)

    *方法二：在文件中切换*

    适合场景：在编辑器中预览教师版。

    #code-only(```typ
    #show: exam.with(
      mode: "teacher",   // 教师版；删去或改成 "student" 即为学生版
    )
    ```)

    *方法三：自定义教师版*

    适合场景：教师版需要不同的设置，例如换标题、把解答移到文末、显示分值。`teacher` 中的设置只在教师版生效：

    #code-only(```typ
    #show: exam.with(
      title: [2026 年春季期中考试],
      teacher: teacher-defaults + (
        title: [2026 年春季期中考试参考答案],
        question: (show-answer: true, show-points: true),
        solution: (show-solution: "show-move"),
      ),
    )
    ```)

    只属于某一版的内容用 `#student-only[...]` 和 `#teacher-only[...]` 包裹，例如教师版不需要的注意事项。
]

#grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    shot("first-student", caption: [学生版]),
    shot("first-teacher", caption: [教师版]),
)

=== 解答显示位置

#code-only(```typ
#show: exam.with(
  // solution: (show-solution: "hide"),       // 隐藏（学生版）
  // solution: (show-solution: "show-stay"),  // 原位显示（教师版）
  solution: (show-solution: "show-move"),     // 移到最后
)
```)

`"show-move"` 适合制作“答案另附”的试卷：解答集中排在文末的“参考答案”中，题号自动对应。

#shot("teacher-moved", width: 70%, caption: [`show-move`：解答集中在文末（`examples/basic/03-real-exam-scenario.typ` 的教师版）])

== 页面设置

=== 纸张大小

#code-only(```typ
#show: exam.with(
  page: (size: "a4"),                  // A4 纸（默认）
  // page: (size: "a3"),               // A3 横向，每张两栏
  // page: (size: (195mm, 270mm)),     // 自定义尺寸，例如 16K
)
```)

=== 页边距调整

LaTeX 版要把 `\geometry` 放进 `\AtEndPreamble`；Typst 版直接写在 `page` 中：

#code-only(```typ
#show: exam.with(
  page: (margin: (top: 2.5cm, bottom: 2cm, left: 2cm, right: 2cm)),
)
```)

=== 分栏设置

让一部分内容分成两栏：

#demo(```typ
#columns(2)[
  #question[题目内容……#paren()
    #choices[选项一][选项二][选项三][选项四]]
  #question[题目内容……#paren()
    #choices[选项一][选项二][选项三][选项四]]
]
```)

整份试卷排成 A3 双栏时用 `page: (size: "a3")`。

== 图文混排详解

=== 基本用法

`textfigure` 的第一个方括号是文字，第二个是图片：

#demo(```typ
#textfigure[
  如图所示，已知三角形 $A B C$ 的三边长分别为 3、4、5，求三角形的面积。
][#image("../examples/assets/example-image.svg", width: 3cm)]
```)

图片位于文字左、右侧时，文字宽度自动等于行宽减去图片宽度；图片过宽时，文字不会窄于 `min-text-width`：

#demo(```typ
#textfigure(fig-pos: "right-top", min-text-width: 40%, column-gap: 1em)[
  如图所示，求阴影部分的面积。
][#image("../examples/assets/example-image.svg", width: 3cm)]
```)

*说明：*第一个方括号是文字内容，第二个方括号是图片内容；更细的控制见 API 对照手册的 `textfigure` 一节。

=== 多张图片

#demo(```typ
#multifigures(columns: 2,
  ([题 1 图], image("../examples/assets/example-image.svg", width: 3cm)),
  ([题 2 图], image("../examples/assets/example-image.svg", width: 3cm)),
)
```)

*适用场景：*
- 一段文字配一张图：优先用 `textfigure`；
- 多张题图并排展示：优先用 `multifigures`；
- 只想简单插图：直接用 `image`。

=== 简单插图

#demo(```typ
#align(center, image("../examples/assets/example-image.svg", width: 30%))
```)

== 行距和间距调整

本节介绍如何调整行距和各种间距，以适应不同需求（如节约纸张）。

=== 全局行距调整

#code-only(```typ
#show: exam.with(
  style: (par-leading: 0.7em),   // 行距（默认 0.85em）
)
```)

*注意：*行距过小会影响阅读。行内公式比行高时，模板会自动加大该行的行距，不会重叠。

=== 题目间距调整

#code-only(```typ
#exam-setup(question: (top-sep: 0.2em, bottom-sep: 0.2em))   // 选择题、填空题
#exam-setup(problem: (top-sep: 0.5em, bottom-sep: 0.5em))    // 解答题
```)

=== 选项间距调整

#demo(```typ
// 选项行之间的额外间距
#choices(columns: 2, linesep: 0.6em)[选项一][选项二][选项三][选项四]
// 列与列之间的最小间距
#choices(column-sep: 3em)[选项一][选项二][选项三][选项四]
```)

=== 段落间距调整

#code-only(```typ
#show: exam.with(
  style: (
    par-spacing: 0.4em,        // 段落间距
    first-line-indent: 0em,    // 取消首行缩进（可选）
  ),
)
```)

=== 紧凑模式示例

*综合示例：让试卷更紧凑以节约纸张*

#code-only(```typ
#import "@preview/exam-zh-next:0.1.0": *

#show: exam.with(
  // === 页边距 ===
  page: (margin: (top: 2cm, bottom: 1.5cm, x: 1.8cm)),
  // === 行距与段落间距 ===
  style: (par-leading: 0.7em, par-spacing: 0.5em),
  // === 题目和选项间距 ===
  question: (top-sep: 0.2em, bottom-sep: 0.2em),
  choices: (linesep: 0.3em, column-sep: 0.8em),
)

// 试卷内容...
```)

*效果：*可节约约 20%–30% 的纸张，保持基本可读性，适合练习题或非正式考试。正式考试建议保持默认设置。

=== 局部调整间距

#code-only(```typ
#v(1em)      // 增加间距
#v(-0.5em)   // 减少间距
#v(1fr)      // 弹性间距，把后面的内容推到页面底部
#pagebreak() // 换页
```)

== 特殊功能

=== 方格纸

需要一串可填写的小方格时，可以使用 `examsquare`：

#demo(```typ
考号：#examsquare(10)
```)

=== 评分框

#demo(```typ
#scoringbox()
```)

`scoringbox: (type: "twocolumn")` 让每个大题标题旁自动出现评分框。

=== 密封线

开启密封线：

#code-only(```typ
#show: exam.with(sealline: (enable: true))
```)

修改密封线文字：

#code-only(```typ
#show: exam.with(sealline: (enable: true, text: "密封线内不要答题"))
```)

#shot("sealline-a4", width: 60%, caption: [A4 试卷的密封线（`examples/basic/03-real-exam-scenario.typ`）])

更多密封线设置见 API 对照手册的“密封线”一节。

== 学科专用功能

=== 语文试卷

*古诗排版：*

#demo(```typ
#poem[
  白日依山尽，\
  黄河入海流。\
  欲穷千里目，\
  更上一层楼。
]
```)

*阅读材料：*

#demo(```typ
#material(title: [文章标题], author: [作者])[
  文章内容……
]
```)

*作文答题格：*

#demo(```typ
= 写作

请以“窗外”为题，写一篇不少于 800 字的文章。

#composition-grid(100, row-sep-ratio: 3, count-marks: (60, 80))
```)

`composition-grid` 的参数是希望提供的最少作文格数，默认每行 20 格；格数不能整除每行格数时，会自动向上补成完整一行（每行 24 格、目标 1000 格时实际提供 1008 格）。网格先利用当前页的剩余空间，再自动分页续排。`row-sep-ratio: 3` 采用较紧凑的行距，`count-marks` 在相应行末显示累计字数（示例中为节省篇幅只画了 100 格）。格子大小可用 `cell-size` 直接指定，默认按当前字号和 `cell-scale` 自动计算。

=== 英语试卷

*作文答题框：*

#demo(```typ
#writingbox(title: [My Dream])[
  #v(6em)
]
```)

== 快速参考

*常用配置速查：*

#code-only(```typ
#show: exam.with(
  // === 答案控制 ===
  question: (show-answer: true, show-points: true),   // 显示答案和分值
  solution: (show-solution: "show-stay"),             // 显示解答
  // === 选项排列 ===
  choices: (columns: 2),
  // === 页面设置 ===
  sealline: (enable: true),                           // 密封线
)
```)

更多功能和详细参数，请查阅《exam-zh-next API 对照手册》。

= 完整示例

本章提供可直接使用的完整试卷示例。所有示例代码都在 `examples/basic/` 目录中，与 LaTeX 版的 `examples-basic/` 一一对应。

== 示例文件说明

/ `00-minimal.typ`: 最小示例（十几行代码创建试卷）
/ `01-first-exam.typ`: 第一份完整试卷（包含选择题、填空题、解答题）
/ `02-math-basic.typ`: 高中数学期末考试（带评分点的解答题）
/ `03-chinese-basic.typ`: 基础语文试卷（材料、古诗、选择标记和作文格）
/ `03-real-exam-scenario.typ`: 真实考试场景（密封线、评分框、草稿纸、教师版答案后置）
/ `04-english-basic.typ`: 基础英语试卷（选择题、作文框和横线）

另外，`examples/example-single.typ` 是 2021 年全国乙卷数学，`examples/example-multiple.typ` 是带密封线和目录的 A3 试卷合集。

#tip([如何使用这些示例], kind: "info")[
    *方法一：直接编译*
    + 在仓库根目录运行 `typst compile --root . examples/basic/01-first-exam.typ`；
    + 查看生成的 PDF 文件。

    *方法二：复制修改*
    + 复制示例文件到你的工作目录，把第一行改为 `#import "@preview/exam-zh-next:0.1.0": *`；
    + 修改标题、科目、题目内容；
    + 编译生成你自己的试卷，用 `--input exam-mode=teacher` 编译教师版。

    *方法三：*运行 `typst init @preview/exam-zh-next` 生成一份新试卷。

    *推荐：*从 `01-first-exam.typ` 开始，这是最适合新手的模板。
]

== 示例对比

#table(
    columns: (auto, 1fr, 1fr),
    [*示例*], [*特点*], [*适用场景*],
    [00-minimal], [最简代码], [快速测试、学习基础语法],
    [01-first-exam], [完整结构，有答案控制], [日常测验、课堂小考],
    [02-math-basic], [题目较多，带评分点], [期中/期末考试],
    [03-chinese-basic], [材料、古诗、选择标记和作文格], [语文练习与考试],
    [03-real-exam], [密封线、评分框、草稿纸], [正式考试、月考],
    [04-english-basic], [阅读选择题、作文框和横线], [英语练习与考试],
)

#grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 0.8em,
    row-gutter: 0.8em,
    shot("minimal", caption: [00-minimal]),
    shot("first-student", caption: [01-first-exam]),
    shot("math-basic", caption: [02-math-basic]),
    shot("chinese-basic", caption: [03-chinese-basic]),
    shot("sealline-a4", caption: [03-real-exam-scenario]),
    shot("english-basic", caption: [04-english-basic]),
)

== 数学试卷示例

完整代码见 `examples/basic/01-first-exam.typ`，这里展示主要结构：

#demo(versions: true, setup: (meta: (title: [2024年春季期中考试], subject: [数学])), ```typ
#import "@preview/exam-zh-next:0.1.0": *
#show: exam.with(title: [2024年春季期中考试], subject: [数学])

// 试卷抬头
#make-title()
#information(
  [姓名#box(width: 6em, stroke: (bottom: .5pt))],
  [班级#box(width: 6em, stroke: (bottom: .5pt))],
  [座号#box(width: 4em, stroke: (bottom: .5pt))],
)
#notice[本试卷共3大题，满分100分，考试时间90分钟。][请用黑色签字笔在答题卡上作答。]

// 一、选择题
= 选择题（每题5分，共20分）
#question[
  已知集合 $A = {1, 2, 3}$，$B = {2, 3, 4}$，则 $A inter B = $ #paren[B]
  #choices(answer: "B")[${1}$][${2, 3}$][${1, 2, 3, 4}$][$emptyset$]
]

// 二、填空题
= 填空题（每题5分，共20分）
#exam-setup(question: (index: 1))  // 题号从 1 重新开始
#question[若 $f(x) = 3x - 2$，则 $f(2) = $ #fillin[4]。]

// 三、解答题
= 解答题（共60分）
#exam-setup(question: (index: 1))
#problem(points: 15)[
  已知函数 $f(x) = x^2 - 4x + 3$。
  + 求 $f(x)$ 的对称轴；
  + 求 $f(x)$ 的最小值。

  #solution[
    + 对称轴为 $x = 2$。#score(7)
    + 最小值为 $-1$。#score(8)
  ]
]
```)

== 真实考试场景示例

完整代码见 `examples/basic/03-real-exam-scenario.typ`，展示了真实考试的完整要素：

*特色功能：*
+ *密封线：*`sealline: (enable: true)` 在装订边画出密封线和考生信息栏；
+ *评分框：*`scoringbox: (type: "twocolumn")` 在每个大题旁加评分框；
+ *完整评分标准：*每个给分点都用 `#score(分值)` 标记；
+ *草稿纸：*`#draftpaper()` 在文末添加不计页码的草稿纸；
+ *教师版：*独立的卷头，解答集中在文末，学生版的注意事项用 `student-only` 隐藏。

*代码片段：*

#code-only(```typ
#show: exam.with(
  title: [高一数学月考试卷],
  sealline: (enable: true),
  scoringbox: (type: "twocolumn"),
  teacher: teacher-defaults + (
    title: [高一数学月考试卷参考答案],
    solution: (show-solution: "show-move"),
  ),
)

#student-only(secret())
#make-title()

#student-only[
  #information([姓名#box(width: 6em, stroke: (bottom: .5pt))], ...)
  #notice[本试卷共 4 页，22 小题，满分 150 分。][...]
]

// ... 题目内容 ...

#student-only(draftpaper())
```)

#grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    shot("sealline-a4", caption: [学生版第 1 页]),
    shot("draftpaper", caption: [草稿纸]),
)

== 自定义你的试卷

+ *修改标题和科目：*`#show: exam.with(title: [你的考试名称], subject: [你的科目])`；
+ *调整题型分值：*`= 选择题（本题共8小题，每小题5分，共40分）`；
+ *添加或删除题目：*直接复制 `#question[...]`、`#problem[...]`，修改内容即可；
+ *切换学生版/教师版：*用 `--input exam-mode=teacher` 编译。

== 更多示例

- `examples/example-single.typ`：2021 年全国乙卷数学（理科）；
- `examples/example-multiple.typ`：A3 试卷合集，两份试卷共用 `examples/papers/` 中的题目文件；
- 用户手册与 API 对照手册中的每个示例都可以直接复制使用。

#grid(
    columns: (1fr, 1.4fr),
    column-gutter: 1em,
    shot("example-single", caption: [example-single]),
    shot("sealline-a3", caption: [example-multiple]),
)

== 使用建议

=== 如何使用示例

+ *复制示例文件*：找到最接近你需求的示例，复制整个文件，重命名为你的试卷名称；
+ *修改内容*：修改标题和科目，替换题目内容，调整题目数量和分值；
+ *生成 PDF*：编译并检查效果，根据需要调整。

=== 常见修改

- *修改题目数量：*直接增加或删除 `question`/`problem`；
- *修改分值分配：*修改每题的 `points`，并调整大题标题中的总分；
- *切换学生版/教师版：*`--input exam-mode=teacher`；
- *调整页面布局：*参考第 4 章“页面设置”。

== 代码模板

这里提供一些常用的代码片段，可以直接复制使用。

=== 选择题模板

#demo(```typ
#question[
  题干内容 #paren[A]
  #choices(answer: "A")[选项A（正确答案）][选项B][选项C][选项D]
]
```)

=== 填空题模板

#demo(```typ
#question[
  题干内容，答案是 #fillin[答案]。
]
```)

=== 解答题模板

#demo(versions: true, ```typ
#problem(points: 10)[
  题干内容

  #solution[
    解：

    步骤1 #score(3)
    步骤2 #score(4)
    答案 #score(3)
  ]
]
```)

== 进一步学习

- 尝试修改示例文件，理解各部分的作用；
- 参考第 3 章学习更多题型和功能；
- 遇到问题查阅第 6 章 FAQ；
- 需要更多功能时查阅《exam-zh-next API 对照手册》。

= 常见问题 FAQ

本章收集了最常遇到的问题，编号与 LaTeX 版入门文档的 FAQ 相同。Typst 中不存在的问题也保留了编号，并说明对应的情况。

== 安装与编译问题

=== Q1：如何确认 exam-zh 可以使用？

创建一个测试文件：

#code-only(```typ
#import "@preview/exam-zh-next:0.1.0": *
#show: exam

测试成功
```)

运行 `typst compile test.typ`，如果生成 PDF 并显示“测试成功”，说明可以使用。

=== Q2：数学公式编译错误

*常见原因 1：*在普通文本中使用了数学符号但没有用 `$` 包裹。

#code-only(```typ
计算结果是 x^2      // 错误：显示为普通文字
计算结果是 $x^2$    // 正确
```)

*常见原因 2：*多个字母连写。Typst 会把 `$ab$` 当作名为 `ab` 的变量，报 `unknown variable: ab`；字母之间加空格：`$a b$`。

=== Q3：中文无法显示或显示为方框

*可能原因及解决方案：*
+ *缺少中文字体*：运行 `typst fonts` 查看可用字体。默认的 `noto` 预设使用 Noto Serif CJK SC 与 Noto Sans CJK SC（typst.app 自带）；Windows、macOS 可以改用系统字体：
  #code-only(```typ
  #show: exam.with(font: (preset: "windows"))   // 宋体、黑体、楷体、仿宋
  // 也可以单独指定：font: (serif: "SimSun", sans: "SimHei", kai: "KaiTi")
  ```)
+ *文件编码不是 UTF-8*：Typst 只读取 UTF-8 文件，大多数编辑器默认如此；
+ *字体放在项目目录中*：用 `typst compile --font-path fonts exam.typ` 让 Typst 找到它们。

=== Q4：为什么 LaTeX 版必须用 XeLaTeX？Typst 版需要什么？

LaTeX 版依赖 XeLaTeX 处理中文和系统字体。Typst 原生支持 Unicode 和 OpenType 字体，只有一种编译器，没有引擎可选：安装 Typst 0.15 或更新版本即可。

=== Q5：如何在线使用？

LaTeX 版在 Overleaf 上需要额外加 `\let\stop\empty`。Typst 版在 #link("https://typst.app")[typst.app] 中新建项目，写上 `#import "@preview/exam-zh-next:0.1.0": *` 即可，不需要任何额外设置。

=== Q6：Typst 版本过旧编译失败怎么办？

*错误现象：*提示某个函数或参数不存在，或要求更新编译器。

*解决方案：*升级 Typst（`typst update`，或用安装时的包管理器升级）；typst.app 和 Tinymist 会自动使用新版本。

=== Q7：编译时提示 “did not converge”

LaTeX 版的 latexmk 可能陷入无限循环。Typst 在一次编译中最多迭代五次来确定页码和答案位置，无法确定时给出 `document did not converge` 警告，不会无限编译。如果在使用模板时遇到这个警告，请把最小示例提交到项目 Issues。

=== Q8：试卷合集里不想显示 `chapter` 标题怎么办？

#code-only(```typ
#show: exam.with(page: (show-chapter: false))
```)

这样 `chapter` 仍然会用于分隔试卷、重置题号并进入目录，但不会排出试卷合集的大标题。

=== Q9：choices 排版异常怎么办？

Typst 版的 `choices` 按所在位置的实际宽度计算列数，在列表、窄栏、图文并排中都能使用。结果不理想时：
+ 手动指定列数：`#choices(columns: 1)[...]`；
+ 调整最多列数：`choices: (max-columns: 2)`；
+ 选项内容中的长公式可以用 `linebreak()` 手动换行。

== 功能使用问题

=== Q10：如何控制选项列数？

*自动模式（推荐）：*选项会根据内容长度自动排列，无需手动设置。

*手动指定：*`#exam-setup(choices: (columns: 2))` 强制所有选项排成 2 列；`#choices(columns: 4)[...]` 只对这一题设置。

=== Q11：如何生成教师版和学生版？

#code-only(spec: doc-config.typst, ```sh
typst compile exam.typ                                            # 学生版
typst compile --input exam-mode=teacher exam.typ exam-teacher.pdf # 教师版
```)

也可以在源码中写 `#show: exam.with(mode: "teacher")`。教师版的具体设置见第 4 章“答案控制方案”。

=== Q12：填空题下划线长度如何调整？

#demo(```typ
#exam-setup(fillin: (no-answer-type: "none", width: 4em))   // 全局：默认宽度 4em
#fillin(width: 6em)[答案]                                   // 单独：这个填空宽度是 6em
#fillin(width: auto)[山重水复疑无路]                        // 按答案长度留空
#fillin(width: auto, width-extra: 2em)[柳暗花明又一村]       // 再多留 2em
```)

`width` 在学生版留空白（`no-answer-type: "none"`）时生效；`width: auto` 测量已输入答案的自然宽度，没有答案时仍使用 3em。

=== Q13：如何修改密封线样式？

#code-only(```typ
#show: exam.with(
  sealline: (
    enable: true,
    scope: "firstpage",           // 只在第一页显示
    line-thickness: 1pt,          // 线条粗细
    line-type: "solid",           // 线型
    text: "密封线内不要答题",      // 文字内容
  ),
)
```)

不需要密封线时删去 `sealline` 或写 `enable: false`。详细说明见 API 对照手册。

=== Q14：分值不显示怎么办？

*问题：*写了 `points: 10` 但看不到分值。

*原因：*`question` 的分值默认不显示（`show-points: auto` 只显示 `problem` 的分值）。

#demo(```typ
#exam-setup(question: (show-points: true))   // 显示分值
#question(points: 10)[题目……]
```)

=== Q15：如何实现答案后置/集中显示？

*需求：*希望选择题答案 `paren` 和填空题答案 `fillin` 像解答题一样，集中显示在试卷末尾。

*当前状态：*与 LaTeX 版相同，目前只有 `solution` 支持 `"show-move"`；`paren` 与 `fillin` 的答案不能自动收集到文末。

*临时解决方案：*把选择题和填空题的答案写进 `solution`，再用 `"show-move"` 集中显示：

#demo(setup: (solution: (show-solution: "show-move")), ```typ
#question[
  $1 + 1 = $ #paren[C]
  #choices[$0$][$1$][$2$][$3$]
  #solution[C]
]
```)

（上例把解答移到了本文档的最后一页。）

== 排版问题

=== Q16：题号对齐与样式

*做法：*用 `question: (label: ..)` 修改题号格式，用 `label-width`、`label-align` 调整题号位的宽度与对齐：

#demo(```typ
#exam-setup(question: (label: "(1)", label-align: left, label-width: 2em))
#question[题号左对齐，题号位宽 2em]
#question[第二题]
```)

题号比 `label-width` 宽时（例如“第 10 题”），题号位会自动加宽，不会重叠。

=== Q17：填空题下划线超出页面边界

+ *显示长答案时直接使用 `fillin`*：答案超过一行时自动换行；
+ *手动控制占位宽度*：`#fillin(width: 5em)[答案]`；
+ *比一行还宽的空白*：`#fillin(width: 120%)[长答案]` 或 `breakable: true` 会自动换行，`width-type: "fill"` 让最后一行延伸到行末。

#demo(```typ
#exam-setup(fillin: (no-answer-type: "none"))
测试 #fillin(width: 120%)[长答案] 测试

测试 #fillin(width: 120%, width-type: "fill")[长答案] 测试
```)

=== Q18：填空题答案中使用区间符号 \[2,3)

LaTeX 版中 `\fillin[[2,3)]` 会报错。Typst 版中数学公式里的方括号可以直接写：

#demo(```typ
答案是 #fillin(show-answer: true)[$[2, 3)$]
```)

=== Q19：图文绕排

LaTeX 版的 wrapstuff 在复杂环境中容易出错。Typst 目前不支持文字绕排图片；需要真正的绕排时，可以使用 #link("https://typst.app/universe/package/meander")[meander] 或 #link("https://typst.app/universe/package/wrap-it")[wrap-it] 包。图片与文字左右并排用 `textfigure`，在列表中也能使用：

#demo(```typ
#problem[
  + 第一问
    + 小问 (a)
      #textfigure(fig-pos: "right")[小问的文字……][#image("../examples/assets/example-image.svg", width: 2cm)]
]
```)

=== Q20：自动换页后行距变大

LaTeX 会拉伸页面上的垂直间距使页面底部对齐，所以偶尔出现行距变大。Typst 不拉伸垂直间距，不会出现这个现象；需要把内容推到页面底部时写 `#v(1fr)`。

=== Q21：如何整体缩小行距以节约纸张？

#code-only(```typ
#show: exam.with(
  style: (par-leading: 0.7em, par-spacing: 0.5em),   // 行距与段落间距
  question: (top-sep: 0.2em, bottom-sep: 0.2em),     // 题目间距
  choices: (linesep: 0.3em, column-sep: 0.8em),      // 选项间距
)
```)

*注意：*行距过小可能影响阅读体验。

=== Q22：选项自动换行出问题

+ 精简选项文字；
+ 手动设置为单列：`#choices(columns: 1)[...]`；
+ 使用 `#linebreak()` 手动换行。

=== Q23：数学公式显示异常

+ *公式不显示*：检查是否用 `$` 包裹公式；
+ *公式中的中文*：用引号包裹：`$x > 0 "时"$`；
+ *分数*：直接写 `$1/2$`，或 `$(a + b)/(c + d)$`；需要行间大小的分数用 `display`：`$display(1/2)$`，或开启 `style: (display-math: true)`。

#demo(```typ
$x > 0 "时"$，$1/2$，$(a + b)/(c + d)$，$display(1/2)$
```)

=== Q24：Ω 或 ∅ 等数学符号

Typst 中直接写符号名：`$Omega$`、`$emptyset$`。教材写法的符号在 `symbols` 模块中，`#import symbols: *` 后可用 `varnothing` 等；也可以换数学字体：`font: (math: "STIX Two Math")`。

#demo(```typ
$Omega$，$emptyset$，$alpha + beta$
```)

=== Q25：概率统计中的波浪号

Typst 数学公式中 `~` 就是相似号，也可以写 `tilde.op`；教材中的相似三角形符号 ∽ 在 `symbols` 模块中：

#demo(```typ
$X ~ N(0, 1)$，$X tilde.op N(0, 1)$
```)

=== Q26：向量箭头样式

`vect` 对单个字母加粗、多个字母加箭头。需要其他样式时，直接用 Typst 的 `arrow`、`harpoon` 等，或者自己定义函数：

#demo(```typ
$vect(a)$，$vect(A B)$，$arrow(a)$，$harpoon(A B)$
#let vec2(x) = math.accent(x, math.arrow)
$vec2(v)$
```)

=== Q27：在题目中写代码

Typst 的代码写在反引号中，在题干和选项中都可以直接使用：

#demo(````typ
#question[
  以下代码的输出是：#paren[B]
  ```python
  print("Hello")
  ```
  #choices[`hello`][`Hello`][`"Hello"`][报错]
]
````)

=== Q28：如何切换西文或数学字体？

#code-only(```typ
#show: exam.with(
  font: (latin: "Times New Roman", math: "STIX Two Math"),
)
```)

中文字体用 `preset`，或单独设置 `serif`、`sans`、`kai`、`fangsong`，见 Q3。

=== Q29：如何插入图片？

#demo(```typ
#question[
  如图所示，计算三角形面积。
  #align(center, image("../examples/assets/example-image.svg", width: 4cm))
]
```)

图片路径相对于当前文件；图文并排见第 4 章“图文混排详解”。

=== Q30：如何调整页边距？

#code-only(```typ
#show: exam.with(
  page: (margin: (top: 2.5cm, bottom: 2cm, left: 2cm, right: 2cm)),
)
```)

纸张预设见第 4 章“纸张大小”。

== 获取帮助

=== 查阅文档

+ *本文档*：`guide.typ`（入门指南）；
+ *API 对照手册*：`reference.typ`（LaTeX 版每个命令和键值的 Typst 写法）；
+ *Typst 入门*：#link("https://typst.app/docs/tutorial")[Typst 官方教程]、#link("https://typst-doc-cn.github.io/docs/")[Typst 中文文档]。

=== 提问前的准备

为了快速得到帮助，提问时请提供：
+ *系统信息*：操作系统、Typst 版本（`typst --version`）；
+ *问题描述*：清楚描述遇到的问题；
+ *最小可复现示例*：能重现问题的最简代码；
+ *错误信息*：完整的错误提示（请复制文字，勿用手机拍照）；
+ *期望结果*：你想要达到的效果。

= 已知问题与限制

本章列出 Typst 版目前的限制和使用边界，并与 LaTeX 版逐项对照。

== 项目状态

LaTeX 版 exam-zh 自 2024 年 4 月 26 日起停止维护。Typst 版是独立的新实现，沿用 exam-zh 的设计、选项和示例。

== 编译环境

- *Typst 0.15 或更新版本*：没有其他引擎可选，也不需要 TeX 发行版；
- *中文字体*：默认使用 Noto CJK 字体，其他字体见第 6 章 Q3。

== 图文排版边界

=== 优先使用模板自带的图文命令

- 一段文字配一张图，用 `textfigure`；
- 多张题图并排，用 `multifigures`；
- 只需要简单插图时，直接用 `image`。

=== 文字绕排

Typst 目前不支持文字绕排图片，模板也不提供绕排命令（LaTeX 版借助 wrapstuff 实现）。需要时可以使用 meander 或 wrap-it 包。

== 填空题边界

=== 长答案会自动换行

显示答案且内容超过一行时自动换行；`breakable: true` 无论长短都采用可换行排版。

=== 方括号不需要保护

LaTeX 版需要写 `\fillin[{$[2,3)$}]`；Typst 版直接写 `#fillin[$[2, 3)$]`。

=== 数学答案仍然要自己进入数学模式

`fillin` 不会自动把答案切换成数学模式，数学内容仍需写成 `#fillin[$x^2 + 1$]`。

== 当前不支持的功能

=== 选择题和填空题答案自动后置

与 LaTeX 版相同，只有 `solution` 支持 `"show-move"`。`paren` 与 `fillin` 的答案不能自动收集到文末（变通方法见 Q15）。

=== 演示文稿

本模板用于排版试卷，不是幻灯片模板。

== 页面设置边界

- 纸张预设有 `"a4"`、`"a3"`，也可以给出任意 `(宽, 高)`；
- 页边距直接写在 `page: (margin: ..)` 中，不需要 LaTeX 版的 `\AtEndPreamble`；
- Typst 不拉伸页面的垂直间距，页面底部可能留白；需要时用 `#v(1fr)` 或 `#pagebreak()` 调整。

#set heading(numbering: none)
= 进阶学习指引

== 《exam-zh-next API 对照手册》导航

《API 对照手册》（`reference.typ`）按 LaTeX 版完整文档 `exam-zh-doc.pdf` 第 3 章“使用说明”的顺序排列：
- *命令和环境介绍*：每个 LaTeX 命令和环境对应的 Typst 函数，附原文档的全部示例；
- *参数设置*：每个 `\examsetup` 键对应的 Typst 选项，附原文档的全部示例；
- 每条都同时给出 LaTeX 写法、Typst 写法和 Typst 效果。

*查阅建议：*知道 LaTeX 写法时，在对照手册中搜索它（如 `fillin/width`）；全部选项与默认值也在对照手册的最后一章。

== 高级功能列表

本入门指南未详细介绍、对照手册中有说明的功能：

- *高级题型*：选择标记题（`select`）、连线题（`lineto`）、计算题排版（`calculations`）；
- *高级排版*：图文混排（`textfigure`、`multifigures`）、试卷合集（`chapter`、`exam-outline`）、自定义题号样式、密封线详细配置；
- *字体和样式*：中文字体预设、西文与数学字体、教材写法的数学符号（`symbols`）。

== Typst 进阶学习

- #link("https://typst.app/docs")[Typst 官方文档] 与 #link("https://typst-doc-cn.github.io/docs/")[中文文档]；
- #link("https://forum.typst.app")[Typst 论坛]：搜索问题通常能找到答案；
- #link("https://typst.app/universe")[Typst Universe]：查找其他包，例如表格、绘图、化学式。

对于制作试卷，建议重点学习：数学公式、表格（`table`）、图片（`image`）和绘图（`cetz` 包）。

== 参与项目

欢迎在项目仓库提交问题和建议。
