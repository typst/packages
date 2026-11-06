# `tbl.typ`
This is a library for [Typst](https://typst.app/) built upon Pg Biel's fabulous
[`tablex`](https://github.com/PgBiel/typst-tablex) library.

It allows the creation of complex tables in Typst using a compact syntax based
on the `tbl` preprocessor for the traditional UNIX TROFF typesetting system.
There are also some novel features that are not currently offered by Typst
itself or `tablex`, namely:

- Decimal point alignment (using the `decimalpoint` region option and
  `N`-classified columns)
- Columns of equal width (using the `e` column modifier)
- Columns with a guaranteed minimum width (using the `w` column modifier)
- Cells that are ignored when calculating column widths (using the `z` column
  modifier)
- Equation tables (using the `mode: "math"` region option)

Many other features exist to condense common configurations to a concise syntax.

For example:

````
#import "@preview/tbl:0.0.3"
#show: tbl.template.with(box: true, tab: "|")

```tbl
      R | L
      R   N.
software|version
_
     AFL|2.39b
    Mutt|1.8.0
    Ruby|1.8.7.374
TeX Live|2015
```
````

![](https://raw.githubusercontent.com/maxcrees/tbl.typ/v0.0.3/test/00/02_software.png)

Many other examples and copious documentation are provided in the
[`README.pdf`](https://maxre.es/tbl.typ/v0.0.3.pdf) file.

[The source repository](https://github.com/maxcrees/tbl.typ) also includes a
test suite based on those examples, which can be ran using the GNU `make`
command. See `make help` for details.
