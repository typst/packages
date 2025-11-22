#import "/src/lib.typ": *
#set page(width: 15cm, height: auto)


= Issue #link("https://github.com/Jollywatt/typst-wordometer/issues/1", `#1`)

Figures might have:
- no `caption` field, or
- a `caption` field with the value `none`.

#let el = rect[
	#figure([Hello from the figure body.], caption: none)
	Ciao.
]

#el
#word-count-of(el)