# Algorithmic NEWS

## v1.0.6

> ![INFO]
> @TimeTravelPenguin fixed an issue with `Assign` not working with nested blocks (#23, #24).
>
> Algorithms similar to the one below will now render correctly.
> ```typ
> #{
>   let Solve = Call.with("Solve")
>   Assign($x$, Solve[$A$, $b$])
> }
> ```

## v1.0.5

> ![INFO]
> Added an option `line-numbers` to toggle line numbers on/off (#22).
> ```typ
> #algorithm(line-numbers: false, ...)
> #algorithm-figure(line-numbers: false, ...)
> ```
> If you would like to remove line numbers globally, you can define
> ```typ
> #let algorithm = algorithm.with(line-numbers: false)
> #let algorithm-figure = algorithm-figure.with(line-numbers: false)
> ```

> ![INFO]
> Fix an issue with `algorithm-figure` float placement (#21).
> `style-algorithm` now has options `placement` and `scope` mimicking `figure`.
> By default, options set on `figure(kind: "algorithm")` supersede those of
> `style-algorithm`.
> ```typ
> #show: style-algorithm.with(placement: top, scope: "column")
> #show figure.where(kind: "algorithm").with(placement: bottom, scope: "parent")
> ```
> The above example will place algorithm figures at the bottom of the parent scope.

## v1.0.4

> ![INFO]
> @drecouse fixed an issue with `LineComment` preventing loops' body from displaying (#20).
> Now, you can use `LineComment` on loops without issues.
> ```typ
> LineComment(
>   While($j <= 10$, {
>     Assign[$x$][1]
>   }),
>   "This is inside a nested block",
> )
> ```
> ![Screenshot of an algorithm showing a for-loop from i = 1 to 10, with each iteration containing a line calculation (1+1) and a nested while-loop from j = 1 to 10 assigning x = 1, with line comments describing "This is inside a nested block" and "This is a line comment after a block".](https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.4/tests/linecommentfor/ref/1.png)

> ![INFO]
> `algorithm-figure` does not set `placement: none` anymore (#21).


## v1.0.3

> ![WARNING]
> algorithmic now use grids instead of tables for accessibility purposes, see [layout/grid](https://typst.app/docs/reference/layout/grid/#:~:text=Typst%20will%20annotate%20its%20output%20such%20that%20screenreaders%20will%20announce%20content%20in%20table%20as%20tabular).
> Any `table.hlines` in `style-algorithm` will error and `grid.hlines` must be used instead.

> ![INFO]
> This version fixes an issue with the indentation offset where the last column corresponding to comments goes in the margin.

> ![INFO]
> `State` is renamed to `Line` and will now work with other commands such as `LineComment`. Documentation is added in the [README](README.md).
