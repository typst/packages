// An opinionated 3rd party library for rendering prettier source code blocks.
// You may get rid of it or replace it with something else if you like.
// https://typst.app/universe/package/codly
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#show: codly-init.with()

// Configure codly. Optional.
#codly(
  languages: (
    c: (name: [C], color: black),
    cpp: (name: [C++], icon: none, color: black),
    py: (name: text(rgb("#003070"))[Python], color: blue),
    rust: (name: text(red)[Rust], color: rgb("#CE412B")),
  )
)
#codly-disable()

= More tips for writers

== Quick rules for better style

- Do not use headings above level 3 (`====` is very bad). If you _really_ need more, then:
  1. You probably don't. Rethink your document structure.
  2. You _really_ probably don't. See above.
  3. Use unnumbered headings or terms lists.

- Do not overuse *strong* (or *bold*) text. It is distracting for the reader
  and blends in with headings. For emphasis, use _emphasis_. Duh.

- Use a _hyphen_ '-' (`-`) for connecting words only (e.g. "semi-automatic").

- Use _en dash_ '--' (`--`) for pause (e.g. "make no mistake -- it's easy").
  - In American typography, _em dash_ '---' (`---`) often serves this purpose,
    and it is used without surrounding spaces, e.g. "make no mistake---it's
    easy". Use either style, but stick to one and one only!

- Make sure that all negative numbers in your prose are typeset using the correct
  minus sign, i.e. "-1", and not a regular hyphen: "\-1". Typst does this
  automatically in most cases, but the distinction is important to know. If
  you want the regular hyphen for some special reason and need to circumvent
  Typst's automatic substitution, escape the sign: "`\-`".

- Use ```typst #block(breakable: false)[ ... ]``` for content that should stay
  on the same page, e.g.: #align(center)[
  ```typst
  #block(breakable: false)[
    And this is a paragraph that leads into a listing, and it would look
    really awkward if it got separated from it by a page break:

    - item A
    - item B
    - item C
  ]
  ```]

- The title of the thesis should occupy 2 lines at maximum and each line should
  ideally be a full phrase (avoid oddly broken sentences).

- Fix all Typst compilation warnings (unless they come from packages).

- Make sure all relevant literature is present in the bibliography file
  (`*.bib` or #link("https://github.com/typst/hayagriva/blob/main/docs/file-format.md")[\*.yml])
  and referenced with the `@` syntax or the ```typst #cite()``` function.

- Place footnotes _after_ the period terminating a sentence, not
  before.#footnote[Like so! Also, do not overuse footnotes.]

- Figure titles (tables, images, code listings, etc.) should end with a period.

- Names of files, paths, directories, variables, functions, classes, etc.
  should be typeset in `a_monospace_font`. Typst supports inline code
  highlighting: ```c main(int argc, char **argv)```.

- Use non-breaking space (typeset using tilde "`~`") to prevent awkward line
  endings. In particular, before every`~@ref` that appears in the middle of a
  sentence.

- Use non-breaking space after periods which do not terminate a sentence, e.g.
  "`e.g.~`", "`w.r.t.~`", "`i.e.~`", etc. In Polish #text(lang: "pl")[`np.~`", "`tj.~`",
  etc.]

- In American typography, closing quotes and footnotes are placed _after_
  adjacent punctuation. This is not a recommendation, but something to
  consider. Example sentence:
    - It can be called "curiosity," but it's actually normal.

== Numbered, unnumbered, terms, tight and wide lists
Typst has numbered, unnumbered and terms lists. All 3 types also can be tight
or wide:

#figure(
  table(
    columns: (4),
    stroke: none,
    align: (left + horizon),
    table.hline(),
    table.header[][*Numbered*][*Unnumbered*][*Terms*],
    table.hline(),
    [*Tight*],
    [
      Paragraph before.
      1. One
      2. Two
      3. Three
      Paragraph after.
    ],
    [
      Paragraph before.
      - One
      - Two
      - Three
      Paragraph after.
    ],
    [
      Paragraph before.
      / One: This is 1.
      / Two: This is 2.
      / Three: This is 3.
      Paragraph after.
    ],
    table.hline(),
    [*Wide*],
    [
      Paragraph before.
      1. One

      2. Two

      3. Three
      Paragraph after.
    ],
    [
      Paragraph before.
      - One

      - Two

      - Three
      Paragraph after.
    ],
    [
      Paragraph before.
      / One: This is 1.

      / Two: This is 2.

      / Three: This is 3.
      Paragraph after.
    ],
    table.hline(),
  ),
  placement: none,
  caption: [Comparison of list types in Typst],
)

Numbering of lists can be done explicitly or automatically. Both examples below
are equivalent:

#align(center, block(width: 5cm)[
  #place(left)[
    ```typst
    // Explicit
    1. One
    2. Two
    3. Three
    ```
  ]
  #place(right)[
    ```typst
    // Automatic
    + One
    + Two
    + Three
    ```
  ]
  #v(17mm)
])

#block(breakable: false)[
  For more information, refer to:
  - https://typst.app/docs/reference/model/list/ ~// Add invisible space in regular font; workaround for ugly vertical spacing caused by https://github.com/typst/typst/issues/1204
  - https://typst.app/docs/reference/model/enum/ ~
  - https://typst.app/docs/reference/model/terms/ ~
]

== Math equations

Typst has native support for typesetting math equations. In the wide majority
of cases, it works perfectly fine and is very intuitive to use. However, it is
not yet as mature and battle-tested as LaTeX's engine, so more demanding use
cases may require manual tweaking or call for better tools.

Example: the quadratic equation shown in~@eq:quadratic.

$
  x = (-b plus.minus sqrt(b^2 - 4 a c)) / (2 a)
$ <eq:quadratic>

And the arc length of a continuous function can be calculated using
@eq:arc-length.

$
  S = integral_a^b sqrt(1 + (f'(x))^2) dif x
$ <eq:arc-length>

== Plots and images
Typst has native support for various image formats. Vector formats such as SVG
are preferred over raster ones, unless there is a good reason against it (e.g.
an extremely high number of objects which slows down the document).
#footnote[A comparison of various graphics formats (in Polish): https://www.youtube.com/watch?v=_98SDNIpm24]

#block(breakable: false)[
  As a rule of thumb, figures should be placed at the top of a page, where they
  do not disrupt the flow of reading. Typst can and will do this automatically in
  this template, similar to LaTeX. To enforce a placement of a figure, override
  the `placement` option of the ```typst #figure()``` function, like so:
  #align(center)[
    ```typst
    #figure(
      ...,
      placement: none,  // Other settings: top (default), bottom, auto
    )
    ```
  ]
]

For plotting, there are native 3rd party libraries such as
#link("https://typst.app/universe/package/cetz-plot")[cetz-plot], although it
may be better to use an independent, mature plotting framework such as Gnuplot,
ggplot2, or Matplotlib and export SVG images.#footnote[A short lecture on
  plotting best practices (in Polish):
  https://www.youtube.com/watch?v=pfSgcsQ2Mtk]

#figure(
  image("../img/plot.svg", width: 80%),
  caption: [Sine wave (made with Gnuplot)],
)

More information on figures:
- https://typst.app/docs/reference/model/figure ~// Add invisible space in regular font; workaround for ugly vertical spacing caused by https://github.com/typst/typst/issues/1204

== Tables
Tables should also be enclosed in ```typst #figure()``` functions, to enable
giving them captions and referring to them. They are little trickier to
typeset, but Typst has good documentation which you are encouraged to read:
https://typst.app/docs/reference/model/table/.

You will notice that table captions are placed _above_ their content, not below
like with the rest of figures. This is the official way endorsed by Poznań
University of Technology.

#block(breakable: false)[
  Here is an example on how to define @tab:example:
  #columns(2)[
    ```typst
    #figure(
      table(
        columns: 2,
        align: (left, right),
        stroke: none,
        table.hline(),
        table.header[*Item*][*Price* [zł]],
        table.hline(),
        [bread], [5.40],
        [butter], [6.20],
        table.hline(),
      ),
      caption: [This is my table],
    ) <tab:example>
    ```
    #colbreak()
    #figure(
      table(
        columns: 2,
        align: (left, right),
        stroke: none,
        table.hline(),
        table.header[*Item*][*Price* [zł]],
        table.hline(),
        [bread], [5.40],
        [butter], [6.20],
        table.hline(),
      ),
      caption: [This is my table],
    ) <tab:example>
  ]
]

=== Aligning number columns
For tables containing number columns, the numbers should be vertically aligned
with respect to the decimal point, for visual aid. Unfortunately, as of Typst
0.13.0, there is no built-in way to achieve this
(see~https://github.com/typst/typst/issues/170).

One workaround is aligning number columns to the right and manually giving them
proper padding (with 0s or fixed-width spaces). If that is not enough, you may
use a community package, e.g.
#link("https://typst.app/universe/package/zero")[zero].

== Source code
#{
set text(size: 8pt)
block(inset: (left: 5mm, right: 5mm), rect(radius: 5pt)[
  *Disclaimer*\
    The opinions on programming languages present in this section are personal
    biases of the template author and~are not officially endorsed by Poznań
    University of Technology. They were left in with humorous intent.
])
}
Much like tables and images, source code typically resides within a
```typst #figure()``` function, where it can be captioned and labeled.
Typst has native support for source code blocks, with syntax highlighting
readily available for a plethora of programming languages.

#block(breakable: false)[
  Out-of-the-box, it looks like this:
  #figure(
    ```c
    #include <stdio.h>

    int main(int argc, char **argv)
    {
      printf("Hello, world!\n");
      return 0;
    }
    ```,
    caption: [The best program, written in the C programming language.],
    placement: none,
  ) <hello-c>
]

For extra punch, we can use a 3rd party package such as
#link("https://typst.app/universe/package/codly")[codly] to prettify the output
and get more features such as highlighting parts of our code.

#codly-enable()
While~@hello-c is written in the best programming language, here is a version
in a much inferior, offspring language, C++:

#codly(highlights: ((line: 5, start: 3, fill: red),))
#figure(
  ```cpp
  #include <iostream>

  int main(int argc, char **argv)
  {
    std::cout << "Hello, world!" << std::endl;
    return 0;
  }
  ```,
  caption: [The best program, made slightly worse.],
  placement: none,
) <hello-cpp>

Highlighted red, you can see one of the earliest red flags in the design of the
C++ language.

Scripting languages also deserve credit. @hello-python showcases a
version of the same program, this time written in Python.

#figure(
  ```py
  print("Hello, world!")
  ```,
  caption: [The best program, for the lazy.],
  placement: none,
) <hello-python>

Coincidentally, @hello-python also happens to be valid code in Lua, doing
exactly the same thing!

Last but not least, let us consider a representative of a newer front of
memory-safe languages, Rust. The code is demonstrated in~@hello-rust.

#figure(
  ```rust
  fn main() {
    println!("Hello, world!");
  }
  ```,
  caption: [The best program, memory safe#footnote[Well, more or less. See~@cve-rs.]],
  placement: none,
) <hello-rust>
#codly-disable()

== Indented paragraphs
By default, Typst (and this template) separate paragraphs with vertical spacing.
If you prefer new paragraphs to be indented instead, you may use this code
snippet at the top of your document:

```typst
#set par(
  first-line-indent: 2em, // Adjust to taste
  spacing: 0.65em,
)
#set block(spacing: 1.2em)
```
This adds a first line indent and gets rid of the vertical spacing.

By default, only the first line of a consecutive paragraph will be indented
(not the first one in the document or container, and not paragraphs immediately
following other block-level elements). To~indiscriminately indent all
paragraphs, you may modify the `set` statement like so:

```typst
#set par(
  first-line-indent: (amount: 2em, all: true),
)
```

More information on paragraphs:
- https://typst.app/docs/reference/model/par/

== Typst Reference
The Typst project hosts an excellent online reference which does a good job
explaining every feature of the language. You are encouraged to consult it,
should any questions arise~@typst-reference: \
https://typst.app/docs/reference
