// 表哥 (biaoge) — Typst 表格工具集
// 表格数据分组、汇总、单元格合并、列拆分等实用函数。

#import "table-style.typ": stroke_light, inner_frame
#import "conf.typ": conf
#import "conf-table.typ": group-tables
#import "group-csv-tools.typ": mergeSelectedColumns, splitColumnInRows, trimString
#import "group-csv.typ": summarize, summary-table, summary-table-data, summary-table-style, summary-table-style-noTotal, grouped-sum-table
#import "merge-cells.typ": merge-col, merge-table-data, merge-table-data-valueCol, merge-table, merge-table-valueCol
