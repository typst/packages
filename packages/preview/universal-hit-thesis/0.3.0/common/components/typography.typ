#import "../theme/type.typ": 字体, 字号
#import "@preview/numbly:0.1.0": numbly

#let indent = h(2em)

// 假段落，附着于 heading 之后可以实现首行缩进
#let empty-par = par[#box()]
#let fake-par = context empty-par + v(-measure(empty-par + empty-par).height)


#let heading-block-unit-multiplier = 2.25

#let heading-level-1-style(
  it,
  above: 1.4em,
  below: 1.7em,
  ) = {
  set align(center)
  set text(font: 字体.黑体, size: 字号.小二, weight: "regular")
  set block(below: below, inset: (top: above))
  it
}

#let heading-level-1(
  it,
  below: auto,
  above: auto,
  ) = {
  // [#below]
  show: heading-level-1-style.with(below: below, above: above)
  pagebreak(weak: true)
  it
}

#let array-at = (arr, index) => {
  arr.at(calc.min(index, arr.len()) - 1)
}

#let use-heading-preface(
  content,
  heading-above: (1.4em, ),
  heading-below: (1.7em, ),
  ) = {

  show heading.where(level: 1): heading-level-1.with(above: array-at(heading-above, 1), below: array-at(heading-below, 1))

  content
}

#let use-heading-main(
  content,
  heading-above: (1.4em, 1.5em, 1.56em, 0.95em, ),
  heading-below: (1.7em, 1.51em, 1.58em, 0.94em, ),
  ) = {

  set heading(numbering: numbly(
    "第 {1:1} 章   ",
    "{1}.{2}   ",
    "{1}.{2}.{3}   ",
    "{1}.{2}.{3}.{4}   ",
    "{1}.{2}.{3}.{4}.{5}   ",
  ))

  show heading.where(level: 1): heading-level-1.with(above: array-at(heading-above, 1), below: array-at(heading-below, 1))
  show heading.where(level: 2): it => {
    set text(font: 字体.黑体, size: 字号.小三, weight: "regular")
    set block(above: array-at(heading-above, 2), below: array-at(heading-below, 2))
    it
  }
  show heading.where(level: 3): it => {
    set text(font: 字体.黑体, size: 字号.四号, weight: "regular")
    set block(above: array-at(heading-above, 3), below: array-at(heading-below, 3))
    it
  }
  show heading: it => {
      if it.level > 3 {
        set text(font: 字体.黑体, size: 字号.小四, weight: "regular")
        set block(above: array-at(heading-above, it.level), below: array-at(heading-below, it.level))
        it
      } else {
        it
      }
  }
  content
}

#let use-heading-end(
  content,
  heading-above: (1.4em, ),
  heading-below: (1.7em, ),
  ) = {

  show heading.where(level: 1): heading-level-1.with(above: array-at(heading-above, 1), below: array-at(heading-below, 1))

  content
}