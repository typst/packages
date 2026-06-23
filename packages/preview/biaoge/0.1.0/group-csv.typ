#import "table-style.typ": stroke_light, inner_frame
#import "group-csv-tools.typ":splitColumnInRows, mergeSelectedColumns 
#import "merge-cells.typ": merge-table-data,merge-table-data-valueCol, merge-table, merge-table-valueCol

// 定义汇总函数
#let summarize(data, groupIndex, valueIndex) = {
  let groups = data.map(row => row.at(groupIndex)).dedup()
  return groups.map(group => {
    let items = data.filter(row => row.at(groupIndex) == group)
    let total = items.map(row => decimal(row.at(valueIndex))).sum()
    let count = items.len()
    return (group: group, total: total, count: count)
  })
}

// 定义表格生成函数
#let summary-table-data(data, groupIndex, valueIndex) = {
  let header=([*分类*],[*数量*],[*合计*],[*占比*])
  let data = data.slice(1,)
  let summary = summarize(data, groupIndex, valueIndex)
  let sorted = summary.sorted(key: row => row.total, by:(l, r) => l>= r)
  let grandTotal = data.map(row => decimal(row.at(valueIndex))).sum()

  let rows = sorted.map(row =>
    (row.group,
    str(row.count),
    // "¥" + str(row.total),
    str(row.total),
    str(calc.round(row.total / grandTotal *100  , digits: 2))    + "%"),
    )
  let total-row = (
    [*总计*], str(data.len()), 
      // "¥" + str(grandTotal)
      str(grandTotal)
    , [*100%*],)
  return (header: header, rows: rows, total-row: total-row)
}

// 定义表格生成函数

#let summary-table(data, groupIndex, valueIndex, title) = {
  let result = summary-table-data(data, groupIndex, valueIndex)
  let header = result.header
  let rows = result.rows
  let total-row = result.total-row
  align(center)[#title]
  table(
    columns: (4fr,) + (1fr,) * (header.len()-1),
    // stroke: stroke_light,
    stroke: inner_frame(stroke_light),
    inset: 10pt,
    // 标题行
    align: (center,) + (right,)*(header.len()-1),
    // 表头
    table.header(..header),
    // 数据行
    ..rows.flatten(),        
    // 数据行结束画一条线
    table.hline(stroke: stroke_light),
    // 总计行
    ..total-row,
  ) 
  }
#let summary-table-style(header, rows, valueIndex, title ) = {
  let grandTotal = rows.map(row => decimal(row.at(valueIndex))).sum()
  let total-row = (
    [*总计*], str(rows.len()), 
      // "¥" + str(grandTotal)
      str(grandTotal)
    , [*100%*],)
  align(center)[#title]
  table(
    columns: (1fr,)*2 + (0.5fr,) * (header.len()-2),

    stroke: inner_frame(stroke_light),
    inset: 10pt,
    // 标题行
    align: (center,)*2 + (right,)*(header.len()-2),
    // 表头
    table.header(..header),
    // 数据行
    ..rows.flatten(),        
    // 数据行结束画一条线
    table.hline(stroke: stroke_light),
    // 总计行
      
    ..total-row,
  ) 
  }
#let summary-table-style-noTotal(header, rows, valueIndex, title ) = {
  // let grandTotal = rows.map(row => decimal(row.at(valueIndex))).sum()
  // let total-row = (
  //   [*总计*], str(rows.len()), 
  //     // "¥" + str(grandTotal)
  //     str(grandTotal)
  //   , [*100%*],)
  align(center)[#title]
  table(
    columns: (1fr,)*2 + (0.5fr,) * (header.len()-2),

    stroke: inner_frame(stroke_light),
    inset: 10pt,
    // 标题行
    align: (center,)*2 + (right,)*(header.len()-2),
    // 表头
    table.header(..header),
    // 数据行
    ..rows.flatten(),        
    // 数据行结束画一条线
    table.hline(stroke: stroke_light),
    // // 总计行
    // if hasTotal {
      
    // ..total-row,
    // }
  ) 
  }
// 按照 groupIndex1 + groupIndex2 对 valueIndex 分类汇总排序
#let grouped-sum-table(data, groupIndex1, groupIndex2, valueIndex, tb-header, tb-title, colNums: 6) = {

  
  //*start 找出主管部门排序
  // #summary-table(data,2,5,"表2  按主管部门分类字段数量明细表")
  let summaryOrderByDep = summary-table-data(data,groupIndex1, valueIndex).rows.map(
  r => r.at(0)
  ).dedup()

  let primaryOrder = ()
  for (i,v) in summaryOrderByDep.enumerate() {
      primaryOrder.push( (v, i) )
    }
  let primaryOrderDict = primaryOrder.to-dict()
  // 找出主管部门排序 end*//
  // 方式1：合并成字符串
  let result = mergeSelectedColumns(data, (groupIndex1, groupIndex2), transform: values => values.join(" - "))

  let table-data = summary-table-data(result,groupIndex1, int(valueIndex) - 1,)

  let split-rows = splitColumnInRows(table-data.rows, 0)

  let table-data-rows-sorted = split-rows.sorted(
    key: item => primaryOrderDict.at(item.at(0))
  )

  let tb-rows = splitColumnInRows(table-data-rows-sorted, 0)
  let tb-data-valueCol = merge-table-data-valueCol(tb-header, tb-rows,0,colNums,4)
  summary-table-style-noTotal( tb-data-valueCol.at("header"), tb-data-valueCol.at("rows"), 3,tb-title)
}
