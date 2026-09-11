I'm happy to present [Algol](https://typst.app/universe/package/algol), a new pseudocode typesetting package for Typst!

Algol typesets algorithms as nested Typst lists, so the pseudocode you write looks like the pseudocode you get:

- **Simple notation:** code blocks are plain nested lists/enums;
- **High flexibility:** see the list of [customization parameters](https://typst.app/universe/package/algol#algol-customization);
- **Line referencing** through Typst's native reference syntax;
- **Per-line number disabling**;
- **High visual fidelity to [algorithm2e](https://ctan.org/pkg/algorithm2e)** with the default configuration.

## Quick Start

```typst
#import "@preview/algol:0.1.0": algol, enable-line-refs, no-next-line-nb
#set page(height: auto, width: 25em, margin: 1em)
#set par(justify: true)
#show: enable-line-refs       // needed for line referencing
#align(center, algol[
- *function* $"binary-search"(A, e)$ *is* #no-next-line-nb
    // #no-next-line-nb disables numbering for the next line only
  - #box(stroke: .5pt, inset: .2em)[_Initialize left and right pointers_]
  - $L <- 0$
  - $R <- "length"(A) - 1$
  - *while* $L <= R$ *do*
    - $m <- L + floor((R - L) / 2)$
    - *if* $A[m] < e$ *then*
      + $L <- m + 1$          // '+' lists are used for unfinished blocks (without hooks)
    - *else if* $A[m] > e$ *then*
      + $R <- m - 1$
    - *else* *return* $m$     <line:found-element>
  - *return* $"error"$        <line:error>
])
If element $e$ is in array $A$, the algorithm returns its index at @line:found-element.
Otherwise it returns $"error"$ at @line:error.
```

![bin-search|566x500, 75%](upload://g0jiVmfePOr88MDjq0009n3HSKc.png)

## Design Principle: "Less is More"

Algol is deliberately unopinionated. In roughly 130 lines of code, it leaves out everything that is easy to implement on the user's side (pseudocode comments, syntax highlighting, integration into figures) which keeps it easy to customize. Building those features into the package would mean either a cluttered API (one parameter per feature) or design choices that won't fit everyone. The [README](https://typst.app/universe/package/algol#user-side-features) shows how to add each of them on top of Algol in a few lines.

## Comparison with Alternatives

Typst Universe already hosts several pseudocode packages, and they all do their job well. My own requirement was to reproduce the algorithm2e look and feel using simple notation, and none of them got me there. Rather than push that direction onto other people's projects through a long series of pull requests, I wrote my own. To the best of my knowledge, here is the landscape:

- **[lovelace](https://typst.app/universe/package/lovelace).** The best-known one (it is featured on Typst Universe), and it also supports pseudocode-as-lists, like Algol. However, it cannot alternate between code blocks with and without guide hooks, and cannot disable numbering on individual lines.
- **[algorithmic](https://typst.app/universe/package/algorithmic).** Parses the pseudocode into an AST (much like algorithm2e), but is fairly rigid in both its set of supported code blocks (`If`, `While`, `Function`...) and its appearance. It also has no vertical guides and no per-line number disabling.
- **[algo](https://typst.app/universe/package/algo).** Takes pseudocode as plain content, but line breaks and indentation have to be handled manually with `\`, `#i` and `#d`, which gets tedious. No guide hooks, no per-line number disabling.
- **[ez-algo](https://typst.app/universe/package/ez-algo).** Also takes pseudocode as plain content, and manages indentation through two keyword lists: one that increases the indent level (`if`, `while`...) and one that decreases it (`end if`, `end while`...). This means every block must be closed by a keyword, so algorithm2e-style hooked blocks are out of reach. No vertical guides and no number disabling either.
- **`raw`-based packages ([codly](https://typst.app/universe/package/codly), [zebraw](https://typst.app/universe/package/zebraw)…).** These cannot render math, since `raw` blocks cannot contain equations, which is a serious limitation for scientific writing.

Two capabilities are missing across the board: alternating between code blocks with and without guide hooks, and disabling numbering for single lines. Both are needed for feature parity with algorithm2e, and both are what Algol adds.

**Side note:** I first wrote this package in 2024 to typeset my PhD thesis in Typst, and only got around to publishing it in 2026, after some invisible hand pushed me to do it :wink: