#import "../utils/style.typ": ziti, zihao
#import "@preview/i-figured:0.2.4"

#let outline-page(
  doctype: "master",
  twoside: false,
  info: (:),
) = {
  show text.where(lang: "en"): set text(stretch: if doctype == "bachelor" { 80% } else { 100% })

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
    if doctype == "bachelor" and it.element.supplement == [附录] {
      it.indented(
        none,
        [
          #it.element.body.text
          #h(-0.5em)
          （
          #it.prefix()
          #h(-0.3em)
          ）
          #h(-0.3em)
          #box(width: 1fr, repeat(".", gap: 0.15em)) // styling
          #it.page()
        ],
      )
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
