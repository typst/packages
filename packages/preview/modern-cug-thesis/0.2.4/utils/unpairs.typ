// 将 pairs 数组转成 dict 字典
#let unpairs(pairs) = {
  let dict = (:)
  for pair in pairs {
    dict.insert(..pair)
  }
  dict
}