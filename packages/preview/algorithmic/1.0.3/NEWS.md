# Algorithmic NEWS

## v1.0.3

> ![WARNING]
> algorithmic now use grids instead of tables for accessibility purposes, see [layout/grid](https://typst.app/docs/reference/layout/grid/#:~:text=Typst%20will%20annotate%20its%20output%20such%20that%20screenreaders%20will%20announce%20content%20in%20table%20as%20tabular).
> Any `table.hlines` in `style-algorithm` will error and `grid.hlines` must be used instead.

> ![INFO]
> This version fixes an issue with the indentation offset where the last column corresponding to comments goes in the margin.

> ![INFO]
> `State` is renamed to `Line` and will now work with other commands such as `LineComment`. Documentation is added in the [README](README.md).
