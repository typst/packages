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

//// Import the tauthesis module and document metadata.

#import "@preview/scholarly-tauthesis:0.24.0" as tauthesis

#import "meta.typ"

// Get preface, glossary and other frontmatter contents.

#import "frontmatter/glossary.typ": glossaryWords

#let tiivistelmänSisältö = include "frontmatter/tiivistelma.typ"

#let abstractContents = include "frontmatter/abstract.typ"

#let prefaceContents = include "frontmatter/preface.typ"

#let acknowledgementContents = include "frontmatter/acknowledgements.typ"

#let aiDisclaimerContents = include "frontmatter/use-of-ai.typ"

#let tekoälynKäyttöTeksti = include "frontmatter/tekoalyn-kaytto.typ"

#let thanksContents = include "frontmatter/thanks.typ"

#let publicationDict = yaml("bibliography.yaml")

// Actually apply all settings related to the template.

#show: tauthesis.template.with(
	abstractContents: abstractContents,
	acknowledgementContents: acknowledgementContents,
	aiDisclaimerContents: aiDisclaimerContents,
	alaotsikko: meta.alaotsikko,
	attachPublications: meta.attachPublications,
	author: meta.author,
	avainsanat: meta.avainsanat,
	citationStyle: meta.citationStyle,
	colorSeparatorLines: meta.colorSeparatorLines,
	compilationThesis: meta.compilationThesis,
	description: meta.description,
	eqNumberWithinLevel : meta.eqNumberWithinLevel,
	examiners: meta.examiners,
	faculty: meta.faculty,
	figNumberWithinLevel : meta.figNumberWithinLevel,
	glossaryDict: glossaryWords,
	includeFinnishAbstract: meta.includeFinnishAbstract,
	includeGlossary: meta.includeGlossary,
	includeListOfFigures: meta.includeListOfFigures,
	includeListOfTables: meta.includeListOfTables,
	includeListOfListings: meta.includeListOfListings,
	includeThanks: meta.includeThanks,
	keywords: meta.keywords,
	koulu: meta.koulu,
	language: meta.language,
	location: meta.location,
	otsikko: meta.otsikko,
	physicallyPrinted: meta.physicallyPrinted,
	prefaceContents: prefaceContents,
	printTwoSided: meta.printTwoSided,
	publicationDict: publicationDict,
	region: meta.region,
	showParagraphLineNumbers: meta.showParagraphLineNumbers,
	sijainti: meta.sijainti,
	subtitle: meta.subtitle,
	tekoälynKäyttöTeksti: tekoälynKäyttöTeksti,
	thesisProgramme : meta.thesisProgramme,
	thesisType: meta.thesisType,
	tiedekunta: meta.tiedekunta,
	tiivistelmänSisältö: tiivistelmänSisältö,
	maintitle: meta.maintitle,
	tutkintoOhjelma : meta.tutkintoOhjelma,
	thanksContents: thanksContents,
	työnTyyppi: meta.työnTyyppi,
	university: meta.university,
	usedAI : meta.usedAI,
	textFont: meta.textFont,
	mathFont: meta.mathFont,
	codeFont: meta.codeFont,
)

// Include your main matter chapters in the index-mainmatter.typ file.

#include "mainmatter/index.typ"

#show: tauthesis.bibSettings.with(meta.language)

#bibliography(
	style: meta.citationStyle,
	target: selector(cite).before(<publicationMatter>),
	"bibliography." + meta.bibFileSuffix
)

// Place appendix-related chapters into the appendix index file.

#show: doc => tauthesis.appendix(
	figNumberWithinLevel: meta.figNumberWithinLevel,
	eqNumberWithinLevel: meta.eqNumberWithinLevel,
	mathFont: meta.mathFont,
	codeFont: meta.codeFont,
	meta.language,
	tauthesis.thesisTypeToIntFn(meta.thesisType),
	doc,
)

#include "appendices/index.typ"

// Load publications based on bibliography data.
//
// This has to be done here, as any paths in Typst are
// resolved in relation to the file where data is loaded.
// This means we cannot call functions like read or image
// in the template module, unless the files are actually in
// relation to the module path.

#show: tauthesis.publicationMatter.with(
	figNumberWithinLevel: meta.figNumberWithinLevel,
	eqNumberWithinLevel: meta.eqNumberWithinLevel,
)

#let thesisTypeInt = tauthesis.thesisTypeToIntFn(meta.thesisType)

#if thesisTypeInt >= tauthesis.licentiateThesisTypeInt and meta.compilationThesis and meta.attachPublications {

	for (citeKey, publication) in publicationDict {
		if not "tauthesis-publication" in publication or not publication.tauthesis-publication { continue }
		tauthesis.displayPublicationTitlePage(
			citeKey,
			publication,
			meta.language,
			thesisTypeInt,
			meta.physicallyPrinted,
			meta.printTwoSided,
		)
		if "path" in publication and publication.path != none {
			let (filePathStr, fileNameSuffix) = tauthesis.publicationFilePath(citeKey, publication)
			let filePath = path(publication.path)
			tauthesis.loadPublicationPages(
				citeKey,
				publication,
				filePath,
				fileNameSuffix,
				tauthesis.thesisTypeToIntFn(meta.thesisType),
				meta.language,
				meta.physicallyPrinted,
				meta.printTwoSided,
			)
		}
	}
}
