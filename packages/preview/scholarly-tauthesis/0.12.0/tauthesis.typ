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

// This global state is needed so that theorem blocks can fetch the maximum
// heading level under which they should be numbered.

#let FIGNUMBERWITHINLEVELSTATE = state("FIGNUMBERWITHINLEVELSTATE")

//// Thesis types.

#let bachelorsThesisType = "Bachelor's Thesis"

#let mastersThesisType = "Master's Thesis"

#let phdThesisType = "Doctoral Thesis"

#let acceptableThesisTypes = (bachelorsThesisType, mastersThesisType, phdThesisType)

#let kandidaatinTyönTyyppi = "Kandidaatintyö"

#let diplomiTyönTyyppi = "Diplomityö"

#let maisterinTyönTyyppi = "Pro gradu -tutkielma"

#let väitöskirjaTyönTyyppi = "Väitöskirja"

#let hyväksyttävätTyönTyypit = (kandidaatinTyönTyyppi, diplomiTyönTyyppi, maisterinTyönTyyppi, väitöskirjaTyönTyyppi)

#let bachelorsThesisTypeInt = 1
#let mastersThesisTypeInt = 2
#let phdThesisTypeInt = 3

/**
 *
 * Converts a given thesis type string to an integer for easy comparisons.
 *
***/

#let thesisTypeToIntFn(thesisType) = if thesisType in (bachelorsThesisType, kandidaatinTyönTyyppi) {
	bachelorsThesisTypeInt
} else if thesisType in (mastersThesisType, diplomiTyönTyyppi, maisterinTyönTyyppi) {
	mastersThesisTypeInt
} else if thesisType in (phdThesisType, väitöskirjaTyönTyyppi) {
	phdThesisTypeInt
} else {
	panic("Unknown thesis type " + str(thesisType) + ". Cannot convert to integer.")
}

/**
 *
 * Makes sure that the given Finnish and English thesis types are valid and match each other.
 *
***/
#let thesisTypeValidationFn(thesisType, työnTyyppi, language, includeFinnishAbstract) = {

	assert(
		thesisType in acceptableThesisTypes,
		message: "The given thesis type \""
			+ str(thesisType)
			+ "\" is not one of the acceptable ones "
			+ acceptableThesisTypes.join(", ", last: " or ")
			+ ". Note the capitalization."
	)

	assert(
		työnTyyppi in hyväksyttävätTyönTyypit,
		message: "Annettu suomenkielinen työn tyyppi \""
			+ str(työnTyyppi)
			+ "\" ei ole yksi hyväksyttävistä: "
			+ hyväksyttävätTyönTyypit.join(", ", last: " or ")
			+ ". Huomaa kirjoitusasu."
	)

	let thesisTypeLevelsMatchPredicate = (
		(thesisType == bachelorsThesisType) and (työnTyyppi == kandidaatinTyönTyyppi) or
		(thesisType == mastersThesisType) and (työnTyyppi in (diplomiTyönTyyppi, maisterinTyönTyyppi)) or
		(thesisType == phdThesisType) and (työnTyyppi == väitöskirjaTyönTyyppi)
	)

	assert(
		thesisTypeLevelsMatchPredicate,
		message: "Received unmatching English and Finnish thesis types "
			+ thesisType
			+ " and "
			+ työnTyyppi
			+ ". The allowed combinations are as follows: "
			+ bachelorsThesisType + " and " + kandidaatinTyönTyyppi + ", "
			+ mastersThesisType + " and (" + diplomiTyönTyyppi + " or " + maisterinTyönTyyppi + ")" + " xor "
			+ phdThesisType + " and " + väitöskirjaTyönTyyppi + "."
	)

}

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
			#grid(
				columns: (5%,1.5%,90%),
				row-gutter: 0.8em,
				align: (right+horizon,center+horizon,left+horizon),
				sym.ballot.cross,
				[~],
				[Kyllä],
				sym.ballot,
				[~],
				[Ei],
			)
		] else [
			#grid(
				columns: (5%,1.5%,90%),
				row-gutter: 0.8em,
				align: (right+horizon,center+horizon,left+horizon),
				sym.ballot,
				[~],
				[Kyllä],
				sym.ballot.cross,
				[~],
				[Ei],
			)
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
			#grid(
				columns: (5%,1.5%,90%),
				row-gutter: 0.8em,
				align: (right+horizon,center+horizon,left+horizon),
				sym.ballot.cross,
				[~],
				[Yes],
				sym.ballot,
				[~],
				[No],
			)
		] else [
			#grid(
				columns: (5%,1.5%,90%),
				row-gutter: 0.8em,
				align: (right+horizon,center+horizon,left+horizon),
				sym.ballot,
				[~],
				[Yes],
				sym.ballot.cross,
				[~],
				[No],
			)
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

#let refShowRule(it, language, figNumberWithinLevel, eqNumberWithinLevel : 1) = {

	let codeSupplement = codeSupplementFn(language)

	let appendixPrefix = appendixPrefixFn(language)

	show link: set text( fill: tuniPurple, weight: "bold" )

	let el = it.element

	if el != none {
		let elementLocation = el.location()
		let headingCounter = counter(heading).at(elementLocation)
		let headingCounter = headingCounter.slice(
			0,
			calc.min(figNumberWithinLevel,headingCounter.len())
		)
		let headingctr = counter(heading).at(elementLocation)
		let docPart = DOCPARTSTATE.at(elementLocation)
		let inAppendix = docPart == APPENDIXPART
		let refText = if el.func() == figure {
			let (carray, supplement) = if el.kind == image {
				(headingCounter + IMAGECOUNTER.at(elementLocation), el.supplement)
			}
			else if el.kind == table {
				(headingCounter + TABLECOUNTER.at(elementLocation), el.supplement)
			}
			else if el.kind == raw {
				(headingCounter + CODECOUNTER.at(elementLocation), codeSupplement)
			}
			else if el.kind == TAUTHEOREMKIND {
				(headingCounter + TAUTHEOREMCOUNTER.at(elementLocation), el.supplement)
			}
			else {
				(
					headingCounter + UNKNOWNCOUNTER.at(elementLocation),
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
			let headctr = EQUATIONCOUNTER.at(elementLocation)
			let headctr = headctr.slice(0,calc.min(headctr.len(),eqNumberWithinLevel))
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

#let figShowRule(language,figNumberWithinLevel,it) = {
	let codeSupplement = codeSupplementFn(language)
	let figloc = it.location()
	let docPart = DOCPARTSTATE.at(figloc)
	let inAppendix = docPart == APPENDIXPART
	let headingCounter = counter(heading).get()
	let headingCounter = headingCounter.slice(
		0,
		calc.min(figNumberWithinLevel,headingCounter.len())
	)
	let fig = if it.kind == image {
		IMAGECOUNTER.step()
		let ctr = headingCounter + IMAGECOUNTER.get()
		ctr.last() += 1
		block(it.body)
		block[
			#text( fill:tuniPurple)[*#it.supplement #array2SectionNumbering(ctr,inAppendix):* ]
			#it.caption.body
		]
	}
	else if it.kind == table {
		set figure.caption( position : top )
		TABLECOUNTER.step()
		let ctr = headingCounter + TABLECOUNTER.get()
		ctr.last() += 1
		block[
			#text( fill:tuniPurple)[*#it.supplement #array2SectionNumbering(ctr,inAppendix):* ]
			#it.caption.body
		]
		block(it.body)
	}
	else if it.kind == raw {
		set figure.caption( position : bottom )
		CODECOUNTER.step()
		let ctr = headingCounter + CODECOUNTER.at(figloc)
		ctr.last() += 1
		block(it.body)
		block[
			#text( fill:tuniPurple)[*#codeSupplement #array2SectionNumbering(ctr,inAppendix):* ]
			#it.caption.body
		]
	}
	else if it.kind == TAUTHEOREMKIND {
		TAUTHEOREMCOUNTER.step()
		it
	}
	else {
		UNKNOWNCOUNTER.step()
		let ctr = headingCounter + UNKNOWNCOUNTER.get()
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

#let headingShowRule(language, figNumberWithinLevel, eqNumberWithinLevel, it) = [

	#let appendixPrefix = appendixPrefixFn(language)

	#if it.level == 1 {
		pagebreak(weak: true)
	}

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
	#if it.outlined and it.level <= figNumberWithinLevel {
		IMAGECOUNTER.update( 0 )
		TABLECOUNTER.update( 0 )
		CODECOUNTER.update( 0 )
		TAUTHEOREMCOUNTER.update( 0 )
		UNKNOWNCOUNTER.update( 0 )
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
	#v(headspacing, weak: true)
	#block[
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
	#v(headspacing, weak:true)
]

/**
 *
 * Defines how outline entries are to be displayed. This is to be used within a
 * show rule, so that context and therefore information about page numbers and
 * such can be resolved.
 *
***/

#let outlineEntryShowRule(language, figNumberWithinLevel, it) = {
	let codeSupplement = codeSupplementFn(language)
	let appendixPrefix = appendixPrefixFn(language)
	set text( size : 13pt )
	let el = it.element
	let elementLocation = el.location()
	let elementPageNum = MAINMATTERPAGENUMBERCOUNTER.at(elementLocation).first() - 1
	let headingCounter = counter(heading).at(elementLocation)
	let headingCounter = headingCounter.slice(
		0,
		calc.min(figNumberWithinLevel,headingCounter.len())
	)
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
		let carray = headingCounter + carray
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
		let tsize = if el.level == 1 { 14pt } else if el.level == 2 { 14pt } else if el.level == 3 { 14pt } else { 14pt }
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
				#text(
					fill: tuniPurple,
					size: tsize,
					weight: "bold",
				)[
					#prefix
					#numbering#colon
				]
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
	v(0.75cm, weak:true) + block[#h((it.level - 1) * 1em)#entry]
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

#let quoteShowRule(it) = if it.block {
  block(
    stroke: (left: tuniPurple + 2pt),
    inset: (
      x : 0.5em,
      y : 0.3em
    ),
  )[
    #it.body

    #if it.attribution != none [
      --#it.attribution
    ]
  ]
} else {
  it
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
		paper: if thesisTypeToIntFn(thesisType) < phdThesisTypeInt {
			"a4"
		} else {
			"iso-b5"
		},
		header: none,
		footer: none,
		margin: (left: 4cm, top: 4.5cm,),
		numbering: none,
	)

	place(top + left, float:true, dx: -3.5cm, dy:-3.5cm, image("template/images/tau-logo-fin-eng.svg", width : 8cm))

	align(right)[
		#text(
			20pt,
			author
		)
		#v(2cm, weak: true)
		#set par( leading : 0.4em )
		#text( 25pt, fill: tuniPurple, weight: "bold" )[
			#smallcaps(
				if language == finnish {
					otsikko
				} else if language == english {
					title
				}
			)
		]
		#v(1cm, weak: true)
		#text(20pt, fill: tuniPurple)[
			#smallcaps(
				if language == finnish {
					alaotsikko
				} else if language == english {
					subtitle
				}
			)
		]
		#v(1fr)
		#set par( leading : 0.65em )
		#text(12pt)[
			#if language == english [
				#thesisType\
				#university\
				#faculty\
				#date.display("[month repr:long] [year]")
			] else if language == finnish [
				#työnTyyppi\
				#koulu\
				#tiedekunta\
				#localizeMonthFi(date.month()) #date.year()
			]
		]
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

	#set par(justify: false)

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

	#set par(justify: true)

	#abstractContent

	#set par(justify: false)

	#if language == finnish [

		*Avainsanat:* #avainsanat.join(", ")

		Tämän julkaisun alkuperäisyys on tarkastettu Turnitin Originality -ohjelmalla.

	] else [

		*Keywords:* #keywords.join(", ")

		The originality of this thesis has been checked using the Turnitin Originality service.

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

	grid(
		stroke: none,
		columns: (10%, auto, 85%),
		align: (top+right, top + center, top+left),
		column-gutter: 0.5em,
		row-gutter: 0.75cm,
		.. for key in glossaryDict.keys().sorted() {
			let name = glossaryDict.at(key).name
			let description = glossaryDict.at(key).description
			(
				text(fill: tuniPurple, weight: "bold", hyphenate: false)[#name],
				[~],
				[#description],
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
	let figNumberWithinLevel = FIGNUMBERWITHINLEVELSTATE.get()
	let headingCounter = counter(heading).get()
	let headingCounter = headingCounter.slice(
		0,
		calc.min(figNumberWithinLevel,headingCounter.len())
	)
	let theoremCounter = headingCounter + TAUTHEOREMCOUNTER.get()
	theoremCounter.last() += 1
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
						#text(weight: "bold", fill: tuniPurple)[#supplement #array2SectionNumbering(theoremCounter,inAppendix)]
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
#let pageSettings(docPart, physicallyPrinted, printTwoSided, language, displayLinkToToC, thesisTypeNum, it) = {
	let prevDocPart = docPart - 1
	set page(
		paper: if thesisTypeNum < phdThesisTypeInt {
			"a4"
		} else {
			"iso-b5"
		},
		numbering: none,
		binding: right,
		header: context {
			if docPart == DOCPREAMBLEPART {
				PREFACEPAGENUMBERCOUNTER.step()
			}
			if docPart >= MAINMATTERPART {
				MAINMATTERPAGENUMBERCOUNTER.step()
			}
			let (pageNum, numberingStr) = {
				if docPart in (TITLEPAGEPART, DOCPREAMBLEPART) {
					(PREFACEPAGENUMBERCOUNTER,"i")
				}
				else if docPart >= MAINMATTERPART {
					(MAINMATTERPAGENUMBERCOUNTER,"1")
				}
				else {
					(none,"")
				}
			}
			let headingsBefore = query(
				heading.where(level: 1).before(here())
			)
			let headingsAfter = query(
				heading.where(level: 1).after(here()),
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
			let docPageNum = counter(page).get().last() + 1
			let pageOrientationFlag = if prevDocPart < MAINMATTERPART { 0 } else { 0 }
			let gridGutter = 0.2em
			let verticalAlignment = top
			if physicallyPrinted and printTwoSided {
				if calc.rem(docPageNum,2) == pageOrientationFlag {
					grid(
						columns: (9fr, 1fr),
						align: (left+verticalAlignment,right+verticalAlignment),
						gutter: gridGutter,
						innerText,
						pageNum.display(numberingStr),
					)
				} else {
					grid(
						columns: (1fr, 9fr),
						align: (left+verticalAlignment,right+verticalAlignment),
						gutter: gridGutter,
						pageNum.display(numberingStr),
						innerText,
					)
				}
			} else {
					grid(
						columns: (9fr, 1fr),
						align: (left+verticalAlignment,right+verticalAlignment),
						gutter: gridGutter,
						innerText,
						pageNum.display(numberingStr),
					)
			}
		},
		footer: if docPart >= MAINMATTERPART and not physicallyPrinted {
			let buttonFillColor = if displayLinkToToC { tuniPurple } else { white }
			let dx = if thesisTypeNum < phdThesisTypeInt { -3.7cm } else { -1.7cm }
			show link: set text(fill: white, size:9pt)
			place(horizon + left, dx: dx, dy: 0.4cm)[
				#link(
					label("outlineLabel"),
					box(stroke: buttonFillColor, fill:buttonFillColor,inset:0.3em,radius:0.2em)[
						#sym.arrow.t
						#if language == finnish [Takaisin sisällykseen] else [Back to Contents]
					]
				)
			]
		},
		margin: if thesisTypeNum < phdThesisTypeInt {
			if physicallyPrinted and printTwoSided {
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
		} else {
			if physicallyPrinted and printTwoSided {
				(
					top: 2cm,
					bottom: 3cm,
					inside: 2cm,
					outside: 2cm,
				)
			} else {
				(
					top: 2cm,
					bottom: 3cm,
					left: 2cm,
					right: 2cm,
				)
			}
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
	description: "A short description of the document.",
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
	printTwoSided: false,
	showParagraphLineNumbers: false,
	sijainti: [Tampereella],
	subtitle: [Subtitle],
	tekoälynKäyttöTeksti: [],
	textFont : ("Roboto", "Open Sans", "Arial", "Helvetica", "Fira Sans", "DejaVu Sans"),
	thesisType: mastersThesisType,
	tiedekunta: [Tiedekunta],
	tiivistelmänSisältö: [],
	title: "Thesis template",
	työnTyyppi: diplomiTyönTyyppi,
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

	thesisTypeValidationFn(thesisType, työnTyyppi, language, includeFinnishAbstract)

	let thesisTypeNum = thesisTypeToIntFn(thesisType)

	set document(
		author: author,
		title: if language == finnish {
			otsikko + if alaotsikko != none [: #alaotsikko]
		} else {
			title + if subtitle != none [: #subtitle]
		},
		keywords: if language == finnish {
			avainsanat + keywords
		} else {
			keywords + avainsanat
		},
		date: datetime.today(),
		description: description,
	)

	// Expose document metadata to typst query CLI utility.

	[
		#metadata(str(alaotsikko)) #label("alaotsikko")
		#metadata(str(author)) #label("author")
		#metadata(avainsanat.join(", ")) #label("avainsanat")
		#metadata(str(citationStyle)) #label("citationStyle")
		#metadata(str(description)) #label("description")
		#metadata(str(eqNumberWithinLevel)) #label("eqNumberWithinLevel")
		#metadata(str(faculty)) #label("faculty")
		#metadata(str(figNumberWithinLevel)) #label("figNumberWithinLevel")
		#metadata(keywords.join(", ")) #label("keywords")
		#metadata(str(koulu)) #label("koulu")
		#metadata(str(language)) #label("language")
		#metadata(str(location)) #label("location")
		#metadata(str(otsikko)) #label("otsikko")
		#metadata(str(int(printTwoSided))) #label("printTwoSided")
		#metadata(str(sijainti)) #label("sijainti")
		#metadata(str(subtitle)) #label("subtitle")
		#metadata(str(thesisType)) #label("thesisType")
		#metadata(str(tiedekunta)) #label("tiedekunta")
		#metadata(str(title)) #label("title")
		#metadata(str(työnTyyppi)) #label("työnTyyppi")
		#metadata(str(university)) #label("university")
		#metadata(str(int(usedAI))) #label("usedAI")
	]

	// Color different kinds of links.

	show link: set text( fill: rgb("#0038FF") )

	show cite: set text( fill: tuniPurple )

	// Prettify emphasized text.

	show emph: set text(fill:tuniPurple)

	// Initialize helper counters in array format.

	IMAGECOUNTER.update(0)
	TABLECOUNTER.update(0)
	CODECOUNTER.update(0)
	TAUTHEOREMCOUNTER.update(0)
	UNKNOWNCOUNTER.update(0)

	FIGNUMBERWITHINLEVELSTATE.update(figNumberWithinLevel)

	// Update helper counters when associated figures are shown.

	show figure: it => figShowRule(language,figNumberWithinLevel,it)

	// Note: this automatic addition of page breaks before level
	// 1 headings might be partially responsible for the
	// introduction page numbering bug discussed below.

	show heading: it => headingShowRule(language, figNumberWithinLevel, eqNumberWithinLevel, it)

	show raw: it => rawShowRule(codeFont,it)

	set text( font: textFont, lang: language, size: 11pt )

	show math.equation: set text(font: mathFont, size: 12pt)

	counter(page).update(0)

	show: doc => pageSettings(TITLEPAGEPART, physicallyPrinted, printTwoSided, language, displayLinkToToC, thesisTypeNum, doc)

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

	show: doc => pageSettings(DOCPREAMBLEPART, physicallyPrinted, printTwoSided, language, displayLinkToToC, thesisTypeNum, doc)

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

	show outline.entry: it => outlineEntryShowRule(language, figNumberWithinLevel, it)

	// Apply new appearance to block quotes.

	show quote: quoteShowRule

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

	show: doc => pageSettings(MAINMATTERPART, physicallyPrinted, printTwoSided, language, displayLinkToToC, thesisTypeNum, doc)

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

	show ref : it => refShowRule( it, language, figNumberWithinLevel, eqNumberWithinLevel : eqNumberWithinLevel)

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

	IMAGECOUNTER.update(0)
	TABLECOUNTER.update(0)
	CODECOUNTER.update(0)
	TAUTHEOREMCOUNTER.update(0)
	UNKNOWNCOUNTER.update(0)

	counter(heading).update( 0 )

	counter(math.equation).update( 0 )

	FIGNUMBERWITHINLEVELSTATE.update(figNumberWithinLevel)

	set heading(numbering: "A.1", supplement: none)

	show heading : it => headingShowRule(language, figNumberWithinLevel, eqNumberWithinLevel, it)

	set math.equation(
		numbering: nn => context {
			let ctrarr = counter(heading).get()
			let ctrarr = ctrarr.slice(0,calc.min(eqNumberWithinLevel,ctrarr.len()))
			"(" + array2SectionNumbering(ctrarr, true) + "." + str(nn) + ")"
		},
		supplement: none
	)

	show ref : it => refShowRule( it, language, figNumberWithinLevel, eqNumberWithinLevel : eqNumberWithinLevel)

	DOCPARTSTATE.update(APPENDIXPART)

	doc

}
