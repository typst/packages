// 利用 state 捕获摘要参数，并通过 context 传递给渲染函数
#import "/utils/style.typ": 字号, 字体

#let abstract-keywords = state("keywords", ("中山大学", "论文", "学位论文", "规范"))
#let abstract-content = state("abstract", [
摘要应概括论文的主要信息，应具有独立性和自含性，即不阅读论文的全文，就能获得必要的信息。
摘要内容一般应包括研究目的、内容、方法、成果和结论，要突出论文的创造性成果或新见解，不要
与绪论相混淆。语言力求精练、准确，以300-500字为宜。关键词是供检索用的主题词条，应体现论
文特色，具有语义性，在论文中有明确的出处，并应尽量采用《汉语主题词表》或各专业主题词表提
供的规范词。关键词与摘要应在同一页，在摘要的下方另起一行注明，一般列3-5个，按词条的外延
层次排列（外延大的排在前面）。
])
#let abstract(
  keywords: (),
  body,
) = {
  context abstract-keywords.update(keywords)
  context abstract-content.update(body)
}

// 中文摘要页
#let abstract-page() = {
  // 中文摘要内容 宋体小四号
  set text(font: 字体.宋体, size: 字号.小四)

  // 中文摘要标题 黑体三号居中
  show heading.where(level: 1): set text(font: 字体.黑体, size: 字号.三号)

  // 摘要标题不编号
  show heading.where(level: 1): set heading(numbering: none)

  [
    = 摘要

    #set par(first-line-indent: (amount: 2em, all: true))
    #context abstract-content.final()

    #v(1em)

    // 摘要正文下方另起一行顶格打印“关键词”款项，后加冒号，多个关键词以逗号分隔。
    // （标题“关键词”加粗）
    #set par(first-line-indent: 0em)
    *关键词：*#context abstract-keywords.final().join("，")
  ]
}
