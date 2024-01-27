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


#v(1fr)

#[
	#show heading: pad.with(y: 10pt)

	= Basic usage

	```typ
	#import "@preview/wordometer:0.1.0": word-count, total-words

	#show: word-count

	In this document, there are #total-words words all up.

	#word-count(total => [
	  The number of words in this block is #total.words
	  and there are #total.characters letters.
	])
	```

	= Excluding elements

	You can exclude elements by name (e.g., `"caption"`), function (e.g., `figure.caption`), where-selector (e.g., `raw.where(block: true)`), or label (e.g., `<no-wc>`).


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


#show-module("/src/lib.typ")