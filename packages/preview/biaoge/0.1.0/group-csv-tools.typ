#let merge-selected-columns(data, indices, transform: (values) => values.join(" - ")) = {
  // 保持原始列的顺序，只是将指定列替换为合并值

  if data.len() > 0 and type(data.first()) == array {
    // 处理二维数组
    data.map(row => {
      // 计算合并值
      let mergedValue = transform(indices.map(idx => row.at(idx)))

      // 构建新行，保持原始列顺序
      let newRow = ()
      let mergedAdded = false

      for i in range(0, row.len()) {
        if indices.contains(i) {
          if not mergedAdded {
            newRow = newRow + (mergedValue,)
            mergedAdded = true
          }
        } else {
          newRow = newRow + (row.at(i),)
        }
      }

      if not mergedAdded and indices.len() > 0 {
        newRow = newRow + (mergedValue,)
      }

      newRow
    })
  } else {
    // 处理一维数组
    let mergedValue = transform(indices.map(idx => data.at(idx)))
    let newRow = ()
    let mergedAdded = false

    for i in range(0, data.len()) {
      if indices.contains(i) {
        if not mergedAdded {
          newRow = newRow + (mergedValue,)
          mergedAdded = true
        }
      } else {
        newRow = newRow + (data.at(i),)
      }
    }

    if not mergedAdded and indices.len() > 0 {
      newRow = newRow + (mergedValue,)
    }

    newRow
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
    let colValue = row.at(split-column-index)

    let splitParts = if type(colValue) == str {
      colValue.split(separator)
        .map(part => part)
        .filter(part => part != "")
    } else {
      (colValue,)
    }

    // 重新构建行
    let before = row.slice(0, split-column-index)
    let after = row.slice(split-column-index + 1)

    before + splitParts + after
  })
}
