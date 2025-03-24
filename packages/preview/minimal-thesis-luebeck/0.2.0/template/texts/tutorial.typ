#import "@preview/abbr:0.1.1"

#set heading(numbering: "1.1")

= Example Section <sec:tutorial>
This section contains some example content to show you how to use Typst to write your thesis.

== Bold and Italic font
In Typst, you can write text in *bold* or _italic_ font by using simple Markdown symbols.

== Line breaks
By leaving a line blank in your `.typ`-file, you can create a new *paragraph*. This should be the default way of structuring your text. In LaTeX, this would be `\par`.

You can also create a simple line break by adding a backslash `\` at the end of a line.\
This is usually not recommended.

== Figures <sec:figures>
Figures are referenced like this: @fig:findus shows a funny cat.

#figure(
  image("../images/top-right.png", width: 30%),
  caption: "This is the figure caption."
) <fig:findus>

Unlike LaTeX, Typst does not have floating figures. Instead, figures are placed where they are defined.

Also, Typst currently cannot embed PDF-files. However, you can still use SVG.

== Citations and references
Citations are referenced like this: `@alley1996craft` is a great book about writing scientific reports (proper citations sadly do not work in this tutorial).\
Note that the bibliography tag stems from the `thesis.bib` file.\
Also, sections can be referenced like this: @sec:figures and @sec:tutorial

== Equations
Equations are written like this:
$sum_i^infinity (f^(\(n\))(a))/(n!) (x-a)^n$.\
Note that adding a space around the equation places it in the center of the page:
$ sum_i^infinity (f^(\(n\))(a))/(n!) (x-a)^n $

Equations can be aligned using `&` for alignment and `\` for line breaks:
$ sum_i^infinity (f^(\(n\))(a))/(n!) (x-a)^n &= f(a)
  + (f'(a))/(1!) (x-a)
  + (f''(a))/(2!) (x-a)^2
  + ...\
  &= ...
$

== Math Symbols
In Typst, math symbols are written differently than in LaTeX. For instance, many symbols are written using their names rather than special characters. Here are some examples:

- Greek letters: $alpha$, $beta$, $gamma$, $delta$, $epsilon$
- Operators: $sum$, $product$
- Relations: $<$, $>$, $!=$, $approx$
- Functions: $sin$, $cos$, $tan$, $log$, $exp$

== Abbreviations
Typst supports abbreviations like this: #abbr.pla[PDE] are important in mathematics. To use the singular, use `abbr.a` (auto) and for plural `abbr.pla`.\
Note that a list of all abbreviations shall be written in `texts/abbreviations.typ`.

== Enumerations and bullet points
Enumerations are written like this:
+ First item
  + First subitem
  + Second subitem
+ Second item
+ Third item

You can also have numbers in subitems:
#set enum(full: true)
+ First item
  + First subitem
  + Second subitem
+ Second item

Bullet points are written like this:
- First item
- Second item
- Third item

== Tables
Tables in Typst are written like this:
#figure(
  table(
    columns: 2,
    [*Header 1*], [*Header 2*],
    [Row 1, Cell 1], [Row 1, Cell 2],
    [Row 2, Cell 1], [Row 2, Cell 2],
    [Row 3, Cell 1], [Row 3, Cell 2],
  ),
  caption: "This is the table caption."
) <tab:example-table>

You can reference @tab:example-table as usual.

== Symbols
There is a wide catalog of symbols available in Typst. For example, #sym.arrow.r gives an arrow.
Use the smart suggestions of your editor to find more symbols like #sym.alpha.

== Code
Source code can be typeset like this:
```python
def main():
  print("Hello Typst!")
```
However, this is not well-suited for large pieces of code.
