#let colors = (
	primary: rgb("137C24"),
	block_background: rgb("E2E2E2"),
	text_title: white,
	text_body: black,
	text_titlepage: rgb("646464"),
	slides_background: white
)

#let Title = state("title", none)
#let Subtitle = state("subtitle", none)
#let Date = state("date", none)
#let Author = state("author", none)
#let Institute = state("institute", none)
#let Content = state("Content",())

#let setup(
	ratio: "16-9",
	title : none,
	subtitle : none,
	date: none,
	author: none,
	institute: none,
	body
) = {
	Title.update(title)
	Subtitle.update(subtitle)
	Date.update(date)
	Author.update(author)
	Institute.update(institute)
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
) = {
	set align(center + horizon)
	box(
		width: 80%,
		height: auto,
		fill: colors.primary,
		radius: 10pt,
		inset: 1em,
		outset: 1em,
	)[
		#text(size: 24pt,fill: colors.text_title)[#context(Title.get())]

		#text(size: 16pt, fill: colors.text_title)[#context(Subtitle.get())]
	]
	context{
		let information = []
		information += v(1cm)
		if Author.get() != none {
			information += text(size: 16pt, fill: colors.text_titlepage)[#context(Author.get())]
		}
		if Institute.get() != none {
			information += text(size: 16pt, fill: colors.text_titlepage)[ \@ #context(Institute.get())]
		}
		if Date.get() != none {
			information += text(size: 18pt, fill: colors.text_titlepage)[#v(.2cm) #context(Date.get())]	
		}
		information
	}
}

#let myBlock(
	title: none,
	body
) = {
	stack(
		dir: ttb,
		spacing: 0pt,
		block(
			width: 100%,
			height: auto,
			fill: colors.primary,
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
	Content.update(
		content => {
			content.push((title:name,loc:page))
			content
		}	
	)	
}

#let slide(
	title: none,
	body
) = {
	pagebreak()
	set page(
		background: context{
			place(top + left)[
				#block(
					width: 100%, height: auto, fill: colors.primary, inset: .59cm
				)[#text(size: 20pt, fill: colors.text_title)[
					#title
				]]
			]
			place(bottom + left)[
				#block(
					width: 100%, height: auto, fill: colors.primary, inset: .2cm
				)[#text(size: 10pt, fill: colors.text_title)[
					#Date.get(): #Title.get() [#Subtitle.get()] #h(4cm) #Author.get() \@ #Institute.get() #h(1fr) #counter(page).display("1/1",both: true) 
				]]
			]
		}
	)
	register(title)
	body
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
		let content = Content.final()
		enum(..content.map(section => link(section.loc, section.title)))
		}
	]
}
