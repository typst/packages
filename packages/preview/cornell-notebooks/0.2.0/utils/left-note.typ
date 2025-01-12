// 左侧笔记线索函数
// 在页面左侧放置笔记内容
#let left-note(body) = {
  place(
    left,
    dx: -6cm,
    block(
      width: 5.0cm,
      align(right, body)
    )
  )
}