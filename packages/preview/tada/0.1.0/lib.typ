#import "src/ops.typ"
#import "src/tabledata.typ"
#import "src/display.typ"
#import "src/helpers.typ"

#import display: to-tablex
#(import tabledata: 
  add-expressions,
  count,
  drop,
  from-columns,
  from-rows,
  from-records,
  item,
  stack,
  subset,
  TableData,
  transpose,
  update-fields
)
#import ops: agg, chain, filter, group-by, sort-values

#let tada-version = toml("typst.toml").package.version
