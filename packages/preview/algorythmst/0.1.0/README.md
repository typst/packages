# algorythmst

Beautiful pseudocode blocks for Typst, styled after LaTeX's `algorithm` + `algorithmicx` look and built on [lovelace](https://typst.app/universe/package/lovelace).

- LaTeX `algorithmicx`-style layout: clean booktabs-like horizontal rules, no side borders
- Line numbers (`1:`) and indent guides
- Optional numbered title, rendered like LaTeX's `\caption` as **Algorithm N:** followed by the title in small caps
- Optional caption below the block
- Easy right-aligned comments with `#comment[...]`
- Referenceable with `@label` via the `label:` argument
- Display math is centred automatically

## Usage
Import the package with:
```typst
#import "@preview/algorythmst:0.1.0": *
```

### Basic block

`pseudo` takes a list and turns it into a pseudocode block. Lines starting with `+` are numbered, lines starting with `-` are not, and indentation nests blocks with an indent guide. It can optionally be given a title and caption.
```typst
#pseudo(
  title: [Binary Search],
  caption: [Finds `v` in the sorted array `A`.],
)[
  - *procedure* #smallcaps[Binary-Search]$(A, n, v)$
    + $l <- 1$; $r <- n$ #comment[search window]
    + *while* $l <= r$ *do*
      + $m <- floor((l + r) / 2)$
      + *while* $l > 0$ *do*
        + #smallcaps[Hanne-Rothe]
      + *end while*
      + *if* $A[m] = v$ *then*
        + *return* $m$
      + *else if* $A[m] < v$ *then* $l <- m + 1$
      + *else* $r <- m - 1$
      + *end if*
    + *end while*
  + *return* $-1$ #comment[not found]
]
```
This renders as a block headed **Algorithm 1:** Binary Search as shown below.

<img width="726" height="446" alt="Rendered Algorithm 1, Binary Search: a numbered pseudocode block with indent guides, gray right-aligned comments, and the caption below the bottom rule" src="https://github.com/user-attachments/assets/83f852d0-f0f4-47ff-9f33-8d745ecb247f" />

Titles are numbered automatically and captions are placed below the pseudocode block.

### Math-heavy algorithms

The same syntax works for more mathematical algorithms, with display math, constraints and comments. Here the `- *Require:*` line is left unnumbered:

```typst
#pseudo(
  title: "Compute DSI",
  caption: [Computes the Dataset Sparse Intervention (DSI): the neuron subset $s$ whose intervention along the activation difference $macron(a)$ best moves the model from dataset $D_0$ toward $D_k$, using at most $n$ non-zero entries.]
  )[
  - *Require:* dataset $D_0$, dataset $D_k$, set size $n$, number of steps $t$
  + $macron(a) <- "mean"_(x in D_k) (a|x) - "mean"_(x in D_0) (a|x)$  #comment[average activation difference]
  + $g <- "mean"_(x in D_0) nabla^r_a f(x)$ #comment[robustified gradient in 0-shot setting]
  + $e<- g dot.o macron(a) $ #comment[expected first-order effect of interventions]
  + $s_0 <- "topn"(e)$ #comment[most relevant neurons as starting point]
  + *for* $i = 1$ *to* $t$ *do*
    + $s_i approx arg max_s "mean"_(x in D_0) f_(s dot.o macron(a)) (x)$ #comment[update intervention]
    
    + #h(1em) $s t space "nnz"(x) <= n, s$ close to $s_(i-1)$ #comment[sparse & close to previous step]
  + *return* $s$
]
```
This renders as **Algorithm 2:** Compute DSI as shown below

<img width="726" height="394" alt="Rendered Algorithm 2, Compute DSI: an unnumbered Require line, numbered math-heavy steps with a for loop, gray right-aligned comments, and a multi-line caption below" src="https://github.com/user-attachments/assets/13b71a27-a7d3-48ea-9d79-2bea8b8b0a28" />

### Comments

Put `#comment[...]` at the end of a line to add a gray, right-aligned comment:

```typst
+ $i <- 0$ #comment[start at the first element]
```

### References

To reference an algorithm, pass a `label` and use it like any other reference:

```typst
#pseudo(title: [Binary Search], label: <alg:search>)[
  + $l <- 1$
]

As shown in @alg:search, ...
```

This prints "As shown in Algorithm 1, ...", with the number linked to the block.

### List of algorithms

Titled blocks show up in a list of algorithms by their title, like LaTeX's `\listofalgorithms`. Blocks without a title use their caption:

```typst
#outline(title: [List of Algorithms], target: figure.where(kind: "algorithm"))
```

### Plain blocks

Without `title`, `caption` or `label`, `pseudo` gives just the framed block, with no number and no header. With a caption or label but no title, the block is still numbered (for references and the outline) but has no header row.

### Customising

Any extra arguments go straight to lovelace's `pseudocode-list`, so its options work as usual. For example:

```typst
#pseudo(line-numbering: none)[ ... ]       // no line numbers
#pseudo(line-gap: 1em)[ ... ]              // more space between lines
#pseudo(indentation: 2em)[ ... ]           // wider indentation
```

## API

| Function | Description |
| --- | --- |
| `pseudo(body, title: none, caption: none, label: none, ..args)` | Pseudocode block. Pass `label: <name>` to reference it with `@name`. Extra `args` go to lovelace's `pseudocode-list`. |
| `comment(body)` | Gray, right-aligned comment at the end of a line. |

## License

MIT
