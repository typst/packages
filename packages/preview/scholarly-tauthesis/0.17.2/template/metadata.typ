//
// metadata.typ
//
// Write any metadata related to your document here, by
// filling in suitable values for the given variables. This
// file is automatically loaded by the main file.
//

#import "@preview/scholarly-tauthesis:0.17.2" as tauthesis

// Common metadata.

#let author = "Firstname Lastname"

#let examiners = (
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
)

/**
 * One of "fi" or "en".
***/

#let language = "fi"

/**
 * "FI" if your language was set as "fi", or some accepted
 * region such as "US" or "GB", if your language was "en".
***/
#let region = "FI"

/**
 * This allows you to choose a citation style. See
 * <https://typst.app/docs/reference/model/bibliography/#parameters-style>
 * for possible options.
***/

#let citationStyle = "ieee"

/**
 * Choose which bibliography file you wish to use.
 * Valid values are "yaml" for Hayagriva and "bib" for BibLaTeX.
***/

#let bibFileSuffix = "yaml"

/**
 * Set this to false if you are an international student and do
 * not need a Finnish abstract.
***/

#let includeFinnishAbstract = true

/**
 * Set this to true before compiling your document, if you intend
 * to print a physical copy of it.
***/

#let physicallyPrinted = false

/**
 * This flag makes the document pages two-sided, meaning the inner
 * margin will vary on even and odd pages. Only set this to true if
 *
 * 1. you set the flag physicallyPrinted to true and
 * 2. your main matter is over 80 pages long.
 *
 * Setting this to true will make the document very annoying to
 * read on electronic screens, if physicallyPrinted is also true.
***/

#let printTwoSided = false

/**
 * Set this to true, if you utilized artificial intelligence, such as large
 * language models in writing your thesis.
***/

#let usedAI = true

/**
 * Set this to false if you are writing a monograph
 * dissertation. Keep the value as true if you are writing
 * a compilation thesis. If you are not writing a PhD
 * dissertation or a licentiate thesis with publications,
 * the value does not matter.
***/

#let compilationThesis = true

/**
 * Setting this to false will disable the loading of PhD
 * dissertation publications at the end of the document.
 * The list of publications will still be printed in the
 * document frontmatter.
 *
 * This is mainly useful, if you want to maintain the
 * accessibility of your published dissertation PDF as
 * required by Finnish law, but would not be able to do so
 * as the PDF files loaded from publisher websites do not
 * contain accessibility tags.
***/

#let attachPublications = true

// A description that ends up in document metadata.

#let description = "A short description of this document."

// Choose your thesis type. The Finnish and English thesis
// types työnTyyppi and thesisType need to match. The
// correspondence relation is as follows:
//
// - bacherlorsThesisType and kandidaatinTyönTyyppi
// - mastersThesisType and diplomiTyönTyyppi
// - mastersThesisType and maisterinTyönTyyppi
// - licentiateThesisType and lisensiaatinTyönTyyppi
// - doctoralThesisType and tohtorinTyönTyyppi
//

#let thesisType = tauthesis.doctoralThesisType

#let työnTyyppi = tauthesis.tohtorinTyönTyyppi

//// Finnish metadata.

#let alaotsikko = "Kuvaava alaotsikko" // or none without the ""
#let avainsanat = ("avainsana1", "avainsana2", "...")
#let koulu  = "Tampereen Yliopisto"
#let otsikko = "Työn otsikko"
#let sijainti = "Tampereella"
#let tiedekunta = "Tiedekunta"
#let tutkintoOhjelma = "Tutkinto-ohjelma"

//// English metadata.

#let faculty = "Faculty"
#let keywords = ("keyword1", "keyword2", "...")
#let location = "Tampere"
#let subtitle = "Descriptive Subtitle" // or none without the ""
#let maintitle = "Thesis Title"
#let thesisProgramme = "Thesis programme"
#let university = "Tampere University"

// Set the maximum heading levels under which figures and equations are numbered.

#let figNumberWithinLevel = 1

#let eqNumberWithinLevel = 1

// Determines whether the link to the table of contents is
// displayed or not. The link will still be there even if
// this is false. It will just be completely white.

#let displayLinkToToC = true

// If you are about to send the document to a reviewer,
// setting this to true will print page-specific line
// numbers for all paragraphs of the main matter. This will
// make it easier for reviewers to give comments related to
// specific content lines.

#let showParagraphLineNumbers = false

// Choose whether to include certain frontmatter sections.

#let includeGlossary = true

#let includeListOfFigures = true

#let includeListOfTables = true

#let includeListOfListings = true

// Choose your fonts. Remember that they need to exist on
// your system for Typst to find them.
//
// NOTE that these should be accessible: sans serif with
// distinctive letters, so that visually impaired people
// have less difficulty reading the text in the output
// format of this template.
//
// The default fonts below are rather accessible, but still
// professional-looking enough for use in a university
// thesis template. To maximize accessibility, you might
// try "Luciole" as a textFont and "Luciole Math" as a
// mathFont.
//
// NOTE that maximum accessibility sometimes means
// wonky-looking letters.

#let textFont = "Roboto"

#let mathFont = "STIX Two Math"

#let codeFont = "Fira Mono"
