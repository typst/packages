// -----------------------------------------------------------------------------
// SETUP & FUNCTIONS FOR UAS TECHNIKUM WIEN THESIS TEMPLATE
// Author: M. Horauer
// GITHUB: https://github.com/mhorauer/
// LICENSE: GPL-3.0-or-later
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// COLOR defintions matching the UAS TECHNIKUM WIEN LOGO
//
#let twblue = rgb("#00649c")
#let twgreen = rgb("#8BB31D")
#let twgray = rgb("#72777A")

#let DEBUG = ""

// -----------------------------------------------------------------------------
// CONSTANT STRINGS
#let DECLARATION_EN = "“As author and creator of this work to hand, I confirm with my signature knowledge of the relevant copyright regulations governed by higher education acts (see Urheberrechtsgesetz/ Austrian copyright law as amended as well as the Statute on Studies Act Provisions / Examination Regulations of the UAS Technikum Wien as amended).

I hereby declare that I completed the present work independently and according to the rules currently applicable at the UAS Technikum Wien and that any ideas, whether written by others or by myself, have been fully sourced and referenced. I am aware of any consequences I may face on the part of the degree program director if there should be evidence of missing autonomy and independence or evidence of any intent to fraudulently achieve a pass mark for this work (see Statute on Studies Act Provisions / Examination Regulations of the UAS Technikum Wien as amended).

I further declare that up to this date I have not published the work to hand nor have I presented it to another examination board in the same or similar form. I affirm that the version submitted matches the version in the upload tool.”";

#let DECLARATION_DE = "„Ich, als Autor / als Autorin und Urheber / Urheberin der vorliegenden Arbeit, bestätige mit meiner Unterschrift die Kenntnisnahme der einschlägigen urheber- und hochschulrechtlichen Bestimmungen (vgl. Urheberrechtsgesetz idgF sowie Satzungsteil Studienrechtliche Bestimmungen / Prüfungsordnung der FH Technikum Wien idgF).
				
Ich erkläre hiermit, dass ich die vorliegende Arbeit selbständig und nach den aktuell geltenden Regeln der FH Technikum Wien angefertigt und dass ich Gedankengut jeglicher Art aus fremden sowie selbst verfassten Quellen zur Gänze zitiert habe. Ich bin mir bei Nachweis fehlender Eigen- und Selbstständigkeit sowie dem Nachweis eines Vorsatzes zur Erschleichung einer positiven Beurteilung dieser Arbeit der Konsequenzen bewusst, die von der Studiengangsleitung ausgesprochen werden können (vgl. Satzungsteil Studienrechtliche Bestimmungen / Prüfungsordnung der FH Technikum Wien idgF).

Weiters bestätige ich, dass ich die vorliegende Arbeit bis dato nicht veröffentlicht und weder in gleicher noch in ähnlicher Form einer anderen Prüfungsbehörde vorgelegt habe. Ich versichere, dass die abgegebene Version jener im Uploadtool entspricht.“";

// -----------------------------------------------------------------------------
// ---[PAGE SETUP]--------------------------------------------------------------
//
#let uastw-thesis-page-setup(
	body
) = {
	// --- PAGE MARGINS --------------------------------------------------------
	//
	set page(
	  paper: "a4",
	  margin: (left: 2.5cm, top: 4.5cm, right: 2.5cm, bottom: 2cm),
	)
	// --- DEFAULT FONT --------------------------------------------------------
	// standard is ARIAL that is not open-source :-(
	// "Open Sans" is a close open-source match
	//
	set text(font: "Open Sans", 11pt, weight: "regular")
	
	// --- HEADINGS ------------------------------------------------------------
	//
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

	// --- HEADER NUMBERING ----------------------------------------------------
	//
	set heading(numbering: "1.1")
	
	// --- PARAGRAPH SETUP -----------------------------------------------------
	//
	set par(
	  justify: true,
	  leading: 0.8em,
	  first-line-indent: (amount: 0em, all: true),
	  spacing: 1.5em,
	)
	
	// --- LINK STYLING --------------------------------------------------------
	//
	show link: set text(twblue)
	
	// --- RAW TEXT BLOCKS -----------------------------------------------------
	//
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

// -----------------------------------------------------------------------------
// ---[TITLEPAGE SETUP]---------------------------------------------------------
//

#let uastw-thesis-titlepage(
	language: "en", 
	thesis-type: "BACHELOR PAPER", 
	degree: "Bachelor", 
	study-program: "Electronics", 
	thesis-title: "title",
	thesis-subtitle: "",	
	author: "Ing. Max Mustermann", 
	authorid: "123456789", 
	advisor: "Dr. Knowitall", 
	location: "Wien", body
) = {
	[
		// --- COLOR RECTANGLE WITH GRADIENT -----------------------------------
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
		// --- LOGO ------------------------------------------------------------
		#place(top + left, dx: 0cm, dy: 0cm)[
			#box(clip:true, stroke: 4pt + white)[
				#image("logo.svg", width: 20%)
			]
		]
		// --- WEB LINK @RIGHT BOTTOM ------------------------------------------
		#place(bottom + right, dx: -0.5cm, dy: -0.5cm)[
			#text(font: "Open Sans", twgray, 16pt)[
				www.technikum-wien.at
			]
		]
		 
		// --- BACHELOR OR MASTER THESIS ---------------------------------------
		#place(top + left, dx: 1.2cm, dy: 4.5cm)[
			#text(font: "Open Sans", 22pt, weight: "bold")[
				#thesis-type
			]	
		]
		// --- TEXT ABOUT THE DEGREE & STUDY PROGRAM ---------------------------
		#place(top + left, dx: 1.2cm, dy: 5.8cm)[
			#text(font: "Open Sans", 16pt)[
				#set par(leading: 1em)
				#if language == "en" [
					Thesis submitted in fulfillment of the requirements for the \
					degree of #degree of Science in Engineering at the University of\  
					Applied Sciences Technikum Wien - Degree Program \
					#study-program
				] else [
					zur Erlangung des akademischen Grades \
					„#degree of Science in Engineering“ im Studiengang \
					#study-program
				]
			]			
		]
		// --- THESIS TITLE & SUBTITLE -----------------------------------------
		#place(top + left, dx: 1.2cm, dy: 10.8cm)[
			#text(font: "Open Sans", 22pt, weight: "bold")[
				#thesis-title
			]	
		]
		#place(top + left, dx: 1.2cm, dy: 12.8cm)[
			#text(font: "Open Sans", 16pt)[
				#thesis-subtitle
			]	
		]
		// --- AUTHOR, ID, ADVISOR, LOCATION & DATE ----------------------------
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
		// --- SET PDF FILE INFORMATION ----------------------------------------
		#set document(
		  title: thesis-title,
		  author: (author),
		  keywords: (thesis-type),
		  date: auto,
		)		
	]
	body
}

// -----------------------------------------------------------------------------
// ---[DECLARATION PAGE]--------------------------------------------------------
//
#let declaration(
	language: "en", 
	location: "Wien", body
) = {
	[
		// --- PLACE THE STANDARD DECLARATION ----------------------------------
		#place(top + left, dx: 0cm, dy: 1.5cm)[
			#if language == "en" [
				#text(font: "Open Sans", 16pt, twblue, weight: "bold")[
					Declaration of Authenticity 
					#v(1em)
				]
				#set par(justify: true)
				#set text(hyphenate: true)
				#text(font: "Open Sans", 11pt)[					
					#DECLARATION_EN								
					#v(3.5cm)
					#location, #datetime.today().display() #h(6cm) #text(twgray)[_place your digital signature here_]
				]			
			] else [
				#text(font: "Open Sans", 16pt, twblue)[
					Eidesstattliche Erklärung 
					#v(1em)
				]
				#set par(justify: true)
				#set text(hyphenate: true)
				#text(font: "Open Sans", 11pt)[
					#DECLARATION_DE 
					#v(3.5cm)
					#location, #datetime.today().display() #h(6cm) #text(twgray)[_hier die digital Signatur einfügen_]
				]					
			]
		]
	]
	body
}

// -----------------------------------------------------------------------------
// ---[ LaTeX ]-----------------------------------------------------------------
//
#let latex = {
  set text(font: "New Computer Modern")
  let l = "L"
  let a = text(baseline: -0.35em, size: 0.66em, "A")
  let t = "T"
  let e = text(baseline: 0.22em, "E")
  let x = "X"
  
  box(l + h(-0.32em) + a + h(-0.13em) + t + h(-0.14em) + e + h(-0.14em) + x)
}

// -----------------------------------------------------------------------------
// ---[ BibTeX ]----------------------------------------------------------------
//
#let bibtex = {
  set text(font: "New Computer Modern")
  let bib = "Bib"
  let t = "T"
  let e = text(baseline: 0.22em, "E")
  let x = "X"
  
  box(bib + h(-0.13em) + t + h(-0.14em) + e + h(-0.14em) + x)
}

// -----------------------------------------------------------------------------
// ---[ RUST ]------------------------------------------------------------------
//
#let rust = { 
	box(image(
		"rust.svg",
		height: 14pt,
		)+v(-0.3em)
	)
	"Rust"
}

