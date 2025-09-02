// 展示一个标题
#let heading-display(it) = {
  if it != none and type(it) == content and it.has("body") {
    let result = ""
    if it.has("numbering") and it.numbering != none {
      result += numbering(it.numbering, ..counter(heading).at(it.location()))
      result += " "
    }
    result += str(it.body)
    result
  } else {
    ""
  }
}

// 获取当前激活的 heading，参数 prev 用于标志优先使用之前页面的 heading
#let active-heading(level: 1, prev: true) = context {
  let current-page = here().page()
  
  // 获取所有相关级别的标题
  let all-headings = query(heading.where(level: level))
  
  // 当前页面的标题（包括当前位置之前和之后的）
  let cur-page-headings = all-headings.filter(it => it.location().page() == current-page)
  
  // 当前页面之前所有页面的标题
  let prev-headings = all-headings.filter(it => it.location().page() < current-page)
  
  // 当前页面之后所有页面的标题  
  let after-headings = all-headings.filter(it => it.location().page() > current-page)
  
  // 优先级：
  // 1. 如果当前页面有标题，使用当前页面的第一个标题
  if cur-page-headings.len() > 0 {
    return cur-page-headings.first()
  }
  
  // 2. 如果当前页面没有标题，使用之前最近页面的最后一个标题
  if prev-headings.len() > 0 {
    return prev-headings.last()
  }
  
  // 3. 如果之前也没有标题，使用之后最近页面的第一个标题
  if after-headings.len() > 0 {
    return after-headings.first()
  }
  
  // 4. 如果都没有，返回 none
  return none
}

// 获取当前页面的标题
#let current-heading(level: 1) = context {
  let current-page = here().page()
  
  // 获取所有相关级别的标题
  let all-headings = query(heading.where(level: level))
  
  // 当前页面的标题
  let cur-page-headings = all-headings.filter(it => it.location().page() == current-page)
  
  if cur-page-headings.len() != 0 {
    return cur-page-headings.first()
  } else {
    return none
  }
}
