// 以group-col列分割主表为多个表格

#let group-tables(data, group-col) = {
  let header = data.at(0)
  let rows = data.slice(1,)
  
  // 获取分组列索引（支持列名或索引）
  let col-index = {
    if type(group-col) == str {
      // 如果是字符串，查找列名对应的索引
      header.position(col => col == group-col)
    } else {
      group-col
    }
  }
  
  
  // 获取分组列的唯一值
  let group-values = rows.map(row => row.at(col-index)).dedup()
  // [== 系统清单如下：]
  //   table(
  //     columns: 1,
  //     //stroke: none,
  //     ..group-values.flatten()
  //     )
  //   pagebreak()
  // 创建每个分组表格
  for value in group-values {
    // 筛选数据
    let filtered-rows = rows.filter(row => row.at(col-index) == value)
    
    // 如果需要，可以从表格中移除分组列
    let display-rows = filtered-rows.map(row => {
      row.enumerate().filter(y => y.at(0) != col-index).map(it => it.at(1))
    })
    
    let display-header = header.enumerate()
      .filter(y => y.at(0) != col-index)
      .map(it => it.at(1))
    // 创建表格
    [== #value 所需字段]
    
    if display-rows.len() > 0 {
      table(
        columns: (auto,) * display-header.len(),
        table.header(..display-header.flatten()),
        ..display-rows.flatten(),
        //map(row => row.map(col => [#col]))

      )
    } else {
      [*暂无数据*]
    }
    
    v(0.5em)
  }
}


