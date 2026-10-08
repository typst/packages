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

#import "@preview/scholarly-tauthesis:0.23.0" as tauthesis

#import "metadata.typ"

// Get preface, glossary and other non-main-matter contents.

#let glossaryModule = import "frontmatter/glossary.typ": glossary_words as glossaryDict

#let tiivistelmänSisältö = include "frontmatter/tiivistelma.typ"

#let abstractContents = include "frontmatter/abstract.typ"

#let prefaceContents = include "frontmatter/preface.typ"

#let aiDisclaimerContents = include "frontmatter/use-of-ai.typ"

#let tekoälynKäyttöTeksti = include "frontmatter/tekoalyn-kaytto.typ"

#let publicationDict = yaml("bibliography.yaml")

// Actually apply all settings related to the template.

#show: tauthesis.template.with(
	abstractContents: abstractContents,
	aiDisclaimerContents: aiDisclaimerContents,
	alaotsikko: metadata.alaotsikko,
	attachPublications: metadata.attachPublications,
	author: metadata.author,
	avainsanat: metadata.avainsanat,
	citationStyle: metadata.citationStyle,
	colorSeparatorLines: metadata.colorSeparatorLines,
	compilationThesis: metadata.compilationThesis,
	description: metadata.description,
	displayLinkToToC: metadata.displayLinkToToC,
	eqNumberWithinLevel : metadata.eqNumberWithinLevel,
	examiners: metadata.examiners,
	faculty: metadata.faculty,
	figNumberWithinLevel : metadata.figNumberWithinLevel,
	glossaryDict: glossaryDict,
	includeFinnishAbstract: metadata.includeFinnishAbstract,
	includeGlossary: metadata.includeGlossary,
	includeListOfFigures: metadata.includeListOfFigures,
	includeListOfTables: metadata.includeListOfTables,
	includeListOfListings: metadata.includeListOfListings,
	keywords: metadata.keywords,
	koulu: metadata.koulu,
	language: metadata.language,
	location: metadata.location,
	otsikko: metadata.otsikko,
	physicallyPrinted: metadata.physicallyPrinted,
	prefaceContents: prefaceContents,
	printTwoSided: metadata.printTwoSided,
	publicationDict: publicationDict,
	region: metadata.region,
	showParagraphLineNumbers: metadata.showParagraphLineNumbers,
	sijainti: metadata.sijainti,
	subtitle: metadata.subtitle,
	tekoälynKäyttöTeksti: tekoälynKäyttöTeksti,
	thesisProgramme : metadata.thesisProgramme,
	thesisType: metadata.thesisType,
	tiedekunta: metadata.tiedekunta,
	tiivistelmänSisältö: tiivistelmänSisältö,
	maintitle: metadata.maintitle,
	tutkintoOhjelma : metadata.tutkintoOhjelma,
	työnTyyppi: metadata.työnTyyppi,
	university: metadata.university,
	usedAI : metadata.usedAI,
	textFont: metadata.textFont,
	mathFont: metadata.mathFont,
	codeFont: metadata.codeFont,
)

// Include your main matter chapters in the index-mainmatter.typ file.

#include "mainmatter/index.typ"

#show: tauthesis.bibSettings.with(metadata.language)

#bibliography(
	style: metadata.citationStyle,
	target: selector(cite).before(<publicationMatter>),
	"bibliography." + metadata.bibFileSuffix
)

// Place appendix-related chapters into the appendix index file.

#show: doc => tauthesis.appendix(
	figNumberWithinLevel: metadata.figNumberWithinLevel,
	eqNumberWithinLevel: metadata.eqNumberWithinLevel,
	mathFont: metadata.mathFont,
	codeFont: metadata.codeFont,
	metadata.language,
	tauthesis.thesisTypeToIntFn(metadata.thesisType),
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
	figNumberWithinLevel: metadata.figNumberWithinLevel,
	eqNumberWithinLevel: metadata.eqNumberWithinLevel,
)

#let thesisTypeInt = tauthesis.thesisTypeToIntFn(metadata.thesisType)

#if thesisTypeInt >= tauthesis.licentiateThesisTypeInt and metadata.compilationThesis and metadata.attachPublications {

	for (citeKey, publication) in publicationDict {
		if not "tauthesis-publication" in publication or not publication.tauthesis-publication { continue }
		tauthesis.displayPublicationTitlePage(citeKey, publication, metadata.language)
		if "path" in publication and publication.path != none {
			let (filePathStr, fileNameSuffix) = tauthesis.publicationFilePath(citeKey, publication)
			let filePath = path(publication.path)
			tauthesis.loadPublicationPages(
				citeKey,
				publication,
				filePath,
				fileNameSuffix,
				tauthesis.thesisTypeToIntFn(metadata.thesisType),
				metadata.language,
			)
		}
	}
}
