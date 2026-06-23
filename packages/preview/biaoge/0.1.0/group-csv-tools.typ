#let mergeSelectedColumns(data, indices, transform: (values) => values.join(" - ")) = {
  // 这个版本保持原始列的顺序，只是将指定列替换为合并值

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
          // 如果是第一个指定列，添加合并值
          if not mergedAdded {
            newRow = newRow + (mergedValue,)
            mergedAdded = true
          }
          // 跳过其他指定列
        } else {
          // 非指定列，直接添加
          newRow = newRow + (row.at(i),)
        }
      }

      // 如果没有指定列（indices为空），在末尾添加合并值
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

#let trimString(str) = {
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

#let splitColumnInRows(data, splitColumnIndex, separator: " - ") = {
  data.map(row => {
    let colValue = row.at(splitColumnIndex)

    let splitParts = if type(colValue) == str {
      colValue.split(separator)
        .map(part => part)
        .filter(part => part != "")
    } else {
      (colValue,)
    }

    // 重新构建行
    let before = row.slice(0, splitColumnIndex)
    let after = row.slice(splitColumnIndex + 1)

    before + splitParts + after
  })
}
