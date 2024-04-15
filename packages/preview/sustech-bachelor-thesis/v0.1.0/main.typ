// Construct the sections as aranged.
#import "@preview/sustech-bachelor-thesis:0.1.0": *
#import "./sections/cover.typ": make-cover
#import "./sections/commitment.typ": make-commitment

// 中英文封面页 Cover
#make-cover(isCN: true)
#make-cover(isCN: false)

// 中英文承诺书页
#make-commitment(isCN: true)
#make-commitment(isCN: false)

// 设定目录编号格式
#set heading(numbering: "1.1.1.")
// 设定非正文部分页码
#set page(numbering: "I")
#counter(page).update(1)

// 插入摘要页
#include "./sections/abstract.typ"

// 插入目录页
#include "./sections/outline.typ"

// 设定正文部分页码
#set page(numbering: "1")
#counter(page).update(1)

// 文章主体（含参考文献）
#include "./sections/body.typ"


