#import "../utils/style.typ": zihao, ziti
#import "@preview/i-figured:0.2.4"

#let outline-page(
  doctype: "master",
  twoside: false,
  info: (:),
) = {
  set text(stretch: if doctype == "bachelor" { 80% } else { 100% })

  show outline.entry.where(level: 1): set text(
    weight: "bold",
    size: if doctype == "bachelor" { zihao.sihao } else { zihao.xiaosi },
  )
  show outline.entry.where(level: 2): set text(size: if doctype == "bachelor" { zihao.xiaosi } else { zihao.xiaosi })
  show outline.entry.where(level: 3): set text(size: if doctype == "bachelor" { zihao.wuhao } else { zihao.xiaosi })
  show outline.entry.where(level: 1): set block(above: 1.75em, below: 1.5em)
  show outline.entry.where(level: 2): set block(above: 1.25em)
  show outline.entry.where(level: 3): set block(above: 1.25em)

  show outline.entry.where(level: 1): it => link(
    it.element.location(),
    if it.element.supplement == [附录] {
      if doctype == "bachelor" {
        it.indented(
          none,
          [
            #it.element.body.text
            #h(-0.5em)
            （
            #h(-0.2em)
            #it.element.supplement
            #it.prefix()
            #h(-0.3em)
            ）
            #h(-0.3em)
            #box(width: 1fr, repeat(".", gap: 0.15em)) // styling
            #it.page()
          ],
        )
      } else {
        it.indented(it.element.supplement + it.prefix(), it.inner())
      }
    } else {
      it.indented(it.prefix(), it.inner())
    },
  )

  context outline(
    title: [目#h(1em)录],
    target: if doctype == "bachelor" {
      selector(heading)
    } else {
      selector(heading).after(here())
    },
    indent: if doctype == "bachelor" { 1.1em } else { 2em },
    depth: 3,
  )

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}

#let image-outline-page(
  twoside: false,
  info: (:),
) = {
  i-figured.outline(target-kind: "image", title: [插#h(1em)图])

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}

#let table-outline-page(
  twoside: false,
  info: (:),
) = {
  i-figured.outline(target-kind: "table", title: [表#h(1em)格])

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}

#let algorithm-outline-page(
  twoside: false,
  info: (:),
) = {
  i-figured.outline(target-kind: "algorithm", title: [算#h(1em)法])

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}
