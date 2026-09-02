# Algol

Algol is a flexible [Typst](https://typst.app/) package for typesetting algorithms and pseudocode using light notations.
Its name is inspired by the [Algol star](https://en.wikipedia.org/wiki/Algol) of the Perseus constellation, and by the [ALGOL](https://en.wikipedia.org/wiki/ALGOL) family of programming languages.

The package is customizable (see [customization parameters](#algol-customization)), but its default appearance aims to reproduce the look-and-feel of the [algorithm2e](https://ctan.org/pkg/algorithm2e) LaTeX package.
In contrast to its LaTeX counterparts, Algol provides a lighter notation style by leveraging Typst's list customization capabilities.

## Quick Start

```typst
#import "../algol.typ": algol, enable-line-refs, no-next-line-nb

#set page(height: auto, width: 25em, margin: 1em)
#set par(justify: true)

#show: enable-line-refs        // needed for line referencing

#align(center, algol[
- *function* $"binary-search"(A, e)$ *is* #no-next-line-nb
  - #box(stroke: .5pt, inset: .2em)[_Initialize left and right pointers_]
  - $L <- 0$
  - $R <- "length"(A) - 1$
  - *while* $L <= R$ *do*
    - $m <- L + floor((R - L) / 2)$
    - *if* $A[m] < e$ *then*
      + $L <- m + 1$
    - *else if* $A[m] > e$ *then*
      + $R <- m - 1$
    - *else* *return* $m$     <line:found-element>
  - *return* $"error"$        <line:error>
])

If element $e$ is in array $A$, the algorithm returns its index at @line:found-element, otherwise it returns $"error"$ at @line:error.
```

<img src="gallery/bin-search.png" alt="Binary search algorithm in Algol" width="60%">

The above example demonstrates several features of Algol:
- Both "`-`" lists ([bullet lists](https://typst.app/docs/reference/model/list/)) and "`+`" lists ([numbered lists](https://typst.app/docs/reference/model/enum/)) are used in Algol
    - the "`-`" lists are used to create _finished_ code blocks, which have a hook at the end of the left-side vertical guide
    - the "`+`" lists are used to create _unfinished_ code blocks, which do not have a hook (ex: lines 7 and 9)
    - lists of depth 0 have no left-side vertical guide or hook (ex: the list starting at line 1)
- Lines of the algorithm can be referenced after applying the `enable-line-refs` show rule (ex: lines 10 and 11)
    - the line labels must respect a certain regex pattern (by default, line labels must start with `"line:"`)
    - the regex pattern, the reference supplement, and the line numbering can be customized
- Line numbering can be disabled for a single line using `#no-next-line-nb` (ex: the comment between line 1 and line 2)
    - note that this command disables the **next** line number, not the previous one

## Algol Customization

<details>
<summary>Customization parameters of the "algol" function</summary>

- `box-stroke` (`stroke`, default: `.5pt + black`): [stroke](https://typst.app/docs/reference/visualize/stroke/) of the outer box
- `box-inset` (`length|dictionary`, default: `.4em`): [inset](https://typst.app/docs/reference/layout/box/#parameters-inset) of the outer box
- `indent-length` (`length`, default: `1.5em`): indentation length of the algorithm
- `line-spacing` (`length`, default: `.6em`): spacing between the lines of the algorithm
- `line-numbering` (`string|function`, default: `"1"`): [numbering](https://typst.app/docs/reference/model/numbering/) of the line numbers
- `line-number-fmt` (`function`, default: see below): function taking a string of a line number (obtained from the `line-numbering` numbering) and returning a formatted content
- `line-number-spacing` (`length`, default: `1.5em`): vertical spacing between the line numbers and the lines of the algorithm
- `guide-stroke` (`stroke`, default: `.5pt + black`): [stroke](https://typst.app/docs/reference/visualize/stroke/) of the vertical guides and hooks
- `hook-length` (`length`, default: `.4em`): length of the hooks at the bottom left of finished code blocks
- `guide-left-offset` (`length`, default: `.5em`): offset of the vertical guides at the left of code blocks (\*)
- `guide-top-offset` (`length`, default: `.4em`): offset of the vertical guides at the top of code blocks (\*)
- `finished-guide-bottom-offset` (`length`, default: `.1em`): offset of the vertical guides at the bottom of finished code blocks (\*) 
- `unfinished-guide-bottom-offset` (`length`, default: `.4em`): offset of the vertical guides at the bottom of unfinished code blocks (\*)
- `finished-block-bottom-spacing` (`length`, default: `.3em`): spacing at the bottom of finished code blocks (impacts the line layout)

(\*) The "guide offset" parameters do not impact the layout of the lines of the algorithm
</details>

<details>
<summary>Default line number formatting function for the "line-number-fmt" parameter</summary>

```typst
#let line-number-fmt-default = n-str => box(width: .8em, baseline: .65em,
    align(horizon + right, text(size: .8em)[*#n-str*])
)
```
</details>

<details>
<summary>Customization parameters of the "enable-line-refs()" show rule</summary>

- `line-numbering` (`str`, default: `"1"`): [numbering](https://typst.app/docs/reference/model/numbering/) of the line references
- `line-supplement` (`content`, default: `[line]`): supplement used before the line numbers in the reference
- `label-pattern` (`regex`, default: `regex("^line:.*")`): pattern for the line labels (by default they must start with `"line:"`)
</details>

## User-Side Features

The philosophy of Algol is to be unopinionated but customizable.
Hence, the keep its API flexible, Algol does not directly provide the following features.
However, as we later show, these features can be easily implemented on the user side.

### Algorithm Keywords

Algol has no special algorithm keywords such as `if`, `else`, or `while`, but the user can easily customize their own list of keywords, either directly in the algorithm (like in the [quick start example](#quick-start)) or using custom show rules:

```typst
#show regex("if|then|else|return"): it => text(blue, strong(it))
```

### Embedding in Figures

The creation of a figure type to embed Algol pseudocode also has to be made on the user side:

```typst
#let algorithm = figure.with(kind: "algorithm", supplement: [Algorithm])
```

### Pseudocode Comments

The Algol package does not provide default functions for typesetting pseudocode comments, but these functions can be easily implemented as follows:

```typst
#let lcomment(c) = [$triangle.small.r$ _ #c _]          // left-aligned comment
#let rcomment(c) = [#h(1fr) $triangle.small.r$ _ #c _]  // right-aligned comment
```

### Combining Everything

The following example combines all the techniques presented in this section.

```typst
#import "../algol.typ": algol

#set page(height: auto, width: 25em, margin: 1em)
#set par(justify: true)
// math-compliant smallcaps font
#show smallcaps: set text(font: "Libertinus Serif")

#let algorithm = figure.with(kind: "algorithm", supplement: [Algorithm])

#let my-algol(it) = {
  show regex("if|then|else|return"): it => text(blue, strong(it))
  algol(it)
}

#let lcomment(c) = [$triangle.small.r$ _ #c _]          // left-aligned comment
#let rcomment(c) = [#h(1fr) $triangle.small.r$ _ #c _]  // right-aligned comment

#let fib = smallcaps[Fibonacci]

#algorithm(my-algol[
$fib(n)$: #rcomment[provide some $n in NN$]
- #lcomment[base case: $n = 0$ or $1$]
- if $n = 0 or n = 1$ then return $n$
- #lcomment[recursive case: add the 2 previous Fib. numbers]
- return $fib(n - 1) + fib(n - 2)$
],
caption: [
  Fibonacci's algorithm.
]) <alg:fibonacci>

@alg:fibonacci describes the recursive algorithm to compute the $n$-th Fibonacci number.
```

<img src="gallery/fibonacci.png" alt="Fibonacci's algorithm in Algol" width="60%">
