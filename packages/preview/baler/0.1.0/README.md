Dynamically balance column sizes of grids and tables. Each column can be set to a specific size or its size can be determined automatically. For automatically determined sizes, you can set minimum and maximum values.

## How to Use
The library can be used with both grids and tables through `baled-grid` and `baled-table`, that have the same interface as `grid` and `table` with the exception of the `columns` argument. 

Accepted values for `columns`:
- `()`: one column taking up the full available width,
- `int`: number of columns, identical to setting all columns to `auto`,
- `array` of column sizes, where each column can be one of:
  - `length`: exact size,
  - `(length, length)`: automatically determined size between the minimum and maximum allowed size,
  - `auto`: automatically determined size between `50pt` and full width available.

## Examples
These are sample content and colors used in the examples. Red color denotes the normal output of `grid` and `table`, green represents the unconstrained output of `baled-grid` and `baled-table`, and yellow is used for `baled-grid` and `baled-table` columns that are constrained by minimum and maximum values. 
```typst
#let table-content = (lorem(10), lorem(20), lorem(5), lorem(40), lorem(5), lorem(9), circle(width: 100%), lorem(20))
#let grid-content = (lorem(40), lorem(10), lorem(3), lorem(12), lorem(30), lorem(5))
#let light-green = rgb(230, 255, 230)
#let light-yellow = rgb(255, 255, 220)
#let light-red = rgb(255, 230, 230)
#set grid(stroke:1pt)
```
### Example 1: Table with `columns` Value
In this example, only the number of columns is set.

![A baled table and a Typst table filled with the same lorem ipsum example text as well as a circle filling 100% of the width of a column. The baled table takes up less vertical space, because the widths of columns are adjusted to fit the amount of content in each column.](example1.svg)

### Example 2: Grid with `columns` Array

In this example, a `columns` array is set. In the case of *Balanced Grid with Size Limits*, the first column's size is set to exactly `70pt`, and the third column's size it set to an automatically determined value between `30pt` and `100pt`, which overrides the default minimum of `50pt` for `auto`. 

![The same grid layed out three times with lorem ipsum content: twice with baled grid and once with Typst grid. The first grid is layed out with no restrictions and takes up the least vertical space. The second grid has different column widths due to columns restriction on the first and last column and takes up a middling amount of vertical space. The last table, laid out with Typst's table function, takes up the most space.](example2.svg)

## How It Works

The algorithm iteratively changes column sizes to decrease grid height and stops when the height is not decreasing anymore.

For text content, increasing cell width will generally decrease cell height. `baled-grid` does not rely on this assumption, which means that it also handles non-text content, such as fixed-height and fixed-aspect ratio elements.

A side effect of minimizing the total grid height is that some column sizes will not be visually balanced if achieving a better visual balance does not result in a decrease in total grid height.

The algorithm runs inside a context and calls `measure` multiple times per iteration. Due to this `baled-grid` can be slow, especially for larger tables.  That said, for small tables, it converges quickly and shouldn't be much bother.
