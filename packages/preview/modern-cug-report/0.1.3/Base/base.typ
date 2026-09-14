// 判断是否为标量类型（不是容器类型）
#let is-scalar(val) = {
  type(val) not in (array, dictionary)
}


/**
 * 递归合并dict，base是默认的全部参数，config是用户设定的部分参数
 */
#let merge-dict(base, config) = {
  // 深度合并字典，递归处理嵌套字典
  if type(base) != dictionary or type(config) != dictionary {
    panic("Both arguments must be dictionaries.")
  }
  
  let result = base
  for (key, replacement) in config {
    if key in base {
      let source = base.at(key)
      
      if type(source) == dictionary and type(replacement) == dictionary {
        result.insert(key, merge-dict(source, replacement)) // dict则递归合并
      } else if is-scalar(source) and is-scalar(replacement) {
        result.insert(key, replacement) // 标量类型则覆盖
      } else {
        // 类型不兼容，保留原值
      }
    } else {
      // result.insert(key, replacement)                        // 新键直接添加
    }
  }
  result
}

