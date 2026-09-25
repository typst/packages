# algorythmst

Beautiful pseudocode blocks for Typst, styled after LaTeX's `algorithm` + `algorithmicx` look and built on [lovelace](https://typst.app/universe/package/lovelace).

- LaTeX `algorithmicx`-style layout: clean booktabs-like horizontal rules, no side borders
- Line numbers (`1:`) and indent guides
- Optional numbered title, rendered like LaTeX's `\caption` as **Algorithm N:** followed by the title in small caps
- Optional caption below the block
- Easy right-aligned comments with `#comment[...]`
- Display math is centred automatically

## Usage

```typst
#import "@preview/algorythmst:0.1.0": *

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
<img width="726" height="446" alt="image" src="https://github.com/user-attachments/assets/83f852d0-f0f4-47ff-9f33-8d745ecb247f" />



```typst
#import "@preview/algorythmst:0.1.0": *

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
<img width="726" height="394" alt="image" src="https://github.com/user-attachments/assets/13b71a27-a7d3-48ea-9d79-2bea8b8b0a28" />


Without `title` and `caption`, `pseudo` gives just the framed block.

## API

| Function | Description |
| --- | --- |
| `pseudo(body, title: none, caption: none, ..args)` | Pseudocode block. Extra `args` go to lovelace's `pseudocode-list`. |
| `comment(body)` | Gray, right-aligned comment at the end of a line. |

## License

MIT

---

