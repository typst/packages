#let scriptsize = 8pt

#let transition(
	// The slide accent color. Default is a vibrant yellow.
	accent-color: rgb("f3bc54"),

	// The slide content.
	body,
) = {
	page(
		width: 15cm,
		height: 10cm,
		background: rect(width: 100%, height: 100%, fill: accent-color),
		header: none,
		footer: none,
	)[
		#set align(center+horizon)
		#set text(28pt, fill: white, weight: "bold")
		#body
	]
}

#let slides-init(
	// The presentation's title, which is displayed on the title slide.
	title: "Title",

	// The presentation's author, which is displayed on the title slide.
	author: none,

	// The date, displayed on the title slide.
	date: none,

	// If true, display the total number of slide of the presentation.
	display-lastpage: true,

	// If set, this will be displayed on top of each slide.
	short-title: none,

	// The presentation's content.
	body
) = {
	set document(title: title, author: author)

	set page(
		width: 15cm,
		height: 10cm,
		header: if short-title != none {
			set align(right)
			set text(size: scriptsize)
			short-title
		},
		footer: [
			#let lastpage-number = locate(pos => counter(page).final(pos).at(0))
			#set align(right)
			#text(size: scriptsize)[
				*#counter(page).display("1")* 
				#if (display-lastpage) [\/ #lastpage-number]
			]
			Powered By 
			#link("https://github.com/zrr1999/BoneDocument")[BoneDocument]
		],
	)

	// Display the title page.
	page(background: none, header: none, footer: none)[
		#set align(center+horizon)
		#set text(24pt, weight: "light")
		#title

		#set text(14pt)
		#author

		#text(features: ("case",))[#date]
	]

	show heading.where(level: 1): it => {
		pagebreak()
		align(top, it)
		v(1em)
	}

    set par(
        // justify: true
    )
    set text(
        font: (
        "Hack Nerd Font",
        // "Source Han Sans CN",
        "Source Han Serif SC",
        ), 
        lang: "zh"
    )
	// Add the body.
	body
}