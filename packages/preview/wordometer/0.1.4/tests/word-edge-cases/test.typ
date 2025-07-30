#import "/src/lib.typ": *
#set page(width: 15cm, height: auto)

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
