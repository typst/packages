#import "@preview/mantys:1.0.2": *
#import "@preview/showybox:2.0.4": *
#import "@preview/swank-tex:0.1.0": LaTeX
#import "@preview/cheq:0.2.2": *
#import "@preview/bookcls:0.1.0": *
// #import "../../src/book.typ": *

#show: checklist.with(fill: eastern.lighten(95%), stroke: eastern, radius: .2em)

#let typst-color = rgb(35,157,173)
#let Typst = text("Typst", fill: typst-color)

#let abstract = [This Typst package is a proposed template for writing thesis dissertations, French habilitations, or scientific books.]

#show: mantys(
  name: "book.typ",
  version: "0.1.0",
  authors: ("Mathieu Aucejo"),
  license: "MIT",
  description: "Write beautiful scientific book or thesis with Typst",
  repository: "https://github.com/maucejo/book_template",

  title: "Book Template",
  date: datetime.today(),

  abstract: abstract,
  show-index: false,
)

= Usage

== Using `bookcls`

To use the #package[bookcls] template, you need to include the following line at the beginning of your `typ` file:
#codesnippet[```typ
#import "@preview/bookcls:0.1.0": *
```
]

== Initializing the template

After importing #package[bookcls], you have to initialize the template by a show rule with the #cmd[book] command. This function takes an optional argument to specify the title of the document.
#codesnippet[```typ
#show: book.with(
  ...
)
```
]

#command("book", ..args(
	title: "Title",
  author: "Author Name",
  book-config: "default-book-config",
	[body]))[
		#argument("title", default: "Title", types: "string")[Title of the book or the thesis.]

		#argument("author", default: "Author Name", types: "string")[Author of the book.]

		#argument("book-config", default: "default-book-config", types: "dict")[Book configuration.

			The dictionary allows you to customize various aspects of the book. It contains the following keys:

			- `theme` #dtype(str) --  Theme of the document. Possible values are:
				-  `"fancy"` (default)
				- `"modern"`
				- `"classic"`

			- `logo` #dtype(image) -- Logo of the book (default #dtype(none))

			- `lang` #dtype(str) -- Language of the document. Supported languages French (`"fr"`-- default) and English (`"en"`)

			- `fonts` #dtypes(dictionary) -- Fonts used in the document. It contains the following keys:
				- `body` #dtype(str) -- Font used for the body text (default: `"New Computer Modern"`).
				- `math` #dtype(str) -- Font used for mathematical equations (default: `"New Computer Modern Math"`).

			- `colors` #dtypes(dictionary) -- Colors used in the document. It contains the following keys:
				- `primary` #dtype(color) -- Primary color (default: `rgb("#c1002a")`)
				- `secondary` #dtype(color) -- Secondary color (default: `rgb("#dddddd").darken(15%)`)
				- `boxeq` #dtype(color) -- Color of equation boxes (default: `rgb("#dddddd")`)
				- `header` #dtype(color) -- Color used for adapting the color of the document headers (default: `rgb("#dddddd").darken(25%)`)

			- title-page #dtype(content) -- Content of the title page (default: #dtype(none))
		]
	]

=== Initialization example
#codesnippet[
```typ
#show: book.with(
	author: "Author Name",
	book-config: (
		fonts: (
			body: "Lato",
			math: "Lete Sans Math"
		),
		theme: "modern",
		lang: "en",
		logo: image("path_to_image/image.png")
	)
)
```
]

#pagebreak()
=== Themes gallery

==== Parts
#subfigure(
	columns: 3,
	figure(image("manual-images/part-fancy.png"), caption: [`"fancy"`]),
	figure(image("manual-images/part-modern.png"), caption: [`"modern"`]),
	figure(image("manual-images/part-classic.png"), caption: [`"classic"`]),
)

#v(4em)
==== Chapters

#subfigure(
	columns: 3,
	figure(image("manual-images/chapter-fancy.png"), caption: [`"fancy"`]),
	figure(image("manual-images/chapter-modern.png"), caption: [`"modern"`]),
	figure(image("manual-images/chapter-classic.png"), caption: [`"classic"`]),
)

#pagebreak()
==== Unnumbered chapters

#subfigure(
	columns: 3,
	figure(image("manual-images/chapter-nonum-fancy.png"), caption: [`"fancy"`]),
	figure(image("manual-images/chapter-nonum-modern.png"), caption: [`"modern"`]),
	figure(image("manual-images/chapter-nonum-classic.png"), caption: [`"classic"`]),
)

#v(4em)
==== Sections

#subfigure(
	columns: 3,
	figure(image("manual-images/sections-fancy.png"), caption: [`"fancy"`]),
	figure(image("manual-images/sections-modern.png"), caption: [`"modern"`]),
	figure(image("manual-images/sections-classic.png"), caption: [`"classic"`]),
)

= Book content

The content of the book should be written in the main `typ` file or in additional files. The template provides a basic structure for writing a book.

In general, the section of the main file corresponding to the book content is structured as follows:
#codesnippet[
	```typ
	#show: front-matter

	#include "front-content.typ"

	#show: main-matter

	#tableofcontents()

	#listoffigures()

	#listoftables()

	#part("Main body")

	#include "chapter.typ"

	#bibliography("bibliography.bib")

	#show: appendix

	#part("Document appendices")

	#include "appendix.typ"
	```
]

The content of the thesis is divided into three main sections: `front-matter`, `main-matter`, and `appendix`. These elements are accompanied by additional functions to facilitate writing.

== Environments

The template provides three environments to structure the thesis content:

1. *front-matter*: environment for preliminary content (cover page, abstract, acknowledgments, etc.). Pages are numbered with Roman numerals and chapters are not numbered. To activate this environment, insert the following command in the main `typ` file at the desired location:
	#codesnippet[
		```typ
		#show: front-matter
		```
	]

2. *main-matter*: environment for the main content (introduction, tables of contents, chapters, conclusion, bibliography, etc.). Pages and chapters are numbered with Arabic numerals. To activate this environment, insert the following command in the main `typ` file at the desired location:
	#codesnippet[
	```typ
	#show: main-matter
	```
]

3. *appendix*: environment for the appendices. Pages are numbered with Roman numerals and chapters are numbered with letters. To activate this environment, insert the following command in the main `typ` file at the desired location:
	#codesnippet[
		```typ
		#show: appendix
		```
	]

== Parts and chapters

To structure the book content, you can define parts using the #cmd("part") function. To insert a new part, use the following command:
#codesnippet[
	```typ
	#part("Part title")
	```
]

Despite chapters can be defined using the standard #Typst markup language. This template defined a fonction #cmd("chapter") that allows to avoid boilerplate code, such as the manual inclusion of standard elements like title, abstract, and minitoc.

#command("chapitre", arg[title],
..args(
	abstract: none,
	toc: true,
	numbered: true,
	[body],
)
)[
	#argument("title", types: "string")[Chapter title.]

	#argument("abstract", default: none, types: "content")[Summary displayed below the chapter title.]

	#argument("toc", default: true, types: "boolean")[Indicates whether a mini table of contents should be displayed at the beginning of the chapter.]

	#argument("numbered", default: true, types: "boolean")[Indicates whether the chapter should be numbered.]
]

#codesnippet[
```typ
	#chapter(
		"First chapter",
		abstract: lorem(20),
		)[
			// Content of the chapter
		]
```
]
#info-alert[If you use a #sym.ast\.typ file for each chapter, you can type at the top of the file the following code.

	#codesnippet[
		```typ
		#show: chapter.with("First chapter", abstract: lorem(20), toc: true)

		// Content of the chapter
		== First section
		```
	]
]

For unnumbered chapters, you can simply use the #cmd("chapter-nonum") function. This function assumes that you have a #sym.ast\.typ file per chapter.
#codesnippet[
	```typ
	#show: chapter-nonum.with()

	// Content of the chapter
	= Chapter title
	```
]

== Tables of contents

The template defines several commands to facilitate the creation of tables of contents:
- #cmd("tableofcontents")\() : Table of contents
- #cmd("listoffigures")\() : List of figures
- #cmd("listoftables")\() : List of tables

A mini table of contents is automatically generated automatically by using the command #cmd("minitoc") in a chapter. This function is a wraper of the #cmd("suboutline") function provided by the `suboutline` package.

= Helper functions

== Subfigures

In general, figures are inserted into the document using the #cmd("figure") function from #Typst. However, #Typst currently does not provide mechanisms for handling subfigures (numbering and referencing). To address this limitation, the template includes a #cmd("subfigure") function that manages subfigures appropriately. This function wraps the #cmd("subpar.grid") function from the `subpar` package.

#codesnippet[
	```typ
	#subfigure(
		figure(image("image1.png"), caption: []),
		figure(image("image2.png"), caption: []), <b>,
		columns: (1fr, 1fr),
		caption: [Figure title],
		label: <fig:subfig>,
	)
	```
]

#info-alert[The example above shows a figure composed of two subfigures. The first subfigure has a caption, while the second has a #dtype("label") but no title. The second subfigure can be referenced in the text using the command #text(`@b`, fill: typst-color.darken(15%)).]

== Equations

To highlight an important equation, use the #cmd("boxeq") function.

#codesnippet[
	```typ
	$
		#boxeq[$p(A|B) prop p(B|A) space p(A)$]
	$
	```
]

To create an equation without numbering, use the #cmd("nonumeq") function.

#codesnippet[
	```typ
	#nonumeq[$integral_0^1 f(x) dif x = F(1) - F(0)$]
	```
]

== Information boxes

The template provides several types of boxes to highlight different kinds of content:

- #cmd("info-box") for remarks;
- #cmd("tip-box") for tips;
- #cmd("warning-box") for warnings;
- #cmd("important-box") for important information;
- #cmd("proof-box") for proofs;
- #cmd("question-box") for questions.

#codesnippet[
	#show math.equation: set text(font: "Lete Sans Math")
	```typ
	#info-box[#lorem(10)]
	#tip-box[#lorem(10)]
	#warning-box[#lorem(10)]
	#important-box[#lorem(10)]
	#proof-box[#lorem(10)]
	#question-box[#lorem(10)]
	```
]

#info-alert[The appearance of the boxes depends on the selected theme (see the "Themes gallery" section).]

The information boxes described above are built using the #cmd("custom-box") function, which allows you to create custom boxes. This generic function takes the following parameters:
#command("custom-box",
..args(
	title: none,
	icon: "info",
	color: rgb(29, 144, 208),
	[body],
)
)[
	#argument("title", default: none, types: "string")[Name of the box.]

	#argument("icon", default: "info", types: "string")[Name of the icon to display in the box.

	Available icons are:
	- #box-title(image("../src/resources/images/icons/alert.svg", width: 1em), [: `"alert"`])
	- #box-title(image("../src/resources/images/icons/info.svg", width: 1em), [: `"info"`])
	- #box-title(image("../src/resources/images/icons/question.svg", width: 1em), [: `"question"`])
	- #box-title(image("../src/resources/images/icons/report.svg", width: 1em), [: `"report"`])
	- #box-title(image("../src/resources/images/icons/stop.svg", width: 1em), [: `"stop"`])
	- #box-title(image("../src/resources/images/icons/tip.svg", width: 1em), [: `"tip"`])
	]

	#argument("color", default: rgb(29, 144, 208), types: "color")[Box color.]
]

#pagebreak()
== Title pages

The template provides two functions to create title pages: one for a book and one for a thesis :

#command("book-page-title",
..args(
	subtitle: "Book subtitle",
  edition: "First edition",
  institution: "Institution",
  series: "Discipline",
  year: "2024",
  cover: none,
  logo: none,
	[body]
)
)[
	#argument("subtitle", default: "Book subtitle", types: "string")[Subtitle of the book.]

	#argument("edition", default: "First edition", types: "string")[Edition of the book.]

	#argument("institution", default: "Institution", types: "string")[Name of the institution.]

	#argument("series", default: "Discipline", types: "string")[Name of the series.]

	#argument("year", default: "2024", types: "string")[Year of publication.]

	#argument("cover", default: none, types: "image")[Cover image of the book.]

	#argument("logo", default: none, types: "image")[Logo of the book.]
]

#codesnippet[
```typ
#show: book.with(
	title-page: book-title-page(
		logo: image("path_to_logo/logo.png"),
		cover: image("path_to_image/book-cover.jpg")
	)
)
```
]

#command("thesis-page-title",
..args(
	type: "phd",
  school: "School name",
  doctoral-school: "Name of the doctoral school",
  supervisor: ("Supervisor name",),
  cosupervisor: none,
  laboratory: "Laboratory name",
  defense-date: "01 January 1970",
  discipline: "Discipline",
  specialty: "Speciality",
  committee: (:),
  logo: none,
	[body]
)
)[
	#argument("type", default: "phd", types: "string")[
		Type of thesis. Two values are possible:
		- `"phd"` for a doctoral thesis
		- `"hablitation"` for a French habilitation
	]

	#argument("school", default: "School name", types: "string")[Name of the institution where the thesis was prepared.]

	#argument("doctoral-school", default: "Name of the doctoral school", types: "string")[Name of the doctoral school.]

	#argument("supervisor", default: ("Supervisor name",), types: "array")[Name of the thesis supervisor(s) or the guarantor of the habilitation.]

	#argument("cosupervisor", default: none, types: "array")[Name of the thesis co-supervisor(s).]

	#argument("laboratory", default: "Laboratory name", types: "string")[Name of the research laboratory.]

	#argument("defense-date", default: "01 January 1970", types: "string")[Date of the thesis defense.]

	#argument("discipline", default: "Discipline", types: "string")[Name of the discipline.]

	#argument("specialty", default: "Speciality", types: "string")[Name of the specialty.]

	#argument("committee", default: (:), types: "array")[

		Name of the thesis committee members. Each element of the array is a #dtype(dictionary) with the following keys:
		- `name`: Name of the committee member.
		- `position`: Position of the committee member (e.g., "Associate Professor", "Professor", etc.).
		- `affiliation`: Affiliation of the committee member (e.g., "University Name").
		- `role`: Role of the committee member (e.g., "Chair", "Member", "Reviewer").

	]

	#argument("logo", default: none, types: "image")[Logo of the institution.]
]

#codesnippet(
```typ
#let committee = (
	(
		name: "Hari Seldon",
		position: "Full Professor",
		affiliation: "Streeling university",
		role: "President",
	),
	(
		name: "Gal Dornick",
		position: "Associate Professor",
		affiliation: "Synnax University",
		role: "Reviewer"
	),
)

#show: book.with(
	title-page: thesis-title-page(
		supervisor: ("Supervisor A", "Supervisor B"),
		cosupervisor: ("Co-supervisor A", "Co-supervisor B"),
		committee: committee
	)
)
```
)

#info-alert[For both title pages, the title of the document and its author are automatically generated based on the information given when initializing the template.]

== Back cover

A back cover of the document is automatically generated using the #cmd("back-cover") function, which displays information about the thesis (title and author), as well as a summary in French and English.

#command("back-cover", ..args(
	resume: none,
	abstract: none,
	logo: none
))[
	#argument("resume", types: "content")[Summary of the document in French.]

	#argument("abstract", types: "content")[Summary of the document in English.]

	#argument("logo", types: array)[Logo of the back cover.
	#codesnippet[
		```typ
		#let logos = (align(left)[#image("images/devise_cnam.svg", width: 45%)], align(right)[#image("images/logo_cnam.png", width: 50%)])

		#back-cover(lorem(10), lorem(10), logos)
		```
	]
	]
]

= Roadmap

The template is under development. Here is the list of features that are implemented or will be in a future version.

*Themes*

- [x] `fancy`
- [x] `modern`
- [x] `classic`

*Layout*

- [x] Standard layout
- [ ] Tufte layout

*Cover pages*

- [x] Title page
- [x] Back cover

*Environments*

- [x] Creation of the `front-matter` environment
- [x] Creation of the `main-matter` environment
- [x] Creation of the `appendix` environment

*Parts and chapters*
- [x] Creation of a document `part` -- #cmd("part")
- [x] Creation of a document `chapter` -- #cmd("chapter")
- [x] Creation of an unnumbered `chapter` -- #cmd("chapter-nonum")

*Tables of contents*

- [x] Creation of the table of contents -- #cmd("tableofcontents")
- [x] Creation of the list of figures -- #cmd("listoffigures")
- [x] Creation of the list of tables -- #cmd("listoftables")
- [x] Creation of a mini table of contents at the beginning of chapters using the `suboutline` package (see #link("https://typst.app/universe/package/minitoc", text("link", fill: typst-color)))
- [x] Customization of entries (appearance, hyperlink) by modifying the `outline.entry` element
- [x] Localization of the different tables

*Figures and tables*

- [x] Customization of the appearance of figure and table captions depending on the context (chapter or appendix)
- [x] Short titles for the lists of figures and tables
- [x] Creation of the #cmd("subfigure") function for subfigures via the `subpar` package

*Equations*

- [x] Adaptation of equation numbering depending on the context (chapter or appendix)
- [x] Creation of a function to highlight important equations -- #cmd("boxeq")
- [x] Creation of a function to define equations without numbering -- #cmd("nonumeq")
- [x] Use of the `equate` package to number equations in a system like (1.1a)

*Boxes*

- [x] Creation of information boxes to highlight important content

*Bibliography*

- [x] Verification of the reference list via `bibtex`
- [x] Same for `hayagriva` (see #link("https://github.com/typst/hayagriva/blob/main/docs/file-format.md", text("documentation", fill: typst-color)))

