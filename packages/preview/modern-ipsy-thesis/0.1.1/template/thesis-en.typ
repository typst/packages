#import "@preview/modern-ipsy-thesis:0.1.1": *

#set raw(lang: "typ")
#show: ipsy.with(
  title: [
    Documentation for the IPSY Typst thesis template:\
    A short overview of syntax and general usage
  ],
  study-course: "Psychology",
  abstract: [
    This document aims to explain the proper creation of a thesis utilizing the typesetting software Typst under the requirements of the Institute of Psychology (IPSY) based on the guidelines for scientific writing outlined in @p:leitfaden.

    The rest of this template intents to explain how Typst works and which functions this template provides to the user to ensure adequate and formally correct formatting of a thesis. Ideally, this document is read at least once as a form of "documentation" with the code side-by-side as some parts reference it specifically. For more specific inquiries regarding the usage of Typst, it is recommended to read through its reference and tutorials on their homepage. However, this template should provide everything needed such that the user can just begin writing after setting the necessary metadata.

    In case of questions regarding specific formalities, the corresponding supervisor should be asked for their wishes; this template is not an absolute truth. Should paragraphs be indented? How do I properly cite this particular publication? Each supervisor has their own ideas which cannot all be represented in this document.
  ],
  appendix: include "chapters/anhang.typ",
  legal: include "chapters/eidesstatt.typ",
  thesis-type: "Guidelines",
  reviewers: ("Prof. Dr. Micky Maus", "Dr. Tommy Secundus"),
  bibliography: bibliography("literature.bib", style: "apa"),
  extra-outlined: true,
  link-color: blue,
  lang: "en"
)

#outline()
#figure-outline(title: "List of Figures")
#table-outline(title: "List of Tables")
#abbrv-outline(title: "List of Abbreviations", outlined: true)[
  / APA: American Psychological Association
  / CSL: Citation Style Language
  / GPL: GNU General Public License
  / IPSY: Institute of Psychology
  / $bold(p)$: Some statistical constant
  / SVG: Scalable Vector Graphics
]

/* --------------------------------------------- */

= Title Page and Default Syntax

The title page is filled in with the help of the `#show`-rule at the top of this source file. It contains several *arguments* which help the user in stylizing this template according to their wishes. They can be specified in any order but they are named, i.e., the name of the argument must be specified as well.

Each argument has a "default value" which will be used if no specific value is given by the user. For example, `thesis-type` has a default value of `"Bachelorarbeit"` ("bachelor thesis")---should this template be used for a bachelor thesis, then this argument can be left as-is. This way, only the arguments that differ from the provided defaults have to be modified.
See @tbl:args:

#figure(
  kind: table,
  caption: [All potential arguments (and default values) of this Typst template],
  align(left, generate-documentation())
)<tbl:args>

== Difference between `[Title]` and `"Title"`

The attentive reader may have noticed that some arguments can either be specified in brackets, such as [...], or in quotation marks "...". Text in between quotation marks are so-called _strings_, i.e., pure text. Content in between brackets can be _anything_, more specifically #link("https://typst.app/docs/reference/foundations/content")[_Content_] which Typst may generate. This allows the user to put arbitrary formatting inside those brackets, for example, a small circle such as #box(circle(radius: 4pt)) even in the thesis title.

For `#show`-rules, such as the one used to stylize this document, pure text in quotation marks will generally cover all use cases. Nonetheless, if the user wishes to put arbitrary content in the title, they are allowed to. Common formatting such as *bold*, _italic_ and #underline[underline] are only supported in _Content_.

*Rule of Thumb:* If an argument just needs text, use quotation marks. For formatting, use brackets. A Typst document, by default, already is in content mode such that formatting is possible (https://typst.app/docs/reference/syntax/).

== Headings and Subheadings<sec:headings>

Typst uses the "=" symbol to create headings. The amount of "=" symbols represents the depth or level of the heading. A singular "=" creates a "level one"-heading, meaning a new chapter. As such, "==" creates a subheading and "===" creates a subsubheading. The correct numbering is automatically applied.

The table of contents lists all headings up to (and including) level three. Headings with a depth of four or more can be used to create semantic paragrah breaks which are not numbered and part of the prose.

==== Subsubsubheading
#lorem(20)

== Table of Contents, List of Tables and List of Figures

A table of contents can be generated with the `#outline(..)` function. Both the `depth` of the to-be-included headings as well as a custom name can be supplied. We recommend to leave `depth` at three; the name will be localized according to the set language.

Both a list of tables and list of figures may also be generated. Internally, these also use the `#outline(..)` function, however, for ease of use, this template supplies `#table-outline(..)` and `#figure-outline(..)` already. It is recommended to use either when more than five tables or figures are used in a thesis. A shorter caption can also be supplied for this list in case the original one is too long to fit.

This can be achieved with the `#flex-caption()` function. Instead of the actual `caption` argument (which will be explained later), this function can be used instead to supply a long caption in the first argument and a shorter one in the second. See @fig:flex and the code above for an example.

== Tables and Figures

Tables can generally be created with the `#table(..)` function. Similarly, images can be embedded with the `#image("path/to/image")` function. In order to properly and semantically use either of these in a figure, the `#figure(..)` function may be called. The appropriate APA formatting for captions above the table or image (or the usage of annotations) is automatically applied---see @fig:test and @tbl:cite.

=== Tables

The following Typst code will generate a table with three columns, each occupying a third of the page width, as well as an inset between rows and columns of `0.75em` (`em` is a relative unit and is equal to the current text size) and no vertical lines. The `caption` argument represents the table caption.#v(0.5em)

```typ
// Automatic APA 7 like formating.
#figure(caption: [Example table with random data])[
  #table(columns: 3 * (1fr,), stroke: (x: none), inset: 0.75em,
   [x], [y], [z],
   [x], [y], [z],
   [x], [y], [z],
  )
]
```

#figure(caption: [Example table with random data])[
  #table(columns: 3 * (1fr,), stroke: (x: none), inset: 0.75em,
   [x], [y], [z],
   [x], [y], [z],
   [x], [y], [z],
  )
]

See https://typst.app/docs/guides/table-guide/ for a full guide geared towards table creation. Also see https://typst.app/docs/reference/model/table/ for a full syntactical reference of Typst's table syntax. Many more things can be customized such as the thickness of the lines.

=== Images (and similar things)

The following Typst code will create a figure with a caption and a corresponding image. Ideally, only vector graphics should be used (SVG or PDF) in order to guarantee maximum image quality. Formatting and the position of the caption is handled by the template. To add _annotations_ to a figure, use the `#annotation-fig()` function supplied by the template. For multiple images in one figure, see #link("https://typst.app/docs/reference/layout/grid")[_Grid_]. #v(0.5em)

```typ
// flex-caption(long, short) can generate a long and short caption
// for the figure itself and list of figures respectively.
 
#figure(
  caption: flex-caption(
    [Some realllllllllllllllllllllllllllllllllly loooooooooooong caption],
    [A short caption]
  ),
  image("diagram.svg")
)
```

#figure(
  caption: flex-caption(
    [Some realllllllllllllllllllllllllllllllllly loooooooooooong caption],
    [A short caption]
  ),
  image("diagram.svg", width: 70%)
)<fig:flex>

== Referencing Figures

Figures, as well as chapters, sections (@sec:headings), or bibliography entries, can be referenced with Typst's automatic referencing system. In order to add a figure, or any of the other mentioned examples, to the referencing system, a _label_ has to be appended.

#annotation-fig(
  annotation-term: "Annotations",
  annotation: lorem(20),
  rect(),
  caption: "A rectangle, anything could be here!"
)<fig:test>

In this example, the `<fig:test>`#footnote("See the code for this document!") represents the aforementioned label---the name can be arbitrarily chosen, however it is recommended to add prefixes such as `tbl`, `fig` or `sec` to differentiate the different types of elements. This figure can now be referenced through @fig:test by typing `@fig:test`; clicking on it directly jumps to the rectangle.

= Extended Syntax

== Math Equations

Typst has proper first-class support for generating typographically correct math equations. It uses a similar but easier-to-learn syntax in comparison with LaTeX. A distinction has to be made between equations as part of prose, such as, "My result is statistically significant as $p <= alpha$" or proper block equations:

$ sum_(i = 0)^n x^i + 3 xor sqrt(5) $<eq:1>

The _only_ difference in syntax here is that equations in prose are enclosed in dollar-signs whereas block equations are enclosed in dollar-signs and a space. See `$x = 3 dot pi - y^3$` vs. `$ x = 3 dot pi - y^3 $`.

In case it is unclear how certain symbols are named, Typst provides an extensive symbol search here: https://typst.app/docs/reference/symbols/sym/. Additionally, https://detypify.quarticcat.com/ can be used for handwriting recognition of the desired math symbol. Finally, block equations can also be referenced and enumerated: see @eq:1 for a nonsensical equation which only exists to serve as an example.

== Bibliography Management and Citations

Typst supports the common BibTeX standard for bibliography management. Almost all journals nowadays will provide a BibTeX entry for their papers or other publications which can be pasted into a separate `.bib`-file.

Afterwards, the path to said `.bib`-file must be placed into the `bibliography()` part of the `#show`-rule at the top of this document---as an argument to the function. Now, the familiar referencing syntax may be used to cite papers from inside said file: `@paper-title` where `paper-title` represents the name of the specific BibTeX entry: see @martenstein or @Son2019.
Often, especially in the field of psychology, RIS-files are used instead of BibTeX. These can be easily converted on the following website, however: https://www.bruot.org/ris2bib.

By default, this template uses the "APA 7" citation style. Typst supports more than a 1000 different citation styles, even `"deutsche-gesellschaft-für-psychologie"`. Which one to use can often depend on the wishes of the supervisor(s). The "Citation Style Language" (CSL) standard is used to design these styles #sym.arrow #link("https://zotero.org/styles")[Interactive Search].

=== More on Citation Syntax

As the `@`-syntax might not be the best match for in-prose citations, the full `#cite(..)` function with its `form` argument may be used instead. @tbl:cite shows all possible citation forms and their corresponding syntax. #footnote[In most cases, the default and prose form should suffice.]

This table also uses an optional APA requirement: _annotations_ as sub-captions. To use it, the `#annotation-table(..)` function with the additional `annotation` argument may be used instead of the usual `#table(..)`.

#figure(caption: [Different ways to display citations and references])[
  #set par(justify: false)
  #annotation-table(
    annotation-term: "Annotations",
    annotation: [Short form for prose: `p:`-prefix. See IPSY guidelines for instructions on correct usage.],
    columns: 2 * (1fr,), stroke: none, inset: 0.75em, align: left,
    /* --- Tabelleninhalt beginnt hier. --- */
    table.hline(stroke: 1pt),
    table.header([Typst Syntax], [Typst Output]),
    table.hline(),
    [`@netwok2020` oder\ `#cite(<netwok2020>, form: "normal")`], [@netwok2020],
    [`@p:netwok2020` oder `#cite(<netwok2020>, form: "prose")`], [@p:netwok2020],
    `#cite(<netwok2020>, form: "author")`, cite(<netwok2020>, form: "author"),
    `#cite(<netwok2020>, form: "year")`, cite(<netwok2020>, form: "year"),
    `#cite(<netwok2020>, form: "full")`, par(justify: true, cite(<netwok2020>, form: "full")),
    table.hline(stroke: 1pt),
  )
]<tbl:cite>

=== Block Quotes

Block quotes may be used for direct quotes with more than 40 words. This is achieved with the `#quote(..)` function. The source may be specified with the `attribution` argument using the familiar `@`-symbol, additionally with the corresponding pages (`@test[pp. 3--4]`).

#quote(attribution: [@martenstein[S. 6]])[
  Ich finde es ein bisschen albern, wenn Leute in solchen Zusammenhängen das Wort
  „unnatürlich“ verwenden. Was, bitte schön, ist an unserem heutigen Leben denn noch
  natürlich? ... Wenn es nach der Natur ginge, dann würden wir alle mit vierzig Jahren
  [oder bereits früher] sterben. ... Natur – der schlimmste [Hervorhebung hinzugefügt]
  Feind des Menschen. Der Natur fallen mehr Menschen zum Opfer als Atomkraftwerks-
  unglücken, Rauschgift, Terror und Flugzeugabstürzen zusammengenommen. ... Bleibt
  mir bloß mit der Natur vom Leib.
]

If a quote spans multiple pages, the interval shall be specified with an en-dash, not a single hyphen. Those are reserved for hyphenation of compound words.

=== Normal Quotes

"A normal quote can simply be put into quotation marks which change according to the set language" @martenstein[p. 6].

== Lists and Enumerations

Lists may be used for TODOs or general enumerations. Unnumbered lists, or bullet points, use the `"-"` symbol while numbered lists use the `"+"` symbol (see @sec:list and @sec:enum). Lists can either be tight or wide, depending on whether the list entries are separated by a newline or not.

=== Unnumbered Lists<sec:list>

- #lorem(10)

- #lorem(12)

  - Sublist for additional explanations

  - Something else...

=== Numbered Lists<sec:enum>

+ #lorem(10)

+ A listing of instructions perhaps

  + Subelement 2.1 for more specific instructions

= Miscellaneous

== File Structure for Chapters

Writing a whole thesis in one file can quickly get unwieldy, so it is recommended to create one file per chapter, at the very least. This is easily achievable with the `#include \"example.typ\"` function at the exact place where the chapter should be put. Usually, some variant of the following structure will emerge if proper care is taken to split up a large document:

#figure(caption: flex-caption([Exemplary file structure for this template. The `include` function may be thought of as a form of "Copy-and-Paste" and creates a coherent structure], "Exemplary file structure for this template."), kind: image)[
  ```typ
  #import "ipsy/ipsy.typ": *
  #show: ipsy.with(            // See Chapter 1: Here, we define
    title: [Title],            // a title page for this document.
    ..,
  )
  
  #outline()                   // Table of Contents
  #table-outline()             // List of Tables
  #figure-outline()            // List of Figures  
  
  #include "introduction.typ"  // It may also make sense to create a more
  #include "background.typ"    // sophisticated folder structure for each
  #include "discussion.typ"    // chapter and its figures for proper
  #include "results.typ"       // organisation.
  ...
  ```
]

Looking at the beginning of this document reveals that this technique was already utilized for the abstract.

== Spell-Check

The Typst web app contains a spellchecking feature which has to be enabled in the project settings under "Enable spellchecking".

Should the user use a different editor, these external tools may also be of assistance: https://mentor.duden.de and https://languagetool.org. These allow manual checks by pasting in one paragraph at a time; better than no spellchecking at least.

== Custom Functions

Typst is very extensible and as such, custom functions to assist in writing can be created. A simple example could be a custom `#todo[xyz]` function which creates a yellow rectangle with a black stroke and includes the prefix "*TODO:*". It could then accept a textual argument specifying what still needs to be done.

This saves potential repetition if many TODOs are sprinkled all over the document and acts as a hard-to-miss reminder not to leave it in the final draft. The code for this function could look as follows:


#figure(kind: image, caption: [Function definition of a custom TODO-box.])[
  ```typ 
  #let todo(txt) = rect(stroke: 0.5pt, fill: yellow)[*TODO:* #emph(txt)]
  ```
]

Calling the function like this: `#todo[Add fitting graph here!]` leads to the following result:

#let todo(txt) = rect(stroke: 0.5pt, fill: yellow)[*TODO:* #emph(txt)]
#todo[Add fitting graph here!]

== Appendix

An appendix can be created with the `#appendix(title, lbl: none)[...]` function. Similar to the abstract, it is recommended to use a separate file for the appendix which can then be included as shown in @tbl:args.
The appendix needs a `title` and an optional _label_ (`lbl`) which is then used as a prefix for figures within.

#figure(caption: "Creating an appendix. Ideally done in an external file.", kind: image)[
  ```typ
  #begin-appendix
  #appendix("Titel", lbl: <appendix>)[
    #figure(..)
    #figure(..)
    #figure(..)
  ]
  ```
]<fig:app-creation>

Arbitrary _content_ can then be put in between the brackets; usually the figures the user wishes to put into the appendix (see @fig:app-creation). The `#begin-appendix` function is needed to reset the numbering of chapters and sections within the appendix such that they begin with an "A" instead of, for example, "D".
Figures inside the appendix can also be appended with labels and use the prefix specified with the `lbl` argument: _"See @app and @app:image, @app:image2 and @app:image3 (maybe even: @app:tbl)."_
