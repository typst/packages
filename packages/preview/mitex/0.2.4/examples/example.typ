#import "../lib.typ": *

#set page(width: 500pt, height: auto, margin: 1em)

#assert.eq(mitex-convert("\alpha x"), "alpha  x ")

Write inline equations like #mi("x") or #mi[y].

Also block equations (this case is from #text(blue.lighten(20%), link("https://katex.org/")[katex.org])):

#mitex(`
  \newcommand{\f}[2]{#1f(#2)}
  \f\relax{x} = \int_{-\infty}^\infty
    \f\hat\xi\,e^{2 \pi i \xi x}
    \,d\xi
`)

We also support text mode (in development):

#mitext(`
  \iftypst
    #set math.equation(numbering: "(1)", supplement: "Equation")
  \fi

  \section{Title}

  A \textbf{strong} text, a \emph{emph} text and inline equation $x + y$.
  
  Also block \eqref{eq:pythagoras} and \ref{tab:example}.

  \begin{equation}
    a^2 + b^2 = c^2 \label{eq:pythagoras}
  \end{equation}

  \begin{table}[ht]
      \centering
      \begin{tabular}{|c|c|}
          \hline
          \textbf{Name} & \textbf{Age} \\
          \hline
          John & 25 \\
          Jane & 22 \\
          \hline
      \end{tabular}
      \caption{This is an example table.}
      \label{tab:example}
  \end{table}
`)
