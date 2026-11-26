#import "@preview/kaodiss:0.1.0": *

= Introduction <ch:introduction>

#epigraph(attribution: [Edward R. Tufte #cite(<tufte2001visual>, form: "year")])[
  "Above all else show the data."
]

This chapter introduces the main elements of the template. Every chapter
starts on a right-hand page. Its number sits in the margin, separated from the
title by a vertical rule, and the margin lists the sections of the chapter.

The text block is 107 mm wide and holds about 460 words on a full page,
roughly nine words per line. Everything else lives in the
margin.#sidenote[Sidenotes are numbered per chapter. A `#footnote` is turned
into a sidenote as well, so existing text needs no changes.]

== Writing with the Template <sec:writing>

Chapters, sections and subsections are written with Typst's usual heading
markup (`=`, `==`, `===`). Up to three levels are numbered and listed in the
table of contents. Level four gives unnumbered headings, and a run-in heading
starts a paragraph with a bold title:

#paragraph[Run-in headings.] They are created with `#paragraph[Title.]` and
correspond to `\paragraph` in LaTeX.

=== Abbreviations

Abbreviations are written like references. The first use of @pdf prints the
long form, every further use only the short form: @pdf. Plurals and explicit
forms are available as `@api[pl]` (@api[pl]), `@ui[long]` (@ui[long]) and
`@ui[short]` (@ui[short]). The list of abbreviations at the end of the document
shows every page on which an abbreviation was used. Glossary entries work the
same way: good @kerning matters most in large headings.

=== Citations

Citations use Typst's `@key` syntax. The default style, `nature-authoryear`,
gives author and year in the text
@knuth1984literate, a numbered bibliography sorted by author, and back
references to all pages on which a source was cited. Several sources are
cited together like this @knuth1984literate @tufte2001visual @kaobook. A
citation in prose reads #cite(<tufte2001visual>, form: "prose").

=== Challenges and Objectives

Grey boxes for the challenges and objectives of a thesis are available as
`#challenge` and `#objective`. They are numbered automatically and can be
referenced (@chal:context, @obj:layout).

#challenge[
  Readers of long technical documents lose track of how notes, figures and
  references relate to the text they belong to.
] <chal:context>

#objective[
  Provide a page layout that keeps notes, figures and references next to the
  text they belong to.
] <obj:layout>

== Outline

@ch:foundations shows figures, tables and mathematics,
@ch:features code listings and other elements, and @app:material the
appendix.
