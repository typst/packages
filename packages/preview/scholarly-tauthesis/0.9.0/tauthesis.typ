/** tauthesis.typ
 *
 * This module defines the Tampere University thesis template structure. You
 * should not need to touch this file. Define your own commands in preamble.typ
 * instead.
 *
***/

//// Counters and kinds

#let IMAGECOUNTER = counter("IMAGE")

#let TABLECOUNTER = counter("TABLE")

#let CODECOUNTER = counter("CODE")

#let TAUTHEOREMCOUNTER = counter("tautheorem")

#let EQUATIONCOUNTER = counter("EQUATION")

#let TAUTHEOREMKIND = "TAUTHEOREMKIND"

#let EQNUMDEPTHSTATE = state("EQNUMDEPTHSTATE", 1)

#let FIGNUMDEPTHSTATE = state("FIGNUMDEPTHSTATE", 1)

#let PREFACEPAGENUMBERCOUNTER = counter("PREFACEPAGENUMBERCOUNTER")

#let MAINMATTERPAGENUMBERCOUNTER = counter("MAINMATTERPAGENUMBERCOUNTER")

#let BINDINGPAGELIMIT = 79

/** DOCPARTSTATE
 *
 * An integer which keeps track of which part of the document we are in. The
 * integers denote the following thing:
 *
 * 0 ↦ initial state
 * 1 ↦ title page
 * 2 ↦ document preamble
 * 3 ↦ main matter
 * 4 ↦ bibliography
 * 5 ↦ appendix
 *
***/

#let INITIALPART = 0
#let TITLEPAGEPART = 1
#let DOCPREAMBLEPART = 2
#let MAINMATTERPART = 3
#let BIBLIOGRAPHYPART = 4
#let APPENDIXPART = 5

#let DOCPARTSTATE = state("DOCPARTSTATE", INITIALPART)

//// Constants

#let templatename = "tauthesis"

#let tunipurple = rgb(78,0,148)

#let tunifontsize = 12pt

#let tunicodefontsize = 10pt

#let finnish = "fi"

#let english = "en"

#let headingsep = 2 * " "

#let tunicodeblockinset = 0.5em

#let codeSupplementFn(language) = {
	if language == finnish {
		[Listaus]
	} else {
		[Listing]
	}
}

#let appendixPrefixFn(language) = {
  if language == finnish {
    [Liite ]
  } else {
    [Appendix ]
  }
}

//// Utility functions

// This function will give Finnish month names by month numbers.
// https://typst.app/docs/reference/foundations/datetime/
// Unfortunately, when choosing the word representation, it can
// currently only display the English version. In the future, it is
// planned to support localization.
#let localize_month_fi(month) = {
	if month < 1 or month > 12 {
		panic("Month must be between [1,12]")
	}
	if month == 1 {
		return "Tammikuu"
	} else if month == 2 {
		return "Helmikuu"
	} else if month == 3 {
		return "Maaliskuu"
	} else if month == 4 {
		return "Huhtikuu"
	} else if month == 5 {
		return "Toukokuu"
	} else if month == 6 {
		return "Kesäkuu"
	} else if month == 7 {
		return "Heinäkuu"
	} else if month == 8 {
		return "Elokuu"
	} else if month == 9 {
		return "Syyskuu"
	} else if month == 10 {
		return "Lokakuu"
	} else if month == 11 {
		return "Marraskuu"
	} else if month == 12 {
		return "Joulukuu"
	} else {
		return "<Parametrina ollut numero ei ole kuukausi>"
	}
}

#let localize_month_fi_partitive(month) = {
	if month < 1 or month > 12 {
		panic("Month must be between [1,12]")
	}
	if month == 1 {
		return "tammikuuta"
	} else if month == 2 {
		return "helmikuuta"
	} else if month == 3 {
		return "maaliskuuta"
	} else if month == 4 {
		return "huhtikuuta"
	} else if month == 5 {
		return "toukokuuta"
	} else if month == 6 {
		return "kesäkuuta"
	} else if month == 7 {
		return "heinäkuuta"
	} else if month == 8 {
		return "elokuuta"
	} else if month == 9 {
		return "syyskuuta"
	} else if month == 10 {
		return "lokakuuta"
	} else if month == 11 {
		return "marraskuuta"
	} else if month == 12 {
		return "joulukuuta"
	} else {
		return "<Parametrina ollut numero ei ole kuukausi>"
	}
}

/**
 *
 * Converts a given integer into a letter that might be used in
 * appendix numbering.
 *
***/

#let int2appendixletter(ii) = {
	let Acodepoint = 65
	let Zcodepoint = 90
	let letterrangelen = Zcodepoint - Acodepoint
	let nnquo = calc.quo( ii, letterrangelen )
	let nnrem = calc.rem( ii, letterrangelen )
	let letter = str.from-unicode( Acodepoint + nnrem - 1 )
	let string = letter
	let counter = 0
	while counter < nnquo { string + letter }
	string
}

/**
 *
 * When given an array of integers, returns a string that might be
 * used as a section number.
 *
***/

#let array2sectionnumbering(arr, inappendix) = {
	if arr.len() < 1 { panic("Arrays of zero length cannot be used to construct a section number string. Reveived " + arr.map(str).join(",") ) }
	if not ( arr.all( elem => type(elem) == int ) ) { panic("Array elements used to construct section numberings need to contain integers.") }
	let firstnum = arr.first()
	let chaptersymbol = if inappendix {
		int2appendixletter(firstnum)
	} else {
		str(firstnum)
	}
	let rest = arr.slice(1).map(str)
	let symbols = (chaptersymbol, ..rest)
	symbols.join(".")
}

/**
 *
 * Displays the AI disclaimer page, where students explain where and how they
 * used AI in producing their thesis, if they did.
 *
 ***/
#let aiDisclaimerPage(usedAI,language, tekoälynKäyttöTeksti, aiDisclaimerContents) = [

	#if language == finnish [

		= Tekoälyn käyttö tässä työssä

		Opinnäytteessäni on käytetty tekoälysovelluksia:

		#if usedAI [
			#h(1em, weak:false) #sym.ballot.cross Kyllä\
			#h(1em, weak:false) #sym.ballot Ei
		] else [
			#h(1em, weak:false) #sym.ballot   Kyllä\
			#h(1em, weak:false) #sym.ballot.cross Ei
		]

		#if usedAI {
			tekoälynKäyttöTeksti
		}

		== Riskien tiedostaminen

		Olen tietoinen siitä, että olen täysin vastuussa koko opinnäytteeni
		sisällöstä, mukaan lukien osat, joiden tuottamisessa on hyödynnetty
		tekoälyä, ja hyväksyn vastuun mahdollisista tästä seuranneista
		eettisten ohjeiden rikkomuksista.


	] else [

		= Use of artificial intellingence in this work

		Artificial intelligence (AI) has been used in generating this work:

		#if usedAI [
			#h(1em, weak:false) #sym.ballot.cross Yes\
			#h(1em, weak:false) #sym.ballot   No
		] else [
			#h(1em, weak:false) #sym.ballot   Yes\
			#h(1em, weak:false) #sym.ballot.cross No
		]

		#if usedAI {
			aiDisclaimerContents
		}

		== Acknowledgement of risks

		I hereby acknowledge, that as the author of this work, I am fully
		responsible for the contents presented in this thesis. This includes
		the parts that were generated by an AI, in part or in their entirety. I
		therefore also acknowledge my responsibility in the case, where use of
		AI has resulted in ethical guidelines being breached.


	]
]

/**
 *
 * Defines how a cross-reference within a document is laid out.
 *
***/

#let refshowrule(it, language, eqnumberwithinlevel : 1) = {

  let codesupplement = codeSupplementFn(language)

  let appendixprefix = appendixPrefixFn(language)

	set text( fill: tunipurple )
	let el = it.element
	if el != none {
		let eloc = el.location()
		let headingctr = counter(heading).at(eloc)
		let docpart = DOCPARTSTATE.at(eloc)
		let inappendix = docpart == APPENDIXPART
		if el.func() == figure {
			let (carray, supplement) = if el.body.func() == image {
				(IMAGECOUNTER.at(eloc), el.supplement)
			} else if el.body.func() == table {
				(TABLECOUNTER.at(eloc), el.supplement)
			} else if el.body.func() == raw {
				(CODECOUNTER.at(eloc), codesupplement)
			} else if el.kind == TAUTHEOREMKIND {
				(TAUTHEOREMCOUNTER.at(eloc), el.supplement)
			} else {
				(none, none)
			}
			let supplement = if it.citation.supplement != none { it.supplement } else { supplement }
			carray.last() += 1
			link(eloc,text(fill:tunipurple)[*#supplement #array2sectionnumbering(carray,inappendix)*])
		}
		else if el.func() == heading {
			let ctr = counter(heading).at(eloc)
			let prefix = if it.citation.supplement == none and el.level == 1 and inappendix {
				appendixprefix
			} else if it.citation.supplement != none {
				[#it.supplement ]
			} else {
				[]
			}
			link(
				eloc
			)[
				*#text(
					fill : tunipurple,
				)[
					#prefix#array2sectionnumbering(ctr, inappendix)
				]*
			]
		}
		else if el.func() == math.equation {
			let numdepth = EQNUMDEPTHSTATE.at(eloc)
			let headctr = EQUATIONCOUNTER.at(eloc)
			let headctr = headctr.slice(0,calc.min(headctr.len(),numdepth))
			let eqctr = counter(math.equation).at(eloc)
			headctr.push( eqctr.last() )
			link(
				eloc,
				text(fill:tunipurple)[$(array2sectionnumbering(headctr, inappendix))$]
			)
		}
		else {
			it
		}
	}
	else {
		it
	}
}

/**
 *
 * Defines how figures given as argument are laid out in the document. Also
 * updates counters related to numbering figures.
 *
***/

#let figshowrule(language,it) = {
	let codesupplement = codeSupplementFn(language)
	let figloc = it.location()
	let docpart = DOCPARTSTATE.at(figloc)
	let inappendix = docpart == APPENDIXPART
	block(
		breakable : false,
		if it.kind == image {
			IMAGECOUNTER.update( (..args) => {
				let argsarr = args.pos()
				argsarr.last() +=  1
				argsarr
			} )
			let ctr = IMAGECOUNTER.at(figloc)
			ctr.last() += 1
			align( center )[
				#block(it.body)
				#block[
					#text( fill:tunipurple)[*#it.supplement #array2sectionnumbering(ctr,inappendix):* ]
					#it.caption.body
				]
			]
		}
		else if it.kind == table {
			set figure.caption ( position : top )
			TABLECOUNTER.update( (..args) => {
				let argsarr = args.pos()
				argsarr.last() += 1
				argsarr
			} )
			let ctr = TABLECOUNTER.at(figloc)
			ctr.last() += 1
			align( center )[
				#block[
					#text( fill:tunipurple)[*#it.supplement #array2sectionnumbering(ctr,inappendix):* ]
					#it.caption.body
				]
				#block(it.body)
			]
		}
		else if it.kind == raw {
			set figure.caption ( position : top )
			CODECOUNTER.update( (..args) => {
				let argsarr = args.pos()
				argsarr.last() += 1
				argsarr
			} )
			let ctr = CODECOUNTER.at(figloc)
			ctr.last() += 1
			align( center )[
				#block[
					#text( fill:tunipurple)[*#codesupplement #array2sectionnumbering(ctr,inappendix):* ]
					#it.caption.body
				]
			]
			block(it.body)
		}
		else if it.kind == TAUTHEOREMKIND {
			TAUTHEOREMCOUNTER.update( (..args) => {
				let argsarr = args.pos()
				argsarr.last() += 1
				argsarr
			} )
			it
		}
		else { it }
	)
}

/**
 *
 * Defines how headings are displayed. Also updates counters related to
 * numbering figures and equations.
 *
***/

#let headingshowrule(language, it) = [

	#let appendixprefix = appendixPrefixFn(language)

	#if it.level == 1 {
		pagebreak(weak: true)
	}
	#let eqnumberwithinlevel = EQNUMDEPTHSTATE.get()
	#let fignumberwithinlevel = FIGNUMDEPTHSTATE.get()
	#let counterlistlen = fignumberwithinlevel + 1
	#let followingheadings = query( heading.where(outlined : true).after(here()))
	#let followingheading = followingheadings.at(0, default: none)
	#let fhloc = if followingheading != none {
		followingheading.location()
	} else {
		here()
	}
	#if it.level <= eqnumberwithinlevel and it.outlined {
		counter(math.equation).update( 0 )
		let ctr = counter(heading).at(fhloc)
		let minlen = calc.min(ctr.len(),eqnumberwithinlevel)
		EQUATIONCOUNTER.update( ctr.slice(0,minlen) )
	}
	#if it.outlined and it.level <= counterlistlen {
		IMAGECOUNTER.update( (..args) => {
			let argsarr = args.pos()
			argsarr.at(it.level - 1) += 1
			argsarr.last() = 0
			argsarr
		} )
		TABLECOUNTER.update( (..args) => {
			let argsarr = args.pos()
			argsarr.at(it.level - 1) += 1
			argsarr.last() = 0
			argsarr
		} )
		CODECOUNTER.update( (..args) => {
			let argsarr = args.pos()
			argsarr.at(it.level - 1) += 1
			argsarr.last() = 0
			argsarr
		} )
		TAUTHEOREMCOUNTER.update( (..args) => {
			let argsarr = args.pos()
			argsarr.at(it.level - 1) += 1
			argsarr.last() = 0
			argsarr
		} )
	}
	#let docpart = DOCPARTSTATE.get()
	#let inappendix = docpart == APPENDIXPART
	#let inbibliography = docpart == BIBLIOGRAPHYPART
	#let (textsize, headspacing) = if it.level == 1 {
		(21pt, 42pt)
	} else if it.level == 2 {
		(17pt, 18pt)
	} else if it.level == 3 or it.level == 4 {
		(13pt, 18pt)
	}
	#set text( size : textsize )
	#block(
		above: headspacing,
		below: headspacing,
		[
			#let prefix = if it.level == 1 and inappendix {
				appendixprefix
			} else {
				[]
			}
			#prefix
			#if it.outlined {
				if it.level == 1 and inappendix {
					counter(heading).display("A.1:")
				}
				else if inappendix {
					counter(heading).display("A.1")
				}
				else if inbibliography {
					[]
				}
				else {
					counter(heading).display()
				}
			}
			#smallcaps( it.body )
		]
	)
]

/**
 *
 * Defines how outline entries are to be displayed. This is to be used within a
 * show rule, so that context and therefore information about page numbers and
 * such can be resolved.
 *
***/

#let outlineentryshowrule(language, it) = {
	let codesupplement = codeSupplementFn(language)
	let appendixprefix = appendixPrefixFn(language)
	set text( size : 13pt )
	let el = it.element
	let eloc = el.location()
	let elpagenum = MAINMATTERPAGENUMBERCOUNTER.at(eloc).first() - 1
	let docpart = DOCPARTSTATE.at(eloc)
	let inappendix = docpart == APPENDIXPART
	let inbibliography = docpart == BIBLIOGRAPHYPART
	if el.func() == figure {
		let (carray, supplement) = if el.body.func() == image {
			(IMAGECOUNTER.at(eloc), el.supplement)
		} else if el.body.func() == table {
			(TABLECOUNTER.at(eloc), el.supplement)
		} else if el.body.func() == raw {
			(CODECOUNTER.at(eloc), codesupplement)
		} else if el.kind == TAUTHEOREMKIND {
			(TAUTHEOREMCOUNTER.at(eloc), el.supplement)
		} else {
			(none, none)
		}
		if carray != none {
			carray.last() += 1
			link(
				eloc,
				[
					#text(fill:tunipurple)[*#supplement #array2sectionnumbering(carray, inappendix):*]
					#set text( fill : black )
					#el.caption.body
					#box(width:1fr,repeat[.])
					#elpagenum
				]
			)
		} else {
			it
		}
	} else if el.func() == heading {
		let tsize = if el.level == 1 { 14pt } else if el.level == 2 { 13pt } else if el.level == 3 { 12pt } else { 11pt }
		let ctr = counter(heading).at(eloc)
		let (prefix, numbering, colon, bodycolor, bodyweight) = if inappendix {
			if el.level == 1 {
				(appendixprefix, array2sectionnumbering(ctr, inappendix), ":", black, "regular")
			} else {
				([], array2sectionnumbering(ctr, inappendix), [], black, "regular")
			}
		} else if inbibliography {
			([],[],[], tunipurple, "bold")
		} else {
			([], array2sectionnumbering(ctr, inappendix), [], black, "regular")
		}
		smallcaps(
			link(
				eloc
			)[
				*#text(
					fill : tunipurple,
					size : tsize,
				)[
					#prefix
					#numbering#colon
				]*
				#text(
					fill:bodycolor,
					weight:bodyweight,
					size:tsize,
				)[
					#el.body
				]
				#text(
					fill:black,
				)[
					#box(width:1fr,repeat[.])
					#elpagenum
				]
			]
		)
	} else {
		it
	}
}

/**
 *
 * Defines the look of the title page, and returns the content related to it.
 *
***/

#let titlepage(
	author,
	title,
	subtitle,
	university,
	faculty,
	thesistype,
	otsikko,
	alaotsikko,
	koulu,
	tiedekunta,
	työntyyppi,
	language,
	examiners,
	doc
) = {

	let date = datetime.today()

	let examinerprefix = if language == finnish {
		"Tarkastaja"
	} else {
		"Examiner"
	}

	set page(
		paper: "a4",
		header: none,
		footer: none,
		margin: (left: 4cm, top: 4.5cm,),
		numbering: none,
	)

	place(top + left, float:true, dx: -2cm, dy:-2cm, image("template/images/tau-logo-fin-eng.svg", width : 8cm))

	align(right)[
		#text(
			20pt,
			author
		)
		#v(1cm, weak: true)
		#set par( leading : 0.4em )
		#text(
			35pt,
			fill: tunipurple,
			smallcaps(
				if language == finnish {
					otsikko
				} else if language == english {
					title
				}
			)
		)
		#v(0.9cm, weak: true)
		#text(
			20pt,
			fill: tunipurple,
			smallcaps(
				if language == finnish {
					alaotsikko
				} else if language == english {
					subtitle
				}
			)
		)
		#v(1fr)
		#set par( leading : 0.65em )
		#text(
			12pt,
			[
				#if language == english [
					#thesistype\
					#university\
					#faculty
				] else if language == finnish [
					#työntyyppi\
					#koulu\
					#tiedekunta
				]\
				#examiners.map(value => examinerprefix + ": " + value.title + " " + value.firstname + " " + value.lastname).join("\n")\
				#if language == english [
					#date.display("[month repr:long] [year]")
				] else if language == finnish [
					#localize_month_fi(date.month()) #date.year()
				]
			]
		)
	]
	doc
}

/**
 *
 * Defines the structure and look of Tampere University thesis
 * abstract.
 *
***/

#let abstract(
	author,
	title,
	subtitle,
	university,
	faculty,
	thesistype,
	keywords,
	otsikko,
	alaotsikko,
	koulu,
	tiedekunta,
	työntyyppi,
	avainsanat,
	content,
	language
) = [

	#let date = datetime.today()

	#set text(size:10pt)

	#let checkSubtitleFn = (subtitle) => {
		if subtitle == none []
		else if type(subtitle) in ("content","str") [: #subtitle ]
		else [ #panic("The subtitle of a thesis needs to be enclosed in […] or \"…\", or be equal to none") ]
	}

	#if language == english [

		= Abstract <abstract>

		#author\
		#title#checkSubtitleFn(subtitle)\
		#university\
		#faculty\
		#thesistype\
		#date.display("[month repr:long] [year]")\

	] else if language == finnish [

		= Tiivistelmä <tiivistelmä>

		#author\
		#otsikko#checkSubtitleFn(alaotsikko)\
		#koulu\
		#tiedekunta\
		#työntyyppi\
		#localize_month_fi(date.month()) #date.year()\
	]

	#line(
		length: 100%,
		stroke: 2pt + tunipurple,
	)

	#content

	#if language == finnish [

		*Avainsanat:* #avainsanat.join(", ")

		Tämän julkaisun alkuperäisyys on tarkastettu Turnitin OriginalityCheck -ohjelmalla.

	] else [

		*Keywords:* #keywords.join(", ")

		The originality of this thesis has been checked using the Turnitin OriginalityCheck service.

	]

]

/**
 *
 * Typesets the preface of this thesis.
 *
***/

#let preface(author, language, prefaceContents, sijainti, location) = {

	let date = datetime.today()

	if language == finnish [

		= Alkusanat

		#prefaceContents

		sijainti #date.day().
		#localize_month_fi_partitive(date.month())
		#date.year(),\
		author

	] else [

		= Preface

		#prefaceContents

		In #location on #date.day(). #date.display("[month repr:long] [year]"),\
		#author

	]
}

/**
 *
 * Typesets the glossary based on the file content/glossary.typ.
 *
***/
#let glossary(language, glossaryDict) = {

	set rect(
		inset: 0pt,
		fill: none,
		stroke: none,
		width: 100%,
	)

	if language == finnish [
		= Lyhenteet ja merkinnät
	] else [
		= Glossary
	]

	set text( size : 12pt )

	stack(
		dir: ttb,
		for key in glossaryDict.keys().sorted() {
			let name = glossaryDict.at(key).name
			let description = glossaryDict.at(key).description
			stack(
				dir: ltr,
				spacing : 5%,
				rect(width: 20%)[
					#set text(fill:tunipurple)
					*#align(left,name)*
				],
				rect(width: 75%)[#description]
			)
		}
	)


}

/**
 *
 * Defines the basic shape of Tampere University mathematics theorem blocks.
 * Below are also defined some common mathematical theorem blocks.
 *
 **/

#let tautheoremblock(
	fill: rgb("#ffffff"),
	supplement: [TAUTheoremBlock],
	title: [],
	reflabel: "",
	content
) = context {
	let docpart = DOCPARTSTATE.get()
	let inappendix = docpart == APPENDIXPART
	let ctr = TAUTHEOREMCOUNTER.get()
	ctr.last() += 1
	[
		#figure(
			kind: TAUTHEOREMKIND,
			supplement: supplement,
			block(
				fill: fill,
				inset: 8pt,
				radius: 4pt,
				stroke: tunipurple,
				width: 100%,
				breakable: true,
				align(
					left,
					[
						#text(weight: "bold", fill: tunipurple, [#supplement #array2sectionnumbering(ctr,inappendix)])
						// Content converted to string with repr always has a lenght ≥ 2.
						#if repr(title).len() > 2 [
							(#text(weight: "bold", fill: tunipurple, title))
						]
						#content
					],
				)
			)
		)
		#if reflabel.len() > 0 { label(reflabel) }
	]
}

#let definition(title: "", reflabel: "", content) = tautheoremblock(
	supplement: "Definition",
	reflabel: reflabel,
	title: title,
	content
)

#let lemma(title: "", reflabel: "", content) = tautheoremblock(
	supplement: "Lemma",
	reflabel: reflabel,
	title: title,
	content
)

#let theorem(title: "", reflabel: "", content) = tautheoremblock(
	supplement: "Theorem",
	reflabel: reflabel,
	title: title,
	content
)

#let corollary(title: "", reflabel: "", content) = tautheoremblock(
	supplement: "Corollary",
	reflabel: reflabel,
	title: title,
	content
)

#let example(title: "", reflabel: "", content) = tautheoremblock(
	supplement: "Example",
	reflabel: reflabel,
	title: title,
	content
)

#let määritelmä(title: "", reflabel: "", content) = tautheoremblock(
	supplement: "Määritelmä",
	reflabel: reflabel,
	title: title,
	content
)

#let apulause(title: "", reflabel: "", content) = tautheoremblock(
	supplement: "Apulause",
	reflabel: reflabel,
	title: title,
	content
)

#let lause(title: "", reflabel: "", content) = tautheoremblock(
	supplement: "Lause",
	reflabel: reflabel,
	title: title,
	content
)

#let seurauslause(title: "", reflabel: "", content) = tautheoremblock(
	supplement: "Seurauslause",
	reflabel: reflabel,
	title: title,
	content
)

#let esimerkki(title: "", reflabel: "", content) = tautheoremblock(
	supplement: "Esimerkki",
	reflabel: reflabel,
	title: title,
	content
)

/**
 *
 * Defines page dimensions in the main matter.
 *
***/
#let pagesettings(docpart, physically-printed, it) = context {
	let finalpagenumber = MAINMATTERPAGENUMBERCOUNTER.final().last()
	let prevdocpart = docpart - 1
	set page(
		numbering: none,
		number-align: right + top,
		binding : {
			let docpagenum = counter(page).get().last() + 1
			if finalpagenumber > BINDINGPAGELIMIT and physically-printed {
				if calc.rem(docpagenum,2) == 0 {
					right
				} else {
					left
				}
			} else {
				left
			}
		},
		header: context {
			if docpart == DOCPREAMBLEPART {
				PREFACEPAGENUMBERCOUNTER.step()
			}
			if docpart >= MAINMATTERPART {
				MAINMATTERPAGENUMBERCOUNTER.step()
			}
			let (pagenum, numberingstr) = {
				if docpart in (TITLEPAGEPART, DOCPREAMBLEPART) {
					(PREFACEPAGENUMBERCOUNTER.get().first(),"i")
				}
				else if docpart >= MAINMATTERPART {
					(MAINMATTERPAGENUMBERCOUNTER.get().first(),"1")
				}
				else {
					(none,"")
				}
			}
			let headings_before = query(
				heading.where(level: 1).and(
					heading.where(outlined: true)
				).before(here())
			)
			let headings_after = query(
				heading.where(outlined: true).after(here()),
			)
			let lastheadbefore = headings_before.at(-1, default: none)
			let firstheadafter = headings_after.at(0, default: none)
			let currentpage = here().page()
			// Display current chapter title in left header, if we have
			// moved past the chapter start page. Lower level section
			// titles are not displayed.
			let innertext = box(
				if lastheadbefore != none {
					let lastpagebefore = lastheadbefore.location().page()
					let locpagediff = currentpage - lastpagebefore
					if firstheadafter != none {
						let firstpageafter = firstheadafter.location().page()
						if firstheadafter.level == 1 and currentpage < firstpageafter {
							// On the last page before next chapter.
							smallcaps( lastheadbefore.body )
						}
						else if locpagediff >= 1 and (firstheadafter.level > lastheadbefore.level) {
							// Pages following chapter title but not last page before next chapter.
							smallcaps( lastheadbefore.body )
						}
						else {
							// On an outlined chapter-starting page.
							[]
						}
					}
					else {
						// No following outlined chapters or lower-level sections. Usually the last page of the document.
						smallcaps( lastheadbefore.body )
					}
				}
				else {
					// No preceding outlined chapters.
					[]
				}
			)
			let outertext = if pagenum == none [] else [#numbering(numberingstr,pagenum)]
			let docpagenum = counter(page).get().first() + 1
			if finalpagenumber > BINDINGPAGELIMIT and physically-printed {
				if calc.rem(docpagenum,2) == 0 {
					innertext + h(1fr) + outertext
				} else {
					outertext + h(1fr) + innertext
				}
			} else {
				innertext + h(1fr) + outertext
			}
		},
		footer: {},
		margin: if finalpagenumber > BINDINGPAGELIMIT and physically-printed {
			(
				top: 2.5cm,
				bottom: 2.5cm,
				inside: 4cm,
				outside: 2cm,
			)
		} else {
			(
				top: 2.5cm,
				bottom: 2.5cm,
				left: 4cm,
				right: 2cm,
			)
		}
	)
	DOCPARTSTATE.update(docpart)
	it
}

/**
 *
 * A list of images.
 *
***/
#let content_figures(language) = {
	outline(
		title:
			if language == finnish
				[Kuvaluettelo]
			else if language == english
				[List of figures],
		target: figure.where(kind: image),
		indent: auto,
	)
}

/**
 *
 * A list of tables.
 *
***/
#let content_tables(language) = {
	outline(
		title:
			if language == finnish
				[Taulukkoluettelo]
			else if language == english
				[List of tables],
	target: figure.where(kind: table),
	indent: auto,
	)
}

/**
 *
 * A list of listings.
 *
***/
#let content_listings(language) = {
	outline(
		title:
			if language == finnish
				[Ohjelma- ja algoritmiluettelo]
			else if language == english
				[Listings],
		target: figure.where(kind: raw),
		indent: auto,
	)
}

/**
 *
 * Defines the structure and look of Tampere University theses.
 *
***/

#let tauthesis(
	fignumberwithinlevel : 1,
	eqnumberwithinlevel : 1,
	textfont : ("Open Sans", "Arial", "Helvetica", "Fira Sans", "DejaVu Sans"),
	mathfont : ("New Computer Modern Math"),
	codefont : ("Fira Mono", "JuliaMono", "Cascadia Code", "DejaVu Sans Mono"),
	usedAI : true,
	author: "Firstname Lastname",
	date: datetime.today(),
	examiners: (
		(
			title : "Professor",
			firstname : "Firstname",
			lastname : "Lastname",
		),
		(
			title : "University lecturer",
			firstname : "Firstname",
			lastname : "Lastname",
		),
	),
	language: "fi",
	citationstyle: "ieee",
	include-finnish-abstract: true,
	physically-printed: false,
	alaotsikko: [Alaotsikko],
	avainsanat: ("avainsana1", "avainsana2"),
	koulu: [Tampereen Yliopisto],
	tiedekunta: [Tiedekunta],
	otsikko: [Opinnäytetyöpohja],
	työntyyppi: [Diplomityö],
	sijainti: [Tampereella],
	faculty: "Faculty",
	keywords: ("keyword1", "keyword2"),
	university: [Tampere University],
	subtitle: [Subtitle],
	thesistype: "Master's thesis",
	title: "Thesis template",
	location: "Tampere",
	prefaceContents: [],
	abstractContents: [],
	tiivistelmänSisältö: [],
	glossaryDict: (:),
	aiDisclaimerContents: [],
	tekoälynKäyttöTeksti: [],
	doc
) = {

	if not language in (finnish, english) {
		panic( templatename + ": unrecognized primary language '" + language + ". Only 'fi' and 'en' are accepted." )
	}

	if fignumberwithinlevel < 1 or fignumberwithinlevel > 4 {
		panic( "Argument fignumberwithinlevel must be in the set {1,2,3,4}. Received " + str(eqnumberwithinlevel) + ".")
	}

	if eqnumberwithinlevel < 1 or eqnumberwithinlevel > 4 {
		panic( "Argument eqnumberwithinlevel must be in the set {1,2,3,4}. Received " + str(eqnumberwithinlevel) + ".")
	}

	set document(
		author: author,
		title: if language == finnish {
			otsikko
		} else {
			title
		},
		keywords: if language == finnish {
			avainsanat
		} else {
			keywords
		},
		date: date,
	)

	// Color different kinds of links.

	show link: it => {
		set text ( fill: rgb("#0038FF") )
		it
	}

	show cite: it => {
		set text( fill: rgb("#FF1B24") )
		it
	}

	// Initialize helper counters in array format.

	let counterlistlen = fignumberwithinlevel + 1

	IMAGECOUNTER.update((0,) * counterlistlen)
	TABLECOUNTER.update((0,) * counterlistlen)
	CODECOUNTER.update((0,)  * counterlistlen)
	TAUTHEOREMCOUNTER.update((0,) * counterlistlen)

	FIGNUMDEPTHSTATE.update( fignumberwithinlevel )

	EQNUMDEPTHSTATE.update( eqnumberwithinlevel )

	// Update helper counters when associated figures are shown.

	show figure: it => figshowrule(language,it)

	show heading: set block( above: 1.4em, below: 2em )

	// Note: this automatic addition of page breaks before level
	// 1 headings might be partially responsible for the
	// introduction page numbering bug discussed below.

	show heading: it => headingshowrule(language,it)

	show raw: set text( font : codefont, size: tunicodefontsize)

	show raw.where( block : false ) : it => {
		box(
			inset : (x : 0.2 * tunicodefontsize),
			outset : (y : 0.2 * tunicodefontsize),
			fill : luma(230),
			radius : 0.25 * tunicodefontsize,
			it
		)
	}

	show raw.where( block : true ): it => {
		show raw.line: it => [
			#box(width : 0.4cm)[#align( right )[#it.number]]
			#h(0.1cm)
			#it.body
		]
		align(
			left,
			block(
				radius : 0.2cm,
				width: 100%,
				fill: rgb(250, 251, 249),
				inset: tunicodeblockinset,
				it
			)
		)
	}

	set text( font: textfont, lang: language, size: 11pt )

	show math.equation: set text(font: mathfont, size: 12pt)

	counter(page).update(0)

	show: doc => pagesettings(TITLEPAGEPART, physically-printed, doc)

	show: doc => titlepage(
		author,
		title,
		subtitle,
		university,
		faculty,
		thesistype,
		otsikko,
		alaotsikko,
		koulu,
		tiedekunta,
		työntyyppi,
		language,
		examiners,
		doc
	)

	PREFACEPAGENUMBERCOUNTER.update(1)

	show: doc => pagesettings(DOCPREAMBLEPART, physically-printed, doc)

	set heading(numbering: none, outlined: false)

	set par( justify : true )

	if language == finnish {
		abstract(
			author,
			title,
			subtitle,
			university,
			faculty,
			thesistype,
			keywords,
			otsikko,
			alaotsikko,
			koulu,
			tiedekunta,
			työntyyppi,
			avainsanat,
			tiivistelmänSisältö,
			finnish,
		)
		abstract(
			author,
			title,
			subtitle,
			university,
			faculty,
			thesistype,
			keywords,
			otsikko,
			alaotsikko,
			koulu,
			tiedekunta,
			työntyyppi,
			avainsanat,
			abstractContents,
			english
		)
	} else if language == english {
		abstract(
			author,
			title,
			subtitle,
			university,
			faculty,
			thesistype,
			keywords,
			otsikko,
			alaotsikko,
			koulu,
			tiedekunta,
			työntyyppi,
			avainsanat,
			abstractContents,
			english,
		)
		if include-finnish-abstract {
			abstract(
				author,
				title,
				subtitle,
				university,
				faculty,
				thesistype,
				keywords,
				otsikko,
				alaotsikko,
				koulu,
				tiedekunta,
				työntyyppi,
				avainsanat,
				tiivistelmänSisältö,
				finnish,
			)
		}
	} else {
		panic( templatename + ": received an unknown language " + language + ". Must be one of {\"fi\", \"en\"}" )
	}

	aiDisclaimerPage(usedAI, language, tekoälynKäyttöTeksti, aiDisclaimerContents)

	// Adjust how ToC entries appear in their respective listings.

	show outline.entry: it => outlineentryshowrule(language, it)

	// Hide any citations before main matter, so that citation counter is not
	// incremented before main matter starts.

	{
		set footnote.entry( separator: none)
		show footnote.entry: hide
		show ref: none
		show footnote: none
		outline(depth: 3,indent:auto)
		preface(author, language, prefaceContents, sijainti, location)
		glossary(language, glossaryDict)
		content_figures(language)
		content_tables(language)
		content_listings(language)
	}

	MAINMATTERPAGENUMBERCOUNTER.update( 1 )

	show: doc => pagesettings(MAINMATTERPART, physically-printed, doc)

	set math.vec(delim : "[")

	set math.mat(delim : "[")

	set math.equation(
		numbering: nn => context {
			let ctrarr = counter(heading).get()
			let ctrarr = ctrarr.slice(0,calc.min(eqnumberwithinlevel,ctrarr.len()))
			"(" + array2sectionnumbering(ctrarr, false) + "." + str(nn) + ")"
		},
		supplement: none
	)

	set par( leading: 0.9em, first-line-indent: 0em, justify: true )

	set par(spacing: 1.5em)

	set heading( numbering: "1.1" + headingsep, outlined: true, supplement: none )

	// Adjust references, so they display figures and such using
	// the auxiliary counters.

	show ref : it => refshowrule( it, language, eqnumberwithinlevel : eqnumberwithinlevel)

	doc

}

/** bibsettings( doc )
 *
 * Lets show rules know that we are currently displaying the bibliography.
 *
***/

#let bibsettings( doc ) = {
	DOCPARTSTATE.update(BIBLIOGRAPHYPART)
	doc
}


/** appendix( fignumberwithinlevel : 1, eqnumberwithinlevel : 1, doc )
 *
 * Defines the appearance of the appendix, supposing that the
 * above tauthesis has already defined the general appearance of
 * the document.
 *
***/

#let appendix( fignumberwithinlevel : 1, eqnumberwithinlevel : 1, language, doc ) = {

	if fignumberwithinlevel < 1 or fignumberwithinlevel > 4 {
		panic( "Argument fignumberwithinlevel must be in the set {1,2,3,4}. Received " + str(eqnumberwithinlevel) + ".")
	}

	if eqnumberwithinlevel < 1 or eqnumberwithinlevel > 4 {
		panic( "Argument eqnumberwithinlevel must be in the set {1,2,3,4}. Received " + str(eqnumberwithinlevel) + ".")
	}

	// Reset counters at the start of appendix.

	let counterlistlen = fignumberwithinlevel + 1

	IMAGECOUNTER.update((0,) * counterlistlen)
	TABLECOUNTER.update((0,) * counterlistlen)
	CODECOUNTER.update((0,) * counterlistlen)
	TAUTHEOREMCOUNTER.update((0,) * counterlistlen)

	counter(heading).update( 0 )

	counter(math.equation).update( 0 )

	set heading(numbering: "A.1", supplement: none)

	show heading: set block( above: 1.4em, below: 2em )

	show heading : it => headingshowrule(language, it)

	set math.equation(
		numbering: nn => context {
			let ctrarr = counter(heading).get()
			let ctrarr = ctrarr.slice(0,calc.min(eqnumberwithinlevel,ctrarr.len()))
			"(" + array2sectionnumbering(ctrarr, true) + "." + str(nn) + ")"
		},
		supplement: none
	)

	show ref : it => refshowrule( it, eqnumberwithinlevel : eqnumberwithinlevel)

	DOCPARTSTATE.update(APPENDIXPART)

	FIGNUMDEPTHSTATE.update( fignumberwithinlevel )

	EQNUMDEPTHSTATE.update( eqnumberwithinlevel )

	show heading.where(level: 4): it =>[
		#block(it.body)
	]

	show heading: it => {
		if it.level > 4 {
			panic("Headings with level greater than 4 are not allowed in a Tampere University theses. Please reconsider your document structure.")
		}
		smallcaps(it)
	}

	doc

}
