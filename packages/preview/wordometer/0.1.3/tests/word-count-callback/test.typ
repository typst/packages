#import "/src/lib.typ": *
#set page(width: 15cm, height: auto)

#word-count-callback(stats => box(stroke: blue, inset: 1em)[
	Guess what, this box contains #stats.words words!

	Full statistics: #stats
])

#rect[
	#show: word-count

	One two three four. There are #total-words total words and #total-characters characters.

]