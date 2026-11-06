# Pillar

_Shorthand notations for table column specifications in [Typst](https://typst.app/)._


[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FMc-Zen%2Fpillar%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://typst.app/universe/package/pillar)
[![Test Status](https://github.com/Mc-Zen/pillar/actions/workflows/run_tests.yml/badge.svg)](https://github.com/Mc-Zen/pillar/actions/workflows/run_tests.yml)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Mc-Zen/pillar/blob/main/LICENSE)



- [Introduction](#introduction)
- [Column specification](#column-specification)
- [`pillar.cols()`](#pillarcols)
- [`pillar.table()`](#pillartable)
- [`vline` customization](#vline-customization)

## Introduction
With **pillar**, you can significantly simplify the column setup of tables by unifying the specification of the number, alignment, and separation of columns. This package is in particular designed for scientific tables, which typically have simple styling:

![Table of some piano notes and their names and frequencies](docs/images/piano-keys.svg)

In order to prepare this table with just the built-in methods, some code like the following would be required.
```typ
#table(
  columns: 5,
  align: (center,) * 4 + (right,),
  stroke: none,


  [Piano Key], table.vline(), [MIDI Number], [Note Name], [Pitch Name], table.vline(), [$f$ in Hz],
  ..
)
```
Using **pillar**, the same can be achieved with 
```typ
#table(
    ..pillar.cols("c|ccc|r"),

    [Piano Key], [MIDI Number], [Note Name], [Pitch Name], [$f$ in Hz], ..
)
```
or alternatively 
```typ
#pillar.table(
    cols: "c|ccc|r",

    [Piano Key], [MIDI Number], [Note Name], [Pitch Name], [$f$ in Hz], ..
)
```

**Pillar** is designed for interoperability. It uses the powerful standard tables and provides generated arguments for `table`'s `columns`, `align`, `stroke`, and for the specified vertical lines. This means that all features of the built-in tables (and also `show` and `set` rules) can be applied as usual. 




## Column specification

This package works with _column specification strings_. Each column is described by its alignment which can be `l` (left), `c` (center), `r` (right), or `a` (auto). 

The width of a column can optionally be specified by appending a (relative) length, or fraction in square brackets to the alignment specifier, e.g., `c[2cm]` or `r[1fr]`. 

Vertical lines can be added between columns with a `|` character. Double lines can be produced with `||` (see [`vline` customization](#vline-customization)). The stroke of the vertical line can be changed by appending anything that is usually allowed as a stroke argument in square brackets, e.g., `|[2pt]`, `|[red]` or `|[(dash: \"dashed\")]`. 

A column specification string may contain any number of spaces (e.g., to improve readability) — all spaces will be ignored. 

_If you find yourself writing highly complex column specifications, consider not using this package and resort to the parameters that the built-in tables provide. This package is intended for quick and relatively simple column specifications._


## `pillar.cols()`

This function produces an argument list that may contain arguments for `columns`, `align`, `stroke`, and `column-gutter` as well as instances of `table.vline()`. These arguments are intended to be expanded with the `..` syntax into the argument list of `table` as shown in the examples.  

## `pillar.table()`

This is a thin wrapper that behaves just like the built-in `table`, except that it extracts the first positional argument if it is a string, and runs it through `pillar.cols()`. 

## `vline` customization

In order to customize the default line setting, just use set rules on `table.vline`, e.g., 
```typ
#set table.vline(stroke: .7pt)

#table(..pillar.cols("c|cc"), ..)
```

Double lines are currently experimental and are realized through column gutters. They could also be realized through patterns, but this can produce artifacts with some renderers. As it currently is, double lines are not supported before the first and after the last column. On the other hand, with the current method, double lines are styled with set rules on `table.vline` which is nice and not achievable in the same way with patterns. 

## Examples

### Double lines
The following example uses a double line for visually separating repeated table columns. 
```typ
#pillar.table(
  cols: "ccc ||[.7pt] ccc",
  
  ..([\#], [$α$ in °], [$β$ in °]) * 2,
  table.hline(),
  [1], [34.3], [11.1],  [6], [34.0], [12.9],
  [2], [34.2], [11.2],  [7], [34.3], [12.8],
  [3], [34.6], [11.4],  [8], [33.9], [11.9],
  [4], [34.7], [10.3],  [9], [34.4], [11.8],
  [5], [34.3], [11.1], [10], [34.4], [11.8],
)
```

![Demonstration example using double vertical lines](docs/images/measurement-results.svg)

### Further customization

This example shows the codes of the first ten printable ASCII characters, demonstrating stroke and column width customization. 

```typ
#pillar.table(
  cols: "ccc|ccc|[1.8pt + blue] l[5cm]",
  
  [Dec],[Hex],[Bin],[Symbol], [HTML code], [HTML name], [Description],
  table.hline(),
  [32], [20], [00100000], [&#32;], [],         [SP], [Space],
  [33], [21], [00100001], [&#33;], [&excl;],   [!],  [Exclamation mark],
  [34], [22], [00100010], [&#34;], [&quot;],   ["],  [Double quotes],
  [35], [23], [00100011], [&#35;], [&num;],    [\#], [Number sign],
  [36], [24], [00100100], [&#36;], [&dollar;], [\$], [Dollar sign],
  [37], [25], [00100101], [&#37;], [&percnt;], [%],  [Percent sign],
  [38], [26], [00100110], [&#38;], [&amp;],    [&],  [Ampersand],
  [39], [27], [00100111], [&#39;], [&apos;],   ['],  [Single quote],
  [40], [28], [00101000], [&#40;], [&lparen;], [(],  [Opening parenthesis],
  [41], [29], [00101001], [&#41;], [&rparen;], [)],  [Closing parenthesis],
)
```

![Demonstration example using double vertical lines](docs/images/ascii-table.svg)

## Tests
This package uses [typst-test](https://github.com/tingerrr/typst-test/) for running [tests](tests/). 
