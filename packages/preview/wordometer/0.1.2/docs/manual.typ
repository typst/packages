#import "@preview/tidy:0.1.0"
#import "/src/lib.typ" as wordometer: *

#set page(numbering: "1")
#set par(justify: true)
#show link: underline.with(stroke: blue.lighten(50%))

#let VERSION = toml("/typst.toml").package.version

#let show-module(path) = {
	show heading.where(level: 3): it => {
		align(center, line(length: 100%, stroke: black.lighten(70%)))
		block(text(1.3em, raw(it.body.text + "()")))
	}
	tidy.show-module(
		tidy.parse-module(
			read(path),
			scope: (wordometer: wordometer)
		),
		show-outline: false,
		sort-functions: x => {
			str(int(not x.name.starts-with("word-count"))) + x.name
		}
	)
}

#show: word-count



#v(.2fr)

#align(center)[
	#stack(
		spacing: 12pt,
		text(2.6em, `wordometer`),
		[_This manual contains #total-words words._],
	)

	#v(30pt)

	A small #link("https://typst.app/")[Typst] package for quick and easy in-document word counts.

	#link("https://github.com/Jollywatt/typst-wordometer")[`github.com/Jollywatt/typst-wordometer`]

	Version #VERSION

]

#set raw(lang: "typc")

// bug in typst v0.11.0
// https://github.com/typst/typst/pull/3847
// remove once fixed
#show raw.where(block: true): it => {
	set text(1.25em)
	block(raw(it.text.replace("\t", "  "), lang: it.lang))
}



#v(1fr)

#[
	#show heading: pad.with(y: 10pt)

	= Basic usage

	#show "VERSION": VERSION
	```typ
	#import "@preview/wordometer:VERSION": word-count, total-words

	#show: word-count

	In this document, there are #total-words words all up.

	#word-count(total => [
	  The number of words in this block is #total.words
	  and there are #total.characters letters.
	])
	```

	= Excluding elements

	You can exclude elements by function (e.g., `heading`, `table`, `figure.caption`), by where-selector (e.g., `raw.where(block: true)`), or by label (e.g., `<no-wc>`).


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
	let text = extract-text(name)
	link(label(text), raw(text))
}

#let scope = (
	word-count: word-count,
	word-count-of: word-count-of,
)
#let example-pair(code) = {
	let result = eval(code.text, mode: "markup", scope: scope)
	(code, result)
}

= Details

The basic #fn[word-count-of()] function accepts content and returns a dictionary of statistics.
The main #fn[word-count()] function wraps this in a more convenient interface, for use in a document show rule:
```typ
#show: word-count
```
...or for scoped word counts:
```typ
#word-count(total => [There are #total.words total words.])
```

The actual word counting works by using #fn[extract-text()] to convert content to a plain string which is split up into words, sentences, and so on. You can specify exactly what is counted via the `counter` argument of most functions.

The #fn[extract-text()] function uses #fn[map-tree()] to traverse a content tree and accumulate the text from each leaf node.
The #fn[map-tree()] function (and most of the other functions) has an `exclude` parameter, which is used to exclude certain elements from the word count.

The following elements have no text content and are always excluded: #IGNORED_ELEMENTS.sorted().map(raw).join([, ], last: [, and ]).

== Where this doesn't work

Word counting with #fn[extract-text()] occurs *before show rules are applied*, which means content modified by show rules may get counted differently to how it looks finally.

== Ways to exclude elements

- By element:
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
- By label:
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
	)

- By `where` selector:

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


#pagebreak()

= Functions

#show-module("/src/lib.typ")