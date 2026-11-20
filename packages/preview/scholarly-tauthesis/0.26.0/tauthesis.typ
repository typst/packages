/** tauthesis.typ
 *
 * This module defines the Tampere University thesis template structure. You
 * should not need to touch this file. Define your own commands in preamble.typ
 * instead.
 *
***/

//// Counters and kinds

#let UNKNOWNSUPPLEMENT = "Unknown"

#let IMAGECOUNTER = counter("IMAGECOUNTER")

#let TABLECOUNTER = counter("TABLECOUNTER")

#let CODECOUNTER = counter("CODECOUNTER")

#let TAUTHEOREMCOUNTER = counter("tautheorem")

#let PUBLICATIONCOUNTER = counter("PUBLICATIONCOUNTER")

#let PUBLICATIONPAGECOUNTER = counter("PUBLICATIONPAGECOUNTER")

#let SUBFIGURECOUNTER = counter("SUBFIGURECOUNTER")

#let UNKNOWNCOUNTER = counter("UNKNOWNCOUNTER")

#let TAUTHEOREMKIND = "TAUTHEOREMKIND"

#let PUBLICATIONKIND = "PUBLICATIONKIND"

#let SUBFIGUREKIND = "SUBFIGUREKIND"

#let PREFACEPAGENUMBERCOUNTER = counter("PREFACEPAGENUMBERCOUNTER")

#let MAINMATTERPAGENUMBERCOUNTER = counter("MAINMATTERPAGENUMBERCOUNTER")

#let INLINECODELUMABACKGROUND = 240

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
 * 6 ↦ publications
 *
***/

#let INITIALPART = 0
#let TITLEPAGEPART = 1
#let FRONTMATTERPART = 2
#let MAINMATTERPART = 3
#let BIBLIOGRAPHYPART = 4
#let APPENDIXPART = 5
#let PUBLICATIONMATTERPART = 6

#let DOCPARTSTATE = state("DOCPARTSTATE", INITIALPART)

// These states keep track of whether we are in a publication main matter or appendix.

#let PUBLICATIONMAINMATTERPART = 7
#let PUBLICATIONAPPENDIXPART = 8
#let UNDEFINEDPUBLICATIONPART = 9

#let PUBLICATIONPART = state("PUBLICATIONPART", UNDEFINEDPUBLICATIONPART)

// This global state is needed so that theorem blocks can fetch the maximum
// heading level under which they should be numbered.

#let FIGNUMBERWITHINLEVELSTATE = state("FIGNUMBERWITHINLEVELSTATE")

/**
 * Used to store the current chapter heading for display in headers.
***/
#let SHORTCHAPTERHEADINGSTATE = state("SHORTCHAPTERHEADINGSTATE", none)

//// Thesis types.

/**
 * The English thesis types are the only template inputs: the Finnish
 * thesis type shown on the Finnish title page and abstract is derived
 * from the English one automatically.
***/

#let bachelorOfTechnologyThesisType = "Bachelor's Thesis in Technology"

#let bachelorOfPhilosophyThesisType = "Bachelor's Thesis"

#let bachelorOfMedicineThesisType = "Bachelor's Thesis in Medicine"

#let masterOfTechnologyThesisType = "Master's Thesis in Technology"

#let masterOfPhilosophyThesisType = "Master's Thesis"

#let masterOfMedicineThesisType = "Master's Thesis in Medicine"

#let licentiateOfTechnologyThesisType = "Licentiate Thesis in Technology"

#let licentiateOfPhilosophyThesisType = "Licentiate Thesis"

#let licentiateOfHealthSciencesThesisType = "Licentiate Thesis in Health Sciences"

#let doctoralThesisType = "Doctoral Thesis"

#let acceptableThesisTypes = (bachelorOfTechnologyThesisType, bachelorOfPhilosophyThesisType, bachelorOfMedicineThesisType, masterOfTechnologyThesisType, masterOfPhilosophyThesisType, masterOfMedicineThesisType, licentiateOfTechnologyThesisType, licentiateOfPhilosophyThesisType, licentiateOfHealthSciencesThesisType, doctoralThesisType)

/**
 * The Finnish translations of the thesis types. These are no longer
 * template inputs; thesisTypeToTyönTyyppiFn maps the English thesis
 * type to its translation.
***/

#let kandidaatinTyönTyyppi = "Kandidaatintyö"

#let kandidaatinTutkielmanTyyppi = "Kandidaatintutkielma"

#let laaketieteenKandidaatinOpinnaytetyonTyyppi = "Lääketieteen kandidaatin opinnäytetyö"

#let diplomiTyönTyyppi = "Diplomityö"

#let maisterinTyönTyyppi = "Pro gradu -tutkielma"

#let syventavanOpinnaytetyonTyyppi = "Syventävä opinnäytetyö"

#let lisensiaatinTyönTyyppi = "Lisensiaatintyö"

#let lisensiaatinTutkielmanTyyppi = "Lisensiaatintutkielma"

#let lisensiaatinTutkimuksenTyyppi = "Lisensiaatintutkimus"

#let tohtorinTyönTyyppi = "Väitöskirja"

// Maps each English thesis type to its Finnish translation.

#let thesisTypeTranslations = (
	(bachelorOfTechnologyThesisType): kandidaatinTyönTyyppi,
	(bachelorOfPhilosophyThesisType): kandidaatinTutkielmanTyyppi,
	(bachelorOfMedicineThesisType): laaketieteenKandidaatinOpinnaytetyonTyyppi,
	(masterOfTechnologyThesisType): diplomiTyönTyyppi,
	(masterOfPhilosophyThesisType): maisterinTyönTyyppi,
	(masterOfMedicineThesisType): syventavanOpinnaytetyonTyyppi,
	(licentiateOfTechnologyThesisType): lisensiaatinTyönTyyppi,
	(licentiateOfPhilosophyThesisType): lisensiaatinTutkielmanTyyppi,
	(licentiateOfHealthSciencesThesisType): lisensiaatinTutkimuksenTyyppi,
	(doctoralThesisType): tohtorinTyönTyyppi,
)

#let bachelorsThesisTypeInt = 1
#let mastersThesisTypeInt = 2
#let licentiateThesisTypeInt = 3
#let doctoralThesisTypeInt = 4

//// Command-line overrides (sys.inputs).

/**
 *
 * Typst's sys.inputs dictionary collects the key=value pairs given
 * to the compiler with --input key=value. The template consults it
 * to override the settings of meta.typ for automated test compiles:
 * a pipeline can, for example, compile the example thesis once per
 * thesis type without editing a single file. The mechanism is
 * deliberately invisible to the document author: a key that is not
 * given on the command line leaves the meta.typ value untouched, so
 * what a typical user compiles is exactly what meta.typ says, and an
 * overridden value passes through the same validation as one read
 * from meta.typ.
 *
 * Command-line values are always strings, so each override is
 * converted to the type of the meta.typ value it replaces:
 *
 * - booleans are written true or false;
 * - integers (the numbering levels) are written as decimal digits;
 * - arrays (keywords and avainsanat) are written comma-separated;
 * - strings and content are passed through as written;
 * - the thesis type is written as the name of one of the module's
 *   thesis type constants and mapped to the constant itself.
 *
 * Settings that are not simple values are not overridable from the
 * command line: the examiners, the glossary and publication
 * dictionaries, the included content files, and citationStyle and
 * bibFileSuffix, which main.typ consumes in its own bibliography
 * call.
 *
***/

// Command-line names of the thesis type constants.

#let thesisTypeInputNames = (
	bachelorOfTechnologyThesisType: bachelorOfTechnologyThesisType,
	bachelorOfPhilosophyThesisType: bachelorOfPhilosophyThesisType,
	bachelorOfMedicineThesisType: bachelorOfMedicineThesisType,
	masterOfTechnologyThesisType: masterOfTechnologyThesisType,
	masterOfPhilosophyThesisType: masterOfPhilosophyThesisType,
	masterOfMedicineThesisType: masterOfMedicineThesisType,
	licentiateOfTechnologyThesisType: licentiateOfTechnologyThesisType,
	licentiateOfPhilosophyThesisType: licentiateOfPhilosophyThesisType,
	licentiateOfHealthSciencesThesisType: licentiateOfHealthSciencesThesisType,
	doctoralThesisType: doctoralThesisType,
)

/**
 *
 * Overrides `current` with the command-line input `key`, if one was
 * given, converting the input string to the type of `current`.
 *
***/

#let sysInput(key, current) = if key not in sys.inputs {
	current
} else {
	let raw = sys.inputs.at(key)
	let t = type(current)
	if t == bool {
		if raw == "true" {
			true
		} else if raw == "false" {
			false
		} else {
			panic("tauthesis: the command-line input \"" + key + "\" must be true or false; got \"" + raw + "\".")
		}
	} else if t == int {
		if not raw.contains(regex("^[0-9]+$")) {
			panic("tauthesis: the command-line input \"" + key + "\" must be a non-negative integer; got \"" + raw + "\".")
		}
		int(raw)
	} else if t == array {
		raw.split(",").map(s => s.trim())
	} else if t == str or t == content or current == none {
		raw
	} else {
		panic("tauthesis: the command-line input \"" + key + "\" cannot override a value of type " + str(t) + ".")
	}
}

/**
 *
 * Like sysInput, but for the thesis type, which is given as the name
 * of one of the thesis type constants.
 *
***/

#let thesisTypeSysInput(current) = if "thesisType" not in sys.inputs {
	current
} else {
	let raw = sys.inputs.at("thesisType")
	if raw in thesisTypeInputNames {
		thesisTypeInputNames.at(raw)
	} else {
		panic("tauthesis: unknown command-line thesis type \"" + raw + "\". Valid values are: " + thesisTypeInputNames.keys().join(", ") + ".")
	}
}

/**
 *
 * Whether the publication pages are attached to the document. The
 * compilationThesis and attachPublications values are read through
 * the command-line overrides, so a command-line input keeps the
 * attached publications and the frontmatter publication list in
 * agreement.
 *
***/

#let includePublicationPages(thesisTypeInteger, compilationThesis, attachPublications) = {
	let compilationThesis = sysInput("compilationThesis", compilationThesis)
	let attachPublications = sysInput("attachPublications", attachPublications)
	thesisTypeInteger >= licentiateThesisTypeInt and compilationThesis and attachPublications
}

/**
 *
 * Converts a given thesis type string to an integer for easy comparisons.
 *
***/

#let thesisTypeToIntFn(thesisType) = {
	let thesisType = thesisTypeSysInput(thesisType)
	if thesisType in (bachelorOfTechnologyThesisType, bachelorOfPhilosophyThesisType, bachelorOfMedicineThesisType) {
		bachelorsThesisTypeInt
	} else if thesisType in (masterOfTechnologyThesisType, masterOfPhilosophyThesisType, masterOfMedicineThesisType) {
		mastersThesisTypeInt
	} else if thesisType in (licentiateOfTechnologyThesisType, licentiateOfPhilosophyThesisType, licentiateOfHealthSciencesThesisType) {
		licentiateThesisTypeInt
	} else if thesisType == doctoralThesisType {
		doctoralThesisTypeInt
	} else {
		panic("Unknown thesis type " + str(thesisType) + ". Cannot convert to integer.")
	}
}

/**
 *
 * Derives the Finnish thesis type from the given English thesis type.
 *
***/

#let thesisTypeToTyönTyyppiFn(thesisType) = if thesisType in thesisTypeTranslations {
	thesisTypeTranslations.at(thesisType)
} else {
	panic("Unknown thesis type " + str(thesisType) + ". Cannot derive the Finnish thesis type from it.")
}

/**
 *
 * Converts a given thesis type string to a page size.
 *
***/

#let thesisTypeIntToPageSizeFn(thesisTypeInt) = {
	if thesisTypeInt <= licentiateThesisTypeInt {
		"a4"
	} else {
		"iso-b5"
	}
}

/**
 *
 * Converts a given thesis type integer to a page margin dictionary.
 *
***/

#let thesisTypeIntToMarginsFn(physicallyPrinted: false, printTwoSided: true, thesisTypeInt) = {
	// Horizontal-margin principle: printed documents have unequal
	// horizontal margins with a binding allowance toward the
	// binding side (mirrored between the two sides in two-sided
	// output, on the left of every page in one-sided output);
	// electronic documents have equal horizontal margins (the
	// smaller of the two printed horizontal margins).
	if thesisTypeInt < licentiateThesisTypeInt {
		if physicallyPrinted {
			if printTwoSided {
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
			(
				top: 2.5cm,
				bottom: 2.5cm,
				left: 2cm,
				right: 2cm,
			)
		}
	} else {
		if physicallyPrinted {
			if printTwoSided {
				(
					top: 2cm,
					bottom: 3cm,
					inside: 2.5cm,
					outside: 2cm,
				)
			} else {
				(
					top: 2cm,
					bottom: 3cm,
					left: 2.5cm,
					right: 2cm,
				)
			}
		} else {
			(
				top: 2cm,
				bottom: 3cm,
				left: 2cm,
				right: 2cm,
			)
		}
	}
}

/**
 *
 * Makes sure that the given thesis type is valid.
 *
***/
#let thesisTypeValidationFn(thesisType) = {

	assert(
		thesisType in acceptableThesisTypes,
		message: "The given thesis type \""
			+ str(thesisType)
			+ "\" is not one of the acceptable ones "
			+ acceptableThesisTypes.join(", ", last: " or ")
			+ ". Note the capitalization. The Finnish thesis type is derived automatically from the English one."
	)

}

//// Constants

#let templateName = "tauthesis"

#let tuniPurple = rgb(78,0,148)

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
	upper[Liite]
} else {
	upper[Appendix]
}

//// Utility functions

// These functions give Finnish month names by month numbers.
// https://typst.app/docs/reference/foundations/datetime/
// Unfortunately, when choosing the word representation, it can
// currently only display the English version. In the future, it is
// planned to support localization.

#let monthNamesFi = (
	"Tammikuu",
	"Helmikuu",
	"Maaliskuu",
	"Huhtikuu",
	"Toukokuu",
	"Kesäkuu",
	"Heinäkuu",
	"Elokuu",
	"Syyskuu",
	"Lokakuu",
	"Marraskuu",
	"Joulukuu",
)

#let monthNamesFiPartitive = (
	"tammikuuta",
	"helmikuuta",
	"maaliskuuta",
	"huhtikuuta",
	"toukokuuta",
	"kesäkuuta",
	"heinäkuuta",
	"elokuuta",
	"syyskuuta",
	"lokakuuta",
	"marraskuuta",
	"joulukuuta",
)

// Gives a Finnish month name in the nominative case, e.g. "Tammikuu".

#let localizeMonthFi(month) = {
	if month < 1 or month > 12 {
		panic("Month must be between [1,12]")
	}
	monthNamesFi.at(month - 1)
}

// Gives a Finnish month name in the partitive case, e.g. "tammikuuta".

#let localizeMonthFiPartitive(month) = {
	if month < 1 or month > 12 {
		panic("Month must be between [1,12]")
	}
	monthNamesFiPartitive.at(month - 1)
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
	for _ in range(nnquo) { string += letter }
	string
}

/**
 *
 * When given an array of integers, returns a string that might be
 * used as a section number.
 *
***/

#let array2SectionNumbering(arr, inAppendix) = {
	if not ( arr.all( elem => type(elem) == int ) ) { panic("Array elements used to construct section numberings need to contain integers.") }
	let firstnum = arr.first(default: none)
	let chaptersymbol = if firstnum == none {""} else {
		if inAppendix {
			int2AppendixLetter(firstnum)
		} else {
			str(firstnum)
		}
	}
	let rest = if arr.len() > 0 {arr.slice(1).map(str)} else {()}
	let symbols = (chaptersymbol, ..rest)
	symbols.join(".")
}

/**
 *
 * Retrieves the counter of a figure based on its kind. Subfigures are
 * intentionally mapped to the unknown-kind counter: subfigure captions are
 * numbered via SUBFIGURECOUNTER separately, and figure show rules step the
 * unknown-kind counter for subfigures on purpose (see figShowRule).
 *
***/

#let figureCounterFromKind(kind) = {
	if kind == image {
		IMAGECOUNTER
	}
	else if kind == table {
		TABLECOUNTER
	}
	else if kind == raw {
		CODECOUNTER
	}
	else if kind == TAUTHEOREMKIND {
		TAUTHEOREMCOUNTER
	}
	else if kind == PUBLICATIONKIND {
		PUBLICATIONCOUNTER
	}
	else {
		UNKNOWNCOUNTER
	}
}

/**
 * Resets all per-chapter figure-related counters to zero.
***/
#let resetFigureCounters() = {
	IMAGECOUNTER.update(0)
	TABLECOUNTER.update(0)
	CODECOUNTER.update(0)
	TAUTHEOREMCOUNTER.update(0)
	UNKNOWNCOUNTER.update(0)
}

/**
 * Validates that a "number within level" argument is in the range 0..4.
***/
#let validateNumberWithinLevel(name, value) = {
	if value < 0 or value > 4 {
		panic("Argument " + name + " must be in the set {0,1,2,3,4}. Received " + str(value) + ".")
	}
}

/**
 * Extracts the text of an optional subtitle given as a string or content,
 * returning the empty string if there is no subtitle text.
***/
#let subtitleText(subtitle) = {
	if subtitle == none {
		""
	} else if type(subtitle) == content {
		if "body" in subtitle.fields() {
			if subtitle.body.trim().len() > 0 { subtitle.body } else { "" }
		} else if "text" in subtitle.fields() {
			if subtitle.text.trim().len() > 0 { subtitle.text } else { "" }
		} else {
			""
		}
	} else if type(subtitle) == str and subtitle.trim().len() > 0 {
		subtitle
	} else {
		""
	}
}

/**
 * Formats an optional subtitle as a ": subtitle" suffix, or an empty string.
***/
#let subtitleSuffix(subtitle) = {
	let text = subtitleText(subtitle)
	if text != "" { ": " + text } else { "" }
}

/**
 * Displays inline code inside headings, outline entries and similar places
 * where code blocks are not allowed.
***/
#let inlineCodeShowRule(codeFont, fontSize, it) = if it.block {
	panic("Code blocks are not allowed here!")
} else {
	set text(font: codeFont, size: fontSize)
	box(
		inset : (x : 0.2 * fontSize),
		outset : (y : 0.2 * fontSize),
		fill : luma(INLINECODELUMABACKGROUND),
		radius : 0.25 * fontSize,
		it.text
	)
}

/**
 * Builds the numbering function of display equations. The section prefix is
 * taken from the given number of leading levels of the heading counter;
 * `skip-first-levels` drops leading counter components (used in publication
 * matter, where level 1 headings act as publication titles).
***/
#let equationNumberingFn(withinLevel, inAppendix, skipFirstLevels) = nn => context {
	let ctrarr = counter(heading).get()
	let ctrarr = ctrarr.slice(
		skipFirstLevels,
		calc.min(withinLevel + skipFirstLevels, ctrarr.len())
	)
	{
		"("
		array2SectionNumbering(ctrarr, inAppendix)
		if ctrarr.len() > 0 {"."}
		str(nn)
		")"
	}
}

/**
 * Joins the authors of a publication into a single string. Author lists
 * longer than `et-al-threshold` are cut to the first author followed by
 * "et al.".
***/
#let authorsToString(citeKey, authors, et-al-threshold: 10) = {
	if type(authors) == str {
		authors
	} else if type(authors) == array {
		if et-al-threshold != none and authors.len() > et-al-threshold {
			authors.first() + " et al."
		} else {
			authors.join(", ", last: " and ")
		}
	} else {
		panic("The author field of publication " + citeKey + " needs to be given as a string or an array of strings.")
	}
}


/**
 *
 * Displays the AI disclaimer page, where students explain where and how they
 * used AI in producing their thesis, if they did.
 *
 ***/
#let aiDisclaimerPage(usedAI, language, tekoälynKäyttöTeksti, aiDisclaimerContents) = {


	let ballotBoxSettings = (
		columns: (5%,1.5%,90%),
		row-gutter: 0.8em,
		align: (right+horizon,center+horizon,left+horizon),
	)

	let strings = if language == finnish {
		(
			title: [Tekoälyn käyttö tässä työssä],
			question: [Opinnäytteessäni on käytetty tekoälysovelluksia:],
			yes: [Kyllä],
			no: [Ei],
			risksTitle: [Riskien tiedostaminen],
			risksText: [Olen tietoinen siitä, että olen täysin vastuussa koko opinnäytteeni sisällöstä, mukaan lukien osat, joissa on hyödynnetty tekoälyä, ja hyväksyn vastuun mahdollisista eettisten ohjeiden rikkomuksista.],
		)
	} else {
		(
			title: [Use of artificial intelligence in this work],
			question: [Artificial intelligence (AI) has been used in my thesis:],
			yes: [Yes],
			no: [No],
			risksTitle: [Acknowledgement of risks],
			risksText: [I acknowledge that I am fully responsible for the entire content of my thesis, including the parts generated by AI, and accept accountability for any violations of ethical standards in publications.],
		)
	}


	heading(strings.title)

	strings.question

	grid(
		..ballotBoxSettings,
		if usedAI { sym.ballot.cross } else { sym.ballot },
		[~],
		strings.yes,
		if usedAI { sym.ballot } else { sym.ballot.cross },
		[~],
		strings.no,
	)

	if usedAI {
		if language == finnish { tekoälynKäyttöTeksti } else { aiDisclaimerContents }
	}

	heading(level: 2, strings.risksTitle)

	strings.risksText
}

#let subfigure = figure.with(
	supplement: none,
	kind: SUBFIGUREKIND,
	numbering: "(a)",
)

/**
 * This function should be used to typeset captions of
 * all figures that have a very long caption. The short
 * alternative caption will be displayed in a related list
 * of figures.
***/

#let figureCaption(long: none, short: none) = {
	assert(
		long !=none,
		message: "figureCaption: A figure needs to have at least a long (full) caption. Use the long argument of this function to enter one."
	)
	context if DOCPARTSTATE.get() < MAINMATTERPART {
		if short == none {
			long
		} else {
			short
		}
	} else {
		long
	}
}

/**
 *
 * Defines how a cross-reference within a document is laid out.
 *
***/

#let refShowRule(it, language, figNumberWithinLevel, eqNumberWithinLevel) = {

	let appendixPrefix = appendixPrefixFn(language)

	show link: set text( fill: black, weight: "regular" )

	let el = it.element

	if el != none {
		let elementLocation = el.location()
		let docPart = DOCPARTSTATE.at(elementLocation)
		let inAppendix = docPart == APPENDIXPART
		let inPublicationAppendix = PUBLICATIONPART.at(elementLocation) == PUBLICATIONAPPENDIXPART
		let inPublications = docPart >= PUBLICATIONMATTERPART
		let headingCounter = counter(heading).at(elementLocation)
		let headingCounterStart = if inPublications { 1 } else { 0 }
		let headingCounterEnd = calc.min(
			headingCounterStart + if el.func() == figure {
				figNumberWithinLevel
			} else if el.func() == math.equation {
				eqNumberWithinLevel
			} else {
				0
			},
			headingCounter.len(),
		)
		let truncatedHeadingCounter = headingCounter.slice(
			headingCounterStart,
			headingCounterEnd,
		)
		let refText = if el.func() == figure {
			let (carray, elementSupplement) = if el.kind == raw {
				(
					CODECOUNTER.at(elementLocation),
					codeSupplementFn(language),
				)
			}
			else if el.kind == SUBFIGUREKIND {
				// For this one we need a parent figure counter value as well.
				// There is no directly accessible concept of a parent element in Typst,
				// so we will query figures of kinds that can contain subfigures and pick
				// the one that comes just before this subfigure.
				let figuresBefore = query(
					selector(figure)
					.before(elementLocation)
				)
				let parentFigure = figuresBefore
					.filter(x => x.kind != SUBFIGUREKIND)
					.last()
				let parentCounter = figureCounterFromKind(parentFigure.kind)
				let parentCounterValue = parentCounter.at(parentFigure.location())
				(
					parentCounterValue + SUBFIGURECOUNTER.at(elementLocation),
					parentFigure.supplement,
				)
			}
			else {
				(
					figureCounterFromKind(el.kind).at(elementLocation),
					el.supplement,
				)
			}
			let supplement = if it.citation.supplement != none { it.citation.supplement } else { elementSupplement }
			carray.last() += 1
			// If we are within a subfigure, also increment parent figure counter.
			if el.kind == SUBFIGUREKIND {
				carray.first() += 1
			}
			{
				supplement
				if supplement != [] { sym.space.nobreak } else { none }
				if figNumberWithinLevel > 0 {
					array2SectionNumbering(
						truncatedHeadingCounter,
						(inAppendix or inPublicationAppendix)
					)
				}
				if figNumberWithinLevel > 0 {"."}
				carray.map(str).first()
				if el.kind == SUBFIGUREKIND {
					"." + numbering("a", carray.last())
				} else {
					none
				}
			}
		}
		else if el.func() == heading {
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
				array2SectionNumbering(headingCounter, inAppendix or inPublicationAppendix)
			)
		}
		else if el.func() == math.equation {
			let eqctr = counter(math.equation).at(elementLocation)
			let equationNum = {
				if eqNumberWithinLevel > 0 {
					array2SectionNumbering(
						truncatedHeadingCounter,
						inAppendix or inPublicationAppendix
					)
					"."
				}
				str(eqctr.last())
			}
			let numberText = "(" + equationNum + ")"
			math.equation(
				alt: numberText,
				$numberText$
			)
		}
		else {
			if DOCPARTSTATE.at(here()) < MAINMATTERPART {
				none
			} else {
				it
			}
		}
		link(elementLocation,refText)
	}
	else {
		if DOCPARTSTATE.at(here()) < MAINMATTERPART {
			none
		} else {
			it
		}
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
	let inPublications = docPart >= PUBLICATIONMATTERPART
	let inPublicationAppendix = PUBLICATIONPART.at(figloc) == PUBLICATIONAPPENDIXPART
	let headingCounterStart = if inPublications { 1 } else { 0 }
	let headingCounter = counter(heading).get()
	let headingCounter = headingCounter.slice(
		headingCounterStart,
		calc.min(
			figNumberWithinLevel + headingCounterStart,
			headingCounter.len(),
		)
	)

	// Reset subfigure counter when entering a new figure.

	if it.kind != SUBFIGUREKIND {
		SUBFIGURECOUNTER.update(0)
	}

	// Step the relevant counter and read back its stepped value.
	// Subfigures intentionally step the unknown-kind counter here and read
	// their own SUBFIGURECOUNTER instead; the subfigure counter is stepped
	// inside the caption layout below.

	if it.kind == SUBFIGUREKIND {
		UNKNOWNCOUNTER.step()
	} else {
		figureCounterFromKind(it.kind).step()
	}

	let ctr = if it.kind == SUBFIGUREKIND {
		SUBFIGURECOUNTER.get()
	} else {
		figureCounterFromKind(it.kind).get()
	}

	ctr.last() += 1

	let supplement = if it.kind == raw {
		codeSupplement
	} else if it.kind == SUBFIGUREKIND {
		none
	} else {
		it.supplement
	}

	set text(size: text.size - 1pt)

	let caption = block(
		width:95%,
		layout( containerSize => {
			let caption = if it.kind == SUBFIGUREKIND {
				{
					set text(weight: "bold")
					SUBFIGURECOUNTER.step()
					numbering(it.numbering, ctr.last())
				}
				if it.caption != none {
					sym.space.nobreak
					it.caption.body
				}
			} else {
				{
					set text(weight: "bold")
					supplement
					sym.space.nobreak
					array2SectionNumbering(
						headingCounter,
						inAppendix or inPublicationAppendix
					)
					if figNumberWithinLevel > 0 {"."}
					ctr.map(str).join(".")
					"."
				}
				if it.caption == none {
					panic("Figures other than subfigures MUST have a caption.")
				}
				sym.space.nobreak
				it.caption.body
			}
			let captionSize = measure(caption)
			let alignment = if captionSize.width >= containerSize.width {
				left
			} else {
				center
			}
			set align(alignment)
			caption
		} )
	)

	let fig = if it.kind == TAUTHEOREMKIND {
		// Theorem blocks lay themselves out in tauTheoremBlock.
		it
	} else if it.kind == PUBLICATIONKIND {
		block(it.body)
	} else if it.kind == table {
		// Tables get their caption above them.
		caption
		block(it.body)
	} else {
		// Image, code, subfigure and unknown kinds: body first, caption below.
		block(it.body)
		caption
	}

	// Prevent separation of figure contents and caption.

	let unbreakableFigure = block(
		breakable: false,
		spacing: 1.5em,
		fig
	)

	if it.placement != none {
		place(
			it.placement,
			scope: it.scope,
			float: true,
			clearance: 0em,
			h(1fr) + unbreakableFigure + h(1fr)
		)
	} else {
		set align(center)
		unbreakableFigure
	}
}

/**
 * Determines the effects which are applied to headings based on its level.
***/

#let headingEffectFunction(body,level) = if level == 1 {
	upper(body)
} else {
	body
}

/**
 *
 * Defines how headings are displayed. Also updates counters related to
 * numbering figures and equations.
 *
***/

#let headingShowRule(
	language,
	mathFont,
	codeFont,
	figNumberWithinLevel,
	eqNumberWithinLevel,
	thesisTypeInteger,
	it,
) = {

	if it.level == 1 { SHORTCHAPTERHEADINGSTATE.update(it.body) }

	set text(weight: "regular")

	let appendixPrefix = appendixPrefixFn(language) + sym.space.nobreak

	if it.level <= eqNumberWithinLevel and it.outlined and eqNumberWithinLevel > 0 {
		counter(math.equation).update( 0 )
	}
	if it.outlined and it.level <= figNumberWithinLevel and figNumberWithinLevel > 0 {
		resetFigureCounters()
	}
	let docPart = DOCPARTSTATE.get()
	let inAppendix = docPart == APPENDIXPART
	let indentation = if it.level == 1 and not inAppendix { 1cm } else if it.level == 1 and inAppendix { 0.7em } else { 1em }
	set heading(
		hanging-indent: indentation,
	)
	set par(
		justify:false,
		hanging-indent: indentation,
	)
	let inBibliography = docPart == BIBLIOGRAPHYPART
	let inPublications = docPart == PUBLICATIONMATTERPART
	if it.level > 4 {
		panic("Headings with levels greater than 4 are not supported by this template. Your document structure is too fine-grained.")
	}
	// Text size, spacing above and spacing below per heading level.
	// Note: belowHeadSpacing for levels 2..4 of doctoral theses intentionally
	// uses the text size in effect where the heading appears.
	let (textSize, aboveHeadSpacing, belowHeadSpacing) = if thesisTypeInteger > licentiateThesisTypeInt {
		(
			(18pt, 0pt, 70.9pt),
			(15pt, 28.35pt, text.size),
			(13pt, 28.35pt, text.size),
			(11pt, 28.35pt, text.size),
		).at(it.level - 1)
	} else {
		(
			(21pt, 42pt, 42pt),
			(17pt, 20pt, 15pt),
			(17pt, 20pt, 15pt),
			(17pt, 20pt, 15pt),
		).at(it.level - 1)
	}
	show math.equation: set text(font: mathFont, size: textSize)
	show raw: it => inlineCodeShowRule(codeFont, textSize, it)
	set text(
		size : textSize,
		hyphenate: false,
	)
	let numberSpace = if it.outlined and it.level <= 3 and not inBibliography {
		h(
			indentation,
			weak:true,
		)
	} else {
		""
	}
	// Page breaks at the start of every chapter.
	// However, let publications themselves decide whether there is a page break at every chapter start.
	if it.level == 1 and not inPublications {
		pagebreak(weak: true)
	}
	show link: set text(fill: black)
	v(aboveHeadSpacing, weak: true)
	link(
		label("outlineLabel"),
		block(
			sticky:true,
			{
				if it.level == 1 and inAppendix {
					appendixPrefix
				} else {
					""
				}
				if it.outlined {
					if it.level > 3 {
						// Leave counter out.
					}
					else if inPublications {
						counter(heading).display("1.1")
					}
					else if it.level == 1 and inAppendix {
						counter(heading).display("A.1.")
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
				} else {
					if inPublications {
						counter(heading).display("1.1") + for _ in range(calc.max(2,3 - it.level)) {
							sym.space.nobreak
						}
					}
				}
				numberSpace
				headingEffectFunction( it.body, it.level )
				parbreak() // Needed to introduce a paragraph with hanging indent into this block.
			}
		)
	)
	v(belowHeadSpacing, weak:true)
}

/**
 *
 * Defines how outline entries are to be displayed. This is to be used within a
 * show rule, so that context and therefore information about page numbers and
 * such can be resolved.
 *
***/

#let outlineEntryShowRule(
	language,
	figNumberWithinLevel,
	thesisTypeInt,
	mathFont,
	codeFont,
	it
) = {
	let codeSupplement = codeSupplementFn(language)
	let appendixPrefix = appendixPrefixFn(language) + sym.space.nobreak
	let el = it.element
	let textSize = if thesisTypeInt >= licentiateThesisTypeInt { 10pt } else { 11pt }
	set text( size : textSize )
	show math.equation: set text(font: mathFont, size: textSize)
	show raw: it => inlineCodeShowRule(codeFont, textSize, it)
	let elementLocation = el.location()
	let docPart = DOCPARTSTATE.at(elementLocation)
	if docPart >= PUBLICATIONMATTERPART { return none }
	// The reduction of the page number here is required because of the ISSN page of a Doctoral thesis.
	// There might be a less brittle solution for this, but this works, so...
	let elementPageNum = if thesisTypeInt >= licentiateThesisTypeInt {
		counter(page).at(elementLocation).first()
	} else {
		MAINMATTERPAGENUMBERCOUNTER.at(elementLocation).first() - 1
	}
	let headingCounter = counter(heading).at(elementLocation)
	let headingCounter = headingCounter.slice(
		0,
		calc.min(figNumberWithinLevel,headingCounter.len())
	)
	let inAppendix = docPart == APPENDIXPART
	let inBibliography = docPart == BIBLIOGRAPHYPART
	let additionalOutlineHSpace = if inBibliography { 0pt } else { 0.5cm }
	let embellishmentColor = black
	show link: set text(fill: embellishmentColor)
	let (number, space, entry) = if el.func() == figure {
		let (carray, supplement) = if el.kind == raw {
			(CODECOUNTER.at(elementLocation), codeSupplement)
		} else if el.kind in (image, table, TAUTHEOREMKIND) {
			(figureCounterFromKind(el.kind).at(elementLocation), el.supplement)
		} else {
			(UNKNOWNCOUNTER.at(elementLocation), UNKNOWNSUPPLEMENT)
		}
		if carray == none {
			panic("A figure did not contain a number that can be referenced. Please contact the developers of tauthesis.")
		}
		carray.last() += 1
		(
			strong({
				supplement
				" "
				array2SectionNumbering(headingCounter, inAppendix)
				if headingCounter.len() > 0 {"."}
				carray.map(str).join(".")
				"."
			}),
			sym.space.nobreak,
			el.caption.body,
		)
	} else if el.func() == heading {
		let ctr = counter(heading).at(elementLocation)
		let (prefix, numbering, colon, space, bodycolor, bodyweight) = if inAppendix {
			if el.level == 1 {
				(appendixPrefix, array2SectionNumbering(ctr, inAppendix), ".", sym.space.nobreak, black, "regular")
			} else {
				([], array2SectionNumbering(ctr, inAppendix), "", sym.space.nobreak, black, "regular")
			}
		} else if inBibliography {
			("", "", "", "", embellishmentColor, "regular")
		} else {
			([], array2SectionNumbering(ctr, inAppendix), "", sym.space.nobreak, black, "regular")
		}
		let effectFn = if el.level == 1 {
			headingEffectFunction
		} else {
			(body,level) => body
		}
		(
			{
				set text(
					fill: black,
					weight: "regular",
				)
				prefix + numbering + colon
			},
			space + h(additionalOutlineHSpace),
			effectFn(
				text(
					fill:bodycolor,
					weight: bodyweight,
					el.body
				),
				el.level
			)
		)
	} else {
		panic("Lists of contents may only reference headings or figures. How we got here is a mystery (and probably a bug in the template).")
	}
	v(
		if el.func() == heading and el.level > 1 { 10pt } else { 14.2pt },
		weak:true
	)
	let spaceWidth = measure(space).width
	let counterWidth = 0cm + range(it.level).map(ii => measure((("A",) * ii).join(".")).width).sum()
	let spaceWidths = (it.level - 1) * spaceWidth
	link(
		elementLocation,
		block(
			grid(
				columns: (auto,1fr,measure(MAINMATTERPAGENUMBERCOUNTER.final().map(str).join()).width + 5pt),
				align: (top+left,top+left,bottom+right),
				h(counterWidth + spaceWidths),
				par(
					hanging-indent: 1cm,
					{
						number
						space
						entry
						box(width: 1fr, repeat[.])
					},
				),
				str(elementPageNum),
			)
		)
	)
}

/**
 *
 * Defines the look of code elements.
 *
***/

#let rawShowRule(codeFont, fontSize, it) = {

	set text( font : codeFont, size: fontSize)

	if it.block {

		let lastLine = it.lines.last()

		let numberColumnWidth = if lastLine.count < 10 {
			0.7em
		} else {
			calc.floor(calc.log(lastLine.count, base:10)) * 1em
		}

		block(
			width: 100%,
			inset: tuniCodeBlockInset,
			fill: luma(252),
			{
				set align(left)
				grid(
					columns: (numberColumnWidth, 1fr),
					align: (right,left),
					row-gutter:0.7em,
					column-gutter: 0.5em,
					.. for line in it.lines {
						if line.number < line.count {
							(text(fill: gray, str(line.number)), line.body)
						} else if line.number == line.count and line.text.trim() != "" {
							(text(fill: gray, str(line.number)), line.body)
						} else {
							none
						}
					}
				)
			}
		)

	} else {

		box(
			inset : (x : 0.2 * fontSize),
			outset : (y : 0.2 * fontSize),
			fill : luma(INLINECODELUMABACKGROUND),
			radius : 0.25 * fontSize,
			it
		)

	}

}

/**
 *
 * Defines how quotes appear in text.
 *
***/
#let quoteShowRule(it) = if it.block {
  block(
    above: 1em,
    below: 1em,
    // stroke: (left: tuniPurple + 2pt),
    inset: (
      left: 1cm,
			right: 0cm,
      y : 0cm,
    ),
    {
      it.body
      parbreak()
      if it.attribution != none {
        sym.dash
        it.attribution
      }
    }
  )
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
	maintitle,
	subtitle,
	faculty,
	thesisType,
	otsikko,
	alaotsikko,
	tiedekunta,
	työnTyyppi,
	language,
	physicallyPrinted,
	thesisTypePaper,
	thesisTypeMargins,
	examiners,
	doc
) = page(
	paper: thesisTypePaper,
	header: none,
	footer: none,
	// The title page is always a recto of the finished copy:
	// the printing house prints it one-sided and binds it in
	// front, with the spine on its left, so its binding
	// allowance belongs on the left regardless of the
	// binding-side flip used by the duplex content pages.
	// The margins are therefore resolved explicitly here
	// instead of being left to the inside/outside flip, which
	// keeps the logo and the title text box aligned at the
	// same text corner in every output mode.
	margin: if "inside" in thesisTypeMargins {
		(
			top: thesisTypeMargins.top,
			bottom: thesisTypeMargins.bottom,
			left: thesisTypeMargins.inside,
			right: thesisTypeMargins.outside,
		)
	} else {
		thesisTypeMargins
	},
	numbering: none,
	background: place(
		top + left,
		float:true,
		dx: if physicallyPrinted {
			// The printed logo sits exactly at the title page
			// text corner: the recto inside margin, which the
			// explicit margin resolution above places on the
			// left in every mode. The electronic logo hugs
			// the upper-left corner instead.
			if "inside" in thesisTypeMargins {
				thesisTypeMargins.inside
			} else {
				thesisTypeMargins.left
			}
		} else {
			0.5cm
		},
		dy: if physicallyPrinted {
			thesisTypeMargins.top
		} else {
			0.5cm
		},
		image(
			if language == finnish {
				"template/images/tau-logo-fin.svg"
			} else {
				"template/images/tau-logo-eng.svg"
			},
			alt: if language == finnish {
				"Tampereen yliopiston logo."
			} else {
				"Tampere University logo."
			},
			width : 8cm
		)
	),
	{

		let date = datetime.today()

		let thesisTypeInt = thesisTypeToIntFn(thesisType)

		// The thesis examiners print on the title pages of
		// the lower thesis types only: each gets an own
		// line after the faculty line and before the date
		// line, preceded by the localized label, like the
		// LaTeX class cover and the Word template info
		// block. The series covers of the higher thesis
		// types carry no examiners.
		let examinerLabel = if language == finnish { "Tarkastaja" } else { "Examiner" }
		let examinerRows = if thesisTypeInt < licentiateThesisTypeInt {
			examiners.map(
				ex => examinerLabel + ":" + sym.space.nobreak + (ex.title + " " + ex.firstname + " " + ex.lastname)
			)
		} else {
			()
		}

		align(right)[
			#v(6cm)
			#text(
				20pt,
				author
			)
			#v(2cm, weak: true)
			#set par( leading : 0.4em )
			#title(
				text( size: 25pt, fill: tuniPurple, weight: "bold" )[
					#upper(
						if language == finnish {
							otsikko
						} else if language == english {
							maintitle
						}
					)
				]
				+ v(0.7cm, weak: true)
				+ text(size: 20pt, fill: tuniPurple, weight: "regular")[
					#(
						if language == finnish {
							alaotsikko
						} else if language == english {
							subtitle
						}
					)
				]

			)
			#v(1fr)
			#if thesisTypeInt >= doctoralThesisTypeInt {
				text(
					size: 15pt,
					fill: red,
					weight: "bold",
					if language == finnish [
						Tämä ja seuraava sivu korvataan painotalossa.
					] else [
						This and the following page will be replaced in the printing house.
					]
				)
				v(1fr)
			}
			#set par( leading : 0.65em )
			#set text(12pt)
			#grid(
				columns: 1,
				row-gutter: 0.7em,
				.. if language == finnish {
					(
						työnTyyppi,
						tiedekunta,
						..examinerRows,
						localizeMonthFi(date.month()) + sym.space.nobreak + str(date.year()),
					)
				} else {
					(
						thesisType,
						faculty,
						..examinerRows,
						date.display("[month repr:long] [year]"),
					)
				}
			)
		]
		doc
	}
)

#let issnPage(language) = page(
	margin: (
		x: 2cm,
		top: 2cm,
		bottom: 3cm,
	),
	background: none,
	{
		set align(center + horizon)
		set text(size: 15pt)
		v(1fr)
		if language == finnish [
			Kirjasto lisää tälle sivulle työn sarja-, ISBN- ja ISSN-numerot.
		] else [
			The series, ISBN and ISSN numbers are added on this page in the library.
		]
		v(1fr)
		text(
			size: 15pt,
			fill: red,
			weight: "bold",
			if language == finnish [
				Tämä ja edellinen sivu korvataan painotalossa.
			] else [
				This and the preceding page will be replaced in the printing house.
			]
		)
		v(1fr)
	}
)

/**
 *
 * Defines the structure and look of Tampere University thesis
 * abstract.
 *
***/

#let abstract(
	author,
	maintitle,
	subtitle,
	university,
	faculty,
	thesisProgramme,
	thesisType,
	keywords,
	otsikko,
	alaotsikko,
	koulu,
	tiedekunta,
	tutkintoOhjelma,
	työnTyyppi,
	avainsanat,
	abstractContent,
	language,
	physicallyPrinted,
	colorSeparatorLines,
) = {


	let date = datetime.today()

	let thesisTypeInt = thesisTypeToIntFn(thesisType)

	set text(size:10pt)

	set text(lang: language)

	set par(justify: false)

	let metadataSettings = (
		columns: 1,
		row-gutter: 0.7em,
		align: left,
	)

	let metadataTitleHangingIndent = 1em

	if language == finnish [

		= Tiivistelmä <tiivistelmä>

	] else [

		= Abstract <abstract>

	]
	if language == finnish and thesisTypeInt <= licentiateThesisTypeInt [

		#grid(
			.. metadataSettings,
			author,
			par(
				hanging-indent: metadataTitleHangingIndent,
				otsikko + subtitleSuffix(alaotsikko),
			),
			koulu,
			tutkintoOhjelma,
			työnTyyppi,
			localizeMonthFi(date.month()) + sym.space.nobreak + str(date.year()),
		)

	] else if language != finnish and thesisTypeInt <= licentiateThesisTypeInt [

		#grid(
			.. metadataSettings,
			author,
			par(
				hanging-indent: metadataTitleHangingIndent,
				maintitle + subtitleSuffix(subtitle),
			),
			university,
			thesisProgramme,
			thesisType,
			date.display("[month repr:long] [year]"),
		)

	] else {
		none
	}

	show divider: it => {
		set line(
			length: 100%,
			stroke: 2pt + if (
				physicallyPrinted
				and
				not colorSeparatorLines
			) {
				black
			} else {
				tuniPurple
			},
		)
		block(spacing: 1.5em, it)
	}

	if thesisTypeInt <= licentiateThesisTypeInt {

		divider()

	}

	set par(justify: true)

	abstractContent
	parbreak()

	set par(
		justify: false,
		first-line-indent: 0cm,
		spacing: 1.5em,
	)

	if language == finnish [

		*Avainsanat:* #avainsanat.join(", ")

		#if thesisTypeInt <= licentiateThesisTypeInt [

			Tämän julkaisun alkuperäisyys on tarkastettu Turnitin Originality -ohjelmalla.

		]

	] else [

		*Keywords:* #keywords.join(", ")

		#if thesisTypeInt <= licentiateThesisTypeInt [

			The originality of this thesis has been checked using the Turnitin Originality service.

		]

	]
}

/**
 *
 * Typesets the preface of this thesis.
 *
***/

#let preface(author, language, prefaceContents, sijainti, location) = {

	let date = datetime.today()

	let locationDateParagraphSettings = (
			first-line-indent: 0cm,
			spacing: 1.5em,
	)

	if language == finnish {


		heading([Alkusanat])

		prefaceContents
		parbreak()

		set par( ..locationDateParagraphSettings )

		sijainti
		" "
		str(date.day())
		"."
		" "
		localizeMonthFiPartitive(date.month())
		" "
		str(date.year())
		","
		linebreak()
		author

	} else {


		heading([Preface])

		prefaceContents
		parbreak()

		set par( ..locationDateParagraphSettings )

		"In "
		location
		" on "
		str(date.day())
		". "
		date.display("[month repr:long] [year]")
		","
		linebreak()
		author

	}
}

/**
 *
 * Determines how term lists are shown.
 *
***/
#let termListShowRule(it) = {

	grid(
		stroke: none,
		columns: (10%, auto, 85%),
		align: (top+left, top + center, top+left),
		column-gutter: 0.5em,
		row-gutter: 0.75cm,
		.. for item in it.children {
			(
				text(fill: black, weight: "bold", hyphenate: false)[#item.term],
				[~],
				[#item.description],
			)
		}
	)

}

/**
 *
 * Typesets the glossary based on the file content/glossary.typ.
 *
***/
#let glossary(language, glossaryDict) = {

	if language == finnish {
		heading([Lyhenteet ja merkinnät])
	} else {
		heading([Glossary])
	}

	table(
		columns: (auto, auto),
		row-gutter: 1em,
		column-gutter: 1em,
		stroke: none,
		.. for key in glossaryDict.keys().sorted() {
			let name = glossaryDict.at(key).name
			let description = glossaryDict.at(key).description
			(box(table.cell(name)), table.cell(description))
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
	content
) = figure(
	kind: TAUTHEOREMKIND,
	supplement: supplement,
	block(
		fill: fill,
		inset: 0pt,
		radius: 0pt,
		stroke: none,
		width: 100%,
		breakable: true,
		context {
			set align(left)
			let docPart = DOCPARTSTATE.get()
			let inAppendix = docPart == APPENDIXPART
			let inPublications = docPart == PUBLICATIONMATTERPART
			let inPublicationAppendix = PUBLICATIONPART.get() == PUBLICATIONAPPENDIXPART
			let figNumberWithinLevel = FIGNUMBERWITHINLEVELSTATE.get()
			let headingCounter = counter(heading).get()
			let headingCounterStart = if inPublications { 1 } else { 0 }
			let headingCounterEnd = calc.min(
				figNumberWithinLevel + headingCounterStart,
				headingCounter.len(),
			)
			let headingCounter = headingCounter.slice(
				headingCounterStart,
				headingCounterEnd,
			)
			let theoremCounter = TAUTHEOREMCOUNTER.get()
			set text(weight: "bold", fill: black)
			supplement
			sym.space.nobreak
			if figNumberWithinLevel > 0 {
				array2SectionNumbering(
					headingCounter,
					inAppendix or inPublicationAppendix
				)
				"."
			}
			theoremCounter.map(str).last()
			// Content converted to string with repr always has a lenght ≥ 2.
			if repr(title).len() > 2 {
				sym.space.nobreak
				"("
				text(weight: "bold", fill: black, title)
				")"
			}
			set text(weight: "bold", fill: black)
			sym.dot.basic
			set text(weight: "regular")
			content
		}
	)
)

/**
 * Factory for theorem-like wrapper functions: each wrapper fills in the
 * supplement of a TAU theorem block.
***/
#let theoremBlockWrapper(supplement) = (title: "", content) => tauTheoremBlock(
	supplement: supplement,
	title: title,
	content
)

// English theorem-like environments.

#let definition = theoremBlockWrapper("Definition")

#let lemma = theoremBlockWrapper("Lemma")

#let theorem = theoremBlockWrapper("Theorem")

#let corollary = theoremBlockWrapper("Corollary")

#let example = theoremBlockWrapper("Example")

// Finnish theorem-like environments.

#let määritelmä = theoremBlockWrapper("Määritelmä")

#let apulause = theoremBlockWrapper("Apulause")

#let lause = theoremBlockWrapper("Lause")

#let seurauslause = theoremBlockWrapper("Seurauslause")

#let esimerkki = theoremBlockWrapper("Esimerkki")

/**
 * Factory for proof environments in a given language.
***/
#let proofWrapper(label) = body => {
	text(style: "italic", label)
	body + h(1fr) + math.equation(
		alt: "∎",
		$∎$
	)
}

// Proof environments in Finnish and in English.

#let todistus = proofWrapper("Todistus.")

#let proof = proofWrapper("Proof.")

/**
 * Used for displaying a short heading in a page header and a long one elsewhere.
***/
#let contextualHeading(..args, short: none, long: none) = {

	assert(
		long != none,
		message: "contextualHeading: The long version of a heading was not given through the long argument.",
	)

	assert(
		short != none,
		message: "contextualHeading: The short version of a heading was not given through the short argument.",
	)

	heading(
		..args,
		long
	)

	let namedArgs = args.named()

	if (
		not ("level" in namedArgs)
		or
		("level" in namedArgs and namedArgs.level == 1)
		or
		(
			"offset" in namedArgs
			and
			"depth" in namedArgs
			and
			namedArgs.offset + namedArgs.depth == 1
		)
	) {
		SHORTCHAPTERHEADINGSTATE.update(short)
	}
}

/**
 *
 * Defines page dimensions in the main matter.
 *
***/
#let pageSettings(docPart, physicallyPrinted, printTwoSided, thesisTypeInt, colorSeparatorLines, it) = {
	set page(
		paper: thesisTypeIntToPageSizeFn(thesisTypeInt),
		background: none,
		numbering: none,
		// The title page is a separately printed one-sided
		// sheet: the printing house prints it on its own and
		// binds it in front of the duplex content, and its
		// back stays blank. The duplex content flow therefore
		// starts on a recto: the page after the title page
		// has its spine on the left. Typst flips the inside
		// and outside margins per the raw sheet parity of
		// the electronic PDF, which starts one page earlier,
		// so the flip is offset by one page: binding: right
		// makes the even PDF pages (the first content pages)
		// recto sheets with the binding allowance on the
		// left and the odd pages verso sheets with it on the
		// right. The title page itself carries zero margins
		// and is unaffected, and the blank back of the title
		// sheet is not part of the electronic PDF.
		//
		// The higher thesis types follow the doctoral
		// structure instead: the licentiate and doctoral
		// electronic copies count their title page, a
		// recto, into the continuous pagination, and print
		// duplex from it, so the PDF parity equals the
		// bound-book parity and the odd PDF pages are the
		// rectos of the finished book. The series
		// specification places the binding allowance on the
		// left margin of every odd page, so no parity
		// offset is needed and the binding side stays left
		// for both of them. The licentiate differs only in
		// the publishing artifacts: it carries no ISSN
		// verso page and no printing-house notes, so its
		// front matter starts on the verso of the title
		// page rather than one page later.
		binding: if thesisTypeInt >= licentiateThesisTypeInt {
			left
		} else {
			right
		},
		header: context if thesisTypeInt < licentiateThesisTypeInt {
			if docPart == FRONTMATTERPART {
				PREFACEPAGENUMBERCOUNTER.step()
			} else if docPart >= MAINMATTERPART {
				MAINMATTERPAGENUMBERCOUNTER.step()
			} else {
				none
			}
			// This header is only used for thesis types below the licentiate
			// level, so the page number is always displayed in it.
			let (pageNum, numberingStr) = if docPart in (TITLEPAGEPART, FRONTMATTERPART) {
				(PREFACEPAGENUMBERCOUNTER, "i")
			} else if docPart >= MAINMATTERPART {
				(MAINMATTERPAGENUMBERCOUNTER, "1")
			} else {
				(none, "")
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
			let (innerText, drawLine) = if lastHeadBefore != none {
				let lastPageBefore = lastHeadBefore.location().page()
				let locationPageDiff = currentPage - lastPageBefore
				let firstShortTitleBefore = SHORTCHAPTERHEADINGSTATE.at(here())
				if firstHeadAfter != none {
					let firstShortTitleAfter = SHORTCHAPTERHEADINGSTATE.at(firstHeadAfter.location())
					let firstpageafter = firstHeadAfter.location().page()
					if firstHeadAfter.level == 1 and currentPage < firstpageafter {
						// On the last page before next chapter.
						(
							if firstShortTitleBefore != none {
								firstShortTitleBefore
							} else {
								lastHeadBefore.body
							},
							true,
						)
					}
					else if locationPageDiff >= 1 and (firstHeadAfter.level > lastHeadBefore.level) {
						// Pages following chapter title but not last page before next chapter.
						(
							if firstShortTitleBefore != none {
								firstShortTitleAfter
							} else {
								lastHeadBefore.body
							},
							true,
						)
					}
					else {
						// On an outlined chapter-starting page.
						("", false)
					}
				}
				else {
					// No following outlined chapters or lower-level sections. Usually the last page of the document.
					(
						if firstShortTitleBefore != none {
							firstShortTitleBefore
						} else {
							lastHeadBefore.body
						},
						true,
					)
				}
			}
			else {
				// No preceding outlined chapters.
				("", false)
			}
			// The physical page number of the header's own page.
			// In containers such as headers Typst 0.15 already
			// evaluates counter(page) to the current page, so
			// the old expression
			// counter(page).get().last() + 1 counted one page
			// too high on every header and flipped the
			// odd/even side choice of the two-sided layout.
			let docPageNum = here().page()
			// A header row of two cells: chapter title and page number.
			let headerGrid(columns, leftCell, rightCell) = grid(
				columns: columns,
				align: (left+top, right+top),
				gutter: 0.2em,
				leftCell,
				rightCell,
			)
			// In two-sided printed output the page number is
			// set at the outer edge of each page, on the side
			// with the smaller horizontal margin, opposite
			// the binding side. Because the title page is
			// printed one-sided separately, the even PDF
			// pages are the recto sheets of the bound copy
			// (spine on the left, number on the right) and
			// the odd PDF pages from the third page onward
			// are verso sheets (spine on the right, number
			// on the left).
			if physicallyPrinted and printTwoSided {
				if calc.rem(docPageNum, 2) == 0 {
					headerGrid(
						(9fr, 1fr),
						upper(innerText),
						pageNum.display(numberingStr),
					)
				} else {
					headerGrid(
						(1fr, 9fr),
						pageNum.display(numberingStr),
						upper(innerText),
					)
				}
			} else {
				headerGrid(
					(9fr, 1fr),
					upper(innerText),
					pageNum.display(numberingStr),
				)
			}
			if drawLine {
				line(
					length: 100%,
					stroke: 2pt + if physicallyPrinted and not colorSeparatorLines { black } else { tuniPurple },
				)
			} else {
				hide(
					line(
						length: 100%,
						stroke: 2pt,
					)
				)
			}
		} else {
			// No headers for licentiate or doctoral theses.
			none
		},
		footer: context {
			if thesisTypeInt >= licentiateThesisTypeInt {
				if docPart == FRONTMATTERPART {
					PREFACEPAGENUMBERCOUNTER.step()
				} else if docPart >= MAINMATTERPART {
					MAINMATTERPAGENUMBERCOUNTER.step()
				} else {
					none
				}
				set align(center + horizon)
				if docPart == FRONTMATTERPART {
					counter(page).display("i")
				} else if docPart >= MAINMATTERPART {
					counter(page).display("1")
				} else {
					none
				}
			}
		},
		margin: thesisTypeIntToMarginsFn(
			physicallyPrinted: physicallyPrinted,
			printTwoSided: printTwoSided,
			thesisTypeInt,
		)
	)
	DOCPARTSTATE.update(docPart)
	it
}

/**
 * A generic list-of-contents outline for figures, tables and listings.
***/
#let contentOutline(target, fiTitle, enTitle, language) = {
	outline(
		title: if language == finnish { fiTitle } else { enTitle },
		target: target,
		indent: auto,
	)
}

/**
 *
 * A list of images.
 *
***/
#let contentFigures(language) = contentOutline(
	figure.where(kind: image),
	[Kuvaluettelo],
	[List of figures],
	language,
)

/**
 *
 * A list of tables.
 *
***/
#let contentTables(language) = contentOutline(
	figure.where(kind: table),
	[Taulukkoluettelo],
	[List of tables],
	language,
)

/**
 *
 * A list of listings.
 *
***/
#let contentListings(language) = contentOutline(
	figure.where(kind: raw),
	[Listausluettelo],
	[List of listings],
	language,
)

/**
 * Filters a publication dictionary down to the publications that should be
 * included in the thesis as original publications.
***/
#let thesisPublications(publicationDict) = publicationDict.pairs().filter(((citeKey, publication)) =>
	"tauthesis-publication" in publication and publication.tauthesis-publication
)

/**
 * The "Publication I" cell of the original publications list, optionally
 * linked to the title page of the attached publication.
***/
#let publicationNumberCell(attachPublications, publicationStr, n) = {
	set text(fill: black, weight: "bold")
	show link: set text(fill: black, weight: "bold")
	if attachPublications {
		let refStr = "tauthesis-publication-anchor-" + str(n)
		link(
			label(refStr),
			publicationStr + sym.space.nobreak + numbering("I", n)
		)
	} else {
		publicationStr + sym.space.nobreak + numbering("I", n)
	}
}

/**
 *
 * A list of Doctoral thesis publications.
 *
***/

#let listOfPublications(attachPublications, language, publicationDict) = {

	if publicationDict == none or publicationDict.len() == 0 {
		return none
	}

	if language == finnish {
		heading([Alkuperäiset julkaisut])
	} else {
		heading([Original Publications])
	}

	let publicationStr = if language == finnish {"Julkaisu"} else {"Publication"}

	set par(justify: false)

	let includedPublications = thesisPublications(publicationDict)

	let publicationCounter = 0

	grid(
		columns: (18%,2%,80%),
		align: (top+left,top+center,top+left),
		row-gutter: 2em,
		column-gutter: 0.9em,
		.. for (citeKey, publication) in includedPublications {

			publicationCounter += 1

			let author = publication.at(
				"author",
				default: ("Unknown author",)
			)
			let title = publication.at(
				"title",
				default: "Unknown title"
			)
			let parent = publication.at(
				"parent",
				default: none
			)
			let volume = if parent != none {
				str(parent.at("volume", default: ""))
			} else {
				""
			}
			let issue = if parent != none {
				str(parent.at("issue", default: ""))
			} else {
				""
			}
			let pages = if parent != none {
				parent.at("pages", default: "")
			} else {
				""
			}
			let parentTitle = if parent != none {
				parent.at("title", default: "")
			} else {
				""
			}
			let parentLocation = if parent != none {
				parent.at("location", default: "")
			} else {
				""
			}
			let parentPublisher = if parent != none {
				parent.at("publisher", default: "")
			} else {
				""
			}
			let editor = publication.at(
				"editor",
				default: ""
			)

			let doi = if "serial-number" in publication {
				if "doi" in publication.serial-number {
					publication.serial-number.doi
				} else {
					none
				}
			} else {
				none
			}

			(
				publicationNumberCell(attachPublications, publicationStr, publicationCounter),
				[~],
				{
					authorsToString(citeKey, author)
					", "
					text(
						style: "italic",
						" " + title
					)
					if lower(publication.type) == "article" {
						", "
						parentTitle
						if volume != "" {
							", volume: "
							volume
						}
						if issue != "" {
							", issue: "
							issue
						}
					} else if lower(publication.type) == "anthos" {
						", In: "
						parentTitle
						", Ed: "
						if type(editor) == array {
							editor.join(", ")
						} else {
							editor
						}
						", "
						parentLocation
						": "
						parentPublisher
					} else {
						", Unknown publication type"
					}
					", DOI: " + if doi != none {
						link("https://www.doi.org/" + doi,doi)
					} else {
						"missing"
					}
				}
			)
		}
	)

	if language == finnish {
		heading(level: 2, [Kirjoittajan osallisuus])
	} else {
		heading(level: 2, [Author contributions])
	}

	v(1em)

	publicationCounter = 0

	grid(
		columns: (18%,2%,80%),
		align: (top+left,top+center,top+left),
		row-gutter: 2em,
		column-gutter: 0.9em,
		.. for (citeKey, publication) in includedPublications {

			publicationCounter += 1

			(
				publicationNumberCell(attachPublications, publicationStr, publicationCounter),
				[~],
				publication.author-contribution
			)
		}
	)
}

/**
 * A template function for generating an examiner dictionary.
***/
#let examiner(..args) = {

	let known-args = ("title", "firstname", "lastname")

	let examiner-dict = (:)

	for known-arg in known-args {

		let known-arg-value = args.named().at(known-arg, default: none)

		assert(
			known-arg-value != none,
			message: "examiner: argument " + known-arg + " was not given."
		)

		let known-arg-value-type = type(known-arg-value)

		assert(
			known-arg-value-type == str,
			message: "examiner: type of argument " + known-arg + " must be a string. Was " + str(known-arg-value-type) + "."
		)

		examiner-dict.insert(
			known-arg,
			known-arg-value,
		)

	}

	examiner-dict

}

/**
 * A front-matter section whose title and label are given in both languages;
 * one of them is picked based on the thesis language.
***/
#let bilingualSection(fiTitle, fiLabel, enTitle, enLabel, contents, language) = {
	if language == finnish [
		= #fiTitle
		#label(fiLabel)
		#contents

	] else [
		= #enTitle
		#label(enLabel)
		#contents

	]
}

#let acknowledgements(acknowledgementContents, language) = bilingualSection(
	[Tunnustukset],
	"tunnustukset",
	[Acknowledgements],
	"acknowledgements",
	acknowledgementContents,
	language,
)

#let thanks(thanksContents, language) = bilingualSection(
	[Kiitokset],
	"kiitokset",
	[Thanks],
	"thanks",
	thanksContents,
	language,
)

/**
 *
 * Defines the structure and look of Tampere University theses.
 *
***/

#let template(
	abstractContents: [],
	acknowledgementContents: "",
	aiDisclaimerContents: [],
	alaotsikko: [Alaotsikko],
	attachPublications: true,
	author: "Firstname Lastname",
	avainsanat: ("avainsana1", "avainsana2"),
	citationStyle: "ieee",
	codeFont : "Fira Mono",
	colorSeparatorLines: true,
	compilationThesis: true,
	description: "A short description of the document.",
	examiners: (
		examiner(
			title: "Professor",
			firstname: "Firstname",
			lastname: "Lastname",
		),
		examiner(
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
	includeGlossary: true,
	includeListOfFigures: true,
	includeListOfTables: true,
	includeListOfListings: true,
	includeThanks: true,
	keywords: ("keyword1", "keyword2"),
	koulu: [Tampereen Yliopisto],
	language: "fi",
	location: "Tampere",
	mathFont : "STIX Two Math",
	otsikko: [Opinnäytetyöpohja],
	physicallyPrinted: false,
	prefaceContents: [],
	printTwoSided: false,
	publicationDict: (:),
	region: "FI",
	showParagraphLineNumbers: false,
	sijainti: [Tampereella],
	subtitle: [Subtitle],
	tekoälynKäyttöTeksti: [],
	textFont : "Roboto",
	thesisProgramme: "Degree programme",
	thesisType: masterOfTechnologyThesisType,
	tiedekunta: [Tiedekunta],
	tiivistelmänSisältö: [],
	maintitle: "Thesis template",
	thanksContents: "",
	tutkintoOhjelma: "Tutkinto-ohjelma",
	university: [Tampere University],
	usedAI : true,
	doc
) = {

	// ----------------------------------------------------------------
	// Command-line overrides (see the sys.inputs section near the
	// thesis types). Applied before any validation so that an
	// overridden value passes through the same checks as one read
	// from meta.typ. Keys that are not given on the command line
	// leave the meta.typ value in effect.
	// ----------------------------------------------------------------

	let thesisType = thesisTypeSysInput(thesisType)
	let alaotsikko = sysInput("alaotsikko", alaotsikko)
	let attachPublications = sysInput("attachPublications", attachPublications)
	let author = sysInput("author", author)
	let avainsanat = sysInput("avainsanat", avainsanat)
	let colorSeparatorLines = sysInput("colorSeparatorLines", colorSeparatorLines)
	let compilationThesis = sysInput("compilationThesis", compilationThesis)
	let description = sysInput("description", description)
	let eqNumberWithinLevel = sysInput("eqNumberWithinLevel", eqNumberWithinLevel)
	let faculty = sysInput("faculty", faculty)
	let figNumberWithinLevel = sysInput("figNumberWithinLevel", figNumberWithinLevel)
	let includeFinnishAbstract = sysInput("includeFinnishAbstract", includeFinnishAbstract)
	let includeGlossary = sysInput("includeGlossary", includeGlossary)
	let includeListOfFigures = sysInput("includeListOfFigures", includeListOfFigures)
	let includeListOfTables = sysInput("includeListOfTables", includeListOfTables)
	let includeListOfListings = sysInput("includeListOfListings", includeListOfListings)
	let includeThanks = sysInput("includeThanks", includeThanks)
	let keywords = sysInput("keywords", keywords)
	let koulu = sysInput("koulu", koulu)
	let language = sysInput("language", language)
	let location = sysInput("location", location)
	let mathFont = sysInput("mathFont", mathFont)
	let otsikko = sysInput("otsikko", otsikko)
	let physicallyPrinted = sysInput("physicallyPrinted", physicallyPrinted)
	let printTwoSided = sysInput("printTwoSided", printTwoSided)
	let region = sysInput("region", region)
	let showParagraphLineNumbers = sysInput("showParagraphLineNumbers", showParagraphLineNumbers)
	let sijainti = sysInput("sijainti", sijainti)
	let subtitle = sysInput("subtitle", subtitle)
	let textFont = sysInput("textFont", textFont)
	let thesisProgramme = sysInput("thesisProgramme", thesisProgramme)
	let tiedekunta = sysInput("tiedekunta", tiedekunta)
	let maintitle = sysInput("maintitle", maintitle)
	let tutkintoOhjelma = sysInput("tutkintoOhjelma", tutkintoOhjelma)
	let university = sysInput("university", university)
	let usedAI = sysInput("usedAI", usedAI)
	let codeFont = sysInput("codeFont", codeFont)

	if not language in (finnish, english) {
		panic( templateName + ": unrecognized primary language '" + language + ". Only 'fi' and 'en' are accepted." )
	}

	validateNumberWithinLevel("figNumberWithinLevel", figNumberWithinLevel)

	validateNumberWithinLevel("eqNumberWithinLevel", eqNumberWithinLevel)

	thesisTypeValidationFn(thesisType)

	let thesisTypeInt = thesisTypeToIntFn(thesisType)

	// The Finnish thesis type is no longer a template input:
	// it is derived from the English thesis type.

	let työnTyyppi = thesisTypeToTyönTyyppiFn(thesisType)

	set document(
		author: author,
		title: if language == finnish {
			otsikko + subtitleSuffix(alaotsikko)
		} else {
			maintitle + subtitleSuffix(subtitle)
		},
		keywords: if language == finnish {
			avainsanat + keywords
		} else {
			keywords + avainsanat
		},
		date: datetime.today(),
		description: description
			+ if description != none and description != [] and description.len() > 0 {
				" "
			}
			+ "Evaluated by "
			+ examiners
				.map(
					ex => (ex.title, ex.firstname, ex.lastname)
					.join(" ")
				)
				.join(", ", last: " and "),
	)

	// Expose document metadata to typst query CLI utility.
	// Values are stored as-is instead of being converted with str(), so
	// that also content-valued arguments (e.g. titles) can be exposed.

	[
		#if subtitleText(alaotsikko) != "" [
			#metadata(subtitleText(alaotsikko))
			#label("alaotsikko")
		]
		#metadata(author) #label("author")
		#metadata(avainsanat.join(", ")) #label("avainsanat")
		#metadata(citationStyle) #label("citationStyle")
		#metadata(description) #label("description")
		#metadata(str(eqNumberWithinLevel)) #label("eqNumberWithinLevel")
		#metadata(faculty) #label("faculty")
		#metadata(str(figNumberWithinLevel)) #label("figNumberWithinLevel")
		#metadata(keywords.join(", ")) #label("keywords")
		#metadata(koulu) #label("koulu")
		#metadata(language) #label("language")
		#metadata(location) #label("location")
		#metadata(otsikko) #label("otsikko")
		#metadata(str(int(printTwoSided))) #label("printTwoSided")
		#metadata(sijainti) #label("sijainti")
		#if subtitleText(subtitle) != "" [
			#metadata(subtitleText(subtitle))
			#label("subtitle")
		]
		#metadata(thesisType) #label("thesisType")
		#metadata(tiedekunta) #label("tiedekunta")
		#metadata(maintitle) #label("maintitle")
		#metadata(työnTyyppi) #label("työnTyyppi")
		#metadata(university) #label("university")
		#metadata(str(int(usedAI))) #label("usedAI")
	]

	show par: set math.frac(style: "horizontal")

	// Color different kinds of links.

	show link: set text( fill: rgb("#0038FF") ) if not physicallyPrinted

	show cite: set text( fill: black )

	// Prettify emphasized text.

	show emph: set text(fill:black)

	// Initialize helper counters in array format.

	resetFigureCounters()

	FIGNUMBERWITHINLEVELSTATE.update(figNumberWithinLevel)

	// Update helper counters when associated figures are shown.

	show figure: it => figShowRule(language,figNumberWithinLevel,it)

	show heading: headingShowRule.with(
		language,
		mathFont,
		codeFont,
		figNumberWithinLevel,
		eqNumberWithinLevel,
		thesisTypeInt,
	)

	show raw: it => rawShowRule(
		codeFont,
		text.size,
		it
	)

	let textFontSize = if thesisTypeInt > licentiateThesisTypeInt { 10pt } else { 11pt }

	set text(
		font: textFont,
		lang: language,
		region: region,
		size: textFontSize,
	)

	show math.equation: set text(
		font: mathFont,
		size: textFontSize,
	)

	show: doc => pageSettings(TITLEPAGEPART, physicallyPrinted, printTwoSided, thesisTypeInt, colorSeparatorLines, doc)

	show: doc => titlepage(
		author,
		maintitle,
		subtitle,
		faculty,
		thesisType,
		otsikko,
		alaotsikko,
		tiedekunta,
		työnTyyppi,
		language,
		physicallyPrinted,
		thesisTypeIntToPageSizeFn(thesisTypeInt),
		thesisTypeIntToMarginsFn(
			physicallyPrinted: physicallyPrinted,
			printTwoSided: printTwoSided,
			thesisTypeInt,
		),
		examiners,
		doc
	)

	if thesisTypeInt >= doctoralThesisTypeInt {
		issnPage(language)
	}

	PREFACEPAGENUMBERCOUNTER.update(1)

	show: doc => pageSettings(FRONTMATTERPART, physicallyPrinted, printTwoSided, thesisTypeInt, colorSeparatorLines, doc)

	set heading(numbering: none, outlined: false, bookmarked: true)

	set par(
		leading: 0.9em,
		first-line-indent: if thesisTypeInt > licentiateThesisTypeInt { 0.5cm } else { 0cm },
		justify: true,
		spacing: if thesisTypeInt > licentiateThesisTypeInt { 0.9em } else { 1.5em },
	)

	// The arguments shared by all calls of the abstract function, in its
	// positional argument order.

	let abstractCommon = (
		author,
		maintitle,
		subtitle,
		university,
		faculty,
		thesisProgramme,
		thesisType,
		keywords,
		otsikko,
		alaotsikko,
		koulu,
		tiedekunta,
		tutkintoOhjelma,
		työnTyyppi,
		avainsanat,
	)

	let abstracts = if language == finnish {
		abstract(..abstractCommon, tiivistelmänSisältö, finnish, physicallyPrinted, colorSeparatorLines)
		abstract(..abstractCommon, abstractContents, english, physicallyPrinted, colorSeparatorLines)
	} else if language == english {
		abstract(..abstractCommon, abstractContents, english, physicallyPrinted, colorSeparatorLines)
		if includeFinnishAbstract {
			abstract(..abstractCommon, tiivistelmänSisältö, finnish, physicallyPrinted, colorSeparatorLines)
		}
	} else {
		panic( templateName + ": received an unknown language " + language + ". Must be one of {\"fi\", \"en\"}" )
	}

	// Adjust how ToC entries appear in their respective listings.

	show outline.entry: it => outlineEntryShowRule(
		language,
		figNumberWithinLevel,
		thesisTypeInt,
		mathFont,
		codeFont,
		it
	)

	// Apply new appearance to block quotes.

	show quote: quoteShowRule

	show terms: termListShowRule

	// Cross-reference layout, defined once for use in both the front matter
	// and the main matter. Two separate show-rule applications are still
	// needed, since show rules only apply to content that follows them:
	// refs in the front matter must be laid out differently from those in
	// the main matter (see refShowRule).

	let refShowFn = it => refShowRule(
		it,
		language,
		figNumberWithinLevel,
		eqNumberWithinLevel
	)

	// Hide any citations before main matter, so that citation counter is not
	// incremented before main matter starts.

	{
		set footnote.entry( separator: none)
		show footnote.entry: hide
		show ref: refShowFn
		show footnote: none
		if thesisTypeInt > licentiateThesisTypeInt {
			acknowledgements(acknowledgementContents, language)
			preface(author, language, prefaceContents, sijainti, location)
			if includeThanks {
				thanks(thanksContents, language)
			}
			abstracts
		} else {
			abstracts
			preface(author, language, prefaceContents, sijainti, location)
		}
		// The dissertation series specification requires
		// the table of contents to begin on an odd page, a
		// recto of the continuous pagination, so a blank
		// verso is inserted automatically when the
		// preceding front matter would end on a recto. The
		// licentiate shares the doctoral structure, without
		// the series publishing artifacts, so the same
		// rule applies to it.
		if thesisTypeInt >= licentiateThesisTypeInt {
			pagebreak(weak: true, to: "odd")
		}
		[
			#outline(depth: 3,indent:auto)
			#label("outlineLabel")
		]
		// The dissertation series specification places the
		// list of figures and the list of tables right
		// after the table of contents, and the list of
		// abbreviations after them, with the list of
		// original publications following the abbreviations
		// before the first chapter. The field-specific
		// guides of the lower thesis types leave the
		// glossary position open, so every thesis type
		// shares this order here, matching the LaTeX demo
		// front matter, which has listed the lists before
		// the glossary all along.
		if thesisTypeInt >= mastersThesisTypeInt {
			if includeListOfFigures {
				contentFigures(language)
			}
			if includeListOfTables {
				contentTables(language)
			}
			if includeListOfListings {
				contentListings(language)
			}
		}
		if includeGlossary {
			glossary(language, glossaryDict)
		}
		if thesisTypeInt >= licentiateThesisTypeInt and compilationThesis {
			listOfPublications(attachPublications,language,publicationDict)
		}
	}

	aiDisclaimerPage(usedAI, language, tekoälynKäyttöTeksti, aiDisclaimerContents)

	if thesisTypeInt < licentiateThesisTypeInt {
		MAINMATTERPAGENUMBERCOUNTER.update( 1 )
	}

	// The dissertation series specification requires the
	// first chapter to begin on an odd page, a recto of
	// the continuous pagination: a blank verso is inserted
	// automatically when the front matter would otherwise
	// end on a recto. The electronic published copy keeps
	// the pagination of the printed book, so the forced
	// break applies in every output mode. The licentiate
	// shares the doctoral structure here too, without the
	// series publishing artifacts.
	if thesisTypeInt >= licentiateThesisTypeInt {
		pagebreak(
			weak: true,
			to: "odd"
		)
	}

	show: doc => pageSettings(MAINMATTERPART, physicallyPrinted, printTwoSided, thesisTypeInt, colorSeparatorLines, doc)

	set math.vec(delim : "[")

	set math.mat(delim : "[")

	set math.equation(
		numbering: equationNumberingFn(eqNumberWithinLevel, false, 0),
		supplement: none
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

	show ref: refShowFn

	doc

}

/** bibSettings( doc )
 *
 * Lets show rules know that we are currently displaying the bibliography.
 *
***/

#let bibSettings(language, doc)  = {

	let language = sysInput("language", language)

	DOCPARTSTATE.update(BIBLIOGRAPHYPART)
	// Prevent page breaks in the middle of bibliography items.
	show bibliography: set grid.cell(breakable: false)
	set bibliography(title: if language == finnish {"Lähteet"} else {"References"})
	doc
}


/** appendix( figNumberWithinLevel : 1, eqNumberWithinLevel : 1, doc )
 *
 * Defines the appearance of the appendix, supposing that the
 * above tauthesis has already defined the general appearance of
 * the document.
 *
***/

#let appendix(
	figNumberWithinLevel: 1,
	eqNumberWithinLevel: 1,
	mathFont: "STIX Two Math",
	codeFont: "Fira Mono",
	language,
	thesisTypeInteger,
	doc
) = {

	// Command-line overrides, so that the appendix honors the same
	// values as the template (see the sys.inputs section).

	let figNumberWithinLevel = sysInput("figNumberWithinLevel", figNumberWithinLevel)
	let eqNumberWithinLevel = sysInput("eqNumberWithinLevel", eqNumberWithinLevel)
	let mathFont = sysInput("mathFont", mathFont)
	let codeFont = sysInput("codeFont", codeFont)
	let language = sysInput("language", language)

	validateNumberWithinLevel("figNumberWithinLevel", figNumberWithinLevel)

	validateNumberWithinLevel("eqNumberWithinLevel", eqNumberWithinLevel)

	// Reset counters at the start of appendix.

	if figNumberWithinLevel > 0 {
		resetFigureCounters()
	}

	counter(heading).update( 0 )

	if eqNumberWithinLevel > 0 {

		counter(math.equation).update( 0 )

	}

	FIGNUMBERWITHINLEVELSTATE.update(figNumberWithinLevel)

	set heading(numbering: "A.1", supplement: none)

	show heading : headingShowRule.with(
		language,
		mathFont,
		codeFont,
		figNumberWithinLevel,
		eqNumberWithinLevel,
		thesisTypeInteger,
	)

	set math.equation(
		numbering: equationNumberingFn(eqNumberWithinLevel, true, 0),
		supplement: none
	)

	show ref : it => refShowRule( it, language, figNumberWithinLevel, eqNumberWithinLevel)

	DOCPARTSTATE.update(APPENDIXPART)

	doc

}

/**
 * Page settings and such for publication matter.
***/
#let publicationMatter(
	figNumberWithinLevel:1,
	eqNumberWithinLevel:1,
	codeFont: "Fira mono",
	doc
) = {

	// Command-line overrides, so that the publication matter honors
	// the same values as the template (see the sys.inputs section).

	let figNumberWithinLevel = sysInput("figNumberWithinLevel", figNumberWithinLevel)
	let eqNumberWithinLevel = sysInput("eqNumberWithinLevel", eqNumberWithinLevel)
	let codeFont = sysInput("codeFont", codeFont)

	DOCPARTSTATE.update(PUBLICATIONMATTERPART)
	set page(margin: 0cm, header: none, footer: none)
	set heading(
		outlined: false,
		numbering: "I.1.1",
	)
	counter(heading).update(0)
	counter(math.equation).update(0)
	let headingSpacing = 1.5em
	show heading: it => if it.level == 1 {
		it.body + linebreak() + counter(heading).display()
	} else {
		show raw: it => inlineCodeShowRule(codeFont, text.size, it)
		let headingCtr = counter(heading).get().slice(1)
		if it.level <= eqNumberWithinLevel + 1 {
			counter(math.equation).update(0)
		}
		if it.level <= figNumberWithinLevel + 1 {
			resetFigureCounters()
		}
		block(
			spacing: headingSpacing,
			headingCtr.map(str).join(".") + sym.space.nobreak + it.body,
		)
	}
	set math.equation(
		// Publication level 2 headings act as publication titles, so the
		// first heading counter component is dropped from the section prefix.
		numbering: equationNumberingFn(
			eqNumberWithinLevel,
			false,
			if eqNumberWithinLevel > 0 { 1 } else { 0 },
		),
		supplement: none
	)
	show bibliography: set heading(level:2)
	show bibliography: it => context {
		let lastPublicationBefore = query(
			selector(heading.where(level:1)).before(here())
		).last(default: none)
		let lastPublicationLocation = if lastPublicationBefore == none {
			here()
		} else {
			lastPublicationBefore.location()
		}
		let firstPublicationAfter = query(
			selector(heading.where(level:1)).after(here())
		).last(default: none)
		let firstPublicationLocation = if firstPublicationAfter == none {
			here()
		} else {
			firstPublicationAfter.location()
		}
		set bibliography(
			target: selector(cite)
			.after(lastPublicationLocation)
			.and(
				selector(cite)
				.before(firstPublicationLocation)
			)
		)

		show heading: it => block(
			spacing: headingSpacing,
			sticky: true,
			it.body,
		)

		it
	}
	[
		#metadata("publicationMatter")
		<publicationMatter>
	]
	doc
}

// Adjust counters for each publication main matter.
// Remember that publication level 2 headings are shown as level 1 headings,
// so many comparisons have an addend of 1.

#let publicationMainMatter(
	doc,
) = {
	PUBLICATIONPART.update(PUBLICATIONMAINMATTERPART)
	counter(math.equation).update(0)
	resetFigureCounters()
	doc
}

#let publicationEnd(doc) = {
	PUBLICATIONPART.update(UNDEFINEDPUBLICATIONPART)
	doc
}

// Adjust counters for each publication main matter.
// Remember that publication level 2 headings are shown as level 1 headings,
// so many comparisons have an addend of 1.

#let publicationAppendix(
	eqNumberWithinLevel: 0,
	figNumberWithinLevel:0,
	codeFont: "Fira Mono",
	doc
) = {
	PUBLICATIONPART.update(PUBLICATIONAPPENDIXPART)
	set heading(numbering: "I.A.1")
	counter(heading).update(
		(..ctr) => {
			let counterArray = ctr.pos()
			// Grow the counter array if no level 2 headings have been
			// seen yet, since appendix headings start at level 2.
			if counterArray.len() < 2 { counterArray += (0,) }
			counterArray.at(1) = 0
			counterArray
		}
	)
	show heading: it => if it.level == 1 {
		panic("Level 1 headings not allowed within publications. Increase level of every heading by 1.")
	} else {
		show raw: it => inlineCodeShowRule(codeFont, text.size, it)
		if it.level <= eqNumberWithinLevel + 1 {
			counter(math.equation).update(0)
		}
		if it.level <= figNumberWithinLevel + 1 {
			resetFigureCounters()
		}
		let headingSpacing = 1.5em
		block(
			spacing: headingSpacing,
			sticky: true,
			{
				array2SectionNumbering(
					counter(heading).get().slice(1),
					true,
				)
				sym.space.nobreak
				it.body
			}
		)
	}
	set math.equation(
		// Publication level 2 headings act as publication titles, so the
		// first heading counter component is dropped from the section prefix.
		// Note: if the remaining counter is empty, the section prefix is
		// omitted entirely (rendering e.g. "(1)" instead of "(.1)").
		numbering: equationNumberingFn(
			eqNumberWithinLevel,
			true,
			if eqNumberWithinLevel > 0 { 1 } else { 0 },
		),
		supplement: none
	)
	doc
}

/**
 * Displays the info page for a publication and generates
 * a label that other parts of the document can link to.
***/
#let displayPublicationTitlePage(
	citeKey,
	publication,
	language,
	thesisTypeInteger,
	physicallyPrinted,
	printTwoSided,
	publicationNumber,
) = {

	// Command-line overrides, so that the publication pages honor
	// the same values as the template (see the sys.inputs section).

	let language = sysInput("language", language)
	let physicallyPrinted = sysInput("physicallyPrinted", physicallyPrinted)
	let printTwoSided = sysInput("printTwoSided", printTwoSided)

	page(
		margin: thesisTypeIntToMarginsFn(
			physicallyPrinted: physicallyPrinted,
			printTwoSided: printTwoSided,
			thesisTypeInteger
		),
		header:[],
		footer:[],
		{
			set align(center + horizon)

			set text(size: 18pt, weight: "bold")

			set par(
				justify: false,
				spacing: 1.5em,
			)

			// The anchor label needs to match the numbering of the list of
			// publications, where the Nth included publication is linked as
			// "tauthesis-publication-anchor-N". The N is passed in from the
			// call site loop, which iterates the publications in the same
			// order as the list of publications numbers its rows, so no
			// counter introspection is needed here. The page body is a
			// code block, and labels only attach in markup, so the heading
			// and its label remain a markup island inside it.

			let anchorLabelText = "tauthesis-publication-anchor-" + str(publicationNumber)

			[
				= #if language == finnish [
					JULKAISU
				] else [
					PUBLICATION
				]

				#label(anchorLabelText)
			]

			block({

				set text(size: 15pt)


				publication.title
				parbreak()

				set text(size: 12pt, weight: "regular")

				authorsToString(citeKey, publication.author)
				","
				" "
				if lower(publication.type) == "article" {

					if "parent" in publication {

						if "title" in publication.parent {
							text(style: "italic", publication.parent.title)
						} else {
							none
						}
						if "volume" in publication.parent {
							", volume " + str(publication.parent.volume)
						} else {
							none
						}
						if "issue" in publication.parent {
							", issue " + str(publication.parent.issue)
						} else if "number" in publication.parent {
							", number " + str(publication.parent.number)
						} else {
							none
						}
						if "date" in publication {
							" ("
							str(publication.date)
							")"
						} else {
							none
						}
						if "pages" in publication.parent {
							", pp." + str(publication.parent.pages)
						} else {
							none
						}
					}

				} else if lower(publication.type) == "anthos" {

					if "parent" in publication {

						if "title" in publication.parent {
							"In: " + text(style: "italic", publication.parent.title)
						} else {
							none
						}
						if "editor" in publication.parent {
							if type(publication.parent.editor) == array {
								", Ed: " + publication.parent.editor.map(str).join(", ", last: " and ")
							} else {
								", Ed: " + str(publication.parent.editor)
							}
						} else if "editor" in publication {
							if type(publication.editor) == array {
								", Ed: " + publication.editor.map(str).join(", ", last: " and ")
							} else {
							", Ed: " + str(publication.editor)
							}
						} else {
							none
						}
						if "location" in publication.parent {
							", " + publication.parent.location
						} else {
							none
						}
						if "publisher" in publication.parent {
							", " + publication.parent.publisher
						} else {
							none
						}
						if "date" in publication {
							", "
							str(publication.date)
						} else {
							none
						}
						if "pages" in publication.parent {
							", pp." + str(publication.parent.pages)
						} else {
							none
						}
					}
				} else {
					"Unimplemented publication type"
				}

				parbreak()

				if "serial-number" in publication {
					if "doi" in publication.serial-number {
						let doi = publication.serial-number.doi
						"DOI: " + link("https://www.doi.org/" + publication.serial-number.doi, publication.serial-number.doi)
					} else {
						none
					}
				} else {
					none
				}

				parbreak()

				set text(weight: "bold")


				if "license" in publication and publication.license == none {
					"Publication reprinted with the permission of the copyright holders"
				} else if "license" in publication and publication.license != none {
					"This work is licensed under " + publication.license
				} else {
					"Publication reprinted with the permission of the copyright holders"
				}
			})
		}
	)
}

/**
 * Read the given Hayagriva YAML file for publication details and displayes them in
 * the current thesis.
***/

#let attachPublications(
	thesisType,
	publicationDict,
	language,
	physicallyPrinted: false,
	printTwoSided: false,
) = {
	if publicationDict == none or publicationDict.len() == 0 {
		return
	}

	let thesisTypeInt = thesisTypeToIntFn(thesisType)

	if thesisTypeInt >= licentiateThesisTypeInt {

		let publicationNumber = 0

		for (citeKey, publication) in thesisPublications(publicationDict) {
			publicationNumber += 1
			displayPublicationTitlePage(
				citeKey,
				publication,
				language,
				thesisTypeInt,
				physicallyPrinted,
				printTwoSided,
				publicationNumber,
			)
		}

	}

}

/**
 * Validates a given file path and then returns it and its suffix.
***/

/**
 * Splits a publication file path into the whole path, its directory, and the
 * stem and suffix of the file name. Both are used e.g. when publication pages
 * are given as numbered image files.
***/
#let publicationPathParts(citeKey, publication) = {
	let filePathStr = publication.path
	// Validate file path.
	let filePathParts = filePathStr.split("/")
	let directoryPath = filePathParts.slice(0,-1).join("/")
	let fileName = filePathParts.last()
	let fileNameParts = fileName.split(".")
	if fileNameParts.len() < 2 {
		panic("Given publication " + citeKey + " file name " + fileName + " was not valid. It needs to be of the form stem.type to differentiate between file types.")
	}
	(
		filePath: filePathStr,
		directory: directoryPath,
		stem: fileNameParts.slice(0,-1).join("."),
		suffix: fileNameParts.last(),
	)
}

/**
 * Validates a given file path and then returns it and its suffix.
***/
#let publicationFilePath(citeKey, publication) = {
	let parts = publicationPathParts(citeKey, publication)
	(parts.at("filePath"), parts.at("suffix"))
}

/**
 * Alternative text of an image containing a single page of a publication.
***/
#let publicationPageAltText(citeKey, publication, pagei) = (
	"Page "
	+ str(pagei + 1)
	+ "of publication \""
	+ publication.title
	+ "\" by "
	+ if type(publication.author) == str {
		publication.author
	} else if type(publication.author) == array {
		publication.author.join(",", last: " and ")
	} else {
		panic("Publication " + citeKey + " author list was not a string or an array.")
	}
	+ ". DOI: " + publication.serial-number.doi + "."
)

#let loadPublicationPages(
	citeKey,
	publication,
	filePath,
	fileNameSuffix,
	thesisTypeInt,
	// The language argument is currently unused, but it is kept in the
	// signature so that existing callers do not break.
	language,
	physicallyPrinted,
	printTwoSided,
) = {

	// Command-line overrides, so that the publication pages honor
	// the same values as the template (see the sys.inputs section).

	let language = sysInput("language", language)
	let physicallyPrinted = sysInput("physicallyPrinted", physicallyPrinted)
	let printTwoSided = sysInput("printTwoSided", printTwoSided)

	let footerDescent = 60%
	assert(
		type(filePath) == path,
		message: "loadPublicationPages: the filePath argument needs to be of type path."
	)
	assert(
		"n-of-pages" in publication,
		message: "The publication " + citeKey + " attached to a thesis needs to contain the field n-of-pages in the bibliography file.",
	)
	assert(
		type(publication.n-of-pages) == int and publication.n-of-pages > 0,
		message: "The field n-of-pages in the entry " + citeKey + " of the biubliography file was not a positive integer. ",
	)
	if fileNameSuffix == "typ" {
		PUBLICATIONPAGECOUNTER.update(1)
		set page(
			paper: thesisTypeIntToPageSizeFn(thesisTypeInt),
			margin: thesisTypeIntToMarginsFn(
				physicallyPrinted: physicallyPrinted,
				printTwoSided: printTwoSided,
				thesisTypeInt,
			),
			header: none,
			footer: context {
				PUBLICATIONPAGECOUNTER.step()
				set align(center)
				PUBLICATIONPAGECOUNTER.display()
			},
			footer-descent: footerDescent,
		)
		include filePath
		show: publicationEnd
	} else if fileNameSuffix == "pdf" {
		let pdfBytes = read(filePath, encoding: none)
		for pagei in range(publication.n-of-pages) {
			image(
				pdfBytes,
				width: 100%,
				page: pagei + 1,
				alt: publicationPageAltText(citeKey, publication, pagei)
			)
		}
	} else if fileNameSuffix in ("svg","png","jpg") {
		// These file formats are split into multiple files,
		// so we assume that the file names are of the form
		// "stem-pagenumber.type".
		// We automatically add the required page numbers.
		let pathParts = publicationPathParts(citeKey, publication)
		for pagei in range(publication.n-of-pages) {
			let filePathWithPageNum = pathParts.directory + "/" + pathParts.stem + "-" + str(pagei+1) + "." + fileNameSuffix
			image(
				filePathWithPageNum,
				width: 100%,
				page: pagei + 1,
				alt: publicationPageAltText(citeKey, publication, pagei)
			)
		}
	} else {
		panic("Unsupported file type ." + fileNameSuffix + " for attaching publications.")
	}
}
