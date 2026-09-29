// ============================================================
// listoffigures.typ — 图/表/代码的列表
// 提供统一的图表列表生成函数 listoffigures
// ============================================================

#import "headings.typ": front-heading
#import "const.typ": supplement
#import "utils.typ": chaptercounter, chinesenumbering

/// 从 figure caption 中提取纯文本，用于图表列表条目。
#let caption-to-text(a) = {
  if type(a) == str {
    a.trim()
  } else if type(a) == content {
    if a.has("body") {
      caption-to-text(a.body)
    } else if a.has("children") {
      let found = a.children.find(it => it.has("text") and it.text.len() > 0)
      if found != none { found } else { a }
    } else {
      a
    }
  } else {
    a
  }
}

/// 图/表/代码列表
/// title: 列表标题
/// kind: image / table / "code"
/// supplements: 引用记号字典（用于前缀标签）。
#let listoffigures(title: "插图", kind: image, supplements: supplement) = {
  front-heading(title)

  show outline.entry: it => context {
    let el = it.element
    let el_loc = el.location()

    let prefix = if kind == image {
      supplements.图
    } else if kind == table {
      supplements.表
    } else if kind == "code" {
      supplements.代码
    } else { "" }
    let maybe_number = {
      prefix
      chinesenumbering(
        chaptercounter.at(el_loc).first(),
        counter(figure.where(kind: kind)).at(el_loc).first(),
        location: el_loc,
      )
      h(0.5em)
    }

    link(el_loc, maybe_number)
    link(el_loc, caption-to-text(el.caption))
    box(width: 1fr, [#h(2pt) #box(width: 1fr, repeat[.]) #h(2pt)])
    link(el_loc, it.page())
    linebreak()
    v(-0.2em)
  }

  outline(title: none, target: figure.where(kind: kind))
}
