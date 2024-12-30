#import "/src/lib.typ": *
#set page(width: 15cm, height: auto)

#let el = [
	Hello, _this_ is a bunch of `content`. \ New line.

	== What we have

	- This and that
	- etcetera

	#text(red)[what we *need*]

	#circle[love]
]

#rect(el)
#raw(extract-text(el))
