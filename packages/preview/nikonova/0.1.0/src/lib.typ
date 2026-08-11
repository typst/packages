// SPDX-FileCopyrightText: Copyright (C) 2025 Nile Jocson <atraphaxia@gmail.com>
// SPDX-License-Identifier: 0BSD

#import "@preview/mannot:0.3.0": markhl
#import "@preview/showybox:2.0.4": showybox



#let nikonova-box(
	bg-color: rgb("#182133"),
	fg-color: rgb("#a1e3d2"),
	emph-color: rgb("#e3a1b2"),
	inset: 1.5em,
	radius: 5pt,
	thickness: 1pt,
	title: [],
	body
) = {
	showybox(
		frame: (
			border-color: fg-color,
			title-color: bg-color,
			body-color: bg-color,
			inset: inset,
			radius: radius,
			thickness: thickness
		),
		title-style: (color: emph-color),
		body-style: (color: fg-color),
		title: title
	)[
		#body
	]
}



#let nikonova-title(
	title: "Math 20",
	subtitle: "Review Topics in Algebra",
	subsubtitle: "Notes and Solutions",
	number: "1",
	author: "Nile Jocson",
	email: "atraphaxia@gmail.com",
	bg-color: rgb("#182133"),
	fg-color: rgb("#a1e3d2"),
	emph-color: rgb("#e3a1b2")
) = {
	align(horizon)[
		#nikonova-box(
			bg-color: bg-color,
			fg-color: fg-color,
			emph-color: emph-color,
			inset: 2em,
			title: [
				#text(size: 27pt)[#title]
				#line(length: 100%, stroke: fg-color)
				#text(size: 19pt)[
					#subtitle #h(1fr) #number \
					#text(fill: fg-color)[#subsubtitle]
				]
			]
		)[
			#text(size: 15pt)[
				by #author #link("mailto:" + email)[#raw("<" + email + ">")]
			]
		]
	]
}



#let nikonova-outline(
	bg-color: rgb("#182133"),
	fg-color: rgb("#a1e3d2"),
	emph-color: rgb("#e3a1b2")
) = {
	nikonova-box(
		bg-color: bg-color,
		fg-color: fg-color,
		emph-color: emph-color,
		title: [
			#text(size: 19pt)[Outline]
		]
	)[
		#outline(title: none)
	]
}



#let nikonova(
	title: "Math 20",
	subtitle: "Review Topics in Algebra",
	subsubtitle: "Notes and Solutions",
	number: "1",
	author: "Nile Jocson",
	email: "atraphaxia@gmail.com",
	font: "New Computer Modern",
	bg-color: rgb("#182133"),
	fg-color: rgb("#a1e3d2"),
	emph-color: rgb("#e3a1b2"),
	body
) = {
	set text(
		fill: fg-color,
		font: font
	)

	set page(
		fill: bg-color,
		numbering: "1",
		footer: context [
			#set align(center)
			#set text(fill: emph-color)
			#counter(page).display("1")
		]
	)

	set heading(numbering: "1.1")
	show heading: set text(fill: emph-color)

	nikonova-title(
		title: title,
		subtitle: subtitle,
		subsubtitle: subsubtitle,
		number: number,
		author: author,
		email: email,
		bg-color: bg-color,
		fg-color: fg-color,
		emph-color: emph-color
	)

	pagebreak()

	set outline.entry(fill: none)
	nikonova-outline(
		bg-color: bg-color,
		fg-color: fg-color,
		emph-color: emph-color
	)

	pagebreak()

	body
}



#let nikonova-problem(
	bg-color: rgb("#182133"),
	fg-color: rgb("#a1e3d2"),
	emph-color: rgb("#e3a1b2"),
	numbering: "a.",
	page-break: true,
	question,
	solution
) = {
	nikonova-box(
		bg-color: bg-color,
		fg-color: fg-color,
		emph-color: emph-color,
		radius: 0pt,
		thickness: (left: 1pt),
		title: [
			===
			#text(fill: fg-color)[#question]
		]
	)[
		#set enum(numbering: numbering)
		#solution
	]

	if page-break {
		pagebreak(weak: true)
	}
}



#let nikonova-final(
	body,
	color: rgb("#e3a1b2").darken(50%)
) = {
	markhl(body, color: color)
}
