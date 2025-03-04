#import "../utils/style.typ": ziti, zihao
#import "../utils/header.typ": no-numbering-page-header
#import "../utils/heading.typ": no-numbering-first-heading

#let achievement-page(
  doctype: "master",
  twoside: false,
  papers: (),
  patents: (),
) = {
  show: no-numbering-page-header.with(
    doctype: doctype,
    twoside: twoside,
  )
  show: no-numbering-first-heading

  let bibitem(body) = figure(kind: "bibitem", supplement: none, body)
  show figure.where(kind: "bibitem"): it => {
    set align(left)
    set text(size: zihao.wuhao)
    box(width: 2em, it.counter.display("[1]"))
    it.body
    parbreak()
  }
  show ref: it => {
    let e = it.element
    if e.func() == figure and e.kind == "bibitem" {
      let loc = e.location()
      return link(loc, numbering("[1]", ..e.counter.at(loc)))
    }
    it
  }
  show list: set text(font: ziti.heiti, weight: "bold")

  heading(level: 1)[学术论文和科研成果目录]

  if papers.len() != 0 {
    list[学术论文]
    for paper in papers {
      bibitem(paper)
    }
  }

  if patents.len() != 0 {
    list[专利]
    for patent in patents {
      bibitem(patent)
    }
  }

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}