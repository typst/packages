# A Typst template for 'acmsmall' papers

[acmart](https://github.com/borisveytsman/acmart/) is a LaTeX template used by many ACM conferences and journals. It comes in various forms, some specialized to specific ACM conferences. `acmsmall` is one configuration for single-column documents. Among others, it is used by conferences in the SIGPLAN umbrella; with the 'nonacm' class option you can also use for non-ACM-related documents.

The present repository offers a Typst template for `acmsmall`: the produced documents should look essentially the same as LaTeX documentations using `\documentclass[acmsmall]{acmart}`.

The template is only an "approximation". If you use it in your own work, you may find various things that are not rendered 'correctly' (the result differs from the LaTeX reference in ways that annoy you). In that case, please feel free to contribute improvements to this template, or at least open an issue to report this, with a minimal reproductible case (please provide both a Typst and a LaTeX version so we can compare).

Eventually the support will become good enough that finding something wrong becomes very rare.

## Example document

See [example.typ](template/example.typ) for an example of using this template. You can copy and extend it to start a new document. To compile it:

```shell
$ typst compile example.typ
```

The compilation may emit a warning with missing fonts, because Typst warns even if some later font in priority order is in fact available.

## Contributions

PRs are welcome! (Preferably human-generated, please.)

There is a simplistic testsuite in the `tests/` directory, with no machinery right now to automate the test of the results. If you improve the template for a specific aspect, please include a test that lets people observe the improvement. (My approach is to write the test first and commit it, so we see the "wrong" result, then as a second commit fix the template, so that we can see the output of the test change.)

## History

This template was first written by Michel Steuwer as part of his [typst-acmart](https://github.com/michel-steuwer/typst-acmart/) repository. The current version was substantially improved by Gabriel Scherer, who currently maintains it.

See [CHANGES.md](./CHANGES.md) for a more detailed list of changes.

## Full articles written using this style

If you write a full article using (some version of) this template, please let us know so that it can be added to this list!
(You can send the link as a PR, or just an issue, or just an email, etc.)

- [*Descend*: a Safe GPU Systems Programming Language](https://github.com/michel-steuwer/typst-acmart/blob/ac58b19873939df0beebfb2d3f788d3c3f05b7d1/sample-typst-descend-pldi.pdf) ([typ](https://github.com/michel-steuwer/typst-acmart/blob/ac58b19873939df0beebfb2d3f788d3c3f05b7d1/sample-typst-descend-pldi.typ)), Bastian Köpcke, Sergei Gorlatch and Michel Steuwer, 2024
- [How to write benchmarks: the Measure-Explain-Test-Improve loop](https://gallium.inria.fr/~scherer/drafts/how-to-benchmark-2026.pdf) ([HTML](https://gallium.inria.fr/~scherer/drafts/how-to-benchmark-2026.html)), Gabriel Scherer, 2026
