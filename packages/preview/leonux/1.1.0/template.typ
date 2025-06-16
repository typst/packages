#let colors = (
	primary: rgb("137C24"),
	block_background: rgb("E2E2E2"),
	text_title: white,
	text_body: black,
	text_titlepage: rgb("646464"),
	slides_background: white
)

#let priv-primary = state("primary",colors.primary)
#let priv-title = state("title", none)
#let priv-subtitle = state("subtitle", none)
#let priv-date = state("date", none)
#let priv-author = state("author", none)
#let priv-institute = state("institute", none)
#let priv-content = state("priv-content",())

// dynamic-slides
#let slide-ctr = counter("slide-ctr")
#let later-ctr = counter("later-ctr")
#let pos-ctr = counter("pos-ctr")
#let sub-ctr = counter("sub-ctr")


#let later(body) = [
	#later-ctr.step()
	#pos-ctr.step()
	#context{
		if (pos-ctr.get().first() < sub-ctr.get().first()) {
			body
		} else {
			hide(body)
		}
	}
]

#let setup(
	ratio: "16-9",
	primary: none,
	title : none,
	subtitle : none,
	date: none,
	author: none,
	institute: none,
	body
) = {
	if primary != none{
		priv-primary.update(primary)
	}
	priv-title.update(title)
	priv-subtitle.update(subtitle)
	priv-date.update(date)
	priv-author.update(author)
	priv-institute.update(institute)
	set align(horizon)
	set text(
		font: "Fira Sans",
		fill: colors.text_body,
		size: 16pt

	)
	set page(
		paper: "presentation-" + ratio,
		fill: colors.slides_background,
		numbering: "1/1",
		number-align: bottom + right,
		header: none,
		footer: none
	)
	show ref: it => text(fill: colors.primary)[#it]
	show link: it => text(fill: colors.primary)[#it]
	show footnote: it => text(fill: colors.primary)[#it]
	body
}

#let titlepage(
) = context{
	set align(center + horizon)
	box(
		width: 80%,
		height: auto,
		fill: priv-primary.get(),
		radius: 10pt,
		inset: 1em,
		outset: 1em,
	)[
		#text(size: 24pt,fill: colors.text_title)[#context(priv-title.get())]

		#text(size: 16pt, fill: colors.text_title)[#context(priv-subtitle.get())]
	]
	context{
		let information = []
		information += v(1cm)
		if priv-author.get() != none {
			information += text(size: 16pt, fill: colors.text_titlepage)[#context(priv-author.get())]
		}
		if priv-institute.get() != none {
			information += text(size: 16pt, fill: colors.text_titlepage)[ \@ #context(priv-institute.get())]
		}
		if priv-date.get() != none {
			information += text(size: 18pt, fill: colors.text_titlepage)[#v(.2cm) #context(priv-date.get())]	
		}
		information
	}
}

#let my-block(
	title: none,
	body
) = context{
	stack(
		dir: ttb,
		spacing: 0pt,
		block(
			width: 100%,
			height: auto,
			fill: priv-primary.get(),
			radius: (top: 10pt),
			inset: .59cm
		)[
			#text(size: 16pt, fill: colors.text_title)[#title]
		],
		block(
			width: 100%,
			height: auto,
			fill: colors.block_background,
			radius: (bottom: 10pt),
			inset: .59cm
		)[
			#body
		]
	)
}

#let register(
	name
) = context{
	let page = here().position()
	priv-content.update(
		content => {
			content.push((title:name,loc:page))
			content
		}	
	)	
}

#let inner-slide(
	title: none,
	ctr: counter(page),
	body
) = {
	pagebreak()
	set page(
		background: context{
			place(top + left)[
				#block(
					width: 100%, height: auto, fill: priv-primary.get(), inset: .59cm
				)[#text(size: 20pt, fill: colors.text_title)[
					#title
				]]
			]
			place(bottom + left)[
				#block(
					width: 100%, height: auto, fill: priv-primary.get(), inset: .2cm
				)[#text(size: 10pt, fill: colors.text_title)[
					#priv-date.get(): #priv-title.get() [#priv-subtitle.get()] #h(4cm) #priv-author.get() \@ #priv-institute.get() #h(1fr) #ctr.display("1/1",both: true) 
				]]
			]
		}
	)
	// register(title)
	body
}

#let slide(
	title: none,
	body
) = {
	slide-ctr.step()
	let inner = inner-slide(title: title, ctr: slide-ctr)[#body]
	later-ctr.update(0)
	pos-ctr.update(0)
	sub-ctr.update(1)
	inner

	context{
		for _ in range(later-ctr.get().first()) {
			sub-ctr.step()
			pos-ctr.update(0)
			inner
		}
	}
}

#let section(title: none) = context{
	pagebreak()
	set align(center + horizon)
	block(
		width: 80%,
		height: auto,
		fill: priv-primary.get(),
		radius: 10pt,
		inset: 1em,
		outset: 1em
	)[
		#text(
			size: 24pt,
			fill: colors.text_title,

		)[
			#title
		]
	]
	register(title)
}

#let references(
	title: "References",
	bib
) = {
	set bibliography(
		title: none,
		style: "ieee"
	)
	slide(title: title)[
		#bib
	]
}

#let content(
	title: "Table of contents"
) = {
	slide(title: title)[
		#context{
		let content = priv-content.final()
		enum(..content.map(section => link(section.loc, section.title)))
		}
	]
}

