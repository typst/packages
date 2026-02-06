// 展示一个标题
#let heading-display(it) = {
  if it != none {
    if it.has("numbering") and it.numbering != none {
      numbering(it.numbering, ..counter(heading).at(it.location()))
      [ ]
    }
    it.body
  } else {
    ""
  }
}

// 获取当前激活的 heading，参数 prev 用于标志优先使用之前页面的 heading
#let active-heading(level: 1, prev: true) = context {
  // 之前页面的标题
  let prev-headings = query(selector(heading.where(level: level)).before(here()))
  // 当前页面的标题
  let cur-headings = query(selector(heading.where(level: level)).after(here()))
    .filter(it => it.location().page() == loc.page())
  if prev-headings.len() == 0 and cur-headings.len() == 0 {
    return none
  } else {
    if prev {
      if prev-headings.len() != 0 {
        return prev-headings.last()
      } else {
        return cur-headings.first()
      }
    } else {
      if cur-headings.len() != 0 {
        return cur-headings.first()
      } else {
        return prev-headings.last()
      }
    }
  }
}

// 获取当前页面的标题
#let current-heading(level: 1) = context {
  // 当前页面的标题
  let cur-headings = query(selector(heading.where(level: level)).after(here()))
    .filter(it => it.location().page() == here().page())
  if cur-headings.len() != 0 {
    return cur-headings.first()
  } else {
    return none
  }
}