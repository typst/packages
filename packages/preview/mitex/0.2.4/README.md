# [MiTeX](https://github.com/mitex-rs/mitex)

**[LaTeX](https://www.latex-project.org/) support for [Typst](https://typst.app/), powered by [Rust](https://www.rust-lang.org/) and [WASM](https://webassembly.org/).**

[MiTeX](https://github.com/mitex-rs/mitex) processes LaTeX code into an abstract syntax tree (AST). Then it transforms the AST into Typst code and evaluates code into Typst content by `eval` function.

MiTeX has been proved to be practical on a large project. It has already correctly converted 32.5k equations from [OI Wiki](https://github.com/OI-wiki/OI-wiki). Compared to [texmath](https://github.com/jgm/texmath), MiTeX has a better display effect and performance in that wiki project. It is also more easy to use, since importing MiTeX to Typst is just one line of code, while texmath is an external program.

In addition, MiTeX is not only **SMALL** but also **FAST**! MiTeX has a size of just about 185 KB, comparing that texmath has a size of 17 MB. A not strict but intuitive comparison is shown below. To convert 32.5k equations from OI Wiki, texmath takes about 109s, while MiTeX WASM takes only 2.28s and MiTeX x86 takes merely 0.085s.

Thanks to [@Myriad-Dreamin](https://github.com/Myriad-Dreamin), he completed the most complex development work: developing the parser for generating AST.

## MiTeX as a Typst Package

- Use `mitex-convert` to convert LaTeX code into Typst code in string.
- Use `mi` to render an inline LaTeX equation in Typst.
- Use `mitex(numbering: none, supplement: auto, ..)` or `mimath` to render a block LaTeX equation in Typst.
- Use `mitext` to render a LaTeX text in Typst.

PS: `#set math.equation(numbering: "(1)")` is also valid for MiTeX.

Following is [a simple example](https://github.com/mitex-rs/mitex/blob/main/packages/mitex/examples/example.typ) of using MiTeX in Typst:

```typst
#import "@preview/mitex:0.2.4": *

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
```

![example](examples/example.png)

## MiTeX as a CLI Tool

### Installation

Install latest nightly version by `cargo install --git https://github.com/mitex-rs/mitex mitex-cli`.

### Usage

```bash
mitex compile main.tex
# or (same as above)
mitex compile main.tex mitex.typ
```

## MiTeX as a Web App

### MiTeX Online Math Converter

We can convert LaTeX equations to Typst equations in web by wasm. https://mitex-rs.github.io/mitex/

### Underleaf

We made a proof of concept online tex editor to show our conversion speed in text mode. The PoC loads files from a git repository and then runs typst compile in browser. As you see, each keystroking get response in preview quickly.

https://mitex-rs.github.io/mitex/tools/underleaf.html

https://github.com/mitex-rs/mitex/assets/34951714/0ce77a2c-0a7d-445f-b26d-e139f3038f83

## Implemented Features

- [x] User-defined TeX (macro) commands, such as `\newcommand{\mysym}{\alpha}`.
- [x] LaTeX equations support.
  - [x] Coloring commands (`\color{red} text`, `\textcolor{red}{text}`).
  - [x] Support for various environments, such as aligned, matrix, cases.
- [x] Basic text mode support, you can use it to write LaTeX drafts.
  - [x] `\section`, `\textbf`, `\emph`.
  - [x] Inline and block math equations.
  - [x] `\ref`, `\eqref` and `\label`.
  - [x] `itemize` and `enumerate` environments.

## Features to Implement

- [ ] Pass command specification to MiTeX plugin dynamically. With that you can define a typst function `let myop(it) = op(upright(it))` and then use it by `\myop{it}`.
- [ ] Package support, which means that you can change set of commands by telling MiTeX to use a list of packages.
- [ ] Better text mode support, such as figure, algorithm and description environments.

To achieve the latter two goals, we need a well-structured architecture for the text mode, along with intricate work. Currently, we don't have very clear ideas yet. If you are willing to contribute by discussing in the issues or even submitting pull requests, your contribution is highly welcome.

## Differences between MiTeX and other solutions

MiTeX has different objectives compared to [texmath](https://github.com/jgm/texmath) (a.k.a. [pandoc](https://pandoc.org/)):

- MiTeX focuses on rendering LaTeX content correctly within Typst, leveraging the powerful programming capabilities of WASM and typst to achieve results that are essentially consistent with LaTeX display.
- texmath aims to be general-purpose converters and generate strings that are more human-readable.

For example, MiTeX transforms `\frac{1}{2}_3` into `frac(1, 2)_3`, while texmath converts it into `1 / 2_3`. The latter's display is not entirely correct, whereas the former ensures consistency in display.

Another example is that MiTeX transforms `(\frac{1}{2})` into `\(frac(1, 2)\)` instead of `(frac(1, 2))`, avoiding the use of automatic Left/Right to achieve consistency with LaTeX rendering.

**Certainly, the greatest advantage is that you can directly write LaTeX content in Typst without the need for manual conversion!**

## Submitting Issues

If you find missing commands or bugs of MiTeX, please feel free to submit an issue [here](https://github.com/mitex-rs/mitex/issues).

## Contributing to MiTeX

Currently, MiTeX maintains following three parts of code:

- A TeX parser library written in **Rust**, see [mitex-lexer](https://github.com/mitex-rs/mitex/tree/main/crates/mitex-lexer) and [mitex-parser](https://github.com/mitex-rs/mitex/tree/main/crates/mitex-parser).
- A TeX to Typst converter library written in **Rust**, see [mitex](https://github.com/mitex-rs/mitex/tree/main/crates/mitex).
- A list of TeX packages and comamnds written in **Typst**, which then used by the typst package, see [MiTeX Command Specification](https://github.com/mitex-rs/mitex/tree/main/packages/mitex/specs).

For a translation process, for example, we have:

```
\frac{1}{2}

===[parser]===> AST ===[converter]===>

#eval("$frac(1, 2)$", scope: (frac: (num, den) => $(num)/(den)$))
```

You can use the `#mitex-convert()` function to get the Typst Code generated from LaTeX Code.

### Add missing TeX commands

Even if you don't know Rust at all, you can still add missing TeX commands to MiTeX by modifying [specification files](https://github.com/mitex-rs/mitex/tree/main/packages/mitex/specs), since they are written in typst! You can open an issue to acquire the commands you want to add, or you can edit the files and submit a pull request.

In the future, we will provide the ability to customize TeX commands, which will make it easier for you to use the commands you create for yourself.

### Develop the parser and the converter

See [CONTRIBUTING.md](https://github.com/mitex-rs/mitex/blob/main/CONTRIBUTING.md).
