#import "../utils/style.typ": zihao, ziti
#import "@preview/i-figured:0.2.4"

#let outline-page(
  doctype: "bachelor",
  twoside: false,
) = {
  pagebreak()
  set text(font: ziti.songti, size: zihao.sihao)
  set par(first-line-indent: 0em, leading: 20pt)

  show heading.where(level: 1): it => {
    set text(font: ziti.songti, weight: "bold", size: zihao.xiaoer)
    set align(center)
    set par(first-line-indent: 0em, justify: false, leading: 20pt)
    v(40pt)
    it.body
    v(20pt)
  }

  heading(level: 1, outlined: false)[目#h(2em)录]

  context {
    show outline.entry.where(level: 1): set text(font: ziti.songti, weight: "bold", size: zihao.sihao)
    show outline.entry.where(level: 2): set text(font: ziti.songti, size: zihao.xiaosi)

    show outline.entry.where(level: 1): set block(above: 1.75em, below: 1.5em)
    show outline.entry.where(level: 2): set block(above: 1.25em)

    show outline.entry.where(level: 1): it => {
      let prefix = it.prefix()
      let numbered = it.element.numbering != none and prefix != none
      let leader = box(width: 1fr, repeat(".", gap: 0.15em))
      let entry = if numbered {
        // 判断是否为附录
        if it.element.supplement == [附录] {
          it.indented(
            [附录#h(0.5em)#prefix#h(1em)],
            [#it.element.body#h(-0.3em)#leader#it.page()],
          )
        } else {
          it.indented(
            [第#prefix#text("章")#h(1em)],
            [#it.element.body#h(-0.3em)#leader#it.page()],
          )
        }
      } else {
        it.indented(none, [#it.element.body#h(-0.3em)#leader#it.page()])
      }
      let loc = it.element.location()
      if loc == none { entry } else { link(loc, entry) }
    }
    show outline.entry.where(level: 2): it => {
      let prefix = it.prefix()
      let numbered = it.element.numbering != none and prefix != none
      let leader = box(width: 1fr, repeat(".", gap: 0.15em))
      let entry = if numbered {
        it.indented([
          #prefix#h(1em)
        ], [#it.element.body#h(-0.3em)#leader#it.page()])
      } else {
        it.indented(none, [#it.element.body#h(-0.3em)#leader#it.page()])
      }
      let loc = it.element.location()
      if loc == none { entry } else { link(loc, entry) }
    }

    outline(
      title: none,
      target: selector(heading).after(here()),
      indent: 2em,
      depth: 2,
    )
  }
}

#let image-outline-page(
  twoside: false,
) = {
  pagebreak()
  set heading(outlined: false)
  i-figured.outline(target-kind: "image", title: [插#h(1em)图])
}

#let table-outline-page(
  twoside: false,
) = {
  pagebreak()
  set heading(outlined: false)
  i-figured.outline(target-kind: "table", title: [表#h(1em)格])
}

#let algorithm-outline-page(
  twoside: false,
) = {
  pagebreak()
  set heading(outlined: false)
  i-figured.outline(target-kind: "algorithm", title: [算#h(1em)法])
}
