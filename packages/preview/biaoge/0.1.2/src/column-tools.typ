#let merge-selected-columns(data, indices, transform: (values) => values.join(" - ")) = {
  // 保持原始列的顺序，只是将指定列替换为合并值

  if data.len() > 0 and type(data.first()) == array {
    // 处理二维数组
    data.map(row => {
      let merged-value = transform(indices.map(idx => row.at(idx)))
      let new-row = ()
      let merged-added = false

      for i in range(row.len()) {
        if indices.contains(i) {
          if not merged-added {
            new-row += (merged-value,)
            merged-added = true
          }
        } else {
          new-row += (row.at(i),)
        }
      }

      if not merged-added and indices.len() > 0 {
        new-row += (merged-value,)
      }

      new-row
    })
  } else {
    // 处理一维数组
    let merged-value = transform(indices.map(idx => data.at(idx)))
    let new-row = ()
    let merged-added = false

    for i in range(data.len()) {
      if indices.contains(i) {
        if not merged-added {
          new-row += (merged-value,)
          merged-added = true
        }
      } else {
        new-row += (data.at(i),)
      }
    }

    if not merged-added and indices.len() > 0 {
      new-row += (merged-value,)
    }

    new-row
  }
}

#let trim-string(str) = {
  let start = 0
  let end = str.len()

  // 去除开头空格
  while start < end and str.at(start) == " " {
    start += 1
  }

  // 去除结尾空格
  while end > start and str.at(end - 1) == " " {
    end -= 1
  }

  str.slice(start, end)
}

#let split-column-in-rows(data, split-column-index, separator: " - ") = {
  data.map(row => {
    let col-value = row.at(split-column-index)
    let split-parts = if type(col-value) == str {
      col-value.split(separator).filter(part => part != "")
    } else {
      (col-value,)
    }

    // 重新构建行
    let before = row.slice(0, split-column-index)
    let after = row.slice(split-column-index + 1)
    before + split-parts + after
  })
}
