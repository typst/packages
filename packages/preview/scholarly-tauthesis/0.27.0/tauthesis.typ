/** tauthesis.typ
 *
 * This module defines the Tampere University thesis template structure. You
 * should not need to touch this file. Define your own commands in preamble.typ
 * instead.
 *
***/

//// Counters and kinds

#let UNKNOWN-SUPPLEMENT = "Unknown"

#let IMAGE-COUNTER = counter("IMAGECOUNTER")

#let TABLE-COUNTER = counter("TABLECOUNTER")

#let CODE-COUNTER = counter("CODECOUNTER")

#let TAUTHEOREM-COUNTER = counter("tautheorem")

#let PUBLICATION-COUNTER = counter("PUBLICATIONCOUNTER")

#let PUBLICATION-PAGE-COUNTER = counter("PUBLICATIONPAGECOUNTER")

#let SUBFIGURE-COUNTER = counter("SUBFIGURECOUNTER")

#let UNKNOWN-COUNTER = counter("UNKNOWNCOUNTER")

#let TAUTHEOREM-KIND = "TAUTHEOREMKIND"

#let PUBLICATION-KIND = "PUBLICATIONKIND"

#let SUBFIGURE-KIND = "SUBFIGUREKIND"

#let PREFACE-PAGE-NUMBER-COUNTER = counter("PREFACEPAGENUMBERCOUNTER")

#let MAINMATTER-PAGE-NUMBER-COUNTER = counter("MAINMATTERPAGENUMBERCOUNTER")

#let INLINE-CODE-LUMA-BACKGROUND = 240

/** DOC-PART-STATE
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

#let INITIAL-PART = 0
#let TITLEPAGE-PART = 1
#let FRONTMATTER-PART = 2
#let MAINMATTER-PART = 3
#let BIBLIOGRAPHY-PART = 4
#let APPENDIX-PART = 5
#let PUBLICATIONMATTER-PART = 6

#let DOC-PART-STATE = state("DOCPARTSTATE", INITIAL-PART)

// These states keep track of whether we are in a publication main matter or appendix.

#let PUBLICATION-MAINMATTER-PART = 7
#let PUBLICATION-APPENDIX-PART = 8
#let UNDEFINED-PUBLICATION-PART = 9

#let PUBLICATION-PART = state("PUBLICATIONPART", UNDEFINED-PUBLICATION-PART)

// This global state is needed so that theorem blocks can fetch the maximum
// heading level under which they should be numbered.

#let FIG-NUMBER-WITHIN-LEVEL-STATE = state("FIGNUMBERWITHINLEVELSTATE")

/**
 * Used to store the current chapter heading for display in headers.
***/
#let SHORT-CHAPTER-HEADING-STATE = state("SHORTCHAPTERHEADINGSTATE", none)

//// Thesis types.

/**
 * The English thesis types are the only template inputs: the Finnish
 * thesis type shown on the Finnish title page and abstract is derived
 * from the English one automatically.
***/

#let bachelor-of-technology-thesis-type = "Bachelor's Thesis in Technology"

#let bachelor-of-philosophy-thesis-type = "Bachelor's Thesis"

#let bachelor-of-medicine-thesis-type = "Bachelor's Thesis in Medicine"

#let master-of-technology-thesis-type = "Master's Thesis in Technology"

#let master-of-philosophy-thesis-type = "Master's Thesis"

#let master-of-medicine-thesis-type = "Master's Thesis in Medicine"

#let licentiate-of-technology-thesis-type = "Licentiate Thesis in Technology"

#let licentiate-of-philosophy-thesis-type = "Licentiate Thesis"

#let licentiate-of-health-sciences-thesis-type = "Licentiate Thesis in Health Sciences"

#let doctoral-thesis-type = "Doctoral Thesis"

#let acceptable-thesis-types = (bachelor-of-technology-thesis-type, bachelor-of-philosophy-thesis-type, bachelor-of-medicine-thesis-type, master-of-technology-thesis-type, master-of-philosophy-thesis-type, master-of-medicine-thesis-type, licentiate-of-technology-thesis-type, licentiate-of-philosophy-thesis-type, licentiate-of-health-sciences-thesis-type, doctoral-thesis-type)

/**
 * The Finnish translations of the thesis types. These are no longer
 * template inputs; thesis-type-to-työn-tyyppi-fn maps the English thesis
 * type to its translation.
***/

#let kandidaatin-työn-tyyppi = "Kandidaatintyö"

#let kandidaatin-tutkielman-tyyppi = "Kandidaatintutkielma"

#let laaketieteen-kandidaatin-opinnaytetyon-tyyppi = "Lääketieteen kandidaatin opinnäytetyö"

#let diplomi-työn-tyyppi = "Diplomityö"

#let maisterin-työn-tyyppi = "Pro gradu -tutkielma"

#let syventavan-opinnaytetyon-tyyppi = "Syventävä opinnäytetyö"

#let lisensiaatin-työn-tyyppi = "Lisensiaatintyö"

#let lisensiaatin-tutkielman-tyyppi = "Lisensiaatintutkielma"

#let lisensiaatin-tutkimuksen-tyyppi = "Lisensiaatintutkimus"

#let tohtorin-työn-tyyppi = "Väitöskirja"

// Maps each English thesis type to its Finnish translation.

#let thesis-type-translations = (
	(bachelor-of-technology-thesis-type): kandidaatin-työn-tyyppi,
	(bachelor-of-philosophy-thesis-type): kandidaatin-tutkielman-tyyppi,
	(bachelor-of-medicine-thesis-type): laaketieteen-kandidaatin-opinnaytetyon-tyyppi,
	(master-of-technology-thesis-type): diplomi-työn-tyyppi,
	(master-of-philosophy-thesis-type): maisterin-työn-tyyppi,
	(master-of-medicine-thesis-type): syventavan-opinnaytetyon-tyyppi,
	(licentiate-of-technology-thesis-type): lisensiaatin-työn-tyyppi,
	(licentiate-of-philosophy-thesis-type): lisensiaatin-tutkielman-tyyppi,
	(licentiate-of-health-sciences-thesis-type): lisensiaatin-tutkimuksen-tyyppi,
	(doctoral-thesis-type): tohtorin-työn-tyyppi,
)

#let bachelors-thesis-type-int = 1
#let masters-thesis-type-int = 2
#let licentiate-thesis-type-int = 3
#let doctoral-thesis-type-int = 4

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
 * dictionaries, the included content files, and citation-style and
 * bib-file-suffix, which main.typ consumes in its own bibliography
 * call.
 *
***/

// Command-line names of the thesis type constants.

#let thesis-type-input-names = (
	bachelor-of-technology-thesis-type: bachelor-of-technology-thesis-type,
	bachelor-of-philosophy-thesis-type: bachelor-of-philosophy-thesis-type,
	bachelor-of-medicine-thesis-type: bachelor-of-medicine-thesis-type,
	master-of-technology-thesis-type: master-of-technology-thesis-type,
	master-of-philosophy-thesis-type: master-of-philosophy-thesis-type,
	master-of-medicine-thesis-type: master-of-medicine-thesis-type,
	licentiate-of-technology-thesis-type: licentiate-of-technology-thesis-type,
	licentiate-of-philosophy-thesis-type: licentiate-of-philosophy-thesis-type,
	licentiate-of-health-sciences-thesis-type: licentiate-of-health-sciences-thesis-type,
	doctoral-thesis-type: doctoral-thesis-type,
)

/**
 *
 * Overrides `current` with the command-line input `key`, if one was
 * given, converting the input string to the type of `current`.
 *
***/

#let sys-input(key, current) = if key not in sys.inputs {
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
 * Like sys-input, but for the thesis type, which is given as the name
 * of one of the thesis type constants.
 *
***/

#let thesis-type-sys-input(current) = if "thesis-type" not in sys.inputs {
	current
} else {
	let raw = sys.inputs.at("thesis-type")
	if raw in thesis-type-input-names {
		thesis-type-input-names.at(raw)
	} else {
		panic("tauthesis: unknown command-line thesis type \"" + raw + "\". Valid values are: " + thesis-type-input-names.keys().join(", ") + ".")
	}
}

/**
 *
 * Whether the publication pages are attached to the document. The
 * compilation-thesis and attach-publications values are read through
 * the command-line overrides, so a command-line input keeps the
 * attached publications and the frontmatter publication list in
 * agreement.
 *
***/

#let include-publication-pages(thesis-type-integer, compilation-thesis, attach-publications) = {
	let compilation-thesis = sys-input("compilation-thesis", compilation-thesis)
	let attach-publications = sys-input("attach-publications", attach-publications)
	thesis-type-integer >= licentiate-thesis-type-int and compilation-thesis and attach-publications
}

/**
 *
 * Converts a given thesis type string to an integer for easy comparisons.
 *
***/

#let thesis-type-to-int-fn(thesis-type) = {
	let thesis-type = thesis-type-sys-input(thesis-type)
	if thesis-type in (bachelor-of-technology-thesis-type, bachelor-of-philosophy-thesis-type, bachelor-of-medicine-thesis-type) {
		bachelors-thesis-type-int
	} else if thesis-type in (master-of-technology-thesis-type, master-of-philosophy-thesis-type, master-of-medicine-thesis-type) {
		masters-thesis-type-int
	} else if thesis-type in (licentiate-of-technology-thesis-type, licentiate-of-philosophy-thesis-type, licentiate-of-health-sciences-thesis-type) {
		licentiate-thesis-type-int
	} else if thesis-type == doctoral-thesis-type {
		doctoral-thesis-type-int
	} else {
		panic("Unknown thesis type " + str(thesis-type) + ". Cannot convert to integer.")
	}
}

/**
 *
 * Derives the Finnish thesis type from the given English thesis type.
 *
***/

#let thesis-type-to-työn-tyyppi-fn(thesis-type) = if thesis-type in thesis-type-translations {
	thesis-type-translations.at(thesis-type)
} else {
	panic("Unknown thesis type " + str(thesis-type) + ". Cannot derive the Finnish thesis type from it.")
}

/**
 *
 * Converts a given thesis type string to a page size.
 *
***/

#let thesis-type-int-to-page-size-fn(thesis-type-int) = {
	if thesis-type-int <= licentiate-thesis-type-int {
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

#let thesis-type-int-to-margins-fn(physically-printed: false, print-two-sided: true, thesis-type-int) = {
	// Horizontal-margin principle: printed documents have unequal
	// horizontal margins with a binding allowance toward the
	// binding side (mirrored between the two sides in two-sided
	// output, on the left of every page in one-sided output);
	// electronic documents have equal horizontal margins (the
	// smaller of the two printed horizontal margins).
	if thesis-type-int < licentiate-thesis-type-int {
		if physically-printed {
			if print-two-sided {
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
		if physically-printed {
			if print-two-sided {
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
#let thesis-type-validation-fn(thesis-type) = {

	assert(
		thesis-type in acceptable-thesis-types,
		message: "The given thesis type \""
			+ str(thesis-type)
			+ "\" is not one of the acceptable ones "
			+ acceptable-thesis-types.join(", ", last: " or ")
			+ ". Note the capitalization. The Finnish thesis type is derived automatically from the English one."
	)

}

//// Constants

#let template-name = "tauthesis"

#let tuni-purple = rgb(78,0,148)

#let finnish = "fi"

#let english = "en"

#let heading-sep = 2 * " "

#let tuni-code-block-inset = 0.5em

#let code-supplement-fn(language) = {
	if language == finnish {
		[Listaus]
	} else {
		[Listing]
	}
}

#let appendix-prefix-fn(language) = if language == finnish {
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

#let month-names-fi = (
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

#let month-names-fi-partitive = (
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

#let localize-month-fi(month) = {
	if month < 1 or month > 12 {
		panic("Month must be between [1,12]")
	}
	month-names-fi.at(month - 1)
}

// Gives a Finnish month name in the partitive case, e.g. "tammikuuta".

#let localize-month-fi-partitive(month) = {
	if month < 1 or month > 12 {
		panic("Month must be between [1,12]")
	}
	month-names-fi-partitive.at(month - 1)
}


/**
 *
 * Converts a given integer into a letter that might be used in
 * appendix numbering.
 *
***/

#let int2-appendix-letter(ii) = {
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

#let array2-section-numbering(arr, in-appendix) = {
	if not ( arr.all( elem => type(elem) == int ) ) { panic("Array elements used to construct section numberings need to contain integers.") }
	let firstnum = arr.first(default: none)
	let chaptersymbol = if firstnum == none {""} else {
		if in-appendix {
			int2-appendix-letter(firstnum)
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
 * numbered via SUBFIGURE-COUNTER separately, and figure show rules step the
 * unknown-kind counter for subfigures on purpose (see fig-show-rule).
 *
***/

#let figure-counter-from-kind(kind) = {
	if kind == image {
		IMAGE-COUNTER
	}
	else if kind == table {
		TABLE-COUNTER
	}
	else if kind == raw {
		CODE-COUNTER
	}
	else if kind == TAUTHEOREM-KIND {
		TAUTHEOREM-COUNTER
	}
	else if kind == PUBLICATION-KIND {
		PUBLICATION-COUNTER
	}
	else {
		UNKNOWN-COUNTER
	}
}

/**
 * Resets all per-chapter figure-related counters to zero.
***/
#let reset-figure-counters() = {
	IMAGE-COUNTER.update(0)
	TABLE-COUNTER.update(0)
	CODE-COUNTER.update(0)
	TAUTHEOREM-COUNTER.update(0)
	UNKNOWN-COUNTER.update(0)
}

/**
 * Validates that a "number within level" argument is in the range 0..4.
***/
#let validate-number-within-level(name, value) = {
	if value < 0 or value > 4 {
		panic("Argument " + name + " must be in the set {0,1,2,3,4}. Received " + str(value) + ".")
	}
}

/**
 * Extracts the text of an optional subtitle given as a string or content,
 * returning the empty string if there is no subtitle text.
***/
#let subtitle-text(subtitle) = {
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
#let subtitle-suffix(subtitle) = {
	let text = subtitle-text(subtitle)
	if text != "" { ": " + text } else { "" }
}

/**
 * Displays inline code inside headings, outline entries and similar places
 * where code blocks are not allowed.
***/
#let inline-code-show-rule(code-font, font-size, it) = if it.block {
	panic("Code blocks are not allowed here!")
} else {
	set text(font: code-font, size: font-size)
	box(
		inset : (x : 0.2 * font-size),
		outset : (y : 0.2 * font-size),
		fill : luma(INLINE-CODE-LUMA-BACKGROUND),
		radius : 0.25 * font-size,
		it.text
	)
}

/**
 * Builds the numbering function of display equations. The section prefix is
 * taken from the given number of leading levels of the heading counter;
 * `skip-first-levels` drops leading counter components (used in publication
 * matter, where level 1 headings act as publication titles).
***/
#let equation-numbering-fn(within-level, in-appendix, skip-first-levels) = nn => context {
	let ctrarr = counter(heading).get()
	let ctrarr = ctrarr.slice(
		skip-first-levels,
		calc.min(within-level + skip-first-levels, ctrarr.len())
	)
	{
		"("
		array2-section-numbering(ctrarr, in-appendix)
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
#let authors-to-string(cite-key, authors, et-al-threshold: 10) = {
	if type(authors) == str {
		authors
	} else if type(authors) == array {
		if et-al-threshold != none and authors.len() > et-al-threshold {
			authors.first() + " et al."
		} else {
			authors.join(", ", last: " and ")
		}
	} else {
		panic("The author field of publication " + cite-key + " needs to be given as a string or an array of strings.")
	}
}


/**
 *
 * Displays the AI disclaimer page, where students explain where and how they
 * used AI in producing their thesis, if they did.
 *
 ***/
#let ai-disclaimer-page(used-ai, language, tekoälyn-käyttö-teksti, ai-disclaimer-contents) = {


	let ballot-box-settings = (
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
			risks-title: [Riskien tiedostaminen],
			risks-text: [Olen tietoinen siitä, että olen täysin vastuussa koko opinnäytteeni sisällöstä, mukaan lukien osat, joissa on hyödynnetty tekoälyä, ja hyväksyn vastuun mahdollisista eettisten ohjeiden rikkomuksista.],
		)
	} else {
		(
			title: [Use of artificial intelligence in this work],
			question: [Artificial intelligence (AI) has been used in my thesis:],
			yes: [Yes],
			no: [No],
			risks-title: [Acknowledgement of risks],
			risks-text: [I acknowledge that I am fully responsible for the entire content of my thesis, including the parts generated by AI, and accept accountability for any violations of ethical standards in publications.],
		)
	}


	heading(strings.title)

	strings.question

	grid(
		..ballot-box-settings,
		if used-ai { sym.ballot.cross } else { sym.ballot },
		[~],
		strings.yes,
		if used-ai { sym.ballot } else { sym.ballot.cross },
		[~],
		strings.no,
	)

	if used-ai {
		if language == finnish { tekoälyn-käyttö-teksti } else { ai-disclaimer-contents }
	}

	heading(level: 2, strings.risks-title)

	strings.risks-text
}

#let subfigure = figure.with(
	supplement: none,
	kind: SUBFIGURE-KIND,
	numbering: "(a)",
)

/**
 * This function should be used to typeset captions of
 * all figures that have a very long caption. The short
 * alternative caption will be displayed in a related list
 * of figures.
***/

#let figure-caption(long: none, short: none) = {
	assert(
		long !=none,
		message: "figure-caption: A figure needs to have at least a long (full) caption. Use the long argument of this function to enter one."
	)
	context if DOC-PART-STATE.get() < MAINMATTER-PART {
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

#let ref-show-rule(it, language, fig-number-within-level, eq-number-within-level) = {

	let appendix-prefix = appendix-prefix-fn(language)

	show link: set text( fill: black, weight: "regular" )

	let el = it.element

	if el != none {
		let element-location = el.location()
		let doc-part = DOC-PART-STATE.at(element-location)
		let in-appendix = doc-part == APPENDIX-PART
		let in-publication-appendix = PUBLICATION-PART.at(element-location) == PUBLICATION-APPENDIX-PART
		let in-publications = doc-part >= PUBLICATIONMATTER-PART
		let heading-counter = counter(heading).at(element-location)
		let heading-counter-start = if in-publications { 1 } else { 0 }
		let heading-counter-end = calc.min(
			heading-counter-start + if el.func() == figure {
				fig-number-within-level
			} else if el.func() == math.equation {
				eq-number-within-level
			} else {
				0
			},
			heading-counter.len(),
		)
		let truncated-heading-counter = heading-counter.slice(
			heading-counter-start,
			heading-counter-end,
		)
		let ref-text = if el.func() == figure {
			let (carray, element-supplement) = if el.kind == raw {
				(
					CODE-COUNTER.at(element-location),
					code-supplement-fn(language),
				)
			}
			else if el.kind == SUBFIGURE-KIND {
				// For this one we need a parent figure counter value as well.
				// There is no directly accessible concept of a parent element in Typst,
				// so we will query figures of kinds that can contain subfigures and pick
				// the one that comes just before this subfigure.
				let figures-before = query(
					selector(figure)
					.before(element-location)
				)
				let parent-figure = figures-before
					.filter(x => x.kind != SUBFIGURE-KIND)
					.last()
				let parent-counter = figure-counter-from-kind(parent-figure.kind)
				let parent-counter-value = parent-counter.at(parent-figure.location())
				(
					parent-counter-value + SUBFIGURE-COUNTER.at(element-location),
					parent-figure.supplement,
				)
			}
			else {
				(
					figure-counter-from-kind(el.kind).at(element-location),
					el.supplement,
				)
			}
			let supplement = if it.citation.supplement != none { it.citation.supplement } else { element-supplement }
			carray.last() += 1
			// If we are within a subfigure, also increment parent figure counter.
			if el.kind == SUBFIGURE-KIND {
				carray.first() += 1
			}
			{
				supplement
				if supplement != [] { sym.space.nobreak } else { none }
				if fig-number-within-level > 0 {
					array2-section-numbering(
						truncated-heading-counter,
						(in-appendix or in-publication-appendix)
					)
				}
				if fig-number-within-level > 0 {"."}
				carray.map(str).first()
				if el.kind == SUBFIGURE-KIND {
					"." + numbering("a", carray.last())
				} else {
					none
				}
			}
		}
		else if el.func() == heading {
			let prefix = if it.citation.supplement == none and el.level == 1 and in-appendix {
				appendix-prefix
			} else if it.citation.supplement != none {
				it.supplement
			} else {
				none
			}
			(
				if prefix != none { prefix + sym.space.nobreak }
				+
				array2-section-numbering(heading-counter, in-appendix or in-publication-appendix)
			)
		}
		else if el.func() == math.equation {
			let eqctr = counter(math.equation).at(element-location)
			let equation-num = {
				if eq-number-within-level > 0 {
					array2-section-numbering(
						truncated-heading-counter,
						in-appendix or in-publication-appendix
					)
					"."
				}
				str(eqctr.last())
			}
			let number-text = "(" + equation-num + ")"
			math.equation(
				alt: number-text,
				$#number-text$
			)
		}
		else {
			if DOC-PART-STATE.at(here()) < MAINMATTER-PART {
				none
			} else {
				it
			}
		}
		link(element-location,ref-text)
	}
	else {
		if DOC-PART-STATE.at(here()) < MAINMATTER-PART {
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

#let fig-show-rule(language,fig-number-within-level,it) = {
	let code-supplement = code-supplement-fn(language)
	let figloc = it.location()
	let doc-part = DOC-PART-STATE.at(figloc)
	let in-appendix = doc-part == APPENDIX-PART
	let in-publications = doc-part >= PUBLICATIONMATTER-PART
	let in-publication-appendix = PUBLICATION-PART.at(figloc) == PUBLICATION-APPENDIX-PART
	let heading-counter-start = if in-publications { 1 } else { 0 }
	let heading-counter = counter(heading).get()
	let heading-counter = heading-counter.slice(
		heading-counter-start,
		calc.min(
			fig-number-within-level + heading-counter-start,
			heading-counter.len(),
		)
	)

	// Reset subfigure counter when entering a new figure.

	if it.kind != SUBFIGURE-KIND {
		SUBFIGURE-COUNTER.update(0)
	}

	// Step the relevant counter and read back its stepped value.
	// Subfigures intentionally step the unknown-kind counter here and read
	// their own SUBFIGURE-COUNTER instead; the subfigure counter is stepped
	// inside the caption layout below.

	if it.kind == SUBFIGURE-KIND {
		UNKNOWN-COUNTER.step()
	} else {
		figure-counter-from-kind(it.kind).step()
	}

	let ctr = if it.kind == SUBFIGURE-KIND {
		SUBFIGURE-COUNTER.get()
	} else {
		figure-counter-from-kind(it.kind).get()
	}

	ctr.last() += 1

	let supplement = if it.kind == raw {
		code-supplement
	} else if it.kind == SUBFIGURE-KIND {
		none
	} else {
		it.supplement
	}

	set text(size: text.size - 1pt)

	let caption = block(
		width:95%,
		layout( container-size => {
			let caption = if it.kind == SUBFIGURE-KIND {
				{
					set text(weight: "bold")
					SUBFIGURE-COUNTER.step()
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
					array2-section-numbering(
						heading-counter,
						in-appendix or in-publication-appendix
					)
					if fig-number-within-level > 0 {"."}
					ctr.map(str).join(".")
					"."
				}
				if it.caption == none {
					panic("Figures other than subfigures MUST have a caption.")
				}
				sym.space.nobreak
				it.caption.body
			}
			let caption-size = measure(caption)
			let alignment = if caption-size.width >= container-size.width {
				left
			} else {
				center
			}
			set align(alignment)
			caption
		} )
	)

	let fig = if it.kind == TAUTHEOREM-KIND {
		// Theorem blocks lay themselves out in tau-theorem-block.
		it
	} else if it.kind == PUBLICATION-KIND {
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

	let unbreakable-figure = block(
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
			h(1fr) + unbreakable-figure + h(1fr)
		)
	} else {
		set align(center)
		unbreakable-figure
	}
}

/**
 * Determines the effects which are applied to headings based on its level.
***/

#let heading-effect-function(body,level) = if level == 1 {
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

#let heading-show-rule(
	language,
	math-font,
	code-font,
	fig-number-within-level,
	eq-number-within-level,
	thesis-type-integer,
	it,
) = {

	if it.level == 1 { SHORT-CHAPTER-HEADING-STATE.update(it.body) }

	set text(weight: "regular")

	let appendix-prefix = appendix-prefix-fn(language) + sym.space.nobreak

	if it.level <= eq-number-within-level and it.outlined and eq-number-within-level > 0 {
		counter(math.equation).update( 0 )
	}
	if it.outlined and it.level <= fig-number-within-level and fig-number-within-level > 0 {
		reset-figure-counters()
	}
	let doc-part = DOC-PART-STATE.get()
	let in-appendix = doc-part == APPENDIX-PART
	let indentation = if it.level == 1 and not in-appendix { 1cm } else if it.level == 1 and in-appendix { 0.7em } else { 1em }
	set heading(
		hanging-indent: indentation,
	)
	set par(
		justify:false,
		hanging-indent: indentation,
	)
	let in-bibliography = doc-part == BIBLIOGRAPHY-PART
	let in-publications = doc-part == PUBLICATIONMATTER-PART
	if it.level > 4 {
		panic("Headings with levels greater than 4 are not supported by this template. Your document structure is too fine-grained.")
	}
	// Text size, spacing above and spacing below per heading level.
	// Note: below-head-spacing for levels 2..4 of doctoral theses intentionally
	// uses the text size in effect where the heading appears.
	let (text-size, above-head-spacing, below-head-spacing) = if thesis-type-integer > licentiate-thesis-type-int {
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
	show math.equation: set text(font: math-font, size: text-size)
	show raw: it => inline-code-show-rule(code-font, text-size, it)
	set text(
		size : text-size,
		hyphenate: false,
	)
	let number-space = if it.outlined and it.level <= 3 and not in-bibliography {
		h(
			indentation,
			weak:true,
		)
	} else {
		""
	}
	// Page breaks at the start of every chapter.
	// However, let publications themselves decide whether there is a page break at every chapter start.
	if it.level == 1 and not in-publications {
		pagebreak(weak: true)
	}
	show link: set text(fill: black)
	v(above-head-spacing, weak: true)
	link(
		label("outlineLabel"),
		block(
			sticky:true,
			{
				if it.level == 1 and in-appendix {
					appendix-prefix
				} else {
					""
				}
				if it.outlined {
					if it.level > 3 {
						// Leave counter out.
					}
					else if in-publications {
						counter(heading).display("1.1")
					}
					else if it.level == 1 and in-appendix {
						counter(heading).display("A.1.")
					}
					else if in-appendix {
						counter(heading).display("A.1")
					}
					else if in-bibliography {
						[]
					}
					else {
						counter(heading).display()
					}
				} else {
					if in-publications {
						counter(heading).display("1.1") + for _ in range(calc.max(2,3 - it.level)) {
							sym.space.nobreak
						}
					}
				}
				number-space
				heading-effect-function( it.body, it.level )
				parbreak() // Needed to introduce a paragraph with hanging indent into this block.
			}
		)
	)
	v(below-head-spacing, weak:true)
}

/**
 *
 * Defines how outline entries are to be displayed. This is to be used within a
 * show rule, so that context and therefore information about page numbers and
 * such can be resolved.
 *
***/

#let outline-entry-show-rule(
	language,
	fig-number-within-level,
	thesis-type-int,
	math-font,
	code-font,
	it
) = {
	let code-supplement = code-supplement-fn(language)
	let appendix-prefix = appendix-prefix-fn(language) + sym.space.nobreak
	let el = it.element
	let text-size = if thesis-type-int >= licentiate-thesis-type-int { 10pt } else { 11pt }
	set text( size : text-size )
	show math.equation: set text(font: math-font, size: text-size)
	show raw: it => inline-code-show-rule(code-font, text-size, it)
	let element-location = el.location()
	let doc-part = DOC-PART-STATE.at(element-location)
	if doc-part >= PUBLICATIONMATTER-PART { return none }
	// The reduction of the page number here is required because of the ISSN page of a Doctoral thesis.
	// There might be a less brittle solution for this, but this works, so...
	let element-page-num = if thesis-type-int >= licentiate-thesis-type-int {
		counter(page).at(element-location).first()
	} else {
		MAINMATTER-PAGE-NUMBER-COUNTER.at(element-location).first() - 1
	}
	let heading-counter = counter(heading).at(element-location)
	let heading-counter = heading-counter.slice(
		0,
		calc.min(fig-number-within-level,heading-counter.len())
	)
	let in-appendix = doc-part == APPENDIX-PART
	let in-bibliography = doc-part == BIBLIOGRAPHY-PART
	let additional-outline-h-space = if in-bibliography { 0pt } else { 0.5cm }
	let embellishment-color = black
	show link: set text(fill: embellishment-color)
	let (number, space, entry) = if el.func() == figure {
		let (carray, supplement) = if el.kind == raw {
			(CODE-COUNTER.at(element-location), code-supplement)
		} else if el.kind in (image, table, TAUTHEOREM-KIND) {
			(figure-counter-from-kind(el.kind).at(element-location), el.supplement)
		} else {
			(UNKNOWN-COUNTER.at(element-location), UNKNOWN-SUPPLEMENT)
		}
		if carray == none {
			panic("A figure did not contain a number that can be referenced. Please contact the developers of tauthesis.")
		}
		carray.last() += 1
		(
			strong({
				supplement
				" "
				array2-section-numbering(heading-counter, in-appendix)
				if heading-counter.len() > 0 {"."}
				carray.map(str).join(".")
				"."
			}),
			sym.space.nobreak,
			el.caption.body,
		)
	} else if el.func() == heading {
		let ctr = counter(heading).at(element-location)
		let (prefix, numbering, colon, space, bodycolor, bodyweight) = if in-appendix {
			if el.level == 1 {
				(appendix-prefix, array2-section-numbering(ctr, in-appendix), ".", sym.space.nobreak, black, "regular")
			} else {
				([], array2-section-numbering(ctr, in-appendix), "", sym.space.nobreak, black, "regular")
			}
		} else if in-bibliography {
			("", "", "", "", embellishment-color, "regular")
		} else {
			([], array2-section-numbering(ctr, in-appendix), "", sym.space.nobreak, black, "regular")
		}
		let effect-fn = if el.level == 1 {
			heading-effect-function
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
			space + h(additional-outline-h-space),
			effect-fn(
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
	let space-width = measure(space).width
	let counter-width = 0cm + range(it.level).map(ii => measure((("A",) * ii).join(".")).width).sum()
	let space-widths = (it.level - 1) * space-width
	link(
		element-location,
		block(
			grid(
				columns: (auto,1fr,measure(MAINMATTER-PAGE-NUMBER-COUNTER.final().map(str).join()).width + 5pt),
				align: (top+left,top+left,bottom+right),
				h(counter-width + space-widths),
				par(
					hanging-indent: 1cm,
					{
						number
						space
						entry
						box(width: 1fr, repeat[.])
					},
				),
				str(element-page-num),
			)
		)
	)
}

/**
 *
 * Defines the look of code elements.
 *
***/

#let raw-show-rule(code-font, font-size, it) = {

	set text( font : code-font, size: font-size)

	if it.block {

		let last-line = it.lines.last()

		let number-column-width = if last-line.count < 10 {
			0.7em
		} else {
			calc.floor(calc.log(last-line.count, base:10)) * 1em
		}

		block(
			width: 100%,
			inset: tuni-code-block-inset,
			fill: luma(252),
			{
				set align(left)
				grid(
					columns: (number-column-width, 1fr),
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
			inset : (x : 0.2 * font-size),
			outset : (y : 0.2 * font-size),
			fill : luma(INLINE-CODE-LUMA-BACKGROUND),
			radius : 0.25 * font-size,
			it
		)

	}

}

/**
 *
 * Defines how quotes appear in text.
 *
***/
#let quote-show-rule(it) = if it.block {
  block(
    above: 1em,
    below: 1em,
    // stroke: (left: tuni-purple + 2pt),
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
	thesis-type,
	otsikko,
	alaotsikko,
	tiedekunta,
	työn-tyyppi,
	language,
	physically-printed,
	thesis-type-paper,
	thesis-type-margins,
	examiners,
	doc
) = page(
	paper: thesis-type-paper,
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
	margin: if "inside" in thesis-type-margins {
		(
			top: thesis-type-margins.top,
			bottom: thesis-type-margins.bottom,
			left: thesis-type-margins.inside,
			right: thesis-type-margins.outside,
		)
	} else {
		thesis-type-margins
	},
	numbering: none,
	background: place(
		top + left,
		float:true,
		dx: if physically-printed {
			// The printed logo sits exactly at the title page
			// text corner: the recto inside margin, which the
			// explicit margin resolution above places on the
			// left in every mode. The electronic logo hugs
			// the upper-left corner instead.
			if "inside" in thesis-type-margins {
				thesis-type-margins.inside
			} else {
				thesis-type-margins.left
			}
		} else {
			0.5cm
		},
		dy: if physically-printed {
			thesis-type-margins.top
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

		let thesis-type-int = thesis-type-to-int-fn(thesis-type)

		// The thesis examiners print on the title pages of
		// the lower thesis types only: each gets an own
		// line after the faculty line and before the date
		// line, preceded by the localized label, like the
		// LaTeX class cover and the Word template info
		// block. The series covers of the higher thesis
		// types carry no examiners.
		let examiner-label = if language == finnish { "Tarkastaja" } else { "Examiner" }
		let examiner-rows = if thesis-type-int < licentiate-thesis-type-int {
			examiners.map(
				ex => examiner-label + ":" + sym.space.nobreak + (ex.title + " " + ex.firstname + " " + ex.lastname)
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
				text( size: 25pt, fill: tuni-purple, weight: "bold" )[
					#upper(
						if language == finnish {
							otsikko
						} else if language == english {
							maintitle
						}
					)
				]
				+ v(0.7cm, weak: true)
				+ text(size: 20pt, fill: tuni-purple, weight: "regular")[
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
			#if thesis-type-int >= doctoral-thesis-type-int {
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
						työn-tyyppi,
						tiedekunta,
						..examiner-rows,
						localize-month-fi(date.month()) + sym.space.nobreak + str(date.year()),
					)
				} else {
					(
						thesis-type,
						faculty,
						..examiner-rows,
						date.display("[month repr:long] [year]"),
					)
				}
			)
		]
		doc
	}
)

#let issn-page(language) = page(
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
	thesis-programme,
	thesis-type,
	keywords,
	otsikko,
	alaotsikko,
	koulu,
	tiedekunta,
	tutkinto-ohjelma,
	työn-tyyppi,
	avainsanat,
	abstract-content,
	language,
	physically-printed,
	color-separator-lines,
) = {


	let date = datetime.today()

	let thesis-type-int = thesis-type-to-int-fn(thesis-type)

	set text(size:10pt)

	set text(lang: language)

	set par(justify: false)

	let metadata-settings = (
		columns: 1,
		row-gutter: 0.7em,
		align: left,
	)

	let metadata-title-hanging-indent = 1em

	if language == finnish [

		= Tiivistelmä <tiivistelmä>

	] else [

		= Abstract <abstract>

	]
	if language == finnish and thesis-type-int <= licentiate-thesis-type-int [

		#grid(
			.. metadata-settings,
			author,
			par(
				hanging-indent: metadata-title-hanging-indent,
				otsikko + subtitle-suffix(alaotsikko),
			),
			koulu,
			tutkinto-ohjelma,
			työn-tyyppi,
			localize-month-fi(date.month()) + sym.space.nobreak + str(date.year()),
		)

	] else if language != finnish and thesis-type-int <= licentiate-thesis-type-int [

		#grid(
			.. metadata-settings,
			author,
			par(
				hanging-indent: metadata-title-hanging-indent,
				maintitle + subtitle-suffix(subtitle),
			),
			university,
			thesis-programme,
			thesis-type,
			date.display("[month repr:long] [year]"),
		)

	] else {
		none
	}

	show divider: it => {
		set line(
			length: 100%,
			stroke: 2pt + if (
				physically-printed
				and
				not color-separator-lines
			) {
				black
			} else {
				tuni-purple
			},
		)
		block(spacing: 1.5em, it)
	}

	if thesis-type-int <= licentiate-thesis-type-int {

		divider()

	}

	set par(justify: true)

	abstract-content
	parbreak()

	set par(
		justify: false,
		first-line-indent: 0cm,
		spacing: 1.5em,
	)

	if language == finnish [

		*Avainsanat:* #avainsanat.join(", ")

		#if thesis-type-int <= licentiate-thesis-type-int [

			Tämän julkaisun alkuperäisyys on tarkastettu Turnitin Originality -ohjelmalla.

		]

	] else [

		*Keywords:* #keywords.join(", ")

		#if thesis-type-int <= licentiate-thesis-type-int [

			The originality of this thesis has been checked using the Turnitin Originality service.

		]

	]
}

/**
 *
 * Typesets the preface of this thesis.
 *
***/

#let preface(author, language, preface-contents, sijainti, location) = {

	let date = datetime.today()

	let location-date-paragraph-settings = (
			first-line-indent: 0cm,
			spacing: 1.5em,
	)

	if language == finnish {


		heading([Alkusanat])

		preface-contents
		parbreak()

		set par( ..location-date-paragraph-settings )

		sijainti
		" "
		str(date.day())
		"."
		" "
		localize-month-fi-partitive(date.month())
		" "
		str(date.year())
		","
		linebreak()
		author

	} else {


		heading([Preface])

		preface-contents
		parbreak()

		set par( ..location-date-paragraph-settings )

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
#let term-list-show-rule(it) = {

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
#let glossary(language, glossary-dict) = {

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
		.. for key in glossary-dict.keys().sorted() {
			let name = glossary-dict.at(key).name
			let description = glossary-dict.at(key).description
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

#let tau-theorem-block(
	fill: rgb("#ffffff"),
	supplement: [TAUTheoremBlock],
	title: [],
	content
) = figure(
	kind: TAUTHEOREM-KIND,
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
			let doc-part = DOC-PART-STATE.get()
			let in-appendix = doc-part == APPENDIX-PART
			let in-publications = doc-part == PUBLICATIONMATTER-PART
			let in-publication-appendix = PUBLICATION-PART.get() == PUBLICATION-APPENDIX-PART
			let fig-number-within-level = FIG-NUMBER-WITHIN-LEVEL-STATE.get()
			let heading-counter = counter(heading).get()
			let heading-counter-start = if in-publications { 1 } else { 0 }
			let heading-counter-end = calc.min(
				fig-number-within-level + heading-counter-start,
				heading-counter.len(),
			)
			let heading-counter = heading-counter.slice(
				heading-counter-start,
				heading-counter-end,
			)
			let theorem-counter = TAUTHEOREM-COUNTER.get()
			set text(weight: "bold", fill: black)
			supplement
			sym.space.nobreak
			if fig-number-within-level > 0 {
				array2-section-numbering(
					heading-counter,
					in-appendix or in-publication-appendix
				)
				"."
			}
			theorem-counter.map(str).last()
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
#let theorem-block-wrapper(supplement) = (title: "", content) => tau-theorem-block(
	supplement: supplement,
	title: title,
	content
)

// English theorem-like environments.

#let definition = theorem-block-wrapper("Definition")

#let lemma = theorem-block-wrapper("Lemma")

#let theorem = theorem-block-wrapper("Theorem")

#let corollary = theorem-block-wrapper("Corollary")

#let example = theorem-block-wrapper("Example")

// Finnish theorem-like environments.

#let määritelmä = theorem-block-wrapper("Määritelmä")

#let apulause = theorem-block-wrapper("Apulause")

#let lause = theorem-block-wrapper("Lause")

#let seurauslause = theorem-block-wrapper("Seurauslause")

#let esimerkki = theorem-block-wrapper("Esimerkki")

/**
 * Factory for proof environments in a given language.
***/
#let proof-wrapper(label) = body => {
	text(style: "italic", label)
	body + h(1fr) + math.equation(
		alt: "∎",
		$∎$
	)
}

// Proof environments in Finnish and in English.

#let todistus = proof-wrapper("Todistus.")

#let proof = proof-wrapper("Proof.")

/**
 * Used for displaying a short heading in a page header and a long one elsewhere.
***/
#let contextual-heading(..args, short: none, long: none) = {

	assert(
		long != none,
		message: "contextual-heading: The long version of a heading was not given through the long argument.",
	)

	assert(
		short != none,
		message: "contextual-heading: The short version of a heading was not given through the short argument.",
	)

	heading(
		..args,
		long
	)

	let named-args = args.named()

	if (
		not ("level" in named-args)
		or
		("level" in named-args and named-args.level == 1)
		or
		(
			"offset" in named-args
			and
			"depth" in named-args
			and
			named-args.offset + named-args.depth == 1
		)
	) {
		SHORT-CHAPTER-HEADING-STATE.update(short)
	}
}

/**
 *
 * Defines page dimensions in the main matter.
 *
***/
#let page-settings(doc-part, physically-printed, print-two-sided, thesis-type-int, color-separator-lines, it) = {
	set page(
		paper: thesis-type-int-to-page-size-fn(thesis-type-int),
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
		binding: if thesis-type-int >= licentiate-thesis-type-int {
			left
		} else {
			right
		},
		header: context if thesis-type-int < licentiate-thesis-type-int {
			if doc-part == FRONTMATTER-PART {
				PREFACE-PAGE-NUMBER-COUNTER.step()
			} else if doc-part >= MAINMATTER-PART {
				MAINMATTER-PAGE-NUMBER-COUNTER.step()
			} else {
				none
			}
			// This header is only used for thesis types below the licentiate
			// level, so the page number is always displayed in it.
			let (page-num, numbering-str) = if doc-part in (TITLEPAGE-PART, FRONTMATTER-PART) {
				(PREFACE-PAGE-NUMBER-COUNTER, "i")
			} else if doc-part >= MAINMATTER-PART {
				(MAINMATTER-PAGE-NUMBER-COUNTER, "1")
			} else {
				(none, "")
			}
			let headings-before = query(
				heading.where(level: 1).before(here())
			)
			let headings-after = query(
				heading.where(level: 1).after(here()),
			)
			let last-head-before = headings-before.at(-1, default: none)
			let first-head-after = headings-after.at(0, default: none)
			let current-page = here().page()
			// Display current chapter title in left header, if we have
			// moved past the chapter start page. Lower level section
			// titles are not displayed.
			let (inner-text, draw-line) = if last-head-before != none {
				let last-page-before = last-head-before.location().page()
				let location-page-diff = current-page - last-page-before
				let first-short-title-before = SHORT-CHAPTER-HEADING-STATE.at(here())
				if first-head-after != none {
					let first-short-title-after = SHORT-CHAPTER-HEADING-STATE.at(first-head-after.location())
					let firstpageafter = first-head-after.location().page()
					if first-head-after.level == 1 and current-page < firstpageafter {
						// On the last page before next chapter.
						(
							if first-short-title-before != none {
								first-short-title-before
							} else {
								last-head-before.body
							},
							true,
						)
					}
					else if location-page-diff >= 1 and (first-head-after.level > last-head-before.level) {
						// Pages following chapter title but not last page before next chapter.
						(
							if first-short-title-before != none {
								first-short-title-after
							} else {
								last-head-before.body
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
						if first-short-title-before != none {
							first-short-title-before
						} else {
							last-head-before.body
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
			let doc-page-num = here().page()
			// A header row of two cells: chapter title and page number.
			let header-grid(columns, left-cell, right-cell) = grid(
				columns: columns,
				align: (left+top, right+top),
				gutter: 0.2em,
				left-cell,
				right-cell,
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
			if physically-printed and print-two-sided {
				if calc.rem(doc-page-num, 2) == 0 {
					header-grid(
						(9fr, 1fr),
						upper(inner-text),
						page-num.display(numbering-str),
					)
				} else {
					header-grid(
						(1fr, 9fr),
						page-num.display(numbering-str),
						upper(inner-text),
					)
				}
			} else {
				header-grid(
					(9fr, 1fr),
					upper(inner-text),
					page-num.display(numbering-str),
				)
			}
			if draw-line {
				line(
					length: 100%,
					stroke: 2pt + if physically-printed and not color-separator-lines { black } else { tuni-purple },
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
			if thesis-type-int >= licentiate-thesis-type-int {
				if doc-part == FRONTMATTER-PART {
					PREFACE-PAGE-NUMBER-COUNTER.step()
				} else if doc-part >= MAINMATTER-PART {
					MAINMATTER-PAGE-NUMBER-COUNTER.step()
				} else {
					none
				}
				set align(center + horizon)
				if doc-part == FRONTMATTER-PART {
					counter(page).display("i")
				} else if doc-part >= MAINMATTER-PART {
					counter(page).display("1")
				} else {
					none
				}
			}
		},
		margin: thesis-type-int-to-margins-fn(
			physically-printed: physically-printed,
			print-two-sided: print-two-sided,
			thesis-type-int,
		)
	)
	DOC-PART-STATE.update(doc-part)
	it
}

/**
 * A generic list-of-contents outline for figures, tables and listings.
***/
#let content-outline(target, fi-title, en-title, language) = {
	outline(
		title: if language == finnish { fi-title } else { en-title },
		target: target,
		indent: auto,
	)
}

/**
 *
 * A list of images.
 *
***/
#let content-figures(language) = content-outline(
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
#let content-tables(language) = content-outline(
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
#let content-listings(language) = content-outline(
	figure.where(kind: raw),
	[Listausluettelo],
	[List of listings],
	language,
)

/**
 * Filters a publication dictionary down to the publications that should be
 * included in the thesis as original publications.
***/
#let thesis-publications(publication-dict) = publication-dict.pairs().filter(((cite-key, publication)) =>
	"tauthesis-publication" in publication and publication.tauthesis-publication
)

/**
 * The "Publication I" cell of the original publications list, optionally
 * linked to the title page of the attached publication.
***/
#let publication-number-cell(attach-publications, publication-str, n) = {
	set text(fill: black, weight: "bold")
	show link: set text(fill: black, weight: "bold")
	if attach-publications {
		let ref-str = "tauthesis-publication-anchor-" + str(n)
		link(
			label(ref-str),
			publication-str + sym.space.nobreak + numbering("I", n)
		)
	} else {
		publication-str + sym.space.nobreak + numbering("I", n)
	}
}

/**
 *
 * A list of Doctoral thesis publications.
 *
***/

#let list-of-publications(attach-publications, language, publication-dict) = {

	if publication-dict == none or publication-dict.len() == 0 {
		return none
	}

	if language == finnish {
		heading([Alkuperäiset julkaisut])
	} else {
		heading([Original Publications])
	}

	let publication-str = if language == finnish {"Julkaisu"} else {"Publication"}

	set par(justify: false)

	let included-publications = thesis-publications(publication-dict)

	let publication-counter = 0

	grid(
		columns: (18%,2%,80%),
		align: (top+left,top+center,top+left),
		row-gutter: 2em,
		column-gutter: 0.9em,
		.. for (cite-key, publication) in included-publications {

			publication-counter += 1

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
			let parent-title = if parent != none {
				parent.at("title", default: "")
			} else {
				""
			}
			let parent-location = if parent != none {
				parent.at("location", default: "")
			} else {
				""
			}
			let parent-publisher = if parent != none {
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
				publication-number-cell(attach-publications, publication-str, publication-counter),
				[~],
				{
					authors-to-string(cite-key, author)
					", "
					text(
						style: "italic",
						" " + title
					)
					if lower(publication.type) == "article" {
						", "
						parent-title
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
						parent-title
						", Ed: "
						if type(editor) == array {
							editor.join(", ")
						} else {
							editor
						}
						", "
						parent-location
						": "
						parent-publisher
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

	publication-counter = 0

	grid(
		columns: (18%,2%,80%),
		align: (top+left,top+center,top+left),
		row-gutter: 2em,
		column-gutter: 0.9em,
		.. for (cite-key, publication) in included-publications {

			publication-counter += 1

			(
				publication-number-cell(attach-publications, publication-str, publication-counter),
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
#let bilingual-section(fi-title, fi-label, en-title, en-label, contents, language) = {
	if language == finnish [
		= #fi-title
		#label(fi-label)
		#contents

	] else [
		= #en-title
		#label(en-label)
		#contents

	]
}

#let acknowledgements(acknowledgement-contents, language) = bilingual-section(
	[Tunnustukset],
	"tunnustukset",
	[Acknowledgements],
	"acknowledgements",
	acknowledgement-contents,
	language,
)

#let thanks(thanks-contents, language) = bilingual-section(
	[Kiitokset],
	"kiitokset",
	[Thanks],
	"thanks",
	thanks-contents,
	language,
)

/**
 *
 * Defines the structure and look of Tampere University theses.
 *
 * The template reads the user frontmatter content files itself
 * through the path-resolver argument: a function that maps user
 * file path strings into path values anchored at the file calling
 * the template. Typst resolves a path given as a raw string in
 * relation to the file where the string is written, so this module
 * cannot construct user file paths by itself: a path built here
 * would point into the module directory instead of the user
 * project, and edits made by the user there would not land in the
 * compiled document. The calling main file therefore hands the
 * template a path constructor defined next to its own files.
 *
***/

#let template(
	alaotsikko: [Alaotsikko],
	attach-publications: true,
	author: "Firstname Lastname",
	avainsanat: ("avainsana1", "avainsana2"),
	citation-style: "ieee",
	code-font : "Fira Mono",
	color-separator-lines: true,
	compilation-thesis: true,
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
	eq-number-within-level : 1,
	faculty: "Faculty",
	fig-number-within-level : 1,
	include-finnish-abstract: true,
	include-glossary: true,
	include-list-of-figures: true,
	include-list-of-tables: true,
	include-list-of-listings: true,
	include-thanks: true,
	keywords: ("keyword1", "keyword2"),
	koulu: [Tampereen Yliopisto],
	language: "fi",
	location: "Tampere",
	math-font : "STIX Two Math",
	otsikko: [Opinnäytetyöpohja],
	path-resolver: none,
	physically-printed: false,
	print-two-sided: false,
	publication-dict: (:),
	region: "FI",
	show-paragraph-line-numbers: false,
	sijainti: [Tampereella],
	subtitle: [Subtitle],
	text-font : "Roboto",
	thesis-programme: "Degree programme",
	thesis-type: master-of-technology-thesis-type,
	tiedekunta: [Tiedekunta],
	maintitle: "Thesis template",
	tutkinto-ohjelma: "Tutkinto-ohjelma",
	university: [Tampere University],
	used-ai : true,
	doc
) = {

	// ----------------------------------------------------------------
	// Command-line overrides (see the sys.inputs section near the
	// thesis types). Applied before any validation so that an
	// overridden value passes through the same checks as one read
	// from meta.typ. Keys that are not given on the command line
	// leave the meta.typ value in effect.
	// ----------------------------------------------------------------

	let thesis-type = thesis-type-sys-input(thesis-type)
	let alaotsikko = sys-input("alaotsikko", alaotsikko)
	let attach-publications = sys-input("attach-publications", attach-publications)
	let author = sys-input("author", author)
	let avainsanat = sys-input("avainsanat", avainsanat)
	let color-separator-lines = sys-input("color-separator-lines", color-separator-lines)
	let compilation-thesis = sys-input("compilation-thesis", compilation-thesis)
	let description = sys-input("description", description)
	let eq-number-within-level = sys-input("eq-number-within-level", eq-number-within-level)
	let faculty = sys-input("faculty", faculty)
	let fig-number-within-level = sys-input("fig-number-within-level", fig-number-within-level)
	let include-finnish-abstract = sys-input("include-finnish-abstract", include-finnish-abstract)
	let include-glossary = sys-input("include-glossary", include-glossary)
	let include-list-of-figures = sys-input("include-list-of-figures", include-list-of-figures)
	let include-list-of-tables = sys-input("include-list-of-tables", include-list-of-tables)
	let include-list-of-listings = sys-input("include-list-of-listings", include-list-of-listings)
	let include-thanks = sys-input("include-thanks", include-thanks)
	let keywords = sys-input("keywords", keywords)
	let koulu = sys-input("koulu", koulu)
	let language = sys-input("language", language)
	let location = sys-input("location", location)
	let math-font = sys-input("math-font", math-font)
	let otsikko = sys-input("otsikko", otsikko)
	let physically-printed = sys-input("physically-printed", physically-printed)
	let print-two-sided = sys-input("print-two-sided", print-two-sided)
	let region = sys-input("region", region)
	let show-paragraph-line-numbers = sys-input("show-paragraph-line-numbers", show-paragraph-line-numbers)
	let sijainti = sys-input("sijainti", sijainti)
	let subtitle = sys-input("subtitle", subtitle)
	let text-font = sys-input("text-font", text-font)
	let thesis-programme = sys-input("thesis-programme", thesis-programme)
	let tiedekunta = sys-input("tiedekunta", tiedekunta)
	let maintitle = sys-input("maintitle", maintitle)
	let tutkinto-ohjelma = sys-input("tutkinto-ohjelma", tutkinto-ohjelma)
	let university = sys-input("university", university)
	let used-ai = sys-input("used-ai", used-ai)
	let code-font = sys-input("code-font", code-font)

	// ----------------------------------------------------------------
	// Frontmatter content loading. Typst resolves a path given as a
	// raw string in relation to the file where the string is
	// written, so the user frontmatter content files are loaded
	// through the path resolver, which anchors their paths to the
	// calling user file: a path constructed inside this module would
	// point into the module directory instead of the user project,
	// and edits made by the user there would not land in the
	// compiled document. The glossary words are a named binding, so
	// a dynamic import is used for them.
	// ----------------------------------------------------------------

	assert(
		type(path-resolver) == function,
		message: "template: the path-resolver argument needs to be a function that maps user file path strings to path values anchored at the calling user file.",
	)

	let abstract-contents = include path-resolver("frontmatter/abstract.typ")
	let acknowledgement-contents = include path-resolver("frontmatter/acknowledgements.typ")
	let ai-disclaimer-contents = include path-resolver("frontmatter/use-of-ai.typ")
	import path-resolver("frontmatter/glossary.typ"): glossary-words
	let glossary-dict = glossary-words
	let preface-contents = include path-resolver("frontmatter/preface.typ")
	let tekoälyn-käyttö-teksti = include path-resolver("frontmatter/tekoalyn-kaytto.typ")
	let tiivistelmän-sisältö = include path-resolver("frontmatter/tiivistelma.typ")
	let thanks-contents = include path-resolver("frontmatter/thanks.typ")

	if not language in (finnish, english) {
		panic( template-name + ": unrecognized primary language '" + language + ". Only 'fi' and 'en' are accepted." )
	}

	validate-number-within-level("fig-number-within-level", fig-number-within-level)

	validate-number-within-level("eq-number-within-level", eq-number-within-level)

	thesis-type-validation-fn(thesis-type)

	let thesis-type-int = thesis-type-to-int-fn(thesis-type)

	// The Finnish thesis type is no longer a template input:
	// it is derived from the English thesis type.

	let työn-tyyppi = thesis-type-to-työn-tyyppi-fn(thesis-type)

	set document(
		author: author,
		title: if language == finnish {
			otsikko + subtitle-suffix(alaotsikko)
		} else {
			maintitle + subtitle-suffix(subtitle)
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
		#if subtitle-text(alaotsikko) != "" [
			#metadata(subtitle-text(alaotsikko))
			#label("alaotsikko")
		]
		#metadata(author) #label("author")
		#metadata(avainsanat.join(", ")) #label("avainsanat")
		#metadata(citation-style) #label("citationStyle")
		#metadata(description) #label("description")
		#metadata(str(eq-number-within-level)) #label("eqNumberWithinLevel")
		#metadata(faculty) #label("faculty")
		#metadata(str(fig-number-within-level)) #label("figNumberWithinLevel")
		#metadata(keywords.join(", ")) #label("keywords")
		#metadata(koulu) #label("koulu")
		#metadata(language) #label("language")
		#metadata(location) #label("location")
		#metadata(otsikko) #label("otsikko")
		#metadata(str(int(print-two-sided))) #label("printTwoSided")
		#metadata(sijainti) #label("sijainti")
		#if subtitle-text(subtitle) != "" [
			#metadata(subtitle-text(subtitle))
			#label("subtitle")
		]
		#metadata(thesis-type) #label("thesisType")
		#metadata(tiedekunta) #label("tiedekunta")
		#metadata(maintitle) #label("maintitle")
		#metadata(työn-tyyppi) #label("työnTyyppi")
		#metadata(university) #label("university")
		#metadata(str(int(used-ai))) #label("usedAI")
	]

	show par: set math.frac(style: "horizontal")

	// Color different kinds of links.

	show link: set text( fill: rgb("#0038FF") ) if not physically-printed

	show cite: set text( fill: black )

	// Prettify emphasized text.

	show emph: set text(fill:black)

	// Initialize helper counters in array format.

	reset-figure-counters()

	FIG-NUMBER-WITHIN-LEVEL-STATE.update(fig-number-within-level)

	// Update helper counters when associated figures are shown.

	show figure: it => fig-show-rule(language,fig-number-within-level,it)

	show heading: heading-show-rule.with(
		language,
		math-font,
		code-font,
		fig-number-within-level,
		eq-number-within-level,
		thesis-type-int,
	)

	show raw: it => raw-show-rule(
		code-font,
		text.size,
		it
	)

	let text-font-size = if thesis-type-int > licentiate-thesis-type-int { 10pt } else { 11pt }

	set text(
		font: text-font,
		lang: language,
		region: region,
		size: text-font-size,
	)

	show math.equation: set text(
		font: math-font,
		size: text-font-size,
	)

	show: doc => page-settings(TITLEPAGE-PART, physically-printed, print-two-sided, thesis-type-int, color-separator-lines, doc)

	show: doc => titlepage(
		author,
		maintitle,
		subtitle,
		faculty,
		thesis-type,
		otsikko,
		alaotsikko,
		tiedekunta,
		työn-tyyppi,
		language,
		physically-printed,
		thesis-type-int-to-page-size-fn(thesis-type-int),
		thesis-type-int-to-margins-fn(
			physically-printed: physically-printed,
			print-two-sided: print-two-sided,
			thesis-type-int,
		),
		examiners,
		doc
	)

	if thesis-type-int >= doctoral-thesis-type-int {
		issn-page(language)
	}

	PREFACE-PAGE-NUMBER-COUNTER.update(1)

	show: doc => page-settings(FRONTMATTER-PART, physically-printed, print-two-sided, thesis-type-int, color-separator-lines, doc)

	set heading(numbering: none, outlined: false, bookmarked: true)

	set par(
		leading: 0.9em,
		first-line-indent: if thesis-type-int > licentiate-thesis-type-int { 0.5cm } else { 0cm },
		justify: true,
		spacing: if thesis-type-int > licentiate-thesis-type-int { 0.9em } else { 1.5em },
	)

	// The arguments shared by all calls of the abstract function, in its
	// positional argument order.

	let abstract-common = (
		author,
		maintitle,
		subtitle,
		university,
		faculty,
		thesis-programme,
		thesis-type,
		keywords,
		otsikko,
		alaotsikko,
		koulu,
		tiedekunta,
		tutkinto-ohjelma,
		työn-tyyppi,
		avainsanat,
	)

	let abstracts = if language == finnish {
		abstract(..abstract-common, tiivistelmän-sisältö, finnish, physically-printed, color-separator-lines)
		abstract(..abstract-common, abstract-contents, english, physically-printed, color-separator-lines)
	} else if language == english {
		abstract(..abstract-common, abstract-contents, english, physically-printed, color-separator-lines)
		if include-finnish-abstract {
			abstract(..abstract-common, tiivistelmän-sisältö, finnish, physically-printed, color-separator-lines)
		}
	} else {
		panic( template-name + ": received an unknown language " + language + ". Must be one of {\"fi\", \"en\"}" )
	}

	// Adjust how ToC entries appear in their respective listings.

	show outline.entry: it => outline-entry-show-rule(
		language,
		fig-number-within-level,
		thesis-type-int,
		math-font,
		code-font,
		it
	)

	// Apply new appearance to block quotes.

	show quote: quote-show-rule

	show terms: term-list-show-rule

	// Cross-reference layout, defined once for use in both the front matter
	// and the main matter. Two separate show-rule applications are still
	// needed, since show rules only apply to content that follows them:
	// refs in the front matter must be laid out differently from those in
	// the main matter (see ref-show-rule).

	let ref-show-fn = it => ref-show-rule(
		it,
		language,
		fig-number-within-level,
		eq-number-within-level
	)

	// Hide any citations before main matter, so that citation counter is not
	// incremented before main matter starts.

	{
		set footnote.entry( separator: none)
		show footnote.entry: hide
		show ref: ref-show-fn
		show footnote: none
		if thesis-type-int > licentiate-thesis-type-int {
			acknowledgements(acknowledgement-contents, language)
			preface(author, language, preface-contents, sijainti, location)
			if include-thanks {
				thanks(thanks-contents, language)
			}
			abstracts
		} else {
			abstracts
			preface(author, language, preface-contents, sijainti, location)
		}
		// The dissertation series specification requires
		// the table of contents to begin on an odd page, a
		// recto of the continuous pagination, so a blank
		// verso is inserted automatically when the
		// preceding front matter would end on a recto. The
		// licentiate shares the doctoral structure, without
		// the series publishing artifacts, so the same
		// rule applies to it.
		if thesis-type-int >= licentiate-thesis-type-int {
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
		if thesis-type-int >= masters-thesis-type-int {
			if include-list-of-figures {
				content-figures(language)
			}
			if include-list-of-tables {
				content-tables(language)
			}
			if include-list-of-listings {
				content-listings(language)
			}
		}
		if include-glossary {
			glossary(language, glossary-dict)
		}
		if thesis-type-int >= licentiate-thesis-type-int and compilation-thesis {
			list-of-publications(attach-publications,language,publication-dict)
		}
	}

	ai-disclaimer-page(used-ai, language, tekoälyn-käyttö-teksti, ai-disclaimer-contents)

	if thesis-type-int < licentiate-thesis-type-int {
		MAINMATTER-PAGE-NUMBER-COUNTER.update( 1 )
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
	if thesis-type-int >= licentiate-thesis-type-int {
		pagebreak(
			weak: true,
			to: "odd"
		)
	}

	show: doc => page-settings(MAINMATTER-PART, physically-printed, print-two-sided, thesis-type-int, color-separator-lines, doc)

	set math.vec(delim : "[")

	set math.mat(delim : "[")

	set math.equation(
		numbering: equation-numbering-fn(eq-number-within-level, false, 0),
		supplement: none
	)

	set par.line(
		numbering: it => if show-paragraph-line-numbers {
			set text(fill: gray)
			it
		} else {
			none
		},
		numbering-scope: "page",
	)

	set heading( numbering: "1.1" + heading-sep, outlined: true, supplement: none )

	// Adjust references, so they display figures and such using
	// the auxiliary counters.

	show ref: ref-show-fn

	doc

}

/** bib-settings( doc )
 *
 * Lets show rules know that we are currently displaying the bibliography.
 *
***/

#let bib-settings(language, doc)  = {

	let language = sys-input("language", language)

	DOC-PART-STATE.update(BIBLIOGRAPHY-PART)
	// Prevent page breaks in the middle of bibliography items.
	show bibliography: set grid.cell(breakable: false)
	set bibliography(title: if language == finnish {"Lähteet"} else {"References"})
	doc
}


/** appendix( fig-number-within-level : 1, eq-number-within-level : 1, doc )
 *
 * Defines the appearance of the appendix, supposing that the
 * above tauthesis has already defined the general appearance of
 * the document.
 *
***/

#let appendix(
	fig-number-within-level: 1,
	eq-number-within-level: 1,
	math-font: "STIX Two Math",
	code-font: "Fira Mono",
	language,
	thesis-type-integer,
	doc
) = {

	// Command-line overrides, so that the appendix honors the same
	// values as the template (see the sys.inputs section).

	let fig-number-within-level = sys-input("fig-number-within-level", fig-number-within-level)
	let eq-number-within-level = sys-input("eq-number-within-level", eq-number-within-level)
	let math-font = sys-input("math-font", math-font)
	let code-font = sys-input("code-font", code-font)
	let language = sys-input("language", language)

	validate-number-within-level("fig-number-within-level", fig-number-within-level)

	validate-number-within-level("eq-number-within-level", eq-number-within-level)

	// Reset counters at the start of appendix.

	if fig-number-within-level > 0 {
		reset-figure-counters()
	}

	counter(heading).update( 0 )

	if eq-number-within-level > 0 {

		counter(math.equation).update( 0 )

	}

	FIG-NUMBER-WITHIN-LEVEL-STATE.update(fig-number-within-level)

	set heading(numbering: "A.1", supplement: none)

	show heading : heading-show-rule.with(
		language,
		math-font,
		code-font,
		fig-number-within-level,
		eq-number-within-level,
		thesis-type-integer,
	)

	set math.equation(
		numbering: equation-numbering-fn(eq-number-within-level, true, 0),
		supplement: none
	)

	show ref : it => ref-show-rule( it, language, fig-number-within-level, eq-number-within-level)

	DOC-PART-STATE.update(APPENDIX-PART)

	doc

}

/**
 * Page settings and such for publication matter.
***/
#let publication-matter(
	fig-number-within-level:1,
	eq-number-within-level:1,
	code-font: "Fira mono",
	doc
) = {

	// Command-line overrides, so that the publication matter honors
	// the same values as the template (see the sys.inputs section).

	let fig-number-within-level = sys-input("fig-number-within-level", fig-number-within-level)
	let eq-number-within-level = sys-input("eq-number-within-level", eq-number-within-level)
	let code-font = sys-input("code-font", code-font)

	DOC-PART-STATE.update(PUBLICATIONMATTER-PART)
	set page(margin: 0cm, header: none, footer: none)
	set heading(
		outlined: false,
		numbering: "I.1.1",
	)
	counter(heading).update(0)
	counter(math.equation).update(0)
	let heading-spacing = 1.5em
	show heading: it => if it.level == 1 {
		it.body + linebreak() + counter(heading).display()
	} else {
		show raw: it => inline-code-show-rule(code-font, text.size, it)
		let heading-ctr = counter(heading).get().slice(1)
		if it.level <= eq-number-within-level + 1 {
			counter(math.equation).update(0)
		}
		if it.level <= fig-number-within-level + 1 {
			reset-figure-counters()
		}
		block(
			spacing: heading-spacing,
			heading-ctr.map(str).join(".") + sym.space.nobreak + it.body,
		)
	}
	set math.equation(
		// Publication level 2 headings act as publication titles, so the
		// first heading counter component is dropped from the section prefix.
		numbering: equation-numbering-fn(
			eq-number-within-level,
			false,
			if eq-number-within-level > 0 { 1 } else { 0 },
		),
		supplement: none
	)
	show bibliography: set heading(level:2)
	show bibliography: it => context {
		let last-publication-before = query(
			selector(heading.where(level:1)).before(here())
		).last(default: none)
		let last-publication-location = if last-publication-before == none {
			here()
		} else {
			last-publication-before.location()
		}
		let first-publication-after = query(
			selector(heading.where(level:1)).after(here())
		).last(default: none)
		let first-publication-location = if first-publication-after == none {
			here()
		} else {
			first-publication-after.location()
		}
		set bibliography(
			target: selector(cite)
			.after(last-publication-location)
			.and(
				selector(cite)
				.before(first-publication-location)
			)
		)

		show heading: it => block(
			spacing: heading-spacing,
			sticky: true,
			it.body,
		)

		it
	}
	[
		#metadata("publicationMatter")
		<publication-matter>
	]
	doc
}

// Adjust counters for each publication main matter.
// Remember that publication level 2 headings are shown as level 1 headings,
// so many comparisons have an addend of 1.

#let publication-main-matter(
	doc,
) = {
	PUBLICATION-PART.update(PUBLICATION-MAINMATTER-PART)
	counter(math.equation).update(0)
	reset-figure-counters()
	doc
}

#let publication-end(doc) = {
	PUBLICATION-PART.update(UNDEFINED-PUBLICATION-PART)
	doc
}

// Adjust counters for each publication main matter.
// Remember that publication level 2 headings are shown as level 1 headings,
// so many comparisons have an addend of 1.

#let publication-appendix(
	eq-number-within-level: 0,
	fig-number-within-level:0,
	code-font: "Fira Mono",
	doc
) = {
	PUBLICATION-PART.update(PUBLICATION-APPENDIX-PART)
	set heading(numbering: "I.A.1")
	counter(heading).update(
		(..ctr) => {
			let counter-array = ctr.pos()
			// Grow the counter array if no level 2 headings have been
			// seen yet, since appendix headings start at level 2.
			if counter-array.len() < 2 { counter-array += (0,) }
			counter-array.at(1) = 0
			counter-array
		}
	)
	show heading: it => if it.level == 1 {
		panic("Level 1 headings not allowed within publications. Increase level of every heading by 1.")
	} else {
		show raw: it => inline-code-show-rule(code-font, text.size, it)
		if it.level <= eq-number-within-level + 1 {
			counter(math.equation).update(0)
		}
		if it.level <= fig-number-within-level + 1 {
			reset-figure-counters()
		}
		let heading-spacing = 1.5em
		block(
			spacing: heading-spacing,
			sticky: true,
			{
				array2-section-numbering(
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
		numbering: equation-numbering-fn(
			eq-number-within-level,
			true,
			if eq-number-within-level > 0 { 1 } else { 0 },
		),
		supplement: none
	)
	doc
}

/**
 * Displays the info page for a publication and generates
 * a label that other parts of the document can link to.
***/
#let display-publication-title-page(
	cite-key,
	publication,
	language,
	thesis-type-integer,
	physically-printed,
	print-two-sided,
	publication-number,
) = {

	// Command-line overrides, so that the publication pages honor
	// the same values as the template (see the sys.inputs section).

	let language = sys-input("language", language)
	let physically-printed = sys-input("physically-printed", physically-printed)
	let print-two-sided = sys-input("print-two-sided", print-two-sided)

	page(
		margin: thesis-type-int-to-margins-fn(
			physically-printed: physically-printed,
			print-two-sided: print-two-sided,
			thesis-type-integer
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

			let anchor-label-text = "tauthesis-publication-anchor-" + str(publication-number)

			[
				= #if language == finnish [
					JULKAISU
				] else [
					PUBLICATION
				]

				#label(anchor-label-text)
			]

			block({

				set text(size: 15pt)


				publication.title
				parbreak()

				set text(size: 12pt, weight: "regular")

				authors-to-string(cite-key, publication.author)
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

#let attach-publications(
	thesis-type,
	publication-dict,
	language,
	physically-printed: false,
	print-two-sided: false,
) = {
	if publication-dict == none or publication-dict.len() == 0 {
		return
	}

	let thesis-type-int = thesis-type-to-int-fn(thesis-type)

	if thesis-type-int >= licentiate-thesis-type-int {

		let publication-number = 0

		for (cite-key, publication) in thesis-publications(publication-dict) {
			publication-number += 1
			display-publication-title-page(
				cite-key,
				publication,
				language,
				thesis-type-int,
				physically-printed,
				print-two-sided,
				publication-number,
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
#let publication-path-parts(cite-key, publication) = {
	let file-path-str = publication.path
	// Validate file path.
	let file-path-parts = file-path-str.split("/")
	let directory-path = file-path-parts.slice(0,-1).join("/")
	let file-name = file-path-parts.last()
	let file-name-parts = file-name.split(".")
	if file-name-parts.len() < 2 {
		panic("Given publication " + cite-key + " file name " + file-name + " was not valid. It needs to be of the form stem.type to differentiate between file types.")
	}
	(
		file-path: file-path-str,
		directory: directory-path,
		stem: file-name-parts.slice(0,-1).join("."),
		suffix: file-name-parts.last(),
	)
}

/**
 * Validates a given file path and then returns it and its suffix.
***/
#let publication-file-path(cite-key, publication) = {
	let parts = publication-path-parts(cite-key, publication)
	(parts.at("file-path"), parts.at("suffix"))
}

/**
 * Alternative text of an image containing a single page of a publication.
***/
#let publication-page-alt-text(cite-key, publication, pagei) = (
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
		panic("Publication " + cite-key + " author list was not a string or an array.")
	}
	+ ". DOI: " + publication.serial-number.doi + "."
)

#let load-publication-pages(
	cite-key,
	publication,
	file-path,
	file-name-suffix,
	thesis-type-int,
	// The language argument is currently unused, but it is kept in the
	// signature so that existing callers do not break.
	language,
	physically-printed,
	print-two-sided,
	// Resolves a user file path string into a path value anchored at
	// the user main file; see display-publication-pages for why the
	// module cannot construct user paths itself.
	path-resolver,
) = {

	// Command-line overrides, so that the publication pages honor
	// the same values as the template (see the sys.inputs section).

	let language = sys-input("language", language)
	let physically-printed = sys-input("physically-printed", physically-printed)
	let print-two-sided = sys-input("print-two-sided", print-two-sided)

	let footer-descent = 60%
	assert(
		type(file-path) == path,
		message: "load-publication-pages: the file-path argument needs to be of type path."
	)
	assert(
		"n-of-pages" in publication,
		message: "The publication " + cite-key + " attached to a thesis needs to contain the field n-of-pages in the bibliography file.",
	)
	assert(
		type(publication.n-of-pages) == int and publication.n-of-pages > 0,
		message: "The field n-of-pages in the entry " + cite-key + " of the biubliography file was not a positive integer. ",
	)
	if file-name-suffix == "typ" {
		PUBLICATION-PAGE-COUNTER.update(1)
		set page(
			paper: thesis-type-int-to-page-size-fn(thesis-type-int),
			margin: thesis-type-int-to-margins-fn(
				physically-printed: physically-printed,
				print-two-sided: print-two-sided,
				thesis-type-int,
			),
			header: none,
			footer: context {
				PUBLICATION-PAGE-COUNTER.step()
				set align(center)
				PUBLICATION-PAGE-COUNTER.display()
			},
			footer-descent: footer-descent,
		)
		include file-path
		show: publication-end
	} else if file-name-suffix == "pdf" {
		let pdf-bytes = read(file-path, encoding: none)
		for pagei in range(publication.n-of-pages) {
			image(
				pdf-bytes,
				width: 100%,
				page: pagei + 1,
				alt: publication-page-alt-text(cite-key, publication, pagei)
			)
		}
	} else if file-name-suffix in ("svg","png","jpg") {
		// These file formats are split into multiple files,
		// so we assume that the file names are of the form
		// "stem-pagenumber.type".
		// We automatically add the required page numbers.
		let path-parts = publication-path-parts(cite-key, publication)
		for pagei in range(publication.n-of-pages) {
			let file-path-with-page-num = path-parts.directory + "/" + path-parts.stem + "-" + str(pagei+1) + "." + file-name-suffix
			image(
				path-resolver(file-path-with-page-num),
				width: 100%,
				page: pagei + 1,
				alt: publication-page-alt-text(cite-key, publication, pagei)
			)
		}
	} else {
		panic("Unsupported file type ." + file-name-suffix + " for attaching publications.")
	}
}

/**
 *
 * Displays the attached publication pages: for each publication
 * flagged with tauthesis-publication in the publication dictionary,
 * a publication title page followed by the publication file
 * itself. The function applies the same command-line overrides as
 * the rest of the template, so the attached pages and the
 * frontmatter list of publications stay in agreement, and the
 * publication number passed to each title page is the ordinal of
 * the displayed publication by construction.
 *
 * The path-resolver argument anchors the publication file paths to
 * the calling user file. Typst resolves a path given as a raw
 * string in relation to the file where the string is written, so
 * a path constructed inside this module would point into the
 * module directory instead of the user project, and user edits
 * would not land in the compiled document. The caller therefore
 * passes a path constructor defined next to its own files.
 *
***/

#let display-publication-pages(
	publication-dict,
	path-resolver,
	language,
	thesis-type,
	physically-printed,
	print-two-sided,
	compilation-thesis,
	attach-publications,
) = {
	let thesis-type-int = thesis-type-to-int-fn(thesis-type)
	if not include-publication-pages(thesis-type-int, compilation-thesis, attach-publications) {
		// Nothing to attach in this configuration.
		none
	} else {
		let publication-number = 0
		for (cite-key, publication) in publication-dict {
			if not "tauthesis-publication" in publication or not publication.tauthesis-publication { continue }
			publication-number += 1
			display-publication-title-page(
				cite-key,
				publication,
				language,
				thesis-type-int,
				physically-printed,
				print-two-sided,
				publication-number,
			)
			if "path" in publication and publication.path != none {
				let (file-path-str, file-name-suffix) = publication-file-path(cite-key, publication)
				let file-path = path-resolver(file-path-str)
				load-publication-pages(
					cite-key,
					publication,
					file-path,
					file-name-suffix,
					thesis-type-int,
					language,
					physically-printed,
					print-two-sided,
					path-resolver,
				)
			}
		}
	}
}