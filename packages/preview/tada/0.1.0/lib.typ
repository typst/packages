#import "src/ops.typ"
#import "src/tabledata.typ"
#import "src/display.typ"

#import display: to-tablex
#import tabledata: TableData, from-columns, values, item, concat, subset, transpose, with-field, with-row
#import ops: agg, chain, filter

#let version = toml("typst.toml").package.version
