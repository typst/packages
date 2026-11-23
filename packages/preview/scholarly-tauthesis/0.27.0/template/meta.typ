//
// meta.typ
//
// Write any metadata related to your document here, by
// filling in suitable values for the given variables. This
// file is automatically loaded by the main file.
//

#import "@preview/scholarly-tauthesis:0.27.0" as tauthesis

// Common metadata.

#let author = "Firstname Lastname"

// Insert your examiners here.
// They will be automatically mentioned in the document metadata
// and printed on the title page of the lower thesis types,
// each preceded by the examiner label. The higher thesis
// types carry none, per the dissertation series covers.
// Remember to also thank them in your preface (alkusanat).

#let examiners = (
  tauthesis.examiner(
		title : "Professor",
		firstname : "John",
		lastname : "Doe",
	),
	tauthesis.examiner(
		title : "Docent",
		firstname : "Jane",
		lastname : "Doe",
	),
)

/**
 * One of "fi" or "en".
***/

#let language = "en"

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

#let citation-style = "ieee"

/**
 * Choose which bibliography file you wish to use.
 * Valid values are "yaml" for Hayagriva and "bib" for BibLaTeX.
***/

#let bib-file-suffix = "yaml"

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
 * If this flag is set to true, the page header separator
 * lines and the metadata separator lines in the abstracts
 * are colored purple, regardless of the value of the
 * flag physically-printed.
 *
 * Note that this might increase printing costs. If money
 * is a concern when printing, set this to false.
***/

#let color-separator-lines = true

/**
 * This flag makes the document pages two-sided, meaning the inner
 * margin will vary on even and odd pages. Only set this to true if
 *
 * 1. you set the flag physically-printed to true and
 * 2. your main matter is over 80 pages long.
 *
 * Setting this to true will make the document very annoying to
 * read on electronic screens, if physically-printed is also true.
***/

#let print-two-sided = false

/**
 * Set this to true, if you utilized artificial intelligence, such as large
 * language models in writing your thesis.
***/

#let used-ai = true

/**
 * Set this to false if you are writing a monograph
 * dissertation. Keep the value as true if you are writing
 * a compilation thesis. If you are not writing a PhD
 * dissertation or a licentiate thesis with publications,
 * the value does not matter.
***/

#let compilation-thesis = true

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

#let attach-publications = true

/**
 * When writing a doctoral thesis, there is a specific
 * section in frontmatter/thanks.typ dedicated to
 * informally thanking persons and other bodies who helped
 * the author of this work to endure through the whole
 * process. This switch determines whether the section is
 * to be included in the final PDF.
***/

#let include-thanks = true

// A description that ends up in document metadata.

#let description = "A short description of this document."

// Choose your thesis type. Only the English constant is needed:
// the Finnish thesis type shown on the Finnish title page and
// abstract is derived from it automatically. The available
// types and their Finnish translations are
//
// - tauthesis.bachelor-of-technology-thesis-type (Kandidaatintyö)
// - tauthesis.bachelor-of-philosophy-thesis-type (Kandidaatintutkielma)
// - tauthesis.bachelor-of-medicine-thesis-type (Lääketieteen kandidaatin opinnäytetyö)
// - tauthesis.master-of-technology-thesis-type (Diplomityö)
// - tauthesis.master-of-philosophy-thesis-type (Pro gradu -tutkielma)
// - tauthesis.master-of-medicine-thesis-type (Syventävä opinnäytetyö)
// - tauthesis.licentiate-of-technology-thesis-type (Lisensiaatintyö)
// - tauthesis.licentiate-of-philosophy-thesis-type (Lisensiaatintutkielma)
// - tauthesis.licentiate-of-health-sciences-thesis-type (Lisensiaatintutkimus)
// - tauthesis.doctoral-thesis-type (Väitöskirja)

#let thesis-type = tauthesis.doctoral-thesis-type

//// Finnish metadata.

#let alaotsikko = "Kuvaava alaotsikko" // or none without the ""
#let avainsanat = ("avainsana1", "avainsana2", "...")
#let koulu  = "Tampereen Yliopisto"
#let otsikko = "Työn otsikko"
#let sijainti = "Tampereella"
#let tiedekunta = "Tiedekunta"
#let tutkinto-ohjelma = "Tutkinto-ohjelma"

//// English metadata.

#let faculty = "Faculty"
#let keywords = ("keyword1", "keyword2", "...")
#let location = "Tampere"
#let subtitle = "Descriptive Subtitle" // or none without the ""
#let maintitle = "Thesis Title"
#let thesis-programme = "Degree programme"
#let university = "Tampere University"

// Set the maximum heading levels under which figures and equations are numbered.

#let fig-number-within-level = 1

#let eq-number-within-level = 1

// If you are about to send the document to a reviewer,
// setting this to true will print page-specific line
// numbers for all paragraphs of the main matter. This will
// make it easier for reviewers to give comments related to
// specific content lines.

#let show-paragraph-line-numbers = false

// Choose whether to include certain frontmatter sections.

#let include-glossary = true

#let include-list-of-figures = true

#let include-list-of-tables = true

#let include-list-of-listings = true

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
// try "Luciole" as a text-font and "Luciole Math" as a
// math-font.
//
// NOTE that maximum accessibility sometimes means
// wonky-looking letters.

#let text-font = "Roboto"

#let math-font = "STIX Two Math"

#let code-font = "Fira Mono"
