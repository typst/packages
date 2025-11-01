#import "/theofig.typ" as theofig-module: *

#import "/docs/doc-style.typ"
#let tidy = doc-style.tidy


#set page(numbering: "1")
#set par(justify: true)
#set text(lang: "en")
#show link: underline.with(stroke: 1pt + blue.lighten(70%), offset: 1.5pt)
#show heading: it => {it; v(0.5em)}

#let VERSION = toml("/typst.toml").package.version

// show references to headings as the heading title with a link
// not as "Section 1.2.3"
#show ref: it => {
	if it.element.func() == heading {
		link(it.target, it.element.body)
	} else { it }
}

#let scope = dictionary(theofig-module)

// link to a specific parameter of a function
#let param(func, arg, full: false) = {
	let func = func.text
	let arg = arg.text
	let l1 = doc-style.fn-param-label(func, arg)
	let l2 = doc-style.fn-label(func)
	if full {
		[the #link(l1, raw(arg)) option of #link(l2, raw(func + "()"))]
	} else {
		link(l1, raw(arg))
	}
}
#let the-param = param.with(full: true)
#let variable(var, prefix: "") = {
  let var = var.text
  link(label(prefix + "-" + var), raw(var))
}
#let fn(func, prefix: "") = {
  let func = func.text
  link(doc-style.fn-label(func), raw(func + "()"))
}


#set raw(lang: "typc")

#v(.2fr)

#align(center)[
	#stack(
		spacing: 14pt,
		{
			set text(1.3em)
            block(width: 75%)[
              #definition[This is a package for theorem environments.]
            ]
		},
		text(2.7em, `theofig`),
		[_`figure` implementation of theorem environments_],
	)

	#v(30pt)

    A #link("https://typst.app/")[Typst] package for creation and
    customization \ of theorem environments built on top of
    #link("https://typst.app/docs/reference/model/figure/")[`std.figure`].

	#link("https://github.com/Danila-Bain/typst-theorems")[`github.com/Danila-Bain/typst-theorems`]

	*Version #VERSION*
]


#show raw.where(block: true): set text(8pt)


#v(1fr)

#columns(2)[
	#outline(
		title: align(center, box(width: 100%)[Guide]),
		indent: 1em,
		target: selector(heading).before(<func-ref>, inclusive: false),
	)<outline>
	#colbreak()
	#outline(
		title: align(center, box(width: 100%)[Reference]),
		indent: 1em,
		target: selector(heading.where(level: 1)).or(heading.where(level: 2)).after(<func-ref>, inclusive: true),
	)
]

#show heading.where(level: 1).or(heading.where(level: 2)): it => link(<outline>, it)

#v(1fr)

#pagebreak()




= Usage examples

#raw(lang: "typ", "#import \"@preview/theofig:" + VERSION + "\": *")


#let code-example(src) = (
	{
		// set text(1.85em)
		let code = src.text.replace(regex("(^|\n).*// hide\n|^[\s|\S]*// setup\n"), "")
		box(raw(block: true, lang: src.lang, code)) // box to prevent pagebreaks
        context {theofig-reset-counters(theofig-kinds)}
	},
	eval(
		src.text,
		mode: "markup",
		scope: scope
	),
)

#let code-example-row(src) = table(
	columns: (2.5fr, 2fr),
	stroke: none,
    inset: 0pt,
    column-gutter: 5mm,
	..code-example(src)
)

== Basic usage

#code-example-row(```typ
#theorem[#lorem(5)] <theorem-1>

#theorem[Lorem][#lorem(10)]

#proof[It follows from @theorem-1.]
```),



== Default environments

`theofig` defines a number of default environments with sensible default style.

#code-example-row(```typ
#theorem[#lorem(5)]

#lemma[#lorem(5)]

#statement[#lorem(5)]

#remark[#lorem(5)]

#corollary[#lorem(5)]

#example[#lorem(5)]

#definition[#lorem(5)]

#algorithm[#lorem(5)]

#proof[#lorem(5)]

#problem[#lorem(5)]

#solution[#lorem(5)]
```)

== Custom environments

All default environments of `theofig` package are defined as `.with()`-specializations of 
a function #fn[theofig], which can also be used to create custom environments. 

#code-example-row(```typ
#let joke = theofig.with(supplement: "Joke")

#{theofig-kinds += ("joke", )}

#show figure-where-kind-in(theofig-kinds): set text(gradient.linear(red, green, blue))

#joke[Why was six afraid of seven? Because 7 8 9.]
#joke[
  Parallel lines have so much in common... 
  It’s a shame they’ll never meet.
]
#statement[A topologist is someone who can’t tell the difference between a coffee mug and a doughnut.]

```)
If #the-param[theofig][supplement] is specified, the #param[theofig][kind] is chosen automatically as `lower(supplement)`,
so in this example adding `"joke"` to #variable[theofig-kinds] lets us apply styling 
to a `joke` environment together with all standard environments.

== Languages support

Enabled by #the-param[theofig][translate-supplement],
#param[theofig][supplement] is translated based on context-dependant
`text.lang`. List of supported languages: #theofig-translations.keys().join(", "). 
Note that unlike supplement of a figure, a supplement in reference changes
if `text.lang` is not the same as it was at the location of the figure.

#code-example-row(```typ
#set text(lang: "ru")
#theorem[#lorem(5)]

#set text(lang: "es")
#theorem[#lorem(5)]

#set text(lang: "de")
#theorem[#lorem(5)]

#set text(lang: "ja")
#theorem[#lorem(5)]
```)


== Ways to specify numbering style

Most default environments use `figure`'s default numbering, which is `"1"` 
(see @def-a-1). Hence, we can change default numbering for many environments
simultaneously using a `show` rule with `set figure(numbering: ...)`
(see @def-a-2). Then, if we specify an argument `numbering` in the environment,
it takes priority over `figure`'s numbering (see @def-a-3 and @def-a-4).

#code-example-row(```typ
#definition[Default @def-a-1.]<def-a-1>

#show figure-where-kind-in(
  theofig-kinds
): set figure(numbering: "I")
#definition[Show rule @def-a-2.]<def-a-2>

#let definition = definition.with(numbering: "A")
#definition[Redefined @def-a-3.]<def-a-3>

#definition(numbering: numbering.with("(i)"))[
  Argument @def-a-4.
]<def-a-4>
```)

== Numbers out of order

Using #the-param[theofig][number], we can specify a number regardless of
automatic numeration. Passing a `label` to #param[theofig][number] copies the 
#param[theofig][numbering] of the same environment by that `label`, which is
useful for alternative definitions or equivalent statements of theorems (see
@def-1 and @def-2).

#code-example-row(```typ
#definition[Default.]

#definition(numbering: none)[No numbering.]

#definition[Equivalent to @def-2.]<def-1>

#definition(number: <def-1>, numbering: "1'")[ 
  Equivalent to @def-1. 
]<def-2>

#definition(number: 100)[ 
  This is @def-100. 
]<def-100>

#definition(number: 5, numbering: "A")[
  This is @def-3.
]<def-3>

#definition(number: $e^pi$)[
  This is @def-exp
]<def-exp>

#definition[Back to default.]
```)

Another use case for #param[theofig][number] argument is local numbering, such as multiple
corollaries immediately after a theorem:
#code-example-row(```typ
#theorem[]
#corollary[]
#theorem[]
#corollary(number: "1")[]
#corollary(number: "2")[]
#theorem[]
#corollary(number: "1")[]
#corollary(number: "2")[]
```)


== Shared numbering

If you want different environments to share numbering,
you just need to have them have the same #param[theofig][kind], but different
#param[theofig][supplement]:
#code-example-row(```typ
#let lemma     = lemma.with(kind: "theorem")
#let statement = statement.with(kind: "theorem")

#theorem[#lorem(5)]
#lemma[#lorem(5)]
#statement[#lorem(5)]
#theorem[#lorem(5)]
```)

One obvious limitation of that approach is that not only numbering
will be shared. All styling of #fn[theorem] that is based on `show` rules
will also apply to #fn[lemma] and #fn[statement]. To mitigate that,
styling can be applied individually through setting arguments
#param[theofig][format-caption], #param[theofig][format-body],
#param[theofig][block-options], and #param[theofig][figure-options].
#code-example-row(```typ
#let theorem = theorem.with(
  format-body: emph,
)
#let lemma     = lemma.with(
  kind: "theorem",
  format-caption: none,
)
#let statement = statement.with(
  kind: "theorem",
  block-options: (
    stroke: 1pt, radius: 3pt, inset: 5pt,
  ),
)

#theorem[#lorem(5)]
#lemma[#lorem(5)]
#lemma[#lorem(5)]
```)

== Show rules to specify a style

All environments are `figure`'s under the hood, and they can be styled
using show rules. The title of environment, such as "*Theorem 4 (Cauchy).*"
can be style using `show figure.caption: ...` rules.

#code-example-row(```typ
// apply to one
#show figure.where(kind: "theorem"): smallcaps
// apply to some
#show figure-where-kind-in(
  ("solution", "problem")
): emph
// apply to all
#show figure-where-kind-in(theofig-kinds): set figure(
  numbering: "I",
)
// apply to all except some
#show figure-where-kind-in(
  theofig-kinds, except: ("proof",),
): set text(blue)

#definition[#lorem(10)]
#theorem[#lorem(10)]
#proof[#lorem(10)]
#problem[#lorem(10)]
#solution[#lorem(10)]
```)



== Style examples

Note that in the following examples, in order for `block`-ed styles to be
breakable without visual glitches, you should make blocks inside a `figure`
sticky with something like \
`show figure-where-kind-in(theofig-kinds): set block(breakable: true, sticky: true)`.
#code-example-row(```typ
#theorem[Default. #lorem(16)]

#show figure.where(kind: "definition"): it => {
  show figure.caption: emph
  show figure.caption: strong.with(delta: -300)
  it
}
#definition[Italic caption. #lorem(16)]

#show figure.where(kind: "lemma"): it => {
  show figure.caption: underline.with(offset: 1.5pt)
  show figure.caption: strong.with(delta: -300)
  it
}
#lemma[Underline caption. #lorem(16)]

#show figure.where(kind: "proposition"): it => {
  show: emph
  show figure.caption: emph
  show figure.caption: smallcaps
  show figure.caption: strong.with(delta: -300)
  it
}
#proposition[Italic body, smallcaps caption. #lorem(12)]


#show figure.where(kind: "corollary"): it => {
  show figure.caption: strong.with(delta: -300)
  show figure.caption: set text(tracking: 3pt)
  it
}
#corollary[Sparse caption. #lorem(16)]

#show figure.where(kind: "statement"): block.with(
  stroke: 1pt, radius: 3pt, inset: 5pt,
)
#statement[Block. #lorem(16)]

#show figure.where(kind: "solution"): block.with(
  stroke: (left: 1pt), inset: (right: 0pt, rest: 5pt)
)
#solution[Line to the left. #lorem(16)]
```)

== Limitations

Because #fn[theofig] implemented as figure, show rules applied to it affect
nested figures of any kind, including images and tables:

#code-example-row(```typ
#show figure.where(kind: "example"): it => {
  set figure(numbering: "I")
  show figure.caption: smallcaps
  it
}
#example[
  Example with an image:
  #figure(caption: [Example Image])[
    #image(
      bytes(range(256).map(i => i.bit-and(i*i))), 
      format:(encoding:"luma8",width:32,height:8),
      width: 100%, 
    )
  ]
]
```)
In this example, `smallcaps` is applied not only to the #fn[example] title, but
also to the actual `figure`'s caption, the same is true for numbering. 
It is an undesirable limitation, which leads us to either moving our figures
outside of #fn[theofig] environments or styling each #fn[theofig] environment individually
like in the following example, using parameters
#param[theofig][format-caption], #param[theofig][format-body], or
#param[theofig][format-note].
#code-example-row(```typ
#let example = example.with(
  numbering: "I", 
  format-caption: it => smallcaps(strong(it)),
)
#example[
  Example with an image:
  #figure(caption: [Example Image])[
    #image(
      bytes(range(256).map(i => i.bit-and(i*i))), 
      format:(encoding:"luma8",width:32,height:8),
      width: 100%, 
    )
  ]
]
```)

#pagebreak()
= Main functions <func-ref>

#let show-module(file) = {
  let module-doc = tidy.parse-module(
    read(file),
    scope: (
      code-example-row: code-example-row,
      param: param,
      the-param: the-param,
      variable: variable,
      ..dictionary(theofig-module)
    ),
    old-syntax: true
  )
  tidy.show-module(
    module-doc,
    show-outline: false,
    sort-functions: none,
    first-heading-level: 1,
    style: doc-style,
  )
}

#show-module("/src/theofig.typ")
#show-module("/src/utils.typ")
#show-module("/src/theofig-kinds.typ")
#show-module("/src/translations.typ")
