/// 文稿设置
/// 用于设置 PDF 的全局选项以及元数据
#let doc(
  /// 论文与作者信息，通过 @@thesis() 传入
  info: (:),
  /// 字体设置
  /// 是否在字体缺失时使用 fallback，以防显示豆腐块
  fallback: false,
  /// 论文语言设置
  lang: "zh",
  /// 页面边距设置
  margin: (top: 2cm, bottom: 2cm, left: 2.5cm, right: 2.5cm),
  it,
) = {
  info = (
    (
      title: "基于 Typst 的东北师范大学学位论文模板",
      author: "张三",
    )
      + info
  )

  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  set text(fallback: fallback, lang: lang)
  set page(paper: "a4", margin: margin)

  set document(
    title: (("",) + info.title).sum(),
    author: info.author,
  )

  it
}
