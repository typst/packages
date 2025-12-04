#import "@preview/unified-uia-thesis:0.1.0": define, report

#show: report.with(
  meta: toml("meta.toml"),

  // anything that goes before the table of contents, like an abstract, acknowledgements, or the group declaration
  frontmatter: include "frontmatter.typ",

  references: bibliography("references.yml"),

  // anything that comes after the bibliography
  appendices: include "appendices.typ",

  // to hide the table of contents
  // contents: false,

  // to hide the listings
  // listings: false,
)

= Introduction

These are the examples from the original LaTeX template, converted to Typst.

== Some Typst examples
=== Using the Bibliography
This is an example of how to use the bibliography and citations. Cite to Einstein @einstein, or something else @dirac.

==== Appendices
You can also reference an appendix, like @appendix-1.

=== Writing Mathematics
This is some examples of how to write math in Typst.

$ y(x) = (sin x)/e^x $ <example>
We can refer to the equation by using the label, like this: @example

We can choose whether to number the equation or not, omitting a label will result in a non-numbered equation:
$ y(x) = (sin x)/e^x $

Lastly, we can write inline math: $y = a dot x + b$

=== Programming Code
Inline MATLAB code: `variabel = max(input)`

MATLAB code in section
#figure(
  ```matlab
    for i = 1 : 10
    % write code here
    end
  ```,
  caption: "Some code",
)

#pagebreak()
=== Inserting Tables
#figure(
  table(
    columns: 2,
    "Variable", "Value",
    $theta$, $10$,
    $omega$, $40$,
  ),
  caption: "The table caption",
) <table1>
This table can be referred to by using the label, like this: @table1.

=== Including Figures
#figure(
  image("UIA_no.svg", width: 70%),
  caption: "The figure caption",
) <image-label>
This figure can be referred to by using the label, like this: @image-label.

=== Multicolumn
#grid(
  columns: (1fr, 1fr),
  // or (50%, 50%), but this is funky with gutters.
  gutter: 1cm,
  [
    Text to describe for example a photo. Here we can write really long sentences just to prove the concept of the minipage, which is that the text will follow the width of the minipage that we have specified.

    In this case, each column has the same width, using the best unit of all time: the `fr` unit, with a `1cm` gutter between the columns:
    ```typst
    #grid(
      columns: (1fr, 1fr),
      gutter: 1cm,
      // content
    ```

    We don't have to manually position this text, but if you wanted to, you could use the command `#v()` with the amount to shift by, like `#v(1cm)` or `#v(1fr)`
    #v(2em)
    Here's some text that's after a `#v(2em)`.
  ],
  image("UIA_no.svg"),
)

// theory, methods, results, discussions, conclusions

=== Using the Glossary
To add entries to a glossary after the contents, use the `define()` function where you use the word first, or where it's most suitable to define it. Here is a #define("definition", "A statement of the exact meaning of a word, especially in a dictionary."), defined using:
```typ
#define("definition", "A statement of the exact meaning of a word, especially in a dictionary."
```
