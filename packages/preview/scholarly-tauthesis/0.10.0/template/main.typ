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

#let citationstyle = "ieee"

/**
 * Set this to false if you are an international student and do
 * not need a Finnish abstract.
***/

#let include-finnish-abstract = true

/**
 * Set this to true before compiling your document, if you intend
 * to print a physical copy of it.
***/

#let physically-printed = false

/**
 * Set this to true, if you utilized artificial intelligence, such as large
 * language models in writing your thesis.
***/

#let usedAI = true

//// Finnish metadata.

#let alaotsikko = [Alaotsikko] // or none
#let avainsanat = ("avainsana1", "avainsana2")
#let koulu = [Tampereen Yliopisto]
#let tiedekunta = [Tiedekunta]
#let otsikko = [Opinnäytetyöpohja]
#let työntyyppi = [Diplomityö]
#let sijainti = [Tampereella]

//// English metadata.

#let faculty = "Faculty"
#let keywords = ("keyword1", "keyword2")
#let university = [Tampere University]
#let subtitle = [Subtitle] // or none
#let thesistype = "Master's thesis"
#let title = "Thesis template"
#let location = "Tampere"

//// Import the tauthesis module..

#import "@preview/scholarly-tauthesis:0.10.0" as tauthesis

//// Set how figures and equations are numbered.

#let fignumberwithinlevel = 1

#let eqnumberwithinlevel = 1

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

// If you are about to send the document to a reviewer,
// setting this to true will print page-specific line
// numbers for all paragraphs of the main matter. This will
// make it easier for reviewers to give comments related to
// specific content lines.

#let showParagraphLineNumbers = false

// Actually set document metadata and structure.

#show: tauthesis.template.with(
	abstractContents: abstractContents,
	aiDisclaimerContents: aiDisclaimerContents,
	alaotsikko: alaotsikko,
	author: author,
	avainsanat: avainsanat,
	citationstyle: citationstyle,
	displayLinkToToC: displayLinkToToC,
	eqnumberwithinlevel : eqnumberwithinlevel,
	examiners: examiners,
	faculty: faculty,
	fignumberwithinlevel : fignumberwithinlevel,
	glossaryDict: glossaryDict,
	include-finnish-abstract: include-finnish-abstract,
	keywords: keywords,
	koulu: koulu,
	language: language,
	location: location,
	otsikko: otsikko,
	physically-printed: physically-printed,
	prefaceContents: prefaceContents,
	showParagraphLineNumbers: showParagraphLineNumbers,
	sijainti: sijainti,
	subtitle: subtitle,
	tekoälynKäyttöTeksti: tekoälynKäyttöTeksti,
	thesistype: thesistype,
	tiedekunta: tiedekunta,
	tiivistelmänSisältö: tiivistelmänSisältö,
	title: title,
	työntyyppi: työntyyppi,
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

#bibliography(style: citationstyle, "bibliography.bib")

//// Place appendix-related chapters here.

#show: doc => tauthesis.appendix(
	fignumberwithinlevel: fignumberwithinlevel,
	eqnumberwithinlevel: eqnumberwithinlevel,
	language,
	doc
)

#include "content/A.typ"
