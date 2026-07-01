#let doc(
  info: (:),
  fallback: false,
  lang: "zh",
  margin: (
      top: 3.3cm,
      bottom: 2.3cm,
      left: 2.8cm,
      right: 2.3cm,
  ),
  it,
) = {

  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  set text(fallback: fallback, lang: lang)
  set page(margin: margin)
  set document(
    title: (("",) + info.title).sum(),
    author: info.author,
  )
  it
}