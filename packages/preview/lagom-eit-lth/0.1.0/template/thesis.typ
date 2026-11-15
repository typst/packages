#import "@preview/lagom-eit-lth:0.1.0": thesis, mainmatter, frontmatter, backmatter, flex-caption
#import "metadata.typ": *

#show: thesis.with(
  thesis-title: title,
  thesis-subtitle: subtitle,
  authors: authors,
  supervisors: supervisors,
  examiner: examiner,
  affiliations: affiliation,
  keywords: keywords,
  description: "Unofficial thesis template for degree projects at Electrical and information technology at Lund University.",
  date: end-date,
  issn: none,
  report-number: none,
  print: false,
)

#show: frontmatter

= Frontmatter

#lorem(75)

#set terms(tight: false, spacing: 5mm)
#for (abb, des) in (
	"EIT": "Engineering Is (never) Trivial",
	"LED": "Let's Emit Dazzle",
	"MOSFET" : "Mostly Our Small Friend Enabling Transistor",
	"AC" : "Actually Confusing",
	"EMC" : "Engineers' Major Complaint",
	"CODE" : "Computers Only Do Exactly (what you tell them)",
	"PING" : "Packet Is Now Going"
).pairs().sorted() [/ #abb: #des]

#align(center)[
  #quote(block: true, quotes: true, attribution: [A wise Associate Professor #footnote([Translated. Original quote in Swedish.]), spring 2025])[
		To mature as an electrical engineer is to realize everything is about impedances.
	]
]

#align(bottom)[*Keywords:* #keywords.join(", ")]

#outline(title: "Table of Contents") <outline>
#outline(title: "List of Figures", target: figure.where(kind: image))
#outline(title: "List of Tables", target: figure.where(kind: table))

#show: mainmatter

= Introduction <intro>
#lorem(100)

#lorem(100)

$ "div" bold(A) := lim_(Delta v arrow 0) (integral.surf_S bold(A) dot d bold(s)) / (Delta v) $ <divergence>

$ nabla times bold(B) = mu_0(bold(J) + epsilon_0 (partial bold(E)) / (partial t)) $ <ampere-maxwell>

The equations above are @divergence and @ampere-maxwell. This is @intro but below is @test and below that is @test2. This chapter can be found on #ref(<intro>, form: "page").

== Test section <test>

#lorem(50)

=== A section which won't appear in the outline on #ref(<outline>, form: "page"). <test2>
#lorem(50)

== Another test section

#lorem(10) #footnote[https://www.lth.se]

#let l = counter("letters")
#let letter() = block[
	#l.step()
	#context l.display("A")
]

#figure(
	block(width: 5cm, height: 3cm, fill: luma(80%), align(center + horizon, text(size: 75pt, fill: luma(10%), letter()))),
	caption: flex-caption([A figure with a longer caption. #lorem(50)], [A shorter caption, but links to the same figure!])
)

= #flex-caption("New Chapter with a Long Title that Spanns over More Than One Line", "A New Chapter with a Short Title") <flexHeading>

#grid(columns: 2, 
	[#figure(
	block(width: 5cm, height: 2.5cm, fill: luma(80%), align(center + horizon, text(size: 75pt, fill: luma(10%), letter()))),
	caption: "A figure together with another figure."
	) <figureB> ], [
	#figure(
	block(width: 5cm, height: 2.5cm, fill: luma(80%), align(center + horizon, text(size: 75pt, fill: luma(10%), letter()))),
	caption: flex-caption([This figure can have a long caption and still fit if done this way. #lorem(10)], [This figure can have a long caption and still fit.])
) <figureC>])

Above @figureB is next to @figureC. By using the #raw("#flex-caption(long caption, short caption)", lang: "typst", block: false) function you can make flexible captions. You can also make longer/shorter headings! See @flexHeading on #ref(<outline>, form: "page").

== New section

$ F_(n) = F_(n-1) + F_(n-2), #h(1cm) cases(F_0 = 0, F_1 = 1) $

#let count = 15
#let nums = range(1, count + 1)
#let fib(n) = (
  if n <= 2 { 1 }
  else { fib(n - 1) + fib(n - 2) }
)

#figure(table(
  columns: count,
  ..nums.map(n => $F_#n$),
  ..nums.map(n => str(fib(n))),
),
caption: [The Fibonacci sequence up to n = #count.])

= A word on Typst referencing

On #ref(<ref>, form: "page") you can find links. @latex-guide provides a guide for past LaTeX users on the differences between the two typesetting languages, including what's native or not native, which macros map to which function etc. @cite and @bibliography links to information on how to cite and reference different sources. Typst includes support for both its native YAML-based format and BibTeX. @universe gives a link to the Typst Universe. On this page you can find packages which aid in your workflow, both in terms of styling and automation. Zap for example is used to make circuit diagrams much like TikZ. @zap

For documentation on all functions, markup- and styling commands, see @documentation.

#bibliography("refs.bib") <ref>

#show: backmatter

= Backmatter

#figure(
	align(left, [```c
	/* Function to sort array using insertion sort */
	void insertionSort(int arr[], int n)
	{
	    for (int i = 1; i < n; ++i) {
	        int key = arr[i];
	        int j = i - 1;

	        /* Move elements of arr[0..i-1], that are
	           greater than key, to one position ahead
	           of their current position */
	        while (j >= 0 && arr[j] > key) {
	            arr[j + 1] = arr[j];
	            j = j - 1;
	        }
	        arr[j + 1] = key;
	    }
	}
	```]),
 // kind: raw,
	caption: "Code snippet for insertionsort written in C."
)

#figure(
	block(width: 5cm, height: 3cm, fill: luma(80%), align(center + horizon, text(size: 90pt, fill: luma(10%), letter()))),
	caption: "This is the last figure."
	) <figureD>