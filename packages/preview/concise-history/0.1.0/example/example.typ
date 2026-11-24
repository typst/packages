#import "@preview/concise-history:0.1.0"： *

// 基本信息
#show: concise-history-book.with(
  title: "标题",
  subtitle: "副标题",
  author: "作者",
  date: datetime.today(),
  edition: "一",
  publisher: "出版社",
  dedication: [献词部分。],
  cfg: concise-history-a5,
)

= 前言

这是前言

= 一级标题

== 二级标题

#heading(depth: 3, [三级行内标题]) 这是正文。#着重号[着重号效果预览]。*强调效果（中文黑体）Strong Emphasis（西文加粗）预览*。

#pagebreak()

偶数页显示节名。

#pagebreak()

奇数页显示章名。

= 后记

这是后记。
