// by M. Horauer
#let twblue = rgb("#00689e")
#let twgreen = rgb("#8bb111")
#let twgray = rgb("#777777")
#let lightgray = rgb("EEEEEE")

#let uastw_thesis_setup(body) = {
	set page(
	  paper: "a4",
	  margin: (left: 2.5cm, top: 4.5cm, right: 2.5cm, bottom: 2cm),
	)
	set text(font: "Open Sans", 11pt, weight: "regular")
	show heading.where(level: 1): it => {
	  colbreak(weak: true)
	  v(32pt)
	  it
	  v(16pt)
	}
	show heading.where(level: 1): set text(size: 24pt, twblue)
	show heading.where(level: 2): set text(size: 18pt, twblue)
	show heading.where(level: 3): set text(size: 14pt, twblue)	
	show heading.where(level: 4): set text(size: 12pt, twblue)	
	set par(
	  justify: true,
	  leading: 0.8em,
	  first-line-indent: (amount: 0em, all: true),
	  spacing: 1em,
	)
	show link: set text(twblue)
	set heading(numbering: "1.1")
	show raw.where(block: true): it => block(
		inset: 10pt,
		radius: 4pt,
		stroke: 1pt + twgreen,
		width: 100%,
		it
	)
	show raw: set text(size: 8pt)	
	body
}



#let uastw_thesis_titlepage_func(language: "en", 
	thesisType: "BACHELOR PAPER", degree: "Bachelor", 
	study_program: "Electronics", thesisTitle: "title",
	thesisSubTitle: "",	author: "Ing. Max Mustermann", 
	authorid: "123456789", advisor: "Dr. Knowitall", 
	location: "Wien", body) = {
	[
		#set page(
		  paper: "a4",
		  margin: (left: 1cm, top: 1cm, right: 1cm, bottom: 1cm),
		)
		#place(top + left, dx: 0cm, dy: 0cm)[
			#rect(width: 19cm, height: 27.6cm, fill: none, 
				  stroke: 3pt + gradient.linear(angle: 0deg,	
					      (twblue, 0%), (twgreen, 50%), 
					      (twgreen, 75%), (twgreen, 100%)))
		]

		#place(top + left, dx: 0cm, dy: 0cm)[
			#box(clip:true, stroke: 4pt + white)[
				#image("logo.svg", width: 20%)
			]
		]

		#place(bottom + right, dx: -0.5cm, dy: -0.5cm)[
			#text(font: "Open Sans", twgray, 16pt)[
				www.technikum-wien.at
			]
		]	
		#place(top + left, dx: 1.2cm, dy: 4.5cm)[
			#text(font: "Open Sans", 22pt, weight: "bold")[
				#thesisType
			]	
		]
		#place(top + left, dx: 1.2cm, dy: 5.8cm)[
			#text(font: "Open Sans", 16pt)[
				#set par(leading: 1em)
				#if language == "en" [
					Thesis submitted in fulfillment of the requirements for the \
					degree of #degree of Science in Engineering at the University of\  
					Applied Sciences Technikum Wien - Degree Program \
					#study_program
				] else [
					zur Erlangung des akademischen Grades \
					„#degree of Science in Engineering“ im Studiengang \
					#study_program
				]
			]			
		]
		#place(top + left, dx: 1.2cm, dy: 10.8cm)[
			#text(font: "Open Sans", 22pt, weight: "bold")[
				#thesisTitle
			]	
		]
		#place(top + left, dx: 1.2cm, dy: 12.8cm)[
			#text(font: "Open Sans", 16pt)[
				#thesisSubTitle
			]	
		]
		#place(top + left, dx: 1.2cm, dy: 14.8cm)[
			#text(font: "Open Sans", 16pt)[
				#set par(leading: 1em)
				#if language == "en" [
					By: #author \
					Student Number: #authorid \ #v(1.5em)
					Supervisor: #advisor \ #v(1.5em)
					#location, #datetime.today().display()
				] else [
					Ausgeführt von: #author \
					Personenkennzeichen: #authorid \ #v(1.5em)
					BegutachterIn: #advisor \ #v(1.5em)
					#location, #datetime.today().display()
				]
			]			
		]
		#set document(
		  title: thesisTitle,
		  author: (author),
		  keywords: (thesisType),
		  date: auto,
		)		
	]
	body
}

#let declaration(language: "en", location: "Wien", body) = {
	[
		#place(top + left, dx: 0cm, dy: 1.5cm)[
			#if language == "en" [
				#text(font: "Open Sans", 16pt, twblue, weight: "bold")[
					Declaration of Authenticity \ #v(1em)
				]
				#set par(justify: true)
				#set text(hyphenate: true)
				#text(font: "Open Sans", 11pt)[
					“As author and creator of this work to hand, I confirm with my signature knowledge of the relevant copyright regulations governed by higher education acts (see Urheberrechtsgesetz/ Austrian copyright law as amended as well as the Statute on Studies Act Provisions / Examination Regulations of the UAS Technikum Wien as amended).

				I hereby declare that I completed the present work independently and according to the rules currently applicable at the UAS Technikum Wien and that any ideas, whether written by others or by myself, have been fully sourced and referenced. I am aware of any consequences I may face on the part of the degree program director if there should be evidence of missing autonomy and independence or evidence of any intent to fraudulently achieve a pass mark for this work (see Statute on Studies Act Provisions / Examination Regulations of the UAS Technikum Wien as amended).

				I further declare that up to this date I have not published the work to hand nor have I presented it to another examination board in the same or similar form. I affirm that the version submitted matches the version in the upload tool.” \ #v(3.5cm)
				#location, #datetime.today().display() #h(6cm) #text(twgray)[_place your digital signature here_]
				]			
			] else [
				#text(font: "Open Sans", 16pt, twblue)[
					Eidesstattliche Erklärung
				]
				#set par(justify: true)
				#set text(hyphenate: true)
				#text(font: "Open Sans", 11pt)[
				„Ich, als Autor / als Autorin und Urheber / Urheberin der vorliegenden Arbeit, bestätige mit meiner Unterschrift die Kenntnisnahme der einschlägigen urheber- und hochschulrechtlichen Bestimmungen (vgl. Urheberrechtsgesetz idgF sowie Satzungsteil Studienrechtliche Bestimmungen / Prüfungsordnung der FH Technikum Wien idgF).
				
Ich erkläre hiermit, dass ich die vorliegende Arbeit selbständig und nach den aktuell geltenden Regeln der FH Technikum Wien angefertigt und dass ich Gedankengut jeglicher Art aus fremden sowie selbst verfassten Quellen zur Gänze zitiert habe. Ich bin mir bei Nachweis fehlender Eigen- und Selbstständigkeit sowie dem Nachweis eines Vorsatzes zur Erschleichung einer positiven Beurteilung dieser Arbeit der Konsequenzen bewusst, die von der Studiengangsleitung ausgesprochen werden können (vgl. Satzungsteil Studienrechtliche Bestimmungen / Prüfungsordnung der FH Technikum Wien idgF).

Weiters bestätige ich, dass ich die vorliegende Arbeit bis dato nicht veröffentlicht und weder in gleicher noch in ähnlicher Form einer anderen Prüfungsbehörde vorgelegt habe. Ich versichere, dass die abgegebene Version jener im Uploadtool entspricht.“
\ #v(3.5cm)
				#location, #datetime.today().display() #h(6cm) #text(twgray)[_hier die digital Signatur einfügen_]
				]					
			]
		]
	]
	body
}

#let LaTeX = {
  set text(font: "New Computer Modern")
  let l = "L"
  let a = text(baseline: -0.35em, size: 0.66em, "A")
  let t = "T"
  let e = text(baseline: 0.22em, "E")
  let x = "X"
  
  box(l + h(-0.32em) + a + h(-0.13em) + t + h(-0.14em) + e + h(-0.14em) + x)
}

#let BibTeX = {
  set text(font: "New Computer Modern")
  let bib = "Bib"
  let t = "T"
  let e = text(baseline: 0.22em, "E")
  let x = "X"
  
  box(bib + h(-0.13em) + t + h(-0.14em) + e + h(-0.14em) + x)
}

#let Rust = { 
	box(image(
		"rust.svg",
		height: 14pt,
		)+v(-0.3em)
	)
	"Rust"
}
