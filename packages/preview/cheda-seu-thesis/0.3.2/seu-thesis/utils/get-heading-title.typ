// 改自小蓝书
// https://typst-doc-cn.github.io/tutorial/intermediate/content-stateful-3.html

#let first-heading = state("first-heading", (:))
#let last-heading = state("last-heading", (:))


// 注：这个函数的逻辑在 `show-heading.typ` 内再次实现了一遍，因此注释掉了此处的代码
// 若需使用，请在 heading 设置格式的最后添加 `show: show-update-heading-title`
/*
#let show-update-heading-title(it) = {
  show heading.where(level: 1): curr-heading => {
    curr-heading
    
    context {
      let loc = here()
      last-heading.update(headings => {
        headings.insert(str(loc.page()), curr-heading)
        return headings
      })
      first-heading.update(headings => {
        let k = str(loc.page())
        if k not in headings.keys() {
          headings.insert(k, curr-heading)
        }
        return headings
      })
    }
  }
  it
}
*/

#let find-headings(headings, page-num) = if page-num > 0 {
  headings.at(str(page-num), default: find-headings(headings, page-num - 1))
}


// 返回 array `(str|none, bool,)` 
// 第一个元素表示当前的一级标题，如果找不到则为 none
// 第二个元素表示当前页面是否为标题页面，是则为 true
#let get-heading-at-page(loc) = {
  let page-num = loc.page()
  let first-headings = first-heading.final()
  let last-headings = last-heading.at(loc)

  let seek-heading = first-headings.at(str(page-num), default: none)

  if seek-heading != none {
    return (seek-heading, true)
  } else {
    return (find-headings(last-headings, page-num), false)
  }
}