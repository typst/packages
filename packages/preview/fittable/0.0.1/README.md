# fittable

A [Typst](https://typst.app/) package distributing leftover space of table or grid into `auto` columns.

## Usage

```typ
#import "@preview/fittable:0.0.1": fit

#let data = (
  [Item], [Description], [Price],
  [Notebook], [A notebook with a long description], [12.00],
)

#fit(
  columns: (auto, auto, 5em),
  table.header([*Item*], [*Description*], [*Price*]),
  ..data,
)
```

## API

### `fit`

```typ
fit(
  func: table,
  columns: (),
  ..children,
) -> content
```

Lays out a table or grid while distributing the available horizontal space among its `auto` columns. If the content does not fit, the original column specification is used instead.

#### Parameters

- `func` (`table | grid`): The layout function to use. Defaults to `table`.
- `columns` (`auto | int | relative | fraction | array`): The column specification accepted by `table` or `grid`. An integer creates that many `auto` columns. Each `auto` column receives an equal share of the remaining width; fractional columns participate according to their fraction.
- `children` (`arguments`): Cells and named arguments forwarded to `func`.

`table.header`, `table.footer`, `table.hline`, and `table.vline` are recognized when measuring table contents. Cells using `colspan` or `rowspan` are not currently supported.

To fit a grid instead of a table:

```typ
#fit(
  func: grid,
  columns: (auto, 2fr, auto),
  gutter: 8pt,
  [Left],
  [Flexible center],
  [Right],
)
```
