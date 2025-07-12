#import "../utils.typ": (
  algorithm, code-listing-figure, code-listing-file, comment, flex-caption,
  silentheading, todo,
)
#import "@preview/wrap-it:0.1.1": wrap-content
#import "@preview/wut-thesis:0.1.0": faculties

= Tutorial <Tutorial>
#todo[Exclude this chapter!]

This template uses the New Computer Modern font with size 11pt, a spacing of 1.15 with a
side margin of 2.5cm with a .5mm single sided bounding correction (only if you compile
it with `in-print` set to `true`), which is _*intended*_ to follow the guidelines of the
@wut (this is a named abbreviation, you can find its definition in the `glossary.typ`
file).
This can be edited in the `thesis.typ` file#footnote[This is a footnote.]. If you
are looking for how to cite, this sentence is what your are looking for @Bradshaw2012 or
#cite(<Bradshaw2012>, form: "prose"). Note that the citation syntax is the same as the
abbreviation syntax and references syntax (more on that later). For more information
about citing/bibliography style refer to the
#link("https://typst.app/docs/reference/model/cite/")[docs] and about glossary refer to
the #link("https://typst.app/universe/package/glossarium")[`glossary` package
  documentation] (note that you might need to update the dependency
version in the import statements in `thesis.typ` and `glossary.typ`. This is an abbreviation
that is explained in the glossary, which is the @goat.

== New to Typst?
Here are some resources to help you get on board:
- #link("https://typst.app/docs/tutorial/")[Official tutorial], highly recommended!

- #link("https://typst.app/docs/reference/syntax")[Syntax reference]. In general Typst
  has good and user friendly reference/documentation
- If you already know a bit about Latex there's a
  #link("https://typst.app/docs/guides/guide-for-latex-users/")[good migration guide]
- #link("https://forum.typst.app/")[User forum] -- for when you don't know how to do
  something and the reference/guides are not enough
- #link("https://typst.app/universe/")[Repository] of user-created packages and templates for typst

== Drafting and Printing
Set the boolean variable `draft` or `in-print` in the `thesis.typ`.

The `draft` variable is used to show TODOs, change the coloring of some elements, and
DRAFT in the header and the title. It should be `true` until the final version is
handed-in.

The `in-print` variable is a boolean:
- set to `true` to generate a PDF file for *physical printing* (it adds bigger margins
  on the binding part, changes the numbering of the page and chapter headers from
  centered to print-sided ones and turns off link coloring);
- set to `false` to create a PDF file for *reading on screen* (e.g. to upload to
  onedrive for the *final thesis hand-in*).

== Choosing a correct faculty
To set a correct abbreviation in the `faculty` argument in `thesis.typ` consult the
@faculties-table. Note that this table is generated programmatically (using the
`faculty` dictionary, but you can achieve similar things by loading data files).

#figure(
  table(
    columns: 3,
    align: left + horizon,
    table.header([*Abbr.*], [*Polish name*], [*English name*]),
    ..faculties
      .pl
      .keys()
      .zip(faculties.pl.values(), faculties.en.values())
      .map(x => (x.at(0), x.at(1).join(" "), x.at(2).join(" ")))
      .flatten(),
  ),
  caption: [Faculties and their abbreviations to use in the settings of the thesis],
)<faculties-table>

== Example figures
=== Normal Figure
The reference system works using the same syntax for both citations and references to
document's elements. For example this is a reference to @cat_figure. And this is a
reference to this chapter: @Tutorial. And this is a reference to a label from a
different chapter: @supplementary (it just works). If you want to customize the supplement text you
can do so in such a way: "W @Tutorial[Rozdziale] znajduje się poradnik".

#figure(image("../images/cat1.png", width: 60%), caption: flex-caption(
  [This is a #strike[caption] beautiful cat named Miss Moneypenny ],
  [Picture of Miss Moneypenny (short description of the image for the list of figures)],
))<cat_figure>


=== Wrap-Content
#wrap-content(
  [#figure(image("../images/cat2.svg"), caption: [another caption])],
  [
    #lorem(100)

  ],
  align: right,
)



=== Sub-Figures
To achieve referencable subfigures it might be easier to use the
#link("https://typst.app/universe/package/subpar")[`subpar` package].

#figure(
  grid(
    columns: 2,
    row-gutter: 2mm,
    column-gutter: 1mm,
    image("../images/cat3.png", height: 200pt),
    image("../images/cat4.png", height: 200pt),

    "a) test 1", "b) test2",
  ),

  caption: "Caption",
)<label>

== Math

This is how you define inline math: $a^2 + b^2 = c^2$. For bigger equations you can use a math block, as you can see in @eq1.
$
  integral_(-oo)^(oo) f(x) d x = 1 \
  1 = 1
$<eq1>

For more math info see #link("https://typst.app/docs/reference/math/")[docs.]

== Tables
If you want to style tables, I recommend this #link("https://typst.app/docs/guides/table-guide/")[in-depth table guide.]
=== Normal Table
#align(center)[
  #table(
    columns: 3,
    align: center,
    table.header([Substance], [Subcritical °C], [Supercritical °C]),
    [Hydrochloric Acid],
    [12.0], [92.1],
    [Sodium Myreth Sulfate],
    [16.6], [104],
    [Potassium Hydroxide],
    table.cell(colspan: 2)[24.7],
  )]
=== Referenceable Table with a caption
#figure(
  table(
    columns: 3,
    align: center,
    table.header([Substance], [Subcritical °C], [Supercritical °C]),
    [Hydrochloric Acid],
    [12.0], [92.1],
    [Sodium Myreth Sulfate],
    [16.6], [104],
    [Potassium Hydroxide],
    table.cell(colspan: 2)[24.7],
  ),
  caption: "This is a caption",
)<my_table>

And this is a reference to @my_table.

#silentheading(4)[This is a silent level 4 heading]
This won't show up in the overview.

== Code

You can create listings from the embedded code like so:
#code-listing-figure(caption: [Hello world in the Python language])[
  ```py
  print("Hello World")
  ```
]

You can also load listings directly from source files, as in the @source-file-loaded.

#code-listing-file("collatz.rs", caption: [Collatz sequence])<source-file-loaded>

If you want to change the theme of the syntax highlighting you can set the
#link("https://typst.app/docs/reference/text/raw/#parameters-theme", `raw.theme`)
parameter. If you want to further customize the look of the code blocks you might want
to use a package like #link("https://typst.app/universe/package/codly")[`codly`] or
similar.


== Algorithms

In this example I use #link("https://typst.app/universe/package/lovelace", `lovelace`) package to typeset the algorithm but there are several
other packages which provide similar functionality. Algorithms are fully referenceable: @bogosort

#algorithm(caption: [The infamous Bogosort algorithm])[
  - *Require:* _deck_ is an unsorted array of integers
  - ~
  + *function* #smallcaps[bogosort];(_deck_) #comment[Optimized for speed]
    + *while* _deck_ *is not* sorted *do*
      + #smallcaps[shuffle];(_deck_)
    + *return* _deck_
]<bogosort>
