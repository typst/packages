#import "/lib.typ": *

#import "@preview/codly:1.0.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init
#codly(languages: codly-languages)

#set page(paper: "us-letter", margin: 0.75in)
#set par(justify: true)
#set text(size: 11pt)

= A Brief History of #TeX and its Descendants

#v(1.5em)

#columns(2)[

== The core system

#TeX (1978) forms the foundation - Donald Knuth's low-level typesetting engine
that handles the core mathematics of digital typography. Think of it as assembly
language for documents. Example:

```tex
\hbox{\bf\tenpoint Introduction}
\vskip 12pt
```

== Introducing usability

#LaTeX (1984) is Leslie Lamport's layer over #TeX that introduces logical
markup, making document creation more intuitive:

```latex
\section{Introduction}
```

== Standardization and packages

#LaTeX2E (1994) standardized #LaTeX, adding robust package management and fixing
incompatibilities between different #LaTeX styles.

== PDF integration

#pdfTeX (1996) added direct PDF output, with font embedding, microtypography
  features like margin kerning and font expansion, and PDF-specific features
  like hyperlinks and tables of contents. It became the default #TeX engine for
  most #LaTeX installations:

```tex
\pdfoutput=1
\pdfcompresslevel=0
\pdfobjcompresslevel=0
\pdfmapline{ptmr8r Times-Roman 2 <8r.enc}
\font\tenrm=ptmr8r
\tenrm
Welcome to pdf\TeX!
\end
```

== Modern fonts and scripting

Two modern branches evolved to handle Unicode and modern fonts:

#XeTeX (2004): A #TeX engine supporting Unicode and modern fonts.
#XeLaTeX enables commands like:

```latex
\usepackage{fontspec}
\setmainfont{Helvetica Neue}
```

#LuaTeX (2007): #TeX engine with embedded Lua scripting.
#LuaLaTeX allows direct programming:

```latex
\directlua{
  local x = 1 + 1
  tex.print(x)
}
```

== Typical use

Modern workflows typically use #XeLaTeX for straightforward Unicode documents
  and #LuaLaTeX when document generation requires programming logic. Both are
  vast improvements over the original #TeX:

Original #TeX:

```tex
\font\x="Times New Roman" at 12pt
\x Hello, 世界
```

#XeLaTeX/#LuaLaTeX:

```latex
\documentclass{article}
\usepackage{fontspec}
\setmainfont{Times New Roman}
\begin{document}
Hello, 世界
\end{document}
```

== The Modern alternative: Typst

Typst (2023) is a modern competitor to the #TeX family, designed from scratch
with a focus on speed and intuitive syntax:

```typst
= Fibonacci sequence
The Fibonacci sequence is defined by
$F_n = F_(n-1) + F_(n-2)$.

#let fib(n) = (
  if n <= 2 { 1 }
  else { fib(n - 1) + fib(n - 2) }
)

The 8th Fibonacci number is #fib(8).
```
]
