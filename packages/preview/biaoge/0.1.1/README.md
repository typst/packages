# biaoge (表哥)

A Typst table toolkit for CSV grouping & summarization, cell merging, and column splitting.

## Functions

| Module | Function | Description |
|--------|----------|-------------|
| `group-csv` | `summarize` | Group and summarize by column |
| `group-csv` | `summary-table` | Generate grouped summary table (with total row) |
| `group-csv` | `summary-table-style` | Styled summary table |
| `group-csv` | `summary-table-style-no-total` | Styled summary table without total row |
| `group-csv` | `grouped-sum-table` | Two-level grouped, sorted summary table |
| `group-csv-tools` | `merge-selected-columns` | Merge selected columns into one |
| `group-csv-tools` | `split-column-in-rows` | Split rows by separator within a column |
| `group-csv-tools` | `trim-string` | Trim leading/trailing whitespace |
| `merge-cells` | `merge-col` | Extract values from a single column |
| `merge-cells` | `merge-table-data` | Vertically merge identical adjacent cells (returns data) |
| `merge-cells` | `merge-table-data-value-col` | Vertically merge and sum a value column (returns data) |
| `merge-cells` | `merge-table` | Vertically merge identical adjacent cells (returns table) |
| `merge-cells` | `merge-table-value-col` | Vertically merge and sum a value column (returns table) |
| `table-style` | `stroke-light` | Light border stroke |
| `table-style` | `inner-frame` | Inner frame stroke pattern (three-line table style) |
| `conf` | `conf` | Paper/report layout with author grid + abstract |
| `conf-table` | `group-tables` | Split a master table into sub-tables by group column |

## Usage

```typ
#import "@preview/biaoge:0.1.1": *
```

### Data format

All table functions use a uniform 2D array format: the first row is the header, followed by data rows.

```typ
#let data = (
  ("Name", "Category", "Amount"),
  ("Apple", "Fruit", "120"),
  ("Banana", "Fruit", "80"),
  ("Milk", "Drink", "150"),
)
```

---

### `summarize` — Group and summarize by column

Groups data by a specified column, computing the sum and count for each group. Returns an array of dictionaries with `group`, `total`, and `count`.

```typ
#let data = (
  ("Apple", "Fruit", "120"),
  ("Banana", "Fruit", "80"),
  ("Milk", "Drink", "150"),
)

#let result = summarize(data, group-index: 1, value-index: 2)
// result = (
//   (group: "Fruit", total: 200, count: 2),
//   (group: "Drink", total: 150, count: 1),
// )
```

**Parameters:**
- `group-index` — Column index for grouping (0-based)
- `value-index` — Column index for the numeric values to sum (0-based)

---

### `summary-table` — Grouped summary table with total row

Generates a summary table with Category, Count, Total, and Percentage columns, sorted by total in descending order. A grand total row is appended automatically.

```typ
#let data = (
  ("Name", "Category", "Amount"),
  ("Apple", "Fruit", "120"),
  ("Banana", "Fruit", "80"),
  ("Milk", "Drink", "150"),
  ("Cola", "Drink", "60"),
  ("Cake", "Bakery", "200"),
)

#summary-table(data, group-index: 1, value-index: 2, title: "Sales by Category")
```

Output table:

| Category | Count | Total | Percentage |
|----------|-------|-------|------------|
| Bakery | 1 | 200 | 32.79% |
| Drink | 2 | 210 | 34.43% |
| Fruit | 2 | 200 | 32.79% |
| **Total** | **5** | **610** | **100%** |

**Parameters:**
- `group-index` — Column index for grouping
- `value-index` — Column index for numeric values
- `title` — Table title

---

### `summary-table-style` — Styled summary table

Similar to `summary-table`, but accepts pre-computed `header` and `rows`. Use when data has already been processed.

```typ
#let header = ([*Category*], [*Count*], [*Total*], [*Percentage*])
#let rows = (
  ("Bakery", "1", "200", "40.82%"),
  ("Fruit",  "2", "200", "40.82%"),
  ("Drink",  "2", "150", "30.61%"),
)

#summary-table-style(header, rows, value-index: 2, title: "Sales Statistics")
```

**Parameters:**
- `header` — Header row array
- `rows` — Data rows (2D array)
- `value-index` — Column index for the total calculation
- `title` — Table title

---

### `summary-table-style-no-total` — Styled summary table without total row

Same as `summary-table-style`, but omits the total row. Useful when a grand total is not needed.

```typ
#let header = ([*Department*], [*Headcount*], [*Budget*])
#let rows = (
  ("Engineering", "15", "500"),
  ("Marketing",   "8",  "300"),
  ("Finance",     "5",  "200"),
)

#summary-table-style-no-total(header, rows, value-index: 2, title: "Department Budgets")
```

**Parameters:** Same as `summary-table-style`.

---

### `grouped-sum-table` — Two-level grouped, sorted summary table

Groups by `group-index-1` (sorted by total descending), sub-groups by `group-index-2`, and vertically merges identical cells in the first column. The value column cells are also merged and summed.

```typ
#let data = (
  ("Department", "Project", "Budget", "Executed", "Rate"),
  ("Engineering", "ERP System", "300", "270", "90%"),
  ("Engineering", "OA System",  "200", "150", "75%"),
  ("Marketing",   "Online Ads", "150", "120", "80%"),
  ("Marketing",   "Offline",    "100", "80",  "80%"),
)

#let tb-header = ([*Department*], [*Project*], [*Budget*], [*Executed*], [*Rate*])

#grouped-sum-table(
  data,
  group-index-1: 0,
  group-index-2: 1,
  value-index: 3,
  tb-header: tb-header,
  tb-title: "Project Execution Summary",
  col-nums: 5,
)
```

Output: departments are sorted by total executed amount, identical department names are vertically merged, and execution rates are summed for each department group.

**Parameters:**
- `group-index-1` — Primary grouping column index
- `group-index-2` — Secondary grouping column index
- `value-index` — Numeric column index for sorting and summation
- `tb-header` — Table header row
- `tb-title` — Table title
- `col-nums` — Total number of columns (default: 6)

---

### `merge-selected-columns` — Merge selected columns

Merges multiple columns into one, joining values with a custom separator. The merged column replaces the first selected column; remaining selected columns are removed.

```typ
#let data = (
  ("First", "Last", "Age"),
  ("San",   "Zhang", "28"),
  ("Si",    "Li",    "35"),
  ("Wu",    "Wang",  "42"),
)

// Default separator " - "
#let merged = merge-selected-columns(data, (0, 1))
// merged = (
//   ("First", "Age"),
//   ("San - Zhang", "28"),
//   ("Si - Li",     "35"),
//   ("Wu - Wang",   "42"),
// )

// Custom separator
#let merged2 = merge-selected-columns(data, (0, 1), transform: values => values.join(" "))
// merged2 = (
//   ("First", "Age"),
//   ("San Zhang", "28"),
//   ("Si Li",     "35"),
//   ("Wu Wang",   "42"),
// )
```

**Parameters:**
- `data` — 2D data array
- `indices` — Array of column indices to merge
- `transform` — Custom merge function, default `values.join(" - ")`

---

### `split-column-in-rows` — Split a column into multiple rows

Splits a column value by a separator, creating one row per split part. Useful for expanding multi-value fields like "Apple - Banana - Orange".

```typ
#let data = (
  ("Category", "Name"),
  ("Fruit", "Apple - Banana - Orange"),
  ("Drink", "Milk - Cola"),
)

#let result = split-column-in-rows(data, split-column-index: 1, separator: " - ")
// result = (
//   ("Category", "Name"),
//   ("Fruit", "Apple"),
//   ("Fruit", "Banana"),
//   ("Fruit", "Orange"),
//   ("Drink", "Milk"),
//   ("Drink", "Cola"),
// )
```

**Parameters:**
- `data` — 2D data array
- `split-column-index` — Column index to split
- `separator` — Separator string, default `" - "`

---

### `trim-string` — Trim whitespace

Removes leading and trailing whitespace from a string.

```typ
#let result = trim-string("   hello world   ")
// result = "hello world"

#let cleaned = (" apple ", " banana ").map(trim-string)
// cleaned = ("apple", "banana")
```

**Parameters:**
- `str` — String to trim

---

### `merge-col` — Extract a column

Extracts all values from a single column. Mostly used internally by other merge functions.

```typ
#let data = (
  ("Name", "Category", "Amount"),
  ("Apple", "Fruit", "120"),
  ("Banana", "Fruit", "80"),
  ("Milk", "Drink", "150"),
)

#let categories = merge-col(data, merge-col-index: 1)
// categories = ("Name", "Category", "Amount", "Fruit", "Fruit", "Drink")
```

**Parameters:**
- `data` — 2D data array
- `merge-col-index` — Column index to extract (0-based)

---

### `merge-table-data` — Vertically merge identical cells (returns data)

Merges consecutive identical cells in a specified column using `table.cell(rowspan:)`. Returns a dictionary `(header:, rows:)` without rendering a table — use this when you need to post-process the data.

```typ
#let header = ("Category", "Name", "Amount")
#let rows = (
  ("Fruit", "Apple",  "120"),
  ("Fruit", "Banana", "80"),
  ("Drink", "Milk",   "150"),
  ("Drink", "Cola",   "60"),
)

#let merged-data = merge-table-data(header, rows, merge-col-index: 0, table-col-count: 3)
// merged-data = (
//   header: ("Category", "Name", "Amount"),
//   rows: (
//     (table.cell(rowspan: 2, "Fruit"), "Apple", "120"),
//     ("Banana", "80"),
//     (table.cell(rowspan: 2, "Drink"), "Milk", "150"),
//     ("Cola", "60"),
//   ),
// )
```

**Parameters:**
- `header` — Header row array
- `rows` — Data rows (without header)
- `merge-col-index` — Column index to merge identical cells in
- `table-col-count` — Total number of table columns

---

### `merge-table-data-value-col` — Vertically merge and sum values (returns data)

Combines `merge-table-data` cell merging with numeric summation on a value column. Merged cells show the summed value with a `%` suffix.

```typ
#let header = ("Category", "Name", "Amount", "Share")
#let rows = (
  ("Fruit", "Apple",  "120", "30%"),
  ("Fruit", "Banana", "80",  "20%"),
  ("Drink", "Milk",   "150", "37.5%"),
  ("Drink", "Cola",   "60",  "15%"),
)

#let merged-data = merge-table-data-value-col(
  header, rows, merge-col-index: 0, table-col-count: 4, value-col-index: 3
)
// Share column summed per group: Fruit "30%" + "20%" → "50%"
```

**Parameters:**
- `header` — Header row array
- `rows` — Data rows
- `merge-col-index` — Column index to merge cells in
- `table-col-count` — Total number of table columns
- `value-col-index` — Value column index (values must be in `"xx%"` format)

---

### `merge-table` — Vertically merge identical cells (returns table)

Same as `merge-table-data`, but directly returns a rendered Typst `table`.

```typ
#let header = ("Category", "Name", "Amount")
#let rows = (
  ("Fruit", "Apple",  "120"),
  ("Fruit", "Banana", "80"),
  ("Drink", "Milk",   "150"),
)

#merge-table(header, rows, merge-col-index: 0, table-col-count: 3)
```

Output: consecutive identical values ("Fruit", "Drink") in the category column are vertically merged with rowspan.

**Parameters:** Same as `merge-table-data`.

---

### `merge-table-value-col` — Vertically merge and sum values (returns table)

Same as `merge-table-data-value-col`, but directly returns a rendered Typst `table`.

```typ
#let header = ("Category", "Name", "Amount", "Share")
#let rows = (
  ("Fruit", "Apple",  "120", "30%"),
  ("Fruit", "Banana", "80",  "20%"),
  ("Drink", "Milk",   "150", "37.5%"),
)

#merge-table-value-col(header, rows, merge-col-index: 0, table-col-count: 4, value-col-index: 3)
```

Output: category column cells are vertically merged; share column shows summed percentages per group.

**Parameters:** Same as `merge-table-data-value-col`.

---

### `stroke-light` — Light border stroke

A `0.5pt + black` stroke value, typically used with `inner-frame` for table borders.

```typ
#table(
  columns: 3,
  stroke: inner-frame(stroke-light),
  [A], [B], [C],
  [1], [2], [3],
)
```

**Value:** `0.5pt + black`

---

### `inner-frame` — Inner frame stroke pattern

A stroke generator that draws separators only between inner cells — hides the left border on the first column and the top border on header rows, producing a clean "three-line table" look.

```typ
#import "table-style.typ": stroke-light, inner-frame

#table(
  columns: 4,
  stroke: inner-frame(stroke-light),
  inset: 10pt,
  table.header([*Name*], [*Qty*], [*Price*], [*Total*]),
  [Apple],  [10], [5.0], [50.0],
  [Banana], [20], [3.0], [60.0],
  table.hline(stroke: stroke-light),
  [*Total*], [], [], [110.0],
)
```

**Parameters:**
- `stroke` — Stroke style (e.g., `stroke-light`)

**Behavior:** Left border hidden on column 0, top border hidden on rows 0 and 1 (header area), giving the table an open, clean style.

---

### `conf` — Paper / report layout

Sets up a paper or report page layout with margins, an author grid, and an abstract block at the top.

```typ
#show: conf.with(
  authors: (
    (name: "Alice", affiliation: "University of Example", email: "alice@example.com"),
    (name: "Bob",   affiliation: "Research Institute",   email: "bob@example.com"),
  ),
  abstract: [This paper presents a novel approach to table generation in Typst...],
)

= Introduction

#lorem(500) // body content
```

Output: title centered at the top, authors arranged in a grid (max 3 columns), abstract below, followed by the document body.

**Parameters:**
- `authors` — Array of author dictionaries with `name` (required), plus optional `affiliation` and `email`
- `abstract` — Abstract content block
- `doc` — Document body (passed as the content block after `#show:`)

---

### `group-tables` — Split master table into sub-tables by group

Splits a single table into multiple independent sub-tables based on unique values in a group column. Each sub-table is titled with the group value, and the group column is removed from display.

```typ
#let data = (
  ("System", "Department", "Module", "Status"),
  ("ERP", "Engineering", "Procurement", "Running"),
  ("ERP", "Engineering", "Inventory",   "Running"),
  ("OA",  "Admin",       "Documents",   "Maintenance"),
  ("OA",  "Admin",       "Meetings",    "Stopped"),
)

#group-tables(data, group-col: "Department")
```

Output:

**== Engineering Required Fields**

| System | Module | Status |
|--------|--------|--------|
| ERP | Procurement | Running |
| ERP | Inventory | Running |

**== Admin Required Fields**

| System | Module | Status |
|--------|--------|--------|
| OA | Documents | Maintenance |
| OA | Meetings | Stopped |

**Parameters:**
- `data` — 2D data array (first row is the header)
- `group-col` — Group column name (string) or column index (integer)

---

### Complete example: from raw data to report

```typ
#import "@preview/biaoge:0.1.1": *

// Raw sales data
#let sales-data = (
  ("Product", "Region", "Quarter", "Revenue"),
  ("Phone",   "East",   "Q1",      "5000"),
  ("Phone",   "East",   "Q2",      "6200"),
  ("Phone",   "South",  "Q1",      "3800"),
  ("Laptop",  "East",   "Q1",      "12000"),
  ("Laptop",  "South",  "Q1",      "8500"),
  ("Laptop",  "South",  "Q2",      "9200"),
)

// 1. Summary by product
#summary-table(sales-data, group-index: 0, value-index: 3, title: "Revenue by Product")

// 2. Split into sub-tables by region
#group-tables(sales-data, group-col: "Region")

// 3. Merge identical product names vertically
#let header = ("Product", "Region", "Quarter", "Revenue")
#let rows = sales-data.slice(1)
#merge-table(header, rows, merge-col-index: 0, table-col-count: 4)
```

## Dependencies

No external dependencies — pure Typst standard library.

## License

MIT — Copyright (c) 2025 songwupei
