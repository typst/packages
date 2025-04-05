// 定义页面样式

// 设置页边距离，使用 word 标准页边距
// - 顶部和底部为 2.54cm ，等于 72pt
// - 左部和右部为 3.18cm ，等于 90pt
#let page-style(doc) = {
  set page(
    paper: "a4",
    margin: (
      top: 72pt,
      bottom: 72pt,
      left: 90pt,
      right: 90pt,
    ),
  )
  doc
}
