// An opinionated 3rd party library for rendering prettier source code blocks.
// You may get rid of it or replace it with something else if you like.
// https://typst.app/universe/package/codly
#import "@preview/codly:1.2.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()

// Auxiliary functions for fixing the vertical offset of icons.
// This is a font-dependent hack (Noto Color Emoji font). You could use
// FontAwesome or Nerd Fonts for better results.
#let icon-text(body) = box()[#v(-1pt)#body#v(1pt)]
#let icon(body) = box()[#v(-2pt)#body#v(2pt)]
// Configure codly. Optional.
#codly(
	languages: (
		c: (name: [C], icon: none, color: black),
		cpp: (name: [C++], icon: none, color: black),
		py: (name: icon-text(text(rgb("#003070"))[Python]), icon: icon[🐍], color: blue),
		rust: (name: icon-text(text(red)[Rust]), icon: icon[🦀], color: rgb("#CE412B")),
	)
)
#codly-disable()

= More tips for writers

== Quick rules for better style

- Do not use headings above level 3 (`====` is very bad). If you _really_ need more, then
	1. You probably don't. Rethink your section structure.
	2. You _really_ probably don't. See above.
	3. Use unnumbered sections or terms lists.

- Do not overuse *strong* (or *bold*) text. It is distracting for the reader
	and blends in with headings. For emphasis, use _emphasis_. Duh.

- Use a _hyphen_ '-' (`-`) for connecting words only (e.g. "semi-automatic").

- Use _en dash_ '--' (`--`) for pause (e.g. "make no mistake -- it's easy").
	- In American typography, _em dash_ '---' (`---`) often serves this purpose,
		and it is used without surrounding spaces, e.g. "make no mistake---it's
		easy". Use either style, but stick to one and one only!

- Use ```typst #block(breakable: false)[ ... ]``` for content that should stay
	on the same page, e.g.: #align(center)[
	```typst
	#block(breakable: false)[
		And this is a paragraph that leads into a listing, and it would look
		really awkward if it got separated from it by a page break:

		- item A
		- item B
		- item C
	]
	```]

- Place footnotes _after_ the period ending a sentence, not before.#footnote[Like so! Also do not overuse footnotes.]

- Figure titles (tables, images, code listings, etc.) should end with a period.

- Names of files, paths, directories, variables, functions, classes, etc.
	should be typeset in `a_monospace_font`. Typst supports inline code
	highlighting: ```c main(int argc, char **argv)```.

- Use non-breaking space (typeset using 'tilda' `~`) to prevent awkward line
	endings. In particular, before every`~@ref` that appears in the middle of a
	sentence. Note that, unlike LaTeX, Typst does not add extra spacing after
	each period and tries to recognize sentence endings in a slightly more
	intelligent way, so it is not necessary to write `e.g.~like this` every
	time, but you should still be mindful about it.

#pagebreak(weak: true)
== Numbered, unnumbered, terms, tight and wide lists
Typst has numbered, unnumbered and terms lists. All 3 types also can be tight
or wide:

#align(center, table(
	columns: (4),
	align: (left + horizon),
	table.header[][*Numbered*][*Unnumbered*][*Terms*],
	[*Tight*],
	[
		Paragraph before.
		1. One
		2. Two
		3. Three
		Paragraph after.
	],
	[
		Paragraph before.
		- One
		- Two
		- Three
		Paragraph after.
	],
	[
		Paragraph before.
		/ One: This is 1.
		/ Two: This is 2.
		/ Three: This is 3.
		Paragraph after.
	],
	[*Wide*],
	[
		Paragraph before.
		1. One

		2. Two

		3. Three
		Paragraph after.
	],
	[
		Paragraph before.
		- One

		- Two

		- Three
		Paragraph after.
	],
	[
		Paragraph before.
		/ One: This is 1.

		/ Two: This is 2.

		/ Three: This is 3.
		Paragraph after.
	],
))

Numbering of lists can be done explicitly or automatically. Both examples below
are equivalent:

#align(center, block(width: 5cm)[
	#place(left)[
		```typst
		// Explicit
		1. One
		2. Two
		3. Three
		```
	]
	#place(right)[
		```typst
		// Automatic
		+ One
		+ Two
		+ Three
		```
	]
	#v(17mm)
])

#block(breakable: false)[
	For more information, refer to:
	- https://typst.app/docs/reference/model/list/
	- https://typst.app/docs/reference/model/enum/
	- https://typst.app/docs/reference/model/terms/
]

== Math equations

Typst has native support for typesetting math equations. In the wide majority
of cases, it works perfectly fine and is very intuitive to use. However, it is
not yet as mature and battle-tested as LaTeX's engine, so more demanding use
cases may require manual tweaking or call for better tools.

The quadratic equation, as seen on~@eq:quadratic.

$
	x = (-b plus.minus sqrt(b^2 - 4 a c)) / (2 a)
$ <eq:quadratic>

And the arc length of a continuous function can be calculated using
@eq:arc-length.

$
	S = integral_a^b sqrt(1 + (f'(x))^2) dif x
$ <eq:arc-length>

== Plots and images
Typst has native support for various image formats. Vector formats such as SVG
are preferred over raster ones.

For plotting, there are 3rd party native libraries such as
#link("https://typst.app/universe/package/cetz-plot")[cetz-plot], although it
may be better to use an entirely independent, mature plotting framework such as
Gnuplot, ggplot2, or Matplotlib and export SVG images.

#figure(
	image("../img/plot.svg", width: 80%),
	caption: [Sine wave (made with Gnuplot)],
)

== Conjugating the supplement in Polish writing
#block(breakable: false)[
	In Polish writing, when using automatic references, the conjugation of the
	supplement poses a slight challenge. For Polish writers:

	#box(stroke: 1pt, inset: 8pt)[
		#set text(lang: "pl")
		Jeśli zdanie wymaga formy mianownikowej suplementu ("Sekcja"), to nie ma
		problemu. Piszemy wtedy po prostu:
		```typst
		@sec:topic-and-scope opowiada o temacie pracy.
		```
		Ale gdybyśmy chcieli napisać "W Sekcji 1.1, ...", potrzebujemy odpowiedniej
		odmiany, której Typst nie zagwarantuje. Przykładowo, taki kod:
		```typst
		W~@sec:topic-and-scope omawiany jest temat pracy.
		```
		Zostanie przełożony na "W~@sec:topic-and-scope omawiany jest temat pracy", co jest
		gramatycznie niepoprawne i nieładnie wygląda. W takich sytuacjach zalecane
		jest tymczasowe nadpisanie tzw. suplementu (w tym wypadku słowa "Sekcja"):
		```typst
		W~@sec:topic-and-scope[Sekcji] omawiany jest temat pracy.
		```
		Taka forma skutkuje poprawnym "W~@sec:topic-and-scope[Sekcji] omawiany jest
		temat pracy". Równocześnie, całe sformułowanie
		"@sec:topic-and-scope[Sekcji]" będzie poprawnie wygenerowane jako klikalny
		odnośnik do odpowiedniego miejsca w pracy.

		To samo tyczy się odwołań do rysunków, tabel, równań, etc. Dla ciekawskich,
		dokumentacja funkcji ```typst ref()```, która jest wywoływana pod spodem
		dla każdego odwołania:\ https://typst.app/docs/reference/model/ref/.
	]
]

== Source code

#block(breakable: false)[
	Typst has native support for source code blocks with syntax highlighting.

	Take some time to examine~@hello-c.
	#figure(
		```c
		#include <stdio.h>

		int main(int argc, char **argv)
		{
			printf("Hello, world!\n");
			return 0;
		}
		```,
		caption: [The best program, written in the C programming language.],
	) <hello-c>
]

These code blocks interact well with figure environments and can be referenced
easily out-of-the-box. But for extra punch, we can use a 3rd party package such
as #link("https://typst.app/universe/package/codly")[codly] to prettify source
code even further and get more features such as highlighting parts of our code.

#codly-enable()
While~@hello-c is written in the best programming language, here is a version
in a much inferior, offspring language, C++:

#codly(highlights: ((line: 5, start: 3, fill: red),))
#figure(
	```cpp
	#include <iostream>

	int main(int argc, char **argv)
	{
		std::cout << "Hello, world!" << std::endl;
		return 0;
	}
	```,
	caption: [The best program, made slightly worse.],
) <hello-cpp>

Highlighted red, you can see one of the earliest red flags in the design of the
C++ language.

Scripting languages also deserve credit. @hello-python showcases a
version of the same program, this time written in Python.

#figure(
	```py
	print("Hello, world!")
	```,
	caption: [The best program, for the lazy.],
) <hello-python>

Last but not least, let us consider a representative of a newer front of
memory-safe languages, Rust. The code can be seen on~@hello-rust.

#figure(
	```rust
	fn main() {
		println!("Hello, world!");
	}
	```,
	caption: [The best program, memory safe#footnote[Well, more or less. See~@cve-rs.]],
) <hello-rust>


=== Ranking
Now that we have seen what the different languages can do and how they present
themselves, a natural question arises: Which one to use? @tab:ranking shows an
objective, unopinionated ranking of all languages.
#figure(
	table(
		stroke: none,
		columns: (3),
		align: (center, left, left),
		table.hline(),
		table.header[*Rank*][*Language*][*Comment*],
		table.hline(),
		[1], [C], [The undisputed king.],
		[2], [Python], [You may disagree, but you cannot argue with its practicality.],
		[3], [Rust], [Rust is on trial. It could become fantastic, let us hope so.],
		[4], [C++], [It's a mess. I just don't like it.],
		table.hline(),
	),
	caption: [Ranking of all languages],
) <tab:ranking>
