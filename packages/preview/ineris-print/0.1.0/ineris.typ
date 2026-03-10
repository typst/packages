#import "ineris_common.typ": *

#let todos=state("todos",())

// Todo generation
#let todo(who,what,when)={
	if type(what)=="string" {
		what=upper(what.at(0))+what.slice(1)
	} else if type(what)=="content" {
		what=eval(repr(what).replace(regex("\[."),it=>upper(it.text),count:1))
	}
	todos.update(it=>it+((who,what,when)))
	strong[#who #when : #what]
}

// Internal note template
#let internal-note(
	title: none,
	author: none,
	description: none,
	keywords: (),
	date: datetime.today(),
	cgr: none,
	version: "1",
	subtitle: none,
	sender: none,
	diffusion: none,
	recipient: none,
	cc: none,
	attachments: none,
	doc
) = {
	// Metadata
	set document(title: title, author: author, description: description, keywords:keywords, date:date)

	// Page
	set page(
		footer: context[
			#set align(if calc.rem(counter(page).get().first(), 2) == 0 {left} else {right})
			#set text(size: 0.7em)
			#counter(page).display("1 / 1", both: true)
		],
	)

	_conf([
		// Document heading
		#block(width: 100%, height: 1.7cm, [
			#place(top + left, text(weight: "bold", [Note interne]))
			#place(top + right, image("logo_ineris_bw.svg",width: 20%))
		])
		#v(0.3em)
		#if cgr != none [
			Ineris - CGR-#cgr - v#version\
		]
		#line(length: 100%, stroke: 1.5pt + black)
		#v(0.5em)
		#align(center, [
			#set text(weight: "bold")
			#text(size: 1.4em, title)
			#if subtitle !=none [
				#v(0.8em)
				#text(size: 1.2em, subtitle) 
			]
		])

		#grid(columns: (1fr, 1fr), stroke: (x, y) => if x == 0 {(right: 0.5pt + black, bottom: 1.5pt + black)} else {(bottom: 1.5pt + black)}, inset: 0.5em, [#if sender != none [Entité émettrice : #sender]], [#if diffusion != none [Diffusion : #diffusion]])
		#v(0.5em)
		#grid(columns: (1fr, 1fr), stroke: (x, y) => if x == 0 {(right: 0.5pt + black)} else {(:)}, inset: 0.5em,
			[#if recipient != none [#grid(columns: (auto, 1fr), [Destinataires :#h(1em)], [#recipient])]],
			[#if cc != none [#grid(columns: (auto, 1fr), [Copies :#h(1em)], [#cc])]]
		)
		#v(0.5em)
		#if attachments != none [PJ : #attachments #v(0.5em) ]
		#line(length: 100%, stroke: 1.5pt + black)

		// Generate todo list as a first section
		#context {
			let todolist=todos.final()
			if todolist.len()>0 [
= Suites à donner
				#table(columns: (auto,auto,auto),[Qui ?],[Quoi ?],[Pour quand ?],..(todolist.flatten()))
			]
		}

		#doc
	])
}

// External note template
#let external-note(
	title: none,
	author: none,
	description: none,
	keywords: (),
	date: datetime.today(),
	cgr: none,
	version: "1",
	subtitle: none,
	sender: none,
	recipient: none,
	cc: none,
	attachments: none,
	simplified: false,
	doc
) = {
	// Metadata
	set document(title: title, author: author, description: description, keywords:keywords, date:date)

	// Page
	set page(
		footer: context[
			#set align(if calc.rem(counter(page).get().first(), 2) == 0 {left} else {right})
			#set text(size: 0.7em)
			#counter(page).display("1 / 1", both: true)
		],
	)

	_conf([
		// Document heading
		#block(width: 100%, height: 5mm, [
			#place(top + left, line(length: 100%, stroke: 4mm + palettea))
			#place(top + left, dy: 2mm, line(length: 100%, stroke: 1mm + paletteb))
		])
		#block(width: 100%, height: 1.7cm, [
			#place(top + left, text(weight: "bold", [Note externe]))
			#place(top + right, image("logo_ineris_e.svg",width: 20%))
		])
		#v(0.3em)
		#grid(columns: (1fr, 1fr),[
			#if cgr != none [
				Ineris - CGR-#cgr - v#version\
			]
			], grid.cell(align: right, date.display("[day]/[month]/[year]")))
		#line(length: 100%, stroke: 1.5pt + palettea)
		#if not(simplified) [
			#grid(columns: (1fr, 1fr), stroke: (x, y) => if x == 0 {(right: 0.5pt + palettea, bottom: 1.5pt + palettea)} else {(bottom: 1.5pt + palettea)}, inset: 0.5em, [#if sender != none [Entité émettrice : #sender]], [#if author != none [
				Rédacteur#(if (type(author) == array and author.len() >=2) or (author.contains(",")) [s]) : #if type(author) == array [#author.join(", ")] else [#author]
			]])
		]
		#v(0.5em)
		#align(center, [
			#set text(weight: "bold")
			#text(size: 1.4em, title)
			#if subtitle !=none [
				#v(0.8em)
				#text(size: 1.2em, subtitle) 
			]
		])
		#v(0.5em)
		#if not(simplified) [
			#line(length: 100%, stroke: 1.5pt + palettea)
			#grid(columns: (1fr, 1fr), stroke: (x, y) => if x == 0 {(right: 0.5pt + black)} else {(:)}, inset: 0.5em,
				[#if recipient != none [#grid(columns: (auto, 1fr), [Destinataires :#h(1em)], [#recipient])]],
				[#if cc != none [#grid(columns: (auto, 1fr), [Copies :#h(1em)], [#cc])]]
			)
			#v(0.5em)
			#if attachments != none [PJ : #attachments #v(0.5em) ]
			#line(length: 100%, stroke: 1.5pt + palettea)
		]

		#doc
	])
}

// Internal report template
#let internal-report(
	title: none,
	author: none,
	description: none,
	keywords: (),
	date: datetime.today(),
	cgr: none,
	version: "1",
	subtitle: none,
	sender: none, // Entity who produced the document
	diffusion: none,  // Either "Ineris" or "Confidential"
	recipient: none,  // Entity for which the document was produced
	cc: none, // Copies
	attachments: none,	// List of attachments
	approver: none,	// Who approved the document
	title-image: image("report_background.png", width: 100%, height: 9.3cm, fit:"cover"),  // Image to use for the title
	doc
) = {
	// Metadata
	set document(title: title, author: author, description: description, keywords:keywords, date:date)

	// Page
	set page(
		footer: context[
			#let p = counter(page).get().first()
			#if (p >= 3) {
				set align(if calc.rem(p, 2) == 0 {left} else {right})
				set text(size: 0.7em)
				counter(page).display("1 / 1", both: true)
			}
		],
	)

	_conf([
		// First page
		#page(background: place(top + left, title-image), margin: (top: 10.5cm))[
			#block(width: 100%, height: 1.7cm, [
				#place(top + left, text(weight: "bold", [Rapport interne]))
				#place(top + right, image("logo_ineris_bw.svg",width: 20%))
			])
			#v(0.3em)
			#grid(columns: (1fr, 1fr),[
				#if cgr != none [
					Ineris - CGR-#cgr - v#version\
				]
				], grid.cell(align: right, date.display("[day]/[month]/[year]")))
			#line(length: 100%, stroke: 1.5pt + black)
			#v(0.5em)
			#align(center, [
				#set text(weight: "bold")
				#text(size: 1.4em, title)
				#if subtitle != none [
					#v(0.8em)
					#text(size: 1.2em, subtitle) 
				]
			])

			#grid(columns: (1fr, 1fr), stroke: (x, y) => if x == 0 {(right: 0.5pt + black, bottom: 1.5pt + black)} else {(bottom: 1.5pt + black)}, inset: 0.5em, [#if sender != none [Entité émettrice : #sender]], [#if diffusion != none [Diffusion : #diffusion]])
			#v(0.2em)
			#line(length: 100%, stroke: 1.5pt + black)
			#v(0.3em)
			#grid(columns: (1fr, 1fr), stroke: (x, y) => if x == 0 {(right: 0.5pt + black)} else {(:)}, inset: 0.5em,
				[#if author != none [#grid(columns: (auto, 1fr), [Rédacteur :#h(1em)], [#if type(author) == array [#author.join(", ")] else [#author]])]],
				[#if approver != none [#grid(columns: (auto, 1fr), [Approbation :#h(1em)], [#approver])]],
			)
			#grid(columns: (1fr, 1fr), stroke: (x, y) => if x == 0 {(right: 0.5pt + black)} else {(:)}, inset: 0.5em,
				[#if recipient != none [#grid(columns: (auto, 1fr), [Destinataires :#h(1em)], [#recipient])]],
				[#if cc != none [#grid(columns: (auto, 1fr), [Copies :#h(1em)], [#cc])]]
			)
			#v(0.5em)
			#if attachments != none [PJ : #attachments #v(0.5em) ]
			#line(length: 100%, stroke: 1.5pt + black)
		]

		#pagebreak(weak: true, to: "odd")
		#outline()
		#pagebreak(weak: true, to: "odd")

		#doc
	])
}

// Commercial report template
#let external-report(
	title: none,
	author: none,
	description: none,
	keywords: (),
	date: datetime.today(),
	cgr: none,
	version: "1",
	subtitle: none,
	sender: none, // Departement who produced the document
	recipient: none,  // For who the document was produced
	approver: none,	// Person who approved the document
	readers: none,	// Persons who read and validated the document
	participants: none,	// Persons who took part in the study
	title-image: image("report_background.jpg", width: 100%, height: 9.3cm, fit:"cover"),  // Image to use for the title
	doc
) = {
	// Metadata
	set document(title: title, author: author, description: description, keywords:keywords, date:date)

	// Page
	set page(
		footer: context[
			#let p = counter(page).get().first()
			#if (p >= 3) {
				set align(if calc.rem(p, 2) == 0 {left} else {right})
				set text(size: 0.7em)
				counter(page).display("1 / 1", both: true)
			}
		],
	)

	_conf([
		// First page
		#page(background: [
			#place(top + left, title-image)
			#place(top + left, dy: 9.5cm, line(length: 100%, stroke: 4mm + palettea))
		])[
			#place(top + left, dy: 11cm, dx: 4cm, [
				#block(width: 11cm, height: 9cm, inset: (left: 7mm), stroke: (left: 2pt + paletteb), [
					#if cgr != none [
						Ineris - CGR-#cgr - v#version\
					]
					#align(right, [#date.display("[day]/[month]/[year]")])
					#v(0.6em)
					#text(size: 1.4em, weight: "bold", title)
					#if subtitle != none [
						#v(0.3em)
						#text(size: 1.2em, weight: "bold", subtitle) 
					]
					#v(1fr)
					#align(right, recipient)
				])
			])
			#place(bottom + right, dx: -1cm, dy: -1.5cm, [
				#image("logo_ineris_e.svg", width: 20%)
			])
		]

		#pagebreak()
		#heading(depth:1, outlined: false)[Préambule]
		Le présent document a été établi sur la base des informations transmises à l’Ineris. La responsabilité de l'Ineris ne peut pas être engagée, directement ou indirectement, du fait d’inexactitudes, d’omissions ou d’erreurs ou tous faits équivalents relatifs aux informations fournies. 

		L’exactitude de ce document doit être appréciée en fonction des connaissances disponibles et objectives et, le cas échéant, de la réglementation en vigueur à la date d’établissement du présent document. Par conséquent, l’Ineris ne peut pas être tenu responsable en raison de l’évolution de ces éléments postérieurement à cette date. La prestation ne comporte aucune obligation pour l’Ineris d’actualiser le document après cette date.

		L’établissement du présent document et la prestation associée sont réalisés dans le cadre d’une obligation de moyens.

		Au vu de la mission qui incombe à l'Ineris au titre de l’article R131-36 du Code de l’environnement, celui-ci n’est pas décideur. Ainsi, les avis, recommandations, préconisations ou équivalent qui seraient proposés par l’Ineris dans le cadre de cette prestation ont uniquement pour objectif de conseiller le décideur. Par conséquent la responsabilité de l'Ineris ne peut pas se substituer à celle du décideur qui est donc notamment seul responsable des interprétations qu’il pourrait réaliser sur la base de ce document. Tout destinataire du document utilisera les résultats qui y sont inclus intégralement ou sinon de manière objective. L’utilisation du présent document sous forme d'extraits ou de notes de synthèse s’effectuera également sous la seule et entière responsabilité de ce destinataire. Il en est de même pour toute autre modification qui y serait apportée. L'Ineris dégage également toute responsabilité pour toute utilisation du document en dehors de son objet.

		En cas de contradiction entre les conditions générales de vente et les stipulations du présent préambule, les stipulations du présent préambule prévalent sur les stipulations des conditions générales de vente.

		#v(1fr)

		#if sender != none [Nom de la direction en charge du rapport : #sender\ ]
		#if author != none [
			#if (type(author) == array and author.len >= 2) or author.contains(",") [Rédacteurs :] else [Rédacteur :]
			#if type(author) == array [#author.join(", ")\ ] else [#author\ ]
		]
		#if readers != none [Vérification : #readers\ ]
		#if approver != none [Approbation : #approver\ ]
		#if participants != none [Participation à l'étude : #participants\ ]

		#pagebreak(weak: true)
		#outline()
		#pagebreak(weak: true, to: "odd")
		#counter(heading).update(0)

		#doc
	])
}

// Appendix
#let appendix(doc) = {
	set heading(
		supplement: "Annexe ",
		numbering: (..nums) => if nums.pos().len()==1 { "Annexe " + numbering("A.", ..nums)} else {numbering("A.1.a.", ..nums)}
	)
	context counter(heading).update(0)
	pagebreak(weak: true)
	doc
}
