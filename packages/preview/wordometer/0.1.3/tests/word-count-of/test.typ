#import "/src/lib.typ": *
#set page(width: 15cm, height: auto)

#let el = [
	One two _three_ four *five* six.

	== Seven eight

	#box[Nine #h(1fr) ten eleven $ sqrt(#[don’t mind me]) $ twelve.]

	Thirteen #text(red)[fourteen]
	- #highlight[fifteen]
	- sixteen #box(rotate(-5deg)[seventeen])
	- eighteen!
]

#rect(el)
#word-count-of(el)

#pagebreak()

#let el = [
	#stack(
		dir: ltr,
		spacing: 1fr,
		table(columns: 3, [one], [two], [three #super[four]], [#sub[five] six], [seven]),
		rotate(180deg)[eight],
		circle[nine ten],
		
	)

	#figure(circle(fill: red, [eleven]), caption: [twelve thirteen])
]

#rect(el)
#word-count-of(el)

#pagebreak()

#let el = [
	"One *two*, three!" #text(red)[Four], five.
	#rect[Six, *seven*, eight.]
]

#rect(el)
#word-count-of(el)
