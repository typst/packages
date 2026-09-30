// ============================================================
// outline.typ — 中文目录
// 提供 chineseoutline，支持中文章节编号与缩进
// 图/表/代码列表见 listoffigures.typ
// ============================================================

#import "../layouts/headings.typ": front-heading
#import "../utils/counter.typ": partcounter
#import "../utils/number.typ": chinesenumbering

/// 中文目录
/// title: 目录标题（默认"目录"）
/// depth: 目录深度（默认 none 表示全部）
/// indent: 是否按标题等级缩进
#let chineseoutline(title: "目录", depth: none, indent: false, style: none) = {
  front-heading(title)

  set par(
    first-line-indent: 0em,
    leading: style.目录其他.leading,
    spacing: style.目录其他.leading,
    justify: true,
  )

  show outline.entry: it => context {
    let s = style
    let el = it.element
    let el_loc = el.location()

    // 跳过前置部分（part < 2）的无编号 heading
    if partcounter.at(el_loc).first() < 2 and el.numbering == none {
      return
    }

    let maybe_number = if el.numbering != none {
      if el.numbering == chinesenumbering {
        chinesenumbering(
          ..counter(heading).at(el_loc),
          location: el_loc,
        )
      } else {
        numbering(el.numbering, ..counter(heading).at(el_loc))
      }
      h(style.目录其他.编号间距)
    }

    if indent {
      h(style.目录其他.缩进量 * (el.level - 1))
    }

    if el.level == 1 {
      v(style.目录章标题.spacing-before)
    }

    if maybe_number != none {
      link(el_loc, if el.level == 1 {
        text(font: s.目录章标题.font, size: s.目录章标题.size, weight: s.目录章标题.weight, maybe_number)
      } else {
        maybe_number
      })
    }

    link(el_loc, if el.level == 1 {
      text(font: s.目录章标题.font, size: s.目录章标题.size, weight: s.目录章标题.weight, el.body)
    } else {
      el.body
    })

    box(width: 1fr, [#h(2pt) #box(width: 1fr, repeat[.]) #h(2pt)])

    // 目录页码显示逻辑页计数（it.page()）。但正文第一个编号标题会在 show rule 中
    // 触发页码重置，而标题的 location() 位于该重置之前，it.page() 取到的是重置前的
    // 物理页。此重置与 part 1 → 2 的转换同步发生，故此处按同一规则（编号标题且
    // part < 2）识别该标题，并显示重置后的逻辑页码 1。
    // 注意：若修改 headings.typ 中 heading-show-rule 的重置条件，需同步此判断。
    let is-page-reset-chapter = (
      el.numbering != none
        and partcounter.at(el_loc).first() < 2
    )

    link(el_loc, if is-page-reset-chapter {
      "1"
    } else {
      it.page()
    })

    linebreak()
  }

  outline(
    title: none,
    target: heading.where(outlined: true),
    depth: depth
  )
}
