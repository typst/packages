<h1 align='center'>tableframe</h1>
<h3 align='center'>A dataframe(/spreadsheet/Excel) library for Typst</h3>

This is a simple columns-and-tables dataframe library for Typst.<br>

Spreadsheets (e.g. Excel) are often used for representing columnar data, often with a handful of aggregate statistics computed on the result. By augmenting regular Typst documents with a columnar dataframe library, we can then build equivalent documents purely in Typst.

_(This is what I use instead of Excel!)_

## Installation

Typst will autodownload packages on import:
```typst
#import "@preview/tableframe:0.1.0"
```

## Usage

We provide two classes, `Column`, which is an array of homogeneous values, and `Table`, which is a dictionary of columns. These are augmented with several methods (adding columns, cumulative sums down a column, etc.) to aid manipulating them.

(Classes are provided with [Typsy](https://github.com/patrick-kidger/typsy).)

```typst
#import "@preview/tableframe:0.1.0": Column, Table
// Table comes with both row-wise and column-wise constructors; this one builds directly from Columns.
#let table = (Table.from-columns)(
    Geography: (Column.from-data)("EU", "US", "Japan"),
    Proportion: (Column.from-data)(35%, 30%, 12%),
    Cost: (Column.from-data)(70%, 100%, 50%),
)
// Get a column, pass a unique prefix of its name.
#let prop-col = (table.col)("Prop")
#let cost-col = (table.col)("Cost")
// Compute the dot-product of two columns.
#let total = ((prop-col.mul)(cost-col).sum)()
// Display as a Typst table. Specify how non-string/content items are transformed into string/content.
#(table.display)(to-content: ("Geog": repr, "Cost": repr))
```