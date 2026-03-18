#import "../utils/style.typ": 字号, 字体
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
#let active-heading(level: 1, prev: true, loc) = {
  // 之前页面的标题
  let prev-headings = query(selector(heading.where(level: level)).before(loc), loc)
  // 当前页面的标题
  let cur-headings = query(selector(heading.where(level: level)).after(loc), loc)
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
#let current-heading(level: 1, loc) = {
  // 当前页面的标题
  let cur-headings = query(selector(heading.where(level: level)).after(loc), loc)
    .filter(it => it.location().page() == loc.page())
  if cur-headings.len() != 0 {
    return cur-headings.first()
  } else {
    return none
  }
}

#let header-display(body) = {
  set text(font: 字体.楷体, size: 字号.五号)
  stack(
    align(center,body),
    stack(
      spacing: 1.4pt,
      line(length: 100%, stroke: 0.5pt+0.3pt + black),
      line(length: 100%, stroke: 0.5pt + black))
  )
}