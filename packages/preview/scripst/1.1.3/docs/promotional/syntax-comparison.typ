#import "@preview/scripst:1.1.3": *

#show: scripst.with(
  template: "article",
  title: none,
  header: false,
  lang: "zh",
  font-size: 10pt,
  par-indent: 0em,
  par-spacing: 1em,
  counter-depth: 2,
  matheq-depth: 2,
  cb-counter-depth: 2,
  matheq-outline: "(1.1)",
  counter-outline: "1.1",
)

#set page(
  width: 180mm,
  height: 240mm,
  margin: (x: 11mm, y: 10mm),
  fill: luma(248),
  numbering: none,
)
#show raw: set text(size: 8pt)
// #show raw.where(block: true): set par(leading: 0.18em)

#let muted = rgb("#6D7471")

#let page-title(number, title, subtitle) = [
  #grid(
    columns: (1fr, auto),
    align: (left, top),
    [#text(font: font.header, size: 7pt, weight: "bold", fill: mycolor.blue)[ONE NOTE, THREE AUTHORING SYSTEMS]],
    [#text(font: "New Computer Modern", size: 8pt, fill: muted)[#number / 04]],
  )
  #v(-10pt)
  #text(font: font.heading, size: 19pt, weight: "bold")[#title]
  #v(-10pt)
  #text(size: 8pt, fill: muted)[#subtitle]
]

#let markdown-code = (
  ```markdown
   # 量子态与测量

  考虑二能级系统：
  - $|0\rangle,|1\rangle$ 构成正交归一基；
  - $|\psi\rangle=\frac{|0\rangle+i|1\rangle}{\sqrt2}$。

   ## 定义 1.1（态展开）
  $$
  |\psi(t)\rangle=\sum_n c_n(t)|n\rangle
  $$
  $$
  i\hbar\frac{\partial}{\partial t}|\psi(t)\rangle
  =\hat H|\psi(t)\rangle
  $$
  可观测量 $\hat A$ 的期望值为
  $$
  \langle\psi|\hat A|\psi\rangle
  =\int\psi^\*(x)\hat A\psi(x)\,\mathrm{d}x
  $$

  ```,
  ```markdown
   ## 定理 1.1（归一化守恒）
  若 $\hat H=\hat H^\dagger$，则
  $\sum_n|c_n(t)|^2=1$ 对任意 $t$ 成立。

  > **证明.** 对定义 1.1 求时间导数，
  > 并利用 Hamilton 算符的厄米性即可。

   ## 习题 1.1
  测量态 $|\psi\rangle
  =\frac{|0\rangle+i|1\rangle}{\sqrt2}$，
  求得到两个基态的概率。

  **解答.**
  $P(0)=|\langle0|\psi\rangle|^2=\frac12$，
  $P(1)=|\langle1|\psi\rangle|^2=\frac12$。

  | 测量态 | 概率振幅 | 测量概率 |
  |---|---:|---:|
  | $|0\rangle$ | $\langle0|\psi\rangle=1/\sqrt2$ | $1/2$ |
  | $|1\rangle$ | $\langle1|\psi\rangle=i/\sqrt2$ | $1/2$ |

  **表 1.1　二能级系统的测量结果**
  ```,
)

#let latex-code = (
  ```latex
  \usepackage{amsmath,amsthm,braket,booktabs}

  \section{量子态与测量}
  考虑二能级系统：
  \begin{itemize}
    \item $\ket{0},\ket{1}$ 构成正交归一基；
    \item $\ket{\psi}
      =\frac{\ket{0}+i\ket{1}}{\sqrt{2}}$。
  \end{itemize}

  \begin{definition}[态展开]\label{def:state}
    \[
      \ket{\psi(t)}=\sum_n c_n(t)\ket{n}
    \]
    \[
      i\hbar\frac{\partial}{\partial t}\ket{\psi(t)}
      =\hat H\ket{\psi(t)}
    \]
    可观测量 $\hat A$ 的期望值为
    \[
      \bra{\psi}\hat A\ket{\psi}
      =\int\psi^*(x)\hat A\psi(x)\,\mathrm{d}x
    \]
  \end{definition}

  ```,
  ```latex
  \begin{theorem}[归一化守恒]\label{thm:norm}
    若 $\hat H=\hat H^\dagger$，则
    $\sum_n|c_n(t)|^2=1$ 对任意 $t$ 成立。
  \end{theorem}
  \begin{proof}
    对定义~\ref{def:state} 求时间导数，
    并利用 Hamilton 算符的厄米性即可。
  \end{proof}

  \begin{problem}
    测量态
    $\ket{\psi}=\frac{\ket{0}+i\ket{1}}{\sqrt{2}}$，
    求得到两个基态的概率。
  \end{problem}
  \begin{solution}
    $P(0)=|\braket{0|\psi}|^2=\frac{1}{2}$，
    $P(1)=|\braket{1|\psi}|^2=\frac{1}{2}$。
  \end{solution}

  \begin{table}
    \centering
    \begin{tabular}{ccc}
      \toprule
      测量态 & 概率振幅 & 测量概率 \\
      \midrule
      $\ket{0}$ & $\braket{0|\psi}=1/\sqrt2$ & $1/2$ \\
      $\ket{1}$ & $\braket{1|\psi}=i/\sqrt2$ & $1/2$ \\
      \bottomrule
    \end{tabular}
    \caption{二能级系统的测量结果}
  \end{table}
  ```,
)

#let typst-code = (
  ```typst
  = 量子态与测量

  考虑二能级系统：

  - $ket(0), ket(1)$ 构成正交归一基；
  - $ket(Psi) = (ket(0) + i ket(1))/sqrt(2)$。

  #definition(subname: [态展开], lab: "def:state")[
    $
      ket(Psi(t)) = sum_n c_n (t) ket(n)
    $
    $
      i hbar dv(, t) ket(Psi(t)) = hat(H) ket(Psi(t))
    $
    可观测量 $hat(A)$ 的期望值为
    $
      braket(Psi, hat(A), Psi)
        = integral Psi^*(x) hat(A) Psi(x) dif x
    $
  ]

  ```,
  ```typst
  #theorem(subname: [归一化守恒], lab: "thm:norm")[
    若 $hat(H) = hat(H)^dagger$，则
    $sum_n abs(c_n (t))^2 = 1$ 对任意 $t$ 成立。
  ]

  #proof[
    对 @def:state 求时间导数，
    并利用 Hamilton 算符的厄米性即可。
  ]

  #problem(lab: "prob:measure")[
    测量态 $ket(Psi) = (ket(0) + i ket(1))/sqrt(2)$，
    求得到两个基态的概率。
  ]

  #solution[
    $P(0) = abs(braket(0, Psi))^2 = 1/2$，
    $P(1) = abs(braket(1, Psi))^2 = 1/2$。
  ]

  #figure(
    three-line-table[
      | 测量态 | 概率振幅 | 测量概率 |
      | $ket(0)$ | $braket(0, Psi) = 1/sqrt(2)$ | $1/2$ |
      | $ket(1)$ | $braket(1, Psi) = i/sqrt(2)$ | $1/2$ |
    ],
    caption: [二能级系统的测量结果],
  )
  ```,
)

#let code-page(number, title, subtitle, code, note-title, note-body) = [
  #page-title(number, title, subtitle)
  #v(2mm)
  #grid(
    columns: (1fr, 1fr),
    gutter: 4mm,
    code.at(0), code.at(1),
  )
  #v(2mm)
  #note(count: false, subname: note-title)[#note-body]
]

#code-page(
  [01],
  [Markdown],
  [语言轻量，但 ket、bra、积分等数学仍需嵌入 TeX；复杂结构与编号系统需要手工维护。],
  markdown-code,
  [需要手工维护],
  [标题、itemize 和普通表格足够直接；块样式、三线表、编号、重置和交叉引用则需要作者自己保持一致。并且渲染表现单一。],
)

#pagebreak()

#code-page(
  [02],
  [LaTeX],
  [能力完整，但 itemize、定理环境、ket/bra 与三线表分别需要显式命令或宏包。],
  latex-code,
  [样板代码],
  [语义明确、控制精细；相应地也要维护环境声明、标签、引用、宏包和编译流程。全篇充满反斜杠，阅读困难；编译缓慢，尤其是Windows上的大文件编译速度堪忧。],
)

#pagebreak()

#code-page(
  [03],
  [Typst + Scripst],
  [列表、物理符号与公式保持短语法；countblock 和三线表直接使用预设。],
  typst-code,
  [Scripst + Ratchet],
  [Scripst 集成 Physica、Tablem 与内容块预设，Ratchet 统一维护编号深度、重置与引用。],
)

#pagebreak()

#page-title(
  [04],
  [真实的 Scripst 输出],
  [以下不是仿制的示意框：物理符号、三线表与全部内容块均由当前 Scripst 直接生成。],
)

#v(-2em)

#heading(level: 1, numbering: none)[量子态与测量]

考虑二能级系统：

- $ket(0), ket(1)$ 构成正交归一基；
- $ket(Psi) = (ket(0) + i ket(1))/sqrt(2)$。

#definition(subname: [态展开], lab: "def:state")[
  $
    ket(Psi(t)) = sum_n c_n (t) ket(n)
  $
  并满足
  $
    i hbar dv(, t) ket(Psi(t)) = hat(H) ket(Psi(t))
  $
  可观测量 $hat(A)$ 的期望值为
  $
    braket(Psi, hat(A), Psi) = integral Psi^*(x) hat(A) Psi(x) dif x
  $
]

#theorem(subname: [归一化守恒], lab: "thm:norm")[
  若 $hat(H) = hat(H)^dagger$，则 $sum_n abs(c_n (t))^2 = 1$ 对任意 $t$ 成立。
]

#proof[对 @def:state 求时间导数，并利用 Hamilton 算符的厄米性即可。]

#problem(lab: "prob:measure")[
  测量态 $ket(Psi) = (ket(0) + i ket(1))/sqrt(2)$，求得到两个基态的概率。
]

#solution[
  $P(0) = abs(braket(0, Psi))^2 = 1/2$，$P(1) = abs(braket(1, Psi))^2 = 1/2$。
]

#figure(
  three-line-table[
    | 测量态 | 概率振幅 | 测量概率 |
    | $ket(0)$ | $braket(0, Psi) = 1/sqrt(2)$ | $1/2$ |
    | $ket(1)$ | $braket(1, Psi) = i/sqrt(2)$ | $1/2$ |
  ],
  caption: [二能级系统的测量结果],
)
