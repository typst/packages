// ============================================================
// listoffigures.typ — 图/表/代码/公式的列表
// 提供统一的图表列表生成函数 listoffigures
// ============================================================

#import "../layouts/headings.typ": front-heading
#import "../utils/supplement.typ": supplement
#import "../utils/counter.typ": chaptercounter
#import "../utils/number.typ": chinesenumbering

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

/// 图/表/代码/公式列表
/// title: 列表标题
/// kind: image / table / "code" / "equation"
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
    } else if kind == "equation" {
      supplements.公式
    } else if kind == "code" {
      supplements.代码
    } else { "" }

    // 公式用 figure 子计数器，编号带括号；其余同理
    let kind-counter = counter(figure.where(kind: kind))
    let brackets = kind == "equation"

    let maybe_number = {
      prefix
      chinesenumbering(
        chaptercounter.at(el_loc).first(),
        kind-counter.at(el_loc).first(),
        location: el_loc,
        brackets: brackets,
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
