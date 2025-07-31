#import "/src/lib.typ": *
#set page(width: 15cm, height: auto)

= Excluding elements by type

#word-count(total => [
	== Not me.
	One, two, three. #strike[Not me, either.] Four.

	#strike[Words: #total.words]
], exclude: (heading, strike))

#pagebreak()

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


#line(length: 100%)


#let el = [
	One two three four.
	#[But not me] <not-me>
]

#rect(el)
#word-count-of(exclude: <not-me>, el).words