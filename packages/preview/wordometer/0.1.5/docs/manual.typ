#import "@preview/tidy:0.4.3"
#import "/src/exports.typ" as wordometer

#set page(numbering: "1")
#set par(justify: true)
#show link: underline.with(stroke: blue.lighten(50%))
#set table(stroke: none, gutter: 2em, inset: 0pt)
#show heading: it => v(2em, weak: true) + it

#let VERSION = toml("/typst.toml").package.version

#let scope = {
	(wordometer: wordometer)
	dictionary(wordometer)
} 

#let show-module(path) = {
	show heading.where(level: 3): it => {
		let prefix = {
			if it.body.text in dictionary(wordometer) { "" }
			else { "utils." }
		}
		align(center, line(length: 100%, stroke: black.lighten(70%)))
		block(text(1.3em, raw(prefix + it.body.text + "()")))
	}
	tidy.show-module(
		tidy.parse-module(
			read(path),
			scope: scope,
			label-prefix: "",
		),
		show-outline: false,
		sort-functions: x => {
			str(int(not x.name.starts-with("word-count"))) + x.name
		},
		style: tidy.styles.default,
	)
}

#show: wordometer.word-count



#v(.2fr)

#align(center)[
	#stack(
		spacing: 12pt,
		text(2.7em, `wordometer`),
		[_This manual contains #wordometer.total-words words._],
	)

	#v(30pt)

	A small #link("https://typst.app/")[Typst] package for quick and easy in-document word counts.

	#link("https://github.com/Jollywatt/typst-wordometer")[`github.com/Jollywatt/typst-wordometer`]

	Version #VERSION

]

#set raw(lang: "typc")
#show raw.where(block: true): it => pad(y: .2em, block(
	it,
	fill: luma(98%),
	stroke: luma(80%) + .5pt,
	outset: .7em,
	width: 100%,
	radius: .5em,
	breakable: false
))

#v(1fr)

#show "VERSION": VERSION

#[
	#show heading: pad.with(y: 10pt)

	= Basic usage

	```typ
	#import "@preview/wordometer:VERSION": word-count, total-words

	#show: word-count // global word count

	In this document, there are #total-words words all up.

	#word-count(total => [ // scoped word count
	  The number of words in this block is #total.words
	  and there are #total.characters letters.
	])
	```

	You can *exclude elements* by function (e.g., `heading`, `table`, `figure.caption`), by where-selector (e.g., `raw.where(block: true)`), or by label (e.g., `<no-wc>`).


	```typ
	#show: word-count.with(exclude: (heading.where(level: 1), strike))

	= This Heading Doesn't Count
	== But I do!

	In this document #strike[(excluding me)], there are #total-words words all up.

	#word-count(total => [
	  You can exclude elements by label, too.
	  #[That was #total.words, excluding this sentence!] <no-wc>
	], exclude: <no-wc>)
	```
]

#v(1fr)

#pagebreak()

#let fn(name) = {
	let text = wordometer.utils.extract-text(name)
	link(label(text), raw(text))
}


#let example-pair(code) = {
	let result = eval(code.text.replace("#import", "//"), mode: "markup", scope: scope)
	(code, result)
}

#let example(code, size: 50%) = {
	table(
		columns: (size, 1fr),
		..example-pair(code)
	)
}

= Details

The basic *#fn[word-count-of()]* function takes content and returns a dictionary of statistics.
#example(```typ
#import "@preview/wordometer:VERSION": word-count-of
#let it = [Hello world!]
#it
#word-count-of(it)
```, size: 60%)

The more convenient *#fn[word-count()]* function can be used both as a *document show rule*...
#example(```typ
#show: word-count
This is a _global word count_. \
(#total-words words)
```, size: 60%)
...or for *scoped word counts* using a callback:
#example(```typ
#word-count(total => [
	There are #total.words total words.
])
```, size: 60%)


== Including specific sections only

You can use scoped show rules to update the running total:

```typ
This preface is not counted.
#[
	#show: word-count
	One two three four.
]
This is not counted either.
#[
	#show: word-count
	Five six seven.
]
```
The contextual variable ```typ #total-words``` always shows the *final word count* of the content passed to this show rule.
For finer control, you can build off of #fn[word-count-of()].


== Excluding elements

You can exclude elements by adding an `exclude` option to #fn[word-count()] or #fn[word-count-of()], which is one or more _element functions_, _labels_, or _where selectors_.

- Excluding by *element*:
	#table(
		columns: (2fr, 1fr),

		..example-pair(```typ
		#word-count-of(exclude: strong)[One *not* two.].words
		```),
		..example-pair(```typ
		#word-count(exclude: (heading, highlight), total => [
			= Not me
			One two #highlight[me neither] three. \
			#total.words words including this line.
		])
		```),
	)
- #box[Excluding by *label*:
	#table(
		columns: (2fr, 1fr),

		..example-pair(```typ
		#word-count-of(exclude: <not-me>, [
			One #[(not I)] <not-me> two three.
		])
		```),	
		..example-pair(```typ
		#word-count(exclude: <not-me>, total => [
		  One, two, three, four.
		  #[That was #total.words words.] <not-me>
		])

		```),
	)]

- Excluding by *`where` selector*:

	#table(
		columns: (2fr, 1fr),

		..example-pair(````typ
		#word-count-of(exclude: raw.where(lang: "python"))[
			```python
			print("Hello, World!")
			```
			Only I count.
		]
		````),
	)

Figures have a slightly special treatment to exclude the body or caption independently:
```typ
#word-count(.., exclude: figure) // exclude both figure body and figure captions
#word-count(.., exclude: caption) // exclude figure captions but count figure body
#word-count(.., exclude: "figure-body") // exclude figure body but count captions
```

== Custom counters

You can customise the _counting function_ used by #fn[word-count()] or #fn[word-count-of()] function with the `counter` option.
For example, here is how to count just five letter words or the letter "e":

#example(```typ
#let it = [#lorem(5)]
#it\
#word-count-of(it, counter: text => (
	five-letter-words: text
		.matches(regex("\b\w{5}\b")).len(),
	letter-e: text.matches("e").len()
))
```)
The default counting function is defined below:
```typ
#let string-word-count(string) = (
  characters: string.replace(regex("\s+"), "").clusters().len(),
  words: string.matches(regex("[\p{Han}]|\b[[\w--\p{Han}]'’.,\-]+\b")).len(),
  sentences: string.matches(regex("\w+\s*[.?!。？！]")).len(),
)
```

== How it works
The actual word counting works by using #fn[extract-text()] to convert content to a plain string which is split up into words, sentences, and so on. You can specify exactly what is counted via the `counter` argument of most functions.

The #fn[extract-text()] function uses #fn[map-tree()] to traverse a content tree and accumulate the text from each leaf node.
The #fn[map-tree()] function (and most of the other functions) has an `exclude` parameter, which is used to exclude certain elements from the word count.

The following elements have no text content and are always excluded: #wordometer.utils.IGNORED_ELEMENTS.sorted().map(raw).join([, ], last: [, and ]).

== Where this doesn't work

Word counting with #fn[extract-text()] occurs *before show rules are applied*, which means content modified by show rules may get counted differently to how it looks finally.
For example, numberings and supplements in headings or references may not be counted.
Some elements only render their content after we can inspect them, making them impossible to count in this way, including bibliographies and citations.



= Function reference

#show-module("/src/lib.typ")
