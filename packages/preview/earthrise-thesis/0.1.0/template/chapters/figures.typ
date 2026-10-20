#import "../utils/global.typ": *
#import "../utils/caption.typ": dynamic-caption
#import "../utils/symbols.typ": *
#import "../utils/subfigure.typ": subfigure

This chapter shows how to insert, adjust and reference figures of every kind. Typst handles figures well on its own; the template adds a few lightweight packages for listings, subfigures and theorems.

== Images <subsec:images>
Typst renders `png`, `jpg` and `svg` images. Prefer the vector format `svg` for graphs and plots: it stays sharp in print and on large screens.

#figure(caption: [SVG of a wondering robot])[
  #image("../figures/wondering_robot.svg")
] <fig:robot>

Give a figure a label to refer to it from anywhere, like @fig:robot. Set `width` to shrink an image, like @fig:robot_small. All options of `image` are in the Typst reference #footnote[see #link("https://typst.app/docs/reference/visualize/image/")].

#figure(caption: [A smaller version of the figure])[
  #image("../figures/wondering_robot.svg", width: 30%)
] <fig:robot_small>

== Tables <subsec:tables>
Tables are simple to create and highly customizable. The template styles them by default with a gray stroke and distinct headers.

#figure(
  table(
    columns: 3,
    table.header([Planet], [Mean radius (km)], [Moons]),
    [Mercury], [2440], [0],
    [Venus], [6052], [0],
    [Earth], [6371], [1],
    [Mars], [3390], [2],
  ),
  caption: [Table with default styling],
) <tab:default_styling>

@tab:default_styling uses the default styling. @tab:rowspan adds bold headers that span several rows or columns.

#figure(
  table(
    columns: 7,
    /* --- header --- */
    table.header(
      table.cell([*Feature*], rowspan: 2),
      table.cell([*Detection precision per orbit*], colspan: 6),
      [1],
      [2],
      [3],
      [1&2],
      [1&3],
      [All],
    ),
    /* --- body --- */
    [Craters],
    [0.91],
    [0.88],
    [0.93],
    [0.92],
    [0.94],
    [0.95],
    [Boulders],
    [0.62],
    [0.70],
    [0.58],
    [0.71],
    [0.66],
    [0.74],
    [Rilles],
    [0.47],
    [0.55],
    [0.61],
    [0.58],
    [0.63],
    [0.67],
    [Lava tubes],
    [0.33],
    [0.29],
    [0.41],
    [0.36],
    [0.44],
    [0.48],
  ),
  caption: [A slightly more elaborate table],
) <tab:rowspan>

To let a long table continue on the next page, allow it with a `show` rule; figures do not break by default.
A table header or footer, like those of @tab:break, repeats on every page the table spans.

#[
  #show figure: set block(breakable: true)
  #figure(caption: [A table that breaks with the page], table(
    columns: 3,
    fill: (_, y) => if y == 0 {
      gray.lighten(75%)
    },
    table.header()[Sol][Distance driven (m)][Battery at dusk (%)],
    [1], [12], [94],
    [2], [35], [88],
    [3], [48], [81],
    [4], [0], [97],
    [5], [61], [79],
    [6], [74], [72],
    [7], [52], [76],
    [8], [83], [68],
    [...], [...], [...],
    table.footer()[_Goal_][_1000_][_≥ 20_],
  )) <tab:break>
]

Override the default styling where needed: @tab:break fills its header with a custom color, and @tab:hlines draws lines only where `table.hline()` asks for them and lets its second column fill the remaining width.

#figure(
  table(
    stroke: none,
    columns: (auto, 1fr),
    table.header([Time], [Event]),
    [T−09:00], [Crew wake-up],
    [T−07:30], [Weather briefing],
    [T−06:00], [Propellant loading],
    [T−03:00], [Crew boards the vehicle],
    table.hline(start: 1),
    [T−01:00], [_Final hold_],
    table.hline(start: 1),
    [T−00:10], [Terminal count],
    [T−00:00], [Liftoff],
    [T+00:03], [Stage separation],
    [T+00:09], [Orbit insertion],
    table.hline(),
    [T+03:00], [First contact from orbit],
  ),
  caption: [A table with no border stroke],
) <tab:hlines>

The official table guide #footnote[see #link("https://typst.app/docs/guides/table-guide/")] covers more, such as tables read from `csv` files and zebra striping.

== Listings <subsec:listings>
Write a code block as in Markdown. The *codly* #footnote[see #link("https://typst.app/universe/package/codly")] package frames it with line numbers, zebra stripes and a language badge, while Typst highlights its syntax; you only need to touch codly to change its appearance.

#figure(caption: [A first program in Rust])[
  ```rs
  pub fn main() {
    println!("Hello, world!");
  }
  ```
] <raw:rust>

Listings show zebra lines, line numbers and the name of the language by default, like the Rust snippet in @raw:rust. Change these for one listing with `#local()`, as in @raw:rs1. Many calls to `#local()` can cause problems; prefer `#codly()` where possible.

#figure(
  caption: [Rust snippet without zebra lines or language name],
  kind: raw,
)[
  #local(zebra-fill: none, display-name: false, display-icon: false)[
    ```rs
    fn main() {
        let _immutable_binding = 1;
        let mut mutable_binding = 1;

        println!("Before mutation: {}", mutable_binding);

        // Ok
        mutable_binding += 1;

        println!("After mutation: {}", mutable_binding);

        // Error! Cannot assign a new value to an immutable variable
        _immutable_binding += 1;
    }
    ```
  ]
] <raw:rs1>

To mark omitted code, skip line numbers; the code itself is unchanged, as in @raw:c.

#figure(caption: [C snippet with skipped lines], kind: raw)[
  #codly(skips: ((2, 15),))
  ```c
  int main() {
    printf("Hello, world!");
    return(0);
  }
  ```
] <raw:c>

Highlight code by line and column. @raw:python highlights a line and tags it "assignment".

#figure(caption: [Python snippet with highlights], kind: raw)[
  #codly(highlights: (
    (line: 2, start: 3, end: none, fill: blue, tag: "assignment"),
  ))
  ```python
  if __name__ == "__main__":
    d = {'a': 1}
    print("Hello, world!")
  ```
] <raw:python>

Import a listing from a file with `code-block`, as in @raw:rs2.

#figure(caption: [Rust snippet imported from a file], kind: raw)[
  #code-block("unit_testing.rs", read("../code-snippets/unit_testing.rs"))
] <raw:rs2>

== Subfigures <subsec:subfigures>
To place figures side by side and refer to each one as well as to the whole, use the *subpar* #footnote[see #link("https://typst.app/universe/package/subpar")] package. It lays out figures in a _grid_ and keeps every label referable.

#subfigure(
  figure(
    image("../figures/earthrise.jpg"),
    caption: [Subfigure A],
  ),
  <fig:a>,
  figure(
    image("../figures/earthrise.jpg"),
    caption: [Subfigure B],
  ),
  <fig:b>,
  columns: (1fr, 1fr),
  caption: [A figure composed of two subfigures],
  label: <fig:subfigures>,
)

Each part has its own reference: @fig:a, @fig:b and the parent @fig:subfigures. Use the template's `#subfigure()`, a thin wrapper around subpar that numbers subfigures like the rest of the template.
#subfigure(
  figure(caption: [Rust snippet in a subfigure], kind: raw)[
    #codly(number-format: none)
    ```rs
    fn main() {
        println!("Hi, Mars!");
    }
    ```
  ],
  <subfig:subfig_rs>,
  figure(
    table(
      columns: 3,
      table.header([Planet], [Mean radius (km)], [Moons]),
      [Mercury], [2440], [0],
      [Venus], [6052], [0],
      [Earth], [6371], [1],
      [Mars], [3390], [2],
    ),
    caption: [Table in a subfigure],
  ),
  <subfig:subfig_table>,
  figure(
    image("../figures/earthrise.jpg"),
    caption: [Subfigure A],
  ),
  <subfig:a2>,
  figure(
    image("../figures/earthrise.jpg"),
    caption: [Subfigure B],
  ),
  <subfig:b2>,
  columns: (190pt, 1fr),
  caption: [A figure with multiple subfigure kinds],
  label: <fig:mixed_kinds>,
)

A grid takes any number of figures of mixed kinds. @fig:mixed_kinds sets its first column to `190pt` and lets the second take the remaining space. Subfigures are not listed in the list of figures, and a reference to a subfigure such as @subfig:subfig_rs does _not_ say "Listing".

#figure(
  caption: dynamic-caption(
    [Earthrise: the Earth rising above the lunar horizon, photographed by William Anders from Apollo 8 on 24 December 1968. Image AS08-14-2383, courtesy of NASA #footnote[see #link("https://images.nasa.gov/details/as08-14-2383")].],
    [Earthrise from Apollo 8],
  ),
  image("../figures/earthrise.jpg"),
) <fig:earthrise>

`#dynamic-caption()` takes a long and a short caption, in that order. The long one appears under the figure, as in @fig:earthrise; the short one appears in the list of figures.

`csv-table` builds a table from a CSV file, as in @tab:csv-table.

#figure(
  csv-table(
    tabledata: csv("../figures/table.csv"),
    header-row: white,
    odd-row: luma(240),
    even-row: white,
    columns: 3,
  ),
  caption: [A table with data from a csv file],
) <tab:csv-table>

== Equations <subsec:equations>
The template numbers block equations, so you can refer to @equ:simple-equation like a figure.

$ sum_(k=1)^n k = (n(n+1)) / 2 $ <equ:simple-equation>

Equation blocks (`$ ... $`) accept symbols and functions for advanced equations. `#attach()` places symbols precisely, as in @equ:attach.

$
  attach(
    Pi, t: alpha, b: beta,
    tl: 1, tr: 2+3, bl: 4+5, br: lambda,
  )
$ <equ:attach>

Many functions take extra parameters; `mat` sets its delimiter in @equ:matrix.

$
  mat(
    delim: "[",
    1, 2, ..., 10;
    2, 2, ..., 10;
    dots.v, dots.v, dots.down, dots.v;
    10, 10, ..., 10;
  )
$ <equ:matrix>

Custom math classes work too, like the spade below; the math section of the Typst reference #footnote()[see #link("https://typst.app/docs/reference/math/")] covers the rest.

#let spade = math.class("normal", sym.suit.spade)

$ root(3, 5 spade) in RR $

== Physica <subsec:physica>
The physica #footnote()[see #link("https://typst.app/universe/package/physica")] package adds shorthands for common notation, such as big O:

$ Order(n log(n)) $

It also draws digital timing diagrams, as in @equ:clock. Its manual #footnote()[see #link("https://github.com/Leedehai/typst-physics/")] lists everything else.

$
  "clk:" & signals("|1...|0...|1...|0...|1...|0...|1...|0...", step: #0.5em)
$ <equ:clock>

== Definitions and Theorems

Definitions, theorems, proofs and similar blocks come from the ctheorems #footnote()[see #link("https://typst.app/universe/package/ctheorems/")] package, which styles, numbers and titles them.

#definition[
  A natural number is called a #highlight[_prime number_] if it is greater
  than 1 and cannot be written as the product of two smaller natural numbers.
] <def:natural-number>

Their numbers follow the heading numbers, and you can refer to @def:natural-number, @th:comp-num or @le:divide like any figure.

#theorem[
  There are arbitrarily long stretches of composite numbers.
] <th:comp-num>

A corollary is numbered after the theorem before it:

#corollary[
  The gaps between consecutive prime numbers are unbounded.
]

#lemma[
  If $n$ divides both $x$ and $y$, it also divides $x - y$.
] <le:divide>
Pass an extra argument to change the title:

#proof([of @th:comp-num])[
  For any $n > 2$, consider$ n! + 2, quad n! + 3, quad ..., quad n! + n #qedhere $
]

Equations in proofs are not numbered. A _Q.E.D._ symbol, a black square, ends each proof at the right edge of the text; `#qedhere` moves it.

`#example` styles a block without numbering it or making it referable:

#example[
  Here is an example
]
