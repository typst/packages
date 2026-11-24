// 分离表头和数据行
#let merge-col(data, merge-col-index) = data.map(r => r.at(merge-col-index))

// 统一 merge-col-index 参数：支持单个索引或索引数组（多级合并）
#let _merge-col-indices(merge-col-index) = {
  let indices = if type(merge-col-index) == int { (merge-col-index,) } else { merge-col-index }
  indices.fold((), (acc, index) => if acc.contains(index) { acc } else { acc + (index,) })
}

// 逐层计算每行在合并列上的 rowspan：
// 0 表示被上方单元格覆盖，k 表示起始且跨 k 行。
// 后一列只在前一列的分组内合并，从而支持多级合并。
#let _merge-spans(rows, merge-col-indices) = {
  let row-count = rows.len()
  let groups = if row-count == 0 { () } else { ((0, row-count),) }
  let spans = ()
  for col-index in merge-col-indices {
    let level-spans = ()
    let next-groups = ()
    for (start, end) in groups {
      let i = start
      while i < end {
        let value = rows.at(i).at(col-index)
        let j = i + 1
        while j < end and rows.at(j).at(col-index) == value {
          j += 1
        }
        level-spans += (j - i,) + (0,) * (j - i - 1)
        next-groups.push((i, j))
        i = j
      }
    }
    spans.push(level-spans)
    groups = next-groups
  }
  (spans: spans, groups: groups)
}

// 生成合并后的扁平单元格序列；被 rowspan 覆盖的单元格直接省略，
// 交给 Typst 表格的自动布局跳过。
#let _merged-cells(rows, merge-col-indices, value-col-index) = {
  let row-count = rows.len()
  let info = _merge-spans(rows, merge-col-indices)

  // 最内层分组（即最小的合并单元）的数值汇总
  let value-spans = ()
  let value-texts = ()
  if value-col-index != none {
    for (start, end) in info.groups {
      let total = range(start, end).map(k => {
        let raw = str(rows.at(k).at(value-col-index))
        decimal(raw.split(regex("[%]")).at(0))
      }).sum()
      value-spans += (end - start,) + (0,) * (end - start - 1)
      value-texts += (str(total) + "%",) + (none,) * (end - start - 1)
    }
  }

  let cells = ()
  for row-index in range(row-count) {
    for (col-index, value) in rows.at(row-index).enumerate() {
      let level = merge-col-indices.position(index => index == col-index)
      if level != none {
        let span = info.spans.at(level).at(row-index)
        if span == 1 {
          cells.push(value)
        } else if span > 1 {
          cells.push(table.cell(rowspan: span, [#value]))
        }
      } else if value-col-index != none and col-index == value-col-index {
        let span = value-spans.at(row-index)
        if span == 1 {
          cells.push(value-texts.at(row-index))
        } else if span > 1 {
          cells.push(table.cell(rowspan: span, [#value-texts.at(row-index)]))
        }
      } else {
        cells.push(value)
      }
    }
  }
  cells
}

// table-col-count 保留以兼容旧调用，实际列数由表头和行长度决定
#let merge-table-data(header, rows, merge-col-index, table-col-count) = {
  let indices = _merge-col-indices(merge-col-index)
  (header: header, rows: _merged-cells(rows, indices, none))
}
#let merge-table-data-value-col(header, rows, merge-col-index, table-col-count, value-col-index) = {
  let indices = _merge-col-indices(merge-col-index)
  (header: header, rows: _merged-cells(rows, indices, value-col-index))
}

#let merge-table(header, rows, merge-col-index, table-col-count) = {
  let merge-table-dict = merge-table-data(header, rows, merge-col-index, table-col-count)
  table(columns:header.len(),
  table.header(
      ..merge-table-dict.at("header"),
    ),
  ..merge-table-dict.at("rows"))

}

#let merge-table-value-col(header, rows, merge-col-index, table-col-count, value-col-index) = {
  let merge-table-dict = merge-table-data-value-col(header, rows, merge-col-index, table-col-count, value-col-index)
  table(columns:header.len(),
  table.header(
      ..merge-table-dict.at("header"),
    ),
  ..merge-table-dict.at("rows"))

}
