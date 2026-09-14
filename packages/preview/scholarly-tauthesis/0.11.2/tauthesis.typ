/** tauthesis.typ
 *
 * This module defines the Tampere University thesis template structure. You
 * should not need to touch this file. Define your own commands in preamble.typ
 * instead.
 *
***/

//// Counters and kinds

#let UNKNOWNSUPPLEMENT = "Unknown"

#let IMAGECOUNTER = counter("IMAGE")

#let TABLECOUNTER = counter("TABLE")

#let CODECOUNTER = counter("CODE")

#let TAUTHEOREMCOUNTER = counter("tautheorem")

#let EQUATIONCOUNTER = counter("EQUATION")

#let UNKNOWNCOUNTER = counter("UNKNOWN")

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

#let templateName = "tauthesis"

#let tuniPurple = rgb(78,0,148)

#let tuniFontSize = 12pt

#let tuniCodeFontSize = 10pt

#let finnish = "fi"

#let english = "en"

#let headingSep = 2 * " "

#let tuniCodeBlockInset = 0.5em

#let codeSupplementFn(language) = {
	if language == finnish {
		[Listaus]
	} else {
		[Listing]
	}
}

#let appendixPrefixFn(language) = if language == finnish {
	smallcaps[Liite]
} else {
	smallcaps[Appendix]
}

//// Utility functions

// This function will give Finnish month names by month numbers.
// https://typst.app/docs/reference/foundations/datetime/
// Unfortunately, when choosing the word representation, it can
// currently only display the English version. In the future, it is
// planned to support localization.

#let localizeMonthFi(month) = {
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

#let localizeMonthFiPartitive(month) = {
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

#let int2AppendixLetter(ii) = {
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

#let array2SectionNumbering(arr, inAppendix) = {
	if arr.len() < 1 { panic("Arrays of zero length cannot be used to construct a section number string. Reveived " + arr.map(str).join(",") ) }
	if not ( arr.all( elem => type(elem) == int ) ) { panic("Array elements used to construct section numberings need to contain integers.") }
	let firstnum = arr.first()
	let chaptersymbol = if inAppendix {
		int2AppendixLetter(firstnum)
	} else {
		str(firstnum)
	}
	let rest = arr.slice(1).map(str)
	let symbols = (chaptersymbol, ..rest)
	symbols.join(".")
}

/**
 *
 * Updates a figure counter given as an array.
 *
***/

#let figCounterUpdateFn(..args) = {
	let argsArray = args.pos()
	argsArray.last() += 1
	argsArray
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
			#h(1em, weak:false) #sym.ballot Kyllä\
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

		= Use of artificial intelligence in this work

		Artificial intelligence (AI) has been used in generating this work:

		#if usedAI [
			#h(1em, weak:false) #sym.ballot.cross Yes\
			#h(1em, weak:false) #sym.ballot No
		] else [
			#h(1em, weak:false) #sym.ballot Yes\
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

#let refShowRule(it, language, eqNumberWithinLevel : 1) = {

	let codeSupplement = codeSupplementFn(language)

	let appendixPrefix = appendixPrefixFn(language)

	show link: set text( fill: tuniPurple, weight: "bold" )

	let el = it.element
	if el != none {
		let elementLocation = el.location()
		let headingctr = counter(heading).at(elementLocation)
		let docPart = DOCPARTSTATE.at(elementLocation)
		let inAppendix = docPart == APPENDIXPART
		let refText = if el.func() == figure {
			let (carray, supplement) = if el.kind == image {
				(IMAGECOUNTER.at(elementLocation), el.supplement)
			}
			else if el.kind == table {
				(TABLECOUNTER.at(elementLocation), el.supplement)
			}
			else if el.kind == raw {
				(CODECOUNTER.at(elementLocation), codeSupplement)
			}
			else if el.kind == TAUTHEOREMKIND {
				(TAUTHEOREMCOUNTER.at(elementLocation), el.supplement)
			}
			else {
				(
					UNKNOWNCOUNTER.at(elementLocation),
					if el.supplement == none {
						UNKNOWNSUPPLEMENT
					} else {
						el.supplement
					}
				)
			}
			if carray != none {
				let supplement = if it.citation.supplement != none { it.supplement } else { supplement }
				carray.last() += 1
				(
					if supplement != [] { supplement + sym.space.nobreak }
					+
					array2SectionNumbering(carray,inAppendix)
				)
			} else {
				it
			}
		}
		else if el.func() == heading {
			let ctr = counter(heading).at(elementLocation)
			let prefix = if it.citation.supplement == none and el.level == 1 and inAppendix {
				appendixPrefix
			} else if it.citation.supplement != none {
				it.supplement
			} else {
				none
			}
			(
				if prefix != none { prefix + sym.space.nobreak }
				+
				array2SectionNumbering(ctr, inAppendix)
			)
		}
		else if el.func() == math.equation {
			let numdepth = EQNUMDEPTHSTATE.at(elementLocation)
			let headctr = EQUATIONCOUNTER.at(elementLocation)
			let headctr = headctr.slice(0,calc.min(headctr.len(),numdepth))
			let eqctr = counter(math.equation).at(elementLocation)
			headctr.push( eqctr.last() )
			[$(array2SectionNumbering(headctr, inAppendix))$]
		}
		else {
			it
		}
		link(elementLocation,refText)
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

#let figShowRule(language,it) = {
	let codeSupplement = codeSupplementFn(language)
	let figloc = it.location()
	let docPart = DOCPARTSTATE.at(figloc)
	let inAppendix = docPart == APPENDIXPART
	let fig = if it.kind == image {
		IMAGECOUNTER.update( figCounterUpdateFn )
		let ctr = IMAGECOUNTER.at(figloc)
		ctr.last() += 1
		block(it.body)
		block[
			#text( fill:tuniPurple)[*#it.supplement #array2SectionNumbering(ctr,inAppendix):* ]
			#it.caption.body
		]
	}
	else if it.kind == table {
		set figure.caption( position : top )
		TABLECOUNTER.update( figCounterUpdateFn )
		let ctr = TABLECOUNTER.at(figloc)
		ctr.last() += 1
		block[
			#text( fill:tuniPurple)[*#it.supplement #array2SectionNumbering(ctr,inAppendix):* ]
			#it.caption.body
		]
		block(it.body)
	}
	else if it.kind == raw {
		set figure.caption( position : top )
		CODECOUNTER.update( figCounterUpdateFn )
		let ctr = CODECOUNTER.at(figloc)
		ctr.last() += 1
		block[
			#text( fill:tuniPurple)[*#codeSupplement #array2SectionNumbering(ctr,inAppendix):* ]
			#it.caption.body
		]
		block(it.body)
	}
	else if it.kind == TAUTHEOREMKIND {
		TAUTHEOREMCOUNTER.update( figCounterUpdateFn )
		it
	}
	else {
		UNKNOWNCOUNTER.update( figCounterUpdateFn )
		let ctr = UNKNOWNCOUNTER.at(figloc)
		ctr.last() += 1
		block(it.body)
		block[
			#text( fill:tuniPurple)[*#it.supplement #array2SectionNumbering(ctr,inAppendix):* ]
			#it.caption.body
		]
	}
	set align(center)
	block(breakable:false,fig)
}

/**
 *
 * Defines how headings are displayed. Also updates counters related to
 * numbering figures and equations.
 *
***/

#let headingShowRule(language, it) = [

	#let appendixPrefix = appendixPrefixFn(language)

	#if it.level == 1 {
		pagebreak(weak: true)
	}

	#let eqNumberWithinLevel = EQNUMDEPTHSTATE.get()
	#let figNumberWithinLevel = FIGNUMDEPTHSTATE.get()
	#let counterListLen = figNumberWithinLevel + 1
	#let followingHeadings = query( heading.where(outlined : true).after(here()))
	#let followingHeading = followingHeadings.at(0, default: none)
	#let followingHeadingLocation = if followingHeading != none {
		followingHeading.location()
	} else {
		here()
	}
	#if it.level <= eqNumberWithinLevel and it.outlined {
		counter(math.equation).update( 0 )
		let ctr = counter(heading).at(followingHeadingLocation)
		let minlen = calc.min(ctr.len(),eqNumberWithinLevel)
		EQUATIONCOUNTER.update( ctr.slice(0,minlen) )
	}
	#let headingShowRuleFigCounterUpdateFn(..args) = {
		let argsArray = args.pos()
		argsArray.at(it.level - 1) += 1
		argsArray.last() = 0
		argsArray
	}
	#if it.outlined and it.level <= counterListLen {
		IMAGECOUNTER.update( headingShowRuleFigCounterUpdateFn )
		TABLECOUNTER.update( headingShowRuleFigCounterUpdateFn )
		CODECOUNTER.update( headingShowRuleFigCounterUpdateFn )
		TAUTHEOREMCOUNTER.update( headingShowRuleFigCounterUpdateFn )
		UNKNOWNCOUNTER.update( headingShowRuleFigCounterUpdateFn )
	}
	#let docPart = DOCPARTSTATE.get()
	#let inAppendix = docPart == APPENDIXPART
	#let inBibliography = docPart == BIBLIOGRAPHYPART
	#let (textSize, headspacing) = if it.level == 1 {
		(21pt, 42pt)
	} else if it.level == 2 {
		(17pt, 18pt)
	} else if it.level == 3 or it.level == 4 {
		(13pt, 18pt)
	}
	#set text( size : textSize )
	#block(above: headspacing, below: headspacing)[
		#if it.level == 1 and inAppendix {
			appendixPrefix
		} else {
			[]
		}
		#if it.outlined {
			if it.level > 3 {
				// Leave counter out.
			}
			else if it.level == 1 and inAppendix {
				counter(heading).display("A.1:")
			}
			else if inAppendix {
				counter(heading).display("A.1")
			}
			else if inBibliography {
				[]
			}
			else {
				counter(heading).display()
			}
		}
		#smallcaps( it.body )
	]
]

/**
 *
 * Defines how outline entries are to be displayed. This is to be used within a
 * show rule, so that context and therefore information about page numbers and
 * such can be resolved.
 *
***/

#let outlineEntryShowRule(language, it) = {
	let codeSupplement = codeSupplementFn(language)
	let appendixPrefix = appendixPrefixFn(language)
	set text( size : 13pt )
	let el = it.element
	let elementLocation = el.location()
	let elementPageNum = MAINMATTERPAGENUMBERCOUNTER.at(elementLocation).first() - 1
	let docPart = DOCPARTSTATE.at(elementLocation)
	let inAppendix = docPart == APPENDIXPART
	let inBibliography = docPart == BIBLIOGRAPHYPART
	let entry = if el.func() == figure {
		let (carray, supplement) = if el.body.func() == image {
			(IMAGECOUNTER.at(elementLocation), el.supplement)
		} else if el.body.func() == table {
			(TABLECOUNTER.at(elementLocation), el.supplement)
		} else if el.body.func() == raw {
			(CODECOUNTER.at(elementLocation), codeSupplement)
		} else if el.kind == TAUTHEOREMKIND {
			(TAUTHEOREMCOUNTER.at(elementLocation), el.supplement)
		} else {
			(UNKNOWNCOUNTER.at(elementLocation), UNKNOWNSUPPLEMENT)
		}
		if carray != none {
			carray.last() += 1
			link(
				elementLocation,
				[
					#text(fill:tuniPurple)[*#supplement #array2SectionNumbering(carray, inAppendix):*]
					#set text( fill : black )
					#el.caption.body
					#box(width:1fr,repeat[.])
					#elementPageNum
				]
			)
		} else {
			it
		}
	} else if el.func() == heading {
		let tsize = if el.level == 1 { 14pt } else if el.level == 2 { 13pt } else if el.level == 3 { 12pt } else { 11pt }
		let ctr = counter(heading).at(elementLocation)
		let (prefix, numbering, colon, bodycolor, bodyweight) = if inAppendix {
			if el.level == 1 {
				(appendixPrefix, array2SectionNumbering(ctr, inAppendix), ":", black, "regular")
			} else {
				([], array2SectionNumbering(ctr, inAppendix), [], black, "regular")
			}
		} else if inBibliography {
			([],[],[], tuniPurple, "bold")
		} else {
			([], array2SectionNumbering(ctr, inAppendix), [], black, "regular")
		}
		smallcaps(
			link(
				elementLocation
			)[
				*#text(
					fill : tuniPurple,
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
					#elementPageNum
				]
			]
		)
	} else {
		it
	}
	block[#h((it.level - 1) * 1em)#entry]
}

/**
 *
 * Defines the look of code elements.
 *
***/

#let rawShowRule(codeFont,it) = {

	set text( font : codeFont, size: tuniCodeFontSize)

	if it.block {

		show raw.line: it => [
			#let numberColWidth = if it.count < 10 {
				0.7em
			} else {
				calc.floor(calc.log(it.count, base:10)) * 1em
			}
			#box(width: numberColWidth)[
				#set text(fill:gray)
				#align(right)[#it.number]
			]
			#it.body
		]

		align(
			left,
			block(
				radius : 0.2cm,
				width: 100%,
				fill: rgb(250, 251, 249),
				inset: tuniCodeBlockInset,
				it
			)
		)

	} else {

		box(
			inset : (x : 0.2 * tuniCodeFontSize),
			outset : (y : 0.2 * tuniCodeFontSize),
			fill : luma(230),
			radius : 0.25 * tuniCodeFontSize,
			it
		)

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
	thesisType,
	otsikko,
	alaotsikko,
	koulu,
	tiedekunta,
	työnTyyppi,
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
			fill: tuniPurple,
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
			fill: tuniPurple,
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
					#thesisType\
					#university\
					#faculty
				] else if language == finnish [
					#työnTyyppi\
					#koulu\
					#tiedekunta
				]\
				#examiners.map(value => examinerprefix + ": " + value.title + " " + value.firstname + " " + value.lastname).join("\n")\
				#if language == english [
					#date.display("[month repr:long] [year]")
				] else if language == finnish [
					#localizeMonthFi(date.month()) #date.year()
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
	thesisType,
	keywords,
	otsikko,
	alaotsikko,
	koulu,
	tiedekunta,
	työnTyyppi,
	avainsanat,
	abstractContent,
	language
) = [

	#let date = datetime.today()

	#set text(size:10pt)

	#let checkSubtitleFn(subtitle) = {
		if subtitle == none []
		else if type(subtitle) in (content,str) [: #subtitle ]
		else [
			#panic("The subtitle of a thesis needs to be enclosed in […] or \"…\", or be equal to none")
		]
	}

	#if language == finnish [

		= Tiivistelmä <tiivistelmä>

		#author\
		#otsikko#checkSubtitleFn(alaotsikko)\
		#koulu\
		#tiedekunta\
		#työnTyyppi\
		#localizeMonthFi(date.month()) #date.year()\

	] else [

		= Abstract <abstract>

		#author\
		#title#checkSubtitleFn(subtitle)\
		#university\
		#faculty\
		#thesisType\
		#date.display("[month repr:long] [year]")\

	]

	#line(
		length: 100%,
		stroke: 2pt + tuniPurple,
	)

	#abstractContent

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

		#sijainti #date.day().
		#localizeMonthFiPartitive(date.month())
		#date.year(),\
		#author

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
					#set text(fill:tuniPurple)
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

#let tauTheoremBlock(
	fill: rgb("#ffffff"),
	supplement: [TAUTheoremBlock],
	title: [],
	reflabel: "",
	content
) = context {
	let docPart = DOCPARTSTATE.get()
	let inAppendix = docPart == APPENDIXPART
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
				stroke: tuniPurple,
				width: 100%,
				breakable: true,
				align(
					left,
					[
						#text(weight: "bold", fill: tuniPurple, [#supplement #array2SectionNumbering(ctr,inAppendix)])
						// Content converted to string with repr always has a lenght ≥ 2.
						#if repr(title).len() > 2 [
							(#text(weight: "bold", fill: tuniPurple, title))
						]
						#content
					],
				)
			)
		)
		#if reflabel.len() > 0 { label(reflabel) }
	]
}

#let definition(title: "", reflabel: "", content) = tauTheoremBlock(
	supplement: "Definition",
	reflabel: reflabel,
	title: title,
	content
)

#let lemma(title: "", reflabel: "", content) = tauTheoremBlock(
	supplement: "Lemma",
	reflabel: reflabel,
	title: title,
	content
)

#let theorem(title: "", reflabel: "", content) = tauTheoremBlock(
	supplement: "Theorem",
	reflabel: reflabel,
	title: title,
	content
)

#let corollary(title: "", reflabel: "", content) = tauTheoremBlock(
	supplement: "Corollary",
	reflabel: reflabel,
	title: title,
	content
)

#let example(title: "", reflabel: "", content) = tauTheoremBlock(
	supplement: "Example",
	reflabel: reflabel,
	title: title,
	content
)

#let määritelmä(title: "", reflabel: "", content) = tauTheoremBlock(
	supplement: "Määritelmä",
	reflabel: reflabel,
	title: title,
	content
)

#let apulause(title: "", reflabel: "", content) = tauTheoremBlock(
	supplement: "Apulause",
	reflabel: reflabel,
	title: title,
	content
)

#let lause(title: "", reflabel: "", content) = tauTheoremBlock(
	supplement: "Lause",
	reflabel: reflabel,
	title: title,
	content
)

#let seurauslause(title: "", reflabel: "", content) = tauTheoremBlock(
	supplement: "Seurauslause",
	reflabel: reflabel,
	title: title,
	content
)

#let esimerkki(title: "", reflabel: "", content) = tauTheoremBlock(
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
#let pageSettings(docPart, physicallyPrinted, language, displayLinkToToC, it) = context {
	let finalPageNumber = MAINMATTERPAGENUMBERCOUNTER.final().last()
	let prevDocPart = docPart - 1
	set page(
		numbering: none,
		binding : {
			let docPageNum = counter(page).get().last() + 1
			if finalPageNumber > BINDINGPAGELIMIT and physicallyPrinted {
				if calc.rem(docPageNum,2) == 0 {
					right
				} else {
					left
				}
			} else {
				left
			}
		},
		header: context {
			if docPart == DOCPREAMBLEPART {
				PREFACEPAGENUMBERCOUNTER.step()
			}
			if docPart >= MAINMATTERPART {
				MAINMATTERPAGENUMBERCOUNTER.step()
			}
			let (pageNum, numberingstr) = {
				if docPart in (TITLEPAGEPART, DOCPREAMBLEPART) {
					(PREFACEPAGENUMBERCOUNTER.get().first(),"i")
				}
				else if docPart >= MAINMATTERPART {
					(MAINMATTERPAGENUMBERCOUNTER.get().first(),"1")
				}
				else {
					(none,"")
				}
			}
			let headingsBefore = query(
				heading.where(level: 1).and(
					heading.where(outlined: true)
				).before(here())
			)
			let headingsAfter = query(
				heading.where(outlined: true).after(here()),
			)
			let lastHeadBefore = headingsBefore.at(-1, default: none)
			let firstHeadAfter = headingsAfter.at(0, default: none)
			let currentPage = here().page()
			// Display current chapter title in left header, if we have
			// moved past the chapter start page. Lower level section
			// titles are not displayed.
			let innerText = box(
				if lastHeadBefore != none {
					let lastPageBefore = lastHeadBefore.location().page()
					let locationPageDiff = currentPage - lastPageBefore
					if firstHeadAfter != none {
						let firstpageafter = firstHeadAfter.location().page()
						if firstHeadAfter.level == 1 and currentPage < firstpageafter {
							// On the last page before next chapter.
							smallcaps( lastHeadBefore.body )
						}
						else if locationPageDiff >= 1 and (firstHeadAfter.level > lastHeadBefore.level) {
							// Pages following chapter title but not last page before next chapter.
							smallcaps( lastHeadBefore.body )
						}
						else {
							// On an outlined chapter-starting page.
							[]
						}
					}
					else {
						// No following outlined chapters or lower-level sections. Usually the last page of the document.
						smallcaps( lastHeadBefore.body )
					}
				}
				else {
					// No preceding outlined chapters.
					[]
				}
			)
			let outerText = if pageNum == none [] else [#numbering(numberingstr,pageNum)]
			let docPageNum = counter(page).get().first() + 1
			if finalPageNumber > BINDINGPAGELIMIT and physicallyPrinted {
				if calc.rem(docPageNum,2) == 0 {
					innerText + h(1fr) + outerText
				} else {
					outerText + h(1fr) + innerText
				}
			} else {
				innerText + h(1fr) + outerText
			}
		},
		footer: if docPart >= MAINMATTERPART and not physicallyPrinted {
			let buttonFillColor = if displayLinkToToC { tuniPurple } else { white }
			show link: set text(fill: white, size:9pt)
			place(horizon + left, dx: -3.7cm, dy: 0.4cm)[
				#link(
					label("outlineLabel"),
					box(stroke: buttonFillColor, fill:buttonFillColor,inset:0.3em,radius:0.2em)[
						#sym.arrow.t
						#if language == finnish [Takaisin sisällykseen] else [Back to Contents]
					]
				)
			]
		},
		margin: if finalPageNumber > BINDINGPAGELIMIT and physicallyPrinted {
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
	DOCPARTSTATE.update(docPart)
	it
}

/**
 *
 * A list of images.
 *
***/
#let contentFigures(language) = {
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
#let contentTables(language) = {
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
#let contentListings(language) = {
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

#let template(
	abstractContents: [],
	aiDisclaimerContents: [],
	alaotsikko: [Alaotsikko],
	author: "Firstname Lastname",
	avainsanat: ("avainsana1", "avainsana2"),
	citationStyle: "ieee",
	codeFont : ("Fira Mono", "JuliaMono", "Cascadia Code", "DejaVu Sans Mono"),
	displayLinkToToC: true,
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
	eqNumberWithinLevel : 1,
	faculty: "Faculty",
	figNumberWithinLevel : 1,
	glossaryDict: (:),
	includeFinnishAbstract: true,
	keywords: ("keyword1", "keyword2"),
	koulu: [Tampereen Yliopisto],
	language: "fi",
	location: "Tampere",
	mathFont : ("STIX Two Math", "New Computer Modern Math"),
	otsikko: [Opinnäytetyöpohja],
	physicallyPrinted: false,
	prefaceContents: [],
	showParagraphLineNumbers: false,
	sijainti: [Tampereella],
	subtitle: [Subtitle],
	tekoälynKäyttöTeksti: [],
	textFont : ("Roboto", "Open Sans", "Arial", "Helvetica", "Fira Sans", "DejaVu Sans"),
	thesisType: "Master's thesis",
	tiedekunta: [Tiedekunta],
	tiivistelmänSisältö: [],
	title: "Thesis template",
	työnTyyppi: [Diplomityö],
	university: [Tampere University],
	usedAI : true,
	doc
) = {

	if not language in (finnish, english) {
		panic( templateName + ": unrecognized primary language '" + language + ". Only 'fi' and 'en' are accepted." )
	}

	if figNumberWithinLevel < 1 or figNumberWithinLevel > 4 {
		panic( "Argument figNumberWithinLevel must be in the set {1,2,3,4}. Received " + str(eqNumberWithinLevel) + ".")
	}

	if eqNumberWithinLevel < 1 or eqNumberWithinLevel > 4 {
		panic( "Argument eqNumberWithinLevel must be in the set {1,2,3,4}. Received " + str(eqNumberWithinLevel) + ".")
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
		date: datetime.today(),
	)

	// Color different kinds of links.

	show link: set text( fill: rgb("#0038FF") )

	show cite: set text( fill: tuniPurple )

	// Prettify emphasized text.

	show emph: set text(fill:tuniPurple)

	// Initialize helper counters in array format.

	let counterListLen = figNumberWithinLevel + 1

	IMAGECOUNTER.update((0,) * counterListLen)
	TABLECOUNTER.update((0,) * counterListLen)
	CODECOUNTER.update((0,) * counterListLen)
	TAUTHEOREMCOUNTER.update((0,) * counterListLen)
	UNKNOWNCOUNTER.update((0,) * counterListLen)

	FIGNUMDEPTHSTATE.update( figNumberWithinLevel )

	EQNUMDEPTHSTATE.update( eqNumberWithinLevel )

	// Update helper counters when associated figures are shown.

	show figure: it => figShowRule(language,it)

	// Note: this automatic addition of page breaks before level
	// 1 headings might be partially responsible for the
	// introduction page numbering bug discussed below.

	show heading: it => headingShowRule(language,it)

	show raw: it => rawShowRule(codeFont,it)

	set text( font: textFont, lang: language, size: 11pt )

	show math.equation: set text(font: mathFont, size: 12pt)

	counter(page).update(0)

	show: doc => pageSettings(TITLEPAGEPART, physicallyPrinted, language, displayLinkToToC, doc)

	show: doc => titlepage(
		author,
		title,
		subtitle,
		university,
		faculty,
		thesisType,
		otsikko,
		alaotsikko,
		koulu,
		tiedekunta,
		työnTyyppi,
		language,
		examiners,
		doc
	)

	PREFACEPAGENUMBERCOUNTER.update(1)

	show: doc => pageSettings(DOCPREAMBLEPART, physicallyPrinted, language, displayLinkToToC, doc)

	set heading(numbering: none, outlined: false)

	set par( justify : true )

	if language == finnish {
		abstract(
			author,
			title,
			subtitle,
			university,
			faculty,
			thesisType,
			keywords,
			otsikko,
			alaotsikko,
			koulu,
			tiedekunta,
			työnTyyppi,
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
			thesisType,
			keywords,
			otsikko,
			alaotsikko,
			koulu,
			tiedekunta,
			työnTyyppi,
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
			thesisType,
			keywords,
			otsikko,
			alaotsikko,
			koulu,
			tiedekunta,
			työnTyyppi,
			avainsanat,
			abstractContents,
			english,
		)
		if includeFinnishAbstract {
			abstract(
				author,
				title,
				subtitle,
				university,
				faculty,
				thesisType,
				keywords,
				otsikko,
				alaotsikko,
				koulu,
				tiedekunta,
				työnTyyppi,
				avainsanat,
				tiivistelmänSisältö,
				finnish,
			)
		}
	} else {
		panic( templateName + ": received an unknown language " + language + ". Must be one of {\"fi\", \"en\"}" )
	}

	aiDisclaimerPage(usedAI, language, tekoälynKäyttöTeksti, aiDisclaimerContents)

	// Adjust how ToC entries appear in their respective listings.

	show outline.entry: it => outlineEntryShowRule(language, it)

	// Hide any citations before main matter, so that citation counter is not
	// incremented before main matter starts.

	[
		#set footnote.entry( separator: none)
		#show footnote.entry: hide
		#show ref: none
		#show footnote: none
		#outline(depth: 3,indent:auto)
		#label("outlineLabel")
		#preface(author, language, prefaceContents, sijainti, location)
		#glossary(language, glossaryDict)
		#contentFigures(language)
		#contentTables(language)
		#contentListings(language)
	]

	MAINMATTERPAGENUMBERCOUNTER.update( 1 )

	show: doc => pageSettings(MAINMATTERPART, physicallyPrinted, language, displayLinkToToC, doc)

	set math.vec(delim : "[")

	set math.mat(delim : "[")

	set math.equation(
		numbering: nn => context {
			let ctrarr = counter(heading).get()
			let ctrarr = ctrarr.slice(0,calc.min(eqNumberWithinLevel,ctrarr.len()))
			"(" + array2SectionNumbering(ctrarr, false) + "." + str(nn) + ")"
		},
		supplement: none
	)

	set par(
		leading: 0.9em,
		first-line-indent: 0em,
		justify: true,
		spacing: 1.5em,
	)

	set par.line(
		numbering: it => if showParagraphLineNumbers {
			set text(fill: gray)
			it
		} else {
			none
		},
		numbering-scope: "page",
	)

	set heading( numbering: "1.1" + headingSep, outlined: true, supplement: none )

	// Adjust references, so they display figures and such using
	// the auxiliary counters.

	show ref : it => refShowRule( it, language, eqNumberWithinLevel : eqNumberWithinLevel)

	doc

}

/** bibSettings( doc )
 *
 * Lets show rules know that we are currently displaying the bibliography.
 *
***/

#let bibSettings( doc ) = {
	DOCPARTSTATE.update(BIBLIOGRAPHYPART)
	doc
}


/** appendix( figNumberWithinLevel : 1, eqNumberWithinLevel : 1, doc )
 *
 * Defines the appearance of the appendix, supposing that the
 * above tauthesis has already defined the general appearance of
 * the document.
 *
***/

#let appendix( figNumberWithinLevel : 1, eqNumberWithinLevel : 1, language, doc ) = {

	if figNumberWithinLevel < 1 or figNumberWithinLevel > 4 {
		panic( "Argument figNumberWithinLevel must be in the set {1,2,3,4}. Received " + str(eqNumberWithinLevel) + ".")
	}

	if eqNumberWithinLevel < 1 or eqNumberWithinLevel > 4 {
		panic( "Argument eqNumberWithinLevel must be in the set {1,2,3,4}. Received " + str(eqNumberWithinLevel) + ".")
	}

	// Reset counters at the start of appendix.

	let counterListLen = figNumberWithinLevel + 1

	IMAGECOUNTER.update((0,) * counterListLen)
	TABLECOUNTER.update((0,) * counterListLen)
	CODECOUNTER.update((0,) * counterListLen)
	TAUTHEOREMCOUNTER.update((0,) * counterListLen)
	UNKNOWNCOUNTER.update((0,) * counterListLen)

	counter(heading).update( 0 )

	counter(math.equation).update( 0 )

	set heading(numbering: "A.1", supplement: none)

	show heading : it => headingShowRule(language, it)

	set math.equation(
		numbering: nn => context {
			let ctrarr = counter(heading).get()
			let ctrarr = ctrarr.slice(0,calc.min(eqNumberWithinLevel,ctrarr.len()))
			"(" + array2SectionNumbering(ctrarr, true) + "." + str(nn) + ")"
		},
		supplement: none
	)

	show ref : it => refShowRule( it, language, eqNumberWithinLevel : eqNumberWithinLevel)

	DOCPARTSTATE.update(APPENDIXPART)

	FIGNUMDEPTHSTATE.update( figNumberWithinLevel )

	EQNUMDEPTHSTATE.update( eqNumberWithinLevel )

	doc

}
