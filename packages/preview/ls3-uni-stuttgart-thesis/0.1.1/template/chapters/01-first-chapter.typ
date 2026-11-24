= First Chapter

This test sentence is supposed to span more than one line. Or maybe, we need
another sentence for this. And why, you ask, do we need several lines at all?
Well, to test the line spacing, of course! Let's have an in-text citation
@kalman1960new and another one here @matheron1963principles. Citation style and
how parentheses are rendered are controlled by the bibliography style passed
to `thesis(..., bib: bibliography("references.bib", style: "..."))`. For a
prose-style citation that renders the author inline you can also write
#cite(<kalman1960new>, form: "prose"), which produces "Kalman (1960)".

We can have enumerations:

+ First important item.
+ Second important item.

and lists:

- Item one.
- Item two.

or how about a description list:

/ big: is the opposite of small.
/ small: is the opposite of big.

To demonstrate the `@preview/abbr` package, here is a first reference to an
@IS, which expands to its full form with the short form in parentheses.
A second mention of @IS now renders as just the short form. The plural is
@IS:pla. To force the long form again, write @IS:l. Abbreviations are
defined once in `main.typ` via `abbr.make(...)`.

*A mini section*

Gives you a small heading that is not separated too much from the previous
text. This kind of mini-section is not part of the table of contents. Please
have a look at @table-example for an example table.

#figure(
  table(
    columns: 4,
    align: left,
    stroke: none,
    [This], [is], [an], [example.],
    table.hline(),
    [Just], [useless], [content], [here.],
  ),
  caption: [An example table.],
) <table-example>

Regarding references, write `@label` anywhere in the text to insert a clickable
reference. Typst figures out the supplement ("Table", "Figure", "Equation",
"Chapter", ...) automatically based on what the label is attached to.

== Equations

Typst's math mode is delimited by `$ ... $` for inline and `$ ... $` with
spaces inside for a display equation. Display equations can be labeled and
referenced.

For a single labeled equation on its own line:

$ x^2 + y^2 = r^2 $ <eq-circle>

For several equations on separate lines that should not be aligned, use `\`
to break:

$ x^2 + y^2 = r^2 \
  r = 1 $

For aligned equations, use `&` to mark the alignment column:

$ r^2 &= x^2 + y^2 \
  r &= 1 $

Equations referenced from text use the `@` syntax, for example @eq-circle.

== Figures

Use Typst's `figure(...)` element to wrap any image. Captions, labels, and
cross-references work the same as for tables.

#figure(
  image("../assets/placeholder-figure.pdf", width: 60%),
  caption: [A placeholder figure showing a sine plus cosine curve.],
) <fig-placeholder>

To place two figures side by side, nest a `grid(...)` of `image(...)` calls
inside one `figure(...)`, or import the `@preview/subpar` package for full
sub-figure labels and cross-references.

When sizing figures, useful Typst values include:

/ `100%`: Width of the current container.
/ `1fr`: A fractional unit that expands to fill available horizontal space.
/ `8cm` or `120mm`: Absolute lengths.
/ no `width:` argument: Uses the image's natural size.

If you reference a figure from another page, write `@fig-placeholder` and
Typst inserts the figure number. To also report the page (the `varioref`
equivalent in LaTeX), ask your supervisor whether they want the "on page X"
suffix; if so, a small helper can be added to the thesis template.

== Source code listings

Typst has fenced code blocks that highlight syntax automatically. Inline code
uses backticks like `sqrt(x.^2)`, and longer listings render in a monospaced
block with line numbers via the `@preview/codly` package. A listing without
`#figure(...)` around it is not numbered and does not appear in the list of
listings, similar to LaTeX's `lstlisting` with a title but no caption.

```matlab
for i = 1:10
    fprintf('Look, a number: %i\n', i);
end
```

Bigger listings benefit from being wrapped in `figure(...)` so they appear in
the list of listings and receive a numbered caption that can be referenced.
See @code-python for an example.

#figure(
  ```python
  for i in range(10):
      print('Look, a number: %i' % i)
  ```,
  caption: [A simple Python program.],
) <code-python>
