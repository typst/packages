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

#import "@preview/scholarly-tauthesis:0.17.2" as tauthesis

#import "metadata.typ"

// Get preface, glossary and other non-main-matter contents.

#let glossaryModule = import "frontmatter/glossary.typ": glossary_words as glossaryDict

#let tiivistelmänSisältö = include "frontmatter/tiivistelmä.typ"

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

#show: tauthesis.bibSettings

#bibliography(
	style: metadata.citationStyle,
	"bibliography." + metadata.bibFileSuffix
)

// Place appendix-related chapters into the appendix index file.

#show: doc => tauthesis.appendix(
	figNumberWithinLevel: metadata.figNumberWithinLevel,
	eqNumberWithinLevel: metadata.eqNumberWithinLevel,
	mathFont: metadata.mathFont,
	codeFont: metadata.codeFont,
	metadata.language,
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

#show: tauthesis.publicationMatter

#let thesisTypeNum = tauthesis.thesisTypeToIntFn(metadata.thesisType)

#if thesisTypeNum >= tauthesis.licentiateThesisTypeInt and metadata.compilationThesis and metadata.attachPublications {
	for (citeKey, publication) in publicationDict {
		if not "tauthesis-publication" in publication or not publication.tauthesis-publication { continue }
		tauthesis.displayPublication(citeKey, publication, metadata.language)
		if "path" in publication and publication.path != none {
			let filePath = publication.path
			// Validate file path.
			let filePathParts = filePath.split("/")
			let directoryPath = filePathParts.slice(0,-1).join("/")
			let fileName = filePathParts.last()
			let fileNameParts = fileName.split(".")
			let fileNamePartsN = fileNameParts.len()
			let fileNameStem = if fileNamePartsN == 1 {
				""
			} else if fileNamePartsN > 1 {
				fileNameParts.slice(0,-1).join(".")
			} else {
				panic("Given publication " + citeKey + " file name " + fileName + " was not valid. It needs to be of the form stem.type to differentiate between file types.")
			}
			let fileNameSuffix = if fileNamePartsN > 1 {
				fileNameParts.last()
			} else {
				panic("Given publication " + citeKey + " file name " + fileName + " was not valid. It needs to be of the form stem.type to differentiate between file types.")
			}
			let footerDescent = 60%
			if "n-of-pages" in publication {
				if fileNameSuffix == "pdf" {
					let pdfBytes = read(filePath, encoding: none)
					for pagei in range(publication.n-of-pages) {
						image(
							pdfBytes,
							width: 100%,
							page: pagei + 1,
							alt: (
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
						)
					}
				} else if fileNameSuffix in ("svg","png","jpg") {
					// These file formats are split into multiple files,
					// so we assume that the file names are of the form
					// "stem-pagenumber.type".
					// We automatically add the required page numbers.
					for pagei in range(publication.n-of-pages) {
						let filePathWithPageNum = directoryPath + "/" + fileNameStem + "-" + str(pagei+1) + "." + fileNameSuffix
						image(
							filePathWithPageNum,
							width: 100%,
							page: pagei + 1,
							alt: (
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
						)
					}
				} else if fileNameSuffix == "typ" {
					tauthesis.PUBLICATIONPAGECOUNTER.update(1)
					set page(
						paper: tauthesis.thesisTypeIntToPageSizeFn(thesisTypeNum),
						margin: tauthesis.thesisTypeIntToMarginsFn(thesisTypeNum),
						header: context {
							smallcaps(if metadata.language == tauthesis.finnish {
								"Julkaisu"
							} else {
								"Publication"
							})
							sym.space.nobreak
							numbering("I", counter(heading).get().first())
							line(
								length: 100%,
								stroke: 2pt + tauthesis.tuniPurple,
							)
						},
						footer: context {
							tauthesis.PUBLICATIONPAGECOUNTER.step()
							set align(center)
							tauthesis.PUBLICATIONPAGECOUNTER.display()
						},
						footer-descent: footerDescent,
					)
					include filePath
					show: tauthesis.publicationEnd
				} else {
					panic("Unsupported file type ." + fileNameSuffix + " for attaching publications.")
				}
			} else {
				if fileNameSuffix == "typ" {
					tauthesis.PUBLICATIONPAGECOUNTER.update(1)
					set page(
						paper: tauthesis.thesisTypeIntToPageSizeFn(thesisTypeNum),
						margin: tauthesis.thesisTypeIntToMarginsFn(thesisTypeNum),
						header: context {
							smallcaps(if metadata.language == tauthesis.finnish {
								"Julkaisu"
							} else {
								"Publication"
							})
							sym.space.nobreak
							numbering("I", counter(heading).get().first())
							line(
								length: 100%,
								stroke: 2pt + tauthesis.tuniPurple,
							)
						},
						footer: context {
							tauthesis.PUBLICATIONPAGECOUNTER.step()
							set align(center)
							tauthesis.PUBLICATIONPAGECOUNTER.display()
						},
						footer-descent: footerDescent,
					)
					include filePath
					show: tauthesis.publicationEnd
				} else if fileNameSuffix in ("pdf","svg","jpg","png") {
					image(
						filePath,
						width: 100%,
						alt: (
						"The only page of publication\""
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
					)
				} else {
					panic("Unsupported file type ." + fileNameSuffix + " for attaching publications.")
				}
			}
		}
	}
}
