 # dframes: DataFrames for typst

 This packages deals with data frames which are objects that are similar to pandas dataframes in python or DataFrames in Julia.
 
 A dataframe is a two dimentionnal array. Many operations can be done between columns, rows and it can be displayed as a table or as a graphic plot.

 ## Simple use case

 A dataframe is created given its array for each column. Displaying the dataframe can be done using `plot` or `tbl` functions:
 ```typst
 #import "@preview/dataframes:0.1.0": *
 
#let df = dataframe(
                    Year:(2021,2022,2023),
                    Fruits:(10,20,30),
                    Vegetables:(11,15,35)
                    )
Stocks:
#tbl(df)
#plot(df, x:"Year", x-tick-step:1)
 ```
![Example 1](https://raw.githubusercontent.com/oravard/typst-dataframes/0.1.0/img/example-01.png)

## Dataframe creation

The simple way to create a dataframe is to provide arrays with their corresponding column names to the constructor like in the preceding paragraph. 

But, you can provide each lines of your dataframe as an array. This means that you have to specify the column names for each line. The following example is equivalent to the preceding one.
```typst
#let adf =(
  (Year:2021, Fruits:10, Vegetables: 11),
  (Year:2022, Fruits:20, Vegetables: 15),
  (Year:2023, Fruits:30, Vegetables: 35),
)
#let df = dataframe(adf)

//is equivalent to

#let df =  = dataframe(
                    Year:(2021,2022,2023),
                    Fruits:(10,20,30),
                    Vegetables:(11,15,35)
                    )
```
The specification of a dataframe is that the number of elements for each column must be the same. If this is not the case, an error is raised.
For the following explainations, we will use `df` as the dataframe which is defined in this paragraph.

## Rows and columns
Columns are accessed using dot following by the column name (ex: `df.Year` returns the column "Year" of the dataframe). Rows can be selected using the `row` function (ex: `row(df,i)` returns the ith row of df). Selecting a set of rows and columns can be done using `slice` or `select` functions.

Rows and columns can be added with `add-cols` and `add-rows` functions or by concatenation of two dataframes using `concat`.

### nb-rows
The function `nb-rows` returns the number of rows of a dataframe:
```typst
#let nb = nb-rows(df)
#nb
```
displays:

```
3
```

### nb-cols
The function `nb-cols` returns the number of columns of a dataframe.
```typst
#let nb = nb-cols(df)
#nb
```
displays:

```
3
```

### size

The function `size` returns an array of (nb-rows,nb-cols).

```typst
#let nb = size(df)
#nb
```
displays:

```
(3,3)
```

### add-cols

The function `add-colls` add columns to the dataframe. Columns are provided with their column name as named arguments.

```typst
#let df = add-cols(df, Milk:(19,5,15))
#tbl(df)
```
displays:

![Example 2](https://raw.githubusercontent.com/oravard/typst-dataframes/0.1.0/img/example-02.png)

a shortcut `hcat` to `add-cols` is provided for people who are more confortable with Python or Julia terminology.

### add-rows

The function `add-rows` add rows to the dataframe. Rows are provided as named arguments. Each argument could be a scalar or an array. The only rule is that the final number of elements for each columns is the same.

```typst
#let df2 = add-rows(df, 
                    Year:2024, 
                    Fruits:25, 
                    Vegetables:20, 
                    Milk:10)
#tbl(df2)

#let df3 = add-rows(df, 
                    Year:(2024,2025), 
                    Fruits:(25,30), 
                    Vegetables:(20,10), 
                    Milk:(10,5))

#columns(2)[
  #tbl(df2)
  #colbreak()
  #tbl(df3)]
```
displays:

![Example 3](https://raw.githubusercontent.com/oravard/typst-dataframes/0.1.0/img/example-03.png)

If the arguments of function `add-rows` do not provides each columns, the missing elements are replaced with the `missing` value:
```typst

#let df2 = add-rows(df, Year:2024, Fruits:25, Vegetables:20)
#let df3 = add-rows(df, Year:2024, Fruits:25, Vegetables:20, missing:"/")
#columns(2)[
  #tbl(df2)
  #colbreak()
  #tbl(df3)]
```
displays:

![Example 4](https://raw.githubusercontent.com/oravard/typst-dataframes/0.1.0/img/example-04.png)

Be carreful using the `missing` argument which default is `none`. Future numerical operations using rows / cols will raise an error. Provide a numerical value for the `missing` argument if you want to do future numerical operations between rows / cols.


a shortcut `vcat` to `add-rows` is provided for people who are more confortable with Python or Julia terminology.

### concatenation

The concatenation of two dataframes can be done using the `concat` function. The `concat` function takes two dataframes as arguments. The result is a dataframe using the following rules:

- if the column names of the two dataframes are the same, the second dataframe is added to the first as new rows.
- if all column names of the second dataframe are different of the first dataframe column names, the second dataframe is added to the first as new columns. It implies that the number of rows of the two dataframes are the same.

```typst
#let df = dataframe(
                    Year:(2021,2022,2023),
                    Fruits:(10,20,30),
                    Vegetables:(11,15,35)
                    )
#let df2 = dataframe(
                    Year:2024,
                    Fruits:25,
                    Vegetables:20
          )
#let df3 = dataframe(Milk:(19,5,15))
#columns(2)[
#tbl(concat(df,df2))
#colbreak()
#tbl(concat(df,df3))
```
displays:

![Example 5](https://raw.githubusercontent.com/oravard/typst-dataframes/0.1.0/img/example-05.png)

The dataframe `df2` is equivalent to adding row to `df` while `df3` is equivalent to adding column to `df`.

### slice

The `slice` function allows to select rows and cols of a dataframe returning a new dataframe. The arguments of the `slice` function are:

- `row-start`: the first row to return (default:0)
- `row-end`: the last row to return (default: none -> the last)
- `row-count`: the number of rows to return (default: -1 -> row-end - row-start)
- `col-start`: the first col to return (default:0)
- `row-end`: the last col to return (default: none -> the last)
- `row-count`: the number of cols to return (default: -1 -> col-end - col-start)
Example :

```typst
#tbl(slice(df, row-start:1, col-start:1))
```
displays:


![Example 6](https://raw.githubusercontent.com/oravard/typst-dataframes/0.1.0/img/example-06.png)

### select 

The select function allows to select rows or columns.
- rows are selected given their name or a filter function 
- cols are selected given a filter function

The arguments of the `select` function are:
- `rows` : (default:`auto`) a filter function which return `true` for all desired rows. 
- `cols`: (default:`auto`) an array of col names or a string of col name or a function which returns `true` for the desired cols.

Example:

```typst
#let df2 = select(df, rows:r=>r.Year > 2022)
#let df3 = select(df, cols:r=>r!="Fruits")
#tbl(select(df, cols:("Fruits","Vegetables"),
                  rows:r=>r.Year > 2022))
```

### sorted

The `sorted` function allows to sort a dataframe. The arguments are:
- `col`: the column name for sorting (ascending)
- `rev`: (default:`false`) `true` for reverse mode (descending)
Example:
```typst
sorted(df,"Year",rev:true)
```
## Numerical operations
Many operations can be done on dataframes. We have four kind of operations: unary, two elements, cumulative and folding.

### Unary operations

An unary operation make the same operation on all elements of a dataframe. Here is the list of available unary operations:

| Function name | Description |
|---------------|-------------|
| `abs`   | returns the absolute value (ex: `abs(df)`)|
| `ceil`  | returns the nearest greter integer|
| `floor` | returns the nearest smaller integer|
| `round` | returns the rounding value. You can use the named argument `digits` (ex: `round(df,digits:2)`) |
| `exp`   | returns exponential value |
| `log`   | returns the logarithmic value |
| `sin`   | returns sinus |
| `cos`   | returns cosinus |

### Two elements operations

For example, some elements can be added to a dataframe using the `add(df,other)` function. We consider four cases for this kind of operation :

- if `other` is a scalar: `other` is added to all efements of `df`
- if `other` is a dataframe: 
    - if `other` number cols is 1, then each col of `df` is added term by term with `other`
    - if `other` number cols is equal to `df` number cols, each col of `df` is added term by term to the col of `other` with the same index
    - if `other` column names are equal to `df` column names, each col of `df` is added term by term to the col of `other` which have the same name.

Example:

![Example 7](https://raw.githubusercontent.com/oravard/typst-dataframes/0.1.0/img/example-07.png)

These rules applies to all the following two elements functions:

| Function  | Description  |
|-----------|--------------|
|`add`      | Addition `add(df,other)`    |
|`substract`| Substraction `substract(df,other)`|
|`mult`     | Multiplication `mult(df,other)` |
|`div`      | Division `div(df,other)` |

### Cumulative operations
A cumulative operation on a dataframe is an operation where each row (or col) is the result of an operation on all preceding rows (or cols).
Each cumulative operation take a dataframe `df` as positional argument and `axis` as named argument. If `axis:1` (default), the operation is made on rows and if `axis:2`, the operation is made on columns.

The cumulative operations are the following:

|Function | Description |
|-|-|
|`cumsum`| Cumulative sum|
|`cumprod`| Cumulative product|

Example:


![Example 8](https://raw.githubusercontent.com/oravard/typst-dataframes/0.1.0/img/example-08.png)

### Folding operation

A folding operation is an operation which result in one row (or col) using a folding operation. For example, the `sum(df)` function on a dataframe `df` will give a row with each element is the sum of the corresponding `df` col.

Each folding operation take a dataframe `df` as positional argument and `axis` as named argument. If `axis:1` (default), the operation is made on rows and if `axis:2`, the operation is made on columns.

The folding operations are the following:

|Function | Description |
|-|-|
| `sum` | sum of all elements of each column or row |
| `product` | product of all elements of each column or row |
| `min` | minimum of all elements of each column or row |
| `max` | maximum of all elements of each column or row |
| `mean` | mean value of all elements of each column or row |

Example:


![Example 9](https://raw.githubusercontent.com/oravard/typst-dataframes/0.1.0/img/example-09.png)

### Other operations

|Function | Description |
|-----------|-|
|`diff(df,axis:1)`| Compute the difference between each element of `df` and the element in the same column (row if `axis:2`) and preceding row (column if `axis:2`)

## Dataframe from CSV

Dataframes can be created from a CSV file using the `dataframe-from-csv` function which takes a `CSV` object as positional argument.

The `dataframe-from-csv` use the `tabut` package but, in addition, this function supports datetime fields. 

Example:

```typst
#let df = dataframe-from-csv(csv("data/AAPL.csv"))
#tbl(slice(df, row-end:5))
```
displays:

![Example 10](https://raw.githubusercontent.com/oravard/typst-dataframes/0.1.0/img/example-10.png)


## Display a dataframe as table

the `tbl` function displays the dataframe as a typst table. This function use the `tabut` function of the `tabut` package. All named argument as passed to the `tabut` function.

Example: display transposed dataframe

```typst
#let df = slice(dataframe-from-csv(csv("data/AAPL.csv")),row-end:5)
#tbl(df, transpose:true)
```
displays:


![Example 11](https://raw.githubusercontent.com/oravard/typst-dataframes/0.1.0/img/example-11.png)

if you want to specify more display details using `tablex` (as an example), the `tabut-cells` is available for dataframes.

All arguments are passed to `tabut-cells` function.

See `tabut` package documentation for more details.

Example:

```typst
#let df = dataframe(
                    Year:(2021,2022,2023),
                    Fruits:(10,20,30),
                    Vegetables:(11,15,35)
                    )
#import "@preview/tablex:0.0.8":*
#tablex(
  ..tabut-cells(df,
  (
    (header: "Year", func:r=>r.Year),
    (header:"Fruits", func:r=>r.Fruits)
  ),
  headers:true
))
```

displays:

![Example 12](https://raw.githubusercontent.com/oravard/typst-dataframes/0.1.0/img/example-12.png)

For more informations about using `tabut-cells` function, see the `tabut` package documentation.

## Display a dataframe as plot

The `plot` function allowed to plot dataframes. Each column of the dataframe is a curve labeled in a legend by their column name. x-axis is the dataframe index if it is not provided in arguments, but a specified column can be used as x-axis which supports datetime.

The plot is build using the `cetz` package. All default parameters are chosen in order to have a scientific standard look and feel, but additionnal parameters are transmitted to `cetz` functions.

```typst
plot(df,    x-label:none, 
            y-label:none,
            y2-label:none, 
            label-text-size:1em,
            tick-text-size:0.8em,
            x-tick-step:auto,
            y-tick-step:auto,
            y2-tick-step:auto,
            x-tick-rotate:0deg,
            x-tick-anchor:"north",
            y-tick-rotate:0deg,
            y-tick-anchor:"east",
            y2-tick-rotate:0deg,
            y2-tick-anchor:"west",
            x-minor-tick-step:auto,
            y-minor-tick-step:auto,
            y2-minor-tick-step:auto,
            x-min:none,
            y-min:none,
            x-max:none,
            y-max:none,
            x-axis-padding:2%,
            y-axis-padding:2%,
            axis-style:"scientific",
            grid:false,
            width:80%,
            aspect-ratio:50%,
            style:(:),
            legend-default-position:"legend.inner-south-east",
            legend-padding:0.15,
            legend-spacing:0.3,
            legend-item-spacing:0.15,
            legend-item-preview-height:0.2,
            legend-item-preview-width:0.6,
            ..kw)
```

| <div style="width:220px">Argument</div> | Description |
|-|-|
|`df`| The dataframe to display |
|`x`| The column name for the x-axis. By default, the dataframe index is used. x-axis column name can be datatime objects. In this case, tick labels are displayed using datetime.display(). x-axis can be a column which contains strings. In this case, the strings appears as x-tick labels and `x-tick-step` has no effect. |
|`y`| The curves to plot as y-axis. By default, all columns of the dataframe are plotted. `y` can be an array of column names to plot. |
|`x-label`| The label on x-axis. By default, `x-label` is the column name of the chosen column for x-axis.  |
|`y-label`| The label on y-axis. By default, no label. |
|`y2-label`| The label on y2-axis. By default, no label. |
|`label-text-size`| The text size of x-label and y-label.  |
|`tick-text-size`| The text size for tick labels. |
|`y-tick-step`| The separation between y axis ticks. |
|`y2-tick-step`| The separation between y2 axis ticks. |
|`x-tick-step`| The separation between x axis ticks. If the dataframe column chosen for x-axis contains datetimes, `x-tick-step` must be a duration object.|
|`x-tick-rotate`| An angle for x-tick rotation. |
|`x-tick-anchor`| Anchor of the x-tick labels ("north","south","west", "east", "center"). Useful when `x-tick-rotate` is used. |
|`y-tick-rotate`| An angle for y-tick rotation. |
|`y-tick-anchor`| Anchor of the y-tick labels ("north","south","west", "east", "center"). Useful when `y-tick-rotate` is used. |
|`y2-tick-rotate`| An angle for y2-tick rotation. |
|`y2-tick-anchor`| Anchor of the y2-tick labels ("north","south","west", "east", "center"). Useful when `y2-tick-rotate` is used. |
|`x-minor-tick-step`| The separation between minor x axis ticks. |
|`y-minor-tick-step`| The separation between minor y axis ticks. |
|`y2-minor-tick-step`| The separation between minor y2 axis ticks. |
|`x-min`| The min value for x-axis. It has no effect if the dataframe column chosen for x-axis contains strings. If the dataframe column chosen  for x-axis contains datetime objects, `x-min` must be a datetime object. |
|`y-min`| The min value for y-axis |
|`x-max`| The max value for x-axis. It has no effect if the dataframe column chosen for x-axis contains strings. If the dataframe column chosen  for x-axis contains datetime objects, `x-max` must be a datetime object. |
|`y-max`| The max value for y-axis. |
|`grid`| `true` to draw a grid for both x and y-axis. |
|`width`| The width of the canvas plot. An absolute or relative length which default is 80%. |
|`aspect-ratio`| The ratio height/width of the plot canvas. A ratio object which default is 50%. |
|`style`| A dictionary which defines each curve plot style. It is indexed by column names of the dataframe. Each value of this dictionary is also a dictionary with the following allowed keys: <BR> `color`: the color of the curve. Any values accepted by `cetz` is allowed.<BR> `label`: the label of the curve. By default label is the column name of the dataframe.<BR> `thickness`: the thickness of the curve. 0.5pt by default.<BR> `mark`: the mark for each point of the curve. By default, no mark but any character is allowed in addition to any value accepted by `cetz`.<BR>`mark-size`: the size of the mark. 0.15 by default.<BR>`dash`: `none`, `dashed`, `dotted` or any value accepted by `cetz`.<BR>`axes`: specifies which axes should be used for the given curve `("x","y")` for bottom / left axis and `("x","y2")` for bottom/right axis. <BR>In addition, any argument which is accepted by `cetz` will be passed to the `cetz.plot.add` function. |
|`legend-default-position`| Legend default position. All values accepted by `cetz` for legend position are allowed. |
|`legend-padding`| Space between the legend frame and and content. Default: 0.15 |
|`legend-spacing`| Space between the legend frame and plot axis. Default: 0.3|
|`legend-item-spacing`| Space between legend items. Default: 0.15|
|`legend-item-preview-height`| Height of each legend previews. Default: 0.2|
|`legend-item-preview-width`| Width of each legend previews. Default: 0.6|
| `kw` | additionnal arguments passed to `cetz.plot.plot` function. See `cetz` documentation for more information on available arguments. |


Example:

```typst
#let df = dataframe-from-csv(csv("data/AAPL.csv"))
#plot(df, x:"Date",
          y:("Close","High","Low"),
          x-tick-step:duration(days:5),
          x-tick-rotate:-45deg, x-tick-anchor:"west",
          style:(
            "Close": (color:red, thickness:1pt, mark:"o", line:"spline"),
            "Low":(color:rgb(250,40,0,100),hypograph:true, thickness:2pt),
            "High":(color:rgb(0,250,0,100),epigraph:true, thickness:2pt)
          ))
```
displays:

![Example 13](https://raw.githubusercontent.com/oravard/typst-dataframes/0.1.0/img/example-13.png)