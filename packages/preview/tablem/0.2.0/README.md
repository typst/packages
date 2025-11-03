# Tablem

Write markdown-like tables easily.

## Example

Have a look at the source [here](./examples/example.typ).

![image](https://github.com/user-attachments/assets/60c14f3e-408d-46e2-b147-3504658bf8e8)


## Usage

You can simply copy the markdown table and paste it in `tablem` function.

```typ
#import "@preview/tablem:0.2.0": tablem, three-line-table

#tablem[
  | *Name* | *Location* | *Height* | *Score* |
  | ------ | ---------- | -------- | ------- |
  | John   | Second St. | 180 cm   | 5       |
  | Wally  | Third Av.  | 160 cm   | 10      |
]
```

And you can use custom render function.

```typ
#import "@preview/tablem:0.2.0": tablem, three-line-table

#let three-line-table = tablem.with(
  render: (columns: auto, ..args) => {
    table(
      columns: columns,
      stroke: none,
      align: center + horizon,
      table.hline(y: 0),
      table.hline(y: 1, stroke: .5pt),
      ..args,
      table.hline(),
    )
  }
)

#three-line-table[
  | *Name* | *Location* | *Height* | *Score* |
  | ------ | ---------- | -------- | ------- |
  | John   | Second St. | 180 cm   | 5       |
  | Wally  | Third Av.  | 160 cm   | 10      |
]
```

![image](https://github.com/user-attachments/assets/60c14f3e-408d-46e2-b147-3504658bf8e8)

## Cell merging

Tablem supports both horizontal and vertical cell merging. You can merge cells using either `<` (or empty cell) for horizontal merging, and `^` (or empty cell) for vertical merging.

### Horizontal Cell Merging

Here's an example of horizontal cell merging:

```typ
#three-line-table[
  | Substance             | Subcritical °C | Supercritical °C |
  | --------------------- | -------------- | ---------------- |
  | Hydrochloric Acid     | 12.0           | 92.1             |
  | Sodium Myreth Sulfate | 16.6           | 104              |
  | Potassium Hydroxide   | 24.7           | <                |
]
```

You can also use empty cells instead of `<`:

```typ
  | Potassium Hydroxide   | 24.7           |                  |
```

Both syntaxes will produce the same result where "24.7" spans across two columns.

![image](https://github.com/user-attachments/assets/0b110e5e-98f0-49b3-94af-a72690fd556b)

### Vertical and Combined Cell Merging

You can merge cells vertically using `^` or empty cells, and even combine horizontal and vertical merging.

```typ
#tablem(ignore-second-row: false)[
  | Soldier | Hero       | <        | Soldier |
  | Guard   | Horizontal | <        | Guard   |
  | ^       | Soldier    | Soldier  | ^       |
  | Soldier | Gate       | <        | Soldier |
]
```

![image](https://github.com/user-attachments/assets/7e707d0b-5e8c-4f14-97e6-22026988a1f9)

## `tablem` function

```typ
#let tablem(
  render: table,
  ignore-second-row: true,
  use-table-header: true,
  ..args,
  body
) = { .. }
```

**Arguments:**

- `render`: [`(columns: int, ..args) => { .. }`] &mdash; Custom render function, default to be `table`, receiving a integer-type columns, which is the count of first row. `..args` is the combination of `args` of `tablem` function and children genenerated from `body`.
- `ignore-second-row`: [`boolean`] &mdash; Whether to ignore the second row (something like `|---|`). Default to be `true`.
- `use-table-header`: [`boolean`] &mdash; Whether to use `table.header` wrapper for the first row. Default to be `true`.
- `args`: [`any`] &mdash; Some arguments you want to pass to `render` function.
- `body`: [`content`] &mdash; The markdown-like table. There should be no extra line breaks in it.


## License

This project is licensed under the MIT License.
