<div>

# Tabut

*Powerful, Simple, Concise*

A Typst plugin for turning data into tables.

## Outline

- [Examples](#examples)

  - [Input Format and Creation](#input-format-and-creation)

  - [Basic Table](#basic-table)

  - [Table Styling](#table-styling)

  - [Header Formatting](#header-formatting)

  - [Remove Headers](#remove-headers)

  - [Cell Expressions and Formatting](#cell-expressions-and-formatting)

  - [Index](#index)

  - [Transpose](#transpose)

  - [Alignment](#alignment)

  - [Column Width](#column-width)

  - [Get Cells Only](#get-cells-only)

  - [Use with Tablex](#use-with-tablex)

- [Data Operation Examples](#data-operation-examples)

  - [CSV Data](#csv-data)

  - [Slice](#slice)

  - [Sorting and Reversing](#sorting-and-reversing)

  - [Filter](#filter)

  - [Aggregation using Map and Sum](#aggregation-using-map-and-sum)

  - [Grouping](#grouping)

- [Function Definitions](#function-definitions)

  - [`tabut`](#tabut)

  - [`tabut-cells`](#tabut-cells)

  - [`rows-to-records`](#rows-to-records)

  - [`records-from-csv`](#records-from-csv)

  - [`group`](#group)

</div>

<div>

# Examples <span id="examples"></span>

</div>

<div>

## Input Format and Creation <span id="input-format-and-creation"></span>

The `tabut` function takes input in “record” format, an array of
dictionaries, with each dictionary representing a single “object” or
“record”.

In the example below, each record is a listing for an office supply
product.

<div>

``` typ
#let supplies = (
  (name: "Notebook", price: 3.49, quantity: 5),
  (name: "Ballpoint Pens", price: 5.99, quantity: 2),
  (name: "Printer Paper", price: 6.99, quantity: 3),
)
```

</div>

</div>

<div>

## Basic Table <span id="basic-table"></span>

Now create a basic table from the data.

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut
#import "example-data/supplies.typ": supplies

#tabut(
  supplies, // the source of the data used to generate the table
  ( // column definitions
    (
      header: [Name], // label, takes content.
      func: r => r.name // generates the cell content.
    ), 
    (header: [Price], func: r => r.price), 
    (header: [Quantity], func: r => r.quantity), 
  )
)
```

</div>

<div>

<img src="doc/compiled-snippets/basic.svg"
style="width:2.24804in;height:1.01335in" />

</div>

`funct` takes a function which generates content for a given cell
corrosponding to the defined column for each record. `r` is the record,
so `r => r.name` returns the `name` property of each record in the input
data if it has one.

</div>

<div>

The philosphy of `tabut` is that the display of data should be simple
and clearly defined, therefore each column and it’s content and
formatting should be defined within a single clear column defintion. One
consequence is you can comment out, remove or move, any column easily,
for example:

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut
#import "example-data/supplies.typ": supplies

#tabut(
  supplies,
  (
    (header: [Price], func: r => r.price), // This column is moved to the front
    (header: [Name], func: r => r.name), 
    (header: [Name 2], func: r => r.name), // copied
    // (header: [Quantity], func: r => r.quantity), // removed via comment
  )
)
```

</div>

<div>

<img src="doc/compiled-snippets/rearrange.svg"
style="width:2.58903in;height:1.01335in" />

</div>

</div>

<div>

## Table Styling <span id="table-styling"></span>

Any default Table style options can be tacked on and are passed to the
final table function.

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut
#import "example-data/supplies.typ": supplies

#tabut(
  supplies,
  ( 
    (header: [Name], func: r => r.name), 
    (header: [Price], func: r => r.price), 
    (header: [Quantity], func: r => r.quantity),
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)
```

</div>

<div>

<img src="doc/compiled-snippets/styling.svg"
style="width:2.24804in;height:1.01335in" />

</div>

</div>

<div>

## Header Formatting <span id="header-formatting"></span>

You can pass any content or expression into the header property.

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut
#import "example-data/supplies.typ": supplies

#let fmt(it) = {
  heading(
    outlined: false,
    upper(it)
  )
}

#tabut(
  supplies,
  ( 
    (header: fmt([Name]), func: r => r.name ), 
    (header: fmt([Price]), func: r => r.price), 
    (header: fmt([Quantity]), func: r => r.quantity), 
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)
```

</div>

<div>

<img src="doc/compiled-snippets/title.svg"
style="width:3.14555in;height:1.05075in" />

</div>

</div>

<div>

## Remove Headers <span id="remove-headers"></span>

You can prevent from being generated with the `headers` paramater. This
is useful with the `tabut-cells` function as demonstrated in it’s
section.

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut
#import "example-data/supplies.typ": supplies

#tabut(
  supplies,
  (
    (header: [*Name*], func: r => r.name), 
    (header: [*Price*], func: r => r.price), 
    (header: [*Quantity*], func: r => r.quantity), 
  ),
  headers: false, // Prevents Headers from being generated
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none,
)
```

</div>

<div>

<img src="doc/compiled-snippets/no-headers.svg"
style="width:1.69109in;height:0.7739in" />

</div>

</div>

<div>

## Cell Expressions and Formatting <span id="cell-expressions-and-formatting"></span>

Just like the headers, cell contents can be modified and formatted like
any content in Typst.

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut
#import "usd.typ": usd
#import "example-data/supplies.typ": supplies

#tabut(
  supplies,
  ( 
    (header: [*Name*], func: r => r.name ), 
    (header: [*Price*], func: r => usd(r.price)), 
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)
```

</div>

<div>

<img src="doc/compiled-snippets/format.svg"
style="width:1.58711in;height:1.01133in" />

</div>

</div>

<div>

You can have the cell content function do calculations on a record
property.

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut
#import "usd.typ": usd
#import "example-data/supplies.typ": supplies

#tabut(
  supplies,
  ( 
    (header: [*Name*], func: r => r.name ), 
    (header: [*Price*], func: r => usd(r.price)), 
    (header: [*Tax*], func: r => usd(r.price * .2)), 
    (header: [*Total*], func: r => usd(r.price * 1.2)), 
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)
```

</div>

<div>

<img src="doc/compiled-snippets/calculation.svg"
style="width:2.53821in;height:1.01133in" />

</div>

</div>

<div>

Or even combine multiple record properties, go wild.

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut

#let employees = (
    (id: 3251, first: "Alice", last: "Smith", middle: "Jane"),
    (id: 4872, first: "Carlos", last: "Garcia", middle: "Luis"),
    (id: 5639, first: "Evelyn", last: "Chen", middle: "Ming")
);

#tabut(
  employees,
  ( 
    (header: [*ID*], func: r => r.id ),
    (header: [*Full Name*], func: r => [#r.first #r.middle.first(), #r.last] ),
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)
```

</div>

<div>

<img src="doc/compiled-snippets/combine.svg"
style="width:1.6171in;height:1.01133in" />

</div>

</div>

<div>

## Index <span id="index"></span>

`tabut` automatically adds an `_index` property to each record.

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut
#import "example-data/supplies.typ": supplies

#tabut(
  supplies,
  ( 
    (header: [*\#*], func: r => r._index),
    (header: [*Name*], func: r => r.name ), 
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)
```

</div>

<div>

<img src="doc/compiled-snippets/index.svg"
style="width:1.31304in;height:1.01133in" />

</div>

You can also prevent the `index` property being generated by setting it
to `none`, or you can also set an alternate name of the index property
as shown below.

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut
#import "example-data/supplies.typ": supplies

#tabut(
  supplies,
  ( 
    (header: [*\#*], func: r => r.index-alt ),
    (header: [*Name*], func: r => r.name ), 
  ),
  index: "index-alt", // set an aternate name for the automatically generated index property.
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)
```

</div>

<div>

<img src="doc/compiled-snippets/index-alternate.svg"
style="width:1.31304in;height:1.01133in" />

</div>

</div>

<div>

## Transpose <span id="transpose"></span>

This was annoying to implement, and I don’t know when you’d actually use
this, but here.

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut
#import "usd.typ": usd
#import "example-data/supplies.typ": supplies

#tabut(
  supplies,
  (
    (header: [*\#*], func: r => r._index),
    (header: [*Name*], func: r => r.name), 
    (header: [*Price*], func: r => usd(r.price)), 
    (header: [*Quantity*], func: r => r.quantity),
  ),
  transpose: true,  // set optional name arg `transpose` to `true`
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)
```

</div>

<div>

<img src="doc/compiled-snippets/transpose.svg"
style="width:3.57327in;height:1.01335in" />

</div>

</div>

<div>

## Alignment <span id="alignment"></span>

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut
#import "usd.typ": usd
#import "example-data/supplies.typ": supplies

#tabut(
  supplies,
  ( // Include `align` as an optional arg to a column def
    (header: [*\#*], func: r => r._index),
    (header: [*Name*], align: right, func: r => r.name), 
    (header: [*Price*], align: right, func: r => usd(r.price)), 
    (header: [*Quantity*], align: right, func: r => r.quantity),
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)
```

</div>

<div>

<img src="doc/compiled-snippets/align.svg"
style="width:2.56141in;height:1.01133in" />

</div>

You can also define Alignment manually as in the the standard Table
Function.

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut
#import "usd.typ": usd
#import "example-data/supplies.typ": supplies

#tabut(
  supplies,
  ( 
    (header: [*\#*], func: r => r._index),
    (header: [*Name*], func: r => r.name), 
    (header: [*Price*], func: r => usd(r.price)), 
    (header: [*Quantity*], func: r => r.quantity),
  ),
  align: (auto, right, right, right), // Alignment defined as in standard table function
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)
```

</div>

<div>

<img src="doc/compiled-snippets/align-manual.svg"
style="width:2.56141in;height:1.01133in" />

</div>

</div>

<div>

## Column Width <span id="column-width"></span>

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut
#import "usd.typ": usd
#import "example-data/supplies.typ": supplies

#box(
  width: 300pt,
  tabut(
    supplies,
    ( // Include `width` as an optional arg to a column def
      (header: [*\#*], func: r => r._index),
      (header: [*Name*], width: 1fr, func: r => r.name), 
      (header: [*Price*], width: 20%, func: r => usd(r.price)), 
      (header: [*Quantity*], width: 1.5in, func: r => r.quantity),
    ),
    fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
    stroke: none,
  )
)

```

</div>

<div>

<img src="doc/compiled-snippets/width.svg"
style="width:4.22222in;height:1.01133in" />

</div>

You can also define Columns manually as in the the standard Table
Function.

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut
#import "usd.typ": usd
#import "example-data/supplies.typ": supplies

#box(
  width: 300pt,
  tabut(
    supplies,
    (
      (header: [*\#*], func: r => r._index),
      (header: [*Name*], func: r => r.name), 
      (header: [*Price*], func: r => usd(r.price)), 
      (header: [*Quantity*], func: r => r.quantity),
    ),
    columns: (auto, 1fr, 20%, 1.5in),  // Columns defined as in standard table
    fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
    stroke: none,
  )
)

```

</div>

<div>

<img src="doc/compiled-snippets/width-manual.svg"
style="width:4.22222in;height:1.01133in" />

</div>

</div>

<div>

## Get Cells Only <span id="get-cells-only"></span>

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut-cells
#import "usd.typ": usd
#import "example-data/supplies.typ": supplies

#tabut-cells(
  supplies,
  ( 
    (header: [Name], func: r => r.name), 
    (header: [Price], func: r => usd(r.price)), 
    (header: [Quantity], func: r => r.quantity),
  )
)
```

</div>

<div>

<img src="doc/compiled-snippets/only-cells.svg"
style="width:3.36683in;height:2.73299in" />

</div>

</div>

<div>

## Use with Tablex <span id="use-with-tablex"></span>

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut-cells
#import "usd.typ": usd
#import "example-data/supplies.typ": supplies

#import "@preview/tablex:0.0.8": tablex, rowspanx, colspanx

#tablex(
  auto-vlines: false,
  header-rows: 2,

  /* --- header --- */
  rowspanx(2)[*Name*], colspanx(2)[*Price*], (), rowspanx(2)[*Quantity*],
  (),                 [*Base*], [*W/Tax*], (),
  /* -------------- */

  ..tabut-cells(
    supplies,
    ( 
      (header: [], func: r => r.name), 
      (header: [], func: r => usd(r.price)), 
      (header: [], func: r => usd(r.price * 1.3)), 
      (header: [], func: r => r.quantity),
    ),
    headers: false
  )
)
```

</div>

<div>

<img src="doc/compiled-snippets/tablex.svg"
style="width:2.90837in;height:1.24877in" />

</div>

</div>

<div>

# Data Operation Examples <span id="data-operation-examples"></span>

While technically seperate from table display, the following are
examples of how to perform operations on data before it is displayed
with `tabut`.

Since `tabut` assumes an “array of dictionaries” format, then most data
operations can be performed easily with Typst’s native array functions.
`tabut` also provides several functions to provide additional
functionality.

</div>

<div>

## CSV Data <span id="csv-data"></span>

By default, imported CSV gives a “rows” or “array of arrays” data
format, which can not be directly used by `tabut`. To convert, `tabut`
includes a function `rows-to-records` demonstrated below.

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut, rows-to-records
#import "example-data/supplies.typ": supplies

#let titanic = {
  let titanic-raw = csv("example-data/titanic.csv");
  rows-to-records(
    titanic-raw.first(), // The header row
    titanic-raw.slice(1, -1), // The rest of the rows
  )
}
```

</div>

Imported CSV data are all strings, so it’s usefull to convert them to
`int` or `float` when possible.

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut, rows-to-records
#import "example-data/supplies.typ": supplies

#let auto-type(input) = {
  let is-int = (input.match(regex("^-?\d+$")) != none);
  if is-int { return int(input); }
  let is-float = (input.match(regex("^-?(inf|nan|\d+|\d*(\.\d+))$")) != none);
  if is-float { return float(input) }
  input
}

#let titanic = {
  let titanic-raw = csv("example-data/titanic.csv");
  rows-to-records( titanic-raw.first(), titanic-raw.slice(1, -1) )
  .map( r => {
    let new-record = (:);
    for (k, v) in r.pairs() { new-record.insert(k, auto-type(v)); }
    new-record
  })
}
```

</div>

`tabut` includes a function, `records-from-csv`, to automatically
perform this process.

<div>

``` typ
#import "@preview/tabut:1.0.0": records-from-csv

#let titanic = records-from-csv("doc/example-snippets/example-data/titanic.csv");
```

</div>

</div>

<div>

## Slice <span id="slice"></span>

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut, records-from-csv
#import "usd.typ": usd
#import "example-data/titanic.typ": titanic

#let classes = (
  "N/A",
  "First", 
  "Second", 
  "Third"
);

#let titanic-head = titanic.slice(0, 5);

#tabut(
  titanic-head,
  ( 
    (header: [*Name*], func: r => r.Name), 
    (header: [*Class*], func: r => classes.at(r.Pclass)),
    (header: [*Fare*], func: r => usd(r.Fare)), 
    (header: [*Survived?*], func: r => ("No", "Yes").at(r.Survived)), 
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)
```

</div>

<div>

<img src="doc/compiled-snippets/slice.svg"
style="width:5.33036in;height:1.49023in" />

</div>

</div>

<div>

## Sorting and Reversing <span id="sorting-and-reversing"></span>

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut
#import "usd.typ": usd
#import "example-data/titanic.typ": titanic, classes

#tabut(
  titanic
  .sorted(key: r => r.Fare)
  .rev()
  .slice(0, 5),
  ( 
    (header: [*Name*], func: r => r.Name), 
    (header: [*Class*], func: r => classes.at(r.Pclass)),
    (header: [*Fare*], func: r => usd(r.Fare)), 
    (header: [*Survived?*], func: r => ("No", "Yes").at(r.Survived)), 
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)
```

</div>

<div>

<img src="doc/compiled-snippets/sort.svg"
style="width:4.40184in;height:1.49023in" />

</div>

</div>

<div>

## Filter <span id="filter"></span>

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut
#import "usd.typ": usd
#import "example-data/titanic.typ": titanic, classes

#tabut(
  titanic
  .filter(r => r.Pclass == 1)
  .slice(0, 5),
  ( 
    (header: [*Name*], func: r => r.Name), 
    (header: [*Class*], func: r => classes.at(r.Pclass)),
    (header: [*Fare*], func: r => usd(r.Fare)), 
    (header: [*Survived?*], func: r => ("No", "Yes").at(r.Survived)), 
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)
```

</div>

<div>

<img src="doc/compiled-snippets/filter.svg"
style="width:5.33036in;height:1.49023in" />

</div>

</div>

<div>

## Aggregation using Map and Sum <span id="aggregation-using-map-and-sum"></span>

<div>

``` typ
#import "usd.typ": usd
#import "example-data/titanic.typ": titanic, classes

#table(
  columns: (auto, auto),
  [*Fare, Total:*], [#usd(titanic.map(r => r.Fare).sum())],
  [*Fare, Avg:*], [#usd(titanic.map(r => r.Fare).sum() / titanic.len())], 
  stroke: none
)
```

</div>

<div>

<img src="doc/compiled-snippets/aggregation.svg"
style="width:1.73668in;height:0.53445in" />

</div>

</div>

<div>

## Grouping <span id="grouping"></span>

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut, group
#import "example-data/titanic.typ": titanic, classes

#tabut(
  group(titanic, r => r.Pclass),
  (
    (header: [*Class*], func: r => classes.at(r.value)), 
    (header: [*Passengers*], func: r => r.group.len()), 
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)
```

</div>

<div>

<img src="doc/compiled-snippets/group.svg"
style="width:1.53415in;height:1.01133in" />

</div>

<div>

``` typ
#import "@preview/tabut:1.0.0": tabut, group
#import "usd.typ": usd
#import "example-data/titanic.typ": titanic, classes

#tabut(
  group(titanic, r => r.Pclass),
  (
    (header: [*Class*], func: r => classes.at(r.value)), 
    (header: [*Total Fare*], func: r => usd(r.group.map(r => r.Fare).sum())), 
    (
      header: [*Avg Fare*], 
      func: r => usd(r.group.map(r => r.Fare).sum() / r.group.len())
    ), 
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)
```

</div>

<div>

<img src="doc/compiled-snippets/group-aggregation.svg"
style="width:2.21231in;height:1.01133in" />

</div>

</div>

<div>

# Function Definitions <span id="function-definitions"></span>

</div>

<div>

## `tabut` <span id="tabut"></span>

Takes data and column definitions and outputs a table.

<div>

``` typc
tabut(
  data-raw, 
  colDefs, 
  columns: auto,
  align: auto,
  index: "_index",
  transpose: false,
  headers: true,
  ..tableArgs
) -> content
```

</div>

### Parameters

`data-raw`  
This is the raw data that will be used to generate the table. The data
is expected to be in an array of dictionaries, where each dictionary
represents a single record or object.

`colDefs`  
These are the column definitions. An array of dictionaries, each
representing column definition. Must include the properties `header` and
a `func`. `header` expects content, and specifies the label of the
column. `func` expects a function, the function takes a record
dictionary as input and returns the value to be displayed in the cell
corresponding to that record and column. There are also two optional
properties; `align` sets the alignment of the content within the cells
of the column, `width` sets the width of the column.

`columns`  
(optional, default: `auto`) Specifies the column widths. If set to
`auto`, the function automatically generates column widths by each
column’s column definition. Otherwise functions exactly the `columns`
paramater of the standard Typst `table` function. Unlike the
`tabut-cells` setting this to `none` will break.

`align`  
(optional, default: `auto`) Specifies the column alignment. If set to
`auto`, the function automatically generates column alignment by each
column’s column definition. If set to `none` no `align` property is
added to the output arg. Otherwise functions exactly the `align`
paramater of the standard Typst `table` function.

`index`  
(optional, default: `"_index"`) Specifies the property name for the
index of each record. By default, an `_index` property is automatically
added to each record. If set to `none`, no index property is added.

`transpose`  
(optional, default: `false`) If set to `true`, transposes the table,
swapping rows and columns.

`headers`  
(optional, default: `true`) Determines whether headers should be
included in the output. If set to `false`, headers are not generated.

`tableArgs`  
(optional) Any additional arguments are passed to the `table` function,
can be used for styling or anything else.

</div>

<div>

## `tabut-cells` <span id="tabut-cells"></span>

The `tabut-cells` function functions as `tabut`, but returns `arguments`
for use in either the standard `table` function or other tools such as
`tablex`. If you just want the array of cells, use the `pos` function on
the returned value, ex `tabut-cells(...).pos`.

`tabut-cells` is particularly useful when you need to generate only the
cell contents of a table or when these cells need to be passed to
another function for further processing or customization.

### Function Signature

<div>

``` typc
tabut-cells(
  data-raw, 
  colDefs, 
  columns: auto,
  align: auto,
  index: "_index",
  transpose: false,
  headers: true,
) -> arguments
```

</div>

### Parameters

`data-raw`  
This is the raw data that will be used to generate the table. The data
is expected to be in an array of dictionaries, where each dictionary
represents a single record or object.

`colDefs`  
These are the column definitions. An array of dictionaries, each
representing column definition. Must include the properties `header` and
a `func`. `header` expects content, and specifies the label of the
column. `func` expects a function, the function takes a record
dictionary as input and returns the value to be displayed in the cell
corresponding to that record and column. There are also two optional
properties; `align` sets the alignment of the content within the cells
of the column, `width` sets the width of the column.

`columns`  
(optional, default: `auto`) Specifies the column widths. If set to
`auto`, the function automatically generates column widths by each
column’s column definition. If set to `none` no `column` property is
added to the output arg. Otherwise functions exactly the `columns`
paramater of the standard typst `table` function.

`align`  
(optional, default: `auto`) Specifies the column alignment. If set to
`auto`, the function automatically generates column alignment by each
column’s column definition. If set to `none` no `align` property is
added to the output arg. Otherwise functions exactly the `align`
paramater of the standard typst `table` function.

`index`  
(optional, default: `"_index"`) Specifies the property name for the
index of each record. By default, an `_index` property is automatically
added to each record. If set to `none`, no index property is added.

`transpose`  
(optional, default: `false`) If set to `true`, transposes the table,
swapping rows and columns.

`headers`  
(optional, default: `true`) Determines whether headers should be
included in the output. If set to `false`, headers are not generated.

</div>

<div>

## `records-from-csv` <span id="records-from-csv"></span>

Automatically converts a CSV file into an array of records.

<div>

``` typc
records-from-csv(
  filename
) -> array
```

</div>

### Parameters

`filename`  
The path to the CSV file that needs to be converted.

This function simplifies the process of converting CSV data into a
format compatible with `tabut`. It reads the CSV file, extracts the
headers, and converts each row into a dictionary, using the headers as
keys.

</div>

<div>

## `rows-to-records` <span id="rows-to-records"></span>

Converts rows of data into an array of records based on specified
headers.

This function is useful for converting data in a “rows” format (commonly
found in CSV files) into an array of dictionaries format, which is
required for `tabut` and allows easy data processing using the built in
array functions.

<div>

``` typc
rows-to-records(
  headers, 
  rows, 
  default: none
) -> array
```

</div>

### Parameters

`headers`  
An array representing the headers of the table. Each item in this array
corresponds to a column header.

`rows`  
An array of arrays, each representing a row of data. Each sub-array
contains the cell data for a corresponding row.

`default`  
(optional, default: `none`) A default value to use when a cell is empty
or there is an error.

</div>

<div>

## `group` <span id="group"></span>

Groups data based on a specified function and returns an array of
grouped records.

<div>

``` typc
group(
  data, 
  function
) -> array
```

</div>

### Parameters

`data`  
An array of dictionaries. Each dictionary represents a single record or
object.

`function`  
A function that takes a record as input and returns a value based on
which the grouping is to be performed.

This function iterates over each record in the `data`, applies the
`function` to determine the grouping value, and organizes the records
into groups based on this value. Each group record is represented as a
dictionary with two properties: `value` (the result of the grouping
function) and `group` (an array of records belonging to this group).

In the context of `tabut`, the `group` function is particularly useful
for creating summary tables where records need to be categorized and
aggregated based on certain criteria, such as calculating total or
average values for each group.

</div>
