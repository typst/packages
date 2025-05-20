/*** main.typ
 *
 * The main document to be compiled. Run
 *
 *   typst compile main.typ
 *
 * to perform the compilation. If you are writing a multi-file
 * project, this file is where you need to include your content
 * files.
 *
***/

//// Import the tauthesis module.

#import "@preview/scholarly-tauthesis:0.13.3" as tauthesis

//// Define document metadata.

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
 * This allows you to choose a citation style. See
 * <https://typst.app/docs/reference/model/bibliography/#parameters-style>
 * for possible options.
***/

#let citationStyle = "ieee"

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

// A description that ends up in document metadata.

#let description = "A short description of this document."

//// Finnish metadata.

#let alaotsikko = "Kuvaava alaotsikko" // or none without the ""
#let avainsanat = ("avainsana1", "avainsana2", "...")
#let koulu  = "Tampereen Yliopisto"
#let otsikko = "Opinnäytetyöpohja"
#let sijainti = "Tampereella"
#let tiedekunta = "Tiedekunta"
#let työnTyyppi = tauthesis.tohtorinTyönTyyppi // One of {kandidaatin,diplomi,maisterin,lisensiaatin,tohtorin}TyönTyyppi

//// English metadata.

#let faculty = "Faculty"
#let keywords = ("keyword1", "keyword2", "...")
#let location = "Tampere"
#let subtitle = "Subtitle" // or none without the ""
#let thesisType = tauthesis.doctoralThesisType // One of {bachelors,masters,licentiate,doctoral}ThesisType
#let title = "Thesis template"
#let university = "Tampere University"

// Set the maximum heading levels under which figures and equations are numbered.

#let figNumberWithinLevel = 1

#let eqNumberWithinLevel = 1

// Get preface, glossary and other non-main-matter contents.

#let glossaryModule = import "content/glossary.typ": glossary_words as glossaryDict

#let tiivistelmänSisältö = include "content/tiivistelmä.typ"

#let abstractContents = include "content/abstract.typ"

#let prefaceContents = include "content/preface.typ"

#let aiDisclaimerContents = include "content/use-of-ai.typ"

#let tekoälynKäyttöTeksti = include "content/tekoalyn-kaytto.typ"

// Determines whether the link to the table of contents is
// displayed or not. The link will still be there even if
// this is false. It will just be completely white.

#let displayLinkToToC = true

// This is the minimum number of figures of each type that is required to make
// lists of figures appear. Bachelor's theses do not contain such listings at
// all, so this setting will have no effect if the thesis type is chosen.

#let minimumFigureListingCount = 1

// If you are about to send the document to a reviewer,
// setting this to true will print page-specific line
// numbers for all paragraphs of the main matter. This will
// make it easier for reviewers to give comments related to
// specific content lines.

#let showParagraphLineNumbers = false

// Experimental: if you are writing a Doctoral thesis, this is the path to the
// Hayagriva YAML file that contains your Doctoral publication metadata. The path
// needs to be in relation to this main.typ file.

#let publicationDict = yaml("publications/publications.yaml")

// Actually set document metadata and structure.

#show: tauthesis.template.with(
	abstractContents: abstractContents,
	aiDisclaimerContents: aiDisclaimerContents,
	alaotsikko: alaotsikko,
	author: author,
	avainsanat: avainsanat,
	citationStyle: citationStyle,
	description: description,
	displayLinkToToC: displayLinkToToC,
	eqNumberWithinLevel : eqNumberWithinLevel,
	examiners: examiners,
	faculty: faculty,
	figNumberWithinLevel : figNumberWithinLevel,
	glossaryDict: glossaryDict,
	includeFinnishAbstract: includeFinnishAbstract,
	keywords: keywords,
	koulu: koulu,
	language: language,
	location: location,
	minimumFigureListingCount: minimumFigureListingCount,
	otsikko: otsikko,
	physicallyPrinted: physicallyPrinted,
	prefaceContents: prefaceContents,
	printTwoSided: printTwoSided,
	publicationDict: publicationDict,
	showParagraphLineNumbers: showParagraphLineNumbers,
	sijainti: sijainti,
	subtitle: subtitle,
	tekoälynKäyttöTeksti: tekoälynKäyttöTeksti,
	thesisType: thesisType,
	tiedekunta: tiedekunta,
	tiivistelmänSisältö: tiivistelmänSisältö,
	title: title,
	työnTyyppi: työnTyyppi,
	university: university,
	usedAI : usedAI,
)

//// Include your chapters here.
//
// Your text can be written entirely in this file, or split into
// multiple subfiles. If you do, you will need to import the
// preamble separately to those files, if you wish to use the
// commands.
//

#include "content/01.typ"
#include "content/02.typ"
#include "content/03.typ"
#include "content/04.typ"

#show: tauthesis.bibSettings

#bibliography(style: citationStyle, "bibliography.bib")

//// Place appendix-related chapters here.

#show: doc => tauthesis.appendix(
	figNumberWithinLevel: figNumberWithinLevel,
	eqNumberWithinLevel: eqNumberWithinLevel,
	language,
	doc
)

#include "content/A.typ"
#include "content/B.typ"

#tauthesis.attachPublications(thesisType, publicationDict, language)
