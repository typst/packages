#let heading-numbering(..nums) = {
  let nums-vec = nums.pos()

  if nums-vec.len() == 1 [
    第 #numbering("1", ..nums-vec) 章
  ] else {
    numbering("1.1", ..nums-vec)
  }
}