#import "../utils/style.typ": 字体, 字号

#let achievement-page(
  doctype: "master",
  twoside: false,
  papers: (),
  patents: (),
  monographs: (),
  research-reports: (),
  other-achievements: (),
  ..args,
) = {
  set heading(numbering: none)
  //仅显示一级标题在目录中
  set heading(outlined: false)
  show heading.where(level: 1): set heading(outlined: true)
  set par(first-line-indent: (amount:0em,all: true), spacing: 1em ,leading:1em)
  let bibitem(body) = figure(kind: "bibitem", supplement: none, body,)
  show figure.where(kind: "bibitem"): it => {
    set align(left)
    set text(size: 字号.五号)
    box(width: 2em, it.counter.display("[1]"))
    it.body
  }
  show ref: it => {
    let e = it.element
    if e.func() == figure and e.kind == "bibitem" {
      let loc = e.location()
      return link(loc, numbering("[1]", ..e.counter.at(loc)))
    }
    it
  }
  show list: set text(size:字号.小四,font: 字体.黑体, weight: "bold", top-edge: 0.7em, bottom-edge: -0.3em)
  show figure: set par(spacing: 1em,leading: 1em)
  set text(size: 字号.五号)
  if doctype == "master"{
    heading(level: 1)[攻读硕士学位期间的科研成果]
  }else{
    heading(level: 1)[攻读博士学位期间的科研成果]
  }

  if (papers.len() == 0 or papers.at(0) == "") and (monographs.len() == 0 or monographs.at(0) == "") and (patents.len() == 0 or patents.at(0) == "") and (research-reports.len() == 0 or research-reports.at(0) == "") and (other-achievements.len() == 0 or other-achievements.at(0) == "") {
    [无]
  }

  if papers.len() != 0 and papers.at(0) != "" {
    list[学术论文]
    for paper in papers {
      bibitem(paper)
    }
  }else{
    // list[学术论文]
    // "无"
  }

  if monographs.len() != 0 and monographs.at(0) != "" {
    list[专著/译注]
    for monograph in monographs {
      bibitem(monograph)
    }
  }else{
    // list[专著/译注]
    // "无"
  }
  
  if patents.len() != 0 and patents.at(0) != "" {
    list[专利]
    for patent in patents {
      bibitem(patent)
    }
  }else{
    // list[专利]
    // "无"
  }


  if research-reports.len() != 0 and research-reports.at(0) != "" {
    list[研究报告]
    for research-report in research-reports {
      bibitem(research-report)
    }
  }else{
    // list[研究报告]
    // "无"
  }

  if other-achievements.len() != 0 and other-achievements.at(0) != "" {
    list[其他研究成果]
    for other-achievement in other-achievements {
      bibitem(other-achievement)
    }
  }else{
    // list[其他研究成果]
    // "无"
  }

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}