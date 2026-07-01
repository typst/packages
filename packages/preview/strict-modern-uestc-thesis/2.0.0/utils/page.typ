#import "info.typ": *
#import "font.typ": *

#let footer-罗马数字页码 = context {
  set align(center)
  set text(size: font-size.小五)
  counter(page).display("I")
}
#let footer-阿拉伯数字页码 = context {
  set align(center)
  set text(size: font-size.小五)
  counter(page).display("1")
}

#let header-help-func(str) = context {
  set align(center + bottom)
  set text(size: font-size.五号)
  set par(spacing: 0.2em, leading: 0.3em)
  // block(inset: 0pt, height: 90%, stroke: red)[
  block(inset: 0pt, height: 90%)[
    #text(str)
    #line(length: 100%, stroke: 0.75pt)
  ]
  // 在Typst中默认footnote编号是连续的, 也就是第一页如果有1 2 3, 那么第二页就会从4开始
  // 学校要求每一页单独计数, 所以这里需要手动重置一下footnote编号
  counter(footnote).update(0)
}

#let header-with-text(s) = context {
  assert(type(s) == str)
  header-help-func(s)
}

#let header-中文摘要 = header-with-text("摘 要")

#let header-英文摘要 = header-with-text("ABSTRACT")

#let header-目录 = header-with-text("目 录")

#let header-图目录 = header-with-text("插图清单")

#let header-表目录 = header-with-text("表格清单")

#let header-正文 = context {
  let txt = "电子科技大学" + query(<学位>).first().value + "学位论文"
  let body-page = counter(page).get().at(0, default: 0)
  // 奇数页为内容
  if calc.odd(body-page) {
    // txt = hydra(1, skip-starting: false, use-last: true)
    let is-heading-1-page = false
    let h = query(heading.where(level: 1).after(here()))
      .filter(h => { h.location().page() == here().page() })
      .at(0, default: none)
    if h != none {
      is-heading-1-page = true
    } else {
      h = query(heading.where(level: 1).before(here())).at(-1, default: none)
    }
    if h != none {
      let cnt = counter(heading).at(here()).at(0, default: 1)
      if is-heading-1-page {
        cnt = cnt + 1
      }

      let num = if h.numbering != none {
        h.numbering
      } else {
        none
      }

      let title-body = h.body
      if num == none {
        txt = title-body
      } else {
        txt = numbering(num, cnt) + " " + title-body
      }
    }
  }
  header-help-func(txt)
}

#let header-致谢 = header-with-text("致 谢")

#let set-global-page(body) = {
  set page(
    paper: "a4",
    header: none,
    footer: none,
    margin: (top: 3cm, right: 3cm, bottom: 3cm, left: 3cm),
    header-ascent: 1cm - font-size.小五 - 4.5pt,
    footer-descent: 1cm - font-size.小五,
  )
  body
}

#let set-中文摘要-page(body) = {
  set page(header: header-中文摘要, footer: footer-罗马数字页码)
  body
}

#let set-英文摘要-page(body) = {
  set page(header: header-英文摘要, footer: footer-罗马数字页码)
  body
}

#let set-目录-page(body) = {
  set page(header: header-目录, footer: footer-罗马数字页码)
  body
}

#let set-图目录-page(body) = {
  set page(header: header-图目录, footer: footer-罗马数字页码)
  body
}

#let set-表目录-page(body) = {
  set page(header: header-表目录, footer: footer-罗马数字页码)
  body
}

#let set-正文-page(body) = {
  set page(header: header-正文, footer: footer-阿拉伯数字页码)
  body
}

#let set-致谢-page(body) = {
  set page(header: header-致谢, footer: footer-阿拉伯数字页码)
  body
}

#let set-附录-page(body) = set-正文-page(body)

#let set-参考文献-page(body) = set-正文-page(body)

#let set-攻读学位期间获取成果-page(body) = set-正文-page(body)
