#import "@preview/mitex:0.2.5": *

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
    #set math.equation(numbering: "(1)", supplement: "equation")
  \fi

  \section{Title}

  A \textbf{strong} text, a \emph{emph} text and inline equation $x + y$.

  Also block \eqref{eq:pythagoras}.

  \begin{equation}
    a^2 + b^2 = c^2 \label{eq:pythagoras}
  \end{equation}
`)