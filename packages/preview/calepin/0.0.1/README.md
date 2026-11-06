# Calepin

Website: <https://vincentarelbundock.github.io/calepin>

Computational notebooks mix narrative text with executable code. Figures, tables, and numbers are computed when the document is rendered, rather than pasted in by hand. This helps analysts write reproducible reports in the tradition of literate programming.

Calepin brings computational notebooks to Typst. It lets you write prose, code chunks, inline computations, figures, tables, and computed values in a single `.typ` source file, then render the document to PDF, HTML, or other Typst-supported formats. Calepin supports Python, R, shell commands, many languages through Jupyter kernels, and diagram tools such as Mermaid, Graphviz, TikZ, and D2.

Typst intentionally sandboxes package and document code. That sandboxing is an important safety feature, but it also means Typst packages cannot run Python, R, shell commands, or other external programs by themselves. Calepin therefore requires an external command-line tool, `calepin`, to execute code chunks through external commands and render their results.

Without this package, a `.typ` file containing `calepin.chunk()` or `calepin.inline()` calls would be difficult to compile with plain `typst`, because those calls normally depend on Calepin's generated runtime. This package provides a stable Typst import so computational notebooks can be compiled with either `typst` or `calepin` without an import error.

When the external Calepin tool is not available and the document is compiled directly with `typst`, code is printed nicely and left unevaluated. The output document also includes a visible warning explaining that chunks were not executed and linking to the Calepin documentation.

Use this package in Typst sources as:

```typst
#import "@preview/calepin:0.0.1" as calepin
```

To suppress the visible warning when compiling directly with `typst`, set:

```typst
#calepin.setup(fallback-warning: false)
```

To execute chunks and render results, compile with the Calepin CLI:

```sh
calepin compile paper.typ
```
