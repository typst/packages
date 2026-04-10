// 定义一个函数来检查前面是否紧跟着另一个标题
#let smart-heading-spacing(default-space, level) = {
  // 返回一个可以在context中计算的长度值
  context {
    let before = query(selector(heading).before(here()), here())
    if before.len() > 0 {
      // 简单检查：如果前面有标题，检查它们之间的距离
      let last-heading-loc = before.last().location()
      let current-loc = here()
      
      // 查询两个位置之间的内容
      let content-between = query(selector().after(last-heading-loc).before(current-loc), current-loc)
      
      // 如果两个标题之间只有很少的内容（比如只有空白），则使用0pt间距
      if content-between.len() <= 2 {  // 允许少量的空白元素
        0pt
      } else {
        default-space
      }
    } else {
      default-space
    }
  }
}

// 简化的智能标题间距函数
#let smart-v(default-space) = context {
  let before = query(selector(heading).before(here()), here())
  if before.len() > 0 {
    // 检查前一个标题和当前位置之间是否有实质内容
    let last-heading = before.last()
    let between = query(selector().after(last-heading.location()).before(here()), here())
    
    // 如果两个标题之间内容很少，认为是相邻标题
    let spacing = if between.len() <= 3 { 0pt } else { default-space }
    v(spacing, weak: true)
  } else {
    v(default-space, weak: true)
  }
}