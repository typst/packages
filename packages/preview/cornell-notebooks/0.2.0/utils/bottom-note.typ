// 底部笔记总结函数
// 在页面底部放置笔记总结内容
#let bottom-note(body) = {
  context {
    let page-number = counter(page).at(here()).first()
    place(
      bottom + left,
      dy:5.8cm,
      block(
        height: 5cm,
        width: 125%,
        stroke: (
          top: none,
          left: none,
          bottom: none,
          right: none
        ),
        inset: (left: -6.2cm, right: 1.5cm, rest: 1em),
        {
          // 添加一个空格来创建首行缩进效果
          h(2em)
          body
        }
      )
    )
  }
}