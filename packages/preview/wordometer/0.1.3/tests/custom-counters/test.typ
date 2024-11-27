#import "/src/lib.typ": *
#set page(width: 15cm, height: auto)

#let el = [
	Hello there are 10 vowels here.
]

#rect(el)
#word-count-of(el, counter: txt => (vowels: lower(txt).matches(regex("[aeiou]")).len()))
