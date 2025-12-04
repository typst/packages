# typst-sela

[Select](https://typst.app/docs/reference/foundations/selector/) elements whose [fields](https://typst.app/docs/reference/foundations/function/#definitions-where) have any of the given values, without repeating [`selector.or`](https://typst.app/docs/reference/foundations/selector/#definitions-or).

## Scenario

Suppose you want the first three levels of headings to be centered, you might write:

```typst
#show (
  heading.where(level: 1)
    .or(heading.where(level: 2))
    .or(heading.where(level: 3))
): set align(center)

// Alternative:
#show selector.or(
  ..(1, 2, 3).map(n => heading.where(level: n)),
): set align(center)
```

But with this package, you can do it more easily and naturally:

```typst
#import "@preview/sela:0.1.0": sel, any
#show sel(
  heading.where(level: any(1, 2, 3)),
): set align(center)
```

1. Put `any(..values)` in the field for the [`where` selector](https://typst.app/docs/reference/foundations/function/#definitions-where).
2. Wrap the selector in `sel(…)`.

## More examples

Use [`..range(1, 4)`](https://typst.app/docs/reference/foundations/array/#definitions-range) to programmatically select the first three levels of headings:

```typst
#show sel(
  heading.where(level: any(..range(1, 4))),
): set text(…)
```

Mix different types of values in `any(table, "atom")` to scope a [caption customization](https://typst.app/docs/reference/model/figure/#caption-customization) rule to two kinds of figures.

```typst
#show sel(
  figure.where(kind: any(table, "atom")),
): set figure.caption(position: top)
```

Use two `any` calls in a single `sel` to select the rectangular area {1,2} × {1,2,3,4} in a [table](https://typst.app/docs/guides/table-guide/).

```typst
#{
  show sel(
    table.cell.where(x: any(1, 2), y: any(..range(1, 5))),
  ): set text(style: "italic")

  table(…)
}
```

Use `selector.or` to combine `sel(…)` with other [selectors](https://typst.app/docs/reference/foundations/selector/):

```typst
#show selector.or(
  sel(heading.where(level: any(2, 3))),
  <appendix>,
  <postscript>,
): set text(font: …)
```

## Use cases for other packages and the canonical Typst

Sometimes you don't need this package.

Use [numbly](https://typst.app/universe/package/numbly) or [numblex](https://typst.app/universe/package/numblex) to specify different numbering formats for different levels of [headings](https://typst.app/docs/reference/model/heading/#parameters-numbering) or [numbered lists](https://typst.app/docs/reference/model/enum/#parameters-numbering):

```typst
#import "@preview/numbly:0.1.0": numbly
#set heading(numbering: numbly(
  "Chapter {1:A}",
  "Section {1:A}.{2}",
  "Topic {3}.",
))
```

Use [an array of values or a function like `(x, y) => value`](https://typst.app/docs/guides/table-guide/#fills) to customize `align`, `inset`, `fill`, `stroke` for tables and grids:

```typst
#table(
  // By an array of values (cycling)
  fill: (rgb("#239dad50"), none),
  // By a function that returns a value
  stroke: (x, y) => if calc.rem(x + y, 3) == 0 { 0.5pt },
  …
)
```

## Known limitations

### Selectors for `grid.cell`

This package cannot distinguish between `table.cell.where(…)` and `grid.cell.where(…)` selectors due to [certain limitations](https://forum.typst.app/t/how-to-distinguish-between-table-cell-where-and-grid-cell-where-selectors/6179).

Considering that show rules for `grid.cell` are rare and [discouraged](https://github.com/typst/typst/pull/6764#discussion_r2333294995), this package will interpret all cells as `table.cell` by default.
If you really mean `grid.cell`, you can pass the definition to the `scope` parameter of the `sel` function:

```typc
sel(
  grid.cell.where(x: any(1, 2)),
  scope: (cell: grid.cell),
)
```

### No hint if `sel` is missing

`any` relies on `sel` to take effect.

If you forget to call `sel`, then the selector is still a valid Typst code, but it will match nothing.

### Silent type error

If you pass nonsense values to `any`, then they will be ignored and no error or warning will be raised.

```typc
sel(heading.where(level: any(3, "nonsense", "values")))

// Effective equivalents:
// - sel(heading.where(level: any(3)))
// - heading.where(level: 3)
```

## Implementation details

This package is a quadruple hack.

1. It exploits the Typst syntax for `where` selectors.
2. It uses `repr` to inspect selectors, but `repr` is for debugging purposes and its output [“should not be considered stable and may change at any time”](https://typst.app/docs/reference/foundations/repr/).
3. It uses [`regex`](https://typst.app/docs/reference/foundations/regex/) to parse the output of `repr`, which can be fragile.
4. It uses [`eval`](https://typst.app/docs/reference/foundations/eval/) to create selectors.

The package is surreal in the Typst Universe, and thus the name [Sela](https://memory-alpha.fandom.com/wiki/Sela).

However, the scope of this package is quite limited and we don’t put complicated things in `where` selectors. Moreover, `sel` and `any` are simple pure functions and they have been tested reasonably.

Therefore, this package is safe for everyday usage. (It might be even safer than many styling packages that parse `content` or use complicated function to reconstruct `ref` and `counter`.)
