#import "/src/lib.typ": *
#set page(width: 15cm, height: auto)

#word-count(totals => [
	Hello, stats are in! #totals
])

#block(fill: orange.lighten(90%), inset: 1em)[
	#show: word-count

	One two three four. There are #total-words total words and #total-characters characters.

]
