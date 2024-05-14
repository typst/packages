#set document(date: none)


#import "/src/lib.typ": *


#set text(size: 10.5pt, font: ("Source Han Serif SC"), lang: "zh", region: "cn")
#set par(leading: 0.55em, justify: true, first-line-indent: 2em)
#show par: set block(spacing: 0.55em)


#for i in range(36) [
  #box(width: 2em)[(#i)] #h(1em) #rand-sc(i, seed: 2*i) \
]
#pagebreak(weak: true)


#for i in range(1, 18) [
  #if i == 1 [#h(2em)]
  #rand-sc(25*i, seed: i, punctuation: true, gap: 2+i)
  #parbreak()
]
#pagebreak(weak: true)
