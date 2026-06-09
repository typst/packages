# akatable

A Typst package for creating clean academic tables with built-in publisher format presets.

Akatable wraps Typst's native `table` in a single `academic-table` function that automatically handles the three-line rule pattern (top, header-bottom, bottom) used across scientific publishing, along with proper figure captioning. Choose a format preset and the stroke weights and caption style match the target publisher's guidelines.

## Quick start

```typst
#import "@preview/akatable:0.1.0": academic-table

#academic-table(
  [Population of major cities],
  header: ([City], [Country], [Pop. (M)]),
  (
    [Tokyo],     [Japan],  [13.96],
    [Delhi],     [India],  [11.03],
    [Shanghai],  [China],  [24.87],
  ),
  columns: 3,
)
```

This produces a `booktabs`-style table by default: heavy top and bottom rules, a lighter mid-rule below the header, caption above.

## API reference

### `academic-table`

```typst
#academic-table(
  caption,          // content – table caption (required, positional)
  cells,            // array – body cell contents (required, positional)
  format: "apa", // string – format preset name
  header: (),       // array – header cell contents (recommended)
  footer: (),       // array – footer cell contents
  label: none,      // label – for cross-referencing
  ..args            // any extra arguments forwarded to Typst's table()
)
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `caption` | `content` | *(required)* | The table caption, placed above the table inside a `figure`. |
| `cells` | `array` | *(required)* | Flat array of cell contents. Supports `table.cell()`, `table.hline()`, and plain content. |
| `format` | `string` | `"booktabs"` | One of the 8 built-in format presets (see below). |
| `header` | `array` | `()` | Header cells. Supports `table.cell(colspan: ..)`, `table.cell(rowspan: ..)`, and `table.hline()` for multi-row headers. |
| `footer` | `array` | `()` | Footer cells. Rendered below the body with a separating rule. |
| `label` | `label` | `none` | Typst label for cross-referencing (e.g. `<tab:results>`). |
| `..args` | | | Any other named argument is passed through to the underlying `table()`. Most commonly: `columns`, `align`, `inset`, `row-gutter`. |

### How the three-line rules work

Akatable uses `table.hline()` elements injected around the header — no stroke callback needed. This means multi-row headers (with `colspan`/`rowspan`) work correctly out of the box:

- **Top rule** — placed at the start of `table.header()`
- **Mid rule** — placed at the end of `table.header()`, auto-attaches after the last header row
- **Bottom rule** — placed after the last body cell (or around the footer)

## Format presets

Use `format: "name"` to switch between publisher styles. Each preset controls rule stroke weights and caption formatting.

### Stroke weights

| Format | Top rule | Mid rule | Bottom rule | Family |
|---|---|---|---|---|
| `booktabs` | 1.5pt | 0.75pt | 1.5pt | heavy/light/heavy |
| `apa` | 1pt | 1pt | 1pt | uniform |
| `ieee` | 1.5pt | 0.75pt | 1.5pt | heavy/light/heavy |
| `acs` | 1.5pt | 0.75pt | 1.5pt | heavy/light/heavy |
| `nature` | 1.5pt | 0.75pt | 1.5pt | heavy/light/heavy |
| `elsevier` | 1.5pt | 0.75pt | 1.5pt | heavy/light/heavy |
| `chicago` | 1pt | 1pt | 1pt | uniform |
| `acm` | 1.5pt | 0.75pt | 1.5pt | heavy/light/heavy |

### Caption formatting

| Format | Label example | Title style | Alignment |
|---|---|---|---|
| `booktabs` | Table 1: | plain | left |
| `apa` | **Table 1** | *italic* (new line) | left |
| `ieee` | TABLE I | ALL CAPS (new line) | center |
| `acs` | **Table 1.** | plain | left |
| `nature` | **Table 1** \| | plain | left |
| `elsevier` | Table 1. | plain | left |
| `chicago` | Table 1. | plain | left |
| `acm` | **Table 1.** | plain | left |

### Usage

```typst
// APA style
#academic-table(
  [Descriptive statistics by group],
  header: ([Variable], [M], [SD]),
  ([Age], [34.2], [5.1], [Income], [52,000], [12,300]),
  format: "apa",
  columns: 3,
)

// IEEE style
#academic-table(
  [Comparison of classification accuracy],
  header: ([Method], [Precision], [Recall], [F1]),
  ([SVM], [0.92], [0.89], [0.90], [Random Forest], [0.95], [0.93], [0.94]),
  format: "ieee",
  columns: 4,
)
```

## Advanced examples

### Multi-level headers

Use `table.cell(colspan: ..)` and `table.cell(rowspan: ..)` inside the `header` array to create grouped column headers:

```typst
#academic-table(
  [Clinical outcomes by treatment group],
  header: (
    table.cell(rowspan: 2)[Metric],
    table.cell(colspan: 2, align: center)[Treatment A],
    table.cell(colspan: 2, align: center)[Treatment B],
    table.hline(),
    [Before], [After], [Before], [After],
  ),
  (
    [Weight (kg)], [72.1], [68.3], [71.8], [70.2],
    [BMI],         [24.5], [22.1], [24.3], [23.8],
  ),
  columns: 5,
)
```

### Grouped rows with subtotals

Use `table.hline()` and `table.cell(colspan: ..)` inside the `cells` array for visual grouping:

```typst
#academic-table(
  [Project budget by category],
  header: ([Category], [Item], [Year 1], [Year 2]),
  (
    [Personnel], [Salaries],  [45,000], [46,000],
    [],          [Benefits],  [12,000], [12,500],
    table.hline(stroke: 0.5pt),
    table.cell(colspan: 2, align: right)[*Subtotal*], [*57,000*], [*58,500*],
    table.hline(stroke: 0.5pt),
    [Equipment], [Hardware],  [8,000],  [2,000],
    [],          [Software],  [3,500],  [3,500],
    table.hline(stroke: 0.5pt),
    table.cell(colspan: 2, align: right)[*Subtotal*], [*11,500*], [*5,500*],
  ),
  footer: (
    table.cell(colspan: 2, align: right)[*Grand Total*], [*68,500*], [*64,000*],
  ),
  columns: (auto, 1fr, auto, auto),
)
```

### Row grouping with rowspan

```typst
#academic-table(
  [GDP by region],
  header: ([Region], [Country], [GDP (T\$)], [Pop. (M)]),
  (
    table.cell(rowspan: 3)[Europe],
      [Germany], [4.2],  [83],
      [France],  [2.9],  [67],
      [Italy],   [2.1],  [59],
    table.cell(rowspan: 2)[Asia],
      [China],   [17.7], [1,412],
      [Japan],   [4.2],  [125],
  ),
  columns: 4,
)
```

## Contributing

Contributions are welcome! Some ideas for future work:

- Additional format presets (e.g. RSC, Wiley, MDPI)
- Font size presets per format
- Table notes/footnotes helper
- Accessibility metadata

Feel free to open an issue or submit a pull request on [GitHub](https://github.com/SimonBure/akatable).

## License

MIT
