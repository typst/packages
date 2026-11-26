#import "@preview/craken-report:0.1.0": *

// ── The cover ───────────────────────────────────────────────────────────────
// Every field is optional: leave one out and its line disappears.
#show: report.with(
  course: "HPC",
  lab: "Lab 2",
  title: [Parallel programming with OpenMP],
  subtitle: [Solving the heat equation],
  authors: (
    (name: "Ada Lovelace", id: "s1815", email: "ada@example.edu"),
    (name: "Alan Turing", id: "s1912", email: "alan@example.edu"),
    (name: "Grace Hopper", id: "s1906", email: "grace@example.edu"),
  ),
  group: "Group 5",
  academic-year: "2026/2027 Q1",
  // fields: (("Professor", [Jane Doe]),),        // more lines on the cover
  date: datetime(year: 2026, month: 10, day: 29), // auto: today
  // logo: read("figures/logo.png", encoding: none),
  contents: true,
  // heading-numbering: "a)",   // one section per question: a), b), c)
)

#lede[
  We parallelise a solver for the heat equation with OpenMP, first with implicit tasks and then with explicit ones, and measure how far each version scales on one 32-core node.
]

= Parallel versions <sec:versions>

Each version in @tab:files takes the place of `solver-omp.c` in the same Makefile, so every one builds with the same command.#footnote[All runs used one node with two 16-core sockets.] Footnotes like that one hold anything a reader can skip.

#figure(
  table(
    columns: 3,
    align: (start, start, start),
    table.header[File][Section][Content],
    [`solver-omp-jacobi-v1.c`], [@sec:jacobi], [Implicit tasks, block decomposition by rows],
    [`solver-omp-jacobi-v2.c`], [@sec:jacobi], [v1 + `copy_mat` with the same blocks],
    [`solver-omp-gauss.c`], [@sec:gauss], [Explicit tasks with `depend(in, out)`],
  ),
  caption: [The parallel versions.],
) <tab:files>

== Jacobi <sec:jacobi>

Each implicit task computes a block of consecutive rows (@lst:solve). The only variable shared across iterations is `sum`, so it becomes a #dfn[reduction]: every thread keeps its own copy, and OpenMP adds them up at the end of the region.

// The listing reads lines 11–36 of the source file, numbered as in the file.
#listing(caption: [Parallel `solve` (`solver-omp-jacobi-v1.c`).], lang: [C], numbers: true, first-line: 11)[
  #raw(lines(read("code/solver.c"), 11, 36), lang: "c", block: true)
] <lst:solve>

A plain code block gets the same box, without a caption:

```sh
make heat-omp && OMP_NUM_THREADS=8 ./heat-omp test.dat
```

== Gauss–Seidel <sec:gauss>

Gauss–Seidel updates the grid in place, so a point depends on its left and top neighbours from the current iteration:

$ u_(i,j)^(k+1) = 1/4 (u_(i-1,j)^(k+1) + u_(i,j-1)^(k+1) + u_(i+1,j)^k + u_(i,j+1)^k). $ <eq:gs>

Only labelled equations get a number, so we can refer to @eq:gs; this one stays unnumbered:

$ T_p = T_"seq" (phi / p + 1 - phi). $

Inline math sits in the text too: with $p = 16$ and $phi = 0.73$, Amdahl's law bounds the speed-up by $1 \/ (1 - phi) approx 3.7$.

= Results <sec:results>

== Validation

Both solvers converge to the same image as the sequential code (@fig:heat). The two images differ in the last decimals only, because Jacobi and Gauss–Seidel stop at slightly different residuals.

#figure(
  grid(
    columns: (55mm, 55mm),
    gutter: spacing.s8,
    image("figures/heat-jacobi.png"), image("figures/heat-gauss-seidel.png"),
  ),
  caption: [Temperature after convergence: Jacobi (left) and Gauss–Seidel (right).],
) <fig:heat>

#figure(
  table(
    columns: 5,
    table.header[Solver][Threads][Time (s)][Iterations][Residual],
    [Jacobi], [1], [2.405], [15756], [0.000050],
    [Jacobi], [16], [0.211], [15756], [0.000050],
    [Gauss–Seidel], [1], [2.856], [12409], [0.000050],
    [Gauss–Seidel], [16], [0.738], [12409], [0.000050],
  ),
  caption: [Executions on the 254 × 254 grid until convergence.],
) <tab:runs>

== Scalability

@fig:speedup reads its points straight from `data/speedup.csv`. Jacobi keeps close to the ideal line up to 8 threads; Gauss–Seidel flattens early, because its wavefront leaves most threads waiting.

#let data = csv("data/speedup.csv", row-type: dictionary)
#figure(
  plot(
    x-label: [Threads],
    y-label: [Speed-up],
    x-scale: "log2",
    y-ticks: (0, 4, 8, 12, 16),
    width: 80%,
    series: (
      (label: [Jacobi], points: csv-points(data, x: "threads", y: "jacobi")),
      (label: [Gauss–Seidel], points: csv-points(data, x: "threads", y: "gauss_seidel")),
      (label: [Ideal], fn: p => p, dashed: true, color: palette.ink-soft),
    ),
  ),
  caption: [Speed-up against the sequential code. The dashed line is the ideal $S_p = p$.],
) <fig:speedup>

A bar chart compares a few versions at a glance. `values: true` prints each bar's value:

#figure(
  bar-chart(
    categories: ([v1], [v2], [swap]),
    series: (
      (label: [4 threads], values: (3.1, 3.4, 3.6)),
      (label: [8 threads], values: (5.2, 6.1, 6.7)),
      (label: [16 threads], values: (7.9, 10.3, 11.4)),
    ),
    y-label: [Speed-up],
    values: true,
    height: 58mm,
  ),
  caption: [Speed-up of the three Jacobi versions.],
) <fig:versions>

A long table can be split into groups with `table-section`, and its rows indented with `#h(1em)`:

#figure(
  table(
    columns: (1fr, auto, auto, auto, auto),
    table.header[Number of processors][1][4][8][16],
    table-section(5)[Overview of whole program execution metrics],
    [Elapsed time (ms)], [2.40], [1.58], [1.48], [1.51],
    [Speed-up], [1.00], [1.53], [1.62], [1.59],
    [Efficiency], [1.00], [0.38], [0.20], [0.10],
    table-section(5)[Efficiency metrics in the parallel fraction],
    [Global efficiency], [99.85%], [85.40%], [62.22%], [33.47%],
    [#h(1em) Load balancing], [100.00%], [92.96%], [99.90%], [99.86%],
    [#h(1em) In-execution efficiency], [99.85%], [96.48%], [98.56%], [98.12%],
  ),
  caption: [Efficiency metrics of Jacobi v1.],
) <tab:modelfactors>

== What we learned

- *Jacobi* scales well: every row block is independent.
  - The copy back into `u` costs about 30 % of each iteration.
- *Gauss–Seidel* needs a wavefront:
  + split the grid into blocks,
  + let each block wait for its left and top neighbours,
  + run the anti-diagonals in parallel.

#sbreak()

Three suckers break a section without a new title.

// Everything after this line is numbered A, B, …
#show: appendix

= Creating your own synchronisation objects

Appendices work like sections: `== Locks` gives A.1, and so on.
