// ============================================================
// outline.typ — 中文目录
// 提供 chineseoutline，支持中文章节编号与缩进
// 图/表/代码列表见 listoffigures.typ
// ============================================================

#import "headings.typ": front-heading
#import "utils.typ": appendixcounter, chaptercounter, chinesenumbering, partcounter

/// 中文目录
/// title: 目录标题（默认"目录"）
/// depth: 目录深度（默认 none 表示全部）
/// indent: 是否按标题等级缩进
#let chineseoutline(title: "目录", depth: none, indent: false) = {
  front-heading(title)

  set par(
    first-line-indent: 0em,
    leading: 10.5pt,
    spacing: 10.5pt,
    justify: true,
  )

  show outline.entry: it => context {
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
      h(1em)
    }

    if indent {
      h(1em * (el.level - 1))
    }

    if el.level == 1 {
      v(6pt)
    }

    if maybe_number != none {
      link(el_loc, if el.level == 1 {
        strong(maybe_number)
      } else {
        maybe_number
      })
    }

    link(el_loc, if el.level == 1 {
      strong(el.body)
    } else {
      el.body
    })

    box(width: 1fr, [#h(2pt) #box(width: 1fr, repeat[.]) #h(2pt)])

    let heading_counter = counter(heading).at(el_loc)
    let is-appendix = appendixcounter.at(el_loc).first() >= 10
    let is-first-body-chapter = (
      el.level == 1
        and el.numbering != none
        and heading_counter == (1,)
        and not is-appendix
    )

    link(el_loc, if is-first-body-chapter {
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
