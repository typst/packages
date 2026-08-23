#import "../consts.typ": *
#import "../tools/term.typ": *

#let 缩略词表等注释表(info: (:)) = [
  // #pagebreak()
  // #set align(center)
  // #set heading(supplement: "术语表", numbering: none, outlined: false)
  // = 术语表

  // #set align(left)
  // #print-glossary()

  // #pagebreak(weak: true)
  // #if info.at(info-keys.论文模式) == 论文模式.打印模式 {
  //   pagebreak(weak: true, to: "odd")
  // }
]
