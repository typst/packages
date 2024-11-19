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
#let date = datetime.today()
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

#import "@preview/scholarly-tauthesis:0.9.0" as tauthesis

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

// Actually set document metadata and structure.

#show: doc => tauthesis.tauthesis(
	fignumberwithinlevel : fignumberwithinlevel,
	eqnumberwithinlevel : eqnumberwithinlevel,
	usedAI : usedAI,
	author: author,
	date: datetime.today(),
	examiners: examiners,
	language: language,
	citationstyle: citationstyle,
	// Set this to false if you are an international student and do not need a Finnish abstract.
	include-finnish-abstract: true,
	physically-printed: physically-printed,
	alaotsikko: alaotsikko,
	avainsanat: avainsanat,
	koulu: koulu,
	tiedekunta: tiedekunta,
	otsikko: otsikko,
	työntyyppi: työntyyppi,
	sijainti: sijainti,
	faculty: faculty,
	keywords: keywords,
	university: university,
	subtitle: subtitle,
	thesistype: thesistype,
	title: title,
	location: location,
	prefaceContents: prefaceContents,
	abstractContents: abstractContents,
	tiivistelmänSisältö: tiivistelmänSisältö,
	glossaryDict: glossaryDict,
	aiDisclaimerContents: aiDisclaimerContents,
	tekoälynKäyttöTeksti: tekoälynKäyttöTeksti,
	doc
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

#show: tauthesis.bibsettings

#bibliography(style: citationstyle, "bibliography.bib")

//// Place appendix-related chapters here.

#show: doc => tauthesis.appendix(
	fignumberwithinlevel: fignumberwithinlevel,
	eqnumberwithinlevel: eqnumberwithinlevel,
	language,
	doc
)

#include "content/A.typ"
