// 分离表头和数据行
#let merge-col(data, merge-col-index) = data.map(r => r.at(merge-col-index))
#let mk-spancell(k,v) = {
  if k == 0 {
    "mergedCell"
  } else {
  if k ==1 {
    v
  } else {
     table.cell(rowspan: k, [#v])
  }
  }
}
#let mk-spancell-valueCol(k,v) = {
  if k == 0 {
    "mergedCell"
  } else {
  if k ==1 {
    v
  } else {
     table.cell(rowspan: k.at(0), [#k.at(1)])
  }
  }
}

#let merge-table-data(header,rows, merge-col-index, table-col-count) = {
  let data-header = header
  let data-rows = rows
  let merge-col = rows.map(r => r.at(merge-col-index))
  // 规避第一行或最后一行遗漏
  let arr = (data-header,) + merge-col + (data-header,)

    // 向下查找连续相同的单元格（在同一列）
  let arr-span = ()
  let arr-span-dict = ()
  let i = 1
  while i < arr.len() {
    let current-value = arr.at(i)
    // let i = j
    let span = 1
    while i+span  < arr.len() {
      if arr.at(i+span) == current-value {
        span += 1
        } else {
      arr-span += (span,)
      arr-span += (0,) * (int(span)-1)
        break
        }
        // i +=span
      }
    i += span
}

let arr-span-data = arr-span.zip(merge-col)
    // arr-span-dict
    let arr-span-data = arr-span-data.map(((k,v)) => (mk-spancell(k,v),)*table-col-count)
    let merged = {
    for (row1, row2) in arr-span-data.zip(data-rows) {
      if merge-col-index > 0{
      (row2.slice(0,merge-col-index),row1.at(merge-col-index),..row2.slice(merge-col-index+1))
      } else {
      (row1.at(merge-col-index),..row2.slice(merge-col-index+1))
      }
    }
} 
(header: data-header, rows: merged.filter(r => {r != "mergedCell"}))
}
#let merge-table-data-valueCol(header,rows, merge-col-index, table-col-count, value-col-index) = {
  let data-header = header
  let data-rows = rows
  let merge-col = rows.map(r => r.at(merge-col-index))
  let value-col = rows.map(r => (r.at(value-col-index)))
  // 规避第一行或最后一行遗漏
  let arr = (data-header,) + merge-col + (data-header,)
  let brr = (0,) + value-col + (0,)

    // 向下查找连续相同的单元格（在同一列）
  let arr-span = ()
  let arr-span-dict = ()
  let brr-span = ()
  let brr-span-dict = ()
  let i = 1
  while i < arr.len() {
    let current-value = arr.at(i)
    // let i = j
    let span = 1
    let vol-sum = decimal(str(brr.at(i)).split(regex("[%]")).at(0))
    while i+span  < arr.len() {
      if arr.at(i+span) == current-value {
        vol-sum += decimal(str(brr.at(i+span)).split(regex("[%]")).at(0))
        span += 1
        } else {
      arr-span += (span,)
      arr-span += (0,) * (int(span)-1)
      brr-span += ((span,str(vol-sum)+"%"),)
      brr-span += (0,) * (int(span)-1)
        break
        }
      }
    i += span
}

let arr-span-data = arr-span.zip(merge-col)
let brr-span-data = brr-span.zip(value-col)
    // arr-span-dict
    let arr-span-data = arr-span-data.map(((k,v)) => (mk-spancell(k,v),)*table-col-count)
    let brr-span-data = brr-span-data.map(((k,v)) => (mk-spancell-valueCol(k,v),)*table-col-count)
    let merged = {
    for (row1, row2, row3) in arr-span-data.zip( data-rows, brr-span-data ) {
      if merge-col-index > 0{
      (row2.slice(0,merge-col-index),row1.at(merge-col-index),..row2.slice(merge-col-index+1),row3.at(merge-col-index),)
      } else {
      (row1.at(merge-col-index),..row2.slice(merge-col-index+1),row3.at(merge-col-index),)
      }
    }
} 
(header: data-header, rows: merged.filter(r => {r != "mergedCell"}))
}

#let merge-table(header, rows, merge-col-index, table-col-count) = {
  let merge-table-dict = merge-table-data(header, rows, merge-col-index, table-col-count)
  table(columns:header.len(),
  table.header(
      ..merge-table-dict.at("header"),
    ),
  ..merge-table-dict.at("rows").map(r=>  [#r] ))
  
}

#let merge-table-valueCol(header, rows, merge-col-index, table-col-count, value-col-index) = {
  let merge-table-dict = merge-table-data-valueCol(header, rows, merge-col-index, table-col-count, value-col-index)
  table(columns:header.len(),
  table.header(
      ..merge-table-dict.at("header"),
    ),
  ..merge-table-dict.at("rows").map(r=>  [#r] ))
  
}