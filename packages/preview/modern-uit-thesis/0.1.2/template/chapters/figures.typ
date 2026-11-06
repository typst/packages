#import "global.typ": *
#import "../utils/caption.typ": dynamic-caption
#import "../utils/symbols.typ": *
#import "../utils/subfigure.typ": subfigure
#import "../utils/todo.typ": TODO

This chapter will demonstrate how to insert, manipulate and reference figures of various types. The functionality offered by typst to work with figures is powerful and relatively intuitive, especially if you're coming from #LaTeX. However, this template also features a few additional lightweight packages to further simplify working with figures.

== Images <subsec:images>
Typst allows us to render images in formats such as `png`, `jpg` and `svg` out of the box. Using the vector graphic format `svg` is recommended when applicable, for instance when inserting graphs and plots, as it ensures good quality and readability when printed or viewed on a large screen. Be aware that `svg` images may render differently when rendered on different PDF viewers in some cases.

#figure(caption: [A plot from python's matplotlib, exported to svg])[
  #image("../figures/plot_serial.svg")
] <fig:blur_plot>

Inserting a figure in typst is very simple, and we can now easily refer to @fig:blur_plot anywhere in the document. We can also easily customize the image, for instance by adjusting the width of it so that it doesn't take up as much space, like @fig:blur_plot_small. The typst documentation #footnote[see #link("https://typst.app/docs/reference/visualize/image/")] covers images more in depth.

#figure(caption: [A smaller version of the figure])[
  #image("../figures/plot_serial.svg", width: 30%)
] <fig:blur_plot_small>

#pagebreak(weak: true)
== Tables <subsec:tables>
Creating a basic table with typst is quite simple, yet we can also customize them a great deal if we would like to. This thesis template also has some custom default styling for tables, to make the stroke gray and headers distinct.

#figure(
  table(
    columns: 3,
    table.header(
      [store],
      [location],
      [open sundays],
    ),

    [Coop Extra], [Breivika], [No],
    [Joker], [Dramsvegen], [Yes],
    [Rema 1000], [K1], [No],
    [Coop Obs], [Jekta], [No],
  ),
  caption: [Table with default styling],
) <tab:default_styling>

While @tab:default_styling is a very simple table with no extra styling, @tab:rowspan is more advanced, using bold for the headers and letting them span multiple rows/columns. Note that we also set the alignment for the text inside the table cells.

#figure(
  table(
    columns: 7,
    align: center + horizon,
    /* --- header --- */
    table.header(
      // table.cell lets us access properties such as rowspan and colspan to customize the cells
      table.cell([*Classifier*], rowspan: 2),
      table.cell([*Precision*], colspan: 6),
      [1],
      [2],
      [3],
      [1&2],
      [1&3],
      [All],
    ),
    /* --- body --- */
    [Perceptron],
    [0.78],
    [0.82],
    [0.24],
    [0.81],
    [0.77],
    [0.83],
    [Decision Tree],
    [0.65],
    [0.79],
    [0.56],
    [0.75],
    [0.65],
    [0.73],
    [One-Class SVM],
    [0.74],
    [0.72],
    [0.50],
    [0.80],
    [0.73],
    [0.85],
    [Isolation Forest],
    [0.54],
    [0.51],
    [0.52],
    [0.53],
    [0.54],
    [0.53],
  ),
  caption: [A slightly more elaborate table],
) <tab:rowspan>

On a page break, a table can also break and continue on the subsequent page. If a table header and/or footer is set, like in @tab:break, these will also repeat on both pages by default.

#figure(
  caption: [A table that breaks with the page],
  table(
    columns: 3,
    fill: (_, y) => if y == 0 {
      gray.lighten(75%)
    },
    table.header[Week][Distance (km)][Time (hh:mm:ss)],
    [1], [5], [00:30:00],
    [2], [7], [00:45:00],
    [3], [10], [01:00:00],
    [4], [12], [01:10:00],
    [5], [15], [01:25:00],
    [6], [18], [01:40:00],
    [7], [20], [01:50:00],
    [8], [22], [02:00:00],
    [...], [...], [...],
    table.footer[_Goal_][_42.195_][_02:45:00_],
  ),
) <tab:break>

We can also override the default styling to customize tables. @tab:break sets a custom fill color for the header and @tab:hlines uses `table.hline()` to enable the border stroke on certain lines only. The second column in @tab:hlines is also set to fill all space available to it.

#figure(
  table(
    stroke: none,
    columns: (auto, 1fr),
    table.header(),
    [09:00], [Badge pick up],
    [09:45], [Opening Keynote],
    [10:30], [Talk: Typst's Future],
    [11:15], [Session: Good PRs],
    table.hline(start: 1),
    [Noon], [_Lunch break_],
    table.hline(start: 1),
    [14:00], [Talk: Tracked Layout],
    [15:00], [Talk: Automations],
    [16:00], [Workshop: Tables],
    table.hline(),
    [19:00], [Day 1 Attendee Mixer],
  ),
  caption: [A table with no border stroke],
) <tab:hlines>

There is a lot more customization to be done with tables. Read the official table guide #footnote[see #link("https://typst.app/docs/guides/table-guide/")] to discover how to create a table by reading a `csv` file with typst, achieving zebra highlighting and much more.

#pagebreak(weak: true)
== Listings <subsec:listings>
For code listings, this template uses a third party package called *codly* #footnote[see #link("https://typst.app/universe/package/codly")] in order to provide some out of the box styling and proper syntax highlighting. Unless you want to customize the appearance you don't need to touch codly at all, simply create a normal code block like you would in markdown.

#figure(caption: [Hello world! in rust])[
  ```rust
  pub fn main() {
    println!("Hello, world!");
  }
  ```
] <raw:rust>

By default, code listings are configured with zebra lines, line numbering and a label displaying the programming language, like the rust snippet in @raw:rust. If we want to, we can disable or customize these features locally using the codly `#local()` function, demonstrated with @raw:fsharp. Note that too many calls to `#local()` may cause issues, so always use `#codly()` where possible.

// FIXME: Empty label is still shown as a tiny circle
// NOTE: As the code snippet is within the #local call here, we need to specify the figure kind to get 'Listing' instead of 'Figure'
#figure(caption: [F\# snippet with no zebras and label], kind: raw)[
  #local(zebra-fill: none, display-name: false)[
    ```fsi
    [<EntryPoint>]
    let main () =
      "Hello, world!"
      |> printfn
    ```
  ]
] <raw:fsharp>

We can also skip lines in the code snippet. Note that it doesn't actually skip lines in your snippet, but rather changes the line numbers to represent skipped code. This is demonstrated in @raw:c below.

#figure(caption: [C snippet with skipped lines], kind: raw)[
  #codly(skips: ((2, 15),))
  ```c
  int main() {
    printf("Hello, world!");
    return(0);
  }
  ```

] <raw:c>

Codly also allows us to highlight code using line and column positions. @raw:python demonstrates highlighting a line and giving it a tag "assignment".

#figure(caption: [Python snippet with highlights], kind: raw)[
  #codly(highlights: (
    (line: 1, start: 3, end: none, fill: blue, tag: "assignment"),
  ))
  ```python
  if __name__ == "__main__":
    d = {'a': 1}
    print("Hello, world!")
  ```

] <raw:python>

Code snippets can also be imported from files using the `code-block` macro. @raw:fsharp-file shows a F\# snippet imported from a file.

#figure(caption: [F\# snippet imported from file], kind: raw)[
  #code-block("Program.fsx", read("../code-snippets/Program.fsx"))
] <raw:fsharp-file>

// TODO: Make subfigures without subpar or figure out how to fix numbering
== Subfigures <subsec:subfigures>
A lot of times we want to display figures side by side and be able to reference them separately as well as together. To make this process easy, this thesis template includes the *subpar* #footnote[see #link("https://typst.app/universe/package/subpar")] package. It lets us easily lay out figures in a _grid_ while making all labels available for reference.

#subfigure(
  figure(
    image("../figures/philosophers.png"),
    caption: [Subfigure with dining philosophers],
  ),
  <fig:philosophers>,
  figure(
    image("../figures/dining_philosophers.png"),
    caption: [Subfigure with a deadlock],
  ),
  <fig:dining_philosophers>,
  columns: (1fr, 1fr),
  caption: [A figure composed of two subfigures],
  label: <fig:with_subfigures>,
)

Now we can refer to @fig:philosophers, @fig:dining_philosophers and the parent @fig:with_subfigures separately. To access subpar, we use a custom function `#subfigure()` which is included in this template. It's a simple wrapper that sets up the numbering for us to match the rules of the template.


#subfigure(
  figure(caption: [F\# snippet in a subfigure], kind: raw)[
    ```fsi
    [<EntryPoint>]
    let main () =
      "Hello, world!"
      |> printfn
    ```
  ],
  <subfig:subfig_fsharp>,
  figure(
    table(
      columns: 3,
      table.header(
        [store],
        [location],
        [open sundays],
      ),

      [Coop Extra], [Breivika], [No],
      [Joker], [Dramsvegen], [Yes],
      [Rema 1000], [K1], [No],
      [Coop Obs], [Jekta], [No],
    ),
    caption: [Table in a subfigure],
  ),
  <subfig:subfig_table>,
  figure(
    image("../figures/philosophers.png"),
    caption: [Subfigure with philosophers],
  ),
  <subfig:philosophers2>,
  figure(
    image("../figures/dining_philosophers.png"),
    caption: [Subfigure with dining philosophers],
  ),
  <subfig:dining_philosophers2>,
  columns: (150pt, 1fr),
  caption: [A figure with multiple subfigure kinds],
  label: <fig:mixed_kinds>,
)

We can include as many figures as we want in the grid, and even mix and match figure types. @fig:mixed_kinds also has the first column set to a width of `150pt` while the second column is set to take up the remaining space. Note that by default, subfigures do not appear in the List of Figures, and the supplement of referring to for instance @subfig:subfig_fsharp is _not_ "Listing" like we might expect.

#figure(
  caption: dynamic-caption(
    [A nice picture of UiT, the Arctic University of Norway, under the northern lights. The picture is taken from #link("https://www.wur.nl/en/").],
    [UiT under aurora borealis],
  ),
  image("../figures/uit_aurora.jpg"),
) <fig:uit_aurora>

Another handy function available in this template is the `#dynamic-caption()`, which takes two arguments: a short and a long version of a caption. The long version is displayed under the figure, like in @fig:uit_aurora, however the short version is used in the List of Figures at the start of the thesis.

Using the custom macro `csv-table` it is possible to include data dynamically for csv files. @table:csv-table demonstrates this.

#figure(
  csv-table(
    tabledata: csv("../figures/table.csv"),
    header-row: white,
    odd-row: luma(240),
    even-row: white,
    columns: 3,
  ),
  caption: [A table with data from a csv file],
) <table:csv-table>

== Equations <subsec:equations>
Typst has great built-in support for mathematical equations and this template applies numbering to them by default, so that we can refer to @equ:simple-equation just like we would a figure.

$ sum_(k=1)^n k = (n(n+1)) / 2 $ <equ:simple-equation>

By default, we can use powerful symbols and functions inside equation blocks (`$ ... $`) to typeset quite advanced equations. For instance, `#attach()` grants us fine control over symbol placement, like in @equ:attach.

$
  attach(
  Pi, t: alpha, b: beta,
  tl: 1, tr: 2+3, bl: 4+5, br: lambda,
)
$ <equ:attach>

Many of the functions have additional parameters to further customize their behavior. For instance, the matrix function allows us to specify the delimiter, see @equ:matrix.

$
  mat(
  delim: "[",
  1, 2, ..., 10;
  2, 2, ..., 10;
  dots.v, dots.v, dots.down, dots.v;
  10, 10, ..., 10;
)
$ <equ:matrix>

We can also define our own classes to use within equation blocks, and much more. Refer to the typst reference #footnote()[see #link("https://typst.app/docs/reference/math/")] to see all capabilities.

#let spade = math.class(
  "normal",
  sym.suit.spade,
)

$ root(3, 5 spade) in RR $

== Physica <subsec:physica>
To expand on the already considerable built-in support for math symbols, we've also included the physica #footnote()[see #link("https://typst.app/universe/package/physica")] package. It makes a far greater range of functions available, allowing us to quickly typeset common symbol sequences without having to build them with the vanilla library. For example, big O notation is easily available:

$ Order(n log(n)) $

This section covers only a fraction of the available symbols and handy shorthands like expectation value in @equ:expval, and digital timing diagrams in @equ:clock. Refer to the full user manual on github #footnote()[see #link("https://github.com/Leedehai/typst-physics/")] to see the full usage.

$ expval(p, psi) $ <equ:expval>

$
  "clk:" & signals("|1...|0...|1...|0...|1...|0...|1...|0...", step: #0.5em)
$ <equ:clock>
