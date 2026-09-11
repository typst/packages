# Algol: A Typst Package for Algorithmic Typesetting

I am happy to present you [Algol](https://typst.app/universe/package/algol), a new pseudocode typesetting package featuring:
- Simple notation style: code blocks are typeset as nested lists/enums;
- High flexibility: see the list of [customization parameters](https://typst.app/universe/package/algol#algol-customization);
- Line referencing;
- Disabling the numbering for single lines;
- High visual fidelity to the [algorithm2e](https://ctan.org/pkg/algorithm2e) LaTeX package (with the default Algol configuration).

## Quick Start

```typst
#import "@preview/algol:0.1.0": algol, enable-line-refs, no-next-line-nb

#set page(height: auto, width: 25em, margin: 1em)
#set par(justify: true)

#show: enable-line-refs        // needed for line referencing

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

If element $e$ is in array $A$, the algorithm returns its index at @line:found-element, otherwise it returns $"error"$ at @line:error.
```

<!-- Insert image here -->

## Design Principle

Algol follows the "less is more" principle: its light codebase (~130 lines of code) does not provide features that could be easily implemented on the user's side, such as pseudocode comments, syntax highlighting, and integration into figures.
This keeps Algol unopinionated and easily customizable.
In contrast, integrating these features directly into the package would either result in a more cluttered API (due to all the new parameters) or in design choices that would not fit the need of some users.
More details on how to easily implement these features on top of Algol can be found on [the README](https://typst.app/universe/package/algol#user-side-features).

## Comparison with Alternatives

Multiple other packages for pseudocode typesetting already exists on Typst Universe.
However, each of these packages either lack features or make opinionated design choices, and I didn't see myself imposing new directions on these projects through repetitive pull requests.
Importantly, I wanted to be able to reproduce the same look-and-feel as the [algorithm2e](https://ctan.org/pkg/algorithm2e) LaTeX package using simple notations, which none of the existing Typst-based alternatives achieved.
To the best of my knowledge, the alternatives on Typst Universe are:

- **[lovelace](https://typst.app/universe/package/lovelace).**
    This one is the most famous (it is featured on Typst Universe) and it also supports pseudocode-as-lists. However, it does not allow alternating between code blocks with/without hooks, and it cannot disable the numbering for single lines.

- **[algorithmic](https://typst.app/universe/package/algorithmic).**
    This one parses the pseudocode into an AST (similarly to how algorithm2e does it), however it is quite rigid in its list of supported code blocks (`If`, `While`, `Function`...) and its appearance. Moreover, it does not supports vertical guides and 1-line number disabling.

- **[algo](https://typst.app/universe/package/algo).**
    This one takes pseudocode written as simple content, but line breaks and indenting/desindenting has to be done manually with `#i`/`#d`, which can be a bit annoying.
    It also does not support guide hooks and 1-line number disabling.

- **[ez-algo](https://typst.app/universe/package/ez-algo).**
    This one also takes pseudocode written as simple content, but it manages indentation with 2 lists of keywords, one that increases the indent level (`if`, `while`...) and another that decreases the indent level (`end if`, `end while`...).
    One of the drawbacks is that you must always end a code block with a keyword, so you can't have algorithm2e-style code blocks. 
    Furthermore, this package does not support vertical guides and cannot disable numbering.

- **`raw`-based pseudocode packages ([codly](https://typst.app/universe/package/codly), [zebraw](https://typst.app/universe/package/zebraw)...).**
    These ones do not support math, as `raw` content cannot contain math equations, which is a serious limitation for scientific writing.

As a last side note, I initially developed this package in 2024 to write my PhD thesis in Typst, but I only decided to finally publish in 2026, after someone who will recognize themselves pushed me to do it :)