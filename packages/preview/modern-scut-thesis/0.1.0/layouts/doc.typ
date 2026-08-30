// 全局页面设置（边距、语言、PDF 元信息）
#let doc(
  info: (:),
  blind: "none",
  fallback: false,
  lang: "zh",
  margin: (x: 25mm, y: 25mm),
  it,
) = {
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  set text(fallback: fallback, lang: lang)
  set page(margin: margin)

  let metadata = if blind == "double" { (:) } else { (author: info.author) }
  set document(
    title: (("",)+ info.title).sum(),
    ..metadata,
  )

  // 修复 cite 多引用时的连接符
  show cite: it => {
    show "–": "-"
    it
  }

  it
}
