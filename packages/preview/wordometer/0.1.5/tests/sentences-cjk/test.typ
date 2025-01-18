#import "/src/lib.typ": *
#set page(width: 15cm, height: auto)
#set text(font: "Noto Serif CJK JP", fallback: false)

#let el = [
	滚滚长江东逝水。

	吾輩は猫である。名前はまだない。

	This should be, uhh... *four* sentences.
]

#el
#word-count-of(el)