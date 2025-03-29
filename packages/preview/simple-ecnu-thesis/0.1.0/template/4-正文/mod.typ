#import "../lib.typ": *


// -------------------- 内容标题样式定义 --------------------
#let header-style(doc) = {
  // 设置标题编号且放入目录页中
  set heading(
    numbering: numbly(
      "第{1:一}章",
      "{1}.{2}",
      "{1}.{2}.{3}",
    ),
    outlined: true,
  )
  doc
}

// 正文样式
#let style(doc) = {
  // 设置靠左
  set align(left)
  show: header-style
  doc
}
