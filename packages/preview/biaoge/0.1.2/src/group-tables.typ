// 以 group-col 列分割主表为多个表格

#let group-tables(data, group-col) = {
  let header = data.at(0)
  let rows = data.slice(1,)

  // 获取分组列索引（支持列名或索引）
  let col-index = if type(group-col) == str {
    header.position(col => col == group-col)
  } else {
    group-col
  }

  // 获取分组列的唯一值
  let group-values = rows.map(row => row.at(col-index)).dedup()

  // 创建每个分组表格
  for value in group-values {
    // 筛选数据
    let filtered-rows = rows.filter(row => row.at(col-index) == value)

    // 从表中移除分组列
    let display-rows = filtered-rows.map(row => {
      row.enumerate().filter(y => y.at(0) != col-index).map(it => it.at(1))
    })
    let display-header = header.enumerate()
      .filter(y => y.at(0) != col-index)
      .map(it => it.at(1))

    [== #value 所需字段]

    if display-rows.len() > 0 {
      table(
        columns: (auto,) * display-header.len(),
        table.header(..display-header),
        ..display-rows.flatten(),
      )
    } else {
      [*暂无数据*]
    }

    v(0.5em)
  }
}
