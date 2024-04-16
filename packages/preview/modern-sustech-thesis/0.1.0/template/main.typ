// Construct the sections as aranged.
#import "./configs/cover.typ": cover
#import "./configs/commitment.typ": commitment
#import "./configs/abstract.typ": abstract
#import "./configs/outline.typ": toc
#import "./sections/info.typ": isCN

#let main(isCN: true) = {
  // 中英文封面页 Cover
  cover(isCN: isCN)
  commitment(isCN: isCN)

  // 设定目录编号格式
  set heading(numbering: "1.1.1.")
  // 设定非正文部分页码
  set page(numbering: "I")
  counter(page).update(1)

  // 插入摘要页
  abstract(isCN: isCN)
  // 插入目录页
  toc(isCN: isCN)

  // 设定正文部分页码
  set page(numbering: "1")
  counter(page).update(1)

  include "configs/bodystyle.typ"
}

#main(isCN: isCN)