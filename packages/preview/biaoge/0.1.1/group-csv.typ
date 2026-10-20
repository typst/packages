#import "table-style.typ": stroke-light, inner-frame
#import "group-csv-tools.typ": split-column-in-rows, merge-selected-columns
#import "merge-cells.typ": merge-table-data, merge-table-data-value-col, merge-table, merge-table-value-col

// 定义汇总函数
#let summarize(data, group-index, value-index) = {
  let groups = data.map(row => row.at(group-index)).dedup()
  return groups.map(group => {
    let items = data.filter(row => row.at(group-index) == group)
    let total = items.map(row => decimal(row.at(value-index))).sum()
    let count = items.len()
    return (group: group, total: total, count: count)
  })
}

// 定义表格生成函数
#let summary-table-data(data, group-index, value-index) = {
  let header=([*分类*],[*数量*],[*合计*],[*占比*])
  let data = data.slice(1,)
  let summary = summarize(data, group-index, value-index)
  let sorted = summary.sorted(key: row => row.total, by:(l, r) => l>= r)
  let grandTotal = data.map(row => decimal(row.at(value-index))).sum()

  let rows = sorted.map(row =>
    (row.group,
    str(row.count),
    str(row.total),
    str(calc.round(row.total / grandTotal *100  , digits: 2))    + "%"),
    )
  let total-row = (
    [*总计*], str(data.len()),
      str(grandTotal)
    , [*100%*],)
  return (header: header, rows: rows, total-row: total-row)
}

// 定义表格生成函数

#let summary-table(data, group-index, value-index, title) = {
  let result = summary-table-data(data, group-index, value-index)
  let header = result.header
  let rows = result.rows
  let total-row = result.total-row
  align(center)[#title]
  table(
    columns: (4fr,) + (1fr,) * (header.len()-1),
    stroke: inner-frame(stroke-light),
    inset: 10pt,
    align: (center,) + (right,)*(header.len()-1),
    table.header(..header),
    ..rows.flatten(),
    table.hline(stroke: stroke-light),
    ..total-row,
  )
  }
#let summary-table-style(header, rows, value-index, title ) = {
  let grandTotal = rows.map(row => decimal(row.at(value-index))).sum()
  let total-row = (
    [*总计*], str(rows.len()),
      str(grandTotal)
    , [*100%*],)
  align(center)[#title]
  table(
    columns: (1fr,)*2 + (0.5fr,) * (header.len()-2),

    stroke: inner-frame(stroke-light),
    inset: 10pt,
    align: (center,)*2 + (right,)*(header.len()-2),
    table.header(..header),
    ..rows.flatten(),
    table.hline(stroke: stroke-light),
    ..total-row,
  )
  }
#let summary-table-style-no-total(header, rows, value-index, title ) = {
  align(center)[#title]
  table(
    columns: (1fr,)*2 + (0.5fr,) * (header.len()-2),

    stroke: inner-frame(stroke-light),
    inset: 10pt,
    align: (center,)*2 + (right,)*(header.len()-2),
    table.header(..header),
    ..rows.flatten(),
    table.hline(stroke: stroke-light),
  )
  }
// 按照 group-index-1 + group-index-2 对 value-index 分类汇总排序
#let grouped-sum-table(data, group-index-1, group-index-2, value-index, tb-header, tb-title, col-nums: 6) = {


  //*start 找出主管部门排序
  let summaryOrderByDep = summary-table-data(data,group-index-1, value-index).rows.map(
  r => r.at(0)
  ).dedup()

  let primaryOrder = ()
  for (i,v) in summaryOrderByDep.enumerate() {
      primaryOrder.push( (v, i) )
    }
  let primaryOrderDict = primaryOrder.to-dict()
  // 找出主管部门排序 end*//

  let result = merge-selected-columns(data, (group-index-1, group-index-2), transform: values => values.join(" - "))

  let table-data = summary-table-data(result,group-index-1, int(value-index) - 1,)

  let split-rows = split-column-in-rows(table-data.rows, 0)

  let table-data-rows-sorted = split-rows.sorted(
    key: item => primaryOrderDict.at(item.at(0))
  )

  let tb-rows = split-column-in-rows(table-data-rows-sorted, 0)
  let tb-data-valueCol = merge-table-data-value-col(tb-header, tb-rows,0,col-nums,4)
  summary-table-style-no-total( tb-data-valueCol.at("header"), tb-data-valueCol.at("rows"), 3,tb-title)
}
