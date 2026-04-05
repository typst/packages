# color-table

A drop-in replacement for Typst tables with automatic color-coded numeric cells (heatmap style).

## Examples

### Basic Usage

Replace `table` with `color_table` to automatically color-code numeric cells. Higher values appear darker, lower values appear lighter.

```typst
#import "@preview/color-table:1.0.0": color_table

#color_table(
  columns: 4,
  align: center,
  inset: 8pt,
  [Parameter], [Test 1], [Test 2], [Test 3],
  [$alpha$], [2.3], [4.3], [4.0],
  [$beta$], [2.1], [3.2], [4.2],
  [$gamma$], [4.3], [3.3], [1.3],
)
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/gabrielalexandrelopes/typst-color-table/main/images/drop-in-dark.png">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/gabrielalexandrelopes/typst-color-table/main/images/drop-in.png">
  <img alt="Standard table vs ColorTable comparison" src="https://raw.githubusercontent.com/gabrielalexandrelopes/typst-color-table/main/images/drop-in.png">
</picture>

### Row-Independent Normalization with Multiple Colors

Use `independent: "row"` to normalize colors within each row separately. Combine with an array of `base_color` to assign different colors per row:

```typst
#color_table(
  columns: 5,
  align: center,
  inset: 8pt,
  base_color: (red, green, blue),
  independent: "row",
  [Metric], [Q1], [Q2], [Q3], [Q4],
  [Revenue], [120], [145], [180], [210],
  [Costs], [80], [75], [90], [85],
  [Margin], [40], [70], [90], [125],
)
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/gabrielalexandrelopes/typst-color-table/main/images/independent-dark.png">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/gabrielalexandrelopes/typst-color-table/main/images/independent.png">
  <img alt="Row-independent normalization example" src="https://raw.githubusercontent.com/gabrielalexandrelopes/typst-color-table/main/images/independent.png">
</picture>

Each row uses its own color and normalization range, making it easy to compare relative values across different metrics.

## API

### `color_table`

A drop-in replacement for `table` that automatically applies heatmap coloring to numeric cells.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `columns` | `int` | `2` | Number of columns in the table |
| `base_color` | `color` or `array` | `blue` | Base color(s) for the heatmap. When an array is provided, colors cycle based on `independent` mode |
| `independent` | `string` or `none` | `none` | Normalization mode: `"row"` (per-row), `"column"` (per-column), or `none` (global) |
| `rows` | `auto` or `array` | `none` | Row sizing (passed to underlying table) |
| `gutter` | `length` | `none` | Gap between cells |
| `column_gutter` | `length` | `none` | Gap between columns |
| `row_gutter` | `length` | `none` | Gap between rows |
| `fill` | `color` | `none` | Background fill for non-numeric cells |
| `align` | `alignment` | `none` | Cell alignment |
| `stroke` | `stroke` | `none` | Cell borders |
| `inset` | `length` | `none` | Cell padding |

#### Normalization Modes

- **Global** (`independent: none`): All numeric cells are normalized together. The highest value across the entire table is darkest.

- **Row** (`independent: "row"`): Each row is normalized independently. Useful when rows represent different metrics with different scales.

- **Column** (`independent: "column"`): Each column is normalized independently. Useful when comparing performance across categories.

#### Color Array Behavior

When `base_color` is an array:
- With `independent: "row"`: Colors cycle per row (row 0 uses color 0, row 1 uses color 1, etc.)
- With `independent: "column"`: Colors cycle per column
- With `independent: none`: Only the first color is used

### Examples

#### Custom Base Color

```typst
#color_table(
  columns: 3,
  base_color: red,
  [A], [B], [C],
  [10], [50], [30],
  [25], [15], [45],
)
```

#### Column-Independent with Multiple Colors

```typst
#color_table(
  columns: 4,
  base_color: (gray, orange, green, blue),
  independent: "column",
  [Region], [Sales], [Returns], [Rating],
  [North], [450], [12], [4.2],
  [South], [380], [8], [4.5],
  [East], [520], [15], [3.9],
  [West], [410], [10], [4.1],
)
```

#### With Table Elements

Table elements like `table.hline()` and `table.vline()` are supported:

```typst
#color_table(
  columns: 3,
  stroke: 0.5pt + gray,
  table.hline(stroke: 2pt),
  [Header 1], [Header 2], [Header 3],
  table.hline(stroke: 2pt),
  [10], [20], [30],
  [15], [25], [35],
)
```

## Notes

- Non-numeric cells (text, math expressions, etc.) pass through without coloring
- Numeric detection works with integers, floats, and content containing numeric strings
- All standard Typst table arguments are supported
