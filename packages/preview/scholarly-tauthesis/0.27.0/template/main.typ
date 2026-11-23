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

#import "@preview/scholarly-tauthesis:0.27.0" as tauthesis

#import "meta.typ"

// Typst resolves a path given as a raw string in relation to the
// file where the string is written, so the template module cannot
// construct paths to files of this project by itself: a path
// constructed there would point into the module directory instead
// of this project, and edits made here would not land in the
// compiled document. The path resolver defined here anchors all
// user files that the template reads through it to this file. It
// is handed to the template, which loads the frontmatter content
// files through it, and to display-publication-pages, which attaches
// the publication files through it.

#let user-file-path-resolver = (path-string) => path(path-string)

// Load the publication data used for the frontmatter list of
// publications and for the attached publication pages.

#let publication-dict = yaml("bibliography.yaml")

// Actually apply all settings related to the template. The
// frontmatter content files are read by the template itself,
// through the path resolver defined above.

#show: tauthesis.template.with(
	alaotsikko: meta.alaotsikko,
	attach-publications: meta.attach-publications,
	author: meta.author,
	avainsanat: meta.avainsanat,
	citation-style: meta.citation-style,
	color-separator-lines: meta.color-separator-lines,
	compilation-thesis: meta.compilation-thesis,
	description: meta.description,
	eq-number-within-level : meta.eq-number-within-level,
	examiners: meta.examiners,
	faculty: meta.faculty,
	fig-number-within-level : meta.fig-number-within-level,
	include-finnish-abstract: meta.include-finnish-abstract,
	include-glossary: meta.include-glossary,
	include-list-of-figures: meta.include-list-of-figures,
	include-list-of-tables: meta.include-list-of-tables,
	include-list-of-listings: meta.include-list-of-listings,
	include-thanks: meta.include-thanks,
	keywords: meta.keywords,
	koulu: meta.koulu,
	language: meta.language,
	location: meta.location,
	otsikko: meta.otsikko,
	path-resolver: user-file-path-resolver,
	physically-printed: meta.physically-printed,
	print-two-sided: meta.print-two-sided,
	publication-dict: publication-dict,
	region: meta.region,
	show-paragraph-line-numbers: meta.show-paragraph-line-numbers,
	sijainti: meta.sijainti,
	subtitle: meta.subtitle,
	thesis-programme : meta.thesis-programme,
	thesis-type: meta.thesis-type,
	tiedekunta: meta.tiedekunta,
	maintitle: meta.maintitle,
	tutkinto-ohjelma : meta.tutkinto-ohjelma,
	university: meta.university,
	used-ai : meta.used-ai,
	text-font: meta.text-font,
	math-font: meta.math-font,
	code-font: meta.code-font,
)

// Include your main matter chapters in the index-mainmatter.typ file.

#include "mainmatter/index.typ"

#show: tauthesis.bib-settings.with(meta.language)

#bibliography(
	style: meta.citation-style,
	target: selector(cite).before(<publication-matter>),
	"bibliography." + meta.bib-file-suffix
)

// Place appendix-related chapters into the appendix index file.

#show: doc => tauthesis.appendix(
	fig-number-within-level: meta.fig-number-within-level,
	eq-number-within-level: meta.eq-number-within-level,
	math-font: meta.math-font,
	code-font: meta.code-font,
	meta.language,
	tauthesis.thesis-type-to-int-fn(meta.thesis-type),
	doc,
)

#include "appendices/index.typ"

// Attach the publication pages based on bibliography data. The
// template handles the inclusion gating, the publication
// numbering, the publication title pages and the attached
// publication files internally, resolving their file paths
// through the path resolver defined above.

#show: tauthesis.publication-matter.with(
	fig-number-within-level: meta.fig-number-within-level,
	eq-number-within-level: meta.eq-number-within-level,
)

#tauthesis.display-publication-pages(
	publication-dict,
	user-file-path-resolver,
	meta.language,
	meta.thesis-type,
	meta.physically-printed,
	meta.print-two-sided,
	meta.compilation-thesis,
	meta.attach-publications,
)
