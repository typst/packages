#import "@preview/scripst:1.1.3": *

#show: scripst.with(
  template: "article",
  title: none,
  header: false,
  lang: "en",
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
  # Quantum States and Measurement

  Consider a two-level system:
  - $|0\rangle,|1\rangle$ form an orthonormal basis;
  - $|\psi\rangle=\frac{|0\rangle+i|1\rangle}{\sqrt2}$.

  ## Definition 1.1 (State expansion)
  $$
  |\psi(t)\rangle=\sum_n c_n(t)|n\rangle
  $$
  $$
  i\hbar\frac{\partial}{\partial t}|\psi(t)\rangle
  =\hat H|\psi(t)\rangle
  $$
  The expectation value of $\hat A$ is
  $$
  \langle\psi|\hat A|\psi\rangle
  =\int\psi^\*(x)\hat A\psi(x)\,\mathrm{d}x
  $$

  ```,
  ```markdown
  ## Theorem 1.1 (Normalization)
  If $\hat H=\hat H^\dagger$, then
  $\sum_n|c_n(t)|^2=1$ for every $t$.

  > **Proof.** Differentiate Definition 1.1
  > and use the Hermiticity of the Hamiltonian.

  ## Problem 1.1
  Measure
  $|\psi\rangle=\frac{|0\rangle+i|1\rangle}{\sqrt2}$.
  Find the probabilities of the two basis states.

  **Solution.**
  $P(0)=|\langle0|\psi\rangle|^2=\frac12$,
  $P(1)=|\langle1|\psi\rangle|^2=\frac12$.

  | State | Amplitude | Probability |
  |---|---:|---:|
  | $|0\rangle$ | $\langle0|\psi\rangle=1/\sqrt2$ | $1/2$ |
  | $|1\rangle$ | $\langle1|\psi\rangle=i/\sqrt2$ | $1/2$ |

  **Table 1.1  Measurement outcomes**
  ```,
)

#let latex-code = (
  ```latex
  \usepackage{amsmath,amsthm,braket,booktabs}

  \section{Quantum States and Measurement}
  Consider a two-level system:
  \begin{itemize}
    \item $\ket{0},\ket{1}$ form an orthonormal basis;
    \item $\ket{\psi}
      =\frac{\ket{0}+i\ket{1}}{\sqrt{2}}$.
  \end{itemize}

  \begin{definition}[State expansion]\label{def:state}
    \[
      \ket{\psi(t)}=\sum_n c_n(t)\ket{n}
    \]
    \[
      i\hbar\frac{\partial}{\partial t}\ket{\psi(t)}
      =\hat H\ket{\psi(t)}
    \]
    The expectation value of $\hat A$ is
    \[
      \bra{\psi}\hat A\ket{\psi}
      =\int\psi^*(x)\hat A\psi(x)\,\mathrm{d}x
    \]
  \end{definition}

  ```,
  ```latex
  \begin{theorem}[Normalization]\label{thm:norm}
    If $\hat H=\hat H^\dagger$, then
    $\sum_n|c_n(t)|^2=1$ for every $t$.
  \end{theorem}
  \begin{proof}
    Differentiate Definition~\ref{def:state}
    and use the Hermiticity of the Hamiltonian.
  \end{proof}

  \begin{problem}
    Measure
    $\ket{\psi}=\frac{\ket{0}+i\ket{1}}{\sqrt{2}}$.
    Find the probabilities of the two basis states.
  \end{problem}
  \begin{solution}
    $P(0)=|\braket{0|\psi}|^2=\frac{1}{2}$,
    $P(1)=|\braket{1|\psi}|^2=\frac{1}{2}$.
  \end{solution}

  \begin{table}
    \centering
    \begin{tabular}{ccc}
      \toprule
      State & Amplitude & Probability \\
      \midrule
      $\ket{0}$ & $\braket{0|\psi}=1/\sqrt2$ & $1/2$ \\
      $\ket{1}$ & $\braket{1|\psi}=i/\sqrt2$ & $1/2$ \\
      \bottomrule
    \end{tabular}
    \caption{Measurement outcomes}
  \end{table}
  ```,
)

#let typst-code = (
  ```typst
  = Quantum States and Measurement

  Consider a two-level system:

  - $ket(0), ket(1)$ form an orthonormal basis;
  - $ket(Psi) = (ket(0) + i ket(1))/sqrt(2)$.

  #definition(subname: [State expansion], lab: "def:state")[
    $
      ket(Psi(t)) = sum_n c_n (t) ket(n)
    $
    $
      i hbar dv(, t) ket(Psi(t)) = hat(H) ket(Psi(t))
    $
    The expectation value of $hat(A)$ is
    $
      braket(Psi, hat(A), Psi)
        = integral Psi^*(x) hat(A) Psi(x) dif x
    $
  ]

  ```,
  ```typst
  #theorem(subname: [Normalization], lab: "thm:norm")[
    If $hat(H) = hat(H)^dagger$, then
    $sum_n abs(c_n (t))^2 = 1$ for every $t$.
  ]

  #proof[
    Differentiate @def:state and use the
    Hermiticity of the Hamiltonian.
  ]

  #problem(lab: "prob:measure")[
    Measure $ket(Psi) = (ket(0) + i ket(1))/sqrt(2)$.
    Find the probabilities of the two basis states.
  ]

  #solution[
    $P(0) = abs(braket(0, Psi))^2 = 1/2$,
    $P(1) = abs(braket(1, Psi))^2 = 1/2$.
  ]

  #figure(
    three-line-table[
      | State | Amplitude | Probability |
      | $ket(0)$ | $braket(0, Psi) = 1/sqrt(2)$ | $1/2$ |
      | $ket(1)$ | $braket(1, Psi) = i/sqrt(2)$ | $1/2$ |
    ],
    caption: [Measurement outcomes],
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
  [Lightweight prose, but ket, bra, and integrals remain embedded TeX; complex structures and numbering stay manual.],
  markdown-code,
  [Manual maintenance],
  [Headings, itemize, and basic tables are direct; block styles, three-line tables, numbering, resets, and cross-references must be kept consistent by hand. Rendering options are limited too.],
)

#pagebreak()

#code-page(
  [02],
  [LaTeX],
  [Fully capable, but itemize, theorem blocks, ket/bra, and three-line tables require explicit commands or packages.],
  latex-code,
  [Boilerplate],
  [The semantics are precise and the controls are deep, but you also maintain environments, labels, references, packages, and the build toolchain. Backslash-heavy source is harder to scan, and large local builds can interrupt the writing flow.],
)

#pagebreak()

#code-page(
  [03],
  [Typst + Scripst],
  [Lists, physics notation, and formulas stay compact; countblocks and three-line tables use ready-made styles.],
  typst-code,
  [Scripst + Ratchet],
  [Scripst integrates Physica, Tablem, and content-block presets, while Ratchet keeps numbering depth, resets, and references consistent.],
)

#pagebreak()

#page-title(
  [04],
  [Real Scripst Output],
  [These are not imitation boxes: the physics notation, three-line table, and content blocks below are generated by Scripst itself.],
)

#v(-2em)

#heading(level: 1, numbering: none)[Quantum States and Measurement]

Consider a two-level system:

- $ket(0), ket(1)$ form an orthonormal basis;
- $ket(Psi) = (ket(0) + i ket(1))/sqrt(2)$.

#definition(subname: [State expansion], lab: "def:state")[
  $
    ket(Psi(t)) = sum_n c_n (t) ket(n)
  $
  and satisfies
  $
    i hbar dv(, t) ket(Psi(t)) = hat(H) ket(Psi(t))
  $
  The expectation value of $hat(A)$ is
  $
    braket(Psi, hat(A), Psi) = integral Psi^*(x) hat(A) Psi(x) dif x
  $
]

#theorem(subname: [Normalization], lab: "thm:norm")[
  If $hat(H) = hat(H)^dagger$, then $sum_n abs(c_n (t))^2 = 1$ for every $t$.
]

#proof[Differentiate @def:state and use the Hermiticity of the Hamiltonian.]

#problem(lab: "prob:measure")[
  Measure $ket(Psi) = (ket(0) + i ket(1))/sqrt(2)$ and find the probabilities of the two basis states.
]

#solution[
  $P(0) = abs(braket(0, Psi))^2 = 1/2$, and $P(1) = abs(braket(1, Psi))^2 = 1/2$.
]

#figure(
  three-line-table[
    | State | Amplitude | Probability |
    | $ket(0)$ | $braket(0, Psi) = 1/sqrt(2)$ | $1/2$ |
    | $ket(1)$ | $braket(1, Psi) = i/sqrt(2)$ | $1/2$ |
  ],
  caption: [Measurement outcomes],
)
