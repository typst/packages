#import "fonts.typ": *

#let heading-setup() = {
  // 章标题 - 宋体三号（16pt）, 居中
  show heading.where(level: 1): it => {
    v(12pt, weak: true)
    set par(first-line-indent: 0em)
    align(center)[
      #text(size: 16pt, weight: "bold", font: fonts.song)[
        #if it.numbering != none {
          [第#counter(heading).display()章#h(1em)]
        }
        #it.body
      ]
    ]
    v(12pt)
  }
  
  // 节标题 - 宋体四号（14pt）, 居左
  show heading.where(level: 2): it => {
    v(12pt, weak: true)
    set par(first-line-indent: 0em)
    align(left)[
      #text(size: 14pt, weight: "bold", font: fonts.song)[
        #counter(heading).display()#h(1em)#it.body
      ]
    ]
    v(6pt)
  }
  
  // 小节标题 - 宋体小四号（12pt）, 居左
  show heading.where(level: 3): it => {
    v(12pt, weak: true)
    set par(first-line-indent: 0em)
    align(left)[
      #text(size: 12pt, weight: "bold", font: fonts.song)[
        #counter(heading).display()#h(1em)#it.body
      ]
    ]
    v(6pt)
  }
  
  // 小小节标题
  show heading.where(level: 4): it => {
    v(6pt, weak: true)
    set par(first-line-indent: 0em)
    align(left)[
      #text(size: 12pt, font: fonts.song)[
        #counter(heading).display()#h(1em)#it.body
      ]
    ]
  }
}