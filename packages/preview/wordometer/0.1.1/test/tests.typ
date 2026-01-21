#import "/src/lib.typ": *
#set page(width: 15cm, height: auto)

#show heading.where(level: 1): it => pagebreak(weak: true) + it + v(1em)

= Basics

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

= More basics

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
#map-tree(x => x, el)

= Punctuation

#let el = [
	"One *two*, three!" #text(red)[Four], five.
	#rect[Six, *seven*, eight.]
]

#rect(el)

Raw tree: #map-tree(x => x, el)

Stats: #word-count-of(el)

= Word edge cases

#let f(el) = {
	let s = word-count-of(el)
	highlight(el) + [ [Words: #s.words]]
}
#f[One two three]
#f[Acronyms count as O.N.E. word!]
#f[Hyphen-words] are one, but #f[En–Dash] are two.
#f[Punctuation doesn't count !?] #f[Qu'est-ce que c'est ?]
#f[The amount is \$4,599.99!]
#f[One (or so).]

= Scoped counts

#word-count-callback(stats => box(stroke: blue, inset: 1em)[
	Guess what, this box contains #stats.words words!

	Full statistics: #stats
])

#rect[
	#show: word-count

	One two three four. There are #total-words total words and #total-characters characters.

]


= Master function

#word-count(totals => [
	Hello, stats are in! #totals
])

#block(fill: orange.lighten(90%), inset: 1em)[
	#show: word-count

	One two three four. There are #total-words total words and #total-characters characters.

]

= Sentences

#let el = [
	Pour quoi ? Qu'est-ce que c'est !?

	"I don't know anything."

]

#el
#word-count-of(el)

= Excluding elements by type

#word-count(total => [
	== Not me.
	One, two, three. #strike[Not me, either.] Four.

	#strike[Words: #total.words]
], exclude: (heading, strike))

= Excluding elements by label

#word-count(total => [
	=== One two
	Three, four.

	=== Not me! <no-wc>
	Five, six.

	#total
], exclude: (raw, <no-wc>))

#line(length: 100%)

#word-count(total => [
  One, two, three, four.
  #[That was #total.words, not counting this sentence!] <no-wc>
], exclude: <no-wc>)


= Where-selectors


#let el = [
	
	== One
	=== Not me!
	==== Two three four five

]
#el

#word-count-of(el, exclude: heading.where(level: 3)))

= Custom counters

#let el = [
	Hello there are vowels here.
]
#el

#word-count-of(el, counter: txt => (vowels: lower(txt).matches(regex("[aeiou]")).len()))

= Raw text extraction

#let el = [
	Hello, _this_ is a bunch of `content`. \ New line.

	== What we have

	- This and that
	- etcetera

	#text(red)[what we *need*]

	#circle[love]
]


#el
#extract-text(el)

= Issue `#1`

Figures might have:
- no `caption` field, or
- a `caption` field with the value `none`.

#let el = rect[
	#figure([Hello from the figure body.], caption: none)
	Ciao.
]
#el

#word-count-of(el)