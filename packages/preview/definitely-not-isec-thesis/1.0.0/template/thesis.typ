#import "@preview/definitely-not-isec-thesis:1.0.0": *

// ----------------------------------------------------------------------------
// Configuration
// ----------------------------------------------------------------------------
#show: thesis.with(
  title: [
		Title and       #linebreak()
		Subtitle        #linebreak()
		of the Thesis   #linebreak()
		(up to 4 Lines) #linebreak()
	],
  author: ([Firstname Lastname], [BSc]),
  curriculum: [Computer Science],
  supervisors: (
    ([Firstname Lastname], [Academic Degrees]),
    ([Firstname Lastname], [Academic Degrees])
  ),
  institute: [Institute of Information Security],
  date: [Month Year],
  acknowledgements: [
		Thanks everyone who made this thesis possible
  ],
  abstract: [
		English abstract of your thesis (at most one page)

    The abstract usually consists of two main parts: a motivational background
    and your contribution. Start with a few sentences of general introduction
    and background information to motivate your main research
    question/challenge. Then, summarize what your paper contributes and
    describe its (potential) impact. This includes a very short summary of all
    your important results and core performance numbers that characterize your
    approach/attack/countermeasure/implementation. Finally, summarize any key
    conclusions and calls to action that you have, e.g., apply the idea more
    broadly, get rid of some technology, find a countermeasure, or similar.
  ],
	kurzfassung: ( // Multi-language support. Set to none to disable.
		"title": [Kurzfassung],
		"abstract": [
			Deutsche Kurzfassung der Abschlussarbeit (maximal eine Seite)
		],
		"ktitle": [Schlagwörter],
		"keywords": ([Einige Stichwörter...],),
	),
  keywords: ([Broad keyword], [Keyword], [Specific Keyword],
             [Another specific keyword]),
	notations: ((
		"xor": ([#sym.xor.big], "exclusive-or (Xor)"),
	)),
	acronyms: ((
		"ISEC": "Institute of Information Security",
	)),
	list-of-figures:  true,
	list-of-tables:   true, 
	list-of-listings: true, // Wrap code in #figure
	debug: false, // Enable once before a revision (slow)
)

// -------------------------------[[ CUT HERE ]]--------------------------------
//
// Welcome to the starting point of your final Master Thesis :) Congrats!
//
// Typst quickstart:
//
// - $ typst watch thesis.typ    (Incremental build, recommended)
// - $ typst compile thesis.typ  (Plain build, not recommended for editing)
// - * tinymist :TypstPreview (neovim) or VSCode plugin (Best for live preview)
//
// Typst documentation, guides & help:
//
// - https://typst.app/docs/
// - https://sitandr.github.io/typst-examples-book/book/about.html
// - https://discord.gg/2uDybryKPe
// - https://forum.typst.app/
//
// Typst LSP: 
//
// - https://github.com/Myriad-Dreamin/tinymist
// - https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist
//
// Typst plugins:
//
// - https://typst.app/universe/
// - https://github.com/qjcg/awesome-typst
//
// Recommendations:
//
// - Keep code/text formatted at 80 cols as in this example
// - Use tinymist for previewing changes (faster than typst watch)
// - Force #pagebreak() if your document is long. This triggers multithr. builds 
// - Keep in mind Typst breaks API for now (still 0.X.X), so update or freeze
//
// Bugs, limitations, differences:
//
// - Upstream: https://github.com/ecomaikgolf/typst-isec-masterthesis-template
// - Check "Issues" in the upstream, report bugs there
// - Feel free to send patches
//
// Now that you know everything important, I recommend removing this comment
//
// Happy writing and good luck defending!
// Ernesto - ecomaikgolf.com
//
// -------------------------------[[ CUT HERE ]]--------------------------------


// ----------------------------------------------------------------------------
// Introduction
// ----------------------------------------------------------------------------

= Introduction <sec:intro>


// ----------------------------------------------------------------------------
// Background
// ----------------------------------------------------------------------------

= Background <sec:background>


// ----------------------------------------------------------------------------
// Attack
// ----------------------------------------------------------------------------

= Attack <sec:attack>


// ----------------------------------------------------------------------------
// Evaluation
// ----------------------------------------------------------------------------

= Evaluation <sec:evaluation>


// ----------------------------------------------------------------------------
// Discussion
// ----------------------------------------------------------------------------

= Discussion <sec:discussion>


// ----------------------------------------------------------------------------
// Notation
// ----------------------------------------------------------------------------

// - Set notations: none in thesis.with to disable this page (or remove this)
// - TLDR: #ntt("xor") from thesis.with notations
// - Downstream "acrostiche" package with patches for notations + page numbers

#notations-page(notat)

// ----------------------------------------------------------------------------
// Acronyms
// ----------------------------------------------------------------------------

// - Set acronyms: none in thesis.with to disable this page (or remove this)
// - TLDR: #acr("AES") from the thesis.with acronyms
// - Downstream "acrostiche" package with patches for listing page numbers
// - See https://typst.app/universe/package/acrostiche/ for documentation

#acronyms-page(acros)

// ----------------------------------------------------------------------------
// Bibliography
// ----------------------------------------------------------------------------

// - Use bibtex (LaTeX) or hayagriva YAML (Typst) bibliography files
// - See https://typst.app/docs/reference/model/cite/
// - See https://typst.app/docs/reference/model/bibliography/
// - TLDR: @biblabel OR #cite(form: ..., biblabel)

#bibliography("bibliography.bib")<sec:bibliography>

// ----------------------------------------------------------------------------
// Appendix (Optional)
// ----------------------------------------------------------------------------
#show: appendix

= Code Listings<sec:codelistings>


// vim:tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab colorcolumn=81
