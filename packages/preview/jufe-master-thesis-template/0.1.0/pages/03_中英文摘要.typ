#import "@preview/cuti:0.4.0": show-cn-fakebold
#import "@preview/pointless-size:0.1.1": zh
#import "@preview/kouhu:0.2.0": kouhu
#let calc-headings(headings) = {
  let max-page-num = calc.max(..headings.map(i => i.location().page()))
  let first-headings = (none,) * max-page-num
  let last-heading = context query(heading.where(level: 1).before(here())).at(-1).body
  let target-headings = (none,) * counter(page).final().at(0)
  //! 该循环排除了一页出现两个一级标题的情况
  for h in headings {
    if first-headings.at(h.location().page() - 1) == none {
      first-headings.at(h.location().page() - 1) = h.body
    }
  }
  for i in range(target-headings.len()) {
    target-headings.at(i) = {
      if i + 1 <= first-headings.len() and first-headings.at(i) != none {
        first-headings.at(i)
      } else {
        last-heading
      }
    }
  }
  target-headings
}
#let paper-title = "论文标题"
#set page(
  margin: (
    top: 3.5cm,
    bottom: 2.5cm,
    left: 2.5cm,
    right: 2.5cm,
  ),
  header-ascent: 0.5cm,
  header: context [
    #set text(font: ("Times New Roman", "SimSun"), size: zh(5))
    #set align(center + bottom)
    #let is-odd = calc.odd(here().page())
    #let head-text = if is-odd {
      paper-title
    } else {
      calc-headings(query(heading.where(level: 1))).at(here().page() - 1)
    }
    #head-text
    #v(-6pt)
    #line(length: 100%, stroke: 0.5pt)
  ],
  footer-descent: 0.5em,
  footer: context [
    #set text(font: "Times New Roman", size: zh(-5))
    #set align(center + top)
    #counter(page).display("I")
  ],
)
#show heading: set text(weight: "regular")
#show heading: set block(above: 0pt, below: 0pt)
#show heading.where(level: 1): it => {
  set align(center)
  set text(
    font: ("Times New Roman", "SimHei"),
    size: zh(-3),
    top-edge: 1.5em,
  )
  it
  v(2em)
}
#set par(
  justify: true,
  first-line-indent: (amount: 2em, all: true),
  leading: 1em,
  spacing: 1em,
)
#set text(font: ("Times New Roman", "SimSun"), size: zh(-4))
// #counter(page).update(1)

//! 中文摘要
= 摘#h(2em)要

#kouhu(indices: 1, length: 20)
#lorem(10)
#kouhu(indices: 2, length: 10)

#text(fill: red)[摘要内容和关键词之间空一行]

#v(1em)

#text(font: "SimHei", size: zh(-4))[关键词：]
#text(font: ("Times New Roman", "FangSong"), size: zh(-4))[关键词1；关键词2；关键词3；关键词4]
#pagebreak()

//! 英文摘要

#heading(outlined: false)[Abstract]

#lorem(20)

#v(1em)

*Key Words:* keyword1; keyword2; keyword3; keyword4
